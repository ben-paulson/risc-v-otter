`timescale 1ns / 1ps

/*
  Generates new PC addresses for jal, jalr, and branch
  instructions given the immediate values for I, J, B-type
  instructions, and the current PC value.
*/
module branch_addr_gen(
    input [31:0] I_type, J_type, B_type, pc, rs1,
    output [31:0] jal, jalr, branch
    );
    
    // Assign addresses
    assign jal = pc + J_type;
    assign jalr = rs1 + I_type;
    assign branch = pc + B_type;
    
endmodule
