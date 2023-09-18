`include "HEADER.v"

module IF_ID_REG(
    input wire              clk,
    input wire              rst,
    input wire              stall,

    input wire[31:0]        if_pc,
    output reg[31:0]        id_pc,
    input wire[31:0]        if_inst,
    output reg[31:0]        id_inst
    );

    always @(posedge clk) begin
        if (rst == `HIGH) begin             //reset
            id_pc <= `ZERO32;
            id_inst <= `ZERO32;
        end
        else if (stall == `HIGH) begin      //stall
            id_pc <= id_pc;
            id_inst <= id_inst;
        end
        else begin                          //normal
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule