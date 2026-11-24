# Gestión del Equipo, Cronograma, Acuerdos y Declaración de Uso de IA

## 1. Integrantes y Responsabilidades

| Integrante | Usuario GitHub | Modalidad / Rol Principal | Módulos Asignados |
| :--- | :---: | :--- | :--- |
| **Ethan** | `@Neitan095` | Diseño de Hardware RTL y Verificación ModelSim | `RTL/*.v`, `VERIF/tb_mips_datapath_top.v`, `VERIF/run_sim.do`, `DOCS/evidencias/` |
| **Darío Israel Fuentes Ramírez** | `@darigfram-source` | Simulador Web Interactivo (React/TS) y Módulos RTL Base | `SRC/web/`, integración web-Verilog, `DOCS/trazas_R_I_J.md`, reporte técnico |
| **Integrante 3** | `@TilinezzZ` | Ensamblador MIPS, Algoritmo Final y Gestión | `SRC/ensamblador/mips_asm.py`, `SRC/programas/*.asm`, `VERIF/ejecutar_pruebas.py`, `DOCS/` |

---

## 2. Cronograma de Avances

| Etapa | Fechas | Actividades Clave | Estado |
| :--- | :---: | :--- | :---: |
| **Fase 1: Diseño y R** | 12–16 Nov 2026 | Definición del datapath monociclo, ALU, ALU Control, Banco de Registros y simulación Tipo R. | Completado |
| **Fase 2: Tipo I y J** | 17–18 Nov 2026 | Incorporación de `lw`, `sw`, `beq`, `j`, extensión con signo y evidencias separadas en ModelSim. | Completado |
| **Fase 3: Integración RTL y Web** | 18–19 Nov 2026 | Unificación en `RTL/`, memoria Big-Endian por byte, `ori` (`ZeroExt`), `addi`/`addiu`, señal `halt` e integración del simulador web en `SRC/web/`. | Completado |
| **Fase 4: Ensamblador, Algoritmo y Suite** | 20–23 Nov 2026 | Desarrollo de `mips_asm.py`, algoritmo de frecuencia con 3 entradas (`frecuencia_caso1..3.asm`), pruebas automatizadas en ModelSim (`ejecutar_pruebas.py`) y corrección de opcodes (`add` 0x21, `sub` 0x23, `addi`/`addiu` 0x09). | Completado |
| **Fase 5: Reporte y Defensa** | 23 Nov 2026 | Generación de reporte técnico (`Reporte_Proyecto_Final_MIPS.docx`), presentación (`Presentacion_Proyecto_Final_MIPS.pptx`), trazas R/I/J y fichas individuales. | Completado |

---

## 3. Registro de Acuerdos y Problemas Resueltos

| Fecha | Problema / Decisión | Acuerdo / Solución Aplicada | Responsable |
| :---: | :--- | :--- | :--- |
| 18 Nov 2026 | Organización de carpetas para evaluación. | Adoptar la estructura oficial exigida: `RTL/`, `SRC/`, `VERIF/` y `DOCS/`, resguardando las etapas previas en `DOCS/evidencias/Etapas_Separadas/`. | Todo el equipo |
| 18 Nov 2026 | Lectura de memoria de instrucciones y datos en formato Big-Endian. | Implementar `instruction_mem.v` y `data_mem.v` como arreglos `reg [7:0]` de 1024 bytes, concatenando `{mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]}` y generando `imem_err` / `dmem_err`. | `@Neitan095` |
| 19 Nov 2026 | Discrepancia en opcodes/funct de la consigna (`add` 0x21, `sub` 0x23, `addi` 0x09) frente a `add` 0x20, `sub` 0x22, `addi` 0x08. | Soportar ambos pares en `RTL/alu_control.v` y `RTL/control_unit.v`, y emitir los códigos de la consigna desde `SRC/ensamblador/mips_asm.py`. | `@Neitan095` / `@darigfram-source` |
| 19 Nov 2026 | Extensión con ceros para `ori` sin afectar `addi`/`lw`/`sw`/`beq`. | Añadir la señal `ZeroExt` de 1 bit desde `control_unit.v` hacia `sign_ext.v`. | `@Neitan095` |
| 23 Nov 2026 | Orden de diagnósticos en el ensamblador al detectar etiquetas duplicadas (Pasada 1) y errores de operandos (Pasada 2). | Ordenar la lista de diagnósticos por número de línea antes de reportar/retornar errores en `mips_asm.py`. | `@darigfram-source` |

---

## 4. Declaración de Uso de IA por Módulo

En cumplimiento con la política de autoría y transparencia de la consigna oficial, se declara el uso de herramientas de Inteligencia Artificial en el proyecto:

| Módulo / Carpeta | Herramienta IA | Propósito | Aportes Incorporados / Descartados | Método de Verificación |
| :--- | :--- | :--- | :--- | :--- |
| `RTL/*.v` | Asistente de código (Gemini / Claude) | Revisión de sintaxis Verilog-2001, adición de `ZeroExt`, detección `imem_err`/`dmem_err` y paro `halt`. | Incorporado el patrón de concatenación Big-Endian y validación de alineación; descartados bloques no sintetizables. | Compilación limpia (`0 errores, 0 warnings`) y simulación de 6 suites en ModelSim 2020.1. |
| `SRC/web/` | Asistente de código (Antigravity / Gemini) | Construcción del rompecabezas interactivo del datapath en React 19, TypeScript, Tailwind CSS y SVG. | Incorporadas vistas didácticas (Datapath, Control, Tipo R, LW, Tipo J, Comparador); descartados textos institucionales no solicitados y service workers conflictivos. | Compilación estricta `tsc -b && vite build` sin errores y pruebas manuales en navegador. |
| `SRC/ensamblador/` y `VERIF/` | Asistente de código (Antigravity / Gemini) | Implementación del ensamblador en dos pasadas (`mips_asm.py`), testbench genérico (`tb_programa.v`) y automatizador (`ejecutar_pruebas.py`). | Incorporada validación por rango de inmediatos, regiones de salto y ordenamiento de errores por línea. | Ejecución real de `python VERIF/ejecutar_pruebas.py` validando 100% de aserciones contra ModelSim. |
| `DOCS/` | Asistente de código (Antigravity / Gemini) | Redacción estructurada del reporte técnico (`.docx`), trazas R/I/J y presentación (`.pptx`). | Incorporadas tablas técnicas, pseudocódigo y trazas extraídas directamente de los logs reales; revisado formato Arial 12 negro. | Auditoría cruzada con `VERIF/resultados/RESUMEN.md` y verificación automatizada de fuentes/estilos. |

---

## 5. Referencias Técnicas

1. **Patterson, D. A., & Hennessy, J. L.** *Computer Organization and Design: The Hardware/Software Interface*, 5.ª edición, Capítulo 4 ("The Processor"). Morgan Kaufmann.
2. **MIPS Technologies, Inc.** *MIPS32 Architecture for Programmers, Volume II: The MIPS32 Instruction Set*.
3. **Nanyang Technological University (NTU).** *MIPS 101 — Interactive MIPS Datapath Reference*.
4. **IEEE Std 1364-2001.** *IEEE Standard Verilog Hardware Description Language*.
