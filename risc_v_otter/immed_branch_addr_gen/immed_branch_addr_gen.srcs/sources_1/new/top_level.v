`timescale 1ns / 1ps

/*
  Top level implementation of PC, Memory, immed_gen,
  and branch_addr_gen. Handles jal, jalr, and branch instructions
  by generating a new address from an immediate value, but does
  not load the immediate value to the PC, as this is only
  for testing.
*/
module top_level(
    input clk,
    input rst,
    input PCWrite,
    input [1:0] pcSource,
    output [31:0] u_type_imm,
    output [31:0] s_type_imm
    );
    
    // PC out
    wire [31:0] pc_data;
    
    // Instruction from memory
    wire [31:0] ir;
    
    // pcSource MUX inputs, branch_addr_gen outputs
    wire [31:0] jal, jalr, branch;
    
    // immediate values
    wire [31:0] I_type, J_type, B_type;
    
    pc_mod pc (
        .clk      (clk),
        .rst      (rst),
        .PCWrite  (PCWrite),
        .pcSource (pcSource),
        .jal      (jal),
        .jalr     (jalr),
        .branch   (branch),
        .pc       (pc_data)
        );
        
    Memory OTTER_MEMORY (
        .MEM_CLK (clk),
        .MEM_RDEN1 (1),
        .MEM_RDEN2 (0),
        .MEM_WE2 (0),
        .MEM_ADDR1 (pc_data[15:2]),
        .MEM_ADDR2 (0),
        .MEM_DIN2 (0),
        .MEM_SIZE (2),
        .MEM_SIGN (0),
        .IO_IN (0),
        .IO_WR (),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 () );
        
    immed_gen ig (
        .ir     (ir[31:7]),
        .U_type (u_type_imm),
        .I_type (I_type),
        .S_type (s_type_imm),
        .J_type (J_type),
        .B_type (B_type)
        );
        
    branch_addr_gen bag (
        .J_type (J_type),
        .B_type (B_type),
        .I_type (I_type),
        .pc     (pc_data - 4), // To align the instruction w/ its output.
        .jal    (jal),         // The "- 4" is not needed normally.
        .jalr   (jalr),
        .branch (branch)
        );
        
endmodule
