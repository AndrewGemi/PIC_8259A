/***********************************************************
 * File: In_Service.v
 * Developer: Carol Botros
 * Description: In-Service Register Functions
 ************************************************************/
 
module In_Service (
    // Inputs
    input   wire   [2:0]   rotate,
    input   wire   [7:0]   interrupt_from_priorty_resolver,
    input   wire           In_Service_flag,
    input   wire   [7:0]   EOI,

    // Outputs
    output  reg   [7:0]   in_service_register,
    output  reg   [7:0]   highest_ISR_bit
);


    //
    // In service register
    //
    wire   [7:0]   next_in_service_register;

    assign next_in_service_register = (in_service_register & ~EOI)
                                     | (In_Service_flag == 1'b1 ? interrupt_from_priorty_resolver : 8'b00000000);

    always @(*) begin
            in_service_register <= next_in_service_register;
    end

    //
    // Get Highst level in service
    //
    reg   [7:0]   next_highest_level_in_service;

    always @(*) begin
        next_highest_level_in_service = next_in_service_register;
        next_highest_level_in_service = rotate_right(next_highest_level_in_service, rotate);
        next_highest_level_in_service = resolv_priority(next_highest_level_in_service);
        next_highest_level_in_service = rotate_left(next_highest_level_in_service, rotate);
    end

    always @(*) begin
        
            highest_ISR_bit <= next_highest_level_in_service;
    end


    function reg [7:0] rotate_right (input [7:0] source, input [2:0] rotate);
        case (rotate)
            3'b000:  rotate_right = { source[0],   source[7:1] };
            3'b001:  rotate_right = { source[1:0], source[7:2] };
            3'b010:  rotate_right = { source[2:0], source[7:3] };
            3'b011:  rotate_right = { source[3:0], source[7:4] };
            3'b100:  rotate_right = { source[4:0], source[7:5] };
            3'b101:  rotate_right = { source[5:0], source[7:6] };
            3'b110:  rotate_right = { source[6:0], source[7]   };
            3'b111:  rotate_right = source;
            default: rotate_right = source;
        endcase
    endfunction

    function reg [7:0] rotate_left (input [7:0] source, input [2:0] rotate);
        case (rotate)
            3'b000:  rotate_left = { source[6:0], source[7]   };
            3'b001:  rotate_left = { source[5:0], source[7:6] };
            3'b010:  rotate_left = { source[4:0], source[7:5] };
            3'b011:  rotate_left = { source[3:0], source[7:4] };
            3'b100:  rotate_left = { source[2:0], source[7:3] };
            3'b101:  rotate_left = { source[1:0], source[7:2] };
            3'b110:  rotate_left = { source[0],   source[7:1] };
            3'b111:  rotate_left = source;
            default: rotate_left = source;
        endcase
    endfunction

    function reg [7:0] resolv_priority (input [7:0] request);
        if      (request[0] == 1'b1)    resolv_priority = 8'b00000001;
        else if (request[1] == 1'b1)    resolv_priority = 8'b00000010;
        else if (request[2] == 1'b1)    resolv_priority = 8'b00000100;
        else if (request[3] == 1'b1)    resolv_priority = 8'b00001000;
        else if (request[4] == 1'b1)    resolv_priority = 8'b00010000;
        else if (request[5] == 1'b1)    resolv_priority = 8'b00100000;
        else if (request[6] == 1'b1)    resolv_priority = 8'b01000000;
        else if (request[7] == 1'b1)    resolv_priority = 8'b10000000;
        else                            resolv_priority = 8'b00000000;
    endfunction
endmodule
