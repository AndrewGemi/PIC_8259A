/***********************************************************
 * File: Interrupt_Reguest.v
 * Developer: Andrew Gamal Todary
 * Description: This module fill IRQ register depending on level or edge trigger
 ************************************************************/

module Interrupt_Reguest( 
    input wire Level_OR_Edge_trigger,
    input wire [7:0] Int_Req_Pins,
    output reg [7:0] Int_Req_Reg);

    reg [7:0] prev_Int_req_pins;
    localparam edgeconfig = 1'b0;
    localparam levelconfig = 1'b1;


    // Reading pins signal depending on level or edge configuration
    genvar ir_bit_no;
    generate
        for(ir_bit_no = 0 ; ir_bit_no <=7 ; ir_bit_no = ir_bit_no + 1)
        begin

            always @(Int_Req_Pins) begin
                case(Level_OR_Edge_trigger)
                   
                    edgeconfig:begin
                        if((~prev_Int_req_pins[ir_bit_no]) & Int_Req_Pins[ir_bit_no])
                        begin
                            Int_Req_Reg[ir_bit_no] <= Int_Req_Pins[ir_bit_no];
                        end
                        else begin
                          prev_Int_req_pins[ir_bit_no] = Int_Req_Pins[ir_bit_no];
                          Int_Req_Reg[ir_bit_no] <= 1'b0;
                        end
                    end

                    levelconfig:begin
                        if(Int_Req_Pins[ir_bit_no] == 1'b1 || Int_Req_Pins[ir_bit_no] == 1'b0)begin
                          Int_Req_Reg [ir_bit_no] <= Int_Req_Pins[ir_bit_no];
                        end
                        else begin
                          Int_Req_Reg [ir_bit_no] <= Int_Req_Reg[ir_bit_no] ;
                        end
                    end

                endcase

            end
        
        end
    endgenerate
endmodule

