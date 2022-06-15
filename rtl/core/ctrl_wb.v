`include "OpCode.vh"
`include "topdef.vh"
`include "CtrlCode.vh"
module ctrl_wb (
    input [6:0] opcode,
    input [2:0] func3,
    input func1,

    // dmem
    output reg dmem_ext_unsign,
    output reg [1:0] dmem_ext_size,

    // wb
    output reg [2:0] wb_sel
);
    // decode
    always @(*) begin
        dmem_ext_unsign = 1'b0;
        dmem_ext_size = 2'b0;
        wb_sel = 3'bx; // @@
        case(opcode)
            `OPC_LUI: begin
                wb_sel = `WB_ALU;
            end
            
            `OPC_AUIPC: begin
                wb_sel = `WB_ALU;
            end

            `OPC_JAL: begin
                wb_sel = `WB_PCADD4;
            end

            `OPC_JALR: begin
                wb_sel = `WB_PCADD4;
            end

            `OPC_LOAD: begin
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

            `OPC_ARI_RTYPE: begin
                wb_sel = `WB_ALU;
            end

            `OPC_ARI_ITYPE: begin
                wb_sel = `WB_ALU;
            end
            
        endcase
    end
endmodule