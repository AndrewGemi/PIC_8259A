/***********************************************************
 * File: In_Mask_Reg.v
 * Developer: 
 * Description: 
 ************************************************************/

module In_Mask_Reg(  
  input wire write_ICW_1,
  input wire write_OCW_1,
  input wire [7:0] Internal_bus_data,
  output reg [7:0] Interrupt_Mask
);

always @(*)begin
  if(write_ICW_1 == 1'b1)begin
    Interrupt_Mask <= 8'b11111111;
  end
  else if(write_OCW_1 == 1'b1) begin
    Interrupt_Mask <= Internal_bus_data; 
  end
  else begin
    Interrupt_Mask <= Interrupt_Mask;
  end
end


endmodule