`timescale 1ns / 1ps

module OTTER_MCU(
    input RST,
    input intr,
    input clk,
    input [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output iobus_wr
    );
    
    // PC wires
    wire [31:0] pc_data;
    wire reset;
    wire PCWrite;
    wire [2:0] pcSource;
    
    // pcSource MUX inputs, branch_addr_gen outputs
    wire [31:0] jal, jalr, branch;
    
    // immediate values
    wire [31:0] I_type, J_type, B_type;
    wire [31:0] U_type, S_type;
    
    // wires for branch_cond_gen
    wire br_eq;
    wire br_lt;
    wire br_ltu;
    
    // wires for memory module
    wire memRDEN1, memRDEN2;
    wire memWE2;
    wire [31:0] memDOUT2;
    wire [31:0] ir;
    
    // wires for register file
    wire regWrite;
    wire [1:0] rf_wr_sel;
    wire [31:0] rs1, rs2;
    wire [31:0] rf_wd;
    
    // wires for ALU
    wire [31:0] srcA, srcB; // mux outputs
    wire alu_srcA; // a select
    wire [1:0] alu_srcB; // b select
    wire [3:0] alu_fun;
    wire [31:0] alu_result;
    
    // Wires for CSR
    wire [31:0] mtvec;
    wire [31:0] mepc;
    wire [31:0] csr_rd;
    wire int_taken;
    wire csr_WE;
    wire mie;
    
    pc_mod pc (
        .clk      (clk),
        .rst      (reset),
        .PCWrite  (PCWrite),
        .pcSource (pcSource),
        .jal      (jal),
        .jalr     (jalr),
        .branch   (branch),
        .mtvec    (mtvec),
        .mepc     (mepc),
        .pc       (pc_data)
        );
        
    Memory OTTER_MEMORY (
        .MEM_CLK   (clk),
        .MEM_RDEN1 (memRDEN1),
        .MEM_RDEN2 (memRDEN2),
        .MEM_WE2   (memWE2),
        .MEM_ADDR1 (pc_data[15:2]),
        .MEM_ADDR2 (alu_result),
        .MEM_DIN2  (rs2),
        .MEM_SIZE  (ir[13:12]),
        .MEM_SIGN  (ir[14]),
        .IO_IN     (iobus_in),
        .IO_WR     (iobus_wr),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 (memDOUT2)
        );
        
     mux_4t1_nb  #(.n(32)) rf_wd_mux (
        .SEL   (rf_wr_sel),
        .D0    (pc_data + 4),
        .D1    (csr_rd),
        .D2    (memDOUT2), 
        .D3    (alu_result),
        .D_OUT (rf_wd)
        );  
        
    RegFile regfile (
        .wd   (rf_wd),
        .clk  (clk), 
        .en   (regWrite),
        .adr1 (ir[19:15]),
        .adr2 (ir[24:20]),
        .wa   (ir[11:7]),
        .rs1  (rs1), 
        .rs2  (rs2)
        );
        
    immed_gen ig (
        .ir     (ir[31:7]),
        .U_type (U_type),
        .I_type (I_type),
        .S_type (S_type),
        .J_type (J_type),
        .B_type (B_type)
        );
        
    branch_addr_gen bag (
        .J_type (J_type),
        .B_type (B_type),
        .I_type (I_type),
        .pc     (pc_data),
        .rs1    (rs1),
        .jal    (jal),
        .jalr   (jalr),
        .branch (branch)
        );
        
    mux_2t1_nb  #(.n(32)) alu_a_mux (
        .SEL   (alu_srcA), 
        .D0    (rs1), 
        .D1    (U_type), 
        .D_OUT (srcA)
        );  
        
    mux_4t1_nb  #(.n(32)) alu_b_mux (
        .SEL   (alu_srcB),
        .D0    (rs2),
        .D1    (I_type),
        .D2    (S_type), 
        .D3    (pc_data),
        .D_OUT (srcB)
        );
            
    alu ALU (
        .srcA    (srcA),
        .srcB    (srcB),
        .alu_fun (alu_fun),
        .result  (alu_result)
        );
        
    branch_cond_gen bcg (
        .rs1    (rs1),
        .rs2    (rs2),
        .br_eq  (br_eq),
        .br_lt  (br_lt),
        .br_ltu (br_ltu)
        );
        
    CU_FSM cu_fsm (
        .intr      (intr & mie),
        .clk       (clk),
        .RST       (RST),
        .opcode    (ir[6:0]),
        .func3     (ir[14:12]),
        .pcWrite   (PCWrite),
        .regWrite  (regWrite),
        .memWE2    (memWE2),
        .memRDEN1  (memRDEN1),
        .memRDEN2  (memRDEN2),
        .reset     (reset),
        .csr_WE    (csr_WE),
        .int_taken (int_taken)
        );
        
    CU_DCDR cu_dcdr (
        .br_eq     (br_eq),
        .br_lt     (br_lt),
        .br_ltu    (br_ltu),
        .opcode    (ir[6:0]),
        .func7     (ir[30]),
        .func3     (ir[14:12]),
        .alu_fun   (alu_fun),
        .pcSource  (pcSource),
        .alu_srcA  (alu_srcA),
        .alu_srcB  (alu_srcB), 
        .rf_wr_sel (rf_wr_sel)
        );
        
    CSR my_csr (
        .CLK       (clk),
        .RST       (reset),
        .INT_TAKEN (int_taken),
        .ADDR      (ir[31:20]),
        .PC        (pc_data),
        .WD        (rs1),
        .WR_EN     (csr_WE), 
        .RD        (csr_rd),
        .CSR_MEPC  (mepc),  
        .CSR_MTVEC (mtvec), 
        .CSR_MIE   (mie)    
        ); 
        
    assign iobus_out = rs2;
    assign iobus_addr = alu_result;
                
endmodule
