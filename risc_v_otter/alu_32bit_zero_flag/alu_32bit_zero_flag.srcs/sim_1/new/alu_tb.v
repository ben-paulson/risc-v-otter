`timescale 1ns / 1ps

module alu_tb();

    reg [31:0] A, B;
    reg [2:0] alu_op;
    wire [31:0] result;
    wire zero;
    
    alu UUT (
        .A      (A),
        .B      (B),
        .alu_op (alu_op),
        .result (result),
        .zero   (zero)
        );
        
    initial begin
        A = 32'h0000_F0F0;
        B = 32'h0000_FF00;
        alu_op = 3'b000; // and
        #20;
        B = 32'h0FF0_0000; // test zero flag
        #20;
        alu_op = 3'b001; // or
        #20;
        alu_op = 3'b010; // add
        #20;
        alu_op = 3'b110; // subtract
        #20;
        alu_op = 3'b111; // set if less than
    end

endmodule
