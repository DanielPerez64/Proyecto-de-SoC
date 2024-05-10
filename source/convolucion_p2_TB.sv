/*
   
   Author:  Pablo Daniel Perez Montes
   Email:   TAE2024.7@cinvestav.mx
   Date:    05/05/2024
   
   Module Name:
      convo_p2_TB
   
   Description:
      Testbench for the PROJECT 2 Convolution. Resets the top module then one shot start signal.
      The convolucion_p2 block DUT will take values stored in MEM_Y, then it will write on MEM_Z the
      product of each operation.
      
   Parameters:
      ADDRESS_WIDTH:    size for the address of vectors Y and H
      ADDRESS_WIDTH_Z:  size for the Z vectors
      DATA_WIDTH:       size in bits of data in vectors Y and H
      DATA_WIDTH_OUT:   size in bits of data for the vector Z
      TXT_FILE_H:       directory path for the text file of vector H values
      TXT_FILE_Y:       directory path for the text file of vector Y values
      SIZE_H:           size of the vector H, it must match the number of elements in TXT_FILE_H
      SIZE_Y:           size of the vector Y, it must match the number of elements in TXT_FILE_Y
      
   Instances:                                   Name of Instance:
      -convolucion_p2                           DUT
      -simple_dual_port_ram_single_clk_sv       MEM_Y
      -simple_ram_block                         MEM_Z
      
   Place here any modifications with the format: "(DD/MM/YY): description"
      
      (05/05/2024):  convo_p2_TB created. Added description.
   
   
*/
`timescale 1ns/1ns

module   convo_p2_TB;

localparam  ADDRESS_WIDTH = 5;
localparam  ADDRESS_WIDTH_Z = 6;
localparam  DATA_WIDTH = 8;
localparam  DATA_WIDTH_OUT = 16;
localparam  TXT_FILE_Y = "C:/Users/dany-/OneDrive/Escritorio/CUCEI/Diplomado/gold_model_SoC/txt_pruebas/memY.txt";
localparam  TXT_FILE_H = "C:/Users/dany-/OneDrive/Escritorio/CUCEI/Diplomado/gold_model_SoC/txt_pruebas/memH.txt";
localparam  SIZE_H = 10;
localparam  SIZE_Y = 5;

logic start;
logic clk = 0;
logic rstn;
logic [ADDRESS_WIDTH-1:0]  sizeY = SIZE_Y;

logic [DATA_WIDTH_OUT-1:0] dataZ_o;

logic busy;
logic write;
logic done;

//convolution_p2 signals
logic [DATA_WIDTH-1:0] data_y_i;
logic [ADDRESS_WIDTH_Z-1:0]  addr_z_o;
logic [ADDRESS_WIDTH-1:0]  addr_y_o;

//memZ out
logic [DATA_WIDTH_OUT-1:0] read_data_memZ;


convolucion_p2 
#(
   .DATA_WIDTH(DATA_WIDTH),
   .DATA_WIDTH_OUT(DATA_WIDTH_OUT),
   .ADDRESS_WIDTH(ADDRESS_WIDTH),
   .ADDRESS_WIDTH_OUT(ADDRESS_WIDTH_Z),
   .TXT_FILE_H(TXT_FILE_H),
   .SIZE_H(SIZE_H)
)
DUT
(
   .clk(clk),
   .rst(rstn),
   .start_i(start),
   .data_y_i(data_y_i),
   .size_y_i(sizeY),
   .data_z_o(dataZ_o),
   .mem_z_addr_o(addr_z_o),
   .mem_y_addr_o(addr_y_o),
   .busy_o(busy),
   .done_o(done),
   .write_o(write)
);

simple_dual_port_ram_single_clk_sv 
#(
   .DATA_WIDTH(DATA_WIDTH),
   .ADDR_WIDTH(ADDRESS_WIDTH),
   .TXT_FILE(TXT_FILE_Y)
)
MEM_Y
(
   .clk(clk),
   .write_en_i(1'b0),
   .write_addr_i(1'b0),
   .read_addr_i(addr_y_o),
   .write_data_i(1'b0),
   .read_data_o(data_y_i)
);

simple_ram_block
#(
   .DATA_WIDTH(DATA_WIDTH_OUT),
   .ADDR_WIDTH(ADDRESS_WIDTH_Z)
)
MEM_Z
(
   .clk(clk),
   .write_en_i(write),
   .write_addr_i(addr_z_o),
   .read_addr_i(1'b0),
   .write_data_i(dataZ_o),
   .read_data_o(read_data_memZ)
);


//clock generation
always begin
   #5 clk = ~clk;
end
initial begin

   rstn = 1'b0;
   @(posedge clk);
   rstn = 1'b1;
   start = 1'b1;
   @(posedge clk);
   start = 1'b0;
   
end

endmodule