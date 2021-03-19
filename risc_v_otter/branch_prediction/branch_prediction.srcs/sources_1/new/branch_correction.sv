`timescale 1ns / 1ps

module branch_correction(
    input [2:0] pcSource_p,
    input [2:0] pcSource_c,
    input [1:0] pred,
    output reg [1:0] new_pred,
    output reg flush_if,
    output reg flush_id,
    output reg bad_pred
    );
    
    always_comb begin
        // Schedule outputs
        flush_if = 1'b0; flush_id = 1'b0;
        bad_pred = 1'b0;
        // If it was predicted taken
        if (pred >= 2'b10) begin
            if (pcSource_p != pcSource_c) begin // Bad guess! Not taken
                // Take id_pc + 4 as next PC
                bad_pred = 1'b1;
                flush_if = 1'b1;
                new_pred = pred == 0 ? pred : pred - 1; // Decrement prediction
            end
            else begin // Good guess! Taken
                flush_id = 1'b1;
                new_pred = pred == 3 ? pred : pred + 1; // Increment prediction
            end
        end
        else begin // Predicted not taken
            if (pcSource_p != pcSource_c) begin // Bad guess! Taken
                bad_pred = 1'b1;
                flush_if = 1'b1;
                flush_id = 1'b1;
                new_pred = pred == 3 ? pred : pred + 1; // Increment prediction
            end
            else begin // Good guess! Not taken
                new_pred = pred == 0 ? 2'b00 : pred - 1; // Decrement prediction
            end
        end
    end
    
endmodule
