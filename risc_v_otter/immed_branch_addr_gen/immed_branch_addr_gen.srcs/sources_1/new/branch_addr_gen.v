`timescale 1ns / 1ps

module branch_addr_gen(
    input [31:0] I_type, J_type, B_type, pc,
    output [31:0] jal, jalr, branch
    );
    
    parameter rs = 32'h0000_000C; // Source reg for jalr, hardcoded for now
    
    assign jal = pc + J_type;
    assign jalr = rs + I_type;
    assign branch = pc + B_type;
    
endmodule
