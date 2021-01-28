`timescale 1ns / 1ps

module riscv(
    input logic clk, reset,
    output logic [31:0] pc,
    input logic [31:0] instr,
    output logic memwrite,
    output logic [31:0] aluout, writedata,
    input logic [31:0] readdata
    );
    
    logic memtoreg, alusrc, regdst,
          regwrite, jump, pcsrc, zero;
          
    logic [2:0] alucontrol;
    
    controller c(clk, instr[6:0], instr[31:25], instr[14:12], zero,
                 memtoreg, memwrite, pcsrc,
                 alusrc, regdst, regwrite, jump,
                 alucontrol, pcwrite);
                 
    datapath dp(clk, reset, memtoreg, pcsrc,
                alusrc, regst, regwrite, jump,
                alucontrol,
                zero, pc, instr,
                aluout, writedata, readdata, pcwrite);
    
endmodule
