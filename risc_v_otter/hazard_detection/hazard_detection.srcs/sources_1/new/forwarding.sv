`timescale 1ns / 1ps

module forwarding(
    input [4:0] id_ex_rs1,
    input [4:0] id_ex_rs2,
    input alu_srcA,
    input [1:0] alu_srcB,
    input [31:0] alu_a,
    input [31:0] alu_b,
    input [4:0] ex_m_rd,
    input ex_m_regWrite,
    input [4:0] m_wb_rd,
    input m_wb_regWrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB,
    output reg [1:0] alu_fwd_a,
    output reg [1:0] alu_fwd_b
    );
    
    assign ex_haz = ex_m_regWrite && ex_m_rd != 5'b00000 &&
        (ex_m_rd == id_ex_rs1 || ex_m_rd == id_ex_rs2);
        
    assign mem_haz = m_wb_regWrite && m_wb_rd != 5'b00000 &&
        (m_wb_rd == id_ex_rs1 || m_wb_rd == id_ex_rs2);
    
    always_comb
    begin
        // Schedule outputs to avoid latch
        forwardA = 2'b00; forwardB = 2'b00;
        alu_fwd_a = 2'b00; alu_fwd_b = 2'b00;
        // Ex hazard - forward data from 1 instruction above
        if (ex_haz) begin
            if (ex_m_rd == id_ex_rs1) begin
                forwardA = 2'b01;
                // If alu_srcA is 0, we know it is using rs1 - must forward
                if (alu_srcA == 1'b0) alu_fwd_a = 2'b01;
            end
            if (ex_m_rd == id_ex_rs2) begin
                forwardB = 2'b01;
                // If alu_srcB is 0, we know it is using rs2 - must forward
                if (alu_srcB == 2'b00) alu_fwd_b = 2'b01;
            end
        end
        else if (mem_haz) begin
            // Mem hazard - forward data from 2 instructions up
            if (m_wb_rd == id_ex_rs1 && !(ex_m_rd == id_ex_rs1)) begin
                forwardA = 2'b10;
                // If alu_srcA is 0, we know it is using rs1 - must forward
                if (alu_srcA == 1'b0) alu_fwd_a = 2'b10;
            end
            if (m_wb_rd == id_ex_rs2 && !(ex_m_rd == id_ex_rs2)) begin
                forwardB = 2'b10;
                // If alu_srcB is 0, we know it is using rs2 - must forward
                if (alu_srcB == 2'b00) alu_fwd_b = 2'b10;
            end
        end
        else begin
            forwardA = 2'b00;
            forwardB = 2'b00;
            alu_fwd_a = 2'b00;
            alu_fwd_b = 2'b00;
        end
    end
    
endmodule
