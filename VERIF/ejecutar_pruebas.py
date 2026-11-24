#!/usr/bin/env python3
"""
Suite reproducible de pruebas ISA, integracion, algoritmo (3 entradas) y casos negativos.
Ensambla los programas en SRC/programas/, ejecuta la simulacion en ModelSim
sobre RTL/ + VERIF/tb_programa.v y genera VERIF/resultados/RESUMEN.md.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parent.parent
RTL_DIR = ROOT / "RTL"
VERIF_DIR = ROOT / "VERIF"
PROG_DIR = ROOT / "SRC" / "programas"
RES_DIR = VERIF_DIR / "resultados"

sys.path.insert(0, str(ROOT / "SRC" / "ensamblador"))
import mips_asm  # noqa: E402


def find_vsim() -> str:
    env_vsim = os.environ.get("MODELSIM_VSIM")
    if env_vsim and Path(env_vsim).exists():
        return env_vsim
    candidates = [
        Path(r"C:\intelFPGA\20.1\modelsim_ase\win32aloem\vsim.exe"),
        Path(r"C:\intelFPGA_lite\20.1\modelsim_ase\win32aloem\vsim.exe"),
        Path(r"C:\modeltech64_2020.4\win64\vsim.exe"),
    ]
    for c in candidates:
        if c.exists():
            return str(c)
    which_vsim = shutil.which("vsim")
    if which_vsim:
        return which_vsim
    raise FileNotFoundError("No se encontro vsim.exe de ModelSim. Configure MODELSIM_VSIM.")


def run_modelsim(caso_dir: Path, ciclos: int = 200) -> Tuple[str, Dict[int, int], Dict[int, int], int, int, List[Tuple[str, str]]]:
    vsim = find_vsim()
    rtl_files = sorted(RTL_DIR.glob("*.v"))
    vlog_list = " ".join(p.as_posix() for p in rtl_files + [VERIF_DIR / "tb_programa.v"])
    sim_do = (
        "vlib work\n"
        "vmap work work\n"
        f"vlog -work work {vlog_list}\n"
        f'vsim -c -onfinish stop work.tb_programa "+CICLOS={ciclos}" -do "run -all; quit -f"\n'
        "quit -f\n"
    )
    do_path = caso_dir / "sim.do"
    do_path.write_text(sim_do, encoding="utf-8")

    proc = subprocess.run(
        [vsim, "-c", "-do", "sim.do"],
        cwd=str(caso_dir),
        capture_output=True,
        text=True,
    )
    log_text = proc.stdout + ("\n" + proc.stderr if proc.stderr else "")
    (caso_dir / "simulacion.log").write_text(log_text, encoding="utf-8")

    # Limpieza de temporales locales de ModelSim
    for tmp in ["work", "modelsim.ini", "transcript", "sim.do"]:
        p = caso_dir / tmp
        if p.is_dir():
            shutil.rmtree(p, ignore_errors=True)
        elif p.exists():
            p.unlink(missing_ok=True)

    regs: Dict[int, int] = {}
    mem: Dict[int, int] = {}
    final_pc = -1
    final_halt = -1

    for line in log_text.splitlines():
        m_pc = re.search(r"FINAL_PC=(\d+)\s+FINAL_HALT=(\d+)", line)
        if m_pc:
            final_pc = int(m_pc.group(1))
            final_halt = int(m_pc.group(2))
        m_reg = re.search(r"REG\s+(\d+)=([0-9a-fA-F]{8})", line)
        if m_reg:
            regs[int(m_reg.group(1))] = int(m_reg.group(2), 16)
        m_mem = re.search(r"MEM\s+(\d+)=([0-9a-fA-F]{8})", line)
        if m_mem:
            mem[int(m_mem.group(1))] = int(m_mem.group(2), 16)

    err_warn = re.findall(r"Errors:\s*(\d+),\s*Warnings:\s*(\d+)", log_text)
    return log_text, regs, mem, final_pc, final_halt, err_warn


def assemble_case(asm_name: str, out_dir: Path) -> Tuple[List[Tuple[int, int, str]], List[str]]:
    out_dir.mkdir(parents=True, exist_ok=True)
    source = (PROG_DIR / asm_name).read_text(encoding="utf-8")
    insts, errs = mips_asm.ensamblar(source)
    if not errs:
        (out_dir / "programa.hex").write_text(mips_asm.generar_hex_big_endian(insts), encoding="utf-8")
        (out_dir / "programa.lst").write_text(mips_asm.generar_listado(insts), encoding="utf-8")
    return insts, errs


def main() -> int:
    RES_DIR.mkdir(parents=True, exist_ok=True)
    sections: List[Tuple[str, List[Tuple[str, str, str, bool]]]] = []
    any_fail = False

    # 1. Integracion completa
    cdir = RES_DIR / "integracion"
    _, errs = assemble_case("integracion.asm", cdir)
    assert not errs, f"Error ensamblando integracion.asm: {errs}"
    _, regs, mem, fpc, fhalt, ew = run_modelsim(cdir, ciclos=80)
    checks_int = [
        ("$t0", "0x00000005", f"0x{regs.get(8, 0):08X}", regs.get(8) == 5),
        ("$t1", "0xFFFFFFFF", f"0x{regs.get(9, 0):08X}", regs.get(9) == 0xFFFFFFFF),
        ("$t2", "0x00008005", f"0x{regs.get(10, 0):08X}", regs.get(10) == 0x00008005),
        ("$t3", "0x0000000A", f"0x{regs.get(11, 0):08X}", regs.get(11) == 10),
        ("$t4", "0x00000005", f"0x{regs.get(12, 0):08X}", regs.get(12) == 5),
        ("$t5", "0x00000000", f"0x{regs.get(13, 0):08X}", regs.get(13) == 0),
        ("$t6", "0x0000000F", f"0x{regs.get(14, 0):08X}", regs.get(14) == 15),
        ("$t7", "0x00000001", f"0x{regs.get(15, 0):08X}", regs.get(15) == 1),
        ("$s0", "0x00000040", f"0x{regs.get(16, 0):08X}", regs.get(16) == 64),
        ("$s1", "0x0000000A", f"0x{regs.get(17, 0):08X}", regs.get(17) == 10),
        ("$s2 (omitida por beq)", "0x00000000", f"0x{regs.get(18, 0):08X}", regs.get(18) == 0),
        ("$s3 (beq no tomado)", "0x00000001", f"0x{regs.get(19, 0):08X}", regs.get(19) == 1),
        ("$s4 (contador ciclo)", "0x00000000", f"0x{regs.get(20, 0):08X}", regs.get(20) == 0),
        ("$s5 (iteraciones ciclo)", "0x00000003", f"0x{regs.get(21, 0):08X}", regs.get(21) == 3),
        ("$s7 (omitida por j)", "0x00000000", f"0x{regs.get(23, 0):08X}", regs.get(23) == 0),
        ("$t8 (destino de j)", "0x00000001", f"0x{regs.get(24, 0):08X}", regs.get(24) == 1),
        ("$zero (escritura descartada)", "0x00000000", f"0x{regs.get(0, 0):08X}", regs.get(0) == 0),
        ("mem[64..67] big-endian", "0x0000000A", f"0x{mem.get(64, 0):08X}", mem.get(64) == 10),
        ("PC final (autosalto)", "96", str(fpc), fpc == 96),
        ("ModelSim errores/advertencias", "0 errores, 0 warnings", str(ew), all(e == "0" and w == "0" for e, w in ew) and len(ew) > 0),
    ]
    sections.append(("integracion", checks_int))

    # 2. Algoritmo Frecuencia - 3 entradas (incluyendo borde)
    frec_cases = [
        ("frecuencia_caso1", "frecuencia_caso1.asm", "caso normal: [3,7,3,9,3], clave 3 -> mem[128] (contador)", 3),
        ("frecuencia_caso2", "frecuencia_caso2.asm", "sin coincidencias: [1,2,4,8], clave 5 -> mem[128] (contador)", 0),
        ("frecuencia_caso3", "frecuencia_caso3.asm", "borde: un elemento negativo minimo de addi [-32768], clave -32768 -> mem[128] (contador)", 1),
    ]
    for name, fname, desc, exp in frec_cases:
        cdir = RES_DIR / name
        _, errs = assemble_case(fname, cdir)
        assert not errs, f"Error ensamblando {fname}: {errs}"
        _, regs, mem, fpc, fhalt, ew = run_modelsim(cdir, ciclos=250)
        obs_mem = mem.get(128, 0)
        obs_s3 = regs.get(19, 0)
        checks = [
            (desc, str(exp), str(obs_mem), obs_mem == exp),
            ("$s3 (contador)", str(exp), str(obs_s3), obs_s3 == exp),
            ("halt", "0", str(fhalt), fhalt == 0),
            ("ModelSim errores/advertencias", "0 errores, 0 warnings", str(ew), all(e == "0" and w == "0" for e, w in ew) and len(ew) > 0),
        ]
        sections.append((name, checks))

    # 3. Acceso a datos invalido (desalineado)
    cdir = RES_DIR / "acceso_datos_invalido"
    _, errs = assemble_case("acceso_datos_invalido.asm", cdir)
    assert not errs, f"Error ensamblando acceso_datos_invalido.asm: {errs}"
    _, regs, mem, fpc, fhalt, _ = run_modelsim(cdir, ciclos=20)
    sections.append(("acceso_datos_invalido", [
        ("halt activo", "1", str(fhalt), fhalt == 1),
        ("PC detenido en el sw invalido", "8", str(fpc), fpc == 8),
        ("memoria sin escritura (mem vacia)", "{}", str(mem), len(mem) == 0),
        ("$t1 no modificado", "0", str(regs.get(9, 0)), regs.get(9, 0) == 0),
    ]))

    # 4. Fetch invalido (fuera de rango)
    cdir = RES_DIR / "fetch_invalido"
    _, errs = assemble_case("fetch_invalido.asm", cdir)
    assert not errs, f"Error ensamblando fetch_invalido.asm: {errs}"
    _, regs, mem, fpc, fhalt, _ = run_modelsim(cdir, ciclos=20)
    sections.append(("fetch_invalido", [
        ("halt activo", "1", str(fhalt), fhalt == 1),
        ("PC detenido en destino invalido", "4096", str(fpc), fpc == 4096),
        ("$t1 no modificado", "0", str(regs.get(9, 0)), regs.get(9, 0) == 0),
    ]))

    # 5. Error de ensamblador (diagnosticos por linea)
    cdir = RES_DIR / "error_ensamblador"
    cdir.mkdir(parents=True, exist_ok=True)
    _, errs = assemble_case("error_ensamblador.asm", cdir)
    (cdir / "diagnosticos.txt").write_text("\n".join(errs) + "\n", encoding="utf-8")
    obs_lines = [int(m.group(1)) for e in errs for m in [re.search(r"linea\s+(\d+)", e)] if m]
    exp_lines = [2, 3, 4, 6, 7, 8]
    sections.append(("error_ensamblador", [
        ("lineas con diagnostico", str(exp_lines), str(obs_lines), obs_lines == exp_lines),
    ]))

    # Generar RESUMEN.md
    md_lines = [
        "# Resumen de pruebas reproducibles (esperado vs observado)",
        "",
        "Generado por `VERIF/ejecutar_pruebas.py`.",
        "",
    ]
    for sec_name, rows in sections:
        md_lines.append(f"## {sec_name}")
        md_lines.append("")
        md_lines.append("| Verificacion | Esperado | Observado | Estado |")
        md_lines.append("|---|---|---|---|")
        for label, exp_s, obs_s, ok in rows:
            if not ok:
                any_fail = True
            md_lines.append(f"| {label} | {exp_s} | {obs_s} | {'OK' if ok else 'FALLA'} |")
        md_lines.append("")

    md_lines.append(f"**Resultado global: {'TODAS LAS PRUEBAS OK (0 FALLAS)' if not any_fail else 'HAY FALLAS'}**")
    (RES_DIR / "RESUMEN.md").write_text("\n".join(md_lines) + "\n", encoding="utf-8")

    print("\n".join(md_lines[-5:]))
    return 1 if any_fail else 0


if __name__ == "__main__":
    raise SystemExit(main())
