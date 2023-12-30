/***********************************************************
 * File: TB_Read_Write_Logic.v
 * Developer: Andrew Basem 2000261
 * Description: Test for Read_Write_Logic module
 ************************************************************/

`include "../HDL/Read_Write_Logic.v"

module TB_Read_Write_Logic();
  
  reg [7:0] data_bus_buffer_in;
  wire [7:0] data_bus_buffer_out;

  reg chip_select_bar, read_bar, write_bar, A0;
  wire [7:0] internal_bus;

  wire ICW1_flag, ICW2_flag, ICW3_flag, ICW4_flag, OCW1_flag, OCW2_flag, OCW3_flag;

  // Testbench stimulus
  initial begin
    // Initialize inputs
    chip_select_bar = 1'b0;
    read_bar = 1'b1;
    write_bar = 1'b1;
    A0 = 1'b0;
    

    #10 write_bar = 1'b0;
    #10 data_bus_buffer_in = 8'b00010001;
    #10 write_bar = 1'b1;
   // #10 read_bar = 1'b0; //to check value of internal bus

    //#10 read_bar = 1'b1;
   // #10 write_bar = 1'b0;

    #10 A0 = 1'b1;


    //#10 A0 = 1'b0;
    #10 data_bus_buffer_in = 8'b10111000;
    #10 write_bar = 1'b0;

    
    #10 data_bus_buffer_in = 8'b00000001;


    #10 data_bus_buffer_in = 8'b00000011;
    #10;

    // End simulation
    $finish;
  end
  
  
  Read_Write_Logic RW_tb (
    .data_bus_buffer_in(data_bus_buffer_in),
    .data_bus_buffer_out(data_bus_buffer_out),
    .internal_bus(internal_bus),

    .chip_select_bar(chip_select_bar),
    .read_bar(read_bar),
    .write_bar(write_bar),
    .A0(A0),

    .ICW1_flag(ICW1_flag),
    .ICW2_flag(ICW2_flag),
    .ICW3_flag(ICW3_flag),
    .ICW4_flag(ICW4_flag),
    .OCW1_flag(OCW1_flag),
    .OCW2_flag(OCW2_flag),
    .OCW3_flag(OCW3_flag)
  );
  
  
  
    
  always@ (ICW1_flag or ICW2_flag or ICW3_flag or ICW4_flag or OCW1_flag or OCW2_flag or OCW3_flag  ) begin
    // Display output values
  $display("Time: %0t, ICW1_flag=%b, ICW2_flag=%b, ICW3_flag=%b, ICW4_flag=%b, OCW1_flag=%b, OCW2_flag=%b, OCW3_flag=%b, data_bus_buffer_out=%b,internal_bus=%b,read_bar=%b,write_bar=%b,A0=%b",$time, ICW1_flag, ICW2_flag, ICW3_flag, ICW4_flag, OCW1_flag, OCW2_flag, OCW3_flag, data_bus_buffer_out,internal_bus,read_bar,write_bar,A0);
  end
endmodule

