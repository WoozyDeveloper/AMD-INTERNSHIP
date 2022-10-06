`timescale 1ns/1ps

/*
	dout - 0 LIFO
    	 - 1 FIFO
         - 2 BUFFER
         - 3 OTHER
         
    Modulul e responsabil cu verificarea corespondentei dintre mode si chip_en pt lifo/fifo/buffer
*/
module DECISION (input [1:0] myMode, input reset, input clk, input chip_en_lifo, input chip_en_fifo, input chip_en_buffer, output reg[1:0] dout);
 
  
  localparam LIFO = 0;
  localparam FIFO = 1;
  localparam BUFFER = 2;
  
  
  localparam OTHER = 3;// ca sa setez dout pe altceva
  
  reg [1:0] mode;//registrul intern pt modul de functionare
  
  always @(myMode or chip_en_lifo or chip_en_fifo or chip_en_buffer) begin
    mode = myMode;//updatez mode-ul intern
    if(!chip_en_lifo & !chip_en_fifo & !chip_en_buffer) begin//daca toate sunt 0 => nu pot avea vreun comportament din LIFO/FIFO/BUFFER asa ca setez dout pe OTHER
      dout = OTHER;
    end
    
    //verific corespondentele intre registrul meu si valoarea fiecarui flag pt LIFO/FIFO/BUFFER
    if(myMode == LIFO && chip_en_lifo) begin
      $display("lifo");
      dout = LIFO;
    end
    if(myMode == FIFO && chip_en_fifo) begin
      $display("fifo");
	  dout = FIFO;
    end
    if(myMode == BUFFER && chip_en_buffer) begin
      $display("buffer");
	  dout = BUFFER;
    end
  end
endmodule


module RTL #(parameter MEM_SIZE = 255)//MEM_SIZE - valoarea maxima de numere ce o poate avea un LIFO/FIFO
  (input [1:0] myMode, input chip_en_lifo, input chip_en_fifo, input chip_en_buffer, input [7:0] din, input clk, input push, input pop, input reset, output reg empty, output reg full, output reg [7:0] dout);
  
  reg [7:0] index, i;
  
  reg [7:0] maxMem = 15;//valoarea maxima setata de noi (15 'blocuri' din 255)
  reg [3:0] currentDim = 0;//dimensiunea curenta a memoriei
  reg [7:0] memory[MEM_SIZE:0];
  
  localparam LIFO = 0;
  localparam FIFO = 1;
  localparam BUFFER = 2;
  
  wire [1:0] final_mode;//aici salvam valoarea care vine de pe output de la modulul DECISION
  DECISION dec(myMode, reset, clk, chip_en_lifo, chip_en_fifo, chip_en_buffer, final_mode);

  
  //reset sincron unde setam iesirile, dimensiunea curenta si memoria pe 0
  always @(posedge reset) begin
    dout <= 0;
    currentDim <= 0;
    for(index = 0; index < maxMem; index = index + 1) begin
      memory[index] <= 0;
    end
    empty <= 0;
    full <= 0;
  end
  
  always @(posedge clk) begin
    
    //afisarea memoriei
    $display("MEM DOWN");
      for(i = 0; i < maxMem; i = i + 1) begin
        $display((i + 1), " ", memory[i]);
      end
    
    //daca modul este buffer, output = input
    if(final_mode == BUFFER) begin
      dout <= din;
    end
    else begin
      if(push) begin// PUSH
        if(currentDim < maxMem) begin//verificam sa ne incadram in limita de spatii setata in maxMem
          //daca intram aici inseamna ca inca putem adauga valori => full = 0
          //fiind in push => avem cel putin o valoare in memory => empty = 0
          full <= 0;
          empty <= 0;
          if(final_mode == LIFO) begin// LIFO/stiva
          	memory[currentDim] <= din;   
          end
          else if(final_mode == FIFO) begin// FIFO/coada
            memory[currentDim] <= din;
          end
          currentDim = currentDim + 1;//crestem cu 1 dimensiunea curenta (pt ca am dat un push)
        end
        else begin//daca currentDim >= maxMem => memory full
          full <= 1;  
        end
      end
      else if(pop) begin// POP
        if(currentDim > 0) begin
          //la fel ca la push
          full <= 0;
		  empty <= 0;
          if(final_mode == LIFO) begin// LIFO/stiva
            dout <= memory[currentDim - 1];
            memory[currentDim - 1] <= 0;
            currentDim <= currentDim - 1;
          end

          else if(final_mode == FIFO) begin// FIFO/coada
            dout <= memory[0];
            for(index = 0; index < maxMem - 1; index = index + 1) begin
              memory[index] <= memory[index + 1];
            end
            currentDim <= currentDim - 1;
          end
        end
        else begin//empty
          empty <= 1;
        end
      end
    end
  end
  
endmodule

module Clock(output c);
  reg val;
  assign c = val;
  initial
    val = 0;
  always
    #5 val = ~val;
endmodule