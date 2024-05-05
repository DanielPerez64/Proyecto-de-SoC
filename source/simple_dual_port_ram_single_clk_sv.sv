/******************************************************************
* Description
*
* Simple dual port ram with single clock 
*
* Parameters: DATAWIDTH  -> Width of data stored/read 
*             ADDR_WIDTH -> Width of the bus address  
*
* Author:
* email :	vidkar.delgado@cinvestav.mx
* Date  :	05/07/2020
******************************************************************/


module simple_dual_port_ram_single_clk_sv #(
		parameter DATA_WIDTH= 8,
		parameter ADDR_WIDTH= 4,
		parameter TXT_FILE= "memX.txt"
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

initial begin  //load hexadecimal data in txt
		$readmemh(TXT_FILE, RAM_structure);		
end

//write and read operations
always_ff @ (posedge clk) begin
		if(write_en_i)
				RAM_structure[write_addr_i] <= write_data_i;
		
		read_data_o <= RAM_structure[read_addr_i];		
end

endmodule
