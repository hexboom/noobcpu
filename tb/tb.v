`timescale 1 ns / 1 ns

module tb;

    reg clk;
    reg rst;

    always #10 clk = ~clk;     // 50MHz
    initial begin
        clk <= 1;
        rst <= 1;
        #30
        rst <= 0;
    end

    wire [31:0] zero_x0  = uut.U_Datapath.U_regfile.mem[0];
    wire [31:0] ra_x1    = uut.U_Datapath.U_regfile.mem[1];
    wire [31:0] sp_x2    = uut.U_Datapath.U_regfile.mem[2];
    wire [31:0] gp_x3    = uut.U_Datapath.U_regfile.mem[3];
    wire [31:0] tp_x4    = uut.U_Datapath.U_regfile.mem[4];
    wire [31:0] t0_x5    = uut.U_Datapath.U_regfile.mem[5];
    wire [31:0] t1_x6    = uut.U_Datapath.U_regfile.mem[6];
    wire [31:0] t2_x7    = uut.U_Datapath.U_regfile.mem[7];
    wire [31:0] s0_fp_x8 = uut.U_Datapath.U_regfile.mem[8];
    wire [31:0] s1_x9    = uut.U_Datapath.U_regfile.mem[9];
    wire [31:0] a0_x10   = uut.U_Datapath.U_regfile.mem[10];
    wire [31:0] a1_x11   = uut.U_Datapath.U_regfile.mem[11];
    wire [31:0] a2_x12   = uut.U_Datapath.U_regfile.mem[12];
    wire [31:0] a3_x13   = uut.U_Datapath.U_regfile.mem[13];
    wire [31:0] a4_x14   = uut.U_Datapath.U_regfile.mem[14];
    wire [31:0] a5_x15   = uut.U_Datapath.U_regfile.mem[15];
    wire [31:0] a6_x16   = uut.U_Datapath.U_regfile.mem[16];
    wire [31:0] a7_x17   = uut.U_Datapath.U_regfile.mem[17];
    wire [31:0] s2_x18   = uut.U_Datapath.U_regfile.mem[18];
    wire [31:0] s3_x19   = uut.U_Datapath.U_regfile.mem[19];
    wire [31:0] s4_x20   = uut.U_Datapath.U_regfile.mem[20];
    wire [31:0] s5_x21   = uut.U_Datapath.U_regfile.mem[21];
    wire [31:0] s6_x22   = uut.U_Datapath.U_regfile.mem[22];
    wire [31:0] s7_x23   = uut.U_Datapath.U_regfile.mem[23];
    wire [31:0] s8_x24   = uut.U_Datapath.U_regfile.mem[24];
    wire [31:0] s9_x25   = uut.U_Datapath.U_regfile.mem[25];
    wire [31:0] s10_x26  = uut.U_Datapath.U_regfile.mem[26];
    wire [31:0] s11_x27  = uut.U_Datapath.U_regfile.mem[27];
    wire [31:0] t3_x28   = uut.U_Datapath.U_regfile.mem[28];
    wire [31:0] t4_x29   = uut.U_Datapath.U_regfile.mem[29];
    wire [31:0] t5_x30   = uut.U_Datapath.U_regfile.mem[30];
    wire [31:0] t6_x31   = uut.U_Datapath.U_regfile.mem[31];

    // defparam uut.U_Datapath.IMEM_MIFH = "../tb/inst2.txt";

    integer r;
    initial begin
        wait(s10_x26 == 32'b1);
        @(posedge clk) #1;
        if(s11_x27 == 32'b1) $display("========== pass ==========");
        else $display("========== fail ==========");
        $finish();
    end

    initial begin
        #10000;
        $display("========== Timeout ==========");
        $display("x26=%h,\tx27=%h\n",s10_x26,s11_x27);
        $display("imem[0]=%h\n",uut.U_Datapath.U_imem.mem[0]);
        $finish();
    end
    // read mem data
    initial begin
        #1;
        // $readmemh ("../tb/inst2.txt", uut.U_Datapath.U_imem.mem);
        // $readmemh ("./generated/rv32ui-p-sb copy.txt", uut.U_Datapath.U_imem.mem);
        $readmemh ("./generated/inst_data.txt", uut.U_Datapath.U_imem.mem);
    end

    // // generate wave file, used by gtkwave
    // initial begin
    //     $dumpfile("tinyriscv_soc_tb.vcd");
    //     $dumpvars(0, tb);
    // end
    riscvcpu uut(clk,rst);

endmodule
