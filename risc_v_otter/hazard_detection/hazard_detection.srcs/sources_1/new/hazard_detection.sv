`timescale 1ns / 1ps

module hazard_detection(
    input [1:0] pcSource,
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    input [4:0] id_ex_rd,
    input id_ex_memRead,
    output reg stall,
    output reg invalid_branch
    );
    
    always_comb
    begin
        stall = 1'b0;
        invalid_branch = 1'b0;
        if (id_ex_memRead) begin
            if (id_ex_rd == if_id_rs1) stall = 1'b1;
            if (id_ex_rd == if_id_rs2) stall = 1'b1;
        end
        // This assumes branches will not be taken, stall if one is
        if (pcSource != 0) invalid_branch = 1'b1;
    end
    
endmodule
