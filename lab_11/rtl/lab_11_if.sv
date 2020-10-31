interface lab_11_if #( parameter ORDER_IF = 8, 
                       parameter WIDTH_IF = 16 )
( input     clk_i,
  input     srst_i );
                                    
  logic [ WIDTH_IF - 1 : 0 ] data;
  //wire  [ WIDTH_IF - 1 : 0 ] data;

 // modport source_if ( output data );
 // modport sink_if   ( input  data );
  //modport bidir_if  ( inout  data );
  
  always_ff @( posedge clk_i )
    $display ( " IF data: %0d ", data );

endinterface