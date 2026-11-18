module MIPS_Datapath_J(
    input clk,
    input reset,
    output [31:0] PC_Current,
    output [31:0] Instruction,
    output [31:0] ReadData1,
    output [31:0] ReadData2,
    output [31:0] ALUResult,
    output [4:0] WriteRegister,
    output [31:0] RegWriteData,
    output RegWrite,
    output Jump
);
    wire RegDst, ALUSrc, MemtoReg, Zero;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;
    wire [27:0] JumpOffset28;
    wire [31:0] PC_Plus4, JumpTarget, PC_Next, ALU_B_In;

    // Calculo de direccion secuencial y concatenacion de salto absoluto
    assign PC_Plus4   = PC_Current + 32'd4;
    assign JumpTarget = {PC_Plus4[31:28], JumpOffset28};

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
        .RegWrite(RegWrite), .Jump(Jump), .ALUOp(ALUOp)
    );

    Shift_Left_2_Jump shift_jump (
        .target_in(Instruction[25:0]),
        .target_out(JumpOffset28)
    );

    Mux2x1_32bit mux_jump (
        .d0(PC_Plus4), .d1(JumpTarget),
        .sel(Jump), .y(PC_Next)
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
