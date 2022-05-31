`timescale 1ns/1ns
module tb_Branch_Comp ();
    reg [31:0] rs1,rs2;
    reg branch_unsign;
    wire branch_eq, branch_lt;

    initial begin
        branch_unsign = 1;
        rs1 = 32'h0000_1234;
        rs2 = 32'h0000_1230;
        #10;
        rs1 = 32'h0000_1234;
        rs2 = 32'h0000_1234;
        #10;
        rs1 = 32'h0000_1230;
        rs2 = 32'h0000_1234;

        #10;
        rs1 = 32'hffff_f234;
        rs2 = 32'hffff_f230;
        #10;
        rs1 = 32'hffff_f234;
        rs2 = 32'hffff_f234;
        #10;
        rs1 = 32'hffff_f230;
        rs2 = 32'hffff_f234;
        
        #10;
        branch_unsign = 0;
        rs1 = 32'h0000_1234;
        rs2 = 32'h0000_1230;
        #10;
        rs1 = 32'h0000_1234;
        rs2 = 32'h0000_1234;
        #10;
        rs1 = 32'h0000_1230;
        rs2 = 32'h0000_1234;

        #10;
        rs1 = 32'hffff_f234;
        rs2 = 32'hffff_f230;
        #10;
        rs1 = 32'hffff_f234;
        rs2 = 32'hffff_f234;
        #10;
        rs1 = 32'hffff_f230;
        rs2 = 32'hffff_f234;

        #10;
        rs1 = 32'hffff_1234;
        rs2 = 32'h0000_1230;
        #10;
        rs1 = 32'hffff_1234;
        rs2 = 32'h0000_1234;
        #10;
        rs1 = 32'hffff_1230;
        rs2 = 32'h0000_1234;

        #10;
        rs1 = 32'h0000_f234;
        rs2 = 32'hffff_f230;
        #10;
        rs1 = 32'h0000_f234;
        rs2 = 32'hffff_f234;
        #10;
        rs1 = 32'h0000_f230;
        rs2 = 32'hffff_f234;

        #10;
        rs1 = -32'sh15;
        rs2 = -32'sh9;

        #10;
        rs1 = -32'd15;
        rs2 = -32'd9;

        #10 $stop();
    end

    Branch_Comp uut(rs1,rs2,branch_unsign,branch_eq, branch_lt);
    
endmodule