`include "HEADER.v"

module EX_MEM_REG(
    input wire              clk,
    input wire              rst,

    input wire              reg_req_in,
    output reg              reg_req_out,
    input wire[4:0]         reg_waddr_in,
    output reg[4:0]         reg_waddr_out,
    input wire[31:0]        ex_val_in,
    output reg[31:0]        ex_val_out,
    
    input wire[2:0]         mem_type_in,
    output reg[2:0]         mem_type_out,
    input wire[31:0]        mem_addr_in,
    output reg[31:0]        mem_addr_out,
    input wire[31:0]        mem_val_in,
    output reg[31:0]        mem_val_out
    );

    always @ (posedge clk) begin
        if (rst == `HIGH) begin
            reg_req_out <= `LOW;
            reg_waddr_out <= `ZERO5;
            ex_val_out <= `ZERO32;
            mem_type_out <= `NOMEM;
            mem_addr_out <= `ZERO32;
            mem_val_out <= `ZERO32;
        end
        else begin
            reg_req_out <= reg_req_in;
            reg_waddr_out <= reg_waddr_in;
            ex_val_out <= ex_val_in;
            mem_type_out <= mem_type_in;
            mem_addr_out <= mem_addr_in;
            mem_val_out <= mem_val_in;
        end
    end
endmodule