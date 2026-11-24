`timescale 1ns / 1ps

module data_mem #(
    parameter MEM_SIZE = 1024
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        halt,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] Address_In,
    input  wire [31:0] Data_In,
    output wire [31:0] Lectura,
    output wire        dmem_err
);
    reg [7:0] ram [0:MEM_SIZE-1];
    integer i;

    assign dmem_err = (MemRead || MemWrite) &&
                      ((Address_In[1:0] != 2'b00) || (Address_In > (MEM_SIZE - 4)));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                ram[i] <= 8'h00;
            end
        end else if (MemWrite && !halt && !dmem_err) begin
            ram[Address_In]     <= Data_In[31:24];
            ram[Address_In + 1] <= Data_In[23:16];
            ram[Address_In + 2] <= Data_In[15:8];
            ram[Address_In + 3] <= Data_In[7:0];
        end
    end

    assign Lectura = (MemRead && !dmem_err) ?
                     {ram[Address_In], ram[Address_In + 1], ram[Address_In + 2], ram[Address_In + 3]} :
                     32'd0;
endmodule
