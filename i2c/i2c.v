module i2c(clk,
           reset,
           avalon_chipselect,
           avalon_address,
           avalon_write,
           avalon_writedata,
           avalon_read,
           avalon_readdata,
           chipselect,
		     address,
           read,
           readdata,
           write,
           writedata,
           I2C_SCL,
           I2C_SDA,
           I2C_TEST_OUT);




    parameter W = 8;// width of the FiFo
    
    parameter M = 7; // N = 64 (depth of FiFO) check the Fifo i2C module for better understanding


    input   clk, reset;
    

    // Avalon MM interface (4 word aperature)
    input             avalon_chipselect,avalon_read,avalon_write;
    input [1:0]       avalon_address;
    input [31:0]      avalon_writedata;
    output reg [31:0] avalon_readdata;
    output            chipselect,read,write;
    output [1:0]      address;   
    output [4:0]      writedata;  
    output [4:0]      readdata;	 
         
           
    output I2C_SCL;
    output I2C_SDA;
    output I2C_TEST_OUT;
	 
	 
    reg [6:0] int_address;
    reg [7:0] data;
    reg [31:0]status;
    reg [31:0]control; 

    wire [7:0] rd_data;
    wire [31:0]rd_status;
    wire [5:0] wr_index;
    wire [5:0] rd_index;
    wire EMPTY;
    wire FULL;
    wire OVERFLOW;
    wire write_fifo;
    wire read_fifo;
    wire CLEAR;
    wire RX_FO;
    wire RX_FF;
    wire RX_FE;
    wire ACK_ERROR;
    wire BUSY;

    assign RX_FO = 1'b0;
    assign RX_FF = 1'b0;
    assign RX_FE = 1'b0;
    assign ACK_ERROR = 1'b0;
    assign BUSY      = 1'b0;
	 
	 reg read_edge;
	 
	 reg write_edge;
    
    
      
    
    
    // register map
    // ofs  fn
    //   0  ADDRESS (r/w)
    //   4  DATA    (r/w)
    //   8  STATUS  (r/w1c)
    //   16 CONTROL (r/w)
    
    // register numbers
      parameter  ADDRESS_REG    =     2'b00;
	 parameter  DATA_REG       =    2'b01;
	 parameter  STATUS_REG     =    2'b10;
	 parameter  CONTROL_REG    =    2'b11;
    
    
    // read register
    always @ (*)
    begin
        if (avalon_read &&  avalon_chipselect)
		  begin
            case (avalon_address)
               ADDRESS_REG: 
                  avalon_readdata = int_address;
               DATA_REG: 
					   begin
					    read_edge       = 1'b1;
                   avalon_readdata = rd_data;
						end
               STATUS_REG:
                  avalon_readdata = rd_status;
               CONTROL_REG:
                  avalon_readdata = control;
            endcase
		   end
         else
		   begin
            avalon_readdata = 32'b0;
				read_edge       = 1'b0;
			end
    end        

    // write register 
    always @ (posedge clk)
    begin
        if (reset)
        begin
            int_address[6:0]       <= 7'b0;
            data[7:0]              <= 8'b0;
		      status[31:0]           <= 32'b0;
		      control[31:0]          <= 32'b0;
        end
        else
        begin
            if (avalon_write && avalon_chipselect)
            begin
                case (avalon_address)
                     ADDRESS_REG: 
                       int_address  <= avalon_writedata;
                     DATA_REG: 
							  begin
                        data         <= avalon_writedata;
							   write_edge   <= 1'b1; s
							  end
                     STATUS_REG:
                       status       <= avalon_writedata;
                     CONTROL_REG:
                       control      <= avalon_writedata;
                endcase
            end
				else 
				  write_edge   <= 1'b0;
        end
    end



assign CLEAR = status[3];// clear the status overflow requests

edgedetector wr(.i_clk(clk),.i_signal(write_edge),.o_signal(write_fifo));

edgedetector rd(.i_clk(clk),.i_signal(read_edge),.o_signal(read_fifo));




fifo_i2c #(.W(W),.M(M))transmit_fifo // transmit fifo
(.i_clk(clk),
 .reset(reset),
 .wr_data(data),
 .wr_request(write_fifo),
 .rd_data(rd_data),
 .rd_request(read_fifo),
 .empty(EMPTY),
 .full(FULL),
 .overflow(OVERFLOW),
 .clear_overflow_request(CLEAR),
 .wr_index(wr_index),
 .rd_index(rd_index));

// status register (read) 
assign rd_status = {12'b000000000000,rd_index,wr_index,BUSY,ACK_ERROR,EMPTY,FULL,OVERFLOW,RX_FE,RX_FF,RX_FO};


assign  chipselect = avalon_chipselect;
assign  read       = avalon_read;
assign  write      = avalon_write;
assign  address    = avalon_address;
assign  writedata  = wr_index[4:0];
assign  readdata   = rd_index[4:0];

endmodule 
