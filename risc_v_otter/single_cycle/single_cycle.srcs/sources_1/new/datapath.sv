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
    
    logic [4:0] writereg;
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    
    // next PC logic
    flopr #(32) pcreg(clk, reset, pcnextbr, pcwrite, pc); //pcnext
    adder pcadd1(pc, 32'b100, pcplus4);
    s12 immsh(signimm, signimmsh);
    adder pcadd2(pc, signimm, pcbranch); //signimmsh, pcplus4
    mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    //mux2 #(32) pcmux(pcnextbr, signimm, jump, pcnext); // {pcplus4[31:28], instr[25:0], 2'b00}
    
    // register file logic
    regfile rf(clk, regwrite, instr[19:15], instr[24:20],
               instr[11:7], result, srca, writedata); // instr[11:7] was regdst
    mux2 #(5) wrmux(instr[19:15], instr[11:7],
                    regdst, writereg);
    mux2 #(32) resmux(aluout, readdata, memtoreg, result);
    signext se(instr, signimm);
    
    // ALU logic
    mux2 #(32) srcbmux(writedata, signimm, alusrc, srcb);
    alu alu(srca, srcb, alucontrol, aluout, zero);
    
endmodule
