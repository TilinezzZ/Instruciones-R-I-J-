// ============================================================================
// Proyecto: Procesador MIPS Monociclo de 32 bits (Datapath Completo)
// Módulo: adder (Sumador combinacional de N bits parametrizado)
// Utilizado para: Sumador PC+4 y Sumador de Branch
// ============================================================================
`timescale 1ns / 1ps

module adder #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] sum
);

    assign sum = a + b;

endmodule
