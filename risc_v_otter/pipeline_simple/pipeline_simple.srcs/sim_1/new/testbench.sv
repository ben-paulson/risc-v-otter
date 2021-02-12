`timescale 1ns / 1ps

module testbench();

    reg clk, rst;
    reg [31:0] iobus_in;
    wire [31:0] iobus_out, iobus_addr;
    wire iobus_wr;
    
    OTTER_MCU otter (
        .RST (rst),
        .intr (0),
        .clk (clk),
        .iobus_in (iobus_in),
        .iobus_out (iobus_out),
        .iobus_wr (iobus_wr)
        );
     
     initial clk = 0;
     always begin
        clk = #5 ~clk;
     end
     
     initial begin
        iobus_in = 32'h00000000;
        rst = 1'b1;
        #12;
        rst = 1'b0;
     end

endmodule
