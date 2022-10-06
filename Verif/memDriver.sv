`include "base.sv"
`include "memInterface.sv"

`ifndef MEM_DRIVER
`define MEM_DRIVER

class mem_driver;
    virtual mem_interface_input ports;

    function new(virtual mem_interface_input i_ports);
    begin
        this.ports = i_ports;
        ports.Din       = 0;
      	ports.mode_in   = 0;
        ports.chip_en   = 0;
        ports.rw        = 0;
    end
    endfunction

  task start(mem_base_obj obj);//transfer the port-values from obj to our ports
    begin
      @(negedge ports.clk);
      begin
        #4
        ports.Din       <= obj.Din;
        ports.mode_in   <= obj.mode_in;
        ports.chip_en   <= obj.mode_in;//!!!!!!!!!!!!!!!!!!!!!!!!
        ports.rw       	<= obj.rw;
      	ports.reset     <= obj.reset;
      

      	$display("DRIVER: Din = %h, mode = %b, chip = %b, rw = %b;", ports.Din, ports.mode_in, ports.chip_en, ports.rw);
      end
    end
    endtask
endclass
`endif