`timescale 1ns / 1ps

module signext(
    input logic [31:0] a,
    output logic [31:0] y
    );
    
    //assign y = {{16{a[15]}}, a};
    
    always_comb
    begin
        case (a[6:0])
            7'b0010011: y <= {{21{a[31]}}, a[30:25], a[24:20]}; // I type
            7'b1100011: y <= {{20{a[31]}}, a[7], a[30:25], a[11:8], 1'b0}; // B type
            7'b0100011: y <= {{21{a[31]}}, a[30:25], a[11:7]}; // S type
            7'b1101111: y <= {{12{a[31]}}, a[19:12], a[20], a[30:21], 1'b0}; // J type
            default: y <= 32'h00000000;
        endcase
    end
    
endmodule
