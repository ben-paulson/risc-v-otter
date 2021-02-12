`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// CU_DCDR my_cu_dcdr(
//   .br_eq     (), 
//   .br_lt     (), 
//   .br_ltu    (),
//   .opcode    (),    //-  ir[6:0]
//   .func7     (),    //-  ir[30]
//   .func3     (),    //-  ir[14:12] 
//   .alu_fun   (),
//   .pcSource  (),
//   .alu_srcA  (),
//   .alu_srcB  (), 
//   .rf_wr_sel ()   );
//
// 
// Revision:
// Revision 1.00 - File Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed unneeded else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_DCDR(
    input [6:0] opcode,   //-  ir[6:0]
    input func7,          //-  ir[30]
    input [2:0] func3,    //-  ir[14:12] 
    input int_taken,
    output logic [3:0] alu_fun,
    output logic alu_srcA,
    output logic [1:0] alu_srcB, 
    output logic [1:0] rf_wr_sel,
    output logic pcWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset
    );
    
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
    
    //- datatype for func3 (arithmetic type - for both rg3 and imm)
    typedef enum logic [2:0] {
        SLL = 3'b001,
        SLT = 3'b010,
        SLTU = 3'b011,
        _XOR = 3'b100,
        _OR = 3'b110,
        _AND = 3'b111
    } func3_ri_t;    
    func3_ri_t FUNC3_RI; //- define variable of new opcode type
    
    assign FUNC3_RI = func3_ri_t'(func3); //- Cast input enum 
    
    // datatype for func7 (immediate type instructions)
    typedef enum logic {
        SRLI = 1'b0,
        SRAI = 1'b1
    } func7_imm_t;
    func7_imm_t FUNC7_I; //- define variable of new opcode type
    
    assign FUNC7_I = func7_imm_t'(func7); // Cast input enum
    
    // datatype for func7 (immediate type instructions)
    typedef enum logic {
        ADD = 1'b0,
        SUB = 1'b1
    } func7_rg3_t;
    func7_rg3_t FUNC7_R; //- define variable of new opcode type
    
    assign FUNC7_R = func7_rg3_t'(func7); // Cast input enum
       
    always_comb
    begin 
        //- schedule all values to avoid latch
        alu_srcB = 2'b00;    rf_wr_sel = 2'b00; 
        alu_srcA = 1'b0;   alu_fun  = 4'b0000;
        // old CU_FSM outputs (always pcWrite and memRead1 - assume no hazard)
        pcWrite = 1'b1;    regWrite = 1'b0;    reset = 1'b0;  
        memWE2 = 1'b0;     memRDEN1 = 1'b1;    memRDEN2 = 1'b0;
        
        case(OPCODE)
            AUIPC:
            begin
                alu_fun = 4'b0000;
                alu_srcA = 1'b1;
                alu_srcB = 2'b11;
                rf_wr_sel = 2'b11;
                regWrite = 1'b1;
            end
            LUI:
            begin
                alu_fun = 4'b1001; 
                alu_srcA = 1'b1; 
                rf_wr_sel = 2'b11; 
                regWrite = 1'b1;
            end
            
            SYS:
            begin
                case (func3)
                    3'b001: rf_wr_sel = 2'b01; // csrrw
                endcase
            end
            
            JAL:
            begin
                rf_wr_sel = 2'b00;
                regWrite = 1'b1;
            end
            
            JALR:
            begin
                rf_wr_sel = 2'b00;
                regWrite = 1'b1;
            end
            
            LOAD: 
            begin
                alu_fun = 4'b0000;
                alu_srcA = 1'b0; 
                alu_srcB = 2'b01; 
                rf_wr_sel = 2'b10; 
                regWrite = 1'b1;
                memRDEN2 = 1'b1;
            end
            
            STORE:
            begin
                alu_fun = 4'b0000; 
                alu_srcA = 1'b0; 
                alu_srcB = 2'b10;
                memWE2 = 1'b1;
            end
            
            OP_IMM:
            begin // all immediate type instructions
                alu_srcA = 1'b0;
                alu_srcB = 2'b01;
                rf_wr_sel = 2'b11;
                regWrite = 1'b1;
                case(FUNC3_RI)
                    3'b000: alu_fun = 4'b0000; // add
                    SLL:    alu_fun = 4'b0001; // slli
                    SLT:    alu_fun = 4'b0010; // slti
                    SLTU:   alu_fun = 4'b0011; // sltiu
                    _XOR:   alu_fun = 4'b0100; // xori
                    3'b101:
                    begin // same FUNC3, differ by FUNC7 only
                        case (FUNC7_I)
                            SRLI: alu_fun = 4'b0101; // srli
                            SRAI: alu_fun = 4'b1101; // srai
                            default: alu_fun = 4'b0000;
                        endcase
                    end
                    _OR:    alu_fun = 4'b0110; // ori
                    _AND:   alu_fun = 4'b0111; // andi                    
                    default: 
                    begin
                        alu_fun = 4'b0000;
                        alu_srcA = 1'b0; 
                        alu_srcB = 2'b00; 
                        rf_wr_sel = 2'b00; 
                    end
                endcase
            end
            
            OP_RG3:
            begin
                alu_srcA = 1'b0;
                alu_srcB = 2'b00;
                rf_wr_sel = 2'b11;
                regWrite = 1'b1;
                case(FUNC3_RI)
                    3'b000: 
                    begin // same FUNC3, differ by FUNC7 only
                        case (FUNC7_R)
                            ADD: alu_fun = 4'b0000; // add
                            SUB: alu_fun = 4'b1000; // sub
                            default: alu_fun = 4'b0000;
                        endcase
                    end
                    SLL:    alu_fun = 4'b0001; // sll
                    SLT:    alu_fun = 4'b0010; // slt
                    SLTU:   alu_fun = 4'b0011; // sltu
                    _XOR:   alu_fun = 4'b0100; // xor
                    3'b101:
                    begin // same FUNC3, differ by FUNC7 only
                        case (FUNC7_I)
                            SRLI: alu_fun = 4'b0101; // srl
                            SRAI: alu_fun = 4'b1101; // sra
                            default: alu_fun = 4'b0000;
                        endcase
                    end
                    _OR:    alu_fun = 4'b0110; // or
                    _AND:   alu_fun = 4'b0111; // and                    
                    default: 
                    begin
                        alu_fun = 4'b0000;
                        alu_srcA = 1'b0; 
                        alu_srcB = 2'b00; 
                        rf_wr_sel = 2'b00; 
                    end
                endcase
            end

            default:
            begin
                 alu_srcB = 2'b00; 
                 rf_wr_sel = 2'b00; 
                 alu_srcA = 1'b0; 
                 alu_fun = 4'b0000;
            end
        endcase        
    end

endmodule