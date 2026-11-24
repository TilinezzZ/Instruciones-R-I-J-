# Frecuencia de un valor en un arreglo (sin coincidencias: [1,2,4,8], clave 5)
# Mapa de registros:
#   $s0 = base del arreglo (64)   $s1 = N   $s2 = clave   $s3 = contador (resultado)
#   $t0 = i   $t1 = direccion del elemento actual   $t2 = elemento leido
# Mapa de datos: arreglo en mem[64..], resultado en mem[128]
# Pseudocodigo:
#   cont = 0; para i = 0..N-1: si arr[i] == clave entonces cont++ ; mem[128] = cont ; detener
        addi $s0, $zero, 64
        addi $s1, $zero, 4
        addi $s2, $zero, 5
        addi $t2, $zero, 1
        sw   $t2, 0($s0)
        addi $t2, $zero, 2
        sw   $t2, 4($s0)
        addi $t2, $zero, 4
        sw   $t2, 8($s0)
        addi $t2, $zero, 8
        sw   $t2, 12($s0)
        addi $s3, $zero, 0
        addi $t0, $zero, 0
        addi $t1, $s0, 0
lazo:   beq  $t0, $s1, fin
        lw   $t2, 0($t1)
        beq  $t2, $s2, coincide
        j    siguiente
coincide: addi $s3, $s3, 1
siguiente: addi $t1, $t1, 4
        addi $t0, $t0, 1
        j    lazo
fin:    sw   $s3, 128($zero)
final:  j    final          # autosalto: punto final observable
