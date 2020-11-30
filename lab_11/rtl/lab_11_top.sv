// moving average LPF design

module lab_11_top #( parameter ORDER = 8, parameter WIDTH = 16 )
(
  input  logic                   clk_i,
  input  logic                   srst_i,
  input  logic [ WIDTH - 1 : 0 ] data_i,
  output logic [ WIDTH - 1 : 0 ] data_o
);

lab_11 #(
  .ORDER      ( ORDER  ),
  .WIDTH      ( WIDTH  ) )
lab_11_inst_0 (  
  .clk_i      ( clk_i  ),
  .srst_i     ( srst_i ),
  .data_i     ( data_i ),
  .data_o     ( data_o )
);
  
endmodule
