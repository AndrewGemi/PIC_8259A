/***********************************************************
 * File: In_Mask_Reg.v
 * Developer: Andrew Gamal Todary
 * Description: this module is responsible for creating interrupt mask reg 
 ************************************************************/

module In_Mask_Reg(  
  input wire ICW1_WRITE,
  input wire OCW1_WRITE,
  inout wire [7:0] internal_bus,
  output reg [7:0] Interrupt_Mask
);

always @(*)begin
  if(ICW1_WRITE == 1'b1)begin
    Interrupt_Mask <= 8'b11111111;
  end
  else if(OCW1_WRITE == 1'b1) begin
    Interrupt_Mask <= internal_bus; 
  end
  else begin
    Interrupt_Mask <= Interrupt_Mask;
  end
end


endmodule