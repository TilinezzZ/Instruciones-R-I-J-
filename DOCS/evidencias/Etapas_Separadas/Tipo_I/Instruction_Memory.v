module Instruction_Memory(
    input [31:0] ReadAddress,
    output [31:0] Instruction
);
    reg [31:0] memory [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'd0;

        $readmemb("instrucciones.txt", memory);
    end

    assign Instruction = memory[ReadAddress[7:2]];
endmodule
