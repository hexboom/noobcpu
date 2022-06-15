`include "topdef.vh"
`include "CtrlCode.vh"
module riscvcpucore (
    input clk,
    input rst
);
    //--------ctrl siganl-------//
    //pc
    wire pc_sel;
    wire pc_en;

    //bios
    wire bios_ena;
    wire bios_enb;

    //imem
    wire imem_ena;
    wire [3:0] imem_wbea;
    wire imem_enb;
    wire [3:0] imem_wbeb;

    // if/id
    wire ifid_rst;
    wire ifid_en;

    // opcode func
    wire [6:0] opcode;
    wire [2:0] func3;
    wire func1;    
    wire [6:0] opcode_ex;
    wire [2:0] func3_ex;
    wire func1_ex;
    wire [6:0] opcode_dm;
    wire [2:0] func3_dm;
    wire func1_dm;    
    wire [6:0] opcode_wb;
    wire [2:0] func3_wb;
    wire func1_wb;

    //imm
    wire [2:0] imm_sel;

    //rf
    wire regfile_wen;
    wire regfile_wen_ex;
    wire regfile_wen_dm;
    wire regfile_wen_wb;

    // hazard
    wire data_flush;
    wire ctrl_flush;
    wire ctrl_flush_dff;
    
    // id/ex
    wire idex_rst;
    wire idex_en;

    wire jump_taken;
    //bc
    wire branch_unsign;
    wire branch_eq;     // output
    wire branch_lt;     // output
    wire branch_taken;

    //alu
    wire alu_A_sel;
    wire alu_B_sel;
    wire [3:0] alu_sel;

    //csr
    wire csr_wen;
    wire csr_wen_ex;

    //forward_ex
    wire [1:0] forw_A_sel;
    wire [1:0] forw_B_sel;

    // ex/dm
    wire exdm_rst;
    wire exdm_en;

    //dmem
    wire dmem_wr;
    wire dmem_rd;
    wire dmem_out_ext_unsign;
    wire [1:0] dmem_in_ext_size;
    wire dmem_wr_ex;
    wire dmem_rd_ex;
    wire dmem_wr_dm;
    wire dmem_rd_dm;
    wire dmem_rd_wb;
    wire [1:0] dmem_out_ext_size;

    wire dmem_en;
    wire [3:0] dmem_byte_wen;
    // wire [3:0] dmem_byte_sel;

    // forward dm
    wire forw_dmem_din_sel;

    // dm/wb
    wire dmwb_rst;
    wire dmwb_en;

    //wb
    wire [2:0] wb_sel;


    //--------data signal-------//
    //pc
    wire [`PC_WIDTH-1:0] pc_value;
    wire [`PC_WIDTH-1:0] pc_add4;
    wire [`PC_WIDTH-1:0] pc_next;
    wire [`PC_WIDTH-1:0] pc_value_id;
    wire [`PC_WIDTH-1:0] pc_value_ex;
    wire [`PC_WIDTH-1:0] pc_add4_dm;
    wire [`PC_WIDTH-1:0] pc_add4_wb;

    //bios
    wire [`BIOS_DWIDTH-1:0] bios_douta;
    wire [`BIOS_AWIDTH-1:0] bios_addra;
    wire [`BIOS_DWIDTH-1:0] bios_doutb;
    wire [`BIOS_AWIDTH-1:0] bios_addrb;

    //imem
    wire [`IMEM_DWIDTH-1:0] imem_douta; 
    wire [`IMEM_AWIDTH-1:0] imem_addra;
    wire [`IMEM_DWIDTH-1:0] imem_dina;
    wire [`IMEM_DWIDTH-1:0] imem_doutb; 
    wire [`IMEM_AWIDTH-1:0] imem_addrb;
    wire [`IMEM_DWIDTH-1:0] imem_dinb;

    wire [`IMEM_DWIDTH-1:0] inst;
    wire [`IMEM_DWIDTH-1:0] inst_id;

    //register file
    // wire [`RF_DWIDTH-1:0] rd_data; 
    wire [`RF_AWIDTH-1:0] rd_addr;
    wire [`RF_DWIDTH-1:0] rs1_data;
    wire [`RF_AWIDTH-1:0] rs1_addr;
    wire [`RF_DWIDTH-1:0] rs2_data;
    wire [`RF_AWIDTH-1:0] rs2_addr;
    wire [`RF_AWIDTH-1:0] rd_addr_ex;
    wire [`RF_DWIDTH-1:0] rs1_data_ex;
    wire [`RF_AWIDTH-1:0] rs1_addr_ex;
    wire [`RF_DWIDTH-1:0] rs2_data_ex;
    wire [`RF_AWIDTH-1:0] rs2_addr_ex;
    wire [`RF_AWIDTH-1:0] rs2_addr_dm;
    wire [`RF_AWIDTH-1:0] rd_addr_dm;
    wire [`RF_AWIDTH-1:0] rd_addr_wb;

    wire [`RF_DWIDTH-1:0] forw_B;
    wire [`RF_DWIDTH-1:0] forw_B_dm;
    //imm_gen
    wire [`IMM_DWIDTH-1:0] imm_out;
    wire [`IMM_DWIDTH-1:0] imm_out_ex;

    //alu
    wire [`ALU_DWIDTH-1:0] alu_out;
    wire [`ALU_DWIDTH-1:0] alu_out_dm;
    wire [`ALU_DWIDTH-1:0] alu_out_wb;

    //dmem gen
    wire [3:0] dmem_byte_sel;
    wire [`DMEM_DWIDTH-1:0] dmem_in_ext;
    // dmem
    wire [`DMEM_AWIDTH-1:0] dmem_addr;
    wire [`DMEM_DWIDTH-1:0] dmem_out;
    wire [`DMEM_DWIDTH-1:0] dmem_in;

    wire [`DMEM_DWIDTH-1:0] dmem_out_wb;
    //dmem masks
    wire [`DMEM_DWIDTH-1:0] dmem_out_ext;

    //wb
    wire [`WB_DWIDTH-1:0] wb_data;

/////////////////////////////////////////
// if
/////////////////////////////////////////

    //pc @@ alu width
    assign pc_next = (pc_sel==`PC_ALU) ? alu_out : pc_value + `PC_WIDTH'd4;
    assign pc_en = ~data_flush;    // @@
    REGISTER_R_CE #(
        .N(`PC_WIDTH),
        .INIT(`PC_VAL_INIT)
    ) pc (
        .q(pc_value), 
        .d(pc_next), 
        .rst(rst), 
        .ce(pc_en),
        .clk(clk)
    );

    //bios
    assign bios_addra = pc_value[`BIOS_AWIDTH+1:2];
    assign bios_addrb = alu_out[`BIOS_AWIDTH+1:2];
    assign bios_ena = ~data_flush;     // @@
    assign bios_enb = 1'b1;
    parameter BIOS_MIFH = "";
    SYNC_ROM_DP #(
        .AWIDTH (`BIOS_AWIDTH),
        .DWIDTH (`BIOS_DWIDTH),
        .MIF_HEX(BIOS_MIFH)
    ) U_bios_mem (
        .q0(bios_douta),  
        .addr0(bios_addra),  
        .en0(bios_ena),

        .q1(bios_doutb),  
        .addr1(bios_addrb),  
        .en1(bios_ena),

        .clk(clk)
    );

    //imem
    assign imem_addra = alu_out[`IMEM_AWIDTH+1:2];
    assign imem_addrb = pc_value[`IMEM_AWIDTH+1:2];
    assign imem_dina = 0;       // @@  forw_B
    assign imem_dinb = 32'b0;
    assign imem_ena = 1'b1;
    assign imem_enb = ~data_flush;     // @@
    assign imem_wbea = 4'b0;    // @@
    assign imem_wbeb = 4'b0;    // @@
    parameter IMEM_MIFB = "";
    SYNC_RAM_DP_WBE #(         
        .DWIDTH(`IMEM_DWIDTH),
        .AWIDTH(`IMEM_AWIDTH),
        .MIF_BIN(IMEM_MIFB)
    ) U_imem (
        .q0(imem_douta),    // output
        .d0(imem_dina),     // input
        .addr0(imem_addra), // input
        .wbe0(imem_wbea),    // input
        .en0(imem_ena),

        .q1(imem_doutb),    // output
        .d1(imem_dinb),     // input
        .addr1(imem_addrb), // input
        .wbe1(imem_wbeb),    // input
        .en1(imem_enb),

        .clk(clk)
    );
    
    REGISTER #(
        .N(1)
    ) U_ctrl_flush_dff (
        .d  (ctrl_flush),
        .q  (ctrl_flush_dff), 
        .clk(clk)
    );

    assign inst = ctrl_flush_dff ? `IMEM_DWIDTH'b0 : ((pc_value[30]==1'b1) ? bios_douta : imem_doutb);

////////////////////////////////////////////
// if/id
//------------------------------------------
// output: 
//      pc_value
////////////////////////////////////////////
    assign ifid_en = 1'b1; // @@
    assign ifid_rst = rst || data_flush; // @@ | flush??

    REGISTER_R_CE #(
        .N(`PC_WIDTH),
        .INIT(0)
    ) if_id_pc (
        .d  (pc_value),
        .q  (pc_value_id),
        .ce (ifid_en),    
        .clk(clk),
        .rst(ifid_rst)
    );

////////////////////////////////////////////
// id
////////////////////////////////////////////
    ctrl_id U_ctrl_id (
        .inst_in(inst),

        .opcode(opcode),
        .func3(func3),
        .func1(func1),

        .regfile_wen(regfile_wen),

        .imm_sel(imm_sel), 

        .dmem_wr(dmem_wr),
        .dmem_rd(dmem_rd)
    );

    id U_id (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .regfile_wen(regfile_wen_wb),
        .rd_addr_in(rd_addr_wb),
        .rd_data_in(wb_data),
        .imm_sel(imm_sel),

        .rd_addr_out(rd_addr),
        .rs1_data_out(rs1_data),
        .rs1_addr_out(rs1_addr),
        .rs2_data_out(rs2_data),
        .rs2_addr_out(rs2_addr),        
        .imm_out(imm_out)
    );

    hazard_detection U_hazard_detection (
        .opcode_id(opcode),
        .dmem_rd_ex(dmem_rd_ex),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .rs1_addr_id(rs1_addr),
        .rs2_addr_id(rs2_addr),
        .rd_addr_ex(rd_addr_ex),

        .data_flush(data_flush),
        .ctrl_flush(ctrl_flush)
    );

////////////////////////////////////////////
// id/ex   
//------------------------------------------
// output:
//      pc_value
//      rd_addr
//      rs1_data
//      rs1_addr
//      rs2_data
//      rs2_addr
//      imm
//
//      opcode
//      func3
//      func1
//      regfile_wen
//      dmem_wr
//      dmem_rd
////////////////////////////////////////////
    assign idex_en = 1'b1; // @@
    assign idex_rst = rst || data_flush || ctrl_flush; // @@ | flush

    REGISTER #(
        .N(`PC_WIDTH)
    ) id_ex_pc (
        .d  (pc_value_id),
        .q  (pc_value_ex), 
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) id_ex_rd_addr (
        .d  (rd_addr),
        .q  (rd_addr_ex),
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_DWIDTH)
    ) id_ex_rs1_data (
        .d  (rs1_data),
        .q  (rs1_data_ex),  
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) id_ex_rs1_addr (
        .d  (rs1_addr),
        .q  (rs1_addr_ex),
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_DWIDTH)
    ) id_ex_rs2_data (
        .d  (rs2_data),
        .q  (rs2_data_ex),
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) id_ex_rs2_addr (
        .d  (rs2_addr),
        .q  (rs2_addr_ex), 
        .clk(clk)
    );

    REGISTER #(
        .N(`IMM_DWIDTH)
    ) id_ex_imm_out (
        .d  (imm_out),
        .q  (imm_out_ex), 
        .clk(clk)
    );

    REGISTER_R_CE #(
        .N(7),
        .INIT(0)
    ) id_ex_opcode (
        .d  (opcode),
        .q  (opcode_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );

    REGISTER_R_CE #(
        .N(3),
        .INIT(0)
    ) id_ex_func3 (
        .d  (func3),
        .q  (func3_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );    
    
    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) id_ex_func1 (
        .d  (func1),
        .q  (func1_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );
    
    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) id_ex_regfile_wen (
        .d  (regfile_wen),
        .q  (regfile_wen_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) id_ex_dmem_wr (
        .d  (dmem_wr),
        .q  (dmem_wr_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) id_ex_dmem_rd (
        .d  (dmem_rd),
        .q  (dmem_rd_ex),
        .ce (idex_en),    
        .clk(clk),
        .rst(idex_rst)
    );

////////////////////////////////////////////
// ex
////////////////////////////////////////////

    ctrl_ex U_ctrl_ex(
        .opcode(opcode_ex),
        .func3(func3_ex),
        .func1(func1_ex),
        .branch_eq(branch_eq),
        .branch_lt(branch_lt),
        .pc_sel(pc_sel),
        .branch_unsign(branch_unsign),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .alu_A_sel(alu_A_sel),
        .alu_B_sel(alu_B_sel),
        .alu_sel(alu_sel)
    );

    ex U_ex (
        .clk(clk),
        .rst(rst),

        .pc(pc_value_ex),
        .forw_A_sel(forw_A_sel),
        .forw_B_sel(forw_B_sel),
        .rs1_data(rs1_data_ex),
        .rs2_data(rs2_data_ex),
        .imm(imm_out_ex),
        .alu_out_forw(alu_out_dm), // @@
        .wb_forw(wb_data),          // @@
        .branch_unsign(branch_unsign),
        .alu_A_sel(alu_A_sel),
        .alu_B_sel(alu_B_sel),
        .alu_sel(alu_sel),
            
        .branch_eq(branch_eq),
        .branch_lt(branch_lt),
        .alu_out(alu_out),
        .forw_B_out(forw_B),
        .pc_add4(pc_add4)
    );

    //forward
    forward U_forward(
        .regfile_wen_ex(regfile_wen_ex),
        .regfile_wen_dm(regfile_wen_dm),
        .regfile_wen_wb(regfile_wen_wb),
        .dmem_wr_dm(dmem_wr_dm),
        .dmem_rd_wb(dmem_rd_wb),
        .rs1_addr_ex(rs1_addr_ex),
        .rs2_addr_ex(rs2_addr_ex),
        .rs2_addr_dm(rs2_addr_dm),
        .rd_addr_dm(rd_addr_dm),
        .rd_addr_wb(rd_addr_wb),

        .forw_A_sel(forw_A_sel),
        .forw_B_sel(forw_B_sel),
        .forw_dmem_din_sel(forw_dmem_din_sel)
    );

    
    //csr
    
////////////////////////////////////////////
// ex/dm    @@ reg tpye
//------------------------------------------
// output:
//      alu_out
//      forw_B
//      pc
//      rd_addr
//
//      opcode
//      func3
//      func1
//      regfile_wen
//      dmem_wr
//      dmem_rd
////////////////////////////////////////////
    assign exdm_en = 1'b1; // @@
    assign exdm_rst = rst; // @@ | flush
    REGISTER #(
        .N(`ALU_DWIDTH)
    ) ex_dm_alu_out (
        .d  (alu_out),
        .q  (alu_out_dm),
        .clk(clk)
    );

    REGISTER #(
        .N(`DMEM_DWIDTH)
    ) ex_dm_forw_B (
        .d  (forw_B),
        .q  (forw_B_dm),
        .clk(clk)
    );

    REGISTER #(
        .N(`PC_WIDTH)
    ) ex_dm_pc_add4 (
        .d  (pc_add4),
        .q  (pc_add4_dm), 
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) ex_dm_rs2_addr (
        .d  (rs2_addr_ex),
        .q  (rs2_addr_dm), 
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) ex_dm_rd_addr (
        .d  (rd_addr_ex),
        .q  (rd_addr_dm),
        .clk(clk)
    );

    REGISTER_R_CE #(
        .N(1)
    ) ex_dm_regfile_wen (
        .d  (regfile_wen_ex),
        .q  (regfile_wen_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );

    REGISTER_R_CE #(
        .N(7),
        .INIT(0)
    ) ex_dm_opcode (
        .d  (opcode_ex),
        .q  (opcode_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );

    REGISTER_R_CE #(
        .N(3),
        .INIT(0)
    ) ex_dm_func3 (
        .d  (func3_ex),
        .q  (func3_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );    
    
    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) ex_dm_func1 (
        .d  (func1_ex),
        .q  (func1_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) ex_dm_dmem_wr (
        .d  (dmem_wr_ex),
        .q  (dmem_wr_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) ex_dm_dmem_rd (
        .d  (dmem_rd_ex),
        .q  (dmem_rd_dm),
        .ce (exdm_en),    
        .clk(clk),
        .rst(exdm_rst)
    );
////////////////////////////////////////////
// dm
////////////////////////////////////////////
    ctrl_dm U_ctrl_dm (
        .opcode(opcode_dm),
        .func3(func3_dm),
        .func1(func1_dm),
        .dmem_shift(alu_out_dm[1:0]),
        
        .dmem_ext_size(dmem_in_ext_size),
        .dmem_byte_sel(dmem_byte_sel)
    );

    // dmem_gen
    assign dmem_in = (forw_dmem_din_sel==`FORW_DMEM_DIN_RS2) ? forw_B_dm : dmem_out_ext;
    dmem_gen #(
        .DWIDTH(`DMEM_DWIDTH)
    ) U_dmem_gen (
        .dmem_shift(alu_out_dm[1:0]),
        .dmem_in(dmem_in),
        .dmem_ext_size(dmem_in_ext_size),

        .dmem_in_ext(dmem_in_ext)
    );

    parameter DMEM_MIFB = "";
    assign dmem_en = 1'b1;      // @@
    assign dmem_addr = alu_out_dm[15:2];
    assign dmem_byte_wen = dmem_byte_sel & {4{dmem_wr_dm & ~dmem_rd_dm}};
    SYNC_RAM_WBE #(            
        .DWIDTH(`DMEM_DWIDTH),
        .AWIDTH(`DMEM_AWIDTH),
        .DEPTH(`DMEM_DEPTH),
        .MIF_BIN(DMEM_MIFB)
    ) U_dmem (
        .q(dmem_out), 
        .d(dmem_in_ext), 
        .addr(dmem_addr), 
        .en(dmem_en), 
        .wbe(dmem_byte_wen), 
        .clk(clk)
    );


////////////////////////////////////////////
// dm/wb    @@ reg tpye
//------------------------------------------
// output:
//      alu_out
//      dmem_out // no pipeline
//      pc_add4
//      rd_addr
//
//      regfile_wen
//      opcode
//      func3
//      func1
//      dmem_rd
////////////////////////////////////////////
    assign dmwb_en = 1'b1; // @@
    assign dmwb_rst = rst; // @@ | flush

    REGISTER #(
        .N(`ALU_DWIDTH)
    ) dm_wb_alu_out (
        .d  (alu_out_dm),
        .q  (alu_out_wb),
        .clk(clk)
    );

    REGISTER #(
        .N(`PC_WIDTH)
    ) dm_wb_pc_add4 (
        .d  (pc_add4_dm),
        .q  (pc_add4_wb), 
        .clk(clk)
    );

    REGISTER #(
        .N(`RF_AWIDTH)
    ) dm_wb_rd_addr (
        .d  (rd_addr_dm),
        .q  (rd_addr_wb),
        .clk(clk)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) dm_wb_regfile_wen (
        .d  (regfile_wen_dm),
        .q  (regfile_wen_wb),
        .ce (dmwb_en),    
        .clk(clk),
        .rst(dmwb_rst)
    );

    REGISTER_R_CE #(
        .N(7),
        .INIT(0)
    ) dm_wb_opcode (
        .d  (opcode_dm),
        .q  (opcode_wb),
        .ce (dmwb_en),    
        .clk(clk),
        .rst(dmwb_rst)
    );

    REGISTER_R_CE #(
        .N(3),
        .INIT(0)
    ) dm_wb_func3 (
        .d  (func3_dm),
        .q  (func3_wb),
        .ce (dmwb_en),    
        .clk(clk),
        .rst(dmwb_rst)
    );    
    
    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) dm_wb_func1 (
        .d  (func1_dm),
        .q  (func1_wb),
        .ce (dmwb_en),    
        .clk(clk),
        .rst(dmwb_rst)
    );

    REGISTER_R_CE #(
        .N(1),
        .INIT(0)
    ) dm_wb_dmem_rd (
        .d  (dmem_rd_dm),
        .q  (dmem_rd_wb),
        .ce (dmwb_en),    
        .clk(clk),
        .rst(dmwb_rst)
    );


////////////////////////////////////////////
// wb
////////////////////////////////////////////
    // reg [`DMEM_DWIDTH-1:0] mem_out;
    // wire [`DMEM_DWIDTH-1:0] mmio_data;
    // always @(*) begin
    //     case (alu_out_wb[31:30])
    //         2'b00: mem_out = dmem_out;
    //         2'b01: mem_out = bios_doutb;
    //         2'b10: mem_out = mmio_data;
    //         2'b11: mem_out = mmio_data;
    //     endcase
    // end
    ctrl_wb U_ctrl_wb (
        .opcode(opcode_wb),
        .func3(func3_wb),
        .func1(func1_wb),

        .dmem_ext_unsign(dmem_out_ext_unsign),
        .dmem_ext_size(dmem_out_ext_size),

        .wb_sel(wb_sel)
    );
    dmem_mask U_dmem_mask (
        .dmem_shift(alu_out_wb[1:0]),
        .dmem_out(dmem_out),
        .dmem_ext_size(dmem_out_ext_size),
        .dmem_ext_unsign(dmem_out_ext_unsign),

        .dmem_out_ext(dmem_out_ext)
    );

    assign  wb_data = ({32{wb_sel[0]}} & dmem_out_ext)
                    | ({32{wb_sel[1]}} & alu_out_wb)
                    | ({32{wb_sel[2]}} & pc_add4_wb);
                    
endmodule
