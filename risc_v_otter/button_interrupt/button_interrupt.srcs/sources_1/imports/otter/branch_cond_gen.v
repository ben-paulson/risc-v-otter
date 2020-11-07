`timescale 1ns / 1ps

module branch_cond_gen(
    input [31:0] rs1,
    input [31:0] rs2,
    output br_eq,
    output br_lt,
    output br_ltu
    );
    
    assign br_eq = rs1 == rs2;
    assign br_lt = $signed(rs1) < $signed(rs2);
    assign br_ltu = rs1 < rs2;
    
endmodule
