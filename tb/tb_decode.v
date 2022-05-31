`timescale 1ns/1ns
module tb_decode ();

    reg [31:0] inst_in;
    initial begin
        inst_in = 32'b111111001110_00001_000_01111_0010011; //addi x15,x1,-50
    end
    Controller uut (inst_in,branch_eq, branch_lt);
    
endmodule