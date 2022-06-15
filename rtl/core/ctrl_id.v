`include "OpCode.vh"
`include "topdef.vh"
`include "CtrlCode.vh"
module ctrl_id (
    input [`IMEM_DWIDTH-1:0] inst_in,

    output [6:0] opcode,
    output [2:0] func3,
    output func1,

    // rf
    output reg regfile_wen,
    
    // imm
    output reg [2:0] imm_sel, 

    // dmem
    output reg dmem_wr,
    output reg dmem_rd
);
/////////////////////////////////
// internal signal definition
/////////////////////////////////
    // opcode func
    // wire [6:0] opcode;
    // wire [4:0] opcode5;
    // wire [6:0] func7;
    // wire [2:0] func3;
    // wire func1;
    
///////////////////////////////////
// decode logic
///////////////////////////////////
    // opcode func
    assign opcode = inst_in[6:0];
    // assign opcode5 = inst_in[6:2];
    assign func7 = inst_in[31:25];
    assign func3 = inst_in[14:12];
    assign func1 = inst_in[30];

    // decode
    always @(*) begin
        regfile_wen = 1'b0;
        imm_sel = 3'bx;
        dmem_wr = 1'b0;
        dmem_rd = 1'b0;
        case(opcode)
            `OPC_LUI: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_UTYPE;
            end
            
            `OPC_AUIPC: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_UTYPE;
            end

            `OPC_JAL: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_JTYPE;
            end

            `OPC_JALR: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
            end

            `OPC_BRANCH: begin  
                imm_sel = `IMM_BTYPE;
            end

            `OPC_STORE: begin
                imm_sel = `IMM_STYPE;
                dmem_wr = 1'b1;
            end

            `OPC_LOAD: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
                dmem_rd = 1'b1;
            end

            `OPC_ARI_RTYPE: begin
                regfile_wen = 1'b1;
            end

            `OPC_ARI_ITYPE: begin
                regfile_wen = 1'b1;
                imm_sel = `IMM_ITYPE;
            end
            
            `OPC_CSR: begin
                imm_sel = `IMM_CSR;
            end
        endcase
    end
endmodule