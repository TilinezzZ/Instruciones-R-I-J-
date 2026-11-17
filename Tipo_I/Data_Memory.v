module Data_Memory(
    input clk,
    input MemRead,
    input MemWrite,
    input [31:0] Address,
    input [31:0] WriteData,
    output [31:0] ReadData
);
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'd0;

        // Valores iniciales de Memoria de Datos (Diapositivas 26 y 27)
        memory[20] = 32'd500;
        memory[21] = 32'd120;
        memory[22] = 32'd700;
        memory[23] = 32'd45;
        memory[24] = 32'd780;
        memory[25] = 32'd965;
        memory[26] = 32'd345;
        memory[27] = 32'd555;
        memory[28] = 32'd609;
        memory[29] = 32'd201;
        memory[30] = 32'd200;
    end

    // Lectura combinacional
    assign ReadData = MemRead ? memory[Address[7:0]] : 32'd0;

    // Escritura sincrona en flanco de subida
    always @(posedge clk) begin
        if (MemWrite)
            memory[Address[7:0]] <= WriteData;
    end
endmodule
