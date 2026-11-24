# Trazas Detalladas Paso a Paso (Formatos R, I y J)

Las siguientes trazas corresponden a la ejecución real y reproducible del programa de integración (`SRC/programas/integracion.asm`) sobre el procesador MIPS monociclo de 32 bits (`RTL/mips_datapath_top.v`) en **ModelSim Intel FPGA Edition 2020.1**, verificables en `VERIF/resultados/integracion/simulacion.log`.

> **Nota sobre registros intermedios (buffers):** Aunque el procesador en `RTL/` opera en modelo monociclo (una instrucción completa por flanco ascendente de reloj con registro síncrono `PC`, banco de registros y memoria de datos), en cada traza se documentan explícitamente las fronteras lógicas de etapa (**IF/ID**, **ID/EX**, **EX/MEM** y **MEM/WB**) con sus anchos en bits, señales de habilitación (`!halt`, `en_BR`, `MemWrite`) y valores observables durante el ciclo.

---

## 1. Traza Formato Tipo R — `add $t3, $t0, $t0`

* **Dirección (`PC`):** `0x00000010` (`16` decimal)
* **Bytes leídos en Memoria de Instrucciones (Big-Endian):**
  * `rom[16] = 0x01`, `rom[17] = 0x08`, `rom[18] = 0x58`, `rom[19] = 0x21`
* **Palabra de 32 bits formada:** `0x01085821` (`000000 01000 01000 01011 00000 100001`)

### Campos Decodificados
| Campo | Rango de bits | Binario | Valor Decimal / Hex | Significado |
| :---: | :---: | :---: | :---: | :--- |
| `opcode` | `[31:26]` | `000000` | `0` (`0x00`) | Instrucción Formato Tipo R |
| `rs` | `[25:21]` | `01000` | `8` (`$t0`) | Primer registro fuente (`AR1 = 8`) |
| `rt` | `[20:16]` | `01000` | `8` (`$t0`) | Segundo registro fuente (`AR2 = 8`) |
| `rd` | `[15:11]` | `01011` | `11` (`$t3`) | Registro destino (`AW = 11` vía `Mux2`) |
| `shamt` | `[10:6]` | `00000` | `0` | Sin desplazamiento |
| `funct` | `[5:0]` | `100001` | `33` (`0x21`) | Operación `add` / `addu` -> `alu_ctrl = 3'b010` (ADD) |

### Señales de Control Activas
| `RegDst` | `ALU_Src` | `ALU_Op` | `MemToReg` | `MemRead` | `MemWrite` | `Branch` | `Jump` | `ZeroExt` | `en_BR` | `halt` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `1` | `0` | `10` | `0` | `0` | `0` | `0` | `0` | `0` | `1` | `0` |

### Flujo por Etapas y Buffers
* **IF/ID:** `PC = 0x00000010`, `PC+4 = 0x00000014`, `Instruction = 0x01085821`.
* **ID/EX:** `DR1 = R[8] = 0x00000005`, `DR2 = R[8] = 0x00000005`, `AW = 11` (`RegDst=1`).
* **EX/MEM:** `alu_b = DR2 = 0x00000005` (`ALU_Src=0`), `alu_ctrl = 010`, `ALU_Result = 0x00000005 + 0x00000005 = 0x0000000A` (`10`), `zf = 0`.
* **MEM/WB:** Sin acceso a RAM (`MemRead=0, MemWrite=0`). `DW = ALU_Result = 0x0000000A` (`MemToReg=0`).

### Estado Antes y Después del Flanco de Reloj
| Elemento | Estado Antes | Estado Después |
| :--- | :---: | :---: |
| Registro `$t3` (`$11`) | `0x00000000` | **`0x0000000A` (`10`)** |
| Memoria de Datos | Sin cambios | Sin cambios |
| `PC` | `0x00000010` (`16`) | **`0x00000014` (`20`)** |

---

## 2. Traza Formato Tipo I — `lw $s1, 0($s0)`

* **Dirección (`PC`):** `0x0000002C` (`44` decimal)
* **Bytes leídos en Memoria de Instrucciones (Big-Endian):**
  * `rom[44] = 0x8E`, `rom[45] = 0x11`, `rom[46] = 0x00`, `rom[47] = 0x00`
* **Palabra de 32 bits formada:** `0x8E110000` (`100011 10000 10001 0000000000000000`)

### Campos Decodificados
| Campo | Rango de bits | Binario | Valor Decimal / Hex | Significado |
| :---: | :---: | :---: | :---: | :--- |
| `opcode` | `[31:26]` | `100011` | `35` (`0x23`) | Instrucción `lw` (Load Word) |
| `rs` | `[25:21]` | `10000` | `16` (`$s0`) | Registro base (`AR1 = 16`, valor `0x00000040 = 64`) |
| `rt` | `[20:16]` | `10001` | `17` (`$s1`) | Registro destino (`AW = 17` vía `Mux2`, `RegDst = 0`) |
| `inmediato` | `[15:0]` | `0000000000000000` | `0` (`0x0000`) | Desplazamiento con signo en bytes |

### Señales de Control Activas
| `RegDst` | `ALU_Src` | `ALU_Op` | `MemToReg` | `MemRead` | `MemWrite` | `Branch` | `Jump` | `ZeroExt` | `en_BR` | `halt` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `0` | `1` | `00` | `1` | `1` | `0` | `0` | `0` | `0` | `1` | `0` |

### Flujo por Etapas y Buffers
* **IF/ID:** `PC = 0x0000002C`, `PC+4 = 0x00000030`, `Instruction = 0x8E110000`.
* **ID/EX:** `DR1 = R[16] = 0x00000040` (`64`), `ExtImm = 0x00000000` (`ZeroExt=0`), `AW = 17` (`RegDst=0`).
* **EX/MEM:** `alu_b = ExtImm = 0x00000000` (`ALU_Src=1`), `alu_ctrl = 010` (ADD), `Address_In = ALU_Result = 0x00000040` (`64`), `dmem_err = 0` (alineada a 4 y dentro de `0..1020`).
* **MEM/WB:** Lectura Big-Endian `{ram[64], ram[65], ram[66], ram[67]} = {0x00, 0x00, 0x00, 0x0A} = 0x0000000A`. `DW = mem_read_data = 0x0000000A` (`MemToReg=1`).

### Estado Antes y Después del Flanco de Reloj
| Elemento | Estado Antes | Estado Después |
| :--- | :---: | :---: |
| Registro `$s1` (`$17`) | `0x00000000` | **`0x0000000A` (`10`)** |
| `ram[64..67]` | `00 00 00 0A` | `00 00 00 0A` (solo lectura) |
| `PC` | `0x0000002C` (`44`) | **`0x00000030` (`48`)** |

---

## 3. Traza Formato Tipo J — `j fin` (destino `0x0000005C`)

* **Dirección (`PC`):** `0x00000054` (`84` decimal)
* **Bytes leídos en Memoria de Instrucciones (Big-Endian):**
  * `rom[84] = 0x08`, `rom[85] = 0x00`, `rom[86] = 0x00`, `rom[87] = 0x17`
* **Palabra de 32 bits formada:** `0x08000017` (`000010 00000000000000000000010111`)

### Campos Decodificados
| Campo | Rango de bits | Binario | Valor Decimal / Hex | Significado |
| :---: | :---: | :---: | :---: | :--- |
| `opcode` | `[31:26]` | `000010` | `2` (`0x02`) | Instrucción `j` (Jump incondicional) |
| `index` | `[25:0]` | `00000000000000000000010111` | `23` (`0x0000017`) | Bits `[27:2]` de la dirección destino (`23 × 4 = 92 = 0x5C`) |

### Señales de Control Activas
| `RegDst` | `ALU_Src` | `ALU_Op` | `MemToReg` | `MemRead` | `MemWrite` | `Branch` | `Jump` | `ZeroExt` | `en_BR` | `halt` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `0` (X) | `0` (X) | `00` (XX) | `0` (X) | `0` | `0` | `0` | **`1`** | `0` | `0` | `0` |

### Flujo por Etapas y Buffers
* **IF/ID:** `PC = 0x00000054` (`84`), `PC+4 = 0x00000058` (`88`), `Instruction = 0x08000017`.
* **Cálculo de Salto (sin ranura de retardo):**
  * `Shift Left 2 (Jump):` `index << 2 = 28'h000005C`.
  * `Concatenación:` `jump_target_32 = {PC+4[31:28], jump_addr_28} = {4'b0000, 28'h000005C} = 0x0000005C` (`92`).
  * `Mux5 (Jump = 1):` selecciona `next_pc = 0x0000005C`.
* **Efecto observable:** La instrucción intermedia en `PC = 0x00000058` (`addi $s7, $zero, 77`) queda **omitida**, por lo que `$s7` permanece en `0x00000000`.

### Estado Antes y Después del Flanco de Reloj
| Elemento | Estado Antes | Estado Después |
| :--- | :---: | :---: |
| Registro `$s7` (`$23`) | `0x00000000` | **`0x00000000` (instrucción en `0x58` omitida)** |
| Memoria de Datos | Sin cambios | Sin cambios |
| `PC` | `0x00000054` (`84`) | **`0x0000005C` (`92`)** |
