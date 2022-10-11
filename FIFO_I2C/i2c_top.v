module i2c_top  (input CLOCK_50,
					  output[6:0]HEX0,
					  output[9:0]LEDR,
					  input [3:0]KEY,
					  input [9:0]SW);

assign clk = CLOCK_50;

parameter W = 9; // width
 
parameter M = 5;  

reg  pre_reset;
reg  RESET;
reg  pre_clear;
reg  CLEAR;
reg  pre_read;
reg  READ;
reg  pre_write;
reg  WRITE;
wire write_edge;
wire read_edge;
wire write_fifo;
wire read_fifo;
wire [W-1:0]DATA;
wire [W-1:0]rd_data;
wire [M-1:0]wr_index;
wire [M-1:0]rd_index;
wire EMPTY;
wire FULL;
wire OVERFLOW;
wire MODE;

//reg [6:0]out_hex;

//reg [9:0]out_led;

assign DATA = SW[8:0];

assign MODE = SW[9];


always @ (posedge(clk))
begin
pre_reset <= !KEY[0];
RESET     <= pre_reset;
pre_clear <= !KEY[1];
CLEAR     <= pre_clear;
pre_read  <= !KEY[2];
READ      <= pre_read;
pre_write <= !KEY[3];
WRITE     <= pre_write;
end

// debouncing the write signal for 50ms to avoid glitches

Debounce_Switch d1(.i_clk(clk),.i_switch(WRITE),.o_switch(write_edge));

// debouncing the read signal for 50ms to avoid glitches

Debounce_Switch d2(.i_clk(clk),.i_switch(READ),.o_switch(read_edge));


edgedetector wr(.i_clk(clk),.i_signal(write_edge),.o_signal(write_fifo));

edgedetector rd(.i_clk(clk),.i_signal(read_edge),.o_signal(read_fifo));

// FIFO

fifo_i2c #(.W(W),.M(M))f1 
(.i_clk(clk),
 .reset(RESET),
 .wr_data(DATA),
 .wr_request(write_fifo),
 .rd_data(rd_data),
 .rd_request(read_fifo),
 .empty(EMPTY),
 .full(FULL),
 .overflow(OVERFLOW),
 .clear_overflow_request(CLEAR),
 .wr_index(wr_index),
 .rd_index(rd_index));
 
//always@(posedge clk)
//begin
 //if(EMPTY || FULL || OVERFLOW) //g,f,e,d,c,b,a
 //begin
 //out_hex <= {~FULL,2'b11,~OVERFLOW,2'b11,~EMPTY};
 //end
//end
assign HEX0 = {~FULL,2'b11,~OVERFLOW,2'b11,~EMPTY};

//always@(posedge clk)
//begin
  // case (MODE)
      //  1'b0: out_led = {1'b0,rd_data};
       // 1'b1: out_led = {wr_index,1'b0,rd_index};
	//endcase
//end
//assign LEDR = out_led;
assign LEDR = (MODE) ? {1'b0,rd_data} : {wr_index,1'b0,rd_index};
endmodule
