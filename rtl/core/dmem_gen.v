`include "CtrlCode.vh"
module dmem_gen #(
    parameter DWIDTH = 32
)(
    input [1:0] dmem_shift,
    input [DWIDTH-1:0] dmem_in,
    input [1:0] dmem_ext_size,

    output reg [DWIDTH-1:0] dmem_in_ext
);
    wire [1:0] byte_shift;
    wire [1:0] half_shift;
    
    wire [5:0] offset_byte,offset_half;

    assign byte_shift = dmem_shift;
    assign half_shift = {dmem_shift[1],1'b0};
    
    assign offset_byte = byte_shift<<3;
    assign offset_half = half_shift<<3;

    always @(*) begin   // @@ ext ctrl in/out
        dmem_in_ext = 32'bx;
        case(dmem_ext_size)
            `DMEM_EXT_BYTE: 
                dmem_in_ext = {{(DWIDTH-8){dmem_in[7]}},dmem_in[7:0]} << (offset_byte);
            `DMEM_EXT_HALF: 
                dmem_in_ext = {{(DWIDTH-16){dmem_in[15]}},dmem_in[15:0]} << (offset_half);
            `DMEM_EXT_WORD: 
                dmem_in_ext = dmem_in;
        endcase
    end

endmodule