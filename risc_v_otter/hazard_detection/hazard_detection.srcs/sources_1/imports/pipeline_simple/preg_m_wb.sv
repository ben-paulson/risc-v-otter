`timescale 1ns / 1ps

module preg_m_wb(
    input clk,
    input [31:0] pc_in,
    input [31:0] instr_in,
    input regWrite_in,
    input [31:0] memdout2_in,
    input [31:0] alu_in,
    input [1:0] rf_wr_sel_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out,
    output reg regWrite_out,
    output reg [31:0] memdout2_out,
    output reg [31:0] alu_out,
    output reg [1:0] rf_wr_sel_out
    );
    
    always @ (posedge clk) begin
        pc_out = pc_in;
        regWrite_out = regWrite_in;
        instr_out = instr_in;
        rf_wr_sel_out = rf_wr_sel_in;
        memdout2_out = memdout2_in;
        alu_out = alu_in;
    end
    
endmodule
