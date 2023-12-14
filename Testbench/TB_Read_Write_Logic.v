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

  wire ICW_1_flag, ICW_2_flag, ICW_3_flag, ICW_4_flag, OCW_1_flag, OCW_2_flag, OCW_3_flag;

  // Testbench stimulus
  initial begin
    // Initialize inputs
    chip_select_bar = 1'b0;
    read_bar = 1'b1;
    write_bar = 1'b1;
    A0 = 1'b0;
    

    #10 write_bar = 1'b0;
    #10 data_bus_buffer_in = 8'b00011010;
    #10 write_bar = 1'b1;
    #10 read_bar = 1'b0; //to check value of internal bus

    #10 read_bar = 1'b1;
    #10 write_bar = 1'b0;

    #10 A0 = 1'b1;


    #10 A0 = 1'b0;
    #10 data_bus_buffer_in = 8'b00010000;


    #10 data_bus_buffer_in = 8'b00000000;


    #10 data_bus_buffer_in = 8'b00001000;
    #10

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

    .ICW_1_flag(ICW_1_flag),
    .ICW_2_flag(ICW_2_flag),
    .ICW_3_flag(ICW_3_flag),
    .ICW_4_flag(ICW_4_flag),
    .OCW_1_flag(OCW_1_flag),
    .OCW_2_flag(OCW_2_flag),
    .OCW_3_flag(OCW_3_flag)
  );
  
  
  
    
  always@ (ICW_1_flag or ICW_2_flag or ICW_3_flag or ICW_4_flag or OCW_1_flag or OCW_2_flag or OCW_3_flag or data_bus_buffer_out or internal_bus ) begin
    // Display output values
  $display("Time: %0t, ICW_1_flag=%b, ICW_2_flag=%b, ICW_3_flag=%b, ICW_4_flag=%b, OCW_1_flag=%b, OCW_2_flag=%b, OCW_3_flag=%b, data_bus_buffer_out=%b,internal_bus=%b,read_bar=%b,write_bar=%b,A0=%b",$time, ICW_1_flag, ICW_2_flag, ICW_3_flag, ICW_4_flag, OCW_1_flag, OCW_2_flag, OCW_3_flag, data_bus_buffer_out,internal_bus,read_bar,write_bar,A0);
  end
endmodule

