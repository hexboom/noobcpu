`timescale 1ns/1ns
module tb_ALU();
    reg [7:0] a = 8'd4;
    reg [31:0] b = 32'hafaf_afaf;
    reg [31:0] c;
    initial begin
        #10;
        c = b << a;
        #10;
        a = 8'd8;
        c = b >> a;
        #10;
        c = b >>> a;
    end
endmodule