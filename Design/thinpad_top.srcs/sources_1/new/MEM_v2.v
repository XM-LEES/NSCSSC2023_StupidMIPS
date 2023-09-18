`include "HEADER.v"

module MEM_v2(
    input wire              rst,

    input wire              reg_req_in,
    output reg              reg_req_out,
    input wire[4:0]         reg_waddr_in,
    output reg[4:0]         reg_waddr_out,
    input wire[31:0]        ex_val_in,

    output reg[31:0]        reg_val,

    input wire[2:0]         mem_type,
    input wire[31:0]        mem_addr,
    input wire[31:0]        mem_val_in,

    //ram
    input wire[31:0]        ram_data_load,
    
    output reg              ram_cen,
    output reg              ram_wen_n,
    output reg[19:0]        ram_addr,

    output reg[31:0]        ram_data_store,
    output reg[3:0]         ram_sel_n,

    output wire             serial_state_req,
    output wire             serial_data_req,
    output wire             baseram_req,
    output wire             extram_req,

    output wire             stallreq
    );

    assign stallreq = (mem_type != `NOMEM) && (mem_addr >= 32'h80000000) && (mem_addr < 32'h80400000);
//    assign stallreq = (mem_addr >= 32'h80000000) && (mem_addr < 32'h80400000);


    assign serial_state_req = (mem_addr ==  `SerialState_addr); 
    assign serial_data_req  = (mem_addr == `SerialData_addr);
    assign baseram_req    = (mem_addr >= 32'h80000000) && (mem_addr < 32'h80400000);
    assign extram_req     = (mem_addr >= 32'h80400000) && (mem_addr < 32'h80800000);

    always @ (*) begin
        if (rst == `HIGH) begin
            reg_req_out = `LOW;
            reg_waddr_out = `ZERO5;
            reg_val = `ZERO32;

            ram_cen = `DISABLE;
            ram_wen_n = `DISABLE_N;
            ram_addr = `ZERO20;
            ram_data_store = `ZERO32;
            ram_sel_n = 4'b1111;
        end
        else begin
            reg_req_out = reg_req_in;
            reg_waddr_out = reg_waddr_in;
            ram_cen = `ENABLE;
        end
        case(mem_type)
            `NOMEM: begin
                reg_val = ex_val_in;               
                ram_wen_n = `DISABLE_N;
                ram_addr = `ZERO20;
                ram_data_store = `ZERO32;
                ram_sel_n = 4'b1111;
            end
            `MEM_LW: begin
                reg_val = ram_data_load;
                ram_wen_n = `DISABLE_N;
                ram_addr = mem_addr[21:2];
                ram_data_store = `ZERO32;
                ram_sel_n = 4'b0000;
            end
            `MEM_LB: begin
                reg_val = ram_data_load;
                ram_wen_n = `DISABLE_N;
                ram_addr = mem_addr[21:2];
                ram_data_store = `ZERO32;
                case(mem_addr[1:0])
                    2'b00: begin
                        ram_sel_n = 4'b1110;
                    end 
                    2'b01: begin
                        ram_sel_n = 4'b1101;
                    end
                    2'b10: begin
                        ram_sel_n = 4'b1011;
                    end
                    2'b11: begin
                        ram_sel_n = 4'b0111;
                    end
                    default : begin
                        ram_sel_n = 4'b1111;
                    end
                endcase
            end
            `MEM_SW: begin
                reg_val = `ZERO32;
                ram_wen_n = `ENABLE_N;
                ram_addr = mem_addr[21:2];
                ram_data_store = mem_val_in;
                ram_sel_n = 4'b0000;
            end
            `MEM_SB: begin
                reg_val = `ZERO32;
                ram_wen_n = `ENABLE_N;
                ram_addr = mem_addr[21:2];
                ram_data_store = {4{mem_val_in[7:0]}};   
                case(mem_addr[1:0])
                        2'b00: begin
                            ram_sel_n = 4'b1110;
                        end 
                        2'b01: begin
                            ram_sel_n = 4'b1101;
                        end
                        2'b10: begin
                            ram_sel_n = 4'b1011;
                        end
                        2'b11: begin
                            ram_sel_n = 4'b0111;
                        end
                        default : begin
                            ram_sel_n = 4'b1111;
                        end
                endcase
            end
            default: begin
                reg_val = ex_val_in;               
                ram_wen_n = `DISABLE_N;
                ram_addr = `ZERO20;
                ram_data_store = `ZERO32;
                ram_sel_n = 4'b1111;
            end
        endcase
    end
endmodule