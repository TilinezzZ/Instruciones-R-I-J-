module Instruction_Memory(
    input [31:0] ReadAddress,
    output [31:0] Instruction
);
    reg [31:0] memory [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'd0;

        // Programa de prueba Tipo R (opcode = 000000)
        // PC = 0:  add $10, $8, $9   -> 125 + 25 = 150
        memory[0] = 32'b000000_01000_01001_01010_00000_100000;
        // PC = 4:  sub $11, $8, $9   -> 125 - 25 = 100
        memory[1] = 32'b000000_01000_01001_01011_00000_100010;
        // PC = 8:  and $12, $8, $9   -> 125 & 25 = 25
        memory[2] = 32'b000000_01000_01001_01100_00000_100100;
        // PC = 12: or  $13, $8, $9   -> 125 | 25 = 125
        memory[3] = 32'b000000_01000_01001_01101_00000_100101;
        // PC = 16: slt $14, $9, $8   -> (25 < 125) = 1
        memory[4] = 32'b000000_01001_01000_01110_00000_101010;
    end

    // Direccionamiento por palabra (PC avanza de 4 en 4)
    assign Instruction = memory[ReadAddress[7:2]];
endmodule
