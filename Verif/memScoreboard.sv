`include "base.sv"

`ifndef MEM_SB
`define MEM_SB

class mem_scoreboard;
  localparam BUFFER = 3'b001;
  localparam FIFO = 3'b010;
  localparam LIFO = 3'b100;
  
  mem_base_obj mem_obj[*];//array where we store all the incomming objects filled with data
  integer dim;//size of the array
  integer index;//index used in for loops
  integer good_results, bad_results;//counter for good/bad results
  
  function new();
    begin
      good_results 	= 0;//counter for good results (when Dout == expected out)
      bad_results 	= 0;//counter for bad results (when Dout != expected out)
      dim 			= 0;//init the dim of the array
    end
  endfunction
  
  function integer getGoodResults();
    begin
      return this.good_results;
    end
  endfunction
  
  function integer getBadResults();
    begin
      return this.bad_results;
    end
  endfunction
  
  function real getGoodTestPercentage();
    begin
      return (this.good_results * 100.0) / (this.good_results + this.bad_results);
    end
  endfunction
  
  function printPercentage();
    begin
      $display();
      $display("-------------------- SCORE -------------------------------GOOD--------------------BAD--------------------");
      $display("Scoreboard: %0f %c good tests with %d good tests and %d bad tests", this.getGoodTestPercentage(), "%", this.good_results, this.bad_results);
      $display("---------------------------------------------------------------------------------------------------------");
    end
  endfunction
  
  task post_input(mem_base_obj obj);//obj is filled with input data
    begin
      $display("SCOREBOAR IN");
      if(obj.reset == 1)
     	begin
        	dim = 0;
          	good_results++;
            $display("Scoreboard: RESET ! ! !");
          	this.printPercentage();
          	return;
        end
      if(obj.chip_en == obj.mode_in)//if we have the same mode and chip
        begin
          if(obj.rw == 2'b01)
            begin
              $display("Scoreboard: Expected write action!!! (Din = %h)", obj.Din);
              good_results++;
              mem_obj[dim] = obj;//put the obj in the array and increase the dim
              dim++;
            end
          else
            begin
              bad_results++;
              $error("Scoreboard: Unexpected write action!!! (Din = %h)", obj.Din);
            end
          
          	this.printPercentage();
          	//print the array for DEBUG
          	$display("<<----------- CURRENT MEM IN SCOREBOARD (INPUT) ----------->> dim = ", this.dim);
            for(index = 0; index < dim; index++) begin
              $display(index, " -- %h", mem_obj[index].Din);
            end
        end
      else begin//if chip != mode
        $display("Scoreboard: Can't add the number because CHIP != MODE ", obj.chip_en, " != ", obj.mode_in);
      end
    end
  endtask
  
  
  
  task post_output(mem_base_obj obj);//obj is filled with output data
    begin
      mem_base_obj expected = new();
		      
     if(obj.reset == 1)
     	begin
        	dim = 0;
          	good_results++;
            $display("Scoreboard: RESET ! ! !");
          	this.printPercentage();
          	return;
        end
        
      if(dim <= 0) begin//if the array is empty
        $display("Scoreboard: EMPTY dout = %h, rw = %b",obj.Dout, obj.rw);
          dim = 0;
        if(obj.Dout != 0 && obj.rw == 2'b10) begin
			bad_results++;
            $display("Scoreboard: Dout != 0 on EMPTY mem");
          	this.printPercentage();
            return;
          end
        if(obj.Dout == 0 && obj.rw == 2'b10)//pop on empty
            begin
              	$display("Scoreboard: Expected output Dout = 0");
              	good_results++;
            end
          else if(obj.Dout != 0 && obj.mode_in != BUFFER)
            begin
            	$error("Scoreboard: %d != 0 (expected 0). . .", obj.Dout);
              	bad_results++;
            end
          else if(obj.mode_in == BUFFER)
            begin
              if(obj.Din == obj.Dout)
                begin
                	$display("Scoreboard: Expected output for BUFFER: %h --> %h", obj.Din, obj.Dout);
                  	good_results++;
                end
              else
                begin
                  $error("Scoreboard: Unexpected output for BUFFER:  mem = %h --> on design = %h", obj.Din, obj.Dout);
                  bad_results++;
                end
            end
        end
        
        else//if we still have data in the array (dim > 0)
        begin
          case(obj.chip_en)
            BUFFER://CHIP = BUFFER
            begin
              if(obj.Din == obj.Dout)
                begin
                	$display("Scoreboard: Expected output for BUFFER: %h --> %h", obj.Din, obj.Dout);
                  	good_results++;
                end
              else
                begin
                  $error("Scoreboard: Unexpected output for BUFFER:  mem = %h --> on design = %h", obj.Din, obj.Dout);
                  bad_results++;
                end
            end

            FIFO: //CHIP = FIFO
            begin
                  expected = mem_obj[0];  //first object in the memory
                  for(index = 0; index < dim - 1; index++)//shift the memory one step to the left to delete the first element
                    mem_obj[index] = mem_obj[index + 1];
                  if(expected.Din == obj.Dout)//if the output of the received obj is the same as the input from our memory
                  begin
                      $display("Scoreboard: Expected output for FIFO: %h --> %h", expected.Din, obj.Dout);
                      $display("scad dim");
                      dim--;
                      good_results++;
                  end
                  else
                  begin
                    $error("Scoreboard: Unexpected output for FIFO: mem = %h --> design = %h", expected.Din, obj.Dout);
                    bad_results++;
                    dim--;
                  end
                
            end

            LIFO: //CHIP = LIFO
            begin
              expected = mem_obj[dim - 1];//last object in the memory
                if(expected.Din == obj.Dout)//if the output of the received obj is the same as the input from our memory
                begin
                  $display("Scoreboard: Expected output for LIFO: %h --> %h", expected.Din, obj.Dout);
                  $display("scad dim");
                  good_results++;
                  dim--;
                end
                else
                begin
                  $error("Scoreboard: Unexpected output for LIFO: mem = %h --> design = %h", expected.Din, obj.Dout);
                  bad_results++;
                  dim--;
                end
            end
        endcase
        
        //print the memory
        $display("<<-----------CURRENT MEM IN SCOREBOARD (OUTPUT) ----------->> dim = ", dim);
        for(index = 0; index < dim; index++) begin
          $display(index, " -- %h", mem_obj[index].Din);
        end
        //$display("----------------------------------------------------------------------");
      end
      this.printPercentage();
    end
  endtask
  

endclass

`endif