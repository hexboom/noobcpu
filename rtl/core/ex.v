`include "CtrlCode.vh"
`include "topdef.vh"
module ex (
    input clk,
    input rst,

    input [`PC_WIDTH-1:0] pc,
    input [1:0] forw_A_sel,
    input [1:0] forw_B_sel,
    input [`RF_DWIDTH-1:0] rs1_data,
    input [`RF_DWIDTH-1:0] rs2_data,
    input [`IMM_DWIDTH-1:0] imm,
    input [`ALU_DWIDTH-1:0] alu_out_forw,   //dm
    input [`WB_DWIDTH-1:0] wb_forw,         //wb
    input branch_unsign,
    input alu_A_sel,
    input alu_B_sel,
    input [3:0] alu_sel,
    
    output branch_eq,
    output branch_lt,
    output [`ALU_DWIDTH-1:0] alu_out,
    output [`DMEM_DWIDTH-1:0] forw_B_out,
    output [`PC_WIDTH-1:0] pc_add4
);
    reg [`DMEM_DWIDTH-1:0] forw_A;
    reg [`DMEM_DWIDTH-1:0] forw_B;

    wire [`ALU_DWIDTH-1:0] alu_A;
    wire [`ALU_DWIDTH-1:0] alu_B;

    wire [1:0] dmem_shift;
    wire [`DMEM_DWIDTH-1:0] dmem_in;

    // forward mux
    always @(*) begin
        forw_A = rs1_data;
        case(forw_A_sel) 
            `FORW_SRC_EX: forw_A = rs1_data;
            `FORW_SRC_DM: forw_A = alu_out_forw;
            `FORW_SRC_WB: forw_A = wb_forw;
        endcase
    end
    
    always @(*) begin
        forw_B = rs2_data;
        case(forw_B_sel) 
            `FORW_SRC_EX: forw_B = rs2_data;
            `FORW_SRC_DM: forw_B = alu_out_forw;
            `FORW_SRC_WB: forw_B = wb_forw;
        endcase
    end
    assign forw_B_out = forw_B;
    // Branch_Comp
    branch_comp #(
        .DWIDTH(`RF_DWIDTH)
    ) U_brn_comp (
        .rs1(forw_A),
        .rs2(forw_B),
        .branch_unsign(branch_unsign),
        .branch_eq(branch_eq),
        .branch_lt(branch_lt)
    );

    // ALU
    assign alu_A = (alu_A_sel==`A_SEL_PC)  ? {{(`ALU_DWIDTH-`PC_WIDTH){pc[`PC_WIDTH-1]}},pc} :forw_A;
    assign alu_B = (alu_B_sel==`B_SEL_IMM) ? imm : forw_B;
    ALU #(
        .DWIDTH(`ALU_DWIDTH)
    ) U_alu (
        .A(alu_A),
        .B(alu_B),
        .alu_sel(alu_sel),
        .alu_out(alu_out)
    );

    // // csr 
    // assign csr_data_in = alu_out;
    // assign csr_addr = imem_out[31:20]; // 0x51e
    // ASYNC_RAM #(
    //     .DWIDTH(`CSR_DWIDTH),
    //     .AWIDTH(`CSR_AWIDTH)
    // ) U_csr (
    //     .addr(csr_addr),  
    //     .we(csr_wen),
    //     .q(csr_data_out),
    //     .d(csr_data_in),
    //     .clk(clk)
    // );

    assign pc_add4 = pc + `PC_WIDTH'd4;

endmodule