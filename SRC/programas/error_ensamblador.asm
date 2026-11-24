# Prueba negativa: errores de sintaxis, operandos y etiquetas en el ensamblador
        addi $t0, $zero, 40000       # linea 2: inmediato fuera de rango (-32768..32767)
        foo  $t0, $t1, $t2           # linea 3: mnemonico invalido
        add  $t9x, $t0, $t1          # linea 4: registro invalido
dup:    addi $t1, $zero, 1
dup:    addi $t2, $zero, 2           # linea 6: etiqueta duplicada
        beq  $t1, $t2, no_existe     # linea 7: etiqueta indefinida
        ori  $t3, $zero, -1          # linea 8: inmediato ori fuera de rango (0..65535)
