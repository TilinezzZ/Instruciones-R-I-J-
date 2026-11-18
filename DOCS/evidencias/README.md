# Evidencias de Validación Incremental (Etapas R, I y J)

Este directorio documenta el desarrollo y verificación modular del procesador MIPS monociclo en ModelSim antes de su integración en el datapath unificado (`RTL/`). Los módulos y vectores de prueba individuales de cada etapa están respaldados en `etapas_separadas/` y en la rama `etapas-separadas`.

---

## 1. Etapa 1: Instrucciones Tipo R (`add`, `sub`, `and`, `or`, `slt`)

Validación de la unidad aritmético-lógica (`ALU`), decodificación de `funct` (`ALU_Control`) y escritura en el banco de registros (`RegDst = 1`, `RegWrite = 1`, `ALUSrc = 0`).

![Simulación Etapa Tipo R](./Capturas/Tipo%20R.png)

| PC | Instrucción | Operación esperada | Resultado esperado | Resultado observado | Estado |
| :---: | :--- | :--- | :---: | :---: | :---: |
| `0` | `add $10, $8, $9` | `125 + 25` | `150` en `$10` | `ALUResult = 150`, `Dest = 10` | Correcto |
| `4` | `sub $11, $8, $9` | `125 - 25` | `100` en `$11` | `ALUResult = 100`, `Dest = 11` | Correcto |
| `8` | `and $12, $8, $9` | `125 & 25` | `25` en `$12` | `ALUResult = 25`, `Dest = 12` | Correcto |
| `12` | `or $13, $8, $9` | `125 \| 25` | `125` en `$13` | `ALUResult = 125`, `Dest = 13` | Correcto |
| `16` | `slt $14, $9, $8` | `25 < 125 ? 1 : 0` | `1` en `$14` | `ALUResult = 1`, `Dest = 14` | Correcto |

---

## 2. Etapa 2: Instrucciones Tipo I (`lw`, `sw`, `beq`, `slti`, `addi`)

Validación de extensión de inmediato, acceso a memoria de datos (`MemRead`, `MemWrite`) y salto condicional (`beq`) mediante comparación de registros.

![Simulación Etapa Tipo I](./Capturas/Tipo%20I.png)

| PC | Instrucción | Acción esperada | Señales / Resultado esperado | Resultado observado | Estado |
| :---: | :--- | :--- | :--- | :---: | :---: |
| `0` | `lw $8, 2($16)` | Lee dato en dirección `24 + 2 = 26` | `RegWrite = 1`, `MemWrite = 0`, dato `345` en `$8` | `ALUResult = 26`, `Data = 345`, `Dest = 8` | Correcto |
| `4` | `sw $9, 2($17)` | Escribe `25` en dirección `28 + 2 = 30` | `RegWrite = 0`, `MemWrite = 1` | `ALUResult = 30`, `MemWrite = 1` | Correcto |
| `8` | `beq $14, $14, 1` | Compara `20 == 20` y salta `PC = 12` | `RegWrite = 0`, `PC_Next = 16` | `ALUResult = 0`, `PC` salta directo a `16` | Correcto |
| `16` | `slti $11, $9, 50` | Evalúa `25 < 50 ? 1 : 0` | `RegWrite = 1`, `1` en `$11` | `ALUResult = 1`, `Dest = 11` | Correcto |
| `20` | `addi $12, $9, 927` | Suma registro + inmediato (`23 + 927`) | `RegWrite = 1`, `950` en `$12` | `Resultado = 950`, `Dest = 12` | Correcto |

---

## 3. Etapa 3: Instrucciones Tipo J (`j`)

Validación del desplazamiento de 26 a 28 bits (`Shift_Left_2_Jump`), concatenación con `PC+4[31:28]`, omisión de instrucciones intermedias y autosalto final observable.

![Simulación Etapa Tipo J](./Capturas/Tipo%20J.png)

| PC | Instrucción | Acción esperada | Señales / Resultado esperado | Resultado observado | Estado |
| :---: | :--- | :--- | :--- | :---: | :---: |
| `0` | `add $10, $8, $9` | Ejecuta `125 + 25` antes del salto | `Jump = 0`, `ALUResult = 150`, `Dest = $10` | `150` guardado en `$10` | Correcto |
| `4` | `j 4` | Salta a palabra `4` (`PC = 16`), omitiendo `PC = 8` y `12` | `Jump = 1`, `RegWrite = 0`, `PC_Next = 16` | `PC` brinca directo de `4` a `16` | Correcto |
| `16` | `or $13, $8, $9` | Ejecuta `125 \| 25` tras aterrizar del salto | `Jump = 0`, `ALUResult = 125`, `Dest = $13` | `125` guardado en `$13` | Correcto |
| `20` | `j 5` | Autosalto incondicional a palabra `5` (`PC = 20`) | `Jump = 1`, `PC` fijo en `20` | `PC` permanece en `20` | Correcto |
