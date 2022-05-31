`timescale 1ns/1ns
module tb_add ();
    reg clk,rst;
    riscvcpu uut(clk,rst);
    defparam uut.U_Datapath.IMEM_MIFB = "../tb/inst1.txt";
    defparam uut.U_Datapath.DMEM_MIFB = "../tb/dmem_init.txt";

    //0 LW x14,1(x2) dmem1
    //1 LBU x15,2(x2) dmem2
    //2 LH x16,3(x2)  dmem3
    //3 ADDI  x27,x0,38  38
    //4 ADDI  x28,x0,54  54
    //5 ADD x29,x28,x27  92
    //6 SUB x30,x28,x27 -16
    //7 SB x27,4(x2) dmem4
    //8 SW x28,5(x2) dmem5
    //9 SH x29,6(x2) dmem6
    //10 SH x30,23(x30) dmem7
    //11 BLT x30,x27,8 pc=13
    //13 JAL x31,-10

    always #5 clk=~clk;
    initial begin
        clk=0;
        rst=1;
        #10
        rst=0;
        @(uut.U_Datapath.pc_value == 32'd44);
        $display("%d\t%d\t%d\n",uut.U_Datapath.U_regfile.mem[27],uut.U_Datapath.U_regfile.mem[28],uut.U_Datapath.U_regfile.mem[29]);
        $display("%d\t%d\t%d\n",uut.U_Datapath.U_dmem.mem[4],uut.U_Datapath.U_dmem.mem[5],uut.U_Datapath.U_dmem.mem[6]);
        @(uut.U_Datapath.pc_value == 32'd48);
        $display("%d\n",uut.U_Datapath.U_dmem.mem[7]);
        #20;
        $stop();
    end
endmodule