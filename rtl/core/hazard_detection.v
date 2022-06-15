`include "topdef.vh"
`include "OpCode.vh"
module hazard_detection(
    input [6:0] opcode_id,
    input dmem_rd_ex,
    input branch_taken,
    input jump_taken,
    input [`RF_AWIDTH-1:0] rs1_addr_id,
    input [`RF_AWIDTH-1:0] rs2_addr_id,
    input [`RF_AWIDTH-1:0] rd_addr_ex,

    output reg data_flush,
    output reg ctrl_flush
);
    always @(*) begin
        if(dmem_rd_ex && ((rd_addr_ex == rs1_addr_id)||(rd_addr_ex == rs2_addr_id)) 
            && (opcode_id != `OPC_STORE || opcode_id != `OPC_JAL && opcode_id != `OPC_LUI && opcode_id != `OPC_AUIPC)) begin
            data_flush=1;
        end else begin
            data_flush=0;
        end
    end

    always @(*) begin
        if(branch_taken || jump_taken) 
            ctrl_flush = 1;
        else 
            ctrl_flush = 0;
    end
    // if(dmem_rd_dm && (rd_addr_dm == rs1_addr_ex) ||(rd_addr_dm == rs2_addr_ex))
    //ld bre
endmodule