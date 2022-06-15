`include "CtrlCode.vh"
module dmem_mask (
    input [1:0] dmem_shift,
    input [31:0] dmem_out,
    input [1:0] dmem_ext_size,
    input dmem_ext_unsign,

    output reg [31:0] dmem_out_ext
);
    wire [31:0] dmem_out_shift;
    wire [5:0] offset;
    assign offset = (dmem_shift[1]<<4) | (dmem_shift[0]<<3);
    assign dmem_out_shift = $signed(dmem_out) >>> (offset);
    always @(*) begin   // @@ optimize
        dmem_out_ext = 32'bx;
        case(dmem_ext_size)
            `DMEM_EXT_BYTE: dmem_out_ext = {{24{(~dmem_ext_unsign) & dmem_out_shift[7]}},dmem_out_shift[7:0]};
            `DMEM_EXT_HALF: dmem_out_ext = {{16{(~dmem_ext_unsign) & dmem_out_shift[15]}},dmem_out_shift[15:0]};
            `DMEM_EXT_WORD: dmem_out_ext = dmem_out_shift;
        endcase
    end
endmodule