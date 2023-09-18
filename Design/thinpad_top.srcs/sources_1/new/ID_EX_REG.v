`include "HEADER.v"

module ID_EX_REG(
    input wire              clk,
    input wire              rst,
    input wire              stall,

    input wire[31:0]        id_pc,
    output reg[31:0]        ex_pc,

    input wire[5:0]         alu_op_in,
    output reg[5:0]         alu_op_out,

    input wire[31:0]        operand1_in,
    output reg[31:0]        operand1_out,
    input wire[31:0]        operand2_in,
    output reg[31:0]        operand2_out,

    input wire              reg_req_in,
    output reg              reg_req_out,
    input wire[4:0]         waddr_in,
    output reg[4:0]         waddr_out,

    input wire[15:0]        imm_in,
    output reg[15:0]        imm_out
    );

    always @(posedge clk) begin
        if ((rst == `HIGH) || (stall == `HIGH)) begin
            ex_pc <= `ZERO32;
            alu_op_out <= `NOP;
            operand1_out <= `ZERO32;
            operand2_out <= `ZERO32;
            reg_req_out <= `LOW;
            waddr_out <= `ZERO5;
            imm_out <= `ZERO16;
        end
        else begin
            ex_pc <= id_pc;
            alu_op_out <= alu_op_in;
            operand1_out <= operand1_in;
            operand2_out <= operand2_in;
            reg_req_out <= reg_req_in;
            waddr_out <= waddr_in;
            imm_out <= imm_in;
        end
    end
endmodule