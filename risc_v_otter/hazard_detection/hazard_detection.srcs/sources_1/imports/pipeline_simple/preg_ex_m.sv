`timescale 1ns / 1ps

module preg_ex_m(
    input clk,
    input [31:0] pc_in,
    input [31:0] instr_in,
    input regWrite_in,
    input memWrite_in,
    input memRead2_in,
    input [31:0] alu_in,
    input [1:0] rf_wr_sel_in,
    input [31:0] rs2_in,
    output reg [31:0] pc_out,
    output reg regWrite_out,
    output reg memWrite_out,
    output reg memRead2_out,
    output reg [31:0] alu_out,
    output reg [1:0] rf_wr_sel_out,
    output reg [31:0] rs2_out,
    output reg [31:0] instr_out
    );
    
    always @ (posedge clk) begin
        pc_out = pc_in;
        regWrite_out = regWrite_in;
        memWrite_out = memWrite_in;
        memRead2_out = memRead2_in;
        alu_out = alu_in;
        rf_wr_sel_out = rf_wr_sel_in;
        rs2_out = rs2_in;
        instr_out = instr_in;
    end
    
endmodule
