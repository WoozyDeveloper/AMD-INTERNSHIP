`ifndef MEM_BASE_OBJ
`define MEM_BASE_OBJ
/*
	Base object that can be filled with input and output data
*/

class mem_base_obj;
    
    //input data
    rand reg [31:0] Din;
    rand reg [2:0] mode_in;
  constraint c_mode {mode_in inside {1,2,4};}// 1 2 4 

    rand reg [2:0] chip_en;
    constraint c_chip {chip_en == mode_in;}
  
    rand reg [1:0] rw;
  	constraint c_rw {rw > 0;
                     rw < 3;}
    rand reg reset;
  constraint c_reset {reset == 0;}
    
  	reg clk;

    //output data
    reg [31:0] Dout;
    reg full;
    reg empty;
endclass
`endif