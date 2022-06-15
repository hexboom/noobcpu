`include "topdef.vh"
`include "CtrlCode.vh"
module id (
    input clk,
    input rst,
    input [`IMEM_DWIDTH-1:0] inst,
    input regfile_wen,
    input [`RF_DWIDTH-1:0] rd_data_in,
    input [`RF_AWIDTH-1:0] rd_addr_in,
    input [2:0] imm_sel,

    output [`RF_AWIDTH-1:0] rd_addr_out,
    output [`RF_DWIDTH-1:0] rs1_data_out,
    output [`RF_AWIDTH-1:0] rs1_addr_out,
    output [`RF_DWIDTH-1:0] rs2_data_out,
    output [`RF_AWIDTH-1:0] rs2_addr_out,
    output [`IMM_DWIDTH-1:0] imm_out
);
    //register file
    assign rd_wen = regfile_wen; // @@ write back control 
    assign rd_addr_out = inst[11:7];
    assign rs1_addr_out = inst[19:15];
    assign rs2_addr_out = inst[24:20];

    ASYNC_RAM_1W2R #(
        .DWIDTH(`RF_DWIDTH), 
        .AWIDTH(`RF_AWIDTH),
        .DEPTH(`RF_DEPTH)
    )  U_regfile (
        .d0(rd_data_in), 
        .addr0(rd_addr_in), 
        .we0(rd_wen), 
        .q1(rs1_data_out), 
        .addr1(rs1_addr_out),
        .q2(rs2_data_out), 
        .addr2(rs2_addr_out), 
        .clk(clk)
    );

    //Imm_gen
    imm_gen #(
        .DWIDTH(`IMEM_DWIDTH)
    ) U_imm_gen (
        .imm_sel(imm_sel),
        .inst_in(inst[`IMEM_DWIDTH-1:7]),
        .imm_out(imm_out)
    );

endmodule