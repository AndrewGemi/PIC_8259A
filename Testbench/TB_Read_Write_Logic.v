/***********************************************************
 * File: TB_Read_Write_Logic.v
 * Developer: Andrew Basem 2000261
 * Description: Test for Read_Write_Logic module
 ************************************************************/

`include "../HDL/Read_Write_Logic.v"

module TB_Read_Write_Logic();
  
  reg [7:0] data_bus_buffer_drive;
  reg chip_select_bar, read_bar, write_bar, A0;
  wire [7:0] data_bus_buffer, internal_bus;
  wire ICW_1_flag, ICW_2_flag, ICW_3_flag, ICW_4_flag, OCW_1_flag, OCW_2_flag, OCW_3_flag;


  assign data_bus_buffer[7:0] = {data_bus_buffer_drive[7:0]};

  // Testbench stimulus
  initial begin
    // Initialize inputs
    chip_select_bar = 1'b0;
    read_bar = 1'b1;
    write_bar = 1'b1;
    A0 = 1'b0;
    data_bus_buffer_drive = 8'b00000000; 
    

    #10 write_bar = 1'b0;
    #10 data_bus_buffer_drive = 8'b00010000;
    #10 write_bar = 1'b1;
    
    // Toggle inputs
    #10 chip_select_bar = 1'b1;
    #10 read_bar = 1'b1;

    #10 chip_select_bar = 1'b0;
    #10 read_bar = 1'b0;

    #10 write_bar = 1'b0;
    #10 A0 = 1'b1;
    #10 data_bus_buffer_drive =8'b00000000;

    #10 write_bar = 1'b0;
    #10 A0 = 1'b0;
    #10 data_bus_buffer_drive =8'b00000000;

    #10 A0 = 1'b0;
    #10 data_bus_buffer_drive =8'b00001000;

    #10 write_bar = 1'b1;  //flags are not changed
    #10 A0 = 1'b1;
    #10 A0 = 1'b0;
    
    // Additional test scenarios
    #10 chip_select_bar = 1'b1;
    #10 A0 = 1'b1;
    #10 write_bar = 1'b0;
    #10 write_bar = 1'b1;
    
    #10 chip_select_bar = 1'b0;
    #10 read_bar = 1'b0;
    #10 read_bar = 1'b1;
    #10 write_bar = 1'b0;
    #10 write_bar = 1'b1;
    #10 A0 = 1'b1;
    #10 A0 = 1'b0;
    
    // End simulation
    $finish;
  end
  
  
  Read_Write_Logic RW_tb (
    .data_bus_buffer(data_bus_buffer),
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
  
  
  
  always@ (ICW_1_flag or ICW_2_flag or ICW_3_flag or ICW_4_flag or OCW_1_flag or OCW_2_flag or OCW_3_flag or data_bus_buffer) begin
    // Display output values
    $display("ICW_1_flag = %b", ICW_1_flag);
    $display("ICW_2_flag = %b", ICW_2_flag);
    $display("ICW_3_flag = %b", ICW_3_flag);
    $display("ICW_4_flag = %b", ICW_4_flag);
    $display("OCW_1_flag = %b", OCW_1_flag);
    $display("OCW_2_flag = %b", OCW_2_flag);
    $display("OCW_3_flag = %b", OCW_3_flag);
    $display("data_bus_buffer = %b", data_bus_buffer);
  end
endmodule