`timescale 1ns / 1ps

module controller(
    input logic clk,
    input logic [6:0] op, funct7,
    input logic [2:0] funct3,
    input logic zero,
    output logic memtoreg, memwrite,
    output logic pcsrc, alusrc,
    output logic regdst, regwrite,
    output logic jump,
    output logic [2:0] alucontrol,
    output logic pcwrite
    );
    
    logic [1:0] aluop;
    logic branch;
    
    maindec md(clk, op, memtoreg, memwrite, branch,
               alusrc, regdst, regwrite, jump, aluop, pcwrite);
    aludec ad(funct7, funct3, aluop, alucontrol);
    
    assign pcsrc = (branch & zero) | jump; // branch & zero
    
endmodule
