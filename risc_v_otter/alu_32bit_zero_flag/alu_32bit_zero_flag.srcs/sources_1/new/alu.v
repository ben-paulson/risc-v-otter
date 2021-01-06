`timescale 1ns / 1ps

module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] alu_op,
    output reg [31:0] result,
    output reg zero
    );
    
    always @ (*) begin
        case (alu_op)
            3'b000: result <= A & B;
            3'b001: result <= A | B;
            3'b010: result <= A + B;
            3'b110: result <= A - B;
            3'b111: result <= (A < B) ? 1 : 0;
            default: result <= 0;
        endcase
        if (result == 0) zero <= 1;
        else zero <= 0;
    end
    
endmodule
