module Control_Unit(
    input [5:0] opcode,
    output RegDst, ALUSrc, MemtoReg, RegWrite,
    output [1:0] ALUOp
);
    wire is_r = (opcode == 6'b000000);

    assign RegDst   = is_r;
    assign ALUSrc   = 1'b0;
    assign MemtoReg = 1'b0;
    assign RegWrite = is_r;
    assign ALUOp    = is_r ? 2'b10 : 2'b00;
endmodule
