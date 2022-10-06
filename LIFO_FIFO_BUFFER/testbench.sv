`timescale 1ns/1ps
module testRTL();
  
  reg [7:0] x;
  reg [1:0] myMode;
  reg chip_en_lifo;
  reg chip_en_fifo;
  reg chip_en_buffer;
  reg [7:0] din;
  reg push;
  reg pop;
  reg reset;
  
  wire CLK;
  wire empty, full;
  wire [7:0] dout;
    
  Clock clk(CLK);
  
  RTL #(.MEM_SIZE(255)) test_rtl (myMode, chip_en_lifo, chip_en_fifo, chip_en_buffer, din, CLK, push, pop, reset, empty, full, dout);
  
  initial begin

     //LIFO
   	#3 push = 1;
    myMode = 0;
    din = 8'b011;
    chip_en_lifo = 1;
    chip_en_fifo = 0;
    chip_en_buffer = 0;
    
    
    #10 din = 8'b100;
    
    #12 din = 8'b001;
    
    #10 push = 0; 
    #10
    pop = 1;
    
    
    #10 pop = 1;
    #10 pop = 1;
    #10 pop = 1;
    
    
    
    //FIFO
    
    myMode = 1;
    chip_en_fifo = 1;
    chip_en_lifo = 0;
    chip_en_buffer = 0;
    
    #5 reset = 1;
    #5 reset = 0;
    
   	#5 push = 1;
    din = 8'b011;
    
    
    
    #10 din = 8'b100;
    
    #10 din = 8'b001;
    
    #10 push = 0; 
    pop = 1;
    
    
    #10 pop = 1;
    #10 pop = 1;
    #10 pop = 1;
    
    
    //BUFFER
    myMode = 2;
    chip_en_buffer = 1;
    chip_en_fifo = 0;
    chip_en_lifo = 0;
    reset = 1;
    #5 reset = 0;
    
   	#5 din = 8'b101;
    
    
    #10 din = 8'b010;
    #10 din = 0;
    
    //LIFO full
    #10 chip_en_lifo = 1;
    chip_en_fifo = 0;
    chip_en_buffer = 0;
    myMode = 0;
    #5 reset = 1;
    #5 reset = 0;
    
    pop = 0;
    for(x = 1; x < 20; x = x + 1) begin
      #10  din = x;
    	push = 1;
    end
    
   	push = 0;
    for(x = 1; x < 20; x = x + 1) begin
      #10  pop = 1;
      if(x == 10) begin
        chip_en_lifo = 0;
      end
    end
    
    #20 $finish;

  end
  
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule