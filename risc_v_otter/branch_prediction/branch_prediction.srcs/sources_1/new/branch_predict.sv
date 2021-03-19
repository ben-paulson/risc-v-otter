`timescale 1ns / 1ps

module branch_predict(
    input [6:0] opcode,
    input [1:0] pred,
    output reg [2:0] pcSource
    );
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 
    
    always_comb begin
        // Default to PC + 4 if not jal, jalr, branch instr.
        pcSource = 3'b000;
        // Only check jump type if predict branch taken
        if (pred > 2'b01) begin
            case (OPCODE)
                JAL: pcSource = 3'b011;
                JALR: pcSource = 3'b001;
                BRANCH: pcSource = 3'b010;
                default: pcSource = 3'b000;
            endcase
        end
    end
    
endmodule
