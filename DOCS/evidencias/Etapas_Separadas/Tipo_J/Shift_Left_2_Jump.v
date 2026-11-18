module Shift_Left_2_Jump(
    input [25:0] target_in,
    output [27:0] target_out
);
    assign target_out = {target_in, 2'b00};
endmodule
