module edgedetector( input i_clk, input i_signal, output  o_signal);

reg d_signal;

always@(posedge i_clk)
begin
  
  d_signal <= i_signal;

end

assign o_signal = i_signal & (!d_signal);

endmodule 