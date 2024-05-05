/*	
   ===================================================================
   Module Name : register
         
   Filename    : register.v
   Type        : Verilog Module
      
   Description : A parametrizable register with async reset
   ------------------------------------------------------------------
      clocks   : posedge clock "clk"
      reset    : async negedge "rstn"
               : sync posedge "clrh"
      enable   : high active enable "enh" 
      
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      Register's data width     8
      
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 13 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please register all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
      register 
      #(
         .DATA_WIDTH ()
      )
      "MODULE_NAME"
      (
         .clk     (),
         .rstn    (),
         .clrh    (),   
         .enh     (),
         .data_i  (),
         .data_o  ()
      );
*/

module register
#(
	parameter DATA_WIDTH =  8
)(
	input wire                    clk,
	input wire                    rstn,
   input wire                    clrh,   
   //--------Control signals----------//
	input wire                    enh,
   //--------Data/addr signals--------//
	input wire [DATA_WIDTH-1:0]   data_i,
	output reg [DATA_WIDTH-1:0]   data_o
);

// ---------------------------------------------

always@(posedge clk, negedge rstn) begin
	if(~rstn) 
		data_o <= {DATA_WIDTH{1'b0}};
	else if (enh)
		data_o <= data_i;
   else if (clrh)
      data_o <= {DATA_WIDTH{1'b0}};
	
end


endmodule