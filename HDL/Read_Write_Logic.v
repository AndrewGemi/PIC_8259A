/***********************************************************
 * File: Read_Write_Logic.v
 * Developer: Andrew Basem 2000261
 * Description: The function of this block is to accept OUTput commands from the CPU. It contains the Initialization
Command Word (ICW) registers and Operation Command Word (OCW) registers which store the various control formats for device operation. This function block also allows the status of the 8259A to be transferred onto the Data Bus.
 ************************************************************/


module Read_Write_Logic(
    input wire [7:0] data_bus_buffer_in,
    output wire [7:0] data_bus_buffer_out,
    inout wire [7:0] internal_bus,

    input wire  chip_select_bar,
    input wire  read_bar,
    input wire  write_bar,
    input wire  A0,

    output wire  ICW1_flag,
    output wire  ICW2_flag,
    output wire  ICW3_flag,
    output wire  ICW4_flag,
    output wire  OCW1_flag,
    output wire  OCW2_flag,
    output wire  OCW3_flag
    // output reg[7:0]  icw1,
    // output reg[7:0]  icw2,
    // output reg[7:0]  icw3,
    // output reg[7:0] icw4
);
    // reg prev_ICW2,prev_ICW3,prev_ICW4;
     reg icw4config , icw3config;
    
    assign internal_bus = (~write_bar & ~chip_select_bar) ? data_bus_buffer_in : 8'bzzzzzzzz;

    assign data_bus_buffer_out = (~read_bar & ~chip_select_bar) ? internal_bus[7:0] : 8'bzzzzzzzz;

    assign ICW1_flag = ~write_bar & ~A0 & internal_bus[4];
    assign ICW2_flag = ~write_bar & A0 & ~internal_bus[2] & ~internal_bus[1] & ~internal_bus[0] ;
    assign ICW3_flag = ~write_bar & A0  & (icw3config == 1'b0)  ;
    assign ICW4_flag = ~write_bar & A0 & (icw4config == 1'b1) & ~internal_bus[7] & ~internal_bus[6] & ~internal_bus[5] & ~internal_bus[3] & ~internal_bus[2]  ;
    assign OCW1_flag = ~write_bar & A0;
    assign OCW2_flag = ~write_bar & ~A0 & ~internal_bus[3] & ~internal_bus[4];
    assign OCW3_flag = ~write_bar & ~A0 & internal_bus[3] & ~internal_bus[4];
   
  always @(ICW1_flag)begin
      if(ICW1_flag == 1'b1)begin
      //icw1 <= internal_bus;
        icw3config <= internal_bus[1];
        icw4config <= internal_bus[0];
      end
      else begin
     // icw1 = icw1;
        icw3config = icw3config;
        icw4config = icw4config;
      end
    end
  // always @(*)begin
  //   if(ICW1_flag == 1'b1)begin
  //     prev_ICW3 = 1'b0;
  //   end
  //   else if(ICW3_flag == 1'b1)begin
  //     prev_ICW3 = 1'b1;
  //   end
  //   else begin
  //     prev_ICW3 = prev_ICW3;
  //   end

  // end

  // always @(*)begin
  //   if(ICW1_flag == 1'b1)begin
  //     prev_ICW2 = 1'b0;
  //   end
  //   else if(ICW2_flag == 1'b1)begin
  //     prev_ICW2 = 1'b1;
  //   end
  //   else begin
  //     prev_ICW2 = prev_ICW2;
  //   end

  // end
    

//   always @(write_bar or A0 or internal_bus)begin
//     if (~write_bar & ~A0 & internal_bus[4]) begin
//       ICW1_flag = 1'b1;
//     end
//     else begin
//       ICW1_flag = 1'b0;
//     end
//   end



//   always @(write_bar or A0 or internal_bus)begin
//     if(~write_bar & A0 & ~internal_bus[2] & ~internal_bus[1] & ~internal_bus[0])begin
//       ICW2_flag <= 1'b1 ;
//      // icw2 <= internal_bus;
//     end
//     else begin
//       ICW2_flag <= 1'b0;
//     //  icw2 <= icw2;
//     end
//   end
//   always @(write_bar or A0 or internal_bus)begin
//     if(~write_bar & A0 & (icw3config == 1'b0) &(prev_ICW3 != 1'b1)& (prev_ICW2 == 1'b1))begin
//       ICW3_flag <= 1'b1 ;
//     //  icw3 <= internal_bus;
//     end
//     else begin
//       ICW3_flag <= 1'b0;
//     //  icw3 <= icw3;
//     end
//   end

//   always @(write_bar or A0 or internal_bus)begin
//     if(~write_bar & A0 & (icw4config == 1'b1) & ~internal_bus[7] & ~internal_bus[6] & ~internal_bus[5] & (prev_ICW4 != 1'b1)  & (prev_ICW3 == 1'b1))begin
//       ICW4_flag <= 1'b1 ;
//      // icw4 <= internal_bus;
//     end
//     else begin
//       ICW4_flag <= 1'b0;
//      // icw4 <= icw4;
//     end
//   end

//   always @(write_bar or A0 or internal_bus)begin
     
    
//      OCW1_flag = ~write_bar & A0 ;
//      OCW2_flag = ~write_bar & ~A0 & ~internal_bus[3] & ~internal_bus[4];
//      OCW3_flag = ~write_bar & ~A0 & internal_bus[3] & ~internal_bus[4];
  


//     // if((~write_bar == 1'b1) & (~A0 == 1'b1) & (internal_bus[4] == 1'b1))begin
//     //     ICW1_flag = 1'b1;
//     //     ICW1_flag = 1'b0;
//     //     ICW2_flag = 1'b0;
//     //     ICW3_flag = 1'b0;
//     //     ICW4_flag = 1'b0;
//     // end
//     // else if((~write_bar == 1'b1) & (A0 == 1'b1) & (~internal_bus[2] == 1'b1) & (~internal_bus[1] == 1'b1) & (~internal_bus[0] == 1'b1) )begin
//     //     ICW1_flag = 1'b0;
//     //     ICW2_flag = 1'b1;
//     //     ICW3_flag = 1'b0;
//     //     ICW4_flag = 1'b0;
//     // end
//     // else if((~write_bar == 1'b1) & (A0 == 1'b1) & (prev_ICW3 == 1'b0) & (icw3 == 1'b0))begin
//     //     ICW1_flag = 1'b0;
//     //     ICW2_flag = 1'b0;
//     //     ICW3_flag = 1'b1;
//     //     ICW4_flag = 1'b0;
//     // end
//     // else if((~write_bar == 1'b1) & (A0 == 1'b1) & (~internal_bus[7] == 1'b1) & (~internal_bus[6] == 1'b1) & (~internal_bus[5]== 1'b1)  & (prev_ICW4 == 1'b0) & (icw4 == 1'b1))begin
//     //     ICW1_flag = 1'b0;
//     //     ICW2_flag = 1'b0;
//     //     ICW3_flag = 1'b0;
//     //     ICW4_flag = 1'b1;
//     // end
//     // else begin
//     //     ICW1_flag = ICW1_flag;
//     //     ICW2_flag = ICW2_flag;
//     //     ICW3_flag = ICW3_flag;
//     //     ICW4_flag = ICW4_flag;
//     // end  
//   end

//   // always @(A0 or internal_bus or write_bar)begin
//   //   if (ICW1_flag == 1'b1)begin
//   //     OCW1_flag <= 1'b0;
//   //     OCW2_flag <= 1'b0;
//   //     OCW3_flag <= 1'b0;
//   //   end
//   //   else if(~write_bar & A0 & (prev_ICW4 == 1'b1) )begin
//   //     OCW1_flag = 1'b1;
//   //     OCW2_flag <= 1'b0;
//   //     OCW3_flag <= 1'b0;
//   //   end
//   //   else if(~write_bar & ~A0 & ~internal_bus[3] & ~internal_bus[4])begin
//   //     OCW1_flag = 1'b0;
//   //     OCW2_flag <= 1'b1;
//   //     OCW3_flag <= 1'b0;
//   //   end
//   //   else if(~write_bar & ~A0 & internal_bus[3] & ~internal_bus[4])begin
//   //     OCW1_flag = 1'b0;
//   //     OCW2_flag = 1'b0;
//   //     OCW3_flag <= 1'b1;
//   //   end
//   //   else begin
//   //     OCW1_flag <= OCW1_flag;
//   //     OCW2_flag <= OCW2_flag;
//   //     OCW3_flag <= OCW3_flag;
//   //   end
//   // end



// always @(ICW1_flag or ICW2_flag)begin
//   if(ICW1_flag == 1'b1)begin
//     prev_ICW2 <= 1'b0;
//   end
//   else if(ICW2_flag == 1'b1)begin
//     prev_ICW2 <= 1'b1;
//   end
//   else begin
//     prev_ICW2 <= prev_ICW2;
//   end
// end

// always @(ICW1_flag or ICW3_flag)begin
//   if(ICW1_flag == 1'b1)begin
//     prev_ICW3 <= 1'b0;
//   end
//   else if(ICW3_flag == 1'b1)begin
//     prev_ICW3 <= 1'b1;
//   end
//   else begin
//     prev_ICW3 <= prev_ICW3;
//   end
// end

// always @(ICW1_flag or ICW4_flag)begin
//   if(ICW1_flag == 1'b1)begin
//     prev_ICW4 <= 1'b0;
//   end
//   else if(ICW4_flag == 1'b1)begin
//     prev_ICW4 <= 1'b1;
//   end
//   else begin
//     prev_ICW4 <= prev_ICW4;
//   end
// end

endmodule