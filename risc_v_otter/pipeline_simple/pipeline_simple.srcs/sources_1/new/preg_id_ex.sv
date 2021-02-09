`timescale 1ns / 1ps

module preg_id_ex(
    input clk,
    input [31:0] pc_in,
    input [31:0] instr_in,
    input regWrite_in,
    input memWrite_in,
    input memRead2_in,
    input [3:0] alu_fun_in,
    input [31:0] alu_srcA_in,
    input [31:0] alu_srcB_in,
    input [1:0] rf_wr_sel_in,
    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [31:0] j_type_in,
    input [31:0] b_type_in,
    input [31:0] i_type_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out,
    output reg regWrite_out,
    output reg memWrite_out,
    output reg memRead2_out,
    output reg [3:0] alu_fun_out,
    output reg [31:0] alu_srcA_out,
    output reg [31:0] alu_srcB_out,
    output reg [1:0] rf_wr_sel_out,
    output reg [31:0] rs1_out,
    output reg [31:0] rs2_out,
    output reg [31:0] j_type_out,
    output reg [31:0] b_type_out,
    output reg [31:0] i_type_out
    );
    
    always @ (posedge clk) begin
        pc_out = pc_in;
        regWrite_out = regWrite_in;
        memWrite_out = memWrite_in;
        memRead2_out = memRead2_in;
        alu_fun_out = alu_fun_in;
        alu_srcA_out = alu_srcA_in;
        alu_srcB_out = alu_srcB_in;
        rf_wr_sel_out = rf_wr_sel_in;
        rs1_out = rs1_in;
        rs2_out = rs2_in;
        j_type_out = j_type_in;
        b_type_out = b_type_in;
        i_type_out = i_type_in;
        instr_out = instr_in;
    end
    
endmodule
