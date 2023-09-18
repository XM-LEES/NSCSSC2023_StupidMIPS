`include "HEADER.v"

module EXE_v2(
    input wire              rst,

    input wire[31:0]        ex_pc_in,

    input wire[5:0]         alu_op,
    input wire[31:0]        operand1,
    input wire[31:0]        operand2,
    input wire              reg_req_in,
    output reg              reg_req_out,
    input wire[4:0]         waddr_in,
    output reg[4:0]         waddr_out,
    output reg[31:0]        ex_val,
    input wire[15:0]        imm,

    //mem
    output reg[2:0]         mem_type,
    output reg[31:0]        mem_addr,
    output reg[31:0]        mem_val,

    output wire             is_load
    );

    assign is_load = (alu_op == `LB) || (alu_op == `LW);
    
    always @ (*) begin
        if (rst == `HIGH) begin
            reg_req_out = `LOW;
            ex_val = `ZERO32;
            waddr_out = `ZERO5;
            mem_type = `NOMEM;
            mem_addr = `ZERO32;
            mem_val = `ZERO32;
        end
        else begin
            waddr_out = waddr_in;
            case (alu_op)
                `NOP: begin
                    reg_req_out = `LOW;
                    ex_val = `ZERO32;
                    
                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `AND: begin
                    reg_req_out = `HIGH;
                    ex_val = operand1 & operand2;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `OR: begin
                    reg_req_out = `HIGH;
                    ex_val = operand1 | operand2;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `XOR: begin
                    reg_req_out = `HIGH;
                    ex_val = operand1 ^ operand2;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `SLL: begin
                    reg_req_out = `HIGH;
                    ex_val = operand2 << operand1[4:0];

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `SRL: begin
                    reg_req_out = `HIGH;
                    ex_val = operand2 >> operand1[4:0];

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `ADD: begin
                    reg_req_out = `HIGH;
                    ex_val = operand1 + operand2;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `JAL: begin
                    reg_req_out = `HIGH;
                    ex_val = ex_pc_in + 4'h8;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `LB: begin
                    reg_req_out = `HIGH;
                    ex_val = `ZERO32;

                    mem_type = `MEM_LB;
                    mem_addr = operand1 + operand2;
                    mem_val = `ZERO32;
                end
                `LW: begin
                    reg_req_out = `HIGH;
                    ex_val = `ZERO32;

                    mem_type = `MEM_LW;
                    mem_addr = operand1 + operand2;
                    mem_val = `ZERO32;
                end
                `SB: begin
                    reg_req_out = `LOW;
                    ex_val = `ZERO32;

                    mem_type = `MEM_SB;
                    mem_addr = operand1 + {{16{imm[15]}}, imm};
                    mem_val = operand2;
                end
                `SW: begin
                    reg_req_out = `LOW;
                    ex_val = `ZERO32;

                    mem_type = `MEM_SW;
                    mem_addr = operand1 + {{16{imm[15]}}, imm};
                    mem_val = operand2;
                end
                `MUL: begin
                    reg_req_out = `HIGH;
                    ex_val = operand1 * operand2;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `SLT: begin
                    reg_req_out = `HIGH;
                    ex_val = (operand1 < operand2) ? 1 : 0;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                `SRA: begin
                    reg_req_out = `HIGH;
                    ex_val = ($signed(operand2)) >>> operand1;

                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;
                end
                default: begin
                    reg_req_out = `LOW;
                    ex_val = `ZERO32;
                    mem_type = `NOMEM;
                    mem_addr = `ZERO32;
                    mem_val = `ZERO32;  
                end
            endcase
        end
    end

endmodule
