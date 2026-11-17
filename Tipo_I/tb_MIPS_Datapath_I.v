`timescale 1ns / 1ps

module tb_MIPS_Datapath_I();
    reg clk, reset;
    wire [31:0] PC_Current, Instruction, ReadData1, ReadData2;
    wire [31:0] ALUResult, MemReadData, RegWriteData;
    wire [4:0] WriteRegister;
    wire RegWrite, MemWrite, PCSrc;

    MIPS_Datapath_I uut (
        .clk(clk), .reset(reset),
        .PC_Current(PC_Current), .Instruction(Instruction),
        .ReadData1(ReadData1), .ReadData2(ReadData2),
        .ALUResult(ALUResult), .MemReadData(MemReadData),
        .WriteRegister(WriteRegister), .RegWriteData(RegWriteData),
        .RegWrite(RegWrite), .MemWrite(MemWrite), .PCSrc(PCSrc)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | PC=%0d | Instr=%h | ALU=%0d | MemRd=%0d | RegWrData=%0d | Dest=$%0d | PCSrc=%b",
                 $time, PC_Current, Instruction, ALUResult, MemReadData, RegWriteData, WriteRegister, PCSrc);

        clk = 0; reset = 1;
        #10 reset = 0;

        // Ejecuta 5 ciclos activos (lw, sw, beq con salto, slti, addi)
        #50;
        $finish;
    end
endmodule
