module BRANCH_COMP #(
    parameter DWIDTH = 32
)(
    input [DWIDTH-1:0] rs1,rs2,
    input branch_unsign,
    output branch_eq, branch_lt
);
    assign branch_eq = (rs1==rs2);
    // @@ can be optimize?
    assign branch_lt = branch_unsign ? (rs1<rs2) : 
                       ((rs1[DWIDTH-1]==rs2[DWIDTH-1]) ? (rs1<rs2) : rs1[DWIDTH-1]);
    // assign branch_lt = (branch_unsign && rs1[31] == rs2[31]) ? (rs1<rs2) : rs1[31];
endmodule