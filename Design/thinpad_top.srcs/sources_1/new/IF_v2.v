`include "HEADER.v"

module IF_v2(
    input wire              clk,
    input wire              rst,

    output reg              base_ram_ce,
    output wire[19:0]        base_ram_addr,

    output reg[31:0]        if_pc,

    input wire              branch_flag,
    input wire[31:0]        branch_addr,

    input wire              stallreq_id,
    input wire              stallreq_mem,

    output wire             stall
    );

    assign stall = stallreq_id || stallreq_mem;
    assign base_ram_addr = if_pc[21:2];
    
    always @ (posedge clk) begin
        if (rst == `HIGH) begin                 //reset
            if_pc <= `PC_START;
            base_ram_ce <= `DISABLE;
        end
        else if (stall == `HIGH) begin          //stall
            if_pc <= if_pc;
            base_ram_ce <= `ENABLE;
        end
        else if (branch_flag == `HIGH) begin    //branch
            if_pc <= branch_addr;
            base_ram_ce <= `ENABLE;
        end
        else begin                              //normal
            if_pc <= if_pc + 4'h4;
            base_ram_ce <= `ENABLE;
        end
    end
endmodule