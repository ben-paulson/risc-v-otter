`timescale 1ns / 1ps

module branch_cond_gen(
    input [6:0] opcode,
    input [2:0] func3,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [2:0] pcSource
    );
    
    wire br_eq = rs1 == rs2;
    wire br_lt = $signed(rs1) < $signed(rs2);
    wire br_ltu = rs1 < rs2;
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3 (branch type)
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_b_t;    
    func3_b_t FUNC3_B; //- define variable of new opcode type
    
    assign FUNC3_B = func3_b_t'(func3); //- Cast input enum 
    
    always_comb
    begin 
        //- schedule all values to avoid latch
        pcSource = 3'b000;
        
        case(OPCODE)
            JAL: pcSource = 3'b011;
            JALR: pcSource = 3'b001;
            BRANCH:
            begin
                case (FUNC3_B)
                    BEQ:
                    begin
                        if (br_eq == 1) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    BNE:
                    begin
                        if (br_eq == 0) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    BLT:
                    begin
                        if (br_lt == 1) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    BGE:
                    begin
                        if (br_lt == 0) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    BLTU:
                    begin
                        if (br_ltu == 1) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    BGEU:
                    begin
                        if (br_ltu == 0) pcSource = 3'b010;
                        else pcSource = 3'b000;
                    end
                    
                    default: pcSource = 3'b000;
                endcase
            end
            
            default: pcSource = 3'b000; 
        endcase        
    end
    
endmodule
