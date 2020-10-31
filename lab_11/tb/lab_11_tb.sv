
`timescale 10ns / 10ns

module lab_11_tb; 

  localparam    TEST_ITERS    = 22222;
  localparam    CLK_HLFPER    = 2; 
  localparam    WIDTH_TB      = 16;
  localparam    ORDER_TB      = 8; 
  localparam    ERR_CNT_SIZE  = 16;  
  localparam    GEN_DEL_MAdata   = CLK_HLFPER * 8; 

  logic                   clk_tb;
  logic                   srst_tb;
  logic [ WIDTH_TB - 1 : 0 ] data_tb_i;
  logic [ WIDTH_TB - 1 : 0 ] data_tb_o;

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
  .data_o      ( top_if_o.data )
);

//-----> transaction <--------------------------------------------------------------------------------

  class packet;
    struct { rand bit [ WIDTH_TB - 1 : 0 ] data; } str;
        
    function void randomize_packet;
      this.str.data = $random;
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
          pck.randomize_packet;
          gen_mbx.put( pck );
          @( posedge clk_tb );
          //$display ( " GEN PACKET : %0p ", this.pck );
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
          dri_mbx.get( pck );
          drv_if.data  = this.pck.str.data;     
          @ ( posedge clk_tb );
		  //$display ( " DRV PACKET : %0p ", this.pck );
        end
    endtask 
    
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
        //$display ( " MON PACKET : %0p ", this.pck );  
      end
    endtask
  endclass : monitor

//-----> scoreboard <------------------------------------------------------------------------------

  class scoreboard;
    logic [ ERR_CNT_SIZE - 1 : 0 ] err;

    mailbox      sbi_mbx;
    mailbox      sbo_mbx;
    packet       pck_i;
    packet       pck_o;
  
    task run;
      begin  
        pck_i = new;
        pck_o = new;
        forever begin 
          @( posedge clk_tb );
          fork 
            sbi_mbx.get( pck_i );
            sbo_mbx.get( pck_o );
          join 
          $display ( " SCOREBOARD pck_o / pck_i: %p / %p \n", pck_o, pck_i );
            if ( this.pck_o.str !== this.pck_i.str ) 
              begin
                this.err = this.err + 1;
                //$display ( "Packages DON't match: %0p / %0p", this.pck_i.str, this.pck_o.str );
              end
            //else
              //$display ( "OK! packages match: %0p / %0p", this.pck_i.str, this.pck_o.str );

        end       
      end
    endtask
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
          #200 $stop;
        join
      end
    endtask
  
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

//-----> initial <---------------------------------------------------------------------------------


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

  
  