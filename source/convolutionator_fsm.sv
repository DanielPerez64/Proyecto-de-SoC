/******************************************************************
* Description
*
* SystemVerilog FSM template with registered outputs
*
* Reset: Async active low
*
* Author:   Daniel Perez Montes
* email :	
* Date  :   04/may/2024	
******************************************************************/

module convolucion_p2_fsm 
(
   input  logic         clk,
   input  logic         rstn,
   input  logic         fsm_start_i,
   
   input  logic         fsm_i_less_sizeZ,
   input  logic         fsm_j_less_sizeH,
   input  logic         fsm_k_less_size_temp,
   input  logic         fsm_k_plus_j_equals_i,
   
   output logic         fsm_load_sizeY,
   output logic         fsm_load_sizeZ,
   output logic         fsm_count_up_i,
   output logic         fsm_clear_i,
   output logic         fsm_count_up_j,
   output logic         fsm_clear_j,
   output logic         fsm_count_up_k,
   output logic         fsm_clear_k,
   output logic         fsm_load_temp_z,
   output logic         fsm_temp_z_clear,
   output logic         fsm_temp_h_load,
   output logic         fsm_temp_y_load,
   output logic         fsm_busy,
   output logic         fsm_done,
   output logic         fsm_write
);


   enum {IDLE = 0,
         S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,         
         S14,S15,S16,S17,S18,S19,S20,S21,S22,S23
        } states;
   
   localparam [4:0] XX = 5'bxxxxx;
 
 logic [4:0] state;
 logic [4:0] next;

 //(1) State register
 always@(posedge clk or negedge rstn)
     if(!rstn) state <= IDLE;                                            
     else      state <= next;

 //(2) Combinational next state logic
 always@* begin
     next = XX;
     case(state)
         IDLE: if(fsm_start_i)                next    = S2;
               else                       next    = IDLE;//@ loopback
                          
         S2:                              next    = S3;
         S3:                              next    = S4;
         S4:                              next    = S5;
         S5:                              next    = S6;
         S6:                              next    = S7;     
         S7:                              next    = S8;
         S8:                              next    = S9;    
         S9:                              next    = S10;
         S10:                             next    = S11;
         S11:                             next    = S12;     
         S12:                             next    = S13;
         S13:                             next    = S14;
         S14:  if(fsm_k_plus_j_equals_i)  next    = S15;
               else                       next    = S19;
                              
         S15:                             next    = S16;
         S16:                             next    = S17;
         S17:                             next    = S18;
         S18:                             next    = S19;
         S19:  if(fsm_k_less_size_temp)   next    = S12;
               else                       next    = S20;
               
         S20:  if(fsm_j_less_sizeH)       next    = S9;
               else                       next    = S21;

         S21:  if(fsm_i_less_sizeZ)       next    = S7;
               else                       next    = S22;
         
         S22:                             next    = S23;
         S23:                             next    = IDLE;
         default:                         next    = XX;
     endcase
 end

 //(3) Registered output logic (Moore outputs)
 always@(posedge clk or negedge rstn) begin
     if(!rstn) begin
         //reset values
        fsm_load_sizeY     <= 'd0;
        fsm_load_sizeY     <= 'd0;
        fsm_count_up_i     <= 'd0;
        fsm_clear_i        <= 'd1;
        fsm_count_up_j     <= 'd0;
        fsm_clear_j        <= 'd1;
        fsm_count_up_k     <= 'd0;
        fsm_clear_k        <= 'd1;
        fsm_load_temp_z    <= 'd0;
        fsm_temp_z_clear   <= 'd1;
        fsm_temp_h_load    <= 'd0;
        fsm_temp_y_load    <= 'd0;
        fsm_busy           <= 'd0;
        fsm_done           <= 'd0;
        fsm_write          <= 'd0;   
         
     end
     else begin
        //First default values!
        fsm_load_sizeY     <= 'd0;
        fsm_load_sizeY     <= 'd0;
        fsm_count_up_i     <= 'd0;
        fsm_clear_i        <= 'd0;
        fsm_count_up_j     <= 'd0;
        fsm_clear_j        <= 'd0;
        fsm_count_up_k     <= 'd0;
        fsm_clear_k        <= 'd0;
        fsm_load_temp_z    <= 'd0;
        fsm_temp_z_clear   <= 'd0;
        fsm_temp_h_load    <= 'd0;
        fsm_temp_y_load    <= 'd0;
        fsm_busy           <= 'd0;
        fsm_done           <= 'd0;
        fsm_write          <= 'd0;
               
             case(next)
                 IDLE: ;
                 S2:    fsm_busy          <= 'b1;
                 S3:    begin
                        fsm_load_sizeY    <= 'b1; 
                        fsm_busy          <= 'b1;
                        end
                 S4:    fsm_busy          <= 'b1;   
                 S5:    begin
                        fsm_load_sizeZ    <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S6:    begin
                        fsm_clear_i       <= 'b1;                 
                        fsm_busy          <= 'b1;
                        end
                 S7:    begin
                        fsm_temp_z_clear  <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S8:    begin
                        fsm_clear_j       <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S9:    fsm_busy          <= 'b1;
                 S10:   begin
                        fsm_temp_h_load   <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S11:   begin
                        fsm_clear_k       <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S12:   fsm_busy          <= 'b1;
                 S13:   begin
                        fsm_temp_y_load   <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S14:   fsm_busy          <= 'b1;
                 S15:   begin
                        fsm_load_temp_z   <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S16:   begin
                        fsm_write         <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S17:   fsm_busy          <= 'b1;
                 S18:   begin
                        fsm_write         <= 'b0;
                        fsm_busy          <= 'b1;
                        end
                 S19:   begin
                        fsm_count_up_k    <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S20:   begin
                        fsm_count_up_j    <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S21:   begin
                        fsm_count_up_i    <= 'b1;
                        fsm_busy          <= 'b1;
                        end
                 S22:   fsm_done          <= 'b1;
                 S23:   fsm_done          <= 'b0;
             endcase
     end

 end

endmodule
