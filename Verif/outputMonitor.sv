`include "base.sv"
`include "memInterface.sv"
`include "memScoreboard.sv"

`ifndef MEM_IN
`define MEM_IN

class mem_in_monitor;
  mem_base_obj base_obj;
  mem_scoreboard sb;
  virtual mem_interface_input output_ports;
  
  funnction new(mem_scoreboard sb, virtual mem_output_interface o_ports);
  begin
    this.sb = sb;
    this.output_ports = o_ports;
  end
  
  task output_monitor();
    begin
      while(1) begin
        @(negedge input_ports.clk);//read the data
        if(input_ports.rw == pop)
        begin
            mem_obj = new();//create the object and fill it with input data
            $display("Output_monitor : DataOut : %h | Chip : %b | Mode : %b | RW : %b", output_ports.Dout, output_ports.chip_en, output_ports.mode_in, output_ports.rw);

            //take data from the input interface and put it in our base object
            mem_obj.Dout 	= output_ports.Dout;
            mem_obj.chip_en = output_ports.chip_en;
            mem_obj.full  	= output_ports.full;
            mem_obj.empty 	= output_ports.empty;
            mem_obj.reset 	= output_ports.reset;


            $display("SENDING OUTPUT TO SCOREBOARD!!!!!!!!!!!!!!!!!!!!!!");
            //send to scoreboard
            mem_sb.post_output(mem_obj);
        end
      end
    end
  endtask
  
  
endclass  
`endif