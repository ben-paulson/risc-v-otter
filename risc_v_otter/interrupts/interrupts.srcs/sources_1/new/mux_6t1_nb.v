`timescale 1ns / 1ps

// Copy of mux_4t1_nb with 2 additional inputs
 module mux_6t1_nb(SEL, D0, D1, D2, D3, D4, D5, D_OUT); 
       input  [1:0] SEL; 
       input  [n-1:0] D0, D1, D2, D3, D4, D5; 
       output reg [n-1:0] D_OUT;  
       
       parameter n = 8; 
        
       always @(*)
       begin 
          case (SEL) 
          0:      D_OUT = D0;
          1:      D_OUT = D1;
          2:      D_OUT = D2;
          3:      D_OUT = D3;
          4:      D_OUT = D4;
          5:      D_OUT = D5;
          default D_OUT = 0;
       endcase 
		  end
                
endmodule
   