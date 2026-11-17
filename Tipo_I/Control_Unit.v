module Control_Unit(
    input [5:0] opcode,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg [1:0] ALUOp
);
    always @(*) begin
        // Valores por defecto
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            6'b000000: begin // Tipo R (compatibilidad)
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            6'b100011: begin // lw (Load Word)
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b101011: begin // sw (Store Word)
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b000100: begin // beq (Branch on Equal)
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            6'b001000: begin // addi (Add Immediate)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b001010: begin // slti (Set on Less Than Immediate)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end
        endcase
    end
endmodule
