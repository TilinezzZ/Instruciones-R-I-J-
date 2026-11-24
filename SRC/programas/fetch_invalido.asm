# Prueba negativa: salto hacia direccion fuera del rango de la memoria de instrucciones
        addi $t0, $zero, 1
        j    0x1000                  # PC = 4096 (> 1020) -> halt visible en fetch
        addi $t1, $zero, 1           # no debe ejecutarse
