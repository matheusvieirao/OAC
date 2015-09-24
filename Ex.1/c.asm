.data
VAL_A: .asciiz "\nDigite valor de a: "
VAL_B: .asciiz "\nDigite valor de b: "
VAL_C: .asciiz "\nDigite valor de c: "
I: .asciiz " i"
PLUS: .asciiz " + "
MINUS: .asciiz " - "
R1: .asciiz "R(1) = "
R2: .asciiz "\nR(2) = "

.text
#testes
#Real: a=1, b=-3, c=-10, x1=5, x2=-2
#Complexo: a=1, b=-4, c=5, x1=2+1i, x2=2-i1

###########################################
# MAIN 
###########################################
MAIN:

PRINT_A: li $v0, 4
	 la $a0, VAL_A
	 syscall
	 j READ_A

PRINT_B: li $v0, 4
	 la $a0, VAL_B
	 syscall
	 j READ_B

PRINT_C: li $v0, 4
	 la $a0, VAL_C
	 syscall
	 j READ_C

READ_A: li $v0, 6
	syscall
	mov.s $f10, $f0 
	j PRINT_B
	
READ_B: li $v0, 6
	syscall
	mov.s $f11, $f0
	j PRINT_C

READ_C: li $v0, 6
	syscall

MOVER:	li $t0, 4
	li $t1, 2
	mtc1 $t0, $f3
	mtc1 $t1, $f4
	cvt.s.w $f3, $f3 
	cvt.s.w $f4, $f4 
	mfc1 $a0, $f10 #move para regs de args
	mfc1 $a1, $f11
	mfc1 $a2, $f0	
	mul.s $f3, $f3, $f10
	mul.s $f4, $f4, $f10

CALLER:	jal BASKARA
	jal SHOW
	j MAIN

#######################################################
# BASKARA ROUTINE
######################################################
BASKARA:mtc1 $a0, $f0 #a em $f0
	mtc1 $a1, $f1 #b em $f1
	mtc1 $a2, $f2 #c em $f2
	addi $sp, $sp, -8 #aloca 12 bytes na pilha
	bne $a0, $zero, SQ_DELT #se a for zero

A_ZERO:	sub.s $f2, $f0, $f2 #-c
	div.s $f12, $f2, $f1 #x = c/b
	swc1 $f12, 4($sp) #salva x
	swc1 $f0, 0($sp) #salva 0
	addiu $v0, $zero, 1
	jr $ra
	
SQ_DELT:mul.s $f5, $f1, $f1 #f5 contem b^2
	mul.s $f3, $f3, $f2 #4ac
	sub.s $f3, $f5, $f3 #b^2-4ac
	mtc1 $zero, $f31 #coloca 0 no reg f31
	c.lt.s $f3, $f31 #compara se delta eh menor que zero (raiz complexa conjugada)
	bc1t C_END
	bc1f R_END

C_END:	addiu $v0, $zero, 2 #prepara retorno 2
	j C_ROOT #chama rot de calcular raizes
	
R_END:	addiu $v0, $zero, 1 #prepara retorno 1
	j R_ROOT #chama rot de calcular raizes
	
C_ROOT: sub.s $f3, $f31, $f3 #delta = -delta (faz delta ser positivo)
	sqrt.s $f3, $f3 #sqrt(delta)
	sub.s $f10, $f31, $f1 #-b
	div.s $f10, $f10, $f4 #Re(xn) = -b/2a
	div.s $f3, $f3, $f4 #abs(Im(xn) = sqrt(delta)/2a)
	swc1 $f3, 4($sp) #salva Im(x) pois x1 e x2 sao complexos conjugados
	swc1 $f10, 0($sp) #salva Re(x)	
	jr $ra #retorna
	
R_ROOT: sqrt.s $f3, $f3 #sqrt(delta)
	sub.s $f10, $f31, $f1 #-b
	add.s $f11, $f10, $f3 #-b+sqrt(delta)
	div.s $f11, $f11, $f4 #-b+sqrt(delta)/2a, #f11 tem x1
	sub.s $f12, $f10, $f3 #-b-sqrt(delta)
	div.s $f12, $f12, $f4 #-b-sqrt(delta)/2a, #f12 tem x1
	swc1 $f12, 4($sp)	#salva x2
	swc1 $f11, 0($sp) #salva x1	
	jr $ra #retorna

###########################################################
# SHOW ROUTINE
###########################################################
SHOW:	beq $v0, 2, SHOW_C #checa se retorno foi complexo
  	beq $v0, 1, SHOW_R #checa se retorno foi real
  	jr $ra #retorna para endereço de $ra 
  	
SHOW_C:	lwc1 $f1, 0($sp) #pega Re(x)
	lwc1 $f0, 4($sp) #pega Im(x)
	addi $sp, $sp, 8 #limpa a pilha
	
	##################################
	# R(1) = Re(x1) + Im(x1)i
	##################################
	addi $v0, $zero, 4 #print string
	la $a0, R1 #string a ser printada
	syscall #printa "R(1) = "				
	
	addi $v0, $zero, 2 #coloca 2 em v0
	mov.s $f12, $f1 #coloca Re(x) em f12
	syscall #printa Re(x)
	
	addi $v0, $zero, 4
	la $a0, PLUS
	syscall #printa " + "	

	addi $v0, $zero, 2 #coloca 2 em v0	
	mov.s $f12, $f0 #coloca Im(x) em f12
	syscall #printa Im(x)
	
	addi $v0, $zero, 4 #print string
	la $a0, I #string a ser printada
	syscall #printa "i"
	
	##################################
	# R(2) = Re(x2) + Im(x2)i
	##################################
	addi $v0, $zero, 4 #print string
	la $a0, R2 #string a ser printada
	syscall #printa "R(2) = "				
	
	addi $v0, $zero, 2 #coloca 2 em v0
	mov.s $f12, $f1 #coloca Re(x) em f12
	syscall #printa Re(x)
	
	addi $v0, $zero, 4
	la $a0, MINUS
	syscall #printa " - "	

	addi $v0, $zero, 2 #coloca 2 em v0	
	mov.s $f12, $f0 #coloca Im(x) em f12
	syscall #printa Im(x)
	
	addi $v0, $zero, 4 #print string
	la $a0, I #string a ser printada
	syscall #printa "i"
	
	jr $ra #retorna
		
SHOW_R:	##################################
	# R(1) = x1
	##################################
	lwc1 $f12, 0($sp) #pega x1
	
	addi $v0, $zero, 4 #print string
	la $a0, R1 #string a ser printada
	syscall #printa "R(1) = "				
	
	addi $v0, $zero, 2 #coloca 2 em v0
	syscall #printa x1
	
	##################################
	# R(2) = x2
	##################################
	lwc1 $f12, 4($sp) #pega x2
	
	addi $v0, $zero, 4 #print string
	la $a0, R2 #string a ser printada
	syscall #printa "R(2) = "				
	
	addi $v0, $zero, 2 #coloca 2 em v0
	syscall #printa Re(x)
	
	addi $sp, $sp, 8 #limpa a pilha
	jr $ra #retorna
