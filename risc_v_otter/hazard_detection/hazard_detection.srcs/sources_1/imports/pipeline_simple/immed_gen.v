`timescale 1ns / 1ps

/*
  Generates immediate values given an
  instruction input. Handles 5 instruction types
  (the 5 that encode immediate values)
*/
module immed_gen(
    input [31:7] ir,
    output [31:0] U_type, I_type, S_type, J_type, B_type
    );
    
    // Switch bits around according to appropriate instruction type
    assign U_type = {ir[31:12], 12'b0};
    assign I_type = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign S_type = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign J_type = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
    assign B_type = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    
endmodule
