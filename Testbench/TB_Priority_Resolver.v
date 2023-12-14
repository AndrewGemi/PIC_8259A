/***********************************************************
 * File: TB_Priority_Resolver.v
 * Developer: 
 * Description: 
 ************************************************************/

`include "../HDL/Priority_Resolver.v"


`timescale 1ns/1ns

module tb;

  // Parameters
  parameter PERIOD = 10;

  // Signals
  reg [2:0] priority_rotate;
  reg [7:0] interrupt_mask;
  reg [7:0] interrupt_special_mask;
  reg special_nest_cfg;
  reg [7:0] highest_level_in_service;
  reg [7:0] interrupt_req_reg;
  reg [7:0] in_service_register;
  wire [7:0] interrupt;

  // Instantiate the PriorityResolver module
  PriorityResolver uut (
    .priority_rotate(priority_rotate),
    .interrupt_mask(interrupt_mask),
    .interrupt_special_mask(interrupt_special_mask),
    .special_nest_cfg(special_nest_cfg),
    .highest_level_in_service(highest_level_in_service),
    .interrupt_req_reg(interrupt_req_reg),
    .in_service_register(in_service_register),
    .interrupt(interrupt)
  );

  // Clock generation
  reg clk = 0;
  always #((PERIOD / 2)) clk = ~clk;

  // Testbench stimulus
  initial begin
    // Test Case 1
    priority_rotate = 3'b000;
    interrupt_mask = 8'b00000000;
    interrupt_special_mask = 8'b00000000;
    special_nest_cfg = 1'b0;
    highest_level_in_service = 8'b00000000;
    interrupt_req_reg = 8'b00000000;
    in_service_register = 8'b00000000;
    #PERIOD $display("Test Case 1: interrupt = %b", interrupt);

    // Test Case 2
    priority_rotate = 3'b001;
    interrupt_mask = 8'b11001100;
    interrupt_special_mask = 8'b00110011;
    special_nest_cfg = 1'b1;
    highest_level_in_service = 8'b00001000;
    interrupt_req_reg = 8'b10101010;
    in_service_register = 8'b00000100;
    #PERIOD $display("Test Case 2: interrupt = %b", interrupt);

    // Test Case 3
    priority_rotate = 3'b010;
    interrupt_mask = 8'b01010101;
    interrupt_special_mask = 8'b10101010;
    special_nest_cfg = 1'b0;
    highest_level_in_service = 8'b00000100;
    interrupt_req_reg = 8'b11001100;
    in_service_register = 8'b00110011;
    #PERIOD $display("Test Case 3: interrupt = %b", interrupt);

    // Test Case 4
    priority_rotate = 3'b110;
    interrupt_mask = 8'b11110000;
    interrupt_special_mask = 8'b00001111;
    special_nest_cfg = 1'b1;
    highest_level_in_service = 8'b00000001;
    interrupt_req_reg = 8'b10001000;
    in_service_register = 8'b00000001;
    #PERIOD $display("Test Case 4: interrupt = %b", interrupt);

    // Test Case 5
    priority_rotate = 3'b001;
    interrupt_mask = 8'b11000000;
    interrupt_special_mask = 8'b00001111;
    special_nest_cfg = 1'b0;
    highest_level_in_service = 8'b00000000;
    interrupt_req_reg = 8'b10101010;
    in_service_register = 8'b00000000;
    #PERIOD $display("Test Case 5: interrupt = %b", interrupt);


    #PERIOD $stop;
  end

  // Clock driver
  always #5 clk = ~clk;

endmodule
