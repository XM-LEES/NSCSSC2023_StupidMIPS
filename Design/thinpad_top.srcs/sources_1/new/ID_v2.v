`include "HEADER.v"

module ID_v2(
    input wire              rst,

    input wire[31:0]        id_pc_in,
    output reg[31:0]        id_pc_out,
    input wire[31:0]        id_inst,

    output reg[5:0]         alu_op,
    output reg[31:0]        operand1,
    output reg[31:0]        operand2,
    output reg              reg_req,
    output reg[4:0]         waddr,
    output wire[15:0]       imm_out,

    output reg[4:0]         raddr1, 
    output reg[4:0]         raddr2,
    output reg              ren1,
    output reg              ren2,
    input wire[31:0]        reg_val1,
    input wire[31:0]        reg_val2,

    //branch
    output reg              branch_flag,
    output reg[31:0]        branch_addr,
    
    //data forwarding
    input wire              ex_reg_req,
    input wire[4:0]         ex_waddr,
    input wire[31:0]        ex_data,

    input wire              mem_reg_req,
    input wire[4:0]         mem_waddr,
    input wire[31:0]        mem_data,

    //load-use hazard
    input wire              ex_is_load,

    //stall request
    output wire             stallreq
    );


    wire[5:0] opcode        = id_inst[31:26];
    wire[4:0] rs            = id_inst[25:21];
    wire[4:0] rt            = id_inst[20:16];
    wire[4:0] rd            = id_inst[15:11];
    wire[4:0] sft_amt       = id_inst[10:6];
    wire[5:0] func          = id_inst[5:0];
    wire[15:0] imm          = id_inst[15:0];
    wire[25:0] inst_idx     = id_inst[25:0];
    wire[31:0] pc_slot      = id_pc_in + 4'h4;

    //imm_out
    assign imm_out = imm;
    wire[31:0] imm_ext_u    = {16'h0000, imm};
    wire[31:0] imm_ext_s    = {{16{imm[15]}}, imm};
    reg[31:0] imm_32        = `ZERO32;


    
    //branch_flag
    //branch_addr
    always @ (*) begin
        if (rst == `HIGH) begin
            branch_addr = `ZERO32;
            branch_flag = `LOW;
        end
        else begin
            branch_addr = `ZERO32;
            branch_flag = `LOW;
            case (opcode)
                `BEQ_OP: begin
                    if (operand1 == operand2) begin
                        branch_flag = `HIGH;
                        branch_addr = id_pc_in + 4'h4 + {imm_ext_s[29:0], 2'b00};
                    end
                end
                `BGTZ_OP: begin
                    if (operand1 > `ZERO32) begin
                        branch_flag = `HIGH;
                        branch_addr = id_pc_in + 4'h4 + {imm_ext_s[29:0], 2'b00};
                    end
                end
                `BGEZ_OP: begin
                    if (operand1 >= `ZERO32) begin
                        branch_flag = `HIGH;
                        branch_addr = id_pc_in + 4'h4 + {imm_ext_s[29:0], 2'b00};
                    end
                end
                `BNE_OP: begin
                    if (operand1 != operand2) begin
                        branch_flag = `HIGH;
                        branch_addr = id_pc_in + 4'h4 + {imm_ext_s[29:0], 2'b00};
                    end
                end
                `J_OP: begin
                    branch_flag = `HIGH;
                    branch_addr = {pc_slot[31:28], inst_idx[25:0], 2'b00};
                end
                `JAL_OP: begin
                    branch_flag = `HIGH;
                    branch_addr = {pc_slot[31:28], inst_idx[25:0], 2'b00};
                end
                `RTYPE_OP: begin
                    case (func)
                        `JR_FUN: begin
                            branch_flag = `HIGH;
                            branch_addr = operand1;
                        end
                        default: begin
                        end
                    endcase
                end
                default: begin
                end
            endcase
        end
    end


    // load-use hazard
    assign stallreq = (ex_is_load && ((raddr1 == ex_waddr && ren1 == `ENABLE) || (raddr2 == ex_waddr && ren2 == `ENABLE)));

    //Decode
    always @ (*) begin
        if ((rst == `HIGH) || (id_inst == 32'h00000000)) begin
            id_pc_out = `ZERO32;
            alu_op = `NOP;
            waddr = `ZERO5;
            reg_req = `LOW;

            ren1 = `DISABLE;
            ren2 = `DISABLE;
            raddr1 = `ZERO5;
            raddr2 = `ZERO5;
            imm_32 = `ZERO32;
        end
        else begin
            id_pc_out = id_pc_in;
            case (opcode)
                `ANDI_OP: begin
                    alu_op = `AND;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_u;
                end
                `LUI_OP: begin
                    alu_op = `OR;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = {imm, 16'h0000};
                end
                `ORI_OP: begin
                    alu_op = `OR;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_u;
                end
                `XORI_OP: begin
                    alu_op = `XOR;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_u;
                end
                `ADDIU_OP: begin
                    alu_op = `ADD;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_s;
                end
                `BEQ_OP: begin
                    alu_op = `NOP;
                    ren1 = `ENABLE;
                    ren2 = `ENABLE;
                    raddr1 = rs;
                    raddr2 = rt;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;
                end
                `BNE_OP: begin
                    alu_op = `NOP;
                    ren1 = `ENABLE;
                    ren2 = `ENABLE;
                    raddr1 = rs;
                    raddr2 = rt;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;
                end
                `BGTZ_OP: begin
                    alu_op = `NOP;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;
                end
                `BGEZ_OP: begin
                    alu_op = `NOP;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;
                end
                `J_OP: begin
                    alu_op = `NOP;
                    ren1 = `DISABLE;
                    ren2 = `DISABLE;
                    raddr1 = `ZERO5;
                    raddr2 = `ZERO5;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;
                end
                `JAL_OP: begin
                    alu_op = `JAL;
                    ren1 = `DISABLE;
                    ren2 = `DISABLE;
                    raddr1 = `ZERO5;
                    raddr2 = `ZERO5;
                    waddr = 5'b11111;
                    reg_req = `HIGH;
                    imm_32 = `ZERO32;
                end
                `LB_OP: begin
                    alu_op = `LB;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_s;
                end
                `SB_OP: begin
                    alu_op = `SB;
                    ren1 = `ENABLE;
                    ren2 = `ENABLE;
                    raddr1 = rs;
                    raddr2 = rt;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = `ZERO32;     //notice: imm16
                end
                `LW_OP: begin
                    alu_op = `LW;
                    ren1 = `ENABLE;
                    ren2 = `DISABLE;
                    raddr1 = rs;
                    raddr2 = `ZERO5;
                    waddr = rt;
                    reg_req = `HIGH;
                    imm_32 = imm_ext_s;
                end
                `SW_OP: begin
                    alu_op = `SW;
                    ren1 = `ENABLE;
                    ren2 = `ENABLE;
                    raddr1 = rs;
                    raddr2 = rt;
                    waddr = `ZERO5;
                    reg_req = `LOW;
                    imm_32 = imm_ext_s;
                end
                `MUL_OP: begin
                    alu_op = `MUL;
                    ren1 = `ENABLE;
                    ren2 = `ENABLE;
                    raddr1 = rs;
                    raddr2 = rt;
                    waddr =rd;
                    reg_req = `HIGH;
                    imm_32 = `ZERO32;
                end
                `RTYPE_OP: begin  
                    case (func)
                    `AND_FUN: begin
                        alu_op = `AND;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    `OR_FUN: begin
                        alu_op = `OR;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    `XOR_FUN: begin
                        alu_op = `XOR;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    `SLL_FUN: begin
                        alu_op = `SLL;
                        ren1 = `DISABLE;
                        ren2 = `ENABLE;
                        raddr1 = `ZERO5;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32[4:0] = sft_amt;
                    end
                    `SRL_FUN: begin
                        alu_op = `SRL;
                        ren1 = `DISABLE;
                        ren2 = `ENABLE;
                        raddr1 = `ZERO5;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32[4:0] = sft_amt;
                    end
                    `ADDU_FUN: begin
                        alu_op = `ADD;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    `JR_FUN: begin
                        alu_op = `NOP;
                        ren1 = `ENABLE;
                        ren2 = `DISABLE;
                        raddr1 = rs;
                        raddr2 = `ZERO5;
                        waddr = `ZERO5;
                        reg_req = `LOW;
                        imm_32 = `ZERO32;
                    end
                    `SLT_FUN: begin
                        alu_op = `SLT;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    `SRAV_FUN: begin
                        alu_op = `SRA;
                        ren1 = `ENABLE;
                        ren2 = `ENABLE;
                        raddr1 = rs;
                        raddr2 = rt;
                        waddr = rd;
                        reg_req = `HIGH;
                        imm_32 = `ZERO32;
                    end
                    default: begin
                        alu_op = `NOP;
                        ren1 = `DISABLE;
                        ren2 = `DISABLE;
                        raddr1 = `ZERO5;
                        raddr2 = `ZERO5;
                        waddr = `ZERO5;
                        reg_req = `LOW;
                        imm_32 = `ZERO32;
                    end
                    endcase
                end
                // default: begin       //default statement like this will cause error
                //     alu_op = `NOP;
                //     ren1 = `DISABLE;
                //     ren2 = `DISABLE;
                //     raddr1 = `ZERO5;
                //     raddr2 = `ZERO5;
                //     waddr = `ZERO5;
                //     reg_req = `LOW;
                //     imm_32 = `ZERO32;
                // end
            endcase
        end
    end


//operand1
    always @ (*) begin
        if (rst == `HIGH) begin
            operand1 = `ZERO32;
        end
        else if (ren1 == `ENABLE && ex_reg_req == `HIGH && raddr1 == ex_waddr) begin
            operand1 = ex_data;
        end
        else if (ren1 == `ENABLE && mem_reg_req == `HIGH && raddr1 == mem_waddr) begin
            operand1 = mem_data;
        end
        else if (ren1 == `ENABLE) begin
            operand1 = reg_val1;
        end
        else begin
            operand1 = imm_32;
        end
    end
    
//operand2
    always @ (*) begin
        if (rst == `HIGH) begin
            operand2 = `ZERO32;
        end
        else if (ren2 == `ENABLE && ex_reg_req == `HIGH && raddr2 == ex_waddr) begin
            operand2 = ex_data;
        end
        else if (ren2 == `ENABLE && mem_reg_req == `HIGH && raddr2 == mem_waddr) begin
            operand2 = mem_data;
        end
        else if (ren2 == `ENABLE) begin
            operand2 = reg_val2;
        end
        else begin
            operand2 = imm_32;
        end
    end
endmodule