/*
   rom_sync
   #(
   
   )
   "MODULE NAME"
   (
      .address(),
      .data_o()
   );
*/
module rom_sync
#(
   parameter DATA_WIDTH = 8,
   parameter ADDRESS_WIDTH = 5,
   parameter TXT_FILE = "C:/disen_SoC/convolution_p2/array_x.txt"
)(
   input    [(ADDRESS_WIDTH)-1:0]      address,
   input                               clk,
   output   logic [(DATA_WIDTH)-1:0]   data_o
);
 
logic [DATA_WIDTH-1:0] rom [(2**ADDRESS_WIDTH)-1:0] ; 
 
initial begin
    $readmemh(TXT_FILE, rom);
end

always@(posedge clk) begin
   data_o <= rom[address];
end
endmodule