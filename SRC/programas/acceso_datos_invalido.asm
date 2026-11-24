# Prueba negativa: acceso a memoria de datos desalineado (direccion 2 no multiplo de 4)
        addi $s0, $zero, 2
        addi $t0, $zero, 7
        sw   $t0, 0($s0)             # direccion 2 no alineada a 4 -> halt sin escritura
        addi $t1, $zero, 1           # no debe ejecutarse
