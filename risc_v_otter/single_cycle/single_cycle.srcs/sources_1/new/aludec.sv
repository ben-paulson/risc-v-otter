`timescale 1ns / 1ps

module aludec(
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    input logic [1:0] aluop,
    output logic [2:0] alucontrol
    );
    
    always_comb
        case (aluop)
            2'b00: alucontrol <= 3'b010; // add (for lw/sw/addi)
            2'b01: alucontrol <= 3'b110; // sub (for beq)
            default: case (funct3)        // R-type instructions
                3'b000: 
                    case (funct7)
                        7'b0000000: alucontrol <= 3'b010; // add
                        7'b0100000: alucontrol <= 3'b110; // sub
                    endcase
                3'b111: alucontrol <= 3'b000; // and
                3'b110: alucontrol <= 3'b001; // or
                3'b010: alucontrol <= 3'b111; // slt
                default:   alucontrol <= 3'bxxx; // ???
            endcase
        endcase
    
endmodule
