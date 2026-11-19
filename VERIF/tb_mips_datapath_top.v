`timescale 1ns / 1ps

module tb_mips_datapath_top;

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

    // Reloj de 10 ns (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    integer ciclo;

    initial begin
        $display("======================================================================");
        $display(" INICIO SIMULACION MIPS MONOCICLO UNIFICADO (12 INSTR + HALT)");
        $display("======================================================================");

        rst = 1;
        ciclo = 0;
        #12;
        rst = 0;

        // Ejecutar 16 ciclos para recorrer todo el programa y llegar al caso halt
        repeat (16) begin
            @(posedge clk);
            #1;
            ciclo = ciclo + 1;
            $display("Ciclo %2d | PC=%2d (0x%02h) | Instr=0x%08h | AW=$%2d DW=0x%08h (en=%b) | ALU=0x%08h zf=%b | HALT=%b",
                     ciclo, pc_out, pc_out[7:0], instruction, AW, DW, en_BR, alu_result, zf, halt);
        end

        $display("----------------------------------------------------------------------");
        $display(" VERIFICACION FINAL DE REGISTROS Y MEMORIA BIG-ENDIAN:");
        $display("   $8  (addi 10)        = %0d (Esperado: 10)", dut.reg_file_inst.regs[8]);
        $display("   $9  (ori 0x8005)     = 0x%08h (Esperado: 0x00008005 - ZeroExt)", dut.reg_file_inst.regs[9]);
        $display("   $10 (addi 4)         = %0d (Esperado: 4)", dut.reg_file_inst.regs[10]);
        $display("   $11 (add 10+4)       = %0d (Esperado: 14)", dut.reg_file_inst.regs[11]);
        $display("   $12 (sub 10-4)       = %0d (Esperado: 6)", dut.reg_file_inst.regs[12]);
        $display("   $13 (and 10&4)       = %0d (Esperado: 0)", dut.reg_file_inst.regs[13]);
        $display("   $14 (or  10|4)       = %0d (Esperado: 14)", dut.reg_file_inst.regs[14]);
        $display("   $15 (slt 4<10)       = %0d (Esperado: 1)", dut.reg_file_inst.regs[15]);
        $display("   $16 (nor ~(10|4))    = 0x%08h (Esperado: 0xfffffff1)", dut.reg_file_inst.regs[16]);
        $display("   MEM[4..7] Big-Endian = %02h %02h %02h %02h (Esperado: 00 00 80 05)",
                 dut.data_mem_inst.ram[4], dut.data_mem_inst.ram[5],
                 dut.data_mem_inst.ram[6], dut.data_mem_inst.ram[7]);
        $display("   $17 (lw MEM[4])      = 0x%08h (Esperado: 0x00008005)", dut.reg_file_inst.regs[17]);
        $display("   $18 (evadido beq)    = %0d (Esperado: 0)", dut.reg_file_inst.regs[18]);
        $display("   $19 (evadido jump)   = %0d (Esperado: 0)", dut.reg_file_inst.regs[19]);
        $display("   PC congelado en HALT = %0d (Esperado: 60) | HALT = %b (Esperado: 1)", pc_out, halt);
        $display("======================================================================");
        $stop;
    end

endmodule
