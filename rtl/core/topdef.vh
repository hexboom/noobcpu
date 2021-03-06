`ifndef TOPDEF
`define TOPDEF

`define PC_WIDTH 32
`define PC_VAL_INIT 32'h0000_0000

`define BIOS_DWIDTH 32
`define BIOS_AWIDTH 12

`define IMEM_DWIDTH 32
`define IMEM_AWIDTH 14

`define RF_DWIDTH 32
`define RF_AWIDTH 5
`define RF_DEPTH  32

`define CSR_DWIDTH 32
`define CSR_AWIDTH 12

`define IMM_DWIDTH 32

`define ALU_DWIDTH 32

`define DMEM_DWIDTH 32
`define DMEM_AWIDTH 14
`define DMEM_DEPTH  1<<14

`define WB_DWIDTH 32

`endif
