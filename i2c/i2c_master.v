module i2c_master#(
            parameter DATA_WIDTH = 8,
            parameter REG_WIDTH  = 8,
            parameter ADDR_WIDTH = 7 )
    (
            input                           i_clk,
            input                           i_reset,
            input                           i_start,// start
            input                           i_repeated_start,// 
            input                           i_rw,// control register
            input                           i_usereg,
            input                           i_bytecount,// 
            input       [DATA_WIDTH-1:0]    i_transmit_data,// connect to transmit fifo
            input       [REG_WIDTH-1:0]     i_reg_addr,
            input       [ADDR_WIDTH-1:0]    i_device_addr,
            output reg  [DATA_WIDTH-1:0]    o_receive_data = 0,// connect it to the recieve fifo
            output reg                      o_rd_signal = 0,
			output reg                         o_wr_signal = 0,
            output reg                      o_busy = 0,
            output reg                      o_ack_error = 0,
		    output reg                      o_start = 1,
            inout  reg                      i2c_sda,
            inout  reg                      i2c_scl,
		    output                          i2c_test_out,
		    output  [5:0]                   o_byte_count
    );


	 
  //
 
	 

	 
	 
	 
	 // MAIN_SM
    parameter IDLE = 3'd0;
    parameter START = 3'd1;
    parameter SEND_RECEIVE_I2C = 3'd2;
    parameter RECEIVE_ACK = 3'd3;
    parameter SEND_RESTART = 3'd4;
    parameter SEND_ACK     = 3'd5;
    parameter SEND_NACK = 3'd6;
    parameter SEND_STOP = 3'd7;
    reg [2:0] Main_SM = IDLE;
    reg [2:0] post_MAIN_SM = IDLE;
    reg process_counter = 0;
    reg [3:0] bit_counter = 0;
    reg use_reg; 
    reg rw = 0;
    reg repeated_start = 0;
    reg [5:0] byte_count = 0;

    reg  [1:0] sel;	
	
	reg read_address_done = 0;
	
	wire [7:0] data;
	
	reg start;
	 
	 
	 assign o_byte_count = byte_count; // output byte_count
	 
	 
	


    // 
      assign data = sel[1] ? (sel[0] ? {i_device_addr,1'b1}: (i_transmit_data)) : (sel[0] ? (i_reg_addr) : {i_device_addr,1'b0});

   
	 
    parameter divider = 8'd250;

    
    reg [7:0] divider_counter = 0;
   
    wire i_divider_tick;
	 
    wire o_divider_tick;
	 
	 assign i_divider_tick = (divider_counter<(divider/2))?1'b1:1'b0;
	 
	 assign i2c_test_out  = i_divider_tick;

    //i2c divider tick geneartor
    always@(posedge i_clk)begin
        if(i_reset)begin
            divider_counter <= 0;
        end
        else 
		     begin
           divider_counter <= divider_counter + 8'd1;
           if(divider_counter >=(divider-1))
              divider_counter <= 8'd0;
        end
    end
edgedetector clocktick (.i_clk(i_clk),.i_signal(i_divider_tick),.o_signal(o_divider_tick));



always@(posedge i_clk)
begin
  if (i_reset)
		begin
			i2c_sda <= 1'bz;
			i2c_scl <= 1'bz;
			process_counter <= 0;
			bit_counter <= 0;
			use_reg <= 0;
			o_busy <= 0;
			o_wr_signal <= 0;
		    repeated_start <= i_repeated_start;
           o_rd_signal <= 0;
			byte_count <=0;
			rw <= 0;
			start <= 0;
			read_address_done <= 0;
			Main_SM  <= IDLE;
		end
		else
		begin
		   if (i_start == 1'b1)
			  start <= 1'b1;
		   if( o_rd_signal == 1'b1)
			   o_rd_signal <= 1'b0;
			if(o_wr_signal== 1'b1)
			   o_wr_signal <= 1'b0;
			if (o_divider_tick)
			begin
				case(Main_SM)
				  IDLE:
					begin
					 process_counter <= 0;
					 i2c_sda <= 1'bz;
					 i2c_scl <= 1'bz;
					 rw      <= i_rw;
					 use_reg <= i_usereg;
					 repeated_start <= i_repeated_start;
                     byte_count <= i_bytecount;
					 sel <= 2'b00;
					 o_busy <= 0;
					 o_wr_signal <= 0;
					 read_address_done <= 0;
                 o_rd_signal <= 0;
					 if(start)
						begin
						Main_SM <= START;
						end
      				end

				  START: 
					begin
					 case(process_counter)
					 0: begin
						 process_counter <= 1;
						 o_busy <=  1;
						 start <= 1'b0;
						 o_start <= 1'b0;
						 i2c_sda <= 1'b0;
						 i2c_scl <= 1'bz;
						 end
					 1: begin
						 bit_counter <= 8;
						 i2c_scl <= 1'b0;
						 process_counter <= 0;
						 Main_SM <= SEND_RECEIVE_I2C;
						 i2c_sda <= data[7];// device address
						 end
					  endcase
					end
				  SEND_RECEIVE_I2C:
				  begin
					case(process_counter)
						0: begin
							i2c_scl <= 1'bz;
							process_counter <= 1;
							bit_counter <= bit_counter-1;
							if(read_address_done)
							i2c_sda <= 1'bz; // relaesing the bus for another read from the slave
						   end
						1: begin
							i2c_scl <= 1'b0;
							process_counter <= 0;
							if(bit_counter == 0)
							 begin//2
							   case (sel)
								2'b00 : begin //1
								        if(use_reg)//// reg addr
								        sel <= 2'b01;
										i2c_sda <= 1'bz;
										Main_SM <= RECEIVE_ACK;// this recieve ack is for address
										end//1
							    2'b01 : begin //2 			
  								          o_rd_signal <=1'b1;
								          sel <= 2'b10;// write data	
											 i2c_sda <= 1'bz;
                                  Main_SM <= RECEIVE_ACK;                    								 
                                  end//2											
								2'b10 : begin //3 // write data
								        byte_count <= byte_count-1; // byte_count 
										  o_rd_signal <=1;
										  i2c_sda <= 1'bz;
										  Main_SM <= RECEIVE_ACK;	// receive ack for data
										  sel <= 2'b10;
								        end//3
									   
                                2'b11 : begin// read data after address
								          if(read_address_done) // read data after address
										   begin
								             byte_count <= byte_count-1;//4
										     o_wr_signal <= 1'b1;
										     if(byte_count == 1'b1)
										      begin
										        Main_SM <= SEND_NACK;
										        i2c_sda <= 1'bz;
										      end
										      else
										       begin
										        Main_SM <= SEND_ACK;
											    i2c_sda <= 1'b0;
											   end
										   end
										  else
										  begin
										    read_address_done <= 1'b1;
											 i2c_sda <= 1'bz; 
										    Main_SM <= RECEIVE_ACK;
		         						end
								          sel <= 2'b11;//4
                                        end														    
                                     endcase							          
							          bit_counter<= 8;								
						           end
							   if(read_address_done)
                               o_receive_data[bit_counter-1] <= i2c_sda;				   
							   else
							    i2c_sda <= data[bit_counter-1]; 			    
                          end							  
						endcase
						end		
			
				 RECEIVE_ACK: 
				  begin
						if(i2c_scl == 0)
						begin
							if(i2c_sda == 0)
							  begin
								i2c_scl <= 1'bz;
								Main_SM <= RECEIVE_ACK;
								if(read_address_done)
								 begin								  
								  i2c_sda <= 1'bz;
								 end
							  end
							  else
							    begin
							     Main_SM <= SEND_STOP;
							    end
						end 
					   else 
                    begin
					       i2c_scl <= 1'b0;
							 if(sel == 2'b10 && rw == 1'b1 && !repeated_start) 
							   Main_SM <= SEND_STOP;
							 else if(sel == 2'b10 && rw == 1'b1 && repeated_start)
							   Main_SM <= SEND_RESTART;
							 else if(byte_count!=0 )
							     begin
                           if(read_address_done)
						          o_receive_data[7] <= i2c_sda;
						        else
						        i2c_sda <= data[7];
						        Main_SM <= SEND_RECEIVE_I2C;
						   end 
							else 
							 Main_SM <= SEND_STOP;
					     end
						 end

				 SEND_RESTART:
				 begin
				 
				 end


				 SEND_ACK:
				 begin
				 case(process_counter)
				  0: begin
				       i2c_scl <= 1'bz;
				       i2c_sda <= 1'b0;
					   process_counter<=1;
				     end
                 1: begin
				      i2c_scl <= 1'b0; 
				      o_receive_data[7] <= i2c_sda;
					  Main_SM <= SEND_RECEIVE_I2C;
					  process_counter<=0;	
                    end
				endcase
				end
				
				  
				  
				 SEND_NACK:
				 begin
				 case(process_counter)
				   0: begin
				       i2c_scl <= 1'bz;
				       i2c_sda <= 1'bz;
					   process_counter<=1;
				     end
                 1: begin
				      i2c_scl <= 1'b0; 
					  i2c_sda <= 1'b0;
					  Main_SM <= SEND_STOP;
					  rw <= 1'b0;
					  process_counter<=0;				 
				    end
				 endcase
				end  

				 SEND_STOP:
				  begin
				  case(process_counter)
				  0: begin
				      i2c_scl <= 1'bz;
				      i2c_sda <= 1'b0;
					  process_counter<=1;
				     end
				  1: begin
				         i2c_scl <= 1'bz;
				         i2c_sda <= 1'bz;
					     if(rw) // read operation is necessary after sending the start 
					      begin
					       sel<= 2'b11;
					       Main_SM <= START;
					      end
					      else
				           Main_SM <= IDLE;	 				
					       process_counter<=0;
             		  end 
					endcase             					  
				   end 
endcase
end// if
end // else
end// always
endmodule
