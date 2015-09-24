.data
I: .asciiz " i"
PLUS: .asciiz " + "
MINUS: .asciiz " - "
R1: .asciiz "R(1) = "
R2: .asciiz "\nR(2) = "

.text
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
