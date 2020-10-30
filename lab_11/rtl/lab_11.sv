// moving average LPF design

module lab_11 # ( parameter ORDER = 8, 
                  parameter WIDTH = 16 )
(
  input  logic         clk_i,
  input  logic         srst_i,
  lab_11_if.sink_if    snk_if,
  lab_11_if.source_if  src_if
);

localparam DIV = $clog2( ORDER );
bit [ WIDTH - 1       : 0 ] data_r    [ ORDER - 1 : 0 ];
bit [ WIDTH + DIV - 1 : 0 ] data_sum_r;

always_ff @( posedge clk_i ) 
  begin
    data_r [ 0 ] <= snk_if.data; 
    for ( int g = 0; g < ORDER - 1; g ++ )
      data_r [ g + 1 ] <= data_r [ g ];
  end

always_ff @( posedge clk_i )
  begin
    src_if.data <= ( data_sum_r >> DIV ) ;  
  end
  
always_comb
  begin  
    data_sum_r = 0;
    for ( int g = 0; g < ORDER; g ++ )
      data_sum_r = data_sum_r + data_r [ g ];
  end  
  
  
endmodule
