MAIN: 
addi $a0, $zero, 0xffffffff
addi $a1, $zero, 0x00000000
addi $a2, $zero, 0x0000000f
addi $a3, $zero, 0x0000000f

jal addl
jal EXIT

#Funcao que soma dois long long, um guardado em a0 e a1 e o outro em a2 e a3 e retorna o resultado em v0 e v1
addl:	add $t0, $a0, $a2
	bleu $a0, $t0, no_over1 #pula se nao tiver overflow nos algarismos menos significativos
	li $t1, 0xffffffff
	blt  $t1, $a1, carry1 #ve se pode add 1 em a1 sem dar overflow
	j overflow
carry1:	addi $a1, $a1, 1
no_over1: add $t1, $a1, $a3
	bleu $a1, $t1, no_over2 #pula se nao tiver overflow nos algarismos mais significativos
	j overflow
no_over2: mtlo, $t0
	mthi, $t1
	jr $ra
overflow: li, $t0, 0xffffffff
	mtlo, $t0
	mthi, $t0
	jr $ra

EXIT: 	li, $v0, 10
	syscall
