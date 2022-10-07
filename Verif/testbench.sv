`include "memInterface.sv"
`include "base.sv"
`include "ioMonitor.sv"
`include "memScoreboard.sv"
`include "transactionGenerator.sv"
`include "agent.sv"
`include "env.sv"


module tb_mem_cell;

    reg [31:0] Din;
    reg [2:0] mode_in;
    reg [2:0] chip_en;
    reg [1:0] rw;
    reg reset;
    reg clk;
    wire [31:0] Dout;
    wire full;
    wire empty;
  

  mem_interface_input i_ports(clk,Din,mode_in,chip_en,rw,reset);//input interface
  mem_interface_output o_ports(clk,Dout,full,empty);//output interface
  
  
  mem_cell #(.WIDTH(8)) DUT (i_ports.Din, i_ports.mode_in, i_ports.chip_en, i_ports.rw, i_ports.reset, i_ports.clk, o_ports.Dout, o_ports.full, o_ports.empty);//design

  mem_scoreboard s_board = new();
  mem_env env = new(s_board, i_ports, o_ports); 

    initial begin

      	$dumpvars(0, tb_mem_cell);
		$dumpfile("my.vcd");
		
      	//clock
        clk = 1;
     
        forever
            #5 clk = ~clk;
        end
        initial begin
          $display("STARTING TESTBENCH");
          i_ports.reset = 0;
          #10
          i_ports.reset = 1;
          #10
          i_ports.reset = 0;
          env.start();
        end
endmodule