# 🖥️ Datapath MIPS Monociclo (Instrucciones Tipo R, I y J)

Este repositorio contiene la implementación estructural en Verilog de la ruta de datos (*Datapath*) monociclo síncrona de un procesador MIPS, desarrollada para el **Seminario de Solución de Problemas de Arquitectura de Computadoras** de la Universidad de Guadalajara (CUCEI).

## 📌 Etapa Actual: Instrucciones Tipo R
Esta versión implementa la ejecución autónoma y síncrona (`posedge clk`) para las operaciones aritmético-lógicas de **formato R** (`ADD`, `SUB`, `AND`, `OR`, `SLT`).

## ⚙️ Arquitectura y Módulos

El diseño combina elementos secuenciales (sincronizados por flanco de subida) y bloques de lógica combinacional:

* **`MIPS_Datapath_R.v`**: Archivo *Top-Level* que interconecta toda la ruta de datos.
* **`PC_Register.v`**: Registro del *Program Counter* que actualiza la dirección de instrucción en cada `posedge clk` o la reinicia a `0` con `reset`.
* **`Instruction_Memory.v`**: Memoria ROM precargada con el programa de prueba en lenguaje máquina (32 bits por instrucción).
* **`Register_File.v`**: Banco de 32 registros de propósito general con lectura combinacional, escritura síncrona en `posedge clk` y valores iniciales precargados (`$7` a `$17`).
* **`Control_Unit.v`**: Unidad de control que activa `RegDst`, `RegWrite` y `ALUOp` (`10`) al detectar el *opcode* de Tipo R (`000000`).
* **`ALU_Control.v`**: Decodificador que interpreta `ALUOp` y el campo `funct` para seleccionar la operación exacta de la ALU.
* **`ALU.v`**: Unidad Lógico Aritmética que ejecuta `ADD`, `SUB`, `AND`, `OR` y `SLT`, además de generar la bandera `Zero`.
* **`Mux2x1_5bit.v` / `Mux2x1_32bit.v`**: Multiplexores para la selección del registro destino (`rd`) y ruteo de datos hacia la ALU y el banco de registros.

## 🛠️ Herramientas Utilizadas
* **Lenguaje:** Verilog HDL
* **Simulador:** ModelSim

## 🚀 Cómo simular el proyecto

1. Clona este repositorio o descarga los archivos `.v` localmente.
2. Crea un nuevo proyecto en **ModelSim** y añade todos los archivos fuente (`.v`).
3. Haz clic derecho en el panel de proyecto y selecciona **Compile > Compile All**.
4. Ve a **Simulate > Start Simulation**, despliega la carpeta `work` y selecciona el banco de pruebas `tb_MIPS_Datapath_R`.
5. Añade las señales (`clk`, `reset`, `PC_Current`, `Instruction`, `ALUResult`, `WriteRegister`) a la ventana gráfica (**Wave**).
6. Ejecuta la simulación escribiendo `run -all` en la consola (*Transcript*).

## 🧪 Pruebas Automatizadas (Testbench)

El archivo `tb_MIPS_Datapath_R.v` genera una señal de reloj con periodo de `10 ns`, aplica un pulso inicial de `reset` y deja correr 5 ciclos de reloj. Con los valores iniciales `$8 = 125` y `$9 = 25`, el procesador ejecuta secuencialmente:

| PC | Instrucción | Operación | Resultado (`ALUResult`) | Registro Destino |
| :--- | :--- | :--- | :---: | :---: |
| `0` | `add $10, $8, $9` | `125 + 25` | `150` | `$10` |
| `4` | `sub $11, $8, $9` | `125 - 25` | `100` | `$11` |
| `8` | `and $12, $8, $9` | `125 & 25` | `25` | `$12` |
| `12` | `or $13, $8, $9` | `125 \| 25` | `125` | `$13` |
| `16` | `slt $14, $9, $8` | `25 < 125` | `1` | `$14` |
