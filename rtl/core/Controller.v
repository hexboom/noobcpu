`include "OpCode.vh"
`include "topdef.vh"
`include "CtrlCode.vh"
module Controller (
    input [`IMEM_DWIDTH-1:0] inst_in,

    input branch_eq,
    input branch_lt,

    // pc
    output reg pc_sel,

    // rf
    output reg regfile_wen,

    // imm
    output reg [2:0] imm_sel, 

    // bc
    output reg branch_unsign,

    // alu
    output reg alu_A_sel,
    output reg alu_B_sel,
    output reg [3:0] alu_sel,

    // csr
    output reg csr_wen,
    // dmem
    output reg dmem_wen,
    output reg dmem_ext_unsign,
    output reg [1:0] dmem_ext_size,

    // wb
    output reg [2:0] wb_sel
);
/////////////////////////////////
// internal signal definition
/////////////////////////////////
    // opcode func
    wire [6:0] opcode;
    wire [4:0] opcode5;
    wire [6:0] func7;
    wire [2:0] func3;
    wire func1;
    
///////////////////////////////////
// decode logic
///////////////////////////////////
    // opcode func
    assign opcode = inst_in[6:0];
    assign opcode5 = inst_in[6:2];
    assign func7 = inst_in[31:25];
    assign func3 = inst_in[14:12];
    assign func1 = inst_in[30];

    // decode
    always @(*) begin
        pc_sel = `PC_ADD4;
        regfile_wen = 1'b0;
        imm_sel = 3'bx;
        branch_unsign = 1'b0;
        alu_A_sel = `A_SEL_PC;
        alu_B_sel = `B_SEL_IMM;
        alu_sel = `ALU_ADD;
        dmem_wen = 1'b0; 
        dmem_ext_unsign = 1'b0;
        dmem_ext_size = 2'b0;
        wb_sel = 3'bx; // @@
        case(opcode5)
            `OPC_LUI_5: begin
                regfile_wen = 1'b1;
                alu_sel = `ALU_B;
                imm_sel = `IMM_UTYPE;
                wb_sel = `WB_ALU;
            end
            
            `OPC_AUIPC_5: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_UTYPE;
                wb_sel = `WB_ALU;
            end

            `OPC_JAL_5: begin
                pc_sel = `PC_ALU;
                regfile_wen = 1'b1;
                imm_sel = `IMM_JTYPE;
                wb_sel = `WB_PCADD4;
            end

            `OPC_JALR_5: begin
                pc_sel = `PC_ALU;
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
                alu_A_sel = `A_SEL_RS1;
                wb_sel = `WB_PCADD4;
            end

            `OPC_BRANCH_5: begin  
                imm_sel = `IMM_BTYPE;
                case(func3)
                    `FNC_BEQ: pc_sel = (branch_eq==1'b1) ? `PC_ALU : `PC_ADD4;
                    `FNC_BNE: pc_sel = (branch_eq==1'b0) ? `PC_ALU : `PC_ADD4;
                    `FNC_BLT: pc_sel = (branch_lt==1'b1) ? `PC_ALU : `PC_ADD4;
                    `FNC_BGE: pc_sel = (branch_lt==1'b0) ? `PC_ALU : `PC_ADD4;
                    `FNC_BLTU: begin
                        pc_sel = (branch_lt==1'b1) ? `PC_ALU : `PC_ADD4;
                        branch_unsign = 1'b1;
                    end
                    `FNC_BGEU: begin
                        pc_sel = (branch_lt==1'b0) ? `PC_ALU : `PC_ADD4;
                        branch_unsign = 1'b1;
                    end
                endcase
                
            end
            `OPC_STORE_5: begin
                imm_sel = `IMM_STYPE;
                alu_A_sel = `A_SEL_RS1;
                dmem_wen = 1'b1;
                case(func3)
                    `FNC_SB: dmem_ext_size = `DMEM_EXT_BYTE;
                    `FNC_SH: dmem_ext_size = `DMEM_EXT_HALF;
                    `FNC_SW: dmem_ext_size = `DMEM_EXT_WORD;
                endcase
            end

            `OPC_LOAD_5: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
                alu_A_sel = `A_SEL_RS1;
                case(func3)
                    `FNC_LB:  dmem_ext_size = `DMEM_EXT_BYTE;
                    `FNC_LH:  dmem_ext_size = `DMEM_EXT_HALF;
                    `FNC_LW:  dmem_ext_size = `DMEM_EXT_WORD;
                    `FNC_LBU: begin
                        dmem_ext_unsign = 1'b1;
                        dmem_ext_size = `DMEM_EXT_BYTE;
                    end
                    `FNC_LHU: begin
                        dmem_ext_unsign = 1'b1;
                        dmem_ext_size = `DMEM_EXT_HALF;
                    end
                endcase
                wb_sel = `WB_DMEM;
            end

            `OPC_ARI_RTYPE_5: begin
                regfile_wen = 1'b1;
                alu_A_sel = `A_SEL_RS1;
                alu_B_sel = `B_SEL_RS2;
                // alu_sel = {func3, func1};
                case(func3)
                    `FNC_ADD_SUB: alu_sel = (func1==`FNC2_ADD) ? `ALU_ADD : `ALU_SUB;
                    `FNC_SLL:     alu_sel = `ALU_SLL;
                    `FNC_SLT:     alu_sel = `ALU_SLT;
                    `FNC_SLTU:    alu_sel = `ALU_SLTU;
                    `FNC_XOR:     alu_sel = `ALU_XOR;
                    `FNC_OR:      alu_sel = `ALU_OR;
                    `FNC_AND:     alu_sel = `ALU_AND;
                    `FNC_SRL_SRA: alu_sel = (func1==`FNC2_SRL) ? `ALU_SRL : `ALU_SRA;
                endcase
                wb_sel = `WB_ALU;
            end

            `OPC_ARI_ITYPE_5: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
                alu_A_sel = `A_SEL_RS1;
                // alu_sel = (func3==`FNC_SRL_SRA) ? ({func3, func1}) : ({func3, 1'b0});
                case(func3)
                    `FNC_ADD_SUB: alu_sel = `ALU_ADD;
                    `FNC_SLL:     alu_sel = `ALU_SLL;
                    `FNC_SLT:     alu_sel = `ALU_SLT;
                    `FNC_SLTU:    alu_sel = `ALU_SLTU;
                    `FNC_XOR:     alu_sel = `ALU_XOR;
                    `FNC_OR:      alu_sel = `ALU_OR;
                    `FNC_AND:     alu_sel = `ALU_AND;
                    `FNC_SRL_SRA: alu_sel = (func1==`FNC2_SRL) ? `ALU_SRL : `ALU_SRA;
                endcase
                wb_sel = `WB_ALU;
            end
            
            `OPC_CSR_5: begin 
                csr_wen = 1'b1; // @@
                case(func3)
                    `FNC_CSRRW: begin
                        // imm_sel = `IMM_CSR;
                        alu_sel = `ALU_A;
                    end
                    `FNC_CSRRWI: begin
                        imm_sel = `IMM_CSR;
                        alu_sel = `ALU_B;
                    end
                endcase
            end
        endcase
    end
endmodule