/*
   Module Name    : multiplicator
   Description    :
      -  multiplicator for entire numbers
      -  2 entire numbers for input
      -  1 entire number to output
   
   Filename       : multiplicator.sv
   Type           : SystemVerilog Module
   
   Author         : Daniel Perez
   Date           : 1 April 2024
   
   Instance template :
   
   multiplicator
   #(
      .DATA_WIDTH(),
      .DATA_WIDTH_OUT("2*DATA_WIDTH")
   )
   "MODULE NAME"
   (
      .A_i(),
      .B_i(),
      .product_AB()
   );
   
*/

module multiplicator
#(
   parameter DATA_WIDTH = 8,
   parameter DATA_WIDTH_OUT = (2*DATA_WIDTH)
)(
   input [DATA_WIDTH-1:0] A_i,
   input [DATA_WIDTH-1:0] B_i,
   output [DATA_WIDTH_OUT-1:0] product_AB
);

logic [DATA_WIDTH-1:0] temp_A;
logic [DATA_WIDTH-1:0] temp_B;
logic signed [DATA_WIDTH_OUT-1:0] temp_product;

assign temp_A = A_i;
assign temp_B = B_i;

assign temp_product = temp_A * temp_B;

assign product_AB = temp_product;

endmodule