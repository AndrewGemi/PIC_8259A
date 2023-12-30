/***********************************************************
 * File: Priority_Resolver.v
 * Developer: Jan Farag Hanna
 ************************************************************/
module PriorityResolver (
    // Inputs from control logic
    input   wire   [2:0]   rotate,
    input   wire   [7:0]   Interrupt_Mask,
    input   wire   [7:0]   highest_level_in_service,

    // Inputs
    input   wire   [7:0]   Int_Req_Reg,
    input   wire   [7:0]   in_service_register,

    // Outputs
    output  wire   [7:0]   interrupt_from_priorty_resolver
);


    //
    // Masked flags
    //
    wire   [7:0]   masked_interrupt_request;
    assign masked_interrupt_request = Int_Req_Reg & ~Interrupt_Mask;

    wire   [7:0]   masked_in_service;
    assign masked_in_service        = in_service_register ;


    //
    // Resolve priority
    //
    wire   [7:0]   rotated_request;
    reg   [7:0]   rotated_in_service;
    reg   [7:0]   priority_mask;
    wire   [7:0]   rotated_interrupt;

    assign rotated_request = rotate_right(masked_interrupt_request, rotate);

    always @(*) begin
        rotated_in_service = rotate_right(masked_in_service, rotate);

    end

    always @(*) begin
        if      (rotated_in_service[0] == 1'b1) priority_mask = 8'b00000000;
        else if (rotated_in_service[1] == 1'b1) priority_mask = 8'b00000001;
        else if (rotated_in_service[2] == 1'b1) priority_mask = 8'b00000011;
        else if (rotated_in_service[3] == 1'b1) priority_mask = 8'b00000111;
        else if (rotated_in_service[4] == 1'b1) priority_mask = 8'b00001111;
        else if (rotated_in_service[5] == 1'b1) priority_mask = 8'b00011111;
        else if (rotated_in_service[6] == 1'b1) priority_mask = 8'b00111111;
        else if (rotated_in_service[7] == 1'b1) priority_mask = 8'b01111111;
        else                                    priority_mask = 8'b11111111;
    end

    assign rotated_interrupt = resolv_priority(rotated_request) & priority_mask;

    assign interrupt_from_priorty_resolver = rotate_left(rotated_interrupt, rotate);

// Function decleration
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

endmodule
