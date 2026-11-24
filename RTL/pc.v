`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst,
    input  wire        halt,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h00000000;
        end else if (!halt) begin
            pc <= next_pc;
        end
    end
endmodule
