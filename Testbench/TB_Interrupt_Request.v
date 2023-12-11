/***********************************************************
 * File: TB_Interrupt_Reguest.v
 * Developer: Andrew Gamal Todary
 * Description: Testing Interrupt Request module by testing both edge and level sense
 ************************************************************/

`include "../HDL/Interrupt_Request.v"

module TB_Interrupt_Reguest;

 reg Level_OR_Edge_trigger;
  reg [7:0] Int_Req_Pins;
  wire [7:0] Int_Req_Reg;

  // Instantiate the module under test
  Interrupt_Reguest UUT (
    .Level_OR_Edge_trigger(Level_OR_Edge_trigger),
    .Int_Req_Pins(Int_Req_Pins),
    .Int_Req_Reg(Int_Req_Reg)
  );

  // Initial stimulus
  initial begin
 // Set some initial values
    Level_OR_Edge_trigger = 0;
    Int_Req_Pins = 8'b00000000;

    // Apply stimulus
    //level sense
    #10 Level_OR_Edge_trigger = 1;
    #10 Int_Req_Pins = 8'b10101010;

    #10 Int_Req_Pins = 8'b00000000;
    //edge sense
    #10 Level_OR_Edge_trigger = 0;
    #10 Int_Req_Pins = 8'b01010101;
    #10 Int_Req_Pins = 8'b10101010;

    

    #100 $finish; 
  end

  // Monitor and display results
  always @(*) begin
    $display("Time=%0t Level_OR_Edge_trigger=%b Int_Req_Pins=%b Int_Req_Reg=%b",
             $time, Level_OR_Edge_trigger, Int_Req_Pins, Int_Req_Reg);
  end




endmodule

