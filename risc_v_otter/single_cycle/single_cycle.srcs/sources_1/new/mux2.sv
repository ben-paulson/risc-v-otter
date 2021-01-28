`timescale 1ns / 1ps

module mux2(
    input [n-1:0] D0, D1,
    input src,
    output [n-1:0] DOUT
    );
    
    parameter n = 32;
    
    assign DOUT = src ? D1 : D0;
    
endmodule
