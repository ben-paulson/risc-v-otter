`timescale 1ns / 1ps

module alu(
    input logic [31:0] srca,
    input logic [31:0] srcb,
    input logic [2:0] alucontrol,
    output logic [31:0] aluout,
    output logic zero
    );
    
    always_comb
        case (alucontrol)
            3'b000: aluout <= srca & srcb;
            3'b001: aluout <= srca | srcb;
            3'b010: aluout <= srca + srcb;
            3'b110: aluout <= srca - srcb;
            default: aluout <= 32'hxxxxxxxx;
        endcase
        
    assign zero = aluout == 0;
    
endmodule
