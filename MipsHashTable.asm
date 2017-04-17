# Turma 1
# Grupo 2
# Integrantes:
#	André Moreira Souza - 9778985
#	Igor
#	Vitor
#	Vitor Trevelin Xavier da Silva - 9791285

# Mips assembly program that implements a hash table with double linked lists

# Estrutura de uma lista:
# 0($lista) = número de elementos da lista
# 4($lista) = primeiro nó da lsita
# 8($lista) = ultimo nó da lista

#Estrutura de um nó:
# 0($no) = item
# 4($no) = nó anterior
# 8($no) = proximo nó

	.data
	.align 0
hash:	.word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 #Hash table with addresses to lists. Initially 0.
str_ops: .asciiz "Operações:\n 1: Inserir valor\n 2: Remover valor\n 3: Buscar valor\n 4: Imprimir\n-1: Sair\n"
str_dig:	.asciiz "Digite um valor inteiro: "
	.text
	.globl main
main:
	# criar as 16 listas para a tabela hash
	li $t0, 0
l_loop:
	beq $t0, 64, l_end # 16 * 4
	
	la $a0, hash # endereco de hash
	add $a0, $a0, $t0 # $a0 = endereco de hash[i]
	
	jal list_create
	
	addi $t0, $t0, 4
	j l_loop
l_end:
menu: # interface de escoha de operação
	#Imprimir str_ops
	li $v0, 4
	la $a0, str_ops
	syscall
	
	#Ler codigo de operação
	li $v0, 5
	syscall
	add $s0, $zero, $v0
	beq $s0, -1, exit
	beq $s0, 1, insert
	beq $s0, 2, remove
	beq $s0, 3, search
	beq $s0, 4, print
	#beq $s0, 1, sort
	
	j menu
	
insert:
	#Imprime str_dig
	li $v0, 4
	la $a0, str_dig
	syscall
	
	#Ler inteiro
	li $v0, 5
	syscall
	add $s1, $zero, $v0
	
	#funcao hash
	li $t0, 16
	div $s1, $t0
	mfhi $t0
	mul $t0, $t0, 4
	la $t1, hash
	add $t0, $t0, $t1 # $t0 == endereco de hash(i)
	lw $a0, 0($t0) # $a0 == conteudo de hash(i)
	add $a1, $zero, $s1 # $ai == numero inserido
	
	beq $s1, -1, menu
	bltz $s1, izless
	jal list_insert
izless:
	j insert
remove:
	#Imprime str_dig
	li $v0, 4
	la $a0, str_dig
	syscall
	
	#Ler inteiro
	li $v0, 5
	syscall
	add $s1, $zero, $v0
	
	beq $s1, -1, menu
	j remove
search:
	#Imprime str_dig
	li $v0, 4
	la $a0, str_dig
	syscall
	
	#Ler inteiro
	li $v0, 5
	syscall
	add $s1, $zero, $v0
	
	beq $s1, -1, menu
	j search
print:

exit:
	li $v0, 10
	syscall


list_create:
	#guarda $a0 e $ra na stack
	addi $sp, $sp, -8
	sw $a0, 4($sp) # endereco da hash[i]
	sw $ra, 0($sp)
	
	#aloca 12 bytes na heap.
	li $v0, 9
	li $a0, 12
	syscall
	
	lw $a0, 4($sp) #recupera endereco de hash[i]
	sw $v0, 0($a0) #guarda endereco da heap em hash[i]
	
	#Set contents of list to NULL
	sw $zero, 0($v0)
	sw $zero, 4($v0)
	sw $zero, 8($v0)
	
	#Recupera ra da stack
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra #retorna

list_insert:
	#guarda $a0, $a1 e $ra na stack
	addi $sp, $sp, -12
	sw $a1, 8($sp) # valor inteiro
	sw $a0, 4($sp) # endereco da lista
	sw $ra, 0($sp)
	
	#Aloca um nó na heap #aloca 12 bytes na heap.
	li $v0, 9
	li $a0, 12
	syscall
	
	#recupera endereco da lista
	lw $a0, 4($sp)
	
	#incrementa numero de elementos
	lw $t1, 0($a0)
	add $t1, $t1, 1
	sw $t1, 0($a0)
	
	#recupera endereco do ultimo nó da lista
	lw $t0, 8($a0)
	
	#inicializa nó
	sw $a1, 0($v0)
	sw $t0, 4($v0)
	sw $zero, 8($v0)
	
	# se a lista estiver "vazia"
	beq $t1, 1, ilist_empty
	
	#ajustar ponteiros
	sw $v0, 8($t0)
	
	j ilist_empty_end
ilist_empty:
	sw $v0, 4($a0) # start = no
ilist_empty_end:
	sw $v0, 8($a0) # end = no
	
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	
	jr $ra
