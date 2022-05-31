`include "CtrlCode.vh"
module ALU #(
    parameter DWIDTH = 32
) (
    input [DWIDTH-1:0] A,B,
    input [3:0] alu_sel,
    output reg [DWIDTH-1:0] alu_out
);
    // shift isa only use lower 5bits of rs2
    wire [4:0] shift_offset;
    assign shift_offset = B[4:0];

    always @(*) begin
        alu_out = 32'bx;
        case(alu_sel)
            `ALU_ADD:  alu_out = A + B;
            `ALU_SUB:  alu_out = A - B;
            `ALU_SLL:  alu_out = A << shift_offset;
            `ALU_SLT:  alu_out = (A[31]==B[31]) ? (A<B) : A[31];
            `ALU_SLTU: alu_out = (A < B); 
            `ALU_XOR:  alu_out = A ^ B;
            `ALU_OR:   alu_out = A | B;
            `ALU_AND:  alu_out = A & B;
            `ALU_SRL:  alu_out = A >> shift_offset;
            `ALU_SRA:  alu_out = $signed(A) >>> shift_offset; // @@ replace $signed()
            `ALU_A:    alu_out = A;
            `ALU_B:    alu_out = B;
        endcase
    end
    
endmodule