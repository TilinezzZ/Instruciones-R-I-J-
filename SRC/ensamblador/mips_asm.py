#!/usr/bin/env python3
"""
Ensamblador MIPS de 32 bits (dos pasadas, formato Big-Endian).
Soporta registros numericos ($0..$31) y alias estandar, etiquetas hacia adelante
y atras, generacion de listado (hex/bin) e imagen de 1 byte por direccion
compatible con $readmemh en ModelSim/Quartus.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

REG_ALIASES: Dict[str, int] = {
    "$zero": 0, "$at": 1,
    "$v0": 2, "$v1": 3,
    "$a0": 4, "$a1": 5, "$a2": 6, "$a3": 7,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11,
    "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15,
    "$s0": 16, "$s1": 17, "$s2": 18, "$s3": 19,
    "$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
    "$t8": 24, "$t9": 25,
    "$k0": 26, "$k1": 27,
    "$gp": 28, "$sp": 29, "$fp": 30, "$ra": 31,
}

# Codificacion segun consigna oficial del proyecto
R_FUNCT: Dict[str, int] = {
    "add":  0x21,
    "addu": 0x21,
    "sub":  0x23,
    "subu": 0x23,
    "and":  0x24,
    "or":   0x25,
    "nor":  0x27,
    "slt":  0x2A,
}

I_OPCODE: Dict[str, int] = {
    "addi":  0x09,
    "addiu": 0x09,
    "ori":   0x0D,
    "lw":    0x23,
    "sw":    0x2B,
    "beq":   0x04,
    "bne":   0x05,
}

J_OPCODE: Dict[str, int] = {
    "j": 0x02,
}

MEM_OFFSET_RE = re.compile(r"^\s*([+-]?(?:0x[0-9a-fA-F]+|\d+))\s*\(\s*(\$[a-zA-Z0-9_]+)\s*\)\s*$")
LABEL_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def parse_reg(token: str, line_no: int) -> int:
    t = token.strip().lower()
    if t in REG_ALIASES:
        return REG_ALIASES[t]
    if t.startswith("$") and t[1:].isdigit():
        num = int(t[1:])
        if 0 <= num <= 31:
            return num
    raise ValueError(f"ERROR linea {line_no}: registro invalido '{token.strip()}'")


def parse_int(token: str, line_no: int, nombre: str = "inmediato") -> int:
    t = token.strip()
    try:
        return int(t, 0)
    except ValueError:
        raise ValueError(f"ERROR linea {line_no}: {nombre} invalido '{t}'")


def strip_comment(line: str) -> str:
    idx = line.find("#")
    if idx != -1:
        line = line[:idx]
    idx2 = line.find("//")
    if idx2 != -1:
        line = line[:idx2]
    return line.strip()


def ensamblar(source: str) -> Tuple[List[Tuple[int, int, str]], List[str]]:
    """
    Ensambla codigo fuente MIPS en dos pasadas.
    Retorna:
      - instrucciones: lista de (direccion_byte, palabra_32bit, linea_fuente)
      - errores: lista de mensajes de diagnostico por linea
    """
    raw_lines = source.splitlines()
    labels: Dict[str, int] = {}
    parsed_stmts: List[Tuple[int, int, str, str]] = []  # (addr, line_no, clean_inst, raw_line)
    errores: List[str] = []

    # Pasada 1: recoleccion de etiquetas y direcciones
    pc = 0
    for line_no, raw in enumerate(raw_lines, start=1):
        clean = strip_comment(raw)
        if not clean:
            continue

        # Procesar una o mas etiquetas al inicio de la linea
        while ":" in clean:
            lbl_part, rest = clean.split(":", 1)
            lbl = lbl_part.strip()
            if not LABEL_RE.match(lbl):
                errores.append(f"ERROR linea {line_no}: etiqueta invalida '{lbl}'")
            elif lbl in labels:
                errores.append(f"ERROR linea {line_no}: etiqueta duplicada '{lbl}'")
            else:
                labels[lbl] = pc
            clean = rest.strip()

        if clean:
            parsed_stmts.append((pc, line_no, clean, raw.strip()))
            pc += 4

    # Pasada 2: codificacion de instrucciones y validacion de operandos
    resultados: List[Tuple[int, int, str]] = []
    for addr, line_no, clean, raw_src in parsed_stmts:
        parts = clean.split(None, 1)
        mnem = parts[0].lower()
        arg_str = parts[1] if len(parts) > 1 else ""
        args = [a.strip() for a in arg_str.split(",") if a.strip()] if arg_str else []

        try:
            if mnem in R_FUNCT:
                if len(args) != 3:
                    raise ValueError(f"ERROR linea {line_no}: '{mnem}' requiere 3 operandos ($rd, $rs, $rt)")
                rd = parse_reg(args[0], line_no)
                rs = parse_reg(args[1], line_no)
                rt = parse_reg(args[2], line_no)
                shamt = 0
                funct = R_FUNCT[mnem]
                word = (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct

            elif mnem in ("addi", "addiu"):
                if len(args) != 3:
                    raise ValueError(f"ERROR linea {line_no}: '{mnem}' requiere 3 operandos ($rt, $rs, imm)")
                rt = parse_reg(args[0], line_no)
                rs = parse_reg(args[1], line_no)
                imm = parse_int(args[2], line_no, "inmediato")
                if not (-32768 <= imm <= 32767):
                    raise ValueError(
                        f"ERROR linea {line_no}: inmediato de {mnem} fuera de rango ({imm}); permitido -32768..32767"
                    )
                word = (I_OPCODE[mnem] << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

            elif mnem == "ori":
                if len(args) != 3:
                    raise ValueError(f"ERROR linea {line_no}: 'ori' requiere 3 operandos ($rt, $rs, imm)")
                rt = parse_reg(args[0], line_no)
                rs = parse_reg(args[1], line_no)
                imm = parse_int(args[2], line_no, "inmediato")
                if not (0 <= imm <= 65535):
                    raise ValueError(
                        f"ERROR linea {line_no}: inmediato de ori fuera de rango ({imm}); permitido 0..65535"
                    )
                word = (I_OPCODE["ori"] << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

            elif mnem in ("lw", "sw"):
                if len(args) != 2:
                    raise ValueError(f"ERROR linea {line_no}: '{mnem}' requiere 2 operandos ($rt, desp($rs))")
                rt = parse_reg(args[0], line_no)
                m = MEM_OFFSET_RE.match(args[1])
                if not m:
                    raise ValueError(f"ERROR linea {line_no}: formato de direccion invalido '{args[1]}'; esperado desp($rs)")
                imm = parse_int(m.group(1), line_no, "desplazamiento")
                rs = parse_reg(m.group(2), line_no)
                if not (-32768 <= imm <= 32767):
                    raise ValueError(
                        f"ERROR linea {line_no}: desplazamiento de {mnem} fuera de rango ({imm}); permitido -32768..32767"
                    )
                word = (I_OPCODE[mnem] << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

            elif mnem in ("beq", "bne"):
                if len(args) != 3:
                    raise ValueError(f"ERROR linea {line_no}: '{mnem}' requiere 3 operandos ($rs, $rt, etiqueta)")
                rs = parse_reg(args[0], line_no)
                rt = parse_reg(args[1], line_no)
                target_tok = args[2]
                pc_next = addr + 4
                if target_tok in labels:
                    dest_addr = labels[target_tok]
                    if (dest_addr - pc_next) % 4 != 0:
                        raise ValueError(f"ERROR linea {line_no}: destino desalineado '{target_tok}'")
                    offset = (dest_addr - pc_next) // 4
                else:
                    try:
                        offset = int(target_tok, 0)
                    except ValueError:
                        raise ValueError(f"ERROR linea {line_no}: etiqueta indefinida '{target_tok}'")
                if not (-32768 <= offset <= 32767):
                    raise ValueError(
                        f"ERROR linea {line_no}: desplazamiento de {mnem} fuera de rango ({offset}); permitido -32768..32767"
                    )
                word = (I_OPCODE[mnem] << 26) | (rs << 21) | (rt << 16) | (offset & 0xFFFF)

            elif mnem == "j":
                if len(args) != 1:
                    raise ValueError(f"ERROR linea {line_no}: 'j' requiere 1 operando (etiqueta o direccion)")
                target_tok = args[0]
                pc_next = addr + 4
                if target_tok in labels:
                    dest_addr = labels[target_tok]
                else:
                    try:
                        dest_addr = int(target_tok, 0)
                    except ValueError:
                        raise ValueError(f"ERROR linea {line_no}: etiqueta indefinida '{target_tok}'")
                if dest_addr < 0 or (dest_addr % 4) != 0:
                    raise ValueError(f"ERROR linea {line_no}: destino de salto j desalineado o negativo ({dest_addr})")
                if (dest_addr & 0xF0000000) != (pc_next & 0xF0000000):
                    raise ValueError(
                        f"ERROR linea {line_no}: salto j fuera de la region de 256 MiB de PC+4 (0x{dest_addr:08X})"
                    )
                index = (dest_addr >> 2) & 0x03FFFFFF
                word = (J_OPCODE["j"] << 26) | index

            else:
                raise ValueError(f"ERROR linea {line_no}: mnemonico invalido '{mnem}'")

            resultados.append((addr, word, raw_src))

        except ValueError as exc:
            errores.append(str(exc))

    def _err_key(msg: str) -> int:
        m = re.search(r"linea\s+(\d+)", msg)
        return int(m.group(1)) if m else 0

    errores.sort(key=_err_key)
    return resultados, errores


def generar_hex_big_endian(instrucciones: List[Tuple[int, int, str]]) -> str:
    """Genera imagen cargable con 1 byte por direccion en orden Big-Endian."""
    lineas: List[str] = []
    for _, word, _ in instrucciones:
        lineas.append(f"{(word >> 24) & 0xFF:02X}")
        lineas.append(f"{(word >> 16) & 0xFF:02X}")
        lineas.append(f"{(word >> 8) & 0xFF:02X}")
        lineas.append(f"{word & 0xFF:02X}")
    return "\n".join(lineas) + ("\n" if lineas else "")


def generar_listado(instrucciones: List[Tuple[int, int, str]]) -> str:
    """Genera tabla de listado: direccion, palabra hex, palabra bin y fuente."""
    lineas = ["DIR   PALABRA(hex)  PALABRA(bin)                       FUENTE"]
    for addr, word, src in instrucciones:
        lineas.append(f"{addr:04X}  0x{word:08X}    {word:032b}   {src}")
    return "\n".join(lineas) + "\n"


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Ensamblador MIPS 32-bit Big-Endian")
    parser.add_argument("entrada", type=Path, help="Archivo fuente .asm")
    parser.add_argument("--hex", dest="hex_out", type=Path, help="Archivo de salida de imagen byte por linea (.hex)")
    parser.add_argument("--lst", dest="lst_out", type=Path, help="Archivo de salida de listado (.lst)")
    args = parser.parse_args(argv)

    source = args.entrada.read_text(encoding="utf-8")
    instrucciones, errores = ensamblar(source)

    if errores:
        for err in errores:
            print(err, file=sys.stderr)
        return 1

    hex_text = generar_hex_big_endian(instrucciones)
    lst_text = generar_listado(instrucciones)

    if args.hex_out:
        args.hex_out.parent.mkdir(parents=True, exist_ok=True)
        args.hex_out.write_text(hex_text, encoding="utf-8")
    else:
        print(hex_text, end="")

    if args.lst_out:
        args.lst_out.parent.mkdir(parents=True, exist_ok=True)
        args.lst_out.write_text(lst_text, encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
