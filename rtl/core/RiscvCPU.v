module riscvcpu (
    input clk,
    input rst
);
    
    wire [31:0] inst;
    wire branch_eq;
    wire branch_lt;
    wire pc_sel;
    wire regfile_wen;
    wire [2:0] imm_sel;
    wire branch_unsign;
    wire alu_A_sel;
    wire alu_B_sel;
    wire [3:0] alu_sel;
    wire csr_wen;
    wire dmem_wen;
    wire dmem_ext_unsign;
    wire [1:0] dmem_ext_size;
    wire [2:0] wb_sel;
    
    Controller U_Controller(
        .inst_in(inst),
        .branch_eq(branch_eq),
        .branch_lt(branch_lt),
        .pc_sel(pc_sel),
        .regfile_wen(regfile_wen),
        .imm_sel(imm_sel),
        .branch_unsign(branch_unsign),
        .alu_A_sel(alu_A_sel),
        .alu_B_sel(alu_B_sel),
        .alu_sel(alu_sel),
        .csr_wen(csr_wen),
        .dmem_wen(dmem_wen),
        .dmem_ext_unsign(dmem_ext_unsign),
        .dmem_ext_size(dmem_ext_size),
        .wb_sel(wb_sel)
    );
    
    Datapath U_Datapath(
        .clk(clk),
        .rst(rst),
        .pc_sel(pc_sel),
        .regfile_wen(regfile_wen),
        .imm_sel(imm_sel),
        .branch_unsign(branch_unsign),
        .alu_A_sel(alu_A_sel),
        .alu_B_sel(alu_B_sel),
        .alu_sel(alu_sel),
        .csr_wen(csr_wen),
        .dmem_wen(dmem_wen),
        .dmem_ext_unsign(dmem_ext_unsign),
        .dmem_ext_size(dmem_ext_size),
        .wb_sel(wb_sel),
        .inst_out(inst),
        .branch_eq(branch_eq),
        .branch_lt(branch_lt)
    );
endmodule
