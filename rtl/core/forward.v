`include "topdef.vh"
`include "CtrlCode.vh"
module forward (
    input regfile_wen_ex,
    input regfile_wen_dm,
    input regfile_wen_wb,
    input dmem_wr_dm,
    input dmem_rd_wb,
    input [`RF_AWIDTH-1:0] rs1_addr_ex,
    input [`RF_AWIDTH-1:0] rs2_addr_ex,
    input [`RF_AWIDTH-1:0] rs2_addr_dm,
    input [`RF_AWIDTH-1:0] rd_addr_dm,
    input [`RF_AWIDTH-1:0] rd_addr_wb,

    output reg [1:0] forw_A_sel,
    output reg [1:0] forw_B_sel,
    output reg forw_dmem_din_sel
);
    // @@ opt
    always @(*) begin
        if(regfile_wen_dm && rs1_addr_ex!='b0 && rs1_addr_ex==rd_addr_dm)
            forw_A_sel = `FORW_SRC_DM;  // higher priority
        else if(regfile_wen_wb && rs1_addr_ex!='b0 && rs1_addr_ex==rd_addr_wb)
            forw_A_sel = `FORW_SRC_WB;
        else 
            forw_A_sel = `FORW_SRC_EX;  //no forward
    end

    always @(*) begin
        if(regfile_wen_dm && rs2_addr_ex!='b0 && rs2_addr_ex==rd_addr_dm)
            forw_B_sel = `FORW_SRC_DM;
        else if(regfile_wen_wb && rs2_addr_ex!='b0 && rs2_addr_ex==rd_addr_wb)
            forw_B_sel = `FORW_SRC_WB;
        else 
            forw_B_sel = `FORW_SRC_EX;  //no forward
    end
    
    always @(*) begin
        if(dmem_rd_wb && dmem_wr_dm && rs2_addr_dm==rd_addr_wb)
            forw_dmem_din_sel = `FORW_DMEM_DIN_DMEM;
        else 
            forw_dmem_din_sel = `FORW_DMEM_DIN_RS2;
    end
endmodule