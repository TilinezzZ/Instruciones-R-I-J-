vlib work
vmap work work

vlog ../RTL/*.v
vlog tb_mips_datapath_top.v

vsim -voptargs="+acc" work.tb_mips_datapath_top

add wave -divider "Reloj y Control General"
add wave -radix binary /tb_mips_datapath_top/clk
add wave -radix binary /tb_mips_datapath_top/rst
add wave -radix binary /tb_mips_datapath_top/halt

add wave -divider "Fetch e Instruccion"
add wave -radix unsigned /tb_mips_datapath_top/pc_out
add wave -radix unsigned /tb_mips_datapath_top/next_pc
add wave -radix hexadecimal /tb_mips_datapath_top/instruction

add wave -divider "Banco de Registros"
add wave -radix unsigned /tb_mips_datapath_top/AR1
add wave -radix unsigned /tb_mips_datapath_top/AR2
add wave -radix unsigned /tb_mips_datapath_top/AW
add wave -radix hexadecimal /tb_mips_datapath_top/DR1
add wave -radix hexadecimal /tb_mips_datapath_top/DR2
add wave -radix hexadecimal /tb_mips_datapath_top/DW
add wave -radix binary /tb_mips_datapath_top/en_BR

add wave -divider "ALU y Memoria de Datos"
add wave -radix hexadecimal /tb_mips_datapath_top/alu_result
add wave -radix binary /tb_mips_datapath_top/zf
add wave -radix hexadecimal /tb_mips_datapath_top/mem_read_data

run -all
wave zoom full
