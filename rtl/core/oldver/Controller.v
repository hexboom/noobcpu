`include "../Opcode.vh"
`include "../CtrlCode.vh"
module Controller (
    input [31:0] inst_in,
    input branch_eq,branch_lt,
    output pc_sel,
    output regfile_wen,
    output branch_unsign,
    output alu_A_sel,
    output alu_B_sel,
    output reg [3:0] alu_sel,
    output [3:0] dmem_wen,
    output dmem_ext_unsign,
    output dmem_ext_half,
    output dmem_ext_lw,
    output [2:0] wb_sel
);

/////////////////////////////////
// internal signal definition
/////////////////////////////////
    // opcode func
    wire [6:0] opcode;
    wire [4:0] opcode_5;
    wire [6:0] func7;
    wire [2:0] func3;
    wire func;
    
    //ctrl signal
    // wire pc_sel;
    // wire [2:0] imm_sel;
    // wire regfile_wen;
    // wire branch_unsign;
    // wire A_sel;
    // wire B_sel;
    // reg [3:0] alu_sel;
    // wire [3:0] dmem_wen;  //write byte en
    // wire [2:0] wb_sel;
    
///////////////////////////////////
// decode logic
///////////////////////////////////
    //opcode func
    assign opcode = inst_in[6:0];
    assign opcode_5 = inst_in[6:2];
    assign func7 = inst_in[31:25];
    assign func3 = inst_in[14:12];
    assign func1 = inst_in[30];

    //pc @@ optimize
    assign pc_sel = ((opcode==`OPC_BRANCH) && (
                    (func3==`FNC_BEQ && branch_eq)  ||
                    (func3==`FNC_BNE && !branch_eq) ||
                    (func3==`FNC_BLT && branch_lt)  ||
                    (func3==`FNC_BGE && !branch_lt) ||
                    (func3==`FNC_BLTU&& branch_lt)  ||
                    (func3==`FNC_BGEU&& !branch_lt))) ||
                    (opcode==`OPC_JAL) || (opcode==`OPC_JALR);

    //imm_gen 
    // assign imm_sel = 

    //reg file
    assign regfile_wen = (opcode != `OPC_BRANCH) && (opcode != `OPC_STORE);

    //branch
    assign branch_unsign = (opcode==`OPC_BRANCH && (func3==`FNC_BLTU || func3==`FNC_BGEU ));

    //A_mux pc : rs1
    assign alu_A_sel = (opcode == `OPC_BRANCH   || 
                    opcode == `OPC_JAL      ||
                    opcode == `OPC_AUIPC) ? 1'b1 : 1'b0;
    //B_mux  imm : rs2
    assign alu_B_sel = (opcode == `OPC_LOAD         || 
                    opcode == `OPC_STORE        || 
                    opcode == `OPC_BRANCH       ||
                    opcode == `OPC_ARI_ITYPE    ||
                    opcode == `OPC_JAL          ||
                    opcode == `OPC_JALR         ||
                    opcode == `OPC_LUI          ||
                    opcode == `OPC_AUIPC) ? 1'b1 : 1'b0;
    //alu
    // @@ optimize
    always @(*) begin
        alu_sel = `ALU_ADD; // @@ default value
        case(opcode)
            `OPC_ARI_RTYPE:
                alu_sel = {func3, func1};
            `OPC_ARI_ITYPE:
                alu_sel = (func3==`FNC_SRL_SRA) ? ({func3, func1}) : ({func3, 1'b0});
        endcase
    end

    //dmem -sw @@ optimize
    assign dmem_wen[0] = (opcode==`OPC_STORE && (func3==`FNC_SW || func3==`FNC_SH || func3==`FNC_SB));
    assign dmem_wen[1] = (opcode==`OPC_STORE && (func3==`FNC_SW || func3==`FNC_SH));
    assign dmem_wen[2] = (opcode==`OPC_STORE && func3==`FNC_SW );
    assign dmem_wen[3] = (opcode==`OPC_STORE && func3==`FNC_SW );

    // dmem -lw
    assign dmem_ext_unsign = func3[2]; 
    assign dmem_ext_half = func3[0];
    assign dmem_ext_lw = func3[1]; 
    // @@ extend for lh lb?

    //writebcak 
    assign wb_sel[0] = (opcode==`OPC_LOAD); //dmem
    assign wb_sel[1] = (opcode==`OPC_ARI_RTYPE || opcode==`OPC_ARI_ITYPE); //alu
    assign wb_sel[2] = (opcode==`OPC_JAL || opcode==`OPC_JALR); //pcnext
    // @@ lui auipc

endmodule