`include "OpCode.vh"
`include "topdef.vh"
`include "CtrlCode.vh"
module ctrl_ex (
    input [6:0] opcode,
    input [2:0] func3,
    input func1,
    input branch_eq,
    input branch_lt,
    // pc
    output reg pc_sel,
    
    // bc
    output reg branch_unsign,
    output reg branch_taken,
    output reg jump_taken,
        
    // alu
    output reg alu_A_sel,
    output reg alu_B_sel,
    output reg [3:0] alu_sel
);
    // decode
    // decode
    always @(*) begin
        pc_sel = `PC_ADD4;
        branch_unsign = 1'b0;
        alu_A_sel = `A_SEL_PC;
        alu_B_sel = `B_SEL_IMM;
        alu_sel = `ALU_ADD;
        branch_taken = 1'b0;
        jump_taken = 1'b0;
        case(opcode)
            `OPC_LUI: begin
                alu_sel = `ALU_B;
            end

            `OPC_JAL: begin
                jump_taken = 1'b1;
                pc_sel = `PC_ALU;
            end

            `OPC_JALR: begin
                jump_taken = 1'b1;
                pc_sel = `PC_ALU;
                alu_A_sel = `A_SEL_RS1;
            end

            `OPC_BRANCH: begin  // @@opt
                case(func3)
                    `FNC_BEQ: begin 
                        if(branch_eq==1'b1) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                    end
                    `FNC_BNE: begin 
                        if(branch_eq==1'b0) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                    end
                    `FNC_BLT: begin 
                        if(branch_lt==1'b1) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                    end
                    `FNC_BGE: begin 
                        if(branch_lt==1'b0) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                    end
                    `FNC_BLTU: begin
                        if(branch_lt==1'b1) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                        branch_unsign = 1'b1;
                    end
                    `FNC_BGEU: begin
                        if(branch_lt==1'b0) begin
                            pc_sel = `PC_ALU;
                            branch_taken = 1'b1;
                        end
                        branch_unsign = 1'b1;
                    end
                endcase
                
            end
            `OPC_STORE: begin
                alu_A_sel = `A_SEL_RS1;
            end

            `OPC_LOAD: begin
                alu_A_sel = `A_SEL_RS1;
            end

            `OPC_ARI_RTYPE: begin
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
            end

            `OPC_ARI_ITYPE: begin
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
            end
            
            `OPC_CSR: begin 
                case(func3)
                    `FNC_CSRRW: alu_sel = `ALU_A;
                    `FNC_CSRRWI: alu_sel = `ALU_B;
                endcase
            end
        endcase
    end
endmodule