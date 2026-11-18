`timescale 1ns / 1ps

module tb_MIPS_Datapath_J();
    reg clk, reset;
    wire [31:0] PC_Current, Instruction, ReadData1, ReadData2;
    wire [31:0] ALUResult, RegWriteData;
    wire [4:0] WriteRegister;
    wire RegWrite, Jump;

    MIPS_Datapath_J uut (
        .clk(clk), .reset(reset),
        .PC_Current(PC_Current), .Instruction(Instruction),
        .ReadData1(ReadData1), .ReadData2(ReadData2),
        .ALUResult(ALUResult), .WriteRegister(WriteRegister),
        .RegWriteData(RegWriteData), .RegWrite(RegWrite),
        .Jump(Jump)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | PC=%0d | Instr=%h | Jump=%b | ALURes=%0d | Dest=$%0d | RegWr=%b",
                 $time, PC_Current, Instruction, Jump, ALUResult, WriteRegister, RegWrite);

        clk = 0;
        reset = 1;
        #10 reset = 0;

        // Corre 6 ciclos para ver el salto a PC=16 y el autosalto final en PC=20
        #60;
        $finish;
    end
endmodule
