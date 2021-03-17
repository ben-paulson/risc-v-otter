`timescale 1ns / 1ps

module preg_if_id(
    input clk,
    input write,
    input [31:0] pc_in,
    input ivb_in,
    output reg [31:0] pc_out,
    output reg ivb_out
    );
    
    always @ (posedge clk) begin
        if (write) begin
            pc_out = pc_in; // PC will not match up with instr if not -4
            ivb_out = ivb_in;
        end
    end
    
endmodule
