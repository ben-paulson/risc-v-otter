`timescale 1ns / 1ps

module maindec(
    input logic clk,
    input logic [6:0] op,
    output logic memtoreg, memwrite,
    output logic branch, alusrc,
    output logic regdst, regwrite,
    output logic jump,
    output logic [1:0] aluop,
    output logic pcwrite
    );
    
    logic [9:0] controls;
    
    assign {pcwrite, regwrite, regdst, alusrc, branch, memwrite,
            memtoreg, jump, aluop} = controls;
    
    logic [2:0] stage = 0;
    
    always @ (posedge clk)  
        if (stage == 4)
            stage <= 0;
        else
            stage <= stage + 1;
        
    always_comb
    begin
        case (op)
            7'b0110011: case (stage) // RTYPE
                0: controls <= 10'b1010000000;
                1: controls <= 10'b0010000000;
                2: controls <= 10'b0010000010;
                3: controls <= 10'b0010000010;
                4: controls <= 10'b0110000010;
                default: controls <= 10'b0000000000;
            endcase
            7'b0000011: case (stage) // LW
                0: controls <= 10'b1000000000;
                1: controls <= 10'b0000000000;
                2: controls <= 10'b0001000000;
                3: controls <= 10'b0001000000;
                4: controls <= 10'b0101001000;
                default: controls <= 10'b0000000000;
            endcase
            7'b0100011: case (stage) // SW
                0: controls <= 10'b1000000000;
                1: controls <= 10'b0000000000;
                2: controls <= 10'b0001000000;
                3: controls <= 10'b0001010000;
                4: controls <= 10'b0001000000;
                default: controls <= 10'b0000000000;
            endcase
            7'b1100011: case (stage) // BEQ
                0: controls <= 10'b1000100000;
                1: controls <= 10'b0000100000;
                2: controls <= 10'b0000100001;
                3: controls <= 10'b0000100001;
                4: controls <= 10'b0000100001;
                default: controls <= 10'b0000000000;
            endcase
            7'b0010011: case (stage) // ADDI
                0: controls <= 10'b1000000000;
                1: controls <= 10'b0000000000;
                2: controls <= 10'b0001000000;
                3: controls <= 10'b0001000000;
                4: controls <= 10'b0101000000;
                default: controls <= 10'b0000000000;
            endcase
            7'b1101111: case (stage) // J
                0: controls <= 10'b1000000100;
                1: controls <= 10'b0000000100;
                2: controls <= 10'b0000000100;
                3: controls <= 10'b0000000100;
                4: controls <= 10'b0000000100;
                default: controls <= 10'b0000000000;
            endcase
            default:   controls <= 10'bxxxxxxxxxx; // illegal op
        endcase
           
    end
    
endmodule
