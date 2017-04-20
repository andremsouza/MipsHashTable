# Turma 1
# Grupo 2
# Integrantes:
#	Andre Moreira Souza - 9778985
#	Igor Barbosa Grecia Lucio - 9778821
#	Victor Roberti Camolesi - 9791239
#	Vitor Trevelin Xavier da Silva - 9791285

# Programa em assembly Mips que implementa uma tabela hash com listas duplamente encadeadas

# Estrutura de uma lista:
# 0($lista) = numero de elementos da lista
# 4($lista) = primeiro no da lista
# 8($lista) = ultimo no da lista

# Estrutura de um no:
# 0($no) = item
# 4($no) = no anterior
# 8($no) = proximo no

	.data
	.align 0
hash:	.word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 # Hash table with addresses to lists. Initially 0.
str_ops: .asciiz "Operacoes\n 1: Inserir valor\n 2: Remover valor\n 3: Buscar valor\n 4: Imprimir\n-1: Sair\n"
str_dig:	.asciiz "Digite um valor inteiro: "
str_insok:	.asciiz "Valor inserido\n"
str_insre:	.asciiz "Valor repetido: nao inserido\n"
str_remok:	.asciiz "Valor removido\n"
str_remno:	.asciiz "Valor nao encontrado, impossivel remover\n"
str_busok:	.asciiz "Valor encontrado"
str_busno:	.asciiz "Valor nao encontrado"
str_negno:	.asciiz "Valor negativo: nao inserido\n"
espaco:	.asciiz " "
enter:	.asciiz "\n"
tab:	.asciiz "\t"

	.text
	.globl main
main:
	# criar as 16 listas para a tabela hash
	li $t0, 0
l_loop:
	beq $t0, 64, menu # 16 * 4
	
	la $a0, hash # endereco de hash
	add $a0, $a0, $t0 # $a0 = endereco de hash[i]
	
	jal list_create
	
	addi $t0, $t0, 4
	j l_loop
	
list_create:
	# guarda $a0 e $ra na stack
	addi $sp, $sp, -8
	sw $a0, 4($sp) # endereco da hash[i]
	sw $ra, 0($sp)
	
	# aloca 12 bytes na heap.
	li $v0, 9
	li $a0, 12
	syscall
	
	lw $a0, 4($sp) # recupera endereco de hash[i]
	sw $v0, 0($a0) # guarda endereco da heap em hash[i]
	
	# zera o conteudo da lista
	sw $zero, 0($v0)
	sw $zero, 4($v0)
	sw $zero, 8($v0)
	
	# recupera ra da stack
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra #retorna

menu: # interface de escoha de operacao
	# imprime str_ops
	li $v0, 4
	la $a0, str_ops
	syscall
	
	# le codigo de operaÃ§Ã£o
	li $v0, 5
	syscall
	add $s0, $zero, $v0
	beq $s0, 1, read_numb
	beq $s0, 2, read_numb
	beq $s0, 3, read_numb
	beq $s0, 4, print
	beq $s0, -1, exit
	# beq $s0, 1, sort
	
	j menu
	
read_numb:
	# imprime str_dig
	li $v0, 4
	la $a0, str_dig
	syscall
	
	# le inteiro
	li $v0, 5
	syscall
	add $s1, $zero, $v0
	beq $s1, -1, menu # se s1 == -1 volta para o menu
	beq $s0, 3, search # se s1 == 3 pula para search, se s1 == 1 ou 2 continua para hash_func
	
hash_func:
	# funcao hash
	li $t0, 16
	div $s1, $t0
	mfhi $t0
	mul $t0, $t0, 4
	la $t1, hash
	add $t0, $t0, $t1 # $t0 == endereco de hash(i)
	lw $a0, 0($t0) # $a0 == conteudo de hash(i)
	add $a1, $zero, $s1 # $a1 == numero inserido
	beq $s0, 2, remove
	
insert:	
	bltz $s1, izless
	jal list_insert
	
izless:
	li $v0, 4
	la $a0, str_negno
	syscall
	j read_numb
	
list_insert:
	# guarda $a0, $a1 e $ra na stack
	addi $sp, $sp, -12
	sw $a1, 8($sp) # valor inteiro
	sw $a0, 4($sp) # endereco da lista
	sw $ra, 0($sp)
	
	
	# aloca um no na heap (12 bytes)
	li $v0, 9
	li $a0, 12
	syscall
	
	# recupera endereco da lista
	lw $a0, 4($sp)
	
	# se lista nao vazia
	lw $t1, 4($a0)		# t1 = primeiro no
	bgtz $a0, li_loop
	
insert_return:
	# incrementa numero de elementos
	lw $t1, 0($a0)
	add $t1, $t1, 1
	sw $t1, 0($a0)
	
	# recupera endereco do ultimo nÃ³ da lista
	lw $t0, 8($a0)
	
	# inicializa nÃ³
	sw $a1, 0($v0)
	sw $t0, 4($v0)
	sw $zero, 8($v0)
	 
	# se a lista estiver "vazia"
	beq $t1, 1, ilist_empty
	# ajustar ponteiros
	sw $v0, 8($t0)
	
	j ilist_empty_end
	
ilist_empty:
	sw $v0, 4($a0) # start = no
	
ilist_empty_end:
	sw $v0, 8($a0) # end = no
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish

li_loop:
	beq $t1, $zero, insert_return	# if($t1 == NULL(0)), fim da lista, sai da funcao

	lw $t2, 0($t1)			# $t2 = $t1->item
	beq $a1, $t2, insert_same	# if($a1==$t2), posicao numero repetido, sai da funcao
	blt $a1, $t2, insert_pos	# if($a1<$t2), posicao correta encontrada, sai da funcao
	lw $t1, 8($t1) 			# $t1 = $t1->next
	
	j li_loop

insert_same:
	li $v0, 4
	la $a0, str_insre
	syscall

insert_finish:
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	j read_numb

insert_pos:
	sw $a1, 0($v0)	# inicializa valor do no
	lw $t3, 4($t1)	# $t3 = $t1->prev
	beq $t3, $zero, insert_first	# if($t1 == NULL(0)), fim da lista, sai da funcao
	sw $v0, 8($t3)	# $t3->next = no
	sw $v0, 4($t1)	# $t1->prev = no
	sw $t3, 4($v0)	# $v0->prev = $t3
	sw $t1, 8($v0)	# $v0->next = $t1
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish

insert_first:
	sw $v0, 4($a0)	# start = no
	sw $v0, 4($t1)	# $t1->prev = no
	sw $t1, 8($v0)	# $v0->next = $t1
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish
	
remove:
	bltz $s1, rzless
	jal list_remove
	
rzless:
	li $v0, 4
	la $a0, str_remno
	syscall
	j read_numb

list_remove:
	# guarda $a0, $a1 e $ra na stack
	addi $sp, $sp, -12
	sw $a1, 8($sp) # valor inteiro
	sw $a0, 4($sp) # endereco da lista
	sw $ra, 0($sp)

	# checar se a lista esta vazia 
	lw $t1, 0($a0) # $t1 recebe o número de elementos na lista($a0)
	beq $t1, $zero, exit_rem_notfound # se o número de elementos na lista == 0, apenas sai da funcao
	
	
	lw $t3, 8($sp)	# $t3 = item buscado
	lw $t1, 4($a0)	# $t1 = list->first
	
lr_loop:
	beq $t1, $zero, exit_rem_notfound	# if($t1 == NULL(0)), elemento nao encontrado, sai da funcao

	lw $t2, 0($t1)	# $t2 = $t1->item
	beq $t2, $t3, rem_node	# if (item atual é o buscado) rem_node
	lw $t1, 8($t1) 	# $t1 = $t1->prox
	
	j lr_loop
	
rem_node:
	# decrementa o número de elementos na lista
	lw $t5, 4($sp)		# $t5 = ponteiro da lista
	lw $t6, 0($t5)		# $t6 = list->n
	addi $t6, $t6, -1	# $t6--
	sw $t6, 0($t5)		# list->n = $t6
	
	# $t1 é o nó a ser removido
	lw $t2, 4($t1)	# $t2 = no->prev
	lw $t3, 8($t1)	# $t3 = no->next
	lw $t4, 4($sp) # $t4 = endereco da lista
	li $v0, 4
	la $a0, str_remok
	syscall
	
check_prev:
	bne $t2, $zero, prev_n_null
					# prev == NULL
	sw $t3, 4($t4)			# ($t2 == null) => list->first = $t3
	
check_next:
	bne $t3, $zero, next_n_null
					# next == NULL
	sw $t2, 8($t4)			# ($t3 == null) => list->last = $t2
	j exit_rem


prev_n_null:				# prev != NULL
	sw $t3, 8($t2)			# $t2->next = $t3 ($t2 != null)
	j check_next

next_n_null:				# next != NULL
	sw $t2, 4($t3)			# $t3->prev = $t2 ($t3 != null)
	j exit_rem
	
exit_rem_notfound:
	li $v0, 4
	la $a0, str_remno
	syscall	

exit_rem:		# return
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	
	j read_numb
	
search:
	add $a0, $zero, $v0	# arg1 - $a0 = inteiro buscado
	la $a1, hash		# arg2 - $a1 = ponteiro da tabela hash
	
	jal hash_search		# chama a funcao de busca int hash_search(int $a0, Hash $a1)

	# $v0 possui o valor de retorno da funcao
	
	ble $v0, 0, search_no
	j search_ok
	
search_finish:	# enter
	li $v0, 4
	la $a0, enter
	syscall
	
	j read_numb

search_ok:
	li $v0, 4
	la $a0, str_busok
	syscall
	j search_finish
	
search_no:
	li $v0, 4
	la $a0, str_busno
	syscall
	j search_finish
			
hash_search:		# retorna $v0, se o número nao foi encontrado, $v0 = -1, caso contrário, $v0 = index da lista no vetor hash()
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)	# inteiro buscado
	sw $a1, 8($sp)	# ponteiro da hash

	# usa a funcao de espalhamento (inteiro % 16) para encontrar o index do vetor
	## PODEMOS FAZER UMA FUNÇÃO SEPARADA DISSO, USAMOS ISTO 2X
	lw $s1, 4($sp)
	
	li $t0, 16
	div $s1, $t0
	mfhi $t0
	mfhi $s2	# salva número % 16 em $s2
	mul $t0, $t0, 4
	lw $t1, 8($sp)		# $t1 == endereco de hash(0)
	add $t0, $t0, $t1	# $t0 == endereco de hash(i)
	
	add $a0, $zero, $s1	# arg1 - $a0 == número buscado
	lw $a1, 0($t0)		# arg2 - $a1 == hash(i)(aponta para a lista)
	
	jal list_search		# chama a funcao de busca em lista int list_search(int $a0, List *$a1)
	
	# $v0 possui o valor de retorno da funcao($v0 = list_search())
	beq $v0, $zero, not_found_in_hashT
	
found_in_hashT:
	add $v0, $zero, $s2
	j end_hash_search
	
not_found_in_hashT:
	addi $v0, $zero, -1
	
end_hash_search:
	lw $ra, 0($sp)		# recupera o endereco de retorno
	addi $sp, $sp, 12	# pop na pilha
	
	jr $ra			# return $v0

list_search:	# retorna $v0, caso o número for encontrado, $v0 = 1, caso contrário, $v0 = 0
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)		# número buscado
	sw $a1, 8($sp)		# ponteiro para a lista
	
	# void *$t0;
	lw $t0, 8($sp)		# $t0 = ponteiro para a lista
	lw $t0, 4($t0)		# $t0 = list->first
	
	lw $t2, 4($sp)		# int $t2 = número buscado
	
while_pointer_dif_null:
	beq $t0, $zero, not_found_in_list	# if($t0 == null) goto end_list_search
	lw $t1, 0($t0)				# $t1 = $t0->item
	beq $t1, $t2, found_in_list		# if($t1 == $t2) goto found_in_list
	bgt $t1, $t2, not_found_in_list		# if($t1>$t2) goto end_list_search
	
	lw $t0, 8($t0)				# $t0 = $t0->next
	
	j while_pointer_dif_null	
	
not_found_in_list:
	addi $v0, $zero, 0		# $v0 = 0
	j end_list_search
	
found_in_list:
	addi $v0, $zero, 1		# $v0 = 1
	
end_list_search:
	lw $ra, 0($sp)			# recupera o endereco de retorno
	addi $sp, $sp, 12		# pop na stack
	jr $ra				# return $v0
	
print:	# print da Hash
	la $t1, hash # $t1 = endereco da Tabela Hash
	# for($a2 = 0, ($a2 * 4) < ($t2 = 64); $a2 += 4)
	
	li $t2, 64	# $t2 = 64
	li $a2, 0	# $a2 = 0
		
	addi $sp, $sp, -8	# push na pilha
	sw $ra, 0($sp)
	sw $a2, 4($sp)	# int i = $a2 = 0
	
loop_a:
	bge $a2, $t2, exit_loop_a
	add $a1, $t1, $a2	# $a1 = ponteiro para o endereco de uma das listas
	
	lw $a1, 0($a1) # $a1 = endereco e uma das listas
	lw $a2, 4($sp) # load $a2 da pilha	
	jal print_list
	
	# incrementa a posicao da lista
	addi $a2, $a2, 1 # incrementa $a2
	sw $a2, 4($sp) # salva #a2 na pilha
	
	mul $a2, $a2, 4 # $a2 = $a2 * 4

	# realiza o loop
	j loop_a
	
exit_loop_a:
	# recupera o endereco de retorno
	lw $ra, 0($sp)

	# pop na pilha
	addi $sp, $sp, 8
	
	#jr $ra # retorna
	j menu

print_list:	# Print de uma Lista, com ponteiro em $a1
	# push na pilha
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a1, 4($sp)	# endereco da lista
	sw $a2, 8($sp)	# index da lista no vetor
	
	# print do número da lista
	li $v0, 1
	lw $a0, 8($sp)
	syscall
	
	# print um tab
	li $v0, 4
	la $a0, tab
	syscall
		
	lw $t0, 4($sp)	# $t0 = endereco da lista
	lw $t0, 4($t0)	# $t0 = list->first
	
	
loop_b:
	beq $t0, $zero, print_enter 	# if($t0 == null) sai
	
	# print do número relativo ao nó
	li $v0, 1
	lw $a0, 0($t0)
	syscall
			
	# print do espaco
	li $v0, 4
	la $a0, espaco
	syscall
	
	lw $t0, 8($t0)			# $t0 = $t0->next
	
	j loop_b
	
print_enter:
	li $v0, 4
	la $a0, enter
	syscall
	
	# recupera o endereco de retorno
	lw $ra, 0($sp)
	
	# pop na pilha
	addi $sp, $sp, 12
	
	# retorna
	jr $ra
	
exit:
	li $v0, 10
	syscall