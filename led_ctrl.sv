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

module led_ctrl(
  input resetn,
  input sclk,
  input [3:0] sw,
  input [3:0] btn,
  output logic [3:0] led,
  output logic led0_r,
  output logic led0_g,
  output logic led0_b,
  output logic led1_r,
  output logic led1_g,
  output logic led1_b,
  output logic led2_r,                    
  output logic led2_g,
  output logic led2_b,
  output logic led3_r,                    
  output logic led3_g,
  output logic led3_b    
);


/*
    wire [3:0] led_temp = sw | btn;
    always_ff @(posedge sclk) begin
      led <= led_temp;
    end
*/
  
  typedef struct packed{
    logic r;
    logic g;
    logic b;
  } color_led__st;
  
  color_led__st color_led__s[4];
  color_led__st color_led_duty_cycled__s[4];
  
  color_led__st red__s;
  color_led__st green__s;
  color_led__st blue__s; 
  
  color_led__st purple__s; 
  color_led__st yellow__s;
  color_led__st cyan__s; 
  
  assign red__s     = color_led__st'{1'b1, 1'b0, 1'b0};
  assign green__s   = color_led__st'{1'b0, 1'b1, 1'b0};
  assign blue__s    = color_led__st'{1'b0, 1'b0, 1'b1}; 
  assign purple__s  = color_led__st'{1'b1, 1'b0, 1'b1};
  assign yellow__s  = color_led__st'{1'b1, 1'b1, 1'b0}; 
  assign cyan__s    = color_led__st'{1'b0, 1'b1, 1'b1};
  
  assign {led0_r, led0_g, led0_b} = {color_led_duty_cycled__s[0].r, color_led_duty_cycled__s[0].g, color_led_duty_cycled__s[0].b};  
  assign {led1_r, led1_g, led1_b} = {color_led_duty_cycled__s[1].r, color_led_duty_cycled__s[1].g, color_led_duty_cycled__s[1].b};
  assign {led2_r, led2_g, led2_b} = {color_led_duty_cycled__s[2].r, color_led_duty_cycled__s[2].g, color_led_duty_cycled__s[2].b};
  assign {led3_r, led3_g, led3_b} = {color_led_duty_cycled__s[3].r, color_led_duty_cycled__s[3].g, color_led_duty_cycled__s[3].b};
  
  logic button_status[4];
  logic button_toggled[4];  
  
  always_ff @(posedge sclk) begin
    for(int i = 0; i < 4; i++) begin
      if(button_toggled[i]) begin
        button_status[i] <= 1'b0;
        button_toggled[i] <= 1'b0;
      end
      else if(btn[i]) begin //Initial push 
        button_status[i] <= 1'b1;
        button_toggled[i] <= 1'b0;  
      end
      else if(!btn[i] && button_status[i]) begin
        button_status[i] <= 1'b0; 
        button_toggled[i] <= 1'b1; 
      end
    end
  end
  
  parameter RED     = 3'd0;
  parameter GREEN   = 3'd1; 
  parameter BLUE    = 3'd2; 
  parameter PURPLE  = 3'd3; 
  parameter YELLOW  = 3'd4; 
  parameter CYAN    = 3'd5; 

  logic [2:0] color_state[4];
  logic [2:0] next_color_state[4];
  
  always_comb begin
    for(int i = 0; i < 4; i++) begin   
      unique case (color_state[i]) 
        RED: begin 
          color_led__s[i] = red__s; 
          next_color_state[i] = GREEN;
        end 
        GREEN: begin
          color_led__s[i] = green__s;
          next_color_state[i] = BLUE;
        end
        BLUE: begin
          color_led__s[i] = blue__s;  
          next_color_state[i] = PURPLE;
        end
        PURPLE: begin
          color_led__s[i] = purple__s;
          next_color_state[i] = YELLOW;
        end 
        YELLOW: begin
          color_led__s[i] = yellow__s;
          next_color_state[i] = CYAN;
        end
        CYAN: begin
          color_led__s[i] = cyan__s; 
          next_color_state[i] = RED;
        end  
        default: begin 
          color_led__s[i] = 'dx;
          next_color_state[i] = 'dx;
        end 
      endcase
    end
  end
  
  always_ff @(posedge sclk) begin
    for(int i = 0; i < 4; i++) begin   
      if(!resetn) begin
        color_state[i] <= 3'd0; 
      end
      else if (button_toggled[i]) begin
        color_state[i] <= next_color_state[i]; 
      end 
    end
  end
  
  logic [3:0] clk_counter; 
  
  always_ff @(posedge sclk) begin
      if(!resetn) clk_counter <= 'd0; 
      else clk_counter <= clk_counter + 1'b1; //Counts 0-15. Intentional roll-over. 
  end
    
  //We need an exponential curve on our output to make the brightness controls more effective. 
  //The curve we want is approx 1.2^x. 
  //Cheapest way to do this is with a table, below
  
  logic [3:0] sw_exp; 
  
  always_comb begin
    unique case (sw)
      'd15: sw_exp = 'd15;
      'd14: sw_exp = 'd12;
      'd13: sw_exp = 'd10; 
      'd12: sw_exp = 'd8; 
      'd11: sw_exp = 'd6; 
      'd10: sw_exp = 'd5; 
      'd9: sw_exp = 'd4; 
      'd8, 'd7: sw_exp = 'd3;  
      'd6, 'd5: sw_exp = 'd2;  
      'd4, 'd3, 'd2, 'd1: sw_exp = 'd1;  
      'd0: sw_exp = 'd0;        
    endcase
  end
  
  always_ff @(posedge sclk) begin
    for(int i = 0; i < 4; i++) begin         
      if(!resetn) begin
        color_led_duty_cycled__s[i].r <= 1'b1;
        color_led_duty_cycled__s[i].g <= 1'b0;
        color_led_duty_cycled__s[i].b <= 1'b1;  
      end
      else if(clk_counter < sw_exp) begin
        color_led_duty_cycled__s[i].r <= color_led__s[i].r | btn[i];
        color_led_duty_cycled__s[i].g <= color_led__s[i].g | btn[i];
        color_led_duty_cycled__s[i].b <= color_led__s[i].b | btn[i];                 
      end
      else begin
        color_led_duty_cycled__s[i].r <= 1'b0;
        color_led_duty_cycled__s[i].g <= 1'b0;
        color_led_duty_cycled__s[i].b <= 1'b0;                 
      end
    end
  end      
endmodule
