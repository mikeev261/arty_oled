`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Mike Evans
// 
// Create Date: 01/15/2017 09:34:59 PM
// Design Name: Arty LED Test Control Module
// Module Name: led_ctrl
// Project Name: Arty LED Test 
// Target Devices: Digilient Arty Dev Board
// Tool Versions: Vivado 2016.4
// Description: This module controls the LED's colors and brightness levels. 
// 
// Dependencies: led_top.sv, debounce.sv, Arty_sw_btn_led.xdc (constraints file, 1/1)
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module debounce (
  sclk,
  resetn,
  signal_in, 
  signal_out
  );
  
  parameter WIDTH = 1;
  
  input sclk;
  input resetn;
  input [WIDTH-1:0] signal_in;
  output logic [WIDTH-1:0] signal_out;
  
  logic [WIDTH-1:0] signal_1d; 
  logic [WIDTH-1:0] signal_2d;
  

  always_ff @(posedge sclk) begin
    if(!resetn) begin
      signal_1d <= 'd0;
      signal_2d <= 'd0;
    end 
    else begin
      signal_1d <= signal_in;
      signal_2d <= signal_1d; 
    end   
  end
  
  //1ms = 1000ns
  //Sample the button every 20 ms = 20000ns = 2000 clocks
  logic [10:0] counter; 
   
  always_ff @(posedge sclk) begin
    if(!resetn) counter <= 'd0;
    else counter <= counter + 1'b1; 
  end
  
  wire sample = counter == 2000; 
  
  logic state[WIDTH];
  logic next_state[WIDTH]; 
  
  always_comb begin
    for(int i=0; i<WIDTH; i++) begin
      case(state[i])
        1'b0: begin 
          if(signal_2d[i]) next_state[i] = 1'b1; 
          else next_state[i] = 1'b0;
        end  
        1'b1: begin
          if(!signal_2d[i]) next_state[i] = 1'b0; 
          else next_state[i] = 1'b1; 
        end
      endcase
    end
  end
  
  always_ff @(posedge sclk) begin
    for(int i=0; i<WIDTH; i++) begin
      if(!resetn) state[i] <= 1'b0; 
      else if(sample) state[i] <= next_state[i];   
    end
  end
     
  always_comb begin
    for(int i=0; i<WIDTH; i++) begin
      signal_out[i] = state[i] == 1'b1; 
    end
  end   
  
endmodule
