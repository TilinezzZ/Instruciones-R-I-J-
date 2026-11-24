`timescale 1ns / 1ps

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output reg  [2:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 3'b010; // lw, sw, addi -> ADD
            2'b01: alu_ctrl = 3'b110; // beq          -> SUB
            2'b11: alu_ctrl = 3'b001; // ori          -> OR
            2'b10: begin
                case (funct)
                    6'b100000, 6'b100001: alu_ctrl = 3'b010; // add / addu (funct 20 y 21)
                    6'b100010, 6'b100011: alu_ctrl = 3'b110; // sub / subu (funct 22 y 23)
                    6'b100100: alu_ctrl = 3'b000; // and
                    6'b100101: alu_ctrl = 3'b001; // or
                    6'b101010: alu_ctrl = 3'b111; // slt
                    6'b100111: alu_ctrl = 3'b100; // nor
                    default:   alu_ctrl = 3'b010;
                endcase
            end
            default: alu_ctrl = 3'b010;
        endcase
    end
endmodule
