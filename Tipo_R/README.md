# 🖥️ Datapath MIPS Monociclo (Instrucciones Tipo R, I y J)

Este repositorio contiene la implementación estructural en Verilog de la ruta de datos (*Datapath*) monociclo síncrona de un procesador MIPS de 32 bits, desarrollada para el **Seminario de Solución de Problemas de Arquitectura de Computadoras** de la Universidad de Guadalajara (CUCEI).

## 📌 Estado del Proyecto

* ✅ **Instrucciones Tipo R:** Completado y simulado (`add`, `sub`, `and`, `or`, `slt`).
* ✅ **Instrucciones Tipo I:** Completado y simulado (`lw`, `sw`, `beq`, `addi`, `slti`).
* ⏳ **Instrucciones Tipo J / Datapath Completo:** En desarrollo (`j` e integración unificada).

---
## ⚙️ Arquitectura y Módulos

El diseño combina lógica secuencial síncrona (`posedge clk`) y bloques combinacionales alimentados desde un archivo externo de programa en binario (`instrucciones.txt`):

### Módulos Base (Compartidos en `Tipo_R` y `Tipo_I`)
* **`PC_Register.v`**: Contador de programa síncrono de 32 bits con reinicio (`reset`) a la dirección `0`.
* **`Instruction_Memory.v`**: Memoria ROM de 64 palabras que carga el código máquina automáticamente desde `instrucciones.txt` mediante `$readmemb`.
* **`Register_File.v`**: Banco de 32 registros de propósito general con lectura combinacional, escritura síncrona en `posedge clk`, protección de solo lectura en `$0` y valores iniciales precargados (`$7` a `$17`).
* **`ALU.v` / `ALU_Control.v`**: Unidad Lógico Aritmética de 32 bits con bandera `Zero` y decodificador de operaciones (`ADD`, `SUB`, `AND`, `OR`, `SLT` con signo).
* **`Mux2x1_5bit.v` / `Mux2x1_32bit.v`**: Multiplexores para selección de registro destino (`RegDst`), operandos (`ALUSrc`), escritura desde memoria (`MemtoReg`) y salto condicional (`PCSrc`).

### Módulos Incorporados en `Tipo_I`
* **`MIPS_Datapath_I.v`**: Archivo *Top-Level* que interconecta la ruta de datos para acceso a memoria y bifurcaciones.
* **`Control_Unit.v`**: Unidad de control ampliada para decodificar `lw`, `sw`, `beq`, `addi`, `slti` y formato R, generando `RegDst`, `ALUSrc`, `MemtoReg`, `RegWrite`, `MemRead`, `MemWrite`, `Branch` y `ALUOp`.
* **`Data_Memory.v`**: Memoria RAM de 256 palabras con lectura combinacional (`MemRead`), escritura síncrona (`MemWrite`) y datos iniciales precargados en las direcciones `20` a `30`.
* **`Sign_Extend.v`**: Extensor de signo de 16 a 32 bits para desplazamientos e inmediatos.
* **`Shift_Left_2.v`**: Desplazador de 2 bits a la izquierda para calcular la dirección relativa de salto en `beq`.

---

## 🛠️ Herramientas Utilizadas
* **Lenguaje:** Verilog HDL
* **Simulador:** ModelSim

---

## 🚀 Cómo simular en ModelSim

1. Clona este repositorio o descarga los archivos localmente.
2. Abre **ModelSim** y crea un proyecto apuntando a la carpeta que deseas evaluar (`Tipo_R` o `Tipo_I`).
3. Añade todos los archivos `.v` de esa carpeta al proyecto y verifica que `instrucciones.txt` esté en el directorio raíz de simulación.
4. Haz clic derecho en el panel de proyecto y selecciona **Compile > Compile All**.
5. Ve a **Simulate > Start Simulation**, abre `work` y selecciona el *Testbench* correspondiente (`tb_MIPS_Datapath_R` o `tb_MIPS_Datapath_I`).
6. Añade las señales a la ventana gráfica (**Wave**) y ejecuta `run -all` en la consola (*Transcript*).

---

## 🧪 Pruebas Automatizadas (Testbenches)

### 1. Simulación Tipo R (`Tipo_R/tb_MIPS_Datapath_R.v`)
Con los registros iniciales `$8 = 125` y `$9 = 25`:

| PC | Instrucción | Operación | Resultado (`ALUResult`) | Registro Destino |
| :---: | :--- | :--- | :---: | :---: |
| `0` | `add $10, $8, $9` | `125 + 25` | `150` | `$10` |
| `4` | `sub $11, $8, $9` | `125 - 25` | `100` | `$11` |
| `8` | `and $12, $8, $9` | `125 & 25` | `25` | `$12` |
| `12` | `or $13, $8, $9` | `125 \| 25` | `125` | `$13` |
| `16` | `slt $14, $9, $8` | `25 < 125` | `1` | `$14` |

### 2. Simulación Tipo I (`Tipo_I/tb_MIPS_Datapath_I.v`)
Con `$9 = 25`, `$14 = 20`, `$15 = 20`, `$16 = 24`, `$17 = 28` y `mem[26] = 345`:

| PC | Instrucción | Acción | Resultado / Señal Clave |
| :---: | :--- | :--- | :--- |
| `0` | `lw $8, 2($16)` | Lee `mem[24 + 2]` (`345`) y guarda en `$8` | `ALUResult = 26`, `MemReadData = 345` |
| `4` | `sw $9, 2($17)` | Guarda `$9` (`25`) en `mem[28 + 2]` (`mem[30]`) | `ALUResult = 30`, `MemWrite = 1` |
| `8` | `beq $14, $15, 1` | Compara `20 == 20` y salta a `PC = 16` | `PCSrc = 1` (evade `PC = 12`) |
| `16` | `slti $11, $9, 50` | Evalúa si `25 < 50` y guarda en `$11` | `ALUResult = 1`, `WriteRegister = $11` |
| `20` | `addi $12, $9, 15` | Suma `25 + 15` y guarda en `$12` | `ALUResult = 40`, `WriteRegister = $12` |
