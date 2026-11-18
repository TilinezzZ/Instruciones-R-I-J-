module MIPS_Datapath_I(
    input clk,
    input reset,
    output [31:0] PC_Current,
    output [31:0] Instruction,
    output [31:0] ReadData1,
    output [31:0] ReadData2,
    output [31:0] ALUResult,
    output [31:0] MemReadData,
    output [4:0] WriteRegister,
    output [31:0] RegWriteData,
    output RegWrite,
    output MemWrite,
    output PCSrc
);
    wire RegDst, ALUSrc, MemtoReg, MemRead, Branch, Zero;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;
    wire [31:0] SignExtImm, ShiftedImm, ALU_B_In;
    wire [31:0] PC_Plus4, BranchTarget, PC_Next;

    assign PC_Plus4 = PC_Current + 32'd4;
    assign PCSrc    = Branch & Zero;

    PC_Register pc_reg (
        .clk(clk), .reset(reset),
        .PC_Next(PC_Next),
        .PC_Current(PC_Current)
    );

    Instruction_Memory imem (
        .ReadAddress(PC_Current),
        .Instruction(Instruction)
    );

    Control_Unit cu (
        .opcode(Instruction[31:26]),
        .RegDst(RegDst), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .Branch(Branch), .ALUOp(ALUOp)
    );

    Mux2x1_5bit mux_regdst (
        .d0(Instruction[20:16]), .d1(Instruction[15:11]),
        .sel(RegDst), .y(WriteRegister)
    );

    Register_File reg_file (
        .clk(clk), .RegWrite(RegWrite),
        .ReadReg1(Instruction[25:21]),
        .ReadReg2(Instruction[20:16]),
        .WriteReg(WriteRegister),
        .WriteData(RegWriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    Sign_Extend sign_ext (
        .imm_in(Instruction[15:0]),
        .imm_out(SignExtImm)
    );

    Shift_Left_2 shift_branch (
        .in(SignExtImm),
        .out(ShiftedImm)
    );

    assign BranchTarget = PC_Plus4 + ShiftedImm;

    Mux2x1_32bit mux_pcsrc (
        .d0(PC_Plus4), .d1(BranchTarget),
        .sel(PCSrc), .y(PC_Next)
    );

    Mux2x1_32bit mux_alusrc (
        .d0(ReadData2), .d1(SignExtImm),
        .sel(ALUSrc), .y(ALU_B_In)
    );

    ALU_Control alu_ctrl (
        .ALUOp(ALUOp), .funct(Instruction[5:0]), .ALUCtrl(ALUCtrl)
    );

    ALU alu_main (
        .A(ReadData1), .B(ALU_B_In), .ALUCtrl(ALUCtrl),
        .ALUResult(ALUResult), .Zero(Zero)
    );

    Data_Memory dmem (
        .clk(clk), .MemRead(MemRead), .MemWrite(MemWrite),
        .Address(ALUResult), .WriteData(ReadData2),
        .ReadData(MemReadData)
    );

    Mux2x1_32bit mux_memtoreg (
        .d0(ALUResult), .d1(MemReadData),
        .sel(MemtoReg), .y(RegWriteData)
    );
endmodule
