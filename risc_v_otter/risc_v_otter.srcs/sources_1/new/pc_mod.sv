`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2020 04:24:52 PM
// Design Name: 
// Module Name: pc_mod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_mod(
    input clk,
    input rst,
    input PCWrite,
    input [1:0] pcSource,
    output [31:0] pc
    );
    
    // PC source options - jal & jalr are jumps, branch is a branch.
    // Constants for now, will be changed later.
    parameter jalr = 32'h0000_4444;
    parameter branch = 32'h0000_8888;
    parameter jal = 32'h0000_CCCC;
    
    wire pc_data_in;
    
    // Mux to choose whether to jump or increment address
    mux_4t1_nb  #(.n(32)) pc_source_mux  (
        .SEL   (pcSource),
        .D0    (pc + 4), 
        .D1    (jalr), 
        .D2    (branch), 
        .D3    (jal),
        .D_OUT (pc_data_in) );  
    
    // Program count counter/register    
    reg_nb_sclr #(32) PC (
        .data_in  (pc_data_in), 
        .ld       (PCWrite), 
        .clk      (clk), 
        .clr      (rst), 
        .data_out (pc)
        );  
        
endmodule
