`include "topdef.vh"
`include "CtrlCode.vh"
module Datapath (
    input clk,rst,

    // pc
    input pc_sel,

    // rf
    input regfile_wen,

    // imm
    input [2:0] imm_sel,

    // bc
    input branch_unsign,

    // alu
    input alu_A_sel,
    input alu_B_sel,
    input [3:0] alu_sel,

    // csr
    input csr_wen,

    // dmem
    input dmem_wen,
    input dmem_ext_unsign,
    input [1:0] dmem_ext_size,

    // wb
    input [2:0] wb_sel,

    output [`IMEM_DWIDTH-1:0] inst_out,
    output branch_eq,
    output branch_lt
); 

///////////////////////////////////
// internal signal definition
///////////////////////////////////

    //--------ctrl siganl-------//
    //pc
    wire pc_en;

    //imem
    wire imem_en;
    wire [3:0] imem_wen; 

    //dmem
    wire dmem_en;
    wire [3:0] dmem_byte_wen;
    reg [3:0] dmem_byte_sel;
    wire [1:0] byte_shift;
    wire [1:0] half_shift;
    
    //--------data signal-------//
    //pc
    wire [`PC_WIDTH-1:0] pc_value;
    wire [`PC_WIDTH-1:0] pc_add4;
    wire [`PC_WIDTH-1:0] pc_next;

    //imem
    wire [`IMEM_DWIDTH-1:0] imem_out; //instance
    wire [`IMEM_AWIDTH-1:0] imem_addr;
    wire [`IMEM_DWIDTH-1:0] imem_in;


    //register file
    wire [`RF_AWIDTH-1:0] rs1_addr,rs2_addr;
    wire [`RF_DWIDTH-1:0] rs1_data,rs2_data; //read
    wire [`RF_AWIDTH-1:0] rd_addr;
    wire [`RF_DWIDTH-1:0] rd_data; //write

    //imm_gen
    wire [`IMM_DWIDTH-1:0] imm_out;

    //alu
    wire [`ALU_DWIDTH-1:0] alu_A,alu_B;
    wire [`ALU_DWIDTH-1:0] alu_out;

    //csr
    wire [`CSR_AWIDTH-1:0] csr_addr;
    wire [`CSR_DWIDTH-1:0] csr_data_in;
    wire [`CSR_DWIDTH-1:0] csr_data_out;

    //dmem
    wire [`DMEM_AWIDTH-1:0] dmem_addr;
    wire [`DMEM_DWIDTH-1:0] dmem_out;
    wire [`DMEM_DWIDTH-1:0] dmem_in;
    wire [`DMEM_DWIDTH-1:0] dmem_out_shift;
    reg  [`DMEM_DWIDTH-1:0] dmem_ext_in;
    reg  [`DMEM_DWIDTH-1:0] dmem_ext_out;

    //write back
    wire [`WB_DWIDTH-1:0] wb_data;

///////////////////////////////////
// block instance
///////////////////////////////////

    //pc @@ alu width
    assign pc_add4 = pc_value + 32'd4;
    assign pc_next = (pc_sel==`PC_ALU) ? alu_out[`PC_WIDTH-1:0] : pc_add4;
    assign pc_en = 1'b1;
    REGISTER_R_CE #(
        .N(`PC_WIDTH)
    ) pc (
        .q(pc_value), 
        .d(pc_next), 
        .rst(rst), 
        .ce(pc_en),
        .clk(clk)
    );

    //imem
    assign imem_addr = pc_value[`PC_WIDTH-1:2];

    assign imem_en = 1'b1;  // @@
    assign imem_in = 32'b0;
    assign imem_wen = 4'b0;
    parameter IMEM_MIFH = "";
    ASYNC_RAM_WBE #(         // @@ sync ram
        .DWIDTH(`IMEM_DWIDTH),
        .AWIDTH(`IMEM_AWIDTH),
        .MIF_HEX(IMEM_MIFH)
    ) U_imem (
        .q(imem_out),   //Instance
        .d(imem_in), 
        .addr(imem_addr), 
        .en(imem_en), 
        .wbe(imem_wen), //[DWIDTH/8-1:0] wbe;  // write-byte-enable
        .clk(clk)
    );
    assign inst_out = imem_out;

    //register file
    assign rd_wen = regfile_wen; // @@ write back control 
    assign rd_addr = imem_out[11:7];
    assign rd_data =  wb_data; //@@ 
    assign rs1_addr = imem_out[19:15];
    assign rs2_addr = imem_out[24:20];

    ASYNC_RAM_1W2R #(
        .DWIDTH(`RF_DWIDTH), 
        .AWIDTH(`RF_AWIDTH),
        .DEPTH(`RF_DEPTH)
    )  U_regfile (
        .d0(rd_data), 
        .addr0(rd_addr), 
        .we0(rd_wen), 
        .q1(rs1_data), 
        .addr1(rs1_addr),
        .q2(rs2_data), 
        .addr2(rs2_addr), 
        .clk(clk)
    );

    // Branch_Comp
    BRANCH_COMP #(
        .DWIDTH(`RF_DWIDTH)
    ) U_brn_comp (
        .rs1(rs1_data),
        .rs2(rs2_data),
        .branch_unsign(branch_unsign),
        .branch_eq(branch_eq),
        .branch_lt(branch_lt)
    );

    //Imm_gen
    IMM_GEN #(
        .DWIDTH(`IMEM_DWIDTH)
    ) U_imm_gen (
        .imm_sel(imm_sel),
        .inst_in(imem_out[`IMEM_DWIDTH-1:7]),
        .imm_out(imm_out)
    );

    //ALU
    assign alu_A = (alu_A_sel==`A_SEL_PC)  ? {{(`ALU_DWIDTH-`PC_WIDTH){pc_value[`PC_WIDTH-1]}},pc_value} : rs1_data;
    assign alu_B = (alu_B_sel==`B_SEL_IMM) ? imm_out : rs2_data;
    ALU #(
        .DWIDTH(`ALU_DWIDTH)
    ) U_alu (
        .A(alu_A),
        .B(alu_B),
        .alu_sel(alu_sel),
        .alu_out(alu_out)
    );

    // csr 
    assign csr_data_in = alu_out;
    assign csr_addr = imem_out[31:20]; // 0x51e
    ASYNC_RAM #(
        .DWIDTH(`CSR_DWIDTH),
        .AWIDTH(`CSR_AWIDTH)
    ) U_csr (
        .addr(csr_addr),  
        .we(csr_wen),
        .q(csr_data_out),
        .d(csr_data_in),
        .clk(clk)
    );

    //dmem
    assign dmem_en = 1'b1;      // @@
    assign dmem_addr = alu_out[15:2];

    assign dmem_in = rs2_data;
    
    // @@ dmem gen

    wire [5:0] offset1,offset2;
    assign offset1 = byte_shift<<3;
    assign offset2 = half_shift<<3;

    assign byte_shift = alu_out[1:0];
    assign half_shift = {alu_out[1],1'b0};
    always @(*) begin   // @@ ext ctrl in/out
        dmem_ext_in = 32'bx;
        dmem_byte_sel = 4'bx;
        case(dmem_ext_size)
            `DMEM_EXT_BYTE: begin
                dmem_byte_sel = 4'b0001 << byte_shift;
                dmem_ext_in = {{24{dmem_in[7]}},dmem_in[7:0]} << (offset1);
            end
            `DMEM_EXT_HALF: begin
                dmem_byte_sel = 4'b0011 << half_shift;
                dmem_ext_in = {{16{dmem_in[15]}},dmem_in[15:0]} << (offset2);
            end
            `DMEM_EXT_WORD: begin
                dmem_byte_sel = 4'b1111;
                dmem_ext_in = dmem_in;
            end
        endcase
    end
    assign dmem_byte_wen = dmem_byte_sel & {4{dmem_wen}};

    parameter DMEM_MIFB = "";
    ASYNC_RAM_WBE #(            // @@ sync ram
        .DWIDTH(`DMEM_DWIDTH),
        .AWIDTH(`DMEM_AWIDTH),
        .DEPTH(`DMEM_DEPTH),
        .MIF_BIN(DMEM_MIFB)
    ) U_dmem (
        .q(dmem_out), 
        .d(dmem_ext_in), 
        .addr(dmem_addr), 
        .en(dmem_en), 
        .wbe(dmem_byte_wen), 
        .clk(clk)
    );

    // @@ dmem mask
    wire [5:0] offset3;
    assign offset3 = (alu_out[1]<<4) | (alu_out[0]<<3);
    assign dmem_out_shift = $signed(dmem_out) >>> (offset3);
    always @(*) begin   // @@ optimize
        dmem_ext_out = 32'bx;
        case(dmem_ext_size)
            `DMEM_EXT_BYTE: dmem_ext_out = {{24{(~dmem_ext_unsign) & dmem_out_shift[7]}},dmem_out_shift[7:0]};
            `DMEM_EXT_HALF: dmem_ext_out = {{16{(~dmem_ext_unsign) & dmem_out_shift[15]}},dmem_out_shift[15:0]};
            `DMEM_EXT_WORD: dmem_ext_out = dmem_out_shift;
        endcase
    end

    //write back
    assign  wb_data = ({32{wb_sel[0]}} & dmem_ext_out)
                    | ({32{wb_sel[1]}} & alu_out)
                    | ({32{wb_sel[2]}} & pc_add4);
                    // @@ lui auipc

endmodule