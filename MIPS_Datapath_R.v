module MIPS_Datapath_R(
    input clk, reset,
    input [31:0] Instruction, ReadData1, ReadData2,
    output [31:0] PC_Current, ALUResult, RegWriteData,
    output [4:0] WriteRegister,
    output RegWrite
);
    wire RegDst, ALUSrc, MemtoReg, Zero;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;
    wire [31:0] ALU_B_In;

    PC_Register pc_reg (
        .clk(clk), .reset(reset),
        .PC_Next(PC_Current + 32'd4),
        .PC_Current(PC_Current)
    );

    Control_Unit cu (
        .opcode(Instruction[31:26]),
        .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg),
        .RegWrite(RegWrite), .ALUOp(ALUOp)
    );

    Mux2x1_5bit mux_regdst (
        .d0(Instruction[20:16]), .d1(Instruction[15:11]),
        .sel(RegDst), .y(WriteRegister)
    );

    Mux2x1_32bit mux_alusrc (
        .d0(ReadData2), .d1(32'd0),
        .sel(ALUSrc), .y(ALU_B_In)
    );

    ALU_Control alu_ctrl (
        .ALUOp(ALUOp), .funct(Instruction[5:0]), .ALUCtrl(ALUCtrl)
    );

    ALU alu_main (
        .A(ReadData1), .B(ALU_B_In), .ALUCtrl(ALUCtrl),
        .ALUResult(ALUResult), .Zero(Zero)
    );

    Mux2x1_32bit mux_memtoreg (
        .d0(ALUResult), .d1(32'd0),
        .sel(MemtoReg), .y(RegWriteData)
    );
endmodule
