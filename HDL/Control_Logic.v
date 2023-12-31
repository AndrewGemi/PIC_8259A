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


// Initialization command word 1



always @(*) begin
    // LTIM
    if (ICW1_WRITE == 1'b1)
        Level_OR_Edge_trigger <= internal_bus[3];
    else begin
        Level_OR_Edge_trigger <= Level_OR_Edge_trigger;
    end
end
    // SNGL
always @(*) begin
    if (ICW1_WRITE == 1'b1)
        Single_OR_Cascade <= internal_bus[1];
    else begin
        Single_OR_Cascade <= Single_OR_Cascade;
    end
end
    // IC4
always @(ICW1_WRITE) begin
    if (ICW1_WRITE == 1'b1)
        ICW4_config <= internal_bus[0];
    else
        ICW4_config <= ICW4_config;
end


// Initialization command word 2


// T7-T3 
always @(*) begin
    if (ICW1_WRITE == 1'b1)
        Interrupt_Vector_Address[7:3] <= 3'b000;
    else if (ICW2_WRITE == 1'b1)
        Interrupt_Vector_Address[7:3] <= internal_bus[7:3];
    else
        Interrupt_Vector_Address[7:3] <= Interrupt_Vector_Address[7:3];
end


// Initialization command word 3


// S7-S0 (MASTER) or ID2-ID0 (SLAVE)
always @(*) begin
    if (ICW1_WRITE == 1'b1)
        Cascade_Device_Config <= 8'b00000000;
    else if (ICW3_WRITE == 1'b1)
        Cascade_Device_Config <= internal_bus;
    else
        Cascade_Device_Config <= Cascade_Device_Config;
end


// Initialization command word 4



always @(*) begin
    //Fully nested mode
    if (ICW1_WRITE == 1'b1)
        Fully_nested_config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        Fully_nested_config <= ~internal_bus[4];
    else begin
        Fully_nested_config <= Fully_nested_config;
    end
end

always @(*)begin
    // AEOI
    if (ICW1_WRITE == 1'b1)
        Auto_EOI_Config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        Auto_EOI_Config <= internal_bus[1];
    else begin
        Auto_EOI_Config <= Auto_EOI_Config;
    end
end
always @(*)begin
    // uPM

    if (ICW1_WRITE == 1'b1)
        U8086_OR_MCS80_Config <= 1'b0;
    else if (ICW4_WRITE == 1'b1)
        U8086_OR_MCS80_Config <= internal_bus[0];
    else begin
        U8086_OR_MCS80_Config <= U8086_OR_MCS80_Config;
end
end


//*********  handling flags from OCW commands  *************//

//***** OCW 1 *****//
// handled at IMR module

//***** OCW 2 *****//
    // EOI flag and specific bit
always @(*)begin
        if (ICW1_flag == 1'b1)begin
                EOI = 8'b11111111;
                EOI_flag = 1'b0;
            end    
        else begin
            EOI_bit = 8'b00000000;
            EOI_flag = 1'b0;
        end
end
// AUTOMATIC ROTATE
always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    auto_rotate <= 1'b0;
  end
  else if(OCW2_WRITE == 1'b1) begin
        case(internal_bus[7:5])
        3'b000: auto_rotate <= 1'b0;
        3'b100: auto_rotate <= 1'b1;
        default: auto_rotate <= auto_rotate;
        endcase
  end
  else begin
    auto_rotate <= auto_rotate;
  end
end
// rotate

always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    rotate <= 3'b111;
  end
  else if((auto_rotate == 1'b1) & (EndOfSequence == 1'b1))begin
        if(highest_ISR_bit[0] == 1'b1) rotate = 3'b000;
        else if (highest_ISR_bit[1] == 1'b1) rotate = 3'b001;
        else if (highest_ISR_bit[2] == 1'b1) rotate = 3'b010;
        else if (highest_ISR_bit[3] == 1'b1) rotate = 3'b011;
        else if (highest_ISR_bit[4] == 1'b1) rotate = 3'b100;
        else if (highest_ISR_bit[5] == 1'b1) rotate = 3'b101;
        else if (highest_ISR_bit[6] == 1'b1) rotate = 3'b110;
        else if (highest_ISR_bit[7] == 1'b1) rotate = 3'b111;
        else                        rotate = 3'b111;

  end

  else if(OCW2_WRITE == 1'b1)begin
    if(internal_bus[7:5] == 3'b101)begin
      if(highest_ISR_bit[0] == 1'b1) rotate = 3'b000;
        else if (highest_ISR_bit[1] == 1'b1) rotate = 3'b001;
        else if (highest_ISR_bit[2] == 1'b1) rotate = 3'b010;
        else if (highest_ISR_bit[3] == 1'b1) rotate = 3'b011;
        else if (highest_ISR_bit[4] == 1'b1) rotate = 3'b100;
        else if (highest_ISR_bit[5] == 1'b1) rotate = 3'b101;
        else if (highest_ISR_bit[6] == 1'b1) rotate = 3'b110;
        else if (highest_ISR_bit[7] == 1'b1) rotate = 3'b111;
        else                        rotate = 3'b111;
    end
  end
  else begin
    rotate <= rotate;
  end
end

//******** OCW 3 **********//
//READ IRR OR ISR

always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    RR <= 1'b0;
    ISR_IRR <= 1'b0;
  end
  else if(OCW3_WRITE == 1'b1)begin
    RR <= internal_bus[1];
    ISR_IRR <= internal_bus[0];  // 0 --> IRR , 1 --> ISR
  end
  else begin
    RR <= RR;
    ISR_IRR <= ISR_IRR;
  end
end


// Sending Interrupt vector address to data bus buffer 
// always @(*)begin 
//   if(current_control == IntAck_2)begin
//         if(highest_ISR_bit[0] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b000;
//           else if (highest_ISR_bit[1] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b001;
//           else if (highest_ISR_bit[2] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b010;
//           else if (highest_ISR_bit[3] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b011;
//           else if (highest_ISR_bit[4] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b100;
//           else if (highest_ISR_bit[5] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b101;
//           else if (highest_ISR_bit[6] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b110;
//           else if (highest_ISR_bit[7] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b111;
//           else                         Interrupt_Vector_Address[2:0] = Interrupt_Vector_Address[2:0];
//   end
//   else begin
//     Interrupt_Vector_Address[2:0] <= Interrupt_Vector_Address [2:0];
//   end
// end

always @(*)begin 
  if(current_control == IntAck_2)begin
      if(Single_OR_Cascade == 1'b1)begin
        if(highest_ISR_bit[0] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b000;
          else if (highest_ISR_bit[1] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b001;
          else if (highest_ISR_bit[2] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b010;
          else if (highest_ISR_bit[3] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b011;
          else if (highest_ISR_bit[4] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b100;
          else if (highest_ISR_bit[5] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b101;
          else if (highest_ISR_bit[6] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b110;
          else if (highest_ISR_bit[7] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b111;
          else                         Interrupt_Vector_Address[2:0] = Interrupt_Vector_Address[2:0];
      end
      else begin
        if((MasterOrSlave == 1'b1) & (Slave_enable == 1'b1) )begin
          if(highest_ISR_bit[0] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b000;
          else if (highest_ISR_bit[1] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b001;
          else if (highest_ISR_bit[2] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b010;
          else if (highest_ISR_bit[3] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b011;
          else if (highest_ISR_bit[4] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b100;
          else if (highest_ISR_bit[5] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b101;
          else if (highest_ISR_bit[6] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b110;
          else if (highest_ISR_bit[7] == 1'b1)  Interrupt_Vector_Address[2:0] = 3'b111;
          else                         Interrupt_Vector_Address[2:0] = Interrupt_Vector_Address[2:0];
        end
        else begin
          Interrupt_Vector_Address[2:0] <= Interrupt_Vector_Address[2:0];
        end
      end
  end
  else begin
    Interrupt_Vector_Address[2:0] <= Interrupt_Vector_Address[2:0];
    
  end
end



// Cascade block 
// checking whether this is master or slave 

always @(*)begin
  if((Single_OR_Cascade == 1'b1) || (SP_bar == 1'b1))begin
    MasterOrSlave <= 1'b0;          // master
  end
  else if(SP_bar == 1'b0)begin
    MasterOrSlave <= 1'b1;          // MasterOrSlave = 1 // slave
  end
  else begin
    MasterOrSlave <= MasterOrSlave; // SP = 1 --> master
                                    // SP = 0 --> Slave
  end
end

// Slave signals

always @(*)begin
  if(MasterOrSlave == 1'b0)begin
    Slave_enable <= 1'b0;
    end     //== ICW3 Slave
    else if(Cascade_Device_Config[2:0] == cascade_in)begin
      Slave_enable <= 1'b1;
    end
    else begin
      Slave_enable <= Slave_enable;
    end
  
end 

// Signals for master 

always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    Slave_Interrupt <= 1'b0;
  end                //== ICW3 MASTER
  else if((buffer & Cascade_Device_Config) != 8'b00000000)begin   // buffer is IRR with priority 
    Slave_Interrupt <= 1'b1;
  end
  else begin
    Slave_Interrupt <= Slave_Interrupt;
  end
end


// getting id of slave to send it to slave 
always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    cascade_out <= 3'b000;
  end
  else if(Slave_Interrupt == 1'b1)begin
        if(buffer[0] == 1'b1)  cascade_out = 3'b000;
        else if (buffer[1] == 1'b1)  cascade_out = 3'b001;
        else if (buffer[2] == 1'b1)  cascade_out = 3'b010;
        else if (buffer[3] == 1'b1)  cascade_out = 3'b011;
        else if (buffer[4] == 1'b1)  cascade_out = 3'b100;
        else if (buffer[5] == 1'b1)  cascade_out = 3'b101;
        else if (buffer[6] == 1'b1)  cascade_out = 3'b110;
        else if (buffer[7] == 1'b1)  cascade_out = 3'b111;
        else                         cascade_out = cascade_out;
  end
  else begin
    cascade_out <= cascade_out;
  end
end

// Flag to send out vector address that depends on whether it is Single or Cascade mode

always @(*) begin
  if(Single_OR_Cascade == 1'b0)begin
    if((MasterOrSlave == 1'b1) & (current_control == IntAck_2))begin
        Control_Output <= 1'b1;
    end
    else begin
      Control_Output <= 1'b0;
    end   
  end
  else begin
    if(current_control == IntAck_2)begin
      Control_Output <= 1'b1;
    end
    else begin
      Control_Output <= 1'b0;
    end
  end
end

endmodule
