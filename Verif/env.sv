`include "base.sv"
`include "memScoreboard.sv"
`include "transactionGenerator.sv"
`include "memInterface.sv"
`include "memDriver.sv"
`include "agent.sv"

`ifndef MEM_ENV
`define MEM_ENV

class mem_env;
  virtual mem_interface_input i_ports;
  virtual mem_interface_output o_ports;
  mem_scoreboard scoreboard;
  mem_agent agent; 
  	

  function new(mem_scoreboard scoreboard, virtual mem_interface_input i_ports, virtual mem_interface_output o_ports);
    begin
      	this.scoreboard = scoreboard;
		this.i_ports = i_ports;
      	this.o_ports = o_ports;
      
      agent = new(scoreboard, i_ports, o_ports); 
    end
  endfunction

  
  
  task start();
    begin
      agent.start();
    end
  endtask
  
endclass
`endif