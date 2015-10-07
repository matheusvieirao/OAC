.data
# Implementacao de aritmetica inteira de 64 bits
# Sendo x={$a1,$a0} e y={$a3,$a2} ->{HI,LO} a ler outros valores.

.text
MAIN: 
	li $a0, -1
	li $a1, -1
	li $a2, 5
	li $a3, 0
	jal MULTL
	jal EXIT
	jal MULTL
	jal ADDL0
	jal SUBL
			
ADDL0:	move $t0, $a0	#Copia os valores de x={$a1,$a0} e y={$a3,$a2}
	move $t1, $a1	# para os registradores $t1$t0 e $t3$t2 
	move $t2, $a2
	move $t3, $a3
	
# {HI,LO}=x+y	
ADDL:	addu $t0, $a0, $t2	#soma Xlo + Yl0
	nor $t5, $a0, $zero	# -Xlo
	sltu $t5, $t5, $t2	# 2³²-1 - Xlo < Ylo  (pois Xlo + Ylo < Maximo numero possivel)
	beqz $t5, NOOVFL	#t1 + t2 > 2³²-1
	addiu $t1, $t1, 1	#Soma 1 a $t1 se houve overflow
NOOVFL:	addu $t1, $t1, $t3	#soma Xhi + Yhi
	mtlo $t0
	mthi $t1
	jr $ra

# {HI,LO}=x-y
SUBL:	addi $sp, $sp, -4	# empilha ra na memoria
	sw $ra, 0($sp)
	nor $t3, $a3, $a3	#Complemento de 1 em Yhi
 	bnez $a2, SUBL2		#verifica se pode ocorrer overflow no complento de 2
 	addiu $t3, $t3, 1	#se ocorrer, soma 1 bit em $t1(Xhi)	
SUBL2:	nor $t2, $a2, $a2	#Complemento de 1 em Ylo
 	addiu $t2, $t2, 1	#Complemento de 2 em Ylo
 	jal ADDL		# Soma $a1$a0 + (- $a3$a2)
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# desempilha ra da memoria
 	jr $ra

# {HI,LO,$v1,$v0}=x*y
MULTL:	add $t9, $zero, $zero	 #t9 sera a flag de condicoes. se 0  X>=0 e Y>=0,  se 1  X<0,  se 2  Y<0, se 3  X<0 e Y<0, 

	bgez $a1, XPOS 		# pula se X Positivo ou 0 (so precisa olhar os bits mais significativos)
	addi $t9, $t9, 1
	nor $a1, $a1, $a1	#inverte o numerador para ele ficar positivo 
	bnez $a0, XPOSOV	#verifica se pode dar overflow no complemento de 2
	addiu $a1, $a1, 1	#se ocorrer soma 1 bit no mais significativo
XPOSOV:	nor $a0, $a0, $a0	#Complemento de 1 em LO
	addi $a0, $a0, 1	#Complemento de 2 em LO
XPOS:	bgez  $a3, YPOS		# pula se Y Positivo ou igual 0
	addi $t9, $t9, 2
	nor $a3, $a3, $a3	#inverte o denominador para ele ficar positivo
	bnez $a2, YPOSOV
	addiu $a3, $a3, 1
YPOSOV: nor $a2, $a2, $a2
	addi $a2, $a2, 1
YPOS:	
	#aqui X e Y ja estao positivos

	mul $t0, $a0, $a2 # t0 = LSB(a*b)
	mfhi $t1	# t1 MSB(a*b)	
	mul $t2, $a0, $a3 # t2 = LSB(a*B)
	mfhi $t3	# t3 = MSB(a*B)
	mul $t4, $a1, $a2 # t4 = LSB(A*b)
	mfhi $t5	# t5 = MSB(A*b)	
	mul $t6, $a1, $a3 # t6 = LSB(A*B)
	mfhi $t7	#t7 = MSB(A*B)
	
	addu $v0, $t0, $zero	# registra o v0
	addu $t0, $zero, $zero 	#zera o t0 para o usar como contador de overflow
	
	addi $sp, $sp, -20
	sw $s0, 0($sp)		#salva os $s para os utilizar na operacao ADDOVF
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s5, 12($sp)
	sw $ra, 16($sp)
	
	move $s0, $t1
	move $s1, $t4
	jal ADDOVF		#s0 = arg1 | s1 = arg2 | s3 = soma | s5 = flag de overflow sendo 0 = no overflow e 1 = overflow
	move $t8, $s3
	beqz $s5, NOOVFL2	
 	addiu $t0, $t0, 1	#guarda o overflow em $t0 para depois somar ele
NOOVFL2:move $s0, $t8
	move $s1, $t2
	jal ADDOVF
	move $v1, $s3		#registra v1
	beqz $s5, NOOVFL3
	addiu $t0, $t0, 1	#guarda o overflow em $t0 para depois somar ele 

NOOVFL3:move $s0, $t0		#soma o overflow passado 
	addu $t0, $zero, $zero	#zera o contador de overflow
	move $s1, $t5
	jal ADDOVF
	move $t8, $s3
	beqz $s5, NOOVFL4	
 	addiu $t0, $t0, 1	#guarda o overflow em $t0
NOOVFL4:move $s0, $t8		
	move $s1, $t3
	jal ADDOVF
	move $t8, $s3
	beqz $s5, NOOVFL5	
 	addiu $t0, $t0, 1	#guarda o overflow em $t0
NOOVFL5:move $s0, $t8		
	move $s1, $t6
	jal ADDOVF
	mtlo $s3		#registra lo
	beqz $s5, NOOVFL6	
 	addiu $t0, $t0, 1	#guarda o overflow em $t0

NOOVFL6:addu $t7, $t7, $t0
	mthi $t7
	
	beq $t9, 3, XYPOS	#se os dois forem negativos nao precisa negativar o resultado
	beq $t9, 0, XYPOS	#se os dois forem positivos nao precisa negativar o resultado
	mflo $s0
	mfhi $s1
	bnez $v0, NOVF		#nao ocorrera overflow no complemento de 2
	bnez $v1, V0OVF		#ocorrera overflow de v0 para v1
	bnez $s0, V1OVF		#ocorrera overflow de v1 para lo
V0OVF:	addi $v1, $v1, 1
	j NOVF
V1OVF:	addi $s0, $s0, 1
	j NOVF
NOVF: 	nor $s1, $s1, $s1	
	nor $s0, $s0, $s0
	nor $v1, $v1, $v1
	nor $v0, $v0, $v0
	addi $v0, $v0, 1
	mtlo $s0
	mthi $s1
	
XYPOS:	lw $s0, 0($sp)		#recupera os $s
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s5, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra	

#s0 = arg1 | s1 = arg2 | s3 = soma | s5 = flag de overflow sendo 0 = no overflow ; 1 = overflow
ADDOVF:addu $s3, $s0, $s1	
	nor $s5, $s0, $zero	
	sltu $s5, $s5, $s1	# 0 = no overflow ; 1 = overflow
	jr $ra

 	
# floor(x/y)={Hi,LO} e (x%y)={$v1,$v0}
#Numerador: a1a0 | Numerador Positivo s1s0 | Denominador: a3a2 | Denominador positivo s3s2 | Quociente: s5s4 | Resto: s7s6
DIVL:	
	move $s0, $a0	#Copia os valores de N={$a1,$a0} e D={$a3,$a2}
	move $s1, $a1	# para os registradores $s1$s0 e $s3$s2 
	move $s2, $a2
	move $s3, $a3
	addi $sp, $sp, -36	# libera espaço na memoria pra salvar ra e s0 a s7
	sw $ra, 0($sp)	
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	add $t9, $zero, $zero	 #t9 sera a flag de condicoes. se 0  N>0 e D>0,  se 1  N<0,  se 2  D<0, se 3  N<0 e D<0, 
	bnez $s2, DNNULO
	bnez $s3, DNNULO 	# continua a equacao normalmente se o denominador nao for nulo
	j DNULO			# nao efetua a divisao se o denominador for nulo
DNNULO:bgez $s1, NPOS 		# pula se Numerador Positivo ou 0 (so precisa olhar os bits mais significativos)
	addi $t9, $t9, 1
	nor $s1, $s1, $s1	#inverte o numerador para ele ficar positivo 
	bnez $s0, NPOSOV	#verifica se pode dar overflow no complemento de 2
	addiu $s1, $s1, 1	#se ocorrer soma 1 bit no mais significativo
NPOSOV:	nor $s0, $s0, $s0	#Complemento de 1 em LO
	addi $s0, $s0, 1	#Complemento de 2 em LO
NPOS:	bgez  $s3, DPOS		# pula se Denominador Positivo ou igual 0
	addi $t9, $t9, 2
	nor $s3, $s3, $s3	#inverte o denominador para ele ficar positivo
	bnez $s2, DPOSOV
	addiu $s3, $s3, 1
DPOSOV: nor $s2, $s2, $s2
	addi $s2, $s2, 1
				#nesse ponto N e D já estao positivos
DPOS:	li $s4, 0		#Q = 0
	li $s5, 0
	move $s6, $s0		#R = N
	move $s7, $s1	
LOOP:	bne $s7, $s3, DIF	#se os bits mais significativos forem diferentes os compara para ver quem é maior
	blt $s6, $s2, SAIRDIV	#se nao compara os menos
DIF:	blt $s7, $s3, SAIRDIV	#sair do loop se R < D
				# Enquanto R >= D  ;  Q = Q++  ;  R = R-D
	move $a0, $s4
	move $a1, $s5
	addi $a2, $zero, 1
	move $a3, $0
	jal ADDL0			# Q = Q + 1
	mfhi $s5
	mflo $s4
	move $a0, $s6
	move $a1, $s7
	move $a2, $s2
	move $a3, $s3
	jal SUBL			# R = R- D
	mfhi $s7
	mflo $s6
	j LOOP
SAIRDIV:
	beq $t9, 3, POSITIVO
	beq $t9, 0, POSITIVO
	
	nor $s5, $s5, $s5	#inverte o QUOCIENTE para ele ficar negativo 
	bnez $s4, DIVOV1	#verifica se pode dar overflow no complemento de 2
	addiu $s5, $s5, 1	#se ocorrer soma 1 bit no mais significativo
DIVOV1:	nor $s4, $s4, $s4	#Complemento de 1 em LO
	addi $s4, $s4, 1	#Complemento de 2 em LO
	nor $s7, $s7, $s7	#inverte o RESTO para ele ficar negativo
	bnez $s6, DIVOV2
	addiu $s7, $s7, 1
DIVOV2: nor $s6, $s6, $s6	#Complemento de 1 em LO
	addi $s6, $s6, 1	#Complemento de 2 em LO
			
POSITIVO:mthi $s5
	mtlo $s4
	move $v1, $s7
	move $v0, $s6

	
	lw $ra, 0($sp)	
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	
	jr $ra

DNULO: #erro! nao pode dividir por 0
	lw $ra, 0($sp)	
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36
	
	jr $ra


#print64(long long int), que apresente o numero de 64 bits {$a1,$a0} na tela, e print128( long
#long long long int x), que apresente o numero de 128 bits {$a3,$a2,$a1,$a0}
PRINT64:


EXIT: 	
	move $at, $v0 #so pra nao apagar o v0 da multiplicacao nos testes
	li $v0, 10
	syscall
