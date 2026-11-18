`timescale 1ns / 1ps

module tb_MIPS_Datapath_R();
    reg clk, reset;
    wire [31:0] PC_Current, Instruction, ReadData1, ReadData2, ALUResult, RegWriteData;
    wire [4:0] WriteRegister;
    wire RegWrite;

    MIPS_Datapath_R uut (
        .clk(clk), .reset(reset),
        .PC_Current(PC_Current), .Instruction(Instruction),
        .ReadData1(ReadData1), .ReadData2(ReadData2),
        .ALUResult(ALUResult), .WriteRegister(WriteRegister),
        .RegWriteData(RegWriteData), .RegWrite(RegWrite)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | PC=%0d | Instr=%h | R1=%0d | R2=%0d | ALURes=%0d | Dest=$%0d",
                 $time, PC_Current, Instruction, ReadData1, ReadData2, ALUResult, WriteRegister);

        clk = 0; reset = 1;
        #10 reset = 0;

        // Ejecuta 5 ciclos de reloj (add, sub, and, or, slt)
        #50;
        $finish;
    end
endmodule