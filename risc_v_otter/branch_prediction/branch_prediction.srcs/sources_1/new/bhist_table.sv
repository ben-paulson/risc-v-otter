`timescale 1ns / 1ps

module bhist_table(
    input clk,
    input we,
    input [9:0] wa,
    input [1:0] newp,
    input [9:0] instr,
    output reg [1:0] prediction
    );
    
    logic [1:0] bhist [0:1023];
    
    // Initialize all branch history to 0
    integer i;
    initial begin
        for (i = 0; i < 1023; i++) begin
            bhist[i] = 2'b00;
        end
    end
    
    //
    always_ff @ (posedge clk) begin
        if (we) bhist[wa] = newp;
        prediction = bhist[instr];
    end
    
endmodule
