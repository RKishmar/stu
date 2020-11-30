// moving average LPF design

module lab_11 # ( parameter ORDER = 8, parameter WIDTH = 16 )
(
  input  logic                   clk_i,
  input  logic                   srst_i,
  input  logic [ WIDTH - 1 : 0 ] data_i,
  output logic [ WIDTH - 1 : 0 ] data_o
);

localparam DIV = $clog2( ORDER );
bit [ ORDER - 1 : 0 ] [ WIDTH - 1       : 0 ] data_r;
bit                   [ WIDTH + DIV - 1 : 0 ] data_sum_r;
bit                   [ WIDTH + DIV - 1 : 0 ] data_sum_h;

always_ff @( posedge clk_i ) 
  begin
    data_r [ ORDER - 1 : 0 ] <= { data_r [ ORDER - 2 : 0 ], data_i };  
    data_sum_r <= data_sum_h + data_i;     
    $display ( "    DUT  DATA  REG  HOLDER  : %0p ", data_r );
  end
 
always_comb
  begin  
    data_o = ( data_sum_r >> DIV ) ; 
    data_sum_h = data_sum_r - data_r [ ORDER - 1 ];   
  end  
   
endmodule
