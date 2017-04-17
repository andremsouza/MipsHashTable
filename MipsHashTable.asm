# Turma 1
# Grupo 2
# Integrantes:
#
#
#
#

# Mips assembly program that implements a hash table with double linked lists

	.data
	.align 0
str_ops: .asciiz "Operações:\n 1: Inserir valor\n 2: Remover valor\n 3: Buscar valor\n 4: Imprimir\n-1: Sair\n"
str_dig:	.asciiz "Digite um valor inteiro: "
	
	.text
	.globl main
main:

menu:
	#Imprimir str_ops
	li $v0, 4
	la $a0, str_ops
	syscall
	
	#Ler codigo de operação
	li $v0, 5
	syscall
	add $s0, $zero, $v0
	add $t0, $zero, -1
	beq $s0, $t0, exit
	
	j menu

insert:

remove:

search:

print:

exit:
	li $v0, 10
	syscall