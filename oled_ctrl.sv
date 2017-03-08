`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2017 10:44:57 PM
// Design Name: 
// Module Name: oled_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: https://reference.digilentinc.com/_media/reference/pmod/pmodoledrgb/pmodoledrgb_rm.pdf
// 
//////////////////////////////////////////////////////////////////////////////////


module oled_ctrl(
  output [7:0] ja; //Output to the JA Arty board header. 

);

  logic [10:1] ja_pin; //Mapping this to keep things straight and prevent bugs

  assign ja[0] = ja_pin[1];
  assign ja[1] = ja_pin[2];
  assign ja[2] = ja_pin[3];
  assign ja[3] = ja_pin[4];
  assign ja[4] = ja_pin[7];
  assign ja[5] = ja_pin[8];
  assign ja[6] = ja_pin[9];
  assign ja[7] = ja_pin[10];

  assign ja_pin[3] = 1'b0; //NC

  typedef struct {
    logic cs;
    logic mosi;
    logic sclk;
    logic data;
    logic reset;
    logic vcc_en;
    logic pmoden;
  } oled__st;
  
  oled__st oled__s;

  assign ja_pin[1] = oled__s.cs;
  assign ja_pin[2] = oled__s.mosi;
  assign ja_pin[4] = oled__s.sclk;
  assign ja_pin[7] = oled__s.data;
  assign ja_pin[8] = oled__s.reset;
  assign ja_pin[9] = oled__s.vcc_en;
  assign ja_pin[10] = oled__s.pmoden;


endmodule
