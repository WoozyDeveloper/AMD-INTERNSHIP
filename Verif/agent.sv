`include "base.sv"
`include "memInterface.sv"
`include "memDriver.sv"
`include "ioMonitor.sv"
`include "transactionGenerator.sv"

`ifndef MEM_AGENT
`define MEM_AGENT

class mem_agent;
  	mem_txgen txgen;
  	mem_io_monitor io_monitor;
  	mem_scoreboard s_board;
    virtual mem_interface_input i_ports;
  	virtual mem_interface_output o_ports;

  function new(mem_scoreboard scoreboard, virtual mem_interface_input i_ports, virtual mem_interface_output o_ports);
    begin
      	txgen = new(i_ports);
      
      	this.s_board = scoreboard;
		this.i_ports = i_ports;
      	this.o_ports = o_ports;
      
      	io_monitor = new(s_board, i_ports, o_ports);
    end
  endfunction

  task start();
    begin
      fork
        //thread1 will run the monitor
        begin
        io_monitor.monitor();
        end
        
        //thread2 will change values in the input interface
        begin
			#1
          txgen.generateTransaction(4);
         	$finish;
        end
      join
    end
  endtask
  
endclass
`endif