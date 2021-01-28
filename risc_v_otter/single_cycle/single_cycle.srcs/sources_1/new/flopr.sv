`timescale 1ns / 1ps

module flopr(
    input logic clk, reset,
    input logic [31:0] pcnext,
    input logic pcwrite,
    output logic [31:0] pc
    );
    
    always @ (posedge clk, posedge reset) begin
        if (reset == 1)
            pc = 32'h00000000;
        else
            pc = (pcwrite == 1) ? pcnext : pc;
    end
    
endmodule
