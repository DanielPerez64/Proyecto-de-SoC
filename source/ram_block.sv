/*
   Pablo Daniel Perez Montes
   
   Simple RAM module, reads data from input, one at once at address
   
   Date: 05/05/2024
*/

module simple_ram_block
#(
   parameter   DATA_WIDTH = 8,
   parameter   ADDR_WIDTH = 5
)(
   input  logic                  clk,		
   input  logic                  write_en_i,
   input  logic [ADDR_WIDTH-1:0] write_addr_i,				
   input  logic [ADDR_WIDTH-1:0] read_addr_i,
   input  logic [DATA_WIDTH-1:0] write_data_i,
   output logic [DATA_WIDTH-1:0] read_data_o
);

// signal declaration
logic [DATA_WIDTH-1:0] RAM_structure [2**ADDR_WIDTH-1:0]; 

//write and read operations
always_ff @ (posedge clk) begin
		if(write_en_i)
				RAM_structure[write_addr_i] <= write_data_i;
		
		read_data_o <= RAM_structure[read_addr_i];		
end

endmodule