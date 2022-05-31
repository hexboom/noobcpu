`include "CtrlCode.vh"
module IMM_GEN #(
    parameter DWIDTH = 32
)(
    input [2:0] imm_sel, 
    input [DWIDTH-1:7] inst_in,
    output reg [DWIDTH-1:0] imm_out
);
    wire [DWIDTH-1:0] imm_I, imm_S, imm_B, imm_U, imm_J, imm_CSR;

    // @@ can be optimized 
    assign imm_I = {{20{inst_in[31]}} , inst_in[31:20]};
    assign imm_S = {{20{inst_in[31]}} , inst_in[31:25] , inst_in[11:7]};
    assign imm_B = {{20{inst_in[31]}} , inst_in[7] , inst_in[30:25] , inst_in[11:8] , 1'b0};
    assign imm_U = {inst_in[31:12] , 12'b0};
    assign imm_J = {{11{inst_in[31]}} , inst_in[31] , inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};
    assign imm_CSR = {{27{1'b0}}, inst_in[19:15]};
    always @(*) begin
        imm_out = 'bx;
        case(imm_sel)
            `IMM_ITYPE: imm_out = imm_I;
            `IMM_STYPE: imm_out = imm_S;
            `IMM_BTYPE: imm_out = imm_B;
            `IMM_UTYPE: imm_out = imm_U;
            `IMM_JTYPE: imm_out = imm_J;
            `IMM_CSR: imm_out = imm_CSR;
        endcase 
    end
    
endmodule