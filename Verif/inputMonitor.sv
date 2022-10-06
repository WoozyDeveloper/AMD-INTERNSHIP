`include "base.sv"
`include "memInterface.sv"
`include "memScoreboard.sv"

`ifndef MEM_IN
`define MEM_IN

class mem_in_monitor;
  mem_base_obj base_obj;
  mem_scoreboard sb;
  virtual mem_interface_input input_ports;
  
  funnction new(mem_scoreboard sb, virtual mem_input_interface i_ports);
  begin
    this.sb = sb;
    this.input_ports = i_ports;
  end
  
  task input_monitor();
    begin
      while(1) begin
        @ (posedge input_ports.clk);
        $display("mode = %b, chip = %b", input_ports.mode_in, input_ports.chip_en);
        if(input_ports.rw == push)
        begin
            mem_obj = new();//create the object and fill it with input data
          $display("input_monitor : DataIn : %h | Chip : %b | Mode : %b | Reset : %b", input_ports.Din, input_ports.chip_en, input_ports.mode_in, input_ports.reset);

            //take data from the input interface and put it in our base object
            mem_obj.Din 	= input_ports.Din;
            mem_obj.mode_in = input_ports.mode_in;
            mem_obj.chip_en = input_ports.chip_en;
            mem_obj.rw 		= input_ports.rw;
            mem_obj.reset 	= input_ports.reset;

            //send to scoreboard  
            mem_sb.post_input(mem_obj);
        end
      end
    end
  endtask
  
  
endclass  
`endif