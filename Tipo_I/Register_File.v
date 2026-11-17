module Register_File(
    input clk,
    input RegWrite,
    input [4:0] ReadReg1,
    input [4:0] ReadReg2,
    input [4:0] WriteReg,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
);
    reg [31:0] registers [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'd0;

        // Valores iniciales del Banco de Registros (Diapositivas 26 y 27)
        registers[7]  = 32'd100;
        registers[8]  = 32'd125;
        registers[9]  = 32'd25;
        registers[10] = 32'd220;
        registers[11] = 32'd96;
        registers[12] = 32'd950;
        registers[13] = 32'd23;
        registers[14] = 32'd20;
        registers[15] = 32'd20;
        registers[16] = 32'd24;
        registers[17] = 32'd28;
    end

    assign ReadData1 = (ReadReg1 == 5'd0) ? 32'd0 : registers[ReadReg1];
    assign ReadData2 = (ReadReg2 == 5'd0) ? 32'd0 : registers[ReadReg2];

    always @(posedge clk) begin
        if (RegWrite && (WriteReg != 5'd0))
            registers[WriteReg] <= WriteData;
    end
endmodule
