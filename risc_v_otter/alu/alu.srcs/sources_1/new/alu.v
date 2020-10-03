`timescale 1ns / 1ps

/*
  High level model of the RISC-V MCU
  Arithmetic Logic Unit (ALU). It implements
  the instructions below using verilog
  mathematical operators.
*/
module alu(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output reg [31:0] result
    );
    
    always @ (*) begin
        case (alu_fun)
            4'b0000: result = srcA + srcB; // add
            4'b1000: result = srcA - srcB; // sub
            4'b0110: result = srcA | srcB; // or
            4'b0111: result = srcA & srcB; // and
            4'b0100: result = srcA ^ srcB; // xor
            4'b0101: result = srcA >> srcB[4:0]; // srl
            4'b0001: result = srcA << srcB[4:0]; // sll
            4'b1101: result = $signed(srcA) >>> srcB[4:0]; // sra
            4'b0010: result = ($signed(srcA) < $signed(srcB)) ? 1 : 0; // slt
            4'b0011: result = (srcA < srcB) ? 1 : 0; // sltu
            4'b1001: result = srcA; // lui
            default: result = 32'hDEAD_BEEF;
        endcase
    end
    
endmodule
