`timescale 1ns / 1ps

module tb_programa;
    reg         clk;
    reg         rst;

    wire [31:0] pc_out;
    wire [31:0] instruction;
    wire [4:0]  AR1;
    wire [4:0]  AR2;
    wire [4:0]  AW;
    wire [31:0] DR1;
    wire [31:0] DR2;
    wire [31:0] DW;
    wire        en_BR;
    wire [31:0] alu_result;
    wire        zf;
    wire [31:0] mem_read_data;
    wire [31:0] next_pc;
    wire        halt;

    mips_datapath_top dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction(instruction),
        .AR1(AR1),
        .AR2(AR2),
        .AW(AW),
        .DR1(DR1),
        .DR2(DR2),
        .DW(DW),
        .en_BR(en_BR),
        .alu_result(alu_result),
        .zf(zf),
        .mem_read_data(mem_read_data),
        .next_pc(next_pc),
        .halt(halt)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer ciclos;
    integer c;
    integer i;
    reg [31:0] reg_antes;
    reg [31:0] reg_despues;
    reg [31:0] mem_antes;
    reg [31:0] mem_despues;
    reg [31:0] addr_m;
    reg [4:0]  aw_cap;
    reg [31:0] word_mem;

    initial begin
        if (!$value$plusargs("CICLOS=%d", ciclos)) begin
            ciclos = 200;
        end

        rst = 1;
        #12;
        rst = 0;
        #1;

        for (c = 1; c <= ciclos; c = c + 1) begin
            aw_cap = AW;
            reg_antes = (aw_cap == 5'd0) ? 32'd0 : dut.reg_file_inst.regs[aw_cap];
            addr_m = alu_result;
            if ((addr_m[1:0] == 2'b00) && (addr_m <= 32'd1020)) begin
                mem_antes = {
                    dut.data_mem_inst.ram[addr_m],
                    dut.data_mem_inst.ram[addr_m + 1],
                    dut.data_mem_inst.ram[addr_m + 2],
                    dut.data_mem_inst.ram[addr_m + 3]
                };
            end else begin
                mem_antes = 32'hxxxxxxxx;
            end

            $display("TRZ c=%0d pc=%0d bytes=%08h word=%08h op=%0d rs=%0d rt=%0d rd=%0d shamt=%0d funct=%0d imm=%0d | RegDst=%b ALU_Src=%b ALU_Op=%b MemToReg=%b MemRead=%b MemWrite=%b Branch=%b Jump=%b ZeroExt=%b en_BR=%b | DR1=%08h DR2=%08h ALU=%08h zf=%b MemRd=%08h DW=%08h AW=%0d | nextPC=%0d halt=%b",
                c, pc_out, instruction, instruction,
                instruction[31:26], instruction[25:21], instruction[20:16],
                instruction[15:11], instruction[10:6], instruction[5:0],
                $signed(instruction[15:0]),
                dut.RegDst, dut.ALU_Src, dut.ALU_Op, dut.MemToReg,
                dut.MemRead, dut.MemWrite, dut.Branch, dut.Jump, dut.ZeroExt, en_BR,
                DR1, DR2, alu_result, zf, mem_read_data, DW, AW, next_pc, halt);

            @(posedge clk);
            #1;

            reg_despues = (aw_cap == 5'd0) ? 32'd0 : dut.reg_file_inst.regs[aw_cap];
            if ((addr_m[1:0] == 2'b00) && (addr_m <= 32'd1020)) begin
                mem_despues = {
                    dut.data_mem_inst.ram[addr_m],
                    dut.data_mem_inst.ram[addr_m + 1],
                    dut.data_mem_inst.ram[addr_m + 2],
                    dut.data_mem_inst.ram[addr_m + 3]
                };
            end else begin
                mem_despues = 32'hxxxxxxxx;
            end

            $display("EST c=%0d AW=%0d antes=%08h despues=%08h | mem[%0d] antes=%08h despues=%08h | PC_nuevo=%0d halt=%b",
                c, aw_cap, reg_antes, reg_despues, addr_m, mem_antes, mem_despues, pc_out, halt);
        end

        $display("FINAL_PC=%0d FINAL_HALT=%b", pc_out, halt);
        for (i = 0; i < 32; i = i + 1) begin
            $display("REG %0d=%08h", i, (i == 0) ? 32'd0 : dut.reg_file_inst.regs[i]);
        end
        for (i = 0; i < 1024; i = i + 4) begin
            word_mem = {
                dut.data_mem_inst.ram[i],
                dut.data_mem_inst.ram[i + 1],
                dut.data_mem_inst.ram[i + 2],
                dut.data_mem_inst.ram[i + 3]
            };
            if (word_mem !== 32'd0) begin
                $display("MEM %0d=%08h", i, word_mem);
            end
        end
        $finish;
    end
endmodule
