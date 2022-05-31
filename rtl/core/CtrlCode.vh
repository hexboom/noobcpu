`ifndef CTRLCODE
`define CTRLCODE

`define PC_ALU  1'b1
`define PC_ADD4 1'b0

`define IMM_ITYPE 3'b000
`define IMM_STYPE 3'b001
`define IMM_BTYPE 3'b010
`define IMM_UTYPE 3'b011
`define IMM_JTYPE 3'b100
`define IMM_CSR   3'b101

`define A_SEL_PC  1'b1
`define A_SEL_RS1 1'b0

`define B_SEL_IMM 1'b1
`define B_SEL_RS2 1'b0

`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_SLL  4'b0010
`define ALU_SLT  4'b0100
`define ALU_SLTU 4'b0110
`define ALU_XOR  4'b1000
`define ALU_OR   4'b1100
`define ALU_AND  4'b1110
`define ALU_SRL  4'b1010
`define ALU_SRA  4'b1011
`define ALU_A    4'b0111
`define ALU_B    4'b1111

`define DMEM_EXT_BYTE 2'b01
`define DMEM_EXT_HALF 2'b10
`define DMEM_EXT_WORD 2'b11

`define WB_DMEM     3'b001
`define WB_ALU      3'b010
`define WB_PCADD4   3'b100 

`endif