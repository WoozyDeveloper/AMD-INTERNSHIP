`include "base.sv"
`include "memInterface.sv"
`include "memDriver.sv"

`ifndef MEM_TXGEN
`define MEM_TXGEN

class mem_txgen;
  	bit [31:0] ap;
    mem_base_obj mem_obj;//base object
    mem_driver mem_driver;//driver

    integer dim;//how many tests

    function new(virtual mem_interface_input ports);
    begin
        dim = 5;
        mem_driver = new(ports);
    end
    endfunction
  
  	task scenario1();//buffer and reset activated
      begin
        this.dim = 10;
        
        mem_obj.randomize();
        mem_obj.chip_en = 1;
        mem_obj.mode_in = 1;
      end
    endtask
  
  task scenario2(integer op);//push 7 elements in lifo and pop one
    begin        
        mem_obj.randomize();
        mem_obj.chip_en = 4;//LIFO
        mem_obj.mode_in = 4;
      
      	if(op == 0)
      		mem_obj.rw = 2'b01;//write
      	else
        	mem_obj.rw = 2'b10;//read
        
    end
  endtask;
  
  task prepareObj(integer op, integer mode);//push 8 in FIFO, 3 in BUFFER pop 9 in LIFO
    begin        
      	mem_obj.randomize();
      	mem_obj.chip_en = mode;
      	mem_obj.mode_in = mode;
      
      if(op == 0)
        mem_obj.rw = 2'b01;
      else
        mem_obj.rw = 2'b10;
    end
  endtask;
  
  task scenario4();
    begin        

    end
  endtask;
  
  task scenario5();
    begin
      
    end
  endtask;
  
  task generateTransaction(integer scenario);//task that generates values on ports and calls the driver
    begin
        integer index;
      	mem_obj = new();

      
      case(scenario)
      	1:begin
            for(index = 0; index < this.dim; index++)
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                scenario1();
                mem_driver.start(mem_obj);

              end
          end
        
        2:begin
            for(index = 0; index <= 7; index++)
                begin
                  $display();
                  $display("\n\nIteration no. %d", index + 1);
                  scenario2(0);
                  mem_driver.start(mem_obj);
                end
          	$display();
          	//mem_obj.reset = 0;
          	scenario2(1);
          	mem_driver.start(mem_obj);
          
          
          	mem_driver.start(mem_obj);
          $display();
          end
        
        3:begin
          for(index = 0; index <= 8; index++)//push 8 elements in FIFO
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(0,2);//0 -> push, 2 -> FIFO
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index <= 3; index++)//BUFFER 4 values
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(0,1);//0 -> push, 1 -> BUFFER
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index < 20; index++)//pop 20 elements in FIFO
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(1,4);//1 -> pop, 4 -> LIFO
                mem_driver.start(mem_obj);
              end
          end
        
        4:begin//2 elements - empty - full - pop 10
          for(index = 0; index < 2; index++)//push
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(0,2);//0 -> push, 2 -> FIFO
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index < 4; index++)//pop
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(1,4);//1 -> pop, 4 -> LIFO
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index < 70; index++)//push - full
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(0,2);//0 -> push, 2 -> FIFO
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index < 10; index++)//pop 10
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(1,4);//1 -> pop, 4 -> LIFO
                mem_driver.start(mem_obj);
              end
        end
        
        5:begin//buffer -> pop
            for(index = 0; index <= 3; index++)//BUFFER 4 values
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(0,1);//0 -> push, 1 -> BUFFER
                mem_driver.start(mem_obj);
              end
          
          for(index = 0; index <= 3; index++)//pop 4 values
              begin
                $display();
                $display("\n\nIteration no. %d", index + 1);

                prepareObj(1,2);//1 -> pop, 2 -> FIFO
                mem_driver.start(mem_obj);
              end
          end
      endcase
    end
    endtask

endclass


`endif