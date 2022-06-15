`timescale 1ns/1ns
module tb_add ();
    reg clk,rst;
    riscvcpucore uut(clk,rst);
    defparam uut.IMEM_MIFB = "../tb/inst1.txt";
    defparam uut.DMEM_MIFB = "../tb/dmem_init.txt";

    //0 LW x14,4(x2) dmem1
    //1 LBU x15,8(x2) dmem2
    //2 LH x16,12(x2)  dmem3
    //3 ADDI  x27,x0,38  38
    //4 ADDI  x28,x0,54  54
    //5 ADD x29,x28,x27  92
    //6 SUB x30,x28,x27 -16
    //7 SB x27,4(x2) dmem1
    //8 SW x28,8(x2) dmem2
    //9 SH x29,12(x2) dmem3
    //10 SH x30,32(x30) dmem4(16)
    //11 BLT x30,x27,16 pc=15
    //15 JAL x31,-10

    always #5 clk=~clk;
    initial begin
        clk=0;
        rst=1;
        #5
        rst=0;
        @(uut.pc_value == 32'd44);
        $display("%d\t%d\t%d\n",uut.U_id.U_regfile.mem[27],uut.U_id.U_regfile.mem[28],uut.U_id.U_regfile.mem[29]);
        $display("%d\t%d\t%d\n",uut.U_dmem.mem[1][7:0],uut.U_dmem.mem[2][15:0],uut.U_dmem.mem[3]);
        @(uut.pc_value == 32'd48);
        $display("%d\n",uut.U_dmem.mem[4][15:0]);
        #20;
        $stop();
    end
endmodule