# Prueba de integracion completa de la ISA minima MIPS 32-bit
# Verifica: fetch big-endian, $zero inmutable, extension con signo y con ceros,
# operaciones R, lw/sw big-endian, beq tomado/no tomado/hacia atras y j omitiendo instruccion.
        addiu $t0, $zero, 5          # 0x24080005 -> bytes 24 08 00 05 ; $t0 = 5
        addi  $t1, $zero, -1         # extension con signo -> $t1 = 0xFFFFFFFF
        ori   $t2, $zero, 0x8005     # extension con ceros -> $t2 = 0x00008005
        add   $zero, $t0, $t0        # escritura a $zero descartada
        add   $t3, $t0, $t0          # $t3 = 10
        sub   $t4, $t3, $t0          # $t4 = 5
        and   $t5, $t3, $t0          # $t5 = 10 & 5 = 0
        or    $t6, $t3, $t0          # $t6 = 15
        slt   $t7, $t1, $t0          # -1 < 5 con signo -> $t7 = 1
        addi  $s0, $zero, 64
        sw    $t3, 0($s0)            # mem[64..67] = 00 00 00 0A
        lw    $s1, 0($s0)            # $s1 = 10
        beq   $s1, $t3, tomada       # tomada (10 == 10)
        addi  $s2, $zero, 99         # OMITIDA: $s2 debe seguir en 0
tomada: beq   $t0, $t3, nunca        # no tomada (5 != 10)
        addi  $s3, $zero, 1          # se ejecuta: $s3 = 1
nunca:  addi  $s4, $zero, 3
lazo:   addi  $s5, $s5, 1            # cuerpo del ciclo (3 iteraciones)
        addi  $s4, $s4, -1
        beq   $s4, $zero, salir
        beq   $zero, $zero, lazo     # rama hacia atras (siempre tomada)
salir:  j     fin
        addi  $s7, $zero, 77         # OMITIDA por j: $s7 debe seguir en 0
fin:    addi  $t8, $zero, 1
final:  j     final                  # autosalto observable en PC = 96
