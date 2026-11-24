# Ficha Individual de Trabajo — Darío Israel Fuentes Ramírez (`@darigfram-source`)

* **Integrante:** Darío Israel Fuentes Ramírez (GitHub: `@darigfram-source`)
* **Rol Principal:** Desarrollo del Simulador Visual Interactivo en React/TypeScript (`SRC/web/`), Módulos RTL Base, Integración de Ensamblador/Suite de Pruebas y Documentación Técnica.

---

## 1. Módulos y Entregables Desarrollados

* **Simulador Pedagógico Web (`SRC/web/web/`):** Aplicación interactiva en React 19, TypeScript, Vite y Tailwind CSS con rompecabezas del datapath completo, vistas dedicadas (Unidad de Control, Tipo R, LW/SW, Tipo J, Comparador), inspector de puertos/Verilog y soporte claro/oscuro.
* **Módulos RTL Base (`SRC/web/verilog/` -> integrados en `RTL/`):** Implementación inicial de los 13 módulos del procesador monociclo MIPS de 32 bits y su banco de pruebas.
* **Ensamblador, Suite Reproducible y Documentación (`SRC/ensamblador/mips_asm.py`, `VERIF/ejecutar_pruebas.py`, `DOCS/`):** Traductor de dos pasadas a formato Big-Endian, automatización de pruebas en ModelSim, trazas R/I/J y entregables finales (`.docx` y `.pptx`).

---

## 2. Decisión Técnica y Corrección Propia

Durante la auditoría del ensamblador (`SRC/ensamblador/mips_asm.py`) y la integración con la Unidad de Control (`RTL/control_unit.v` / `RTL/alu_control.v`), se identificaron dos correcciones críticas:
1. **Compatibilidad de opcodes/funct:** Se unificó el soporte para los códigos de la consigna (`add` 00/21, `sub` 00/23, `addi`/`addiu` 09) junto con los estándar (`add` 00/20, `sub` 00/22, `addi` 08) para garantizar compatibilidad total entre el simulador web, el ensamblador y el hardware en ModelSim.
2. **Ordenamiento determinístico de diagnósticos por línea:** Al detectar errores en Pasada 1 (etiquetas duplicadas) y Pasada 2 (operandos fuera de rango o mnemónicos inválidos), se implementó el ordenamiento ascendente por número de línea antes de reportar los diagnósticos, logrando 100% de pruebas aprobadas en `VERIF/resultados/RESUMEN.md`.

---

## 3. Traza Reproducible (Simulador Web y ModelSim)

### Reproducción del Simulador Web
```bash
cd SRC/web/web
npm install
npm run dev      # http://localhost:5173
npm run build    # Compilacion limpia (tsc -b && vite build)
```

### Traza Verificada (`SRC/programas/integracion.asm` en ModelSim)

| Paso | PC | Bytes (Big-Endian) | Instrucción | Estado Antes -> Después | Observaciones |
| :---: | :---: | :---: | :--- | :--- | :--- |
| 1 | `0x00` | `24 08 00 05` | `addiu $t0, $zero, 5` | `$t0: 0 -> 5`, `PC: 0 -> 4` | Valida lectura Big-Endian y suma inmediata. |
| 5 | `0x10` | `01 08 58 21` | `add $t3, $t0, $t0` | `$t3: 0 -> 10`, `PC: 16 -> 20` | Tipo R: `RegDst=1`, `en_BR=1`, `ALU=0x0A`. |
| 12 | `0x2C` | `8E 11 00 00` | `lw $s1, 0($s0)` | `$s1: 0 -> 10`, `PC: 44 -> 48` | Tipo I: lee `ram[64..67]` Big-Endian (`00 00 00 0A`). |
| 22 | `0x54` | `08 00 00 17` | `j fin` | `PC: 84 -> 92`, `$s7: 0` | Tipo J: omite `0x58` (`addi $s7, $zero, 77`). |

---

## 4. Historial de Commits Verificables en GitHub

| Fecha | Commit | Descripción |
| :---: | :---: | :--- |
| 2026-11-12 | `d52f323` | `chore: remueve menciones institucionales y referencias a diapositiva 17` |
| 2026-11-12 | `117455c` | `fix(deploy): agrega configuracion raiz de Vercel y limpia leyenda de lienzo RTL` |
| 2026-11-12 | `d4fc101` | `fix: remueve referencias textuales, agrega purga de service worker y configura workspace Vercel` |
| 2026-11-18 | `22055b3` | `refactor: remueve todos los comentarios del codigo general (Verilog y Web)` (en `ProyFinalSlides`) |
| 2026-11-23 | *(commit actual)* | `feat: agrega ensamblador MIPS, suite automatizada ModelSim, trazas R/I/J y entregables DOCS` |

---

## 5. Conclusión Individual

La integración entre el simulador web interactivo y la verificación RTL en ModelSim permitió comprobar de forma visual y determinística cómo cada campo de 32 bits se traduce en señales de control concretas (`RegDst`, `ALU_Src`, `ZeroExt`, `MemToReg`, `Branch`, `Jump`, `en_BR`) y produce cambios observables en registros, memoria Big-Endian y `PC`.
