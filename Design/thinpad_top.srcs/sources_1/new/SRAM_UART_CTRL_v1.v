`include "HEADER.v"

module RAM_Serial_Controller (
    input wire clk,
    input wire rst,

    input wire          serial_state_req,
    input wire          serial_data_req,
    input wire          baseram_req,
    input wire          extram_req,


    //to if
    input    wire[19:0]  rom_addr_i,
    input    wire        rom_ce_i,
    output   reg [31:0]  inst_o,

    //to mem
    output   reg[31:0]   ram_data_o,
    input    wire[19:0]  mem_addr_i,
    input    wire[31:0]  mem_data_i,
    input    wire        mem_we_n,
    input    wire[3:0]   mem_sel_n,
    input    wire        mem_ce_i,

    //to BaseRAM
    inout    wire[31:0]  base_ram_data,
    output   reg [19:0]  base_ram_addr,
    output   reg [3:0]   base_ram_be_n,
    output   reg         base_ram_ce_n,
    output   reg         base_ram_oe_n,
    output   reg         base_ram_we_n,

    //to ExtRAM
    inout    wire[31:0]  ext_ram_data,
    output   reg [19:0]  ext_ram_addr,
    output   reg [3:0]   ext_ram_be_n,
    output   reg         ext_ram_ce_n,
    output   reg         ext_ram_oe_n,
    output   reg         ext_ram_we_n,

    //直连串口信号
    output   wire        txd,
    input    wire        rxd
);



// Serial Controller, referencing XZMIPS' design, using fifo IP core
//https://github.com/xiazhuo/nscc2022_personal/blob/main/thinpad_top.srcs/sources_1/XZMIPS/RAM_Serial_ctrl.v
wire [7:0]  RxD_data;           //received data
wire [7:0]  TxD_data;           //transmitted data
wire        RxD_data_ready;
wire        TxD_busy;
wire        TxD_start;
wire        RxD_clear;

wire        RxD_FIFO_full;
reg         RxD_FIFO_rd_en;
wire        RxD_FIFO_empty;
wire [7:0]  RxD_FIFO_dout;

reg         TxD_FIFO_wr_en;
wire        TxD_FIFO_full;
reg  [7:0]  TxD_FIFO_din;
wire        TxD_FIFO_empty;

async_receiver #(.ClkFrequency(58000000),.Baud(9600))   //接收模块
                ext_uart_r(
                   .clk(clk),                           //外部时钟信号
                   .RxD(rxd),                           //外部串行信号输入
                   .RxD_data_ready(RxD_data_ready),     //数据接收到标志
                   .RxD_clear(RxD_clear),               //清除接收标志
                   .RxD_data(RxD_data)                  //接收到的一字节数据
                );

async_transmitter #(.ClkFrequency(58000000),.Baud(9600)) //发送模块
                    ext_uart_t(
                      .clk(clk),                        //外部时钟信号
                      .TxD(txd),                        //串行信号输出
                      .TxD_busy(TxD_busy),              //发送器忙状态指示
                      .TxD_start(TxD_start),            //开始发送信号
                      .TxD_data(TxD_data)               //待发送的数据
                    );

//fifo接收模块
fifo_generator_0 RXD_FIFO (
    .rst(rst),
    .clk(clk),
    .wr_en(RxD_data_ready),     //写使能
    .din(RxD_data),         //接收到的数据
    .full(RxD_FIFO_full),       //判满标志
    .rd_en(RxD_FIFO_rd_en),     //读使能
    .dout(RxD_FIFO_dout),       //传递给mem阶段读出的数据
    .empty(RxD_FIFO_empty)      //判空标志
);

//fifo发送模块
fifo_generator_0 TXD_FIFO (
    .rst(rst),
    .clk(clk),
    .wr_en(TxD_FIFO_wr_en),     //写使能
    .din(TxD_FIFO_din),         //需要发送的数据
    .full(TxD_FIFO_full),       //判满标志

    .rd_en(TxD_start),     //读使能，为1时串口取出数据发送
    .dout(TxD_data),       //传递给串口待发送的数据
    .empty(TxD_FIFO_empty)      //判空标志
);
////////////////////////////////////////////////////////////
reg [31:0] serial_o;        //串口输出数据
wire[31:0] base_ram_o;      //baseram输出数据
wire[31:0] ext_ram_o;       //extram输出数据

assign TxD_start = (!TxD_busy) && (!TxD_FIFO_empty);
assign RxD_clear = RxD_data_ready && (!RxD_FIFO_full);

always @(*) begin
    TxD_FIFO_wr_en = `LOW;
    TxD_FIFO_din = `ZERO8;
    RxD_FIFO_rd_en = `LOW;
    serial_o = `ZERO32;
    if(serial_state_req) begin
        TxD_FIFO_wr_en = `LOW;
        TxD_FIFO_din = `ZERO8;
        RxD_FIFO_rd_en = `LOW;
        serial_o = {{30{1'b0}}, !RxD_FIFO_empty,!TxD_FIFO_full};
    end 
    else if(serial_data_req) begin
        if(mem_we_n == `HIGH) begin
            TxD_FIFO_wr_en = `LOW;
            TxD_FIFO_din = `ZERO8;
            RxD_FIFO_rd_en = `HIGH;
            serial_o = {{24{1'b0}}, RxD_FIFO_dout};
        end
        else begin
            TxD_FIFO_wr_en = `HIGH;
            TxD_FIFO_din = mem_data_i[7:0];
            RxD_FIFO_rd_en = `LOW;
            serial_o = `ZERO32;
        end
    end
    else begin
        TxD_FIFO_wr_en = `LOW;
        TxD_FIFO_din = `ZERO8;
        RxD_FIFO_rd_en = `LOW;
        serial_o = `ZERO32;
    end
end


//BaseRam
assign base_ram_data = baseram_req ? ((mem_we_n == `ENABLE_N) ? mem_data_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
assign base_ram_o = base_ram_data;

always @(*) begin
    if(baseram_req) begin
        base_ram_addr = mem_addr_i;
        base_ram_be_n = mem_sel_n;
        base_ram_ce_n = `ENABLE_N;
        base_ram_oe_n = !mem_we_n;
        base_ram_we_n = mem_we_n;
        inst_o = `ZERO32;
    end else begin
        base_ram_addr = rom_addr_i;
        base_ram_be_n = `ZERO4;
        base_ram_ce_n = `ENABLE_N;
        base_ram_oe_n = `ENABLE_N;
        base_ram_we_n = `DISABLE_N;
        inst_o = base_ram_o;
    end
end


//ExtRam
assign ext_ram_data = extram_req ? ((mem_we_n == `ENABLE_N) ? mem_data_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
assign ext_ram_o = ext_ram_data;

always @(*) begin
    if(extram_req) begin
        ext_ram_addr = mem_addr_i;
        ext_ram_be_n = mem_sel_n;
        ext_ram_ce_n = `ENABLE_N;
        ext_ram_oe_n = !mem_we_n;
        ext_ram_we_n = mem_we_n;
    end else begin
        ext_ram_addr = `ZERO20;
        ext_ram_be_n = `ZERO4;
        ext_ram_ce_n = `DISABLE_N;
        ext_ram_oe_n = `DISABLE_N;
        ext_ram_we_n = `DISABLE_N;
    end
end


//for lb sb, read a word, then process according to chip-select signal
always @(*) begin
    ram_data_o = `ZERO32;
    if(serial_state_req || serial_data_req ) begin
        ram_data_o = serial_o;
    end else if (baseram_req) begin
        case (mem_sel_n)
            4'b1110: begin
                ram_data_o = {{24{base_ram_o[7]}}, base_ram_o[7:0]};
            end
            4'b1101: begin
                ram_data_o = {{24{base_ram_o[15]}}, base_ram_o[15:8]};
            end
            4'b1011: begin
                ram_data_o = {{24{base_ram_o[23]}}, base_ram_o[23:16]};
            end
            4'b0111: begin
                ram_data_o = {{24{base_ram_o[31]}}, base_ram_o[31:24]};
            end
            4'b0000: begin
                ram_data_o = base_ram_o;
            end
            default: begin
                ram_data_o = base_ram_o;
            end
        endcase
    end else if (extram_req) begin
        case (mem_sel_n)
            4'b1110: begin
                ram_data_o = {{24{ext_ram_o[7]}}, ext_ram_o[7:0]};
            end
            4'b1101: begin
                ram_data_o = {{24{ext_ram_o[15]}}, ext_ram_o[15:8]};
            end
            4'b1011: begin
                ram_data_o = {{24{ext_ram_o[23]}}, ext_ram_o[23:16]};
            end
            4'b0111: begin
                ram_data_o = {{24{ext_ram_o[31]}}, ext_ram_o[31:24]};
            end
            4'b0000: begin
                ram_data_o = ext_ram_o;
            end
            default: begin
                ram_data_o = ext_ram_o;
            end
        endcase
    end else begin
        ram_data_o = `ZERO32;
    end
end

endmodule