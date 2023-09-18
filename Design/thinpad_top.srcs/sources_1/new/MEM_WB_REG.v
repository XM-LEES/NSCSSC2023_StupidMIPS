`include "HEADER.v"

module MEM_WB_REG(
    input wire              clk,
    input wire              rst,

    input wire              reg_req_in,
    input wire[4:0]         reg_waddr_in,
    input wire[31:0]        reg_val_in,

    output reg              reg_req_out,
    output reg[4:0]         reg_waddr_out,
    output reg[31:0]        reg_val_out
    );

    always @ (posedge clk) begin
        if (rst == `HIGH) begin
            reg_req_out <= `LOW;
            reg_val_out <= `ZERO32;
            reg_waddr_out <= `ZERO5;
        end
        else begin
            reg_req_out <= reg_req_in;
            reg_val_out <= reg_val_in;
            reg_waddr_out <= reg_waddr_in;
        end
    end
endmodule