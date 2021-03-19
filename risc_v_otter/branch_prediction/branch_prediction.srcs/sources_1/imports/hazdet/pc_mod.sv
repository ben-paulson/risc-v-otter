`timescale 1ns / 1ps

/*
  The program counter (PC) module
  with MUX for data in selection
*/
module pc_mod(
    input clk,
    input rst,
    input PCWrite,
    input ivb,
    input [31:0] id_pc,
    input [2:0] pcSource,
    input [31:0] jalr,
    input [31:0] jal,
    input [31:0] branch,
    output [31:0] pc
    );
    
    // Data input for the PC register
    wire [31:0] pc_data_in;
    wire [31:0] pcplus4;
    
    mux_2t1_nb  #(.n(32)) pcplus4_mux (
        .SEL   (ivb), 
        .D0    (pc + 4), 
        .D1    (id_pc + 4), 
        .D_OUT (pcplus4)
        );

    // Mux to choose whether to jump or increment address
    mux_4t1_nb  #(.n(32)) pc_source_mux  (
        .SEL   (pcSource[1:0]),
        .D0    (pcplus4),
        .D1    (jalr), 
        .D2    (branch), 
        .D3    (jal),
        .D_OUT (pc_data_in) 
        );  
    
    // Program count counter/register    
    reg_nb_sclr #(.n(32)) PC (
        .data_in  (pc_data_in), 
        .ld       (PCWrite), 
        .clk      (clk), 
        .clr      (rst), 
        .data_out (pc)
        );  
        
endmodule
