`timescale 1ns / 1ps

/*
  PC and memory combined, with
  next instruction output.
*/
module pc_mem_top_level(
    input clk,
    input rst,
    input PCWrite,
    input [1:0] pcSource,
    output [31:0] ir
    );
    
    // Output of PC counter, input to memory address
    wire [31:0] pc;
    
    pc_mod program_count (
        .clk      (clk),
        .rst      (rst),
        .PCWrite  (PCWrite),
        .pcSource (pcSource),
        .pc       (pc)
        );
        
    Memory OTTER_MEMORY (
        .MEM_CLK   (clk),
        .MEM_RDEN1 (1),
        .MEM_RDEN2 (0),
        .MEM_WE2   (0),
        .MEM_ADDR1 (pc[15:2]),
        .MEM_ADDR2 (0),
        .MEM_DIN2  (0),
        .MEM_SIZE  (2),
        .MEM_SIGN  (0),
        .IO_IN     (0),
        .IO_WR     (),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 () 
        ); 
            
endmodule
