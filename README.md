# 🧠 Procesador MIPS Monociclo de 32 bits
### Rompecabezas Interactivo, Simulador Visual y Diseño RTL en Verilog

Proyecto final: **Arquitectura de Computadoras**

[![Vercel Deployment](https://img.shields.io/badge/Deploy-Vercel-black?style=for-the-badge&logo=vercel)](https://vercel.com/)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github)](https://github.com/TilinezzZ/ProyFinalSlides)
[![Stack](https://img.shields.io/badge/React%2019-TypeScript-blue?style=for-the-badge&logo=react)](https://react.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-CSS%204-38B2AC?style=for-the-badge&logo=tailwind-css)](https://tailwindcss.com/)
[![ModelSim](https://img.shields.io/badge/ModelSim-Verilog%20HDL-red?style=for-the-badge)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-technology.html)

---

## 🌟 Descripción del Proyecto

Este proyecto aborda la comprensión, diseño e implementación del **Datapath Completo Monociclo de 32 bits**. El trabajo se divide en dos fases fundamentales:

1. **Plataforma Web Interactiva (Estilo Rompecabezas y Simulador Visual):**
   - Una aplicación moderna donde el usuario aprende la arquitectura de computadoras arrastrando y encajando los 18 componentes del procesador.
   - **Vistas Especializadas por Diapositiva:**
     - `/` (**Datapath Completo**): Rompecabezas interactivo con Modo Aprender y Modo Reto (cronómetro y puntuación).
     - `/control` (**Unidad de Control** · Diapositivas 18, 19, 23 y 24): Diagrama RTL con tooltip interactivo de señales, Tabla de Señales de Control (0, 1, X), Tabla de Verdad de Opcodes, Tabla de ALU Control (4 bits), Modo Decodificador interactivo y Mini-Quiz formativo.
     - `/tipo-r` (**Instrucción Tipo R** · Diapositiva 20): Simulación paso a paso de los 9 pasos del ciclo, formato de instrucción campo a campo, componentes inactivos atenuados y calculadora interactiva de operandos/funct.
     - `/lw` (**Instrucción LW y SW** · Diapositivas 21, 26 y 27): Visualización y edición interactiva de las tablas de Banco de Registros (7 a 17) y Memoria de Datos (20 a 30) de la Diapositiva 26 con animación de transferencia de datos.
     - `/tipo-j` (**Tipo J y Saltos** · Diapositivas 22 y 28): Desglose de concatenación `{PC+4[31:28], target<<2}`, calculadora de salto absoluto y simulación interactiva del bucle con `beq` y `j`.
     - `/comparar` (**Comparador Lado a Lado**): Análisis diferencial simultáneo entre cualesquiera dos instrucciones con matriz de señales y diagramas paralelos.
   - **Soporte de Tema:** Modo Oscuro ("Placa de Circuito" neón) y Modo Claro.
   - **Selector Global de Instrucción:** Resalta en vivo el camino de datos correspondiente (`R`, `lw`, `sw`, `beq`, `j`).
   - **Panel Inspector Técnico:** Al pulsar cualquier pieza, se detallan sus entradas y salidas con ancho en bits, su propósito RTL, las instrucciones en las que participa y su código Verilog sintetizable.
   - **Fe de Erratas y Discrepancias Académicas:** Documentación interactiva de las notas entre diapositivas (`en_BR` vs `RegWrite`, 3 vs 4 bits de ALU Control, errata de sintaxis de SW en Diapositiva 27 y de LW en Diapositiva 25).

2. **Diseño RTL en Verilog y Simulación en ModelSim (`/verilog`):**
   - 13 módulos Verilog parametrizados y documentados en español, respetando exactamente los nombres de puertos y señales (`AR1`, `AR2`, `AW`, `DR1`, `DR2`, `DW`, `en_BR`, `zf`, etc.).
   - Testbench dedicado para cada módulo individual.
   - Testbench del datapath completo (`tb_mips_datapath_top.v`) que ejecuta un programa con `add`, `sw`, `lw`, `beq` y `j`.
   - Script de automatización `.do` para ModelSim que compila, carga las formas de onda organizadas por colores y ejecuta la simulación.

---

## 🧩 Los 18 Componentes del Datapath

1. **PC** (Registro de 32 bits con entrada `CLK` y `rst`)
2. **Sumador PC+4** (Calcula la dirección secuencial siguiente)
3. **Memoria de Instrucciones** (ROM combinacional de 32 bits)
4. **Unidad de Control** (Decodificador central de 9 señales de control)
5. **Mux2 (RegDst)** (Elige entre `rt [20:16]` y `rd [15:11]` para `AW`)
6. **Banco de Registros** (32 registros x 32 bits: `AR1`, `AR2`, `AW`, `DW`, `en_BR`, `DR1`, `DR2`)
7. **Sign Ext** (Extensor de signo 16 → 32 bits)
8. **Mux3 (ALU_Src)** (Elige entre `DR2` y el inmediato extendido para entrada `B` de ALU)
9. **ALU** (Operaciones de 32 bits con salida `zf` Zero Flag)
10. **ALU Control** (Decodifica operación de 3 bits según `funct` y `ALU Op`)
11. **Memoria de Datos** (RAM con `Address_In`, `Data_In`, `MemRead`, `MemWrite`, `Lectura`)
12. **Mux1 (MemToReg)** (Elige entre resultado de ALU y dato de memoria para `DW`)
13. **Shift Left (branch)** (Desplaza 2 bits el offset extendido)
14. **Sumador de Branch** (`PC+4` + offset desplazado)
15. **Compuerta AND** (Evalúa `Branch AND zf` para `PCSrc`)
16. **Mux4** (Elige entre `PC+4` y dirección de branch)
17. **Shift Left (jump)** (Desplaza 2 bits el campo target: 26 → 28 bits)
18. **Mux5** (Elige entre salida de Mux4 y salto incondicional `{PC+4[31:28], target<<2}`)

---

## 🚀 Despliegue en Vercel (Paso a Paso)

La aplicación web está configurada para ser 100% estática, sin backend, permitiendo hosting gratuito ilimitado en Vercel.

1. Ve a [Vercel Dashboard](https://vercel.com/dashboard) e inicia sesión con tu cuenta de GitHub.
2. Haz clic en **"Add New..."** → **"Project"**.
3. Importa el repositorio: `https://github.com/TilinezzZ/ProyFinalSlides`.
4. Configura las siguientes opciones del proyecto:
   - **Framework Preset:** `Vite`
   - **Root Directory:** Haz clic en *Edit* y selecciona la carpeta **`web`**.
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`
5. Haz clic en **Deploy**. ¡Tu aplicación estará en línea con HTTPS automático y despliegue continuo en cada `git push` a `main`!

---

## 💻 Ejecución Local de la Web

```bash
# 1. Clonar el repositorio
git clone https://github.com/TilinezzZ/ProyFinalSlides.git
cd ProyFinalSlides/web

# 2. Instalar dependencias
npm install

# 3. Iniciar servidor de desarrollo
npm run dev

# 4. Compilar para producción
npm run build
```

---

## 🔬 Ejecución de Simulación en ModelSim

1. Abre **ModelSim** o **QuestaSim**.
2. En la consola de comandos de ModelSim, navega a la carpeta `/verilog`:
   ```tcl
   cd {ruta/del/repositorio}/verilog
   ```
3. Ejecuta el script `.do`:
   ```tcl
   do run_sim.do
   ```
4. Se compilarán todos los módulos, se cargará el testbench `tb_mips_datapath_top` y se abrirá la ventana de formas de onda (*Waves*) con todas las señales agrupadas por color y etapa arquitectónica.

---

## 👥 Créditos del Equipo (3 Integrantes)

- **Materia:** Arquitectura de Computadoras
- **Desarrollo del Datapath Monociclo & Web Interactiva:**
  - Módulos RTL Verilog y scripts de simulación ModelSim
  - Aplicación Web interactiva en Vite, React, TypeScript y Tailwind CSS
  - Documentación técnica y despliegue
