/*	
   ===================================================================
   Module Name  : Comparator Less Than
      
   Filename     : comparatorLessThan.v
   Type         : Verilog Module
   
   Description  : This block compares two unsigned binary numbers.
                  A_less_than_B_o output values:
                  
                  Value   Condition
                  
                  1'b1     A_i < B_i                  
                  1'b0     otherwise
                  
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                   Default
         ------------------------------------------------------------------------------
         DATA_WIDTH              Number of data bits                13 
         ------------------------------------------------------------------------------
   Version     : 1.0
   Data        : 14 Nov 2018
   Revision    : -
   Reviser     : -		
   ------------------------------------------------------------------------------
      Modification Log "please register all the modifications in this area"
      (D/M/Y)  
      
   ----------------------
   // Instance template
   ----------------------
   comparatorLessThan 
   #(
      .DATA_WIDTH   (),
   )
   "MODULE_NAME"
   (
      A_i            (),
      B_i            (), 
      A_less_than_B_o()
   );
*/

module comparatorLessThan
#(
   parameter DATA_WIDTH = 13
)(
	input [DATA_WIDTH-1:0]  A_i,
	input [DATA_WIDTH-1:0]  B_i, 
	output                  A_less_than_B_o
);

assign A_less_than_B_o = ( A_i < B_i ) ? 1'b1 :  1'b0;



endmodule
