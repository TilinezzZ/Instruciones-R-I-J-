module Control_Unit(
    input [5:0] opcode,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg Jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        Jump     = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            6'b000000: begin // Tipo R (instrucciones de verificacion)
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            6'b000010: begin // j (Jump incondicional - Opcode 0x02)
                Jump     = 1'b1;
            end
        endcase
    end
endmodule
