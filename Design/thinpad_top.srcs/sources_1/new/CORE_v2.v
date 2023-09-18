
module CORE_v2(
    input wire              clk,
    input wire              rst,


    //BaseRAM
    output wire[19:0]       base_ram_addr,
	output wire             rom_ce_o,
	input wire[31:0]        inst,
	
    //ExtRAM
    input wire[31:0]        ext_ram_data_r,
    output wire[19:0]       ext_ram_addr,
    output wire[31:0]       ext_ram_data_w,

    output wire             serial_state_req,
    output wire             serial_data_req,
    output wire             baseram_req,
    output wire             extram_req,

	output wire             ram_we_n,
	output wire[3:0]        ram_sel_n,
	output wire             ram_ce_o
    );


    //IF
    wire                    wire_stall;
    wire                    wire_branch_flag;
    wire[31:0]              wire_branch_addr;

    wire                    wire_stallreq_id;
    wire                    wire_stallreq_mem;
    wire[31:0]              wire_pc_if2reg;

    IF_v2 if_v2(
        .clk    (clk),
        .rst    (rst),

        .if_pc          (wire_pc_if2reg),
        .base_ram_addr  (base_ram_addr),
        .base_ram_ce    (rom_ce_o),

        .branch_flag    (wire_branch_flag),
        .branch_addr    (wire_branch_addr),

        .stallreq_id    (wire_stallreq_id),
        .stallreq_mem   (wire_stallreq_mem),
        .stall          (wire_stall)
    );


    //IF_ID
    wire[31:0]              wire_pc_reg2id;
    wire[31:0]              wire_inst_reg2id;

    IF_ID_REG if_id_reg(
        .clk    (clk),
        .rst    (rst),
        .stall  (wire_stall),

        .if_pc          (wire_pc_if2reg),
        .id_pc          (wire_pc_reg2id),

        .if_inst        (inst),
        .id_inst        (wire_inst_reg2id)
    );


    //ID
    wire[31:0]              wire_pc_id2reg;
    wire[5:0]               wire_alu_op_id2reg;
    wire[31:0]              wire_operand1_id2reg;
    wire[31:0]              wire_operand2_id2reg;
    wire                    wire_reg_req_id2reg;
    wire[4:0]               wire_waddr_id2reg;
    wire[15:0]              wire_imm_id2reg;

    wire                    wire_ex_is_load;

    wire[4:0]               wire_raddr1;
    wire[4:0]               wire_raddr2;
    wire                    wire_ren1;
    wire                    wire_ren2;
    wire[31:0]              wire_reg_val1;
    wire[31:0]              wire_reg_val2;

    //exe
    wire                    wire_reg_req_ex2reg;
    wire[4:0]               wire_waddr_ex2reg;
    wire[31:0]              wire_ex_val_ex2reg;
    //mem
    wire                    wire_reg_req_mem2reg;
    wire[4:0]               wire_waddr_mem2reg;
    wire[31:0]              wire_reg_val_mem2reg;

    ID_v2 id_v2(
        .rst    (rst),

        .id_pc_in       (wire_pc_reg2id),
        .id_pc_out      (wire_pc_id2reg),

        .id_inst        (wire_inst_reg2id),

        .alu_op         (wire_alu_op_id2reg),
        .operand1       (wire_operand1_id2reg),
        .operand2       (wire_operand2_id2reg),
        .reg_req        (wire_reg_req_id2reg),
        .waddr          (wire_waddr_id2reg),
        .imm_out        (wire_imm_id2reg),

        .raddr1         (wire_raddr1),
        .raddr2         (wire_raddr2),
        .ren1           (wire_ren1),
        .ren2           (wire_ren2),
        .reg_val1       (wire_reg_val1),
        .reg_val2       (wire_reg_val2),

        .branch_flag    (wire_branch_flag),
        .branch_addr    (wire_branch_addr),

        .ex_reg_req     (wire_reg_req_ex2reg),
        .ex_waddr       (wire_waddr_ex2reg),
        .ex_data        (wire_ex_val_ex2reg),

        .mem_reg_req    (wire_reg_req_mem2reg),
        .mem_waddr      (wire_waddr_mem2reg),
        .mem_data       (wire_reg_val_mem2reg),

        .ex_is_load     (wire_ex_is_load),
        .stallreq       (wire_stallreq_id)
    );


    //ID_EX
    wire[31:0]              wire_pc_reg2ex;
    wire[5:0]               wire_alu_op_reg2ex;
    wire[31:0]              wire_operand1_reg2ex;
    wire[31:0]              wire_operand2_reg2ex;
    wire                    wire_reg_req_reg2ex;
    wire[4:0]               wire_waddr_reg2ex;
    wire[15:0]              wire_imm_reg2ex;

    ID_EX_REG id_ex_reg(
        .clk    (clk),
        .rst    (rst),
        .stall  (wire_stall),

        .id_pc          (wire_pc_id2reg),
        .ex_pc          (wire_pc_reg2ex),

        .alu_op_in      (wire_alu_op_id2reg),
        .alu_op_out     (wire_alu_op_reg2ex),

        .operand1_in    (wire_operand1_id2reg),
        .operand1_out   (wire_operand1_reg2ex),
        .operand2_in    (wire_operand2_id2reg),
        .operand2_out   (wire_operand2_reg2ex),

        .reg_req_in     (wire_reg_req_id2reg),
        .reg_req_out    (wire_reg_req_reg2ex),

        .waddr_in       (wire_waddr_id2reg),
        .waddr_out      (wire_waddr_reg2ex),

        .imm_in         (wire_imm_id2reg),
        .imm_out        (wire_imm_reg2ex)
    );


    //EXE

    wire[2:0]               wire_mem_type_ex2reg;
    wire[31:0]              wire_mem_addr_ex2reg;
    wire[31:0]              wire_mem_val_ex2reg;

    EXE_v2 exe_v2(
        .rst    (rst),

        .ex_pc_in       (wire_pc_reg2ex),

        .alu_op         (wire_alu_op_reg2ex),
        .operand1       (wire_operand1_reg2ex),
        .operand2       (wire_operand2_reg2ex),
        .reg_req_in     (wire_reg_req_reg2ex),
        .reg_req_out    (wire_reg_req_ex2reg),
        .waddr_in       (wire_waddr_reg2ex),
        .waddr_out      (wire_waddr_ex2reg),
        .ex_val         (wire_ex_val_ex2reg),

        .imm            (wire_imm_reg2ex),

        .mem_type       (wire_mem_type_ex2reg),
        .mem_addr       (wire_mem_addr_ex2reg),
        .mem_val        (wire_mem_val_ex2reg),

        .is_load        (wire_ex_is_load)
    );


    //EX_MEM
    wire                    wire_reg_req_reg2mem;
    wire[4:0]               wire_waddr_reg2mem;
    wire[31:0]              wire_ex_val_reg2mem;

    wire[2:0]               wire_mem_type_reg2mem;
    wire[31:0]              wire_mem_addr_reg2mem;
    wire[31:0]              wire_mem_val_reg2mem;

    EX_MEM_REG ex_mem_reg(
        .clk    (clk),
        .rst    (rst),

        .reg_req_in     (wire_reg_req_ex2reg),
        .reg_req_out    (wire_reg_req_reg2mem),
        .reg_waddr_in   (wire_waddr_ex2reg),
        .reg_waddr_out  (wire_waddr_reg2mem),
        .ex_val_in      (wire_ex_val_ex2reg),
        .ex_val_out     (wire_ex_val_reg2mem),

        .mem_type_in    (wire_mem_type_ex2reg),
        .mem_type_out   (wire_mem_type_reg2mem),
        .mem_addr_in    (wire_mem_addr_ex2reg),
        .mem_addr_out   (wire_mem_addr_reg2mem),
        .mem_val_in     (wire_mem_val_ex2reg),
        .mem_val_out    (wire_mem_val_reg2mem)
    );


    //MEM
    wire[2:0]               wire_mem_type_mem2reg;
    wire[31:0]              wire_mem_addr_mem2reg;
    wire[31:0]              wire_mem_val_mem2reg;


    MEM_v2 mem_v2(
        .rst    (rst),

        .reg_req_in     (wire_reg_req_reg2mem),
        .reg_req_out    (wire_reg_req_mem2reg),
        .reg_waddr_in   (wire_waddr_reg2mem),
        .reg_waddr_out  (wire_waddr_mem2reg),
        .ex_val_in      (wire_ex_val_reg2mem),

        .reg_val        (wire_reg_val_mem2reg),

        .mem_type       (wire_mem_type_reg2mem),
        .mem_addr       (wire_mem_addr_reg2mem),
        .mem_val_in     (wire_mem_val_reg2mem),


        .ram_data_load  (ext_ram_data_r),
    
        .ram_cen        (ram_ce_o),
        .ram_wen_n      (ram_we_n),
        .ram_addr       (ext_ram_addr),
        .ram_data_store (ext_ram_data_w),
        .ram_sel_n      (ram_sel_n),

        .serial_state_req(serial_state_req),
        .serial_data_req(serial_data_req),
        .baseram_req    (baseram_req),
        .extram_req     (extram_req),

        .stallreq       (wire_stallreq_mem)
    );


    //MEM_WB
    wire                    wire_reg_req_wb;
    wire[4:0]               wire_reg_waddr_wb;
    wire[31:0]              wire_reg_val_wb;

    MEM_WB_REG mem_wb_reg(
        .clk    (clk),
        .rst    (rst),

        .reg_req_in     (wire_reg_req_mem2reg),
        .reg_waddr_in   (wire_waddr_mem2reg),
        .reg_val_in     (wire_reg_val_mem2reg),

        .reg_req_out    (wire_reg_req_wb),
        .reg_waddr_out  (wire_reg_waddr_wb),
        .reg_val_out    (wire_reg_val_wb)
    );


    //WB and Register
    WB_v2 wb_v2(
        .clk    (clk),
        .rst    (rst),

        .wen            (wire_reg_req_wb),
        .waddr          (wire_reg_waddr_wb),
        .wdata          (wire_reg_val_wb),

        .req1           (wire_ren1),
        .raddr1         (wire_raddr1),
        .rval1          (wire_reg_val1),

        .req2           (wire_ren2),
        .raddr2         (wire_raddr2),
        .rval2          (wire_reg_val2)
    );

endmodule