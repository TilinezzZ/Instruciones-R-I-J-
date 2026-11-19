# Ficha Individual de Trabajo — Ethan

* **Integrante:** Ethan (GitHub: `@Neitan095`)
* **Rol Principal:** Diseño de Hardware en Verilog HDL (`RTL/`), Integración del Datapath Monociclo y Verificación en ModelSim (`VERIF/`).
* **Arquitectura:** Procesador MIPS Monociclo de 32 bits (Arquitectura Harvard, memoria direccionada por byte en formato *Big-Endian*, 12 instrucciones y protección `halt`).

---

## 1. Módulos y Entregables Desarrollados

* **Desarrollo Incremental (`DOCS/evidencias/etapas_separadas/`):** Validación por etapas de instrucciones Tipo R (`add`, `sub`, `and`, `or`, `slt`, `nor`), Tipo I (`lw`, `sw`, `beq`) y Tipo J (`j`).
* **Datapath Principal Unificado (`RTL/mips_datapath_top.v`):** Interconexión estructural de los 12 submódulos con soporte para `addi`, `ori` (`ZeroExt`) y paro síncrono `halt`.
* **Memorias *Big-Endian* y Seguridad (`RTL/instruction_mem.v`, `RTL/data_mem.v`, `RTL/pc.v`):** Almacenamiento y lectura direccionados por byte en orden *Big-Endian* (`$readmemh("programa.hex", rom)`) y detección de desalineación (`addr[1:0] != 2'b00`) o fuera de rango (mayor a `1020`).
* **Banco de Pruebas Integral (`VERIF/tb_mips_datapath_top.v`, `VERIF/programa.hex`, `VERIF/run_sim.do`):** Simulación de 16 ciclos que comprueba las 12 instrucciones y el disparo de `halt`.

---

## 2. Decisiones Técnicas y Aportaciones Propias

1. **Memoria por byte *Big-Endian*:** Se usaron arreglos `reg [7:0]` de 1024 bytes guardando el byte más significativo (`[31:24]`) en `addr`, asegurando compatibilidad directa entre el ensamblador en Python, ModelSim y el simulador web.
2. **Extensión sin signo (`ZeroExt`):** Agregada entre `control_unit.v` y `sign_ext.v` para que `ori` rellene los 16 bits altos con ceros (`{16'd0, in}`) sin propagar signo.
3. **Protección `halt = imem_err | dmem_err`:** Congela el `PC` e inhibe escrituras en `register_file` y `data_mem` en el mismo ciclo en que ocurre un acceso inválido.

---

## 3. Traza Reproducible en ModelSim (`VERIF/programa.hex`)

1. Abrir **ModelSim** y cambiar el directorio (`File -> Change Directory...`) a `VERIF/`.
2. Ejecutar `do run_sim.do` (aplica `rst = 1` por `12 ns`, carga 64 bytes *Big-Endian* y corre 16 ciclos hasta `t = 166 ns`).

| Ciclo | PC | Instrucción | Mnemónico | Destino (`AW`) | Dato (`DW`) | `en_BR` | `zf` | `HALT` | Efecto Verificado |
| :---: | :---: | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **0** | `0x00` | `0x2008000A` | `addi $8, $0, 10` | `$8` | `0x0000000A` | `1` | `0` | `0` | Inicializa `$8 = 10` (escribe en `t = 15 ns`). |
| **1** | `0x04` | `0x34098005` | `ori $9, $0, 0x8005` | `$9` | `0x00008005` | `1` | `0` | `0` | Valida `ZeroExt`: `$9 = 0x00008005`. |
| **2** | `0x08` | `0x200A0004` | `addi $10, $0, 4` | `$10` | `0x00000004` | `1` | `0` | `0` | Carga dirección base alineada `4` en `$10`. |
| **3–8** | `0x0C–0x20` | `0x010A...` | `add, sub, and, or, slt, nor` | `$11–$16` | `14, 6, 0, 14, 1, 0xFFFFFFF1` | `1` | `0/1` | `0` | Valida las 6 operaciones Tipo R (`and` activa `zf = 1`). |
| **9** | `0x24` | `0xAD490000` | `sw $9, 0($10)` | — | — | `0` | `0` | `0` | Escribe *Big-Endian*: `MEM[4..7] = 00 00 80 05`. |
| **10** | `0x28` | `0x8D510000` | `lw $17, 0($10)` | `$17` | `0x00008005` | `1` | `0` | `0` | Reconstruye `0x00008005` desde `MEM[4..7]`. |
| **11** | `0x2C` | `0x11310001` | `beq $9, $17, 1` | — | — | `0` | `1` | `0` | Salta `PC = 0x30` (`$18 = 0`) hacia `PC = 0x34`. |
| **12** | `0x34` | `0x0800000F` | `j 15` | — | — | `0` | `1` | `0` | Salta a `15 × 4 = 60` (`0x3C`), evade `$19 = 0`. |
| **13–16** | `0x3C` | `0x8C140002` | `lw $20, 2($0)` | `$20` | `0x00000000` | `0` | `0` | `1` | Dirección `2` desalineada: `HALT = 1`, congela `PC = 60` y bloquea `$20`. |

* **Evidencias vinculadas:** [`DOCS/evidencias/README.md`](../evidencias/README.md), [`DOCS/evidencias/Capturas/Datapath_Unificado.png`](../evidencias/Capturas/Datapath_Unificado.png) y [`DOCS/evidencias/log_simulacion_unificada.txt`](../evidencias/log_simulacion_unificada.txt).

---

## 4. Historial de Commits en GitHub

| Fecha | Commit | Descripción |
| :---: | :---: | :--- |
| 2026-11-05 | [`663271e`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/663271ef4428e64fa26eca322c2ba37d3147ac2a) | chore: inicializa repositorio con .gitignore |
| 2026-11-05 | [`a5968f3`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/a5968f391a3a6f22c9ac6c33ab7642f804f025dc) | chore: inicializa proyecto Vite + React + Tailwind |
| 2026-11-06 | [`38fcb5c`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/38fcb5ccfa80dff0f5433e9ec9ef397a9d8a64fd) | feat: agrega datos de componentes del datapath |
| 2026-11-06 | [`1455e07`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/1455e07168ff08c6563786d91df26982b5c367f1) | feat: implementa rompecabezas interactivo, simulador de datapath y panel explicativo |
| 2026-11-06 | [`24cef37`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/24cef378be16632a7a3fed6971c15f553cb12b20) | feat: agrega m├│dulos Verilog, testbenches y script ModelSim del datapath completo |
| 2026-11-06 | [`5980e5e`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/5980e5edb4c98e8efea1975f28dda2dd9980e0fb) | docs: actualiza README y documentaci├│n t├®cnica del datapath |
| 2026-11-06 | [`3ca5435`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/3ca543505d9b220c16d8ea660aaff32b5d254820) | Commit inicial: M├│dulos Datapath Tipo R y Testbench comprobado |
| 2026-11-06 | [`3465e75`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/3465e75e67a76b992f39f418a2027e9ea8f6a90a) | Create README for MIPS Monocycle Datapath project |
| 2026-11-11 | [`29d5025`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/29d502563d8c8028a4b7f8c4051b708a4cbd40fb) | Actualizaci├│n a arquitectura s├¡ncrona: se agreg├│ PC_Register, clk y reset |
| 2026-11-12 | [`7a018f1`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/7a018f1d8881c668478269dfc984edf61c8d1867) | feat: agrega navegaci├│n entre vistas, temas claro/oscuro y diagrama reutilizable |
| 2026-11-12 | [`f3fe658`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/f3fe6585ee0b63d5dd7f4b2bf8b900c227f7c42c) | feat: vista de Unidad de Control con tabla interactiva, decodificador y quiz |
| 2026-11-12 | [`7c373c0`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/7c373c0812951b0db5b093814fc5f5066cce9820) | feat: simulaci├│n paso a paso de instrucci├│n tipo R con calculadora de funct |
| 2026-11-12 | [`7a9cfc2`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/7a9cfc2bd0d6a21a541e13a691859a99575087af) | feat: vista LW y SW con banco de registros y memoria de datos interactivos |
| 2026-11-12 | [`20bd9f1`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/20bd9f1ec0237a212a28efb2fdce7108bbac9bb9) | feat: vista Tipo J con c├ílculo de salto y bucle interactivo |
| 2026-11-12 | [`7ad2665`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/7ad2665b8d2c433f2d25bc69bfe96ca2a66e834f) | feat: comparador de instrucciones lado a lado |
| 2026-11-12 | [`c748031`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/c74803145693df44d8edbaa967e82dbacf7b2ba7) | docs: documenta nuevas vistas pedag├│gicas y fe de erratas |
| 2026-11-12 | [`d52f323`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/d52f323b982a51d9cf2262b37967710d97c3cb33) | chore: remueve menciones institucionales y referencias a diapositiva 17 |
| 2026-11-12 | [`117455c`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/117455cd86666605375a40104d841a4e93705de9) | fix(deploy): agrega configuracion raiz de Vercel y limpia leyenda de lienzo RTL |
| 2026-11-12 | [`d4fc101`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/d4fc10176e75a9a7c4ba001bf2683ce8335d5995) | fix: remueve referencias textuales, agrega purga de service worker y configura workspace Vercel |
| 2026-11-16 | [`2717817`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/2717817b978e8a07a3848bf6bb8040173e28607d) | Optimizacion y limpieza de modulos Tipo R |
| 2026-11-16 | [`de8d195`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/de8d19583ee4f1b18e8221a3118d0dc3c92fdbe2) | Agregados Instruction_Memory y Register_File al Datapath Tipo R |
| 2026-11-16 | [`f2fee2b`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/f2fee2ba974d3acd02b902637598043d45aad24c) | Enhance README with instruction types and simulation details |
| 2026-11-17 | [`d7f0719`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/d7f07196476c23c96e9f8c60b0da41d7b3c99d62) | Carga de instrucciones Tipo R desde archivo instrucciones.txt |
| 2026-11-17 | [`23e2122`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/23e212224ef50c0347fc3c62871b37c0f68fc181) | Implementacion y simulacion de instrucciones Tipo I |
| 2026-11-17 | [`5437352`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/54373526addf1d220c7efd94d33e677ef71dab00) | Enhance README with project details and status |
| 2026-11-18 | [`1089f3b`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/1089f3b188d40a79c37a2a51493dd768352ec1b8) | Implementacion y simulacion de instrucciones Tipo J y Organizacion del proyecto |
| 2026-11-18 | [`dbe469c`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/dbe469c68797b035b246dc7faa381527d37d01ed) | Estructura ofical del proyecto y guardado de las etapas separadas en DOCS |
| 2026-11-18 | [`f4fec4a`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/f4fec4a7f3bf7140e11063bf368f0e528f739bda) | Agrega estructura oficial de carpetas RTL, VERIF y SRC otra vez por wey |
| 2026-11-18 | [`66c2e12`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/66c2e1253eff650bdd4fb29ddd575dbb422f00e5) | Integra proyecto web ProyFinalSlides en SRC/web |
| 2026-11-18 | [`9fa3237`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/9fa32370aff7aa79e09e24325c7caca9bacaf58a) | Tabla de resultados esperados y observados |
| 2026-11-18 | [`584cbc0`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/584cbc06795fe1dcf2b06cecc1009267f1e08a0e) | Agrega al README las capturas |
| 2026-11-18 | [`670f159`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/670f159e27769a7d0ed995f81dc132d33a0ba3b1) | Integrar modulos RTL unificados con memoria Big-Endian, ori, addi y halt |
| 2026-11-19 | [`095d4b5`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/095d4b5d438dfbef068fde9b68c278186a47ec6b) | Agrega verificacion unificada en VERIF y log de simulacion en DOCS |
| 2026-11-19 | [`07ab877`](https://github.com/TilinezzZ/Instruciones-R-I-J-/commit/07ab87794b9d3a572440567d4ae458b2fd4a88d7) | Documentar captura y tabla de verificacion del datapath unificado |
