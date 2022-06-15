`include "OpCode.vh"
`include "topdef.vh"
`include "CtrlCode.vh"
module ctrl_dm (
    input [6:0] opcode,
    input [2:0] func3,
    input func1,
    input [1:0] dmem_shift,
        
    // dmem gen
    output reg [1:0] dmem_ext_size,
    // output reg dmem_wr,
    // output reg dmem_rd,
    output reg [3:0] dmem_byte_sel
    
    // csr
    // output reg csr_wen
);
    wire [1:0] byte_shift;
    wire [1:0] half_shift;

    assign byte_shift = dmem_shift;
    assign half_shift = {dmem_shift[1],1'b0};

    always @(*) begin
        dmem_ext_size = 2'b0;
        dmem_byte_sel = 4'b1111;
        case(opcode)
            `OPC_STORE: begin
                case(func3)
                    `FNC_SB: begin
                        dmem_byte_sel = 4'b0001 << byte_shift;
                        dmem_ext_size = `DMEM_EXT_BYTE;
                    end
                    `FNC_SH: begin
                        dmem_byte_sel = 4'b0011 << half_shift;
                        dmem_ext_size = `DMEM_EXT_HALF;
                    end
                    `FNC_SW: begin 
                        dmem_byte_sel = 4'b1111;
                        dmem_ext_size = `DMEM_EXT_WORD;
                    end
                endcase
            end
        endcase
    end
endmodule