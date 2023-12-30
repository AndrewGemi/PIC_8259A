/***********************************************************
 * File: PIC8259A.v
 * Developer: Andrew Gamal Todary
 * Description: the top module that connects small modules
 ************************************************************/  

 `include "../HDL/Control_Logic.v"
`include "../HDL/In_Mask_Reg.v"
`include "../HDL/In_Service.v"
`include "../HDL/Interrupt_Request.v"
`include "../HDL/Priority_Resolver.v"
`include "../HDL/Read_Write_Logic.v"

module PIC8259A(
    // Bus
    input   wire           chip_select_bar,
    input   wire           read_bar,
    input   wire           write_bar,
    input   wire           A0,
    input   wire   [7:0]   data_bus_buffer_in,
    output  wire   [7:0]   data_bus_buffer_out,

    // I/O
    input   wire   [2:0]   cascade_in,
    output  wire   [2:0]   cascade_out,
  

    input   wire           SP_bar,
    output  reg           BUF_bar,

    input   wire           INTA_bar,
    output  wire           INT_TO_CPU,

    input   wire   [7:0]   Int_Req_Pins

);
    //inputs and outputs for Read Write Logic module
  wire [7:0] internal_bus ;
  //assign internal_bus = (~write_bar & ~chip_select_bar) ? data_bus_buffer_in : 11'bzzzzzzzzzzz;
    wire [7:0] icw1 ;wire [7:0] icw2 ;wire [7:0] icw3 ;wire [7:0] icw4 ;
    wire ICW1_flag, ICW2_flag, ICW3_flag, ICW4_flag;
    wire  OCW1_flag, OCW2_flag, OCW3_flag;
    wire ICW1_WRITE, OCW1_WRITE,ICW2_WRITE,ICW3_WRITE,ICW4_WRITE;
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
    // .icw1(icw1),
    // .icw2(icw2),
    // .icw3(icw3),
    // .icw4(icw4)
  );


    // Control Logic


    //inputs from priorty resolver
     wire[7:0] interrupt_from_priorty_resolver;
    //inputs from ISR
     wire [7:0] highest_ISR_bit;

    //output to different modules
     wire Level_OR_Edge_trigger;
     wire Single_OR_Cascade;
     wire [7:0] Cascade_Device_Config;
     wire ICW4_config;
     wire Auto_EOI_Config;
     wire U8086_OR_MCS80_Config;
     wire Fully_nested_config;
    //flag for IRR
     wire [7:0] Clear_bits_IRR;
    //flag for ISR
     wire In_Service_flag;
     wire [7:0] EOI;
    // flags for data bus buffer
     wire RR;
     wire ISR_IRR;
     wire [2:0] rotate;
     wire [7:0] Interrupt_Vector_Address;
     wire auto_rotate;
     wire EndOfSequence;
     wire [1:0] current_control;
     wire Control_Output;
    //ControlUnit
    ControlLogic Controllogic(
    // input flags from R/W logic module 
    .ICW1_flag(ICW1_flag),
    .ICW2_flag(ICW2_flag),
    .ICW3_flag(ICW3_flag),
    .ICW4_flag(ICW4_flag),
    .OCW1_flag(OCW1_flag),
    .OCW2_flag(OCW2_flag),
    .OCW3_flag(OCW3_flag),
    // .icw1(icw1),
    // .icw2(icw2),
    // .icw3(icw3),
    // .icw4(icw4),
    //inputs of PIC
    .INTA_bar(INTA_bar),
    .internal_bus(internal_bus),
    //inputs from priorty resolver
    .interrupt_from_priorty_resolver(interrupt_from_priorty_resolver),
    //inputs from ISR
    .highest_ISR_bit(highest_ISR_bit),
    .SP_bar(SP_bar),
    .cascade_in(cascade_in),
    .cascade_out(cascade_out),

    //output to CPU    
    .INT_TO_CPU(INT_TO_CPU),
    //output to different modules
    .Level_OR_Edge_trigger(Level_OR_Edge_trigger),
    .Single_OR_Cascade(Single_OR_Cascade),
    .Cascade_Device_Config(Cascade_Device_Config),
    .ICW4_config(ICW4_config),
    .Auto_EOI_Config(Auto_EOI_Config),
    .U8086_OR_MCS80_Config(U8086_OR_MCS80_Config),
    .Fully_nested_config(Fully_nested_config),
    //flag for IRR
    .Clear_bits_IRR(Clear_bits_IRR),
    //flag for ISR
    .In_Service_flag(In_Service_flag),
    .EOI(EOI),
    // flags for data bus buffer
    .RR(RR),
    .ISR_IRR(ISR_IRR),
    .rotate(rotate),
    .ICW1_WRITE(ICW1_WRITE),
    .ICW2_WRITE(ICW2_WRITE),
    .ICW3_WRITE(ICW3_WRITE),
    .ICW4_WRITE(ICW4_WRITE),
    .OCW1_WRITE(OCW1_WRITE),
    .Interrupt_Vector_Address(Interrupt_Vector_Address),
    .auto_rotate(auto_rotate),
    .EndOfSequence(EndOfSequence),
    .current_control(current_control),
    .Control_Output(Control_Output)
 );

    // IMR
    wire [7:0] Interrupt_Mask;

  In_Mask_Reg IMR (
    .ICW1_WRITE(ICW1_WRITE),
    .OCW1_WRITE(OCW1_WRITE),
    .internal_bus(internal_bus),
    .Interrupt_Mask(Interrupt_Mask)
  );

    // IRR

  wire [7:0] Int_Req_Reg;

  // Instantiate the module under test
  Interrupt_Reguest Irr (
    .Level_OR_Edge_trigger(Level_OR_Edge_trigger),
    .Int_Req_Pins(Int_Req_Pins),
    .Clear_bits_IRR(Clear_bits_IRR),
    .Int_Req_Reg(Int_Req_Reg)
  );


  // Priority Resolver

    // Signals
  wire [7:0] in_service_register;

  // Instantiate the PriorityResolver module
  PriorityResolver Priorityresolver (
    .rotate(rotate),
    .Interrupt_Mask(Interrupt_Mask),
    .Int_Req_Reg(Int_Req_Reg),
    .in_service_register(in_service_register),
    .interrupt_from_priorty_resolver(interrupt_from_priorty_resolver)
  );

    // In service register

    // Instantiate the In_Service module
    In_Service ISR (
        .rotate(rotate),
        .interrupt_from_priorty_resolver(interrupt_from_priorty_resolver),
        .In_Service_flag(In_Service_flag),
        .EOI(EOI),
        .in_service_register(in_service_register),
        .highest_ISR_bit(highest_ISR_bit)
    );
    assign data_bus_buffer_out = (~read_bar & (Control_Output == 1'b1)) ? Interrupt_Vector_Address : 8'bzzzzzzzz;
    assign data_bus_buffer_out = (~read_bar & (RR == 1'b1) & (ISR_IRR == 1'b0)) ? Int_Req_Reg : 8'bzzzzzzzz;
    assign data_bus_buffer_out = (~read_bar & (RR == 1'b1) & (ISR_IRR == 1'b1)) ? in_service_register : 8'bzzzzzzzz;
    assign data_bus_buffer_out = (~read_bar & (A0 == 1'b1)) ? Interrupt_Mask : 8'bzzzzzzzz;

endmodule