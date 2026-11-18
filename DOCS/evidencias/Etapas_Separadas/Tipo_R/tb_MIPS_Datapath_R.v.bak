`timescale 1ns / 1ps

module tb_MIPS_Datapath_R();
    reg clk, reset;
    reg [31:0] Instruction, ReadData1, ReadData2;
    wire [31:0] PC_Current, ALUResult, RegWriteData;
    wire [4:0] WriteRegister;
    wire RegWrite;

    MIPS_Datapath_R uut (
        .clk(clk), .reset(reset),
        .Instruction(Instruction), .ReadData1(ReadData1), .ReadData2(ReadData2),
        .PC_Current(PC_Current), .ALUResult(ALUResult), .WriteRegister(WriteRegister),
        .RegWriteData(RegWriteData), .RegWrite(RegWrite)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("T=%0t | PC=%0d | ALURes=%0d | Dest=%0d | RegWrite=%b",
                 $time, PC_Current, ALUResult, WriteRegister, RegWrite);

        clk = 0; reset = 1; Instruction = 0; ReadData1 = 0; ReadData2 = 0;
        #10 reset = 0;

        @(negedge clk); // ADD: 15 + 10 = 25 -> Reg 10
        Instruction = 32'b000000_01000_01001_01010_00000_100000;
        ReadData1 = 32'd15; ReadData2 = 32'd10;

        @(negedge clk); // SUB: 25 - 5 = 20 -> Reg 11
        Instruction = 32'b000000_01000_01001_01011_00000_100010;
        ReadData1 = 32'd25; ReadData2 = 32'd5;

        @(negedge clk); // AND: 12 & 10 = 8 -> Reg 12
        Instruction = 32'b000000_01000_01001_01100_00000_100100;
        ReadData1 = 32'd12; ReadData2 = 32'd10;

        @(negedge clk);
        $finish;
    end
endmodule
