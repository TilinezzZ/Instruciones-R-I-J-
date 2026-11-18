module Instruction_Memory(
input [31:0] ReadAddress,
output [31:0] Instruction
);
reg [31:0] memory [0:63];
integer i;

initial begin
    // Inicializar toda la memoria en 0 (nop)
    for (i = 0; i < 64; i = i + 1)
        memory[i] = 32'd0;

    // Cargar las instrucciones desde el archivo externo
    $readmemb("instrucciones.txt", memory);
end

// Direccionamiento por palabra (PC avanza de 4 en 4)
assign Instruction = memory[ReadAddress[7:2]];


endmodule
