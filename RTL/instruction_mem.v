`timescale 1ns / 1ps

module instruction_mem #(
    parameter MEM_SIZE = 1024
)(
    input  wire [31:0] addr,
    output wire [31:0] instruction,
    output wire        imem_err
);
    reg [7:0] rom [0:MEM_SIZE-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            rom[i] = 8'h00;
        end
        $readmemh("programa.hex", rom);
    end

    assign imem_err = (addr[1:0] != 2'b00) || (addr > (MEM_SIZE - 4));

    assign instruction = imem_err ? 32'h00000000 :
                         {rom[addr], rom[addr + 1], rom[addr + 2], rom[addr + 3]};
endmodule
