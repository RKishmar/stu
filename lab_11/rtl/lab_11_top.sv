// moving average LPF design

module lab_11_top #( parameter WIDTH = 16,
                     parameter ORDER = 8 )
(
  input  logic                   clk_i,
  input  logic                   srst_i,
  input  logic [ WIDTH - 1 : 0 ] data_i,
  output logic [ WIDTH - 1 : 0 ] data_o
);

  lab_11_if #( ORDER, WIDTH ) sink_if_inst   ( clk_i, srst_i );
  lab_11_if #( ORDER, WIDTH ) source_if_inst ( clk_i, srst_i );

  lab_11 #(
    .ORDER      ( ORDER          ),
    .WIDTH      ( WIDTH          ) )
  lab_11_inst_0 (  
    .clk_i      ( clk_i          ),
    .srst_i     ( srst_i         ),
    .snk_if     ( sink_if_inst   ),
    .src_if     ( source_if_inst )
  );

  always_comb 
    begin
      sink_if_inst.data = data_i;
      data_o = source_if_inst.data;
    end

endmodule
