    //
    // Initialization command word 1
    //

    // LTIM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            level_or_edge_toriggered_config <= internal_data_bus[3];
        else
            level_or_edge_toriggered_config <= level_or_edge_toriggered_config;
    end

    // SNGL
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config;
    end

    // IC4
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config;
    end

    //
    // Initialization command word 2
    //

    // A15-A8 (MCS-80) or T7-T3 (8086, 8088)
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address[10:3] <= 3'b000;
        else if (write_initial_command_word_2 == 1'b1)
            interrupt_vector_address[10:3] <= internal_data_bus;
        else
            interrupt_vector_address[10:3] <= interrupt_vector_address[10:3];
    end

    //
    // Initialization command word 3
    //

    // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            cascade_device_config <= 8'b00000000;
        else if (write_initial_command_word_3 == 1'b1)
            cascade_device_config <= internal_data_bus;
        else
            cascade_device_config <= cascade_device_config;
    end

    //
    // Initialization command word 4
    //

    // SFNM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            special_fully_nest_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            special_fully_nest_config <= internal_data_bus[4];
        else
            special_fully_nest_config <= special_fully_nest_config;
    end

    // AEOI
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_eoi_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1];
        else
            auto_eoi_config <= auto_eoi_config;
    end

    // uPM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            u8086_or_mcs80_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            u8086_or_mcs80_config <= internal_data_bus[0];
        else
            u8086_or_mcs80_config <= u8086_or_mcs80_config;
    end