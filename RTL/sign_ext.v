`timescale 1ns / 1ps

module sign_ext (
    input  wire [15:0] in,
    input  wire        ZeroExt,
    output wire [31:0] out
);
    assign out = ZeroExt ? {16'd0, in} : {{16{in[15]}}, in};
endmodule
