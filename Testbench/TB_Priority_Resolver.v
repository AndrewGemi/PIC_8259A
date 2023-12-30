/***********************************************************
 * File: TB_Priority_Resolver.v
 * Developer: Jan Farag
 * Description: test bench for Priority Resolver
 ************************************************************/

`include "../HDL/Priority_Resolver.v"


module tb;


  // Signals
  reg [2:0] priority_rotate;
  reg [7:0] interrupt_mask;
  reg [7:0] interrupt_request_register;
  reg [7:0] in_service_register;
  wire [7:0] interrupt;

  // Instantiate the PriorityResolver module
  PriorityResolver uut (
    .priority_rotate(priority_rotate),
    .interrupt_mask(interrupt_mask),
    .interrupt_request_register(interrupt_request_register),
    .in_service_register(in_service_register),
    .interrupt(interrupt)
  );
    initial begin
    priority_rotate = 3'b111;
    interrupt_mask = 8'b00000000;
    interrupt_request_register = 8'b00000000;
    in_service_register = 8'b00000000;
    #10;
    $display("Output : %b ",interrupt);
    #10;
    #10 priority_rotate = 3'b001;
    #10 interrupt_mask = 8'b00000000;
    #10 interrupt_request_register = 8'b00000011;
    #10 in_service_register = 8'b00000010;
    #10;
     $display("Output : %b ",interrupt);
    end


    
  endmodule
