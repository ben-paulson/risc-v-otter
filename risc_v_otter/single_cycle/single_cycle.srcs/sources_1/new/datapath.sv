`timescale 1ns / 1ps

module datapath(
    input logic clk, reset,
    input logic memtoreg, pcsrc,
    input logic alusrc, regdst,
    input logic regwrite, jump,
    input logic [2:0] alucontrol,
    output logic zero,
    output logic [31:0] pc,
    input logic [31:0] instr,
    output logic [31:0] aluout, writedata,
    input logic [31:0] readdata,
    input logic pcwrite
    );
    
    logic [31:0] pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    
    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnextbr, pcwrite, pc);
    adder pcadd1(pc, 32'b100, pcplus4);
    adder pcadd2(pc, signimm, pcbranch);
    mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    
    // register file logic
    regfile rf(clk, regwrite, instr[19:15], instr[24:20],
               instr[11:7], result, srca, writedata);
    mux2 #(32) resmux(aluout, readdata, memtoreg, result);
    signext se(instr, signimm);
    
    // ALU logic
    mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb);
    alu alu(srca, srcb, alucontrol, aluout, zero);
    
endmodule