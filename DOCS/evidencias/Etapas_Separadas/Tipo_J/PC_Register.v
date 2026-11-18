module PC_Register(
    input clk,
    input reset,
    input [31:0] PC_Next,
    output reg [31:0] PC_Current
);
    always @(posedge clk or posedge reset) begin
        PC_Current <= reset ? 32'd0 : PC_Next;
    end
endmodule
