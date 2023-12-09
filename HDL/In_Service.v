/***********************************************************
 * File: In_Service.v
 * Developer: Carol Botros
 * Description: In-Service Register Functions
 ************************************************************/

module In_Service (
    input   [2:0]   priority_rotate,
    input   [7:0]   interrupt_special_mask,
    input   [7:0]   interrupt,
    input           latch_in_service,
    input   [7:0]   end_of_interrupt,

    output  reg [7:0]   in_service_register,
    output  reg [7:0]   highest_level_in_service
);
    // In service register
    reg   [7:0]   next_in_service_register;

    always @* begin
        next_in_service_register = (in_service_register & ~end_of_interrupt)
                                   | (latch_in_service ? interrupt : 8'b00000000);
    end

    always @* begin
        in_service_register <= next_in_service_register;
    end

    // Get Highest level in service
    reg   [7:0]   next_highest_level_in_service;

    always @* begin
        next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;
        next_highest_level_in_service = next_highest_level_in_service >> priority_rotate;
        // Additional processing as needed
    end

    always @* begin
        highest_level_in_service <= next_highest_level_in_service;
    end

endmodule
