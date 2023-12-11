/***********************************************************
 * File: TB_In_Service.v
 * Developer: 
 * Description: 
 ************************************************************/

`include "../HDL/In_Service.v"

`timescale 1ns / 1ns

module tb_In_Service;

    // Parameters
    parameter CLOCK_PERIOD = 10; // Clock period in nanoseconds

    // Signals
    reg [2:0] priority_rotate;
    reg [7:0] interrupt_special_mask;
    reg [7:0] interrupt;
    reg latch_in_service;
    reg [7:0] end_of_interrupt;

    wire [7:0] in_service_register;
    wire [7:0] highest_level_in_service;

    // Instantiate the In_Service module
    In_Service uut (
        .priority_rotate(priority_rotate),
        .interrupt_special_mask(interrupt_special_mask),
        .interrupt(interrupt),
        .latch_in_service(latch_in_service),
        .end_of_interrupt(end_of_interrupt),
        .in_service_register(in_service_register),
        .highest_level_in_service(highest_level_in_service)
    );

    // Clock generation
    reg clk = 0;
    always #((CLOCK_PERIOD)/2) clk =~clk;

    // Test stimulus
    initial begin
        // Initialize inputs
        priority_rotate = 3'b001;
        interrupt_special_mask = 8'b11000000;
        interrupt = 8'b00110011;
        latch_in_service = 0;
        end_of_interrupt = 8'b00000001;

        // Apply stimulus and observe outputs
        #10 latch_in_service = 1;
        #10 latch_in_service = 0;
        #10 $finish;
    end

    // Clock driver
    always #((CLOCK_PERIOD)/2) clk = ~clk;

endmodule
