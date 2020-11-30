
`timescale 10ns / 10ns

module lab_11_tb; 

  localparam CLK_HLFPER  = 2; 
  localparam TEST_LENGTH = 555555;
  localparam WIDTH_TB    = 16;
  localparam ORDER_TB    = 8;  

  logic                      clk_tb;
  logic                      srst_tb;

//-----> DUT interfaces <-----------------------------------------------------------------------------------

  lab_11_if #( ORDER_TB, WIDTH_TB ) top_if_i ( clk_tb, srst_tb );
  lab_11_if #( ORDER_TB, WIDTH_TB ) top_if_o ( clk_tb, srst_tb );
  
//-----> DUT inst <-----------------------------------------------------------------------------------

  lab_11_top    #(
    .ORDER       ( ORDER_TB      ),
    .WIDTH       ( WIDTH_TB      ) )
  lab_11_inst_tb (  
    .clk_i       ( clk_tb        ),
    .srst_i      ( srst_tb       ),
    .data_i      ( top_if_i.data ),
    .data_o      ( top_if_o.data ) );

//-----> transaction <--------------------------------------------------------------------------------

  class packet;
    struct { rand bit [ WIDTH_TB - 1 : 0 ] data; } str;
    int k = 0;
    
    function void randomize_packet;
      begin
        this.str.data = $random; 
      end
    endfunction
          
    function void print;
      $display ( " Packet content -> %0p ", this.str );
    endfunction
  
  endclass 

//-----> generator <--------------------------------------------------------------------------------

  class generator;
    mailbox gen_mbx;
    packet pck = new;

    task run;
      forever
        begin
          @( posedge clk_tb );      
          pck.randomize_packet;
          gen_mbx.put( pck );
        end
    endtask : run 
    
  endclass : generator

//-----> driver <--------------------------------------------------------------------------------

  class driver;
    virtual lab_11_if #( ORDER_TB, WIDTH_TB ) drv_if; 
    mailbox dri_mbx;
    packet  pck = new;
      
    task run;
      forever 
        begin
          @ ( posedge clk_tb );     
          dri_mbx.get( pck );
          drv_if.data = this.pck.str.data;     
        end
    endtask : run
    
  endclass : driver

//-----> monitor <---------------------------------------------------------------------------------

  class monitor;
    virtual lab_11_if #( ORDER_TB, WIDTH_TB ) mon_if;
    mailbox mon_mbx;
    packet  pck = new; 
    
    task run;
      forever begin
        @( posedge clk_tb );      
        pck.str.data = mon_if.data; 
        this.mon_mbx.put( pck );
      end
    endtask
    
  endclass : monitor

//-----> scoreboard <------------------------------------------------------------------------------

  class scoreboard;
    mailbox      sbi_mbx;
    mailbox      sbo_mbx;
    packet       pck_i;
    packet       pck_o;
    int          res = 0;
    int          err = 0;
    
    bit [ WIDTH_TB - 1 : 0 ] data_hld [ ORDER_TB - 1 : 0 ];     
      
    task get_true_output ( packet new_pck );
      bit [ WIDTH_TB + ORDER_TB : 0 ] sum;
      begin
        data_hld [ ORDER_TB - 1 : 0 ] = { data_hld [ ORDER_TB - 2 : 0 ], new_pck.str.data }; 
        sum = 0;
        for ( int i = 0; i < ORDER_TB; i++ )
          begin 
            sum = sum + data_hld [ i ];
          end   
        $display ( "    TB SCB FUNC DATA HOLDER : %0p ", data_hld );           
        res = int '( sum / ORDER_TB );
      end
    endtask

    
    task run;
      begin  
        pck_i = new;
        pck_o = new;
        
        @( posedge clk_tb );    

        forever begin
          
          get_true_output ( pck_i );  
          
          fork 
            sbi_mbx.get( pck_i );
            sbo_mbx.get( pck_o );
          join   
    
          if ( this.pck_o.str.data !== res ) 
            begin
              this.err = this.err + 1;
              $display ( "\n--- RESULTS DON'T MATCH (dut/tst): %0d / %0d\n", this.pck_o.str.data, res );
            end
          else              
            $display ( "\nOK! GOT CORRECT RESULTS (dut/tst): %0p / %0p\n", this.pck_o.str.data, res );
            
          $display( "    ERROR COUNT: %0d ", this.err );            
        end  

      end
    endtask : run
            
    task summarize ();
      begin
        $display ( "\n------------------------------------------------------------------------------" );
        $display ( "\n THE TEST HAS REACHED IT'S FINISH " );
        $display ( "\n TOTAL ERROR COUNT: %0d \n", this.err ); 
        $stop;
      end
    endtask : summarize
    
  endclass : scoreboard

//-----> environment <-----------------------------------------------------------------------------

  class environment;
    driver        d_o;         
    monitor       m_o;         
    monitor       m_i;         
    generator     g_o;         
    scoreboard    s_i;         

    mailbox   env_gen_mbx;        
    mailbox   env_inp_mbx;        
    mailbox   env_out_mbx;            
 
    virtual lab_11_if env_if_i;    
    virtual lab_11_if env_if_o;      

    function new;
      fork
        d_o          = new;
        g_o          = new;   
        m_o          = new;
        m_i          = new;
        s_i          = new;
        env_gen_mbx  = new;
        env_inp_mbx  = new;
        env_out_mbx  = new;
      join
      d_o.dri_mbx  = env_gen_mbx;
      g_o.gen_mbx  = env_gen_mbx;
      m_i.mon_mbx  = env_inp_mbx;
      s_i.sbi_mbx  = env_inp_mbx;
      s_i.sbo_mbx  = env_out_mbx;
      m_o.mon_mbx  = env_out_mbx;
    endfunction

    task run;
      begin 
        d_o.drv_if = env_if_i;
        m_o.mon_if = env_if_o;
        m_i.mon_if = env_if_i;
      
        fork
          d_o.run;
          m_i.run;
          m_o.run;
          g_o.run;
          s_i.run;
          #TEST_LENGTH s_i.summarize();
        join
        
      end
    endtask : run
  
  endclass : environment

//-----> test <------------------------------------------------------------------------------------

  class test;
    environment e0;

    function new;
      e0 = new;
    endfunction

    task run;
      e0.run;
    endtask
  
  endclass : test

//-----> main <---------------------------------------------------------------------------------


  initial // main
    begin
      automatic test t0 = new;
      t0.e0.env_if_i = top_if_i;
      t0.e0.env_if_o = top_if_o;
      t0.run;
    end

  always 
    begin
      clk_tb = 1; #CLK_HLFPER; 
      clk_tb = 0; #CLK_HLFPER;
    end
    
endmodule

  
  