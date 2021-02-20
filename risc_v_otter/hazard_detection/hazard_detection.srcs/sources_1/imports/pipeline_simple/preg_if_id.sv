`timescale 1ns / 1ps

module preg_if_id(
    input clk,
    input [31:0] pc_in,
    input [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
    );
    
    always @ (posedge clk) begin
        pc_out = pc_in; // PC will not match up with instr if not -4
        instr_out = instr_in; // (only need -4 for this pipe reg, not others)
    end
    
endmodule
