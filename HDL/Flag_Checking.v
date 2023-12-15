//
// Variable Declarations
//
reg ICW1_WRITE, ICW2_WRITE, ICW3_WRITE, ICW4_WRITE;
reg [7:0] internal_data_bus;
reg [7:0] Level_OR_Edge_trigger, Single_OR_Cascade_Config, Set_ICW4_Config, Interrupt_Vector_Address, Cascade_Device_Config, Special_Fully_Nest_Config, Auto_EOI_Config, U8086_OR_MCS80_Config;

//
// Initialization command word 1
//

// LTIM
always @* begin
    if (ICW1_WRITE == 1'b1)
        Level_OR_Edge_trigger <= internal_data_bus[3];
    else
        Level_OR_Edge_trigger <= Level_OR_Edge_trigger;
end

// SNGL
always @* begin
    if (ICW1_WRITE == 1'b1)
        Single_OR_Cascade_Config <= internal_data_bus[1];
    else
        Single_OR_Cascade_Config <= Single_OR_Cascade_Config;
end

// IC4
always @* begin
    if (ICW1_WRITE == 1'b1)
        Set_ICW4_Config <= internal_data_bus[0];
    else
        Set_ICW4_Config <= Set_ICW4_Config;
end

//
// Initialization command word 2
//

// A15-A8 (MCS-80) or T7-T3 (8086, 8088)
always @* begin
    if (ICW1_WRITE == 1'b1)
        Interrupt_Vector_Address[10:3] <= 3'b000;
    else if (ICW2_WRITE == 1'b1)
        Interrupt_Vector_Address[10:3] <= internal_data_bus;
    else
        Interrupt_Vector_Address[10:3] <= Interrupt_Vector_Address[10:3];
end

//
// Initialization command word 3
//

// S7-S0 (MASTER) or ID2-ID0 (SLAVE)
always @* begin
    if (ICW1_WRITE == 1'b1)
        Cascade_Device_Config <= 8'b00000000;
    else if (ICW3_WRITE == 1'b1)
        Cascade_Device_Config <= internal_data_bus;
    else
        Cascade_Device_Config <= Cascade_Device_Config;
end

//
// Initialization command word 4
//

// SFNM
always @* begin
    if (ICW1_WRITE == 1'b1)
        Special_Fully_Nest_Config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        Special_Fully_Nest_Config <= internal_data_bus[4];
    else
        Special_Fully_Nest_Config <= Special_Fully_Nest_Config;
end

// AEOI
always @* begin
    if (ICW1_WRITE == 1'b1)
        Auto_EOI_Config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        Auto_EOI_Config <= internal_data_bus[1];
    else
        Auto_EOI_Config <= Auto_EOI_Config;
end

// uPM
always @* begin
    if (ICW1_WRITE == 1'b1)
        U8086_OR_MCS80_Config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        U8086_OR_MCS80_Config <= internal_data_bus[0];
    else
        U8086_OR_MCS80_Config <= U8086_OR_MCS80_Config;
end

 //
    // Operation control word 1
    //

    // IMR
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            interrupt_mask <= 8'b11111111;
        else if (write_initial_command_word_1 == 1'b1)
            interrupt_mask <= 8'b11111111;
        else if ((write_operation_control_word_1_registers == 1'b1) && (special_mask_mode == 1'b0))
            interrupt_mask <= internal_data_bus;
        else
            interrupt_mask <= interrupt_mask;
    end

    // Special mask
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            interrupt_special_mask <= 8'b00000000;
        else if (write_initial_command_word_1 == 1'b1)
            interrupt_special_mask <= 8'b00000000;
        else if (special_mask_mode == 1'b0)
            interrupt_special_mask <= 8'b00000000;
        else if (write_operation_control_word_1_registers  == 1'b1)
            interrupt_special_mask <= internal_data_bus;
        else
            interrupt_special_mask <= interrupt_special_mask;
    end

    //
    // Operation control word 2
    //

    // End of interrupt
    always_comb begin
        if (write_initial_command_word_1 == 1'b1)
            end_of_interrupt = 8'b11111111;
        else if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            end_of_interrupt = acknowledge_interrupt;
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[6:5])
                2'b01:   end_of_interrupt = highest_level_in_service;
                2'b11:   end_of_interrupt = num2bit(internal_data_bus[2:0]);
                default: end_of_interrupt = 8'b00000000;
            endcase
        end
        else
            end_of_interrupt = 8'b00000000;
    end

    // Auto rotate mode
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            auto_rotate_mode <= 1'b0;
        else if (write_initial_command_word_1 == 1'b1)
            auto_rotate_mode <= 1'b0;
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0;
                3'b100:  auto_rotate_mode <= 1'b1;
                default: auto_rotate_mode <= auto_rotate_mode;
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode;
    end

    // Rotate
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            priority_rotate <= 3'b111;
        else if (write_initial_command_word_1 == 1'b1)
            priority_rotate <= 3'b111;
        else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            priority_rotate <= bit2num(acknowledge_interrupt);
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b101:  priority_rotate <= bit2num(highest_level_in_service);
                3'b11?:  priority_rotate <= internal_data_bus[2:0];
                default: priority_rotate <= priority_rotate;
            endcase
        end
        else
            priority_rotate <= priority_rotate;
    end

    //
    // Operation control word 3
    //

