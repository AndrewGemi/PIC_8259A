* File: TB_In_Service.v
 * Developer: Carol Botros
 * Description: testbench for in service register
 ************************************************************/

`include "../HDL/In_Service.v"


module tb_In_Service;

    // Signals
    reg [2:0] priority_rotate;
    reg [7:0] interrupt;
    reg In_Service_flag;
    reg [7:0] EOI;

    wire [7:0] in_service_register;
    wire [7:0] highest_level_in_service;

    // Instantiate the In_Service module
    In_Service uut (
        .priority_rotate(priority_rotate),
        .interrupt(interrupt),
        .In_Service_flag(In_Service_flag),
        .EOI(EOI),
        .in_service_register(in_service_register),
        .highest_level_in_service(highest_level_in_service)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        priority_rotate = 3'b001;
        interrupt = 8'b00000010;
        In_Service_flag = 0;
        EOI = 8'b00000000;

        // Apply stimulus and observe outputs
        #10 In_Service_flag = 1;

        #10 $display("highest isr = %b ",highest_level_in_service);
        #10 interrupt = 8'b00000001;
        #10 $display("highest isr = %b ",highest_level_in_service);
        #10 $finish;
    end


endmodule
