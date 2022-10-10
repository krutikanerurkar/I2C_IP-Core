
module fifo_i2c #(parameter W,      // word size
                  parameter M, 
                  parameter N = 2 ** M) // depth fifo
                 (input i_clk,
                  input reset,
			         input[W-1:0]wr_data,
			         input wr_request,
			         output reg [W-1:0]rd_data,
			         input rd_request,
			         output empty,
			         output full, 
			         output reg overflow, 
			         input clear_overflow_request, 
			         output reg [M-1:0] wr_index,
			         output reg [M-1:0] rd_index);
		
	
reg [W-1:0]FIFO[(N/2)-1:0];

 assign empty       = (wr_index == rd_index)? 1'b1: 1'b0; // empty condition
 assign full        = ((wr_index [M-2:0] == rd_index[M-2:0]) & (wr_index[M-1] != rd_index[M-1])) ? 1'b1 : 1'b0; // full condition


  
 always@(posedge i_clk)
 begin
   if (reset)
	begin
	   wr_index <= 0;
		rd_index <= 0;
		overflow <= 0;
	end
	else
		begin
		if (clear_overflow_request)
		begin  
			overflow <= 0;
		end
		if (wr_request && !full && !overflow) 
		begin
		  FIFO[wr_index] <= wr_data;
		  wr_index <= wr_index+1;	
		end    
		if (wr_request && full)    
		begin
		  overflow <= 1;	
		end
		if (rd_request && !empty) 
		begin
		 rd_data<= FIFO[rd_index];
		 rd_index <= rd_index+1; 
		end
	end
 end
endmodule 