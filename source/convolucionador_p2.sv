/*
   
   Author:  Pablo Daniel Perez Montes
   Email:   TAE2024.7@cinvestav.mx
   Date:    05/05/2024
   
   Module Name:
      convolucion_p2
   
   Description:
      This module computes a discrete time convolution. H vector is internally stored in an synchronous ROM memory
      Once the start signal get shot to high, convolucion_p2 will take values stored in a extern RAM or device,   
      then will elaborate the calculus of each value of Z. It always writes on extern memory block for the Z output.
      The data will be ready only when the output done is one shotted.
      
      User should be careful of overflow. Sizes is fixed by DATA_WIDTH_OUT.
      
   Parameters:
      ADDRESS_WIDTH:       size for the address of vectors Y and H
      ADDRESS_WIDTH_OUT:   size for the adrress of Z vectors
      DATA_WIDTH:          size in bits of data in vectors Y and H
      DATA_WIDTH_OUT:      size in bits for the data Z output
      TXT_FILE_H:          directory path for the text file of vector H values
      SIZE_H:              size of the vector H, it must match the number of elements in TXT_FILE_H
   
   Ports:
      Inputs:
         clk:              clock signal
         rst:              negative edge reset
         start_i:          start signal
         data_y_i:         data from extern device
         size_y_i:         size of vector Y (number of values the device will take from extern device)
         
      Outputs: 
         data_z_o:         data that will be stored on a extern device  (results for the convolution)
         mem_z_addr_o:     address for the data output
         mem_y_addr_o:     address for the data input in vector Y
         busy_o:           signal for busy device
         done_o:           tells the user that the calculus is complete (one shot)
         write:            tells the extern device that will store the vector Z that this device is writting to output
   
   Instances:
      -register
      -realAdder
      -realSubstractor
      -comparatorEqual
      -comparatorLessThan
      -rom_sync
      -convolucion_p2_fsm
      -multiplicator
   
   Instance Template:
   
      convolucion_p2 
         #(
            .DATA_WIDTH(),
            .DATA_WIDTH_OUT(),
            .ADDRESS_WIDTH(),
            .ADDRESS_WIDTH_OUT(),
            .TXT_FILE_H(),
            .SIZE_H()
         )
         "MODULE NAME"
         (
            .clk(),
            .rst(),
            .start_i(),
            .data_y_i(),
            .size_y_i(),
            .data_z_o(),
            .mem_z_addr_o(),
            .mem_y_addr_o(),
            .busy_o(),
            .done_o(),
            .write_o()
         );

      
      
   Place here any modifications with the format: "(DD/MM/YY): description"
      
      (05/05/2024):  convolucion_p2 created. Added description.
   
   
*/

module convolucion_p2
#(
   //parameters
	DATA_WIDTH = 8,
   DATA_WIDTH_OUT = 16,
   ADDRESS_WIDTH = 5,
   ADDRESS_WIDTH_OUT = 6,
   TXT_FILE_H = "C:/disen_SoC/convolution_p2/array_x.txt",
   SIZE_H   = 32
)(
   //ports
   input                            clk,
   input                            rst,
   /* ------------ start signal ------------------ */
   input                            start_i,
   /* ------------- memory y signals ------------- */
   input  [DATA_WIDTH - 1: 0]       data_y_i,
   input  [ADDRESS_WIDTH - 1: 0]    size_y_i,
   /* ------------- memory z signals ------------- */
   output [DATA_WIDTH_OUT - 1: 0]       data_z_o,
   output [ADDRESS_WIDTH_OUT - 1: 0]    mem_z_addr_o,
   /* ------------- memory y addres signal ------- */   
   output [ADDRESS_WIDTH - 1: 0]    mem_y_addr_o,
   /* ------------- output control signals ------- */
   output                           busy_o,
   output                           done_o,
   output                           write_o
);

// signal declaration   *****************************

/* ******** 5 bits length nets  ***************** */

//length of vectors Y, H
logic [ADDRESS_WIDTH-1:0]     size_temp;  // Y
logic [ADDRESS_WIDTH-1:0]     sizeH;      // H


//counter signals 32b
logic [ADDRESS_WIDTH-1:0]     next_j;
logic [ADDRESS_WIDTH-1:0]     _j;
logic [ADDRESS_WIDTH-1:0]     next_k;
logic [ADDRESS_WIDTH-1:0]     _k;

//addresses
logic [ADDRESS_WIDTH-1:0]     addrH;

/* ******** 8 bits length nets  ***************** */

//data nets
logic [DATA_WIDTH-1:0]        temp_y;
logic [DATA_WIDTH-1:0]        to_temp_h;
logic [DATA_WIDTH-1:0]        temp_h;


/* ******** 6 bits length nets  ***************** */

logic [ADDRESS_WIDTH_OUT-1:0] size_temp_plus_sizeH;
logic [ADDRESS_WIDTH_OUT-1:0] sizeZ;
logic [ADDRESS_WIDTH_OUT-1:0] temp_sizeZ;

logic [ADDRESS_WIDTH_OUT-1:0] sizeH_fixed;
logic [ADDRESS_WIDTH_OUT-1:0] size_temp_fixed;
logic [ADDRESS_WIDTH_OUT-1:0] k_plus_j;

//counter signals 6b
logic [ADDRESS_WIDTH_OUT-1:0] k_fixed;
logic [ADDRESS_WIDTH_OUT-1:0] j_fixed;

logic [ADDRESS_WIDTH_OUT-1:0] next_i;
logic [ADDRESS_WIDTH_OUT-1:0] _i;

/* ******** 16 bits length nets  ***************** */
logic [DATA_WIDTH_OUT-1:0]    product; 
logic [DATA_WIDTH_OUT-1:0]    temp_z;
logic [DATA_WIDTH_OUT-1:0]    temp_result;

//fsm inputs
logic i_less_sizeZ;
logic j_less_sizeH;
logic k_less_size_temp;
logic k_plus_j_equals_i;

//fsm outputs
logic load_sizeY;
logic load_sizeZ;
logic count_up_i;
logic clear_i;
logic count_up_j;
logic clear_j;
logic count_up_k;
logic clear_k;
logic load_temp_z;
logic temp_z_clear;
logic temp_h_load;
logic temp_y_load;

//fsm instatiaton

convolucion_p2_fsm   CONVOLUTION_STATE_MACHINE
(
   .clk(clk),
   .rstn(rst),
   .fsm_start_i(start_i),
   .fsm_i_less_sizeZ(i_less_sizeZ),
   .fsm_j_less_sizeH(j_less_sizeH),
   .fsm_k_less_size_temp(k_less_size_temp),
   .fsm_k_plus_j_equals_i(k_plus_j_equals_i),
   
   //OUTPUTS
   .fsm_load_sizeY(load_sizeY),
   .fsm_load_sizeZ(load_sizeZ),
   .fsm_count_up_i(count_up_i),
   .fsm_clear_i(clear_i),
   .fsm_count_up_j(count_up_j),
   .fsm_clear_j(clear_j),
   .fsm_count_up_k(count_up_k),
   .fsm_clear_k(clear_k),
   .fsm_load_temp_z(load_temp_z),
   .fsm_temp_z_clear(temp_z_clear),
   .fsm_temp_h_load(temp_h_load),
   .fsm_temp_y_load(temp_y_load),
   .fsm_busy(busy_o),
   .fsm_done(done_o),
   .fsm_write(write_o)
  
);

/* ================== DATA PATH ======================= */

//bring sizeY from input
register 
   #(
      .DATA_WIDTH (ADDRESS_WIDTH)
   )
   size_temp_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (1'b0),   
      .enh     (load_sizeY),
      .data_i  (size_y_i),
      .data_o  (size_temp)
   );
//size H flipflop
always@(posedge clk) begin
   sizeH <= SIZE_H;
end

assign sizeH_fixed = {1'b0,sizeH};
assign size_temp_fixed = {1'b0,size_temp};
   
realAdder
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH_OUT)
   )
   adder_sizeH_size_temp
   (
       .re_A      (sizeH_fixed),
       .re_B      (size_temp_fixed),
       .re_out    (size_temp_plus_sizeH)
   );

realSubstractor
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH_OUT)
   )
   subs_sizeZ
   (
       .re_A      (size_temp_plus_sizeH),
       .re_B      (6'h1),
       .re_out    (temp_sizeZ)
   );

//save sizeZ
register 
   #(
      .DATA_WIDTH (ADDRESS_WIDTH_OUT)
   )
   size_Z_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (1'b0),   
      .enh     (load_sizeZ),
      .data_i  (temp_sizeZ),
      .data_o  (sizeZ)
   );
   
/* ================== data path for comparators ======================= */

comparatorLessThan 
   #(
      .DATA_WIDTH   (ADDRESS_WIDTH_OUT)
   )
   cmp_i_less_than_sizeZ
   (
      .A_i            (next_i),
      .B_i            (sizeZ), 
      .A_less_than_B_o(i_less_sizeZ)
   );

// j less than sizeH
comparatorLessThan 
   #(
      .DATA_WIDTH   (ADDRESS_WIDTH)  //32 bits
   )
   cmp_j_less_than_sizeH
   (
      .A_i            (next_j),
      .B_i            (sizeH), 
      .A_less_than_B_o(j_less_sizeH)
   );
   
// k less than size_temp
comparatorLessThan 
   #(
      .DATA_WIDTH   (ADDRESS_WIDTH)   //32 bits
   )
   cmp_k_less_than_size_temp
   (
      .A_i            (next_k),
      .B_i            (size_temp), 
      .A_less_than_B_o(k_less_size_temp)
   );

// (k+j) equal to i
assign k_fixed = {1'b0,_k};
assign j_fixed = {1'b0,_j};

realAdder
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH_OUT)
   )
   adder_k_plus_j
   (
       .re_A      (k_fixed),
       .re_B      (j_fixed),
       .re_out    (k_plus_j)
   );

comparatorEqual 
   #(
      .DATA_WIDTH   (ADDRESS_WIDTH_OUT)
   )
   cmp_k_plus_j_equals_i
   (
      .A_i            (k_plus_j),
      .B_i            (_i), 
      .A_equal_B_o    (k_plus_j_equals_i)
   );
/* ================== data path for counters ======================= */

//counter for _i
realAdder
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH_OUT)
   )
   adder_counter_i
   (
       .re_A      (6'h1),
       .re_B      (_i),
       .re_out    (next_i)
   );

register 
   #(
      .DATA_WIDTH (ADDRESS_WIDTH_OUT)
   )
   counter_i_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (clear_i),   
      .enh     (count_up_i),
      .data_i  (next_i),
      .data_o  (_i)
   );


//counter for _j
realAdder
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH)
   )
   adder_counter_j
   (
       .re_A      (5'h1),
       .re_B      (_j),
       .re_out    (next_j)
   );

register 
   #(
      .DATA_WIDTH (ADDRESS_WIDTH)
   )
   counter_j_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (clear_j),   
      .enh     (count_up_j),
      .data_i  (next_j),
      .data_o  (_j)
   );
   
//counter for _k
realAdder
   #(
      .DATA_WIDTH    (ADDRESS_WIDTH)
   )
   adder_counter_k
   (
       .re_A      (5'h1),
       .re_B      (_k),
       .re_out    (next_k)
   );

register 
   #(
      .DATA_WIDTH (ADDRESS_WIDTH)
   )
   counter_k_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (clear_k),   
      .enh     (count_up_k),
      .data_i  (next_k),
      .data_o  (_k)
   );

/* ================== data path for the convolution algorithm ======================= */

register 
   #(
      .DATA_WIDTH (DATA_WIDTH)
   )
   temp_y_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (1'b0),   
      .enh     (temp_y_load),
      .data_i  (data_y_i),
      .data_o  (temp_y)
   );

assign addrH = _j;

rom_sync
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .TXT_FILE(TXT_FILE_H)
   )
   rom_interna
   (
      .address(addrH),
      .clk(clk),
      .data_o(to_temp_h)
   );
   
register 
   #(
      .DATA_WIDTH (DATA_WIDTH)
   )
   temp_h_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (1'b0),   
      .enh     (temp_h_load),
      .data_i  (to_temp_h),
      .data_o  (temp_h)
   );

// multiplication instance
multiplicator
   #(
      .DATA_WIDTH(DATA_WIDTH),
      .DATA_WIDTH_OUT(2*DATA_WIDTH)
   )
   convolution_multiplicator
   (
      .A_i(temp_h),
      .B_i(temp_y),
      .product_AB(product)
   );  

realAdder
   #(
      .DATA_WIDTH    (DATA_WIDTH_OUT)
   )
   adder_convolution
   (
       .re_A      (product),
       .re_B      (temp_z),
       .re_out    (temp_result)
   );
   
register 
   #(
      .DATA_WIDTH (DATA_WIDTH_OUT)
   )
   temp_z_register
   (
      .clk     (clk),
      .rstn    (rst),
      .clrh    (temp_z_clear),   
      .enh     (load_temp_z),
      .data_i  (temp_result),
      .data_o  (temp_z)
   );

/* ================== OUTPUTS ======================= */
assign mem_y_addr_o  = _k;
assign mem_z_addr_o  = _i;
assign data_z_o      = temp_z;

endmodule