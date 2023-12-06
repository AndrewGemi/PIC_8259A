/***********************************************************
 * File: TB_In_Mask_Reg.v
 * Developer: 
 * Description: 
 ************************************************************/

`include "../HDL/In_Mask_Reg.v"

module TB_In_Mask_Reg();

  reg write_ICW_1;
  reg write_OCW_1;
  reg [7:0] Internal_bus_data;
  wire [7:0] Interrupt_Mask;

  // Instantiate the module under test
  In_Mask_Reg UUT (
    .write_ICW_1(write_ICW_1),
    .write_OCW_1(write_OCW_1),
    .Internal_bus_data(Internal_bus_data),
    .Interrupt_Mask(Interrupt_Mask)
  );

  // Initial stimulus
  initial begin
    // Set some initial values
    write_ICW_1 = 0;
    write_OCW_1 = 0;
    Internal_bus_data = 8'b00000000;

    // Apply stimulus
    #10 write_ICW_1 = 1;
    #10 write_ICW_1 = 0;

    #10 write_OCW_1 = 1;
    #10 Internal_bus_data = 8'b10101010;
    #10 write_OCW_1 = 0;

    // Add more test cases as needed

    #100 $finish; // End simulation
  end

  // Monitor and display results
  always @* begin
    $display("Time=%0t write_ICW_1=%b write_OCW_1=%b Internal_bus_data=%b Interrupt_Mask=%b",
             $time, write_ICW_1, write_OCW_1, Internal_bus_data, Interrupt_Mask);
  end

endmodule