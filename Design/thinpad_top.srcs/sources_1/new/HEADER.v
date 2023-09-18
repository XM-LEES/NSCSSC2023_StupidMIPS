`timescale 1ns / 1ps

//OPCODE
`define ANDI_OP 6'b001100
`define LUI_OP 6'b001111
`define ORI_OP 6'b001101
`define XORI_OP 6'b001110
`define ADDIU_OP 6'b001001
`define LB_OP 6'b100000
`define SB_OP 6'b101000
`define LW_OP 6'b100011
`define SW_OP 6'b101011

`define MUL_OP 6'b011100

`define BEQ_OP 6'b000100
`define BGEZ_OP 6'b000001
`define BGTZ_OP 6'b000111
`define BNE_OP 6'b000101
`define J_OP 6'b000010
`define JAL_OP 6'b000011

`define RTYPE_OP 6'b000000

`define AND_FUN 6'b100100
`define OR_FUN 6'b100101
`define XOR_FUN 6'b100110
`define SLL_FUN 6'b000000
`define SRL_FUN 6'b000010
`define ADDU_FUN 6'b100001
`define JR_FUN 6'b001000

`define SLT_FUN 6'b101010
`define SRAV_FUN 6'b000111

//////////////////////////////
//ALU_OP
`define NOP 6'b000000
`define AND 6'b000001
`define OR  6'b000010
`define XOR 6'b000011
`define SLL 6'b000100
`define SRL 6'b000101
`define ADD 6'b000110
`define JAL 6'b000111
`define LB  6'b001000
`define LW  6'b001001
`define SB  6'b001010
`define SW  6'b001011
`define SLT 6'b001100
`define SRA 6'b001101
`define MUL 6'b001110

/////////////////////////////
//mem type
`define NOMEM 3'b000  
`define MEM_LB 3'b001
`define MEM_LW 3'b010
`define MEM_SB 3'b011
`define MEM_SW 3'b100

//////////////////////////////
`define HIGH 1'b1
`define LOW 1'b0

`define ZERO 32'h00000000
`define NONE_ADDR 5'b00000

`define PC_START 32'h80000000

//////////////////////////////
//CONSISTANT
`define ENABLE 1'b1
`define DISABLE 1'b0
`define ENABLE_N 1'b0
`define DISABLE_N 1'b1

`define HIGH 1'b1
`define LOW 1'b0

`define ZERO32 32'h00000000
`define ZERO20 20'h00000
`define ZERO16 16'h0000
`define ZERO8 8'h00
`define ZERO5 5'b00000
`define ZERO4 4'b0000

`define PC_START 32'h80000000

`define SerialState_addr 32'hBFD003FC
`define SerialData_addr  32'hBFD003F8