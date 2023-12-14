/***********************************************************
 * File: Read_Write_Logic.v
 * Developer: Andrew Basem 2000261
 * Description: The function of this block is to accept OUTput commands from the CPU. It contains the Initialization
Command Word (ICW) registers and Operation Command Word (OCW) registers which store the various control formats for device operation. This function block also allows the status of the 8259A to be transferred onto the Data Bus.
 ************************************************************/


module Read_Write_Logic(
    input wire [7:0] data_bus_buffer_in,
    output wire [7:0] data_bus_buffer_out,
    inout wire [7:0] internal_bus,

    input wire  chip_select_bar,
    input wire  read_bar,
    input wire  write_bar,
    input wire  A0,

    output wire  ICW_1_flag,
    output wire  ICW_2_flag,
    output wire  ICW_3_flag,
    output wire  ICW_4_flag,
    output wire  OCW_1_flag,
    output wire  OCW_2_flag,
    output wire  OCW_3_flag
);

    assign internal_bus = (~write_bar & ~chip_select_bar) ? data_bus_buffer_in : internal_bus;

    assign data_bus_buffer_out = (~read_bar & ~chip_select_bar) ? internal_bus : 8'bzzzzzzzz;

    assign ICW_1_flag = ~write_bar & ~A0 & internal_bus[4];
    assign ICW_2_flag = ~write_bar & A0;
    assign ICW_3_flag = ~write_bar & ~A0 & ~internal_bus[1] & internal_bus[4];
    assign ICW_4_flag = ~write_bar & A0;
    assign OCW_1_flag = ~write_bar & A0;
    assign OCW_2_flag = ~write_bar & ~A0 & ~internal_bus[3] & ~internal_bus[4];
    assign OCW_3_flag = ~write_bar & ~A0 & internal_bus[3] & ~internal_bus[4];

endmodule