# Procesador MIPS 32-bit Monociclo — Proyecto Final de Arquitectura de Computadoras

Sistema completo MIPS de 32 bits compuesto por un procesador RTL en **Verilog HDL** (arquitectura Harvard con memorias **Big-Endian** direccionadas por byte y detención síncrona `halt`), un **ensamblador MIPS en Python** de dos pasadas, una **suite automatizada de pruebas en ModelSim** y un **simulador web interactivo** en React + TypeScript.

---

## Estructura del Repositorio

```text
Instruciones-R-I-J-/
├── RTL/                      # Modulos Verilog sintetizables del datapath MIPS 32-bit
│   ├── mips_datapath_top.v   # Modulo top-level integrando los 12 submodulos + halt
│   ├── pc.v                  # Contador de programa (reset=0, congelacion por halt)
│   ├── instruction_mem.v     # ROM de 1024 bytes Big-Endian + deteccion imem_err
│   ├── data_mem.v            # RAM de 1024 bytes Big-Endian + deteccion dmem_err
│   ├── control_unit.v        # Decodificador principal (R, addi/addiu, ori, lw, sw, beq, j)
│   ├── alu_control.v         # Decodificador de operaciones ALU (add/sub/and/or/slt/nor)
│   ├── alu.v                 # ALU de 32 bits con bandera Zero Flag (zf)
│   ├── register_file.v       # Banco de 32 registros ($zero inmutable)
│   ├── sign_ext.v            # Extension con signo y con ceros (ZeroExt para ori)
│   ├── adder.v / mux2to1.v / shift_left_2.v / and_gate.v
├── SRC/                      # Codigo fuente no-Verilog (ensamblador, programas y web)
│   ├── ensamblador/
│   │   └── mips_asm.py       # Ensamblador MIPS 2 pasadas -> Big-Endian (.hex) y (.lst)
│   ├── programas/
│   │   ├── frecuencia.asm            # Algoritmo principal: frecuencia de un valor en arreglo
│   │   ├── frecuencia_caso1.asm      # Entrada 1 (normal): [3,7,3,9,3], clave 3 -> 3
│   │   ├── frecuencia_caso2.asm      # Entrada 2 (sin coincidencias): [1,2,4,8], clave 5 -> 0
│   │   ├── frecuencia_caso3.asm      # Entrada 3 (borde): [-32768], clave -32768 -> 1
│   │   ├── integracion.asm           # Prueba integral de toda la ISA y control de flujo
│   │   ├── acceso_datos_invalido.asm # Prueba negativa: sw desalineado -> halt=1
│   │   ├── fetch_invalido.asm        # Prueba negativa: j fuera de rango -> halt=1
│   │   └── error_ensamblador.asm     # Prueba negativa: 6 diagnosticos por linea
│   └── web/                  # Simulador web interactivo (React 19 + TypeScript + Vite)
├── VERIF/                    # Bancos de prueba, scripts ModelSim y resultados
│   ├── tb_mips_datapath_top.v# Testbench de validacion unificada de 12 instrucciones
│   ├── tb_programa.v         # Testbench generico con traza por ciclo y volcado de estado
│   ├── ejecutar_pruebas.py   # Ejecutor automatizado (ensambla + simula en ModelSim)
│   ├── run_sim.do            # Script grafico de formas de onda para ModelSim GUI
│   ├── programa.hex          # Imagen Big-Endian por defecto (1 byte por linea)
│   └── resultados/           # Logs, listados, imagenes .hex y RESUMEN.md (0 fallas)
└── DOCS/                     # Documentacion tecnica, evidencias y entregables
    ├── Reporte_Proyecto_Final_MIPS.docx      # Reporte tecnico completo (Arial 12 negro)
    ├── Presentacion_Proyecto_Final_MIPS.pptx # Presentacion ejecutiva de defensa
    ├── trazas_R_I_J.md                       # Trazas detalladas paso a paso (R, I, J)
    ├── gestion_equipo_ia.md                  # Cronograma, acuerdos, uso de IA y referencias
    ├── fichas_individuales/                  # Fichas verificables de cada integrante
    └── evidencias/                           # Capturas de ModelSim y etapas separadas
```

---

## Conjunto de Instrucciones Soportado (ISA)

| Tipo | Instrucción | Opcode / Funct (hex) | Operación |
| :---: | :--- | :---: | :--- |
| **R** | `add $rd, $rs, $rt` | `00` / `21` (y `20`) | Suma módulo $2^{32}$ |
| **R** | `sub $rd, $rs, $rt` | `00` / `23` (y `22`) | Resta módulo $2^{32}$ |
| **R** | `and $rd, $rs, $rt` | `00` / `24` | AND bit a bit |
| **R** | `or $rd, $rs, $rt` | `00` / `25` | OR bit a bit |
| **R** | `slt $rd, $rs, $rt` | `00` / `2A` | `$rd = ($rs < $rt) ? 1 : 0` (con signo) |
| **R** | `nor $rd, $rs, $rt` | `00` / `27` | NOR bit a bit (extensión) |
| **I** | `addi` / `addiu $rt, $rs, #imm` | `09` (y `08`) | Suma con inmediato extendido con signo (`-32768..32767`) |
| **I** | `ori $rt, $rs, #imm` | `0D` | OR con inmediato extendido con ceros (`0..65535`, `ZeroExt=1`) |
| **I** | `lw $rt, #desp($rs)` | `23` | Carga palabra Big-Endian alineada a 4 bytes |
| **I** | `sw $rt, #desp($rs)` | `2B` | Guarda palabra Big-Endian alineada a 4 bytes |
| **I** | `beq $rs, $rt, #etiqueta` | `04` | Salto condicional sin ranura de retardo (`PC+4 + 4*imm`) |
| **J** | `j #etiqueta` | `02` | Salto incondicional dentro de la región de 256 MiB de `PC+4` |

---

## Guía de Reproducción Paso a Paso

### 1. Ensamblar un programa `.asm` a imagen Big-Endian (`.hex`) y listado (`.lst`)
```bash
python SRC/ensamblador/mips_asm.py SRC/programas/frecuencia.asm \
  --hex VERIF/programa.hex \
  --lst VERIF/programa.lst
```

### 2. Ejecutar toda la suite automatizada en ModelSim (ISA, Algoritmo 3 entradas y Casos Negativos)
```bash
python VERIF/ejecutar_pruebas.py
```
El resultado consolidado (esperado vs. observado) se escribe en [`VERIF/resultados/RESUMEN.md`](VERIF/resultados/RESUMEN.md).

### 3. Abrir formas de onda en la interfaz gráfica de ModelSim
1. Abrir **ModelSim** y seleccionar `File -> Change Directory...` hacia `VERIF/`.
2. En la consola Transcript ejecutar:
```tcl
do run_sim.do
```

### 4. Ejecutar y compilar el Simulador Web Interactivo
```bash
cd SRC/web/web
npm install
npm run dev      # Servidor local en http://localhost:5173
npm run build    # Compilacion de produccion (tsc -b && vite build)
```

---

## Evidencias y Entregables Principales
* **Reporte Técnico (Word):** [`DOCS/Reporte_Proyecto_Final_MIPS.docx`](DOCS/Reporte_Proyecto_Final_MIPS.docx)
* **Presentación de Defensa (PowerPoint):** [`DOCS/Presentacion_Proyecto_Final_MIPS.pptx`](DOCS/Presentacion_Proyecto_Final_MIPS.pptx)
* **Trazas R, I y J:** [`DOCS/trazas_R_I_J.md`](DOCS/trazas_R_I_J.md)
* **Resumen de Pruebas Verificadas:** [`VERIF/resultados/RESUMEN.md`](VERIF/resultados/RESUMEN.md)
* **Gestión, Cronograma y Declaración de IA:** [`DOCS/gestion_equipo_ia.md`](DOCS/gestion_equipo_ia.md)
* **Fichas Individuales:** [`DOCS/fichas_individuales/`](DOCS/fichas_individuales/)
