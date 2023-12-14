/***********************************************************
 * File: Priority_Resolver.v
 * Developer: Jan Farag Hanna
 ************************************************************/
module PriorityResolver (
  input    wire  [2:0]     priority_rotate,
  input    wire  [7:0]     interrupt_mask,
  input    wire  [7:0]     interrupt_special_mask,
  input    wire          special_nest_cfg,
  input    wire  [7:0]     highest_level_in_service,
  input    wire  [7:0]     interrupt_req_reg,
  input    wire  [7:0]     in_service_register,
  output      wire  [7:0]     interrupt
  );

  wire [7:0] masked_int_req;
  assign masked_int_req = interrupt_req_reg & ~interrupt_mask;
  wire [7:0] masked_in_svc;
  assign masked_in_svc = in_service_register & ~interrupt_special_mask;
  wire [7:0] rotated_req;
  reg [7:0] rotated_in_svc;
  wire [7:0] rotated_highest_level_in_service;
  reg [7:0] prio_mask;
  wire [7:0] rotated_int;
  function [7:0] rotate_right;
    input [7:0] src;
    input [2:0] rot;
    casez (rot)
      3'b000: rotate_right = {src[0], src[7:1]};
      3'b001: rotate_right = {src[1:0], src[7:2]};
      3'b010: rotate_right = {src[2:0], src[7:3]};
      3'b011: rotate_right = {src[3:0], src[7:4]};
      3'b100: rotate_right = {src[4:0], src[7:5]};
      3'b101: rotate_right = {src[5:0], src[7:6]};
      3'b110: rotate_right = {src[6:0], src[7]};
      3'b111: rotate_right = src;
      default: rotate_right = src;
    endcase
  endfunction
  assign rotated_req = rotate_right(masked_int_req, priority_rotate);
  assign rotated_highest_level_in_service = rotate_right(highest_level_in_service, priority_rotate);
  always @(*) begin
    rotated_in_svc = rotate_right(masked_in_svc, priority_rotate);
    if (special_nest_cfg == 1'b1)
      rotated_in_svc = (rotated_in_svc & ~rotated_highest_level_in_service) | {rotated_highest_level_in_service[6:0], 1'b0};
  end
  always @(*)
    if (rotated_in_svc[0] == 1'b1)
      prio_mask = 8'b00000000;
    else if (rotated_in_svc[1] == 1'b1)
      prio_mask = 8'b00000001;
    else if (rotated_in_svc[2] == 1'b1)
      prio_mask = 8'b00000011;
    else if (rotated_in_svc[3] == 1'b1)
      prio_mask = 8'b00000111;
    else if (rotated_in_svc[4] == 1'b1)
      prio_mask = 8'b00001111;
    else if (rotated_in_svc[5] == 1'b1)
      prio_mask = 8'b00011111;
    else if (rotated_in_svc[6] == 1'b1)
      prio_mask = 8'b00111111;
    else if (rotated_in_svc[7] == 1'b1)
      prio_mask = 8'b01111111;
    else
      prio_mask = 8'b11111111;
  function [7:0] resolv_priority;
    input [7:0] req;
    if (req[0] == 1'b1)
      resolv_priority = 8'b00000001;
    else if (req[1] == 1'b1)
      resolv_priority = 8'b00000010;
    else if (req[2] == 1'b1)
      resolv_priority = 8'b00000100;
    else if (req[3] == 1'b1)
      resolv_priority = 8'b00001000;
    else if (req[4] == 1'b1)
      resolv_priority = 8'b00010000;
    else if (req[5] == 1'b1)
      resolv_priority = 8'b00100000;
    else if (req[6] == 1'b1)
      resolv_priority = 8'b01000000;
    else if (req[7] == 1'b1)
      resolv_priority = 8'b10000000;
    else
      resolv_priority = 8'b00000000;
  endfunction
  assign rotated_int = resolv_priority(rotated_req) & prio_mask;
  function [7:0] rotate_left;
    input [7:0] src;
    input [2:0] rot;
    casez (rot)
      3'b000: rotate_left = {src[6:0], src[7]};
      3'b001: rotate_left = {src[5:0], src[7:6]};
      3'b010: rotate_left = {src[4:0], src[7:5]};
      3'b011: rotate_left = {src[3:0], src[7:4]};
      3'b100: rotate_left = {src[2:0], src[7:3]};
      3'b101: rotate_left = {src[1:0], src[7:2]};
      3'b110: rotate_left = {src[0], src[7:1]};
      3'b111: rotate_left = src;
      default: rotate_left = src;
    endcase
  endfunction
  assign interrupt = rotate_left(rotated_int, priority_rotate);
endmodule
