interface lab_11_if #( parameter ORDER_IF = 8, 
                       parameter WIDTH_IF = 16 )
( input     clk_i,
  input     srst_i );
                                    
  logic [ WIDTH_IF - 1 : 0 ] data;

endinterface