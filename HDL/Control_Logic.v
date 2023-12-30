/***********************************************************
 * File: Control_Logic.v
 * Developer: Andrew Gamal Todary (Interrupt sequence )
              Andrew Basem Ishak (Cascade)
              Carol Botros Wissa (ICWS & OCWS)
 * Description: construction the Brain of PIC 
 ************************************************************/

 module ControlLogic(
    // input flags from R/W logic module 
    input wire ICW1_flag,
    input wire ICW2_flag,
    input wire ICW3_flag,
    input wire ICW4_flag,
    input wire OCW1_flag,
    input wire OCW2_flag,
    input wire OCW3_flag,
    // input wire [7:0] icw1,
    // input wire [7:0] icw2,
    // input wire [7:0] icw3,
    // input wire [7:0] icw4,
    //inputs of PIC
    input wire INTA_bar,
    inout wire [7:0] internal_bus,
    //inputs from priorty resolver
    input wire[7:0] interrupt_from_priorty_resolver,
    //inputs from ISR
    input wire [7:0] highest_ISR_bit,
    input wire SP_bar,
    input wire [2:0] cascade_in,

    output reg [2:0] cascade_out,
    //output to CPU    
    output reg INT_TO_CPU,
    //output to different modules
    output reg Level_OR_Edge_trigger,
    output reg Single_OR_Cascade,
    output reg [7:0] Cascade_Device_Config,
    output reg ICW4_config,
    output reg Auto_EOI_Config,
    output reg U8086_OR_MCS80_Config,
    output reg Fully_nested_config,
    //flag for IRR
    output reg [7:0] Clear_bits_IRR,
    //flag for ISR
    output reg In_Service_flag,
    output reg [7:0] EOI,
    // flags for data bus buffer
    output reg RR,
    output reg ISR_IRR,
    output reg [2:0] rotate,
    output  wire ICW1_WRITE,
    output  wire OCW1_WRITE,
    output wire ICW2_WRITE,
    output wire ICW3_WRITE,
    output wire ICW4_WRITE,
    output reg [7:0] Interrupt_Vector_Address,
    output reg auto_rotate,
    output reg EndOfSequence,
    output reg [1:0] current_control,
    output reg Control_Output
 );

wire OCW2_WRITE,OCW3_WRITE;
reg [1:0] current , next;
//reg ICW4_config;
reg Slave_enable;
reg Slave_Interrupt;
reg MasterOrSlave;
reg negedge_INTA ;
reg posedge_INTA ;
reg prev_INTA;
reg EOI_flag;
reg [7:0] EOI_bit;
reg [7:0] buffer;


//reg Level_OR_Edge_trigger, Single_OR_Cascade,Cascade_Device_Config,Fully_nested_config,Auto_EOI_Config,U8086_OR_MCS80_Config;

reg[1:0]   next_control;

localparam [1:0] ICW2_State = 2'b00,
                ICW3_State = 2'b01,
                ICW4_State = 2'b10,
                READY = 2'b11;

localparam [1:0] IntAck_1 = 2'b00,
                IntAck_2 = 2'b01,
                Ready_Request = 2'b10;



    // FSM for Initializing until controller is ready to accept operations
always @(*)begin
    if(ICW1_flag == 1'b1)begin
      next = ICW2_State;
    end
    else if(ICW2_flag == 1'b1 || ICW3_flag == 1'b1 || ICW4_flag == 1'b1)begin
      case(current)
            ICW2_State: begin
                if(ICW2_WRITE == 1'b1)begin
                if(Single_OR_Cascade == 1'b0) begin
                    next = ICW3_State;
                end
                else if(ICW4_config == 1'b1)begin
                    next = ICW4_State;
                end
                else begin
                    next = READY;
                end
                end
                else begin
                  next = current;
                end

            end

            ICW3_State:begin
                if(ICW3_flag == 1'b1)begin
                    if(ICW4_config == 1'b1)begin
                        next = ICW4_State;
                    end
                    else begin
                    next = READY;
                    end
                end
                else begin
                  next = current;
                end
            end

            ICW4_State:begin
              if(ICW4_flag == 1'b1)begin
                next = READY;
              end
              else begin
                next = current;
              end
            end

            default: begin
              next = READY;
            end
        endcase
    end
    else begin
      next = current;
    end

end

// if nextstate updated then update current
always @(next) begin
    current <= next;
 end
    
// constructing new flags for each state to be sure we are in its state
assign ICW1_WRITE = (ICW1_flag == 1'b1);
assign ICW2_WRITE = (current == ICW2_State) & ICW2_flag  ;
assign ICW3_WRITE = (current == ICW3_State) & ICW3_flag ;
assign ICW4_WRITE = (current == ICW4_State) & ICW4_flag ;


assign OCW1_WRITE = (current == READY) & OCW1_flag ;
assign  OCW2_WRITE = (current == READY) & OCW2_flag ;
assign OCW3_WRITE = (current == READY) & OCW3_flag;


// Handling sequence
// handling positive and negative edge for INTA' 


always @(INTA_bar)begin
  if(prev_INTA & ~INTA_bar) begin       // first edge
    negedge_INTA = 1'b1;
    posedge_INTA = 1'b0;
    prev_INTA = INTA_bar;
  end
  else if(~prev_INTA & INTA_bar)begin   // second edge 
    posedge_INTA = 1'b1;
    negedge_INTA = 1'b0;
    prev_INTA = INTA_bar;
  end
  else begin                            // try again until edge sense 
    prev_INTA <= INTA_bar;
  end

end

reg prev_negedge , INTA_ACK2;
always @(*)begin
  if(ICW1_flag == 1'b1)begin
    prev_negedge <= 1'b0;
    INTA_ACK2 = 1'b0;
  end
  else if(negedge_INTA == 1'b1) begin
    if(prev_negedge == 1'b1)begin
      INTA_ACK2 = 1'b1;
      prev_negedge = 1'b0;
    end
    else begin
      INTA_ACK2 = 1'b0;
      prev_negedge = 1'b1;
    end
    
  end
  else begin
    prev_negedge = prev_negedge;
  end
end

//handling sequence for interrupt to cpu and acknowladge

//Interrupt to CPU
//I get this interrupt from priority resolver after it is done with its job

always @(*)begin
  if(ICW1_WRITE == 1'b1 || (interrupt_from_priorty_resolver == 8'b00000000))begin
    INT_TO_CPU <= 1'b0;
  end
  else if(interrupt_from_priorty_resolver != 8'b00000000)begin
    INT_TO_CPU <= 1'b1;
  end
  else begin
    INT_TO_CPU <= INT_TO_CPU;
  end
end

//FSM for sequence from being ready to accept req to ack 1 then ack 2
always @(*)begin
    case(current_control)
        Ready_Request:begin
        if((INT_TO_CPU == 1'b1) & (negedge_INTA == 1'b1))begin
            next_control <= IntAck_1;
        end
        else begin
            next_control <= Ready_Request;
        end
        end

        IntAck_1: begin
            if(INTA_ACK2 == 1'b1 )begin
            next_control <= IntAck_2;
            end
            else begin
            next_control <= IntAck_1;
            end
        end

        IntAck_2: begin
        if(posedge_INTA == 1'b1 )begin
            next_control <= Ready_Request;
        end
        else begin
            next_control <= IntAck_2;
        end
        end

        default : begin
        next_control <= Ready_Request;
        end
    endcase
end

always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    current_control <= Ready_Request;
  end
  else begin
    current_control <= next_control;
  end
end


// this flag for in service register as to set highest priorty bit at first INTA  
always @(*)begin
  if (ICW1_flag == 1'b1)begin
    In_Service_flag = 1'b0;
  end
  else if((current_control == Ready_Request) & (next_control != Ready_Request))begin
    In_Service_flag = 1'b1;
  end
  else if(current_control == IntAck_2)begin
    In_Service_flag = 1'b0;
  end
  else begin
    In_Service_flag = In_Service_flag;
  end
end



// handling clearbits that will be done on IRR at first INTA && set bit on ISR
always @(*)begin
    if (ICW1_flag == 1'b1)begin
      Clear_bits_IRR <= 8'b11111111;
    end 
    else if(In_Service_flag == 1'b1)begin
      Clear_bits_IRR <= interrupt_from_priorty_resolver;
    end
    else begin
      Clear_bits_IRR <= 8'b00000000;
    end

end

//******** handling end of interrupt sequence depending if it is AEOI or not ***************//

// a flag indicates that interrupt sequence is done after second INTA is set for 1
always @(*)begin
  if (ICW1_flag == 1'b1)begin
    EndOfSequence = 1'b0;
  end
  else if((current_control != Ready_Request) & (next_control == Ready_Request))begin
    EndOfSequence = 1'b1;
  end
  else if(current_control == IntAck_1) begin
    EndOfSequence = 1'b0;
  end
  else begin
    EndOfSequence = EndOfSequence;
  end
end

always @(*)begin
  
   // End of interrupt 
   if(ICW1_flag == 1'b1)begin
     EOI <= 8'b11111111;
   end
   else if((Auto_EOI_Config == 1'b1) &&(EndOfSequence == 1'b1))begin
    EOI <= buffer;
   end
   else if (OCW2_flag == 1'b1 || internal_bus[5] == 1'b1) begin
            EOI_flag = 1'b1;
            case (internal_bus[6:5])
                // NON SPECIFIC EOI
                2'b01:  EOI = highest_ISR_bit;
                // SPECIFIC EOI
                2'b11:  begin
                      case (internal_bus[2:0])
                            3'b000:  EOI = 8'b00000001;
                            3'b001:  EOI = 8'b00000010;
                            3'b010:  EOI = 8'b00000100;
                            3'b011:  EOI = 8'b00001000;
                            3'b100:  EOI = 8'b00010000;
                            3'b101:  EOI = 8'b00100000;
                            3'b110:  EOI = 8'b01000000;
                            3'b111:  EOI = 8'b10000000;
                            default: EOI = 8'b00000000;
                        endcase
                    end
                default: EOI = 8'b00000000;
            endcase
        end 
   else begin
     EOI <= 8'b00000000;
   end

end

//buffer for priority resolver interrupt

always @(*)begin
  if((ICW1_flag == 1'b1) )begin
    buffer <= 8'b00000000;
  end
  else if(In_Service_flag == 1'b1)begin
    buffer <= highest_ISR_bit;
  end
  else begin
    buffer <= buffer;
  end
end




//*********  handling flags from ICW commands  *************//


endmodule





