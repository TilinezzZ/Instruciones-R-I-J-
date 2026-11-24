# Resumen de pruebas reproducibles (esperado vs observado)

Generado por `VERIF/ejecutar_pruebas.py`.

## integracion

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| $t0 | 0x00000005 | 0x00000005 | OK |
| $t1 | 0xFFFFFFFF | 0xFFFFFFFF | OK |
| $t2 | 0x00008005 | 0x00008005 | OK |
| $t3 | 0x0000000A | 0x0000000A | OK |
| $t4 | 0x00000005 | 0x00000005 | OK |
| $t5 | 0x00000000 | 0x00000000 | OK |
| $t6 | 0x0000000F | 0x0000000F | OK |
| $t7 | 0x00000001 | 0x00000001 | OK |
| $s0 | 0x00000040 | 0x00000040 | OK |
| $s1 | 0x0000000A | 0x0000000A | OK |
| $s2 (omitida por beq) | 0x00000000 | 0x00000000 | OK |
| $s3 (beq no tomado) | 0x00000001 | 0x00000001 | OK |
| $s4 (contador ciclo) | 0x00000000 | 0x00000000 | OK |
| $s5 (iteraciones ciclo) | 0x00000003 | 0x00000003 | OK |
| $s7 (omitida por j) | 0x00000000 | 0x00000000 | OK |
| $t8 (destino de j) | 0x00000001 | 0x00000001 | OK |
| $zero (escritura descartada) | 0x00000000 | 0x00000000 | OK |
| mem[64..67] big-endian | 0x0000000A | 0x0000000A | OK |
| PC final (autosalto) | 96 | 96 | OK |
| ModelSim errores/advertencias | 0 errores, 0 warnings | [('0', '0'), ('0', '0')] | OK |

## frecuencia_caso1

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| caso normal: [3,7,3,9,3], clave 3 -> mem[128] (contador) | 3 | 3 | OK |
| $s3 (contador) | 3 | 3 | OK |
| halt | 0 | 0 | OK |
| ModelSim errores/advertencias | 0 errores, 0 warnings | [('0', '0'), ('0', '0')] | OK |

## frecuencia_caso2

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| sin coincidencias: [1,2,4,8], clave 5 -> mem[128] (contador) | 0 | 0 | OK |
| $s3 (contador) | 0 | 0 | OK |
| halt | 0 | 0 | OK |
| ModelSim errores/advertencias | 0 errores, 0 warnings | [('0', '0'), ('0', '0')] | OK |

## frecuencia_caso3

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| borde: un elemento negativo minimo de addi [-32768], clave -32768 -> mem[128] (contador) | 1 | 1 | OK |
| $s3 (contador) | 1 | 1 | OK |
| halt | 0 | 0 | OK |
| ModelSim errores/advertencias | 0 errores, 0 warnings | [('0', '0'), ('0', '0')] | OK |

## acceso_datos_invalido

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| halt activo | 1 | 1 | OK |
| PC detenido en el sw invalido | 8 | 8 | OK |
| memoria sin escritura (mem vacia) | {} | {} | OK |
| $t1 no modificado | 0 | 0 | OK |

## fetch_invalido

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| halt activo | 1 | 1 | OK |
| PC detenido en destino invalido | 4096 | 4096 | OK |
| $t1 no modificado | 0 | 0 | OK |

## error_ensamblador

| Verificacion | Esperado | Observado | Estado |
|---|---|---|---|
| lineas con diagnostico | [2, 3, 4, 6, 7, 8] | [2, 3, 4, 6, 7, 8] | OK |

**Resultado global: TODAS LAS PRUEBAS OK (0 FALLAS)**
