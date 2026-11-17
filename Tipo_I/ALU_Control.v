module ALU_Control(
    input [1:0] ALUOp,
    input [5:0] funct,
    output reg [3:0] ALUCtrl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUCtrl = 4'b0010; // ADD (lw, sw, addi)
            2'b01: ALUCtrl = 4'b0110; // SUB (beq)
            2'b11: ALUCtrl = 4'b0111; // SLT (slti)
            2'b10: begin              // Tipo R
                case (funct)
                    6'b100000: ALUCtrl = 4'b0010; // ADD
                    6'b100010: ALUCtrl = 4'b0110; // SUB
                    6'b100100: ALUCtrl = 4'b0000; // AND
                    6'b100101: ALUCtrl = 4'b0001; // OR
                    6'b101010: ALUCtrl = 4'b0111; // SLT
                    default:   ALUCtrl = 4'b0000;
                endcase
            end
            default: ALUCtrl = 4'b0000;
        endcase
    end
endmodule
