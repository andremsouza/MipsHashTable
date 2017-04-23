# Turma 1
# Grupo 2
# Integrantes:
#	Andre Moreira Souza - 9778985
#	Igor Barbosa Grecia Lucio - 9778821
#	Victor Roberti Camolesi - 9791239
#	Vitor Trevelin Xavier da Silva - 9791285

# Programa em assembly Mips que implementa uma tabela hash com listas dinamicas duplamente encadeadas.
# Cada lista admite valores inteiros positivos, de ate 32 bits(signed).
# O programa implementa um menu, em que o usuario pode escolher as operacoes desejadas.
# Ao entrar em cada operacao, exceto as operacoes "print" e "exit", serao solicitados valores ate que seja recebido o valor de saida de operacao "-1".

# Operacoes implementadas:
# 	Insert:	Insere um valor na tabela hash. A insercao em cada lista e ordenada.
#	Remove:	Remove um valor da tabela hash. O valor sera procurado em sua devida posicao da tabela, determinada pela funcao hash.
#	Search:	Procura um valor na tabela hash. Retorna o indice da tabela se encontrado, ou "-1".
#	Print:	Imprime a tabela hash, com os indices na primeira coluna, e os valores de cada lista na segunda coluna.
#	Exit:	Finaliza o programa.

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
str_neg:	.asciiz "Valor negativo: invalido\n"
espaco:		.asciiz " "
enter:		.asciiz "\n"
tab:		.asciiz "\t"

	.text
	.globl main

main:
	li $t0, 0

l_loop: # criar as 16 listas para a tabela hash
	beq $t0, 64, menu # 16 * 4
	
	la $a0, hash # endereco de hash
	add $a0, $a0, $t0 # $a0 = endereco de hash[i]
	
	jal list_create
	
	addi $t0, $t0, 4
	j l_loop

list_create: # funcao: cria uma lista vazia em hash[i]
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
	
	# zera o conteudo da lista => lista vazia
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
	
	# le codigo de operacao
	li $v0, 5
	syscall
	add $s0, $zero, $v0 # $s0 = codigo de operacao
	beq $s0, 1, read_numb
	beq $s0, 2, read_numb
	beq $s0, 3, read_numb
	beq $s0, 4, print_hash
	beq $s0, -1, exit
	
	j menu

read_numb: # le um numero, guarda em $s1
	# imprime str_dig
	li $v0, 4
	la $a0, str_dig
	syscall
	
	# le inteiro
	li $v0, 5
	syscall
	add $s1, $zero, $v0
	
	bne $s1, -1, validate_number
	
	# ($s1 == -1) caso de retorno para o menu
	li $v0, 4
	la $a0, enter
	syscall			#imprime enter
	j menu			#volta para o menu
	
validate_number:
	bgt $s1, -1, hash_func	# se ($s1 > -1) o numero e valido, o programa continua em hash_func:
	
	# $s1 < -1, o numero e invalido
	li $v0, 4
	la $a0, str_neg
	syscall			# imprime str_neg
	j read_numb		# le o numero novamente

	
# hash_func:	gera os argumentos para as funcoes inserir/remover/buscar:
#		(List *) $a0,	(int) $a1	(int) $a2
# Descricao: encontra uma lista para inserir/remover/buscar um numero especifico e qual o indice de hash em que a lista se encontra
hash_func: 
	li $t0, 16		# $t0 = 16
	div $s1, $t0		# hi = modulo = numero % 16
	mfhi $t0		# $t0 = modulo

	add $a2, $t0, $zero	# ARG: $a2 = indice da lista em hash = modulo; *OBS: usado apenas na busca

	mul $t0, $t0, 4		# $t0 = modulo * 4
	la $t1, hash		# $t1 = ponteiro para hash
	add $t0, $t0, $t1	# $t0 = posicao de memoria que contem o endereco de uma das listas: &(hash->list[i])
	
	lw $a0, 0($t0)		# ARG: $a0 = endereco de uma das listas de hash, (hash->list[i])
	add $a1, $zero, $s1	# ARG: $a1 = numero a ser inserido/removido/buscado
	
	beq $s0, 1, insert	# vai para a insercao
	beq $s0, 2, remove	# vai para a remocao
	beq $s0, 3, search	# vai para a busca
	# continua para a insercao

insert:	# operacao: inserir
	jal list_insert
	
# Funcao:		void list_insert(List *list, int item)
# Argumentos:		                $a0,        $a1
# Valor de Retorno:	void
# Descricao:		Recebe o ponteiro 'list' para uma lista em que sera inserido um elemento 'item'
list_insert: # funcao: insere valor em uma lista
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

li_loop: # loop auxiliar de list_insert
	beq $t1, $zero, insert_return	# if($t1 == NULL(0)), fim da lista, sai da funcao

	lw $t2, 0($t1)			# $t2 = $t1->item
	beq $a1, $t2, insert_same	# if($a1==$t2), posicao numero repetido, sai da funcao
	blt $a1, $t2, insert_pos	# if($a1<$t2), posicao correta encontrada, sai da funcao
	lw $t1, 8($t1) 			# $t1 = $t1->next

	j li_loop

insert_return: # fim de li_loop
	# incrementa numero de elementos
	lw $t1, 0($a0)
	add $t1, $t1, 1
	sw $t1, 0($a0)
	
	# recupera endereco do ultimo nó da lista
	lw $t0, 8($a0)
	
	# inicializa no
	sw $a1, 0($v0)
	sw $t0, 4($v0)
	sw $zero, 8($v0)
	 
	# se a lista estiver "vazia"
	beq $t1, 1, ilist_empty
	# ajustar ponteiros
	sw $v0, 8($t0)
	
	j ilist_empty_end
	
ilist_empty: # se a lista estiver vazia
	sw $v0, 4($a0) # start = no
	
ilist_empty_end:
	sw $v0, 8($a0) # end = no
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish

insert_same: # se j� existe o n�mero, finaliza a funcao
	li $v0, 4
	la $a0, str_insre
	syscall
	j insert_finish

insert_pos: # insere um no em uma posicao, e ajusta os ponteiros
	sw $a1, 0($v0)	# inicializa valor do no
	lw $t3, 4($t1)	# $t3 = $t1->prev
	beq $t3, $zero, insert_first	# if($t1 == NULL(0)), fim da lista, sai da funcao
	sw $v0, 8($t3)	# $t3->next = no
	sw $v0, 4($t1)	# $t1->prev = no
	sw $t3, 4($v0)	# $v0->prev = $t3
	sw $t1, 8($v0)	# $v0->next = $t1
	# incrementa numero de elementos
	lw $t1, 0($a0)
	add $t1, $t1, 1
	sw $t1, 0($a0)
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish

insert_first: # insercao: caso primeira posicao
	sw $v0, 4($a0)	# start = no
	sw $v0, 4($t1)	# $t1->prev = no
	sw $t1, 8($v0)	# $v0->next = $t1
	# incrementa numero de elementos
	lw $t1, 0($a0)
	add $t1, $t1, 1
	sw $t1, 0($a0)
	li $v0, 4
	la $a0, str_insok
	syscall
	j insert_finish

insert_finish: # final da funcao de insercao
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	j read_numb

remove: # operacao: remover
	jal list_remove
	
# Funcao:		void list_insert(List *list, int item)
# Argumentos:		                $a0,        $a1
# Valor de Retorno:	void
# Descricao:		Recebe o ponteiro 'list' para uma lista em que sera removido um elemento 'item'
list_remove: # funcao: remove um valor da lista, se existente
	# guarda $a0, $a1 e $ra na stack
	addi $sp, $sp, -12
	sw $a1, 8($sp) # valor inteiro
	sw $a0, 4($sp) # endereco da lista
	sw $ra, 0($sp)

	# checar se a lista esta vazia 
	lw $t1, 0($a0) # $t1 recebe o n�mero de elementos na lista($a0)
	beq $t1, $zero, exit_rem_notfound # se o n�mero de elementos na lista == 0, apenas sai da funcao
	
	
	lw $t3, 8($sp)	# $t3 = item buscado
	lw $t1, 4($a0)	# $t1 = list->first
	
lr_loop:
	beq $t1, $zero, exit_rem_notfound	# if($t1 == NULL(0)), elemento nao encontrado, sai da funcao

	lw $t2, 0($t1)	# $t2 = $t1->item
	beq $t2, $t3, rem_node	# if (item atual � o buscado) rem_node
	lw $t1, 8($t1) 	# $t1 = $t1->prox
	
	j lr_loop
	
rem_node:
	# decrementa o n�mero de elementos na lista
	lw $t5, 4($sp)		# $t5 = ponteiro da lista
	lw $t6, 0($t5)		# $t6 = list->n
	addi $t6, $t6, -1	# $t6--
	sw $t6, 0($t5)		# list->n = $t6
	
	# $t1 � o n� a ser removido
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
	
exit_rem_notfound: # se valor nao for encontrado na lista
	li $v0, 4
	la $a0, str_remno
	syscall	

exit_rem:		# return
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	
	j read_numb
	
	
	
search: # chegou aqui de hash_func, verifica se $a1 e valido. Se for, continua para a busca, se nao for, volta ao menu
	# $a0 = ponteiro para a lista em que se deve buscar
	# $a1 = inteiro a ser buscado
	# $a2 = indice da tabela hash em que se encontra a lista $a1	
	
	# chama a funcao de busca
	jal hash_search		# $v0 = int hash_search(List *$a0, int $a1, int $a2)
	
	
	# imprime o resultado da busca("%d\n", int hash_search(...)):

				# valor
	add $a0, $zero, $v0	# $a0 = $v0
	li $v0, 1		# $v0 = 1
	syscall			# print_int($a0)
	
				# enter
	li $v0, 4		# $v0 = 4
	la $a0, enter		# $a0 = (char *)enter
	syscall			# print_str($a0)
	
	j read_numb		# volta para ler o proximo numero da busca



# Funcao:		int hash_search(List *list, int item, int index)
# Argumentos:		                $a0,        $a1,      $a2
# Valor de Retorno:	$v0 = encontrou ? $a2 : -1
# Descricao:		Recebe o ponteiro 'list' para uma lista em que sera buscado um elemento 'item' e o indice 'index' em que essa lista se encontra em hash
# Obs:			Ja recebe o ponteiro para a lista para que esse processo so se repita uma vez em hash_func:
# Obs2:			Nao faz pushs na pilha, ja que nao faz chamada de outras funcoes
hash_search:

	lw $t0, 4($a0)				# $t0 = hash[$a2]->list->first

loop_pointer_dif_null:				# while(1) {
	beq $t0, $zero, not_found_in_list	#	if($t0 == NULL) goto not_found_in_list
	lw $t1, 0($t0)				#	$t1 = $t0->item
	beq $t1, $a1, found_in_list		#	if($t1 == $a1) goto found_in_list
	bgt $t1, $t2, not_found_in_list		#	if($t1 > $a1) goto not_found_in_list
	lw $t0, 8($t0)				#	$t0 = $t0->next
	j loop_pointer_dif_null			# }

not_found_in_list:
	addi $v0, $zero, -1			# $v0 = -1
	jr $ra					# retorna $v0 
	
found_in_list:
	add $v0, $zero, $a2			# $v0 = $a2
	jr $ra					# retorna $v0	
	
	
print_hash:	# chama a funcao que printa uma lista, para cada lista da Tabela Hash
			
	la $t1, hash			# $t1 = endereco da Tabela Hash
	li $t2, 64			# $t2 = 64
	li $t0, 0			# $t0 = 0
	
	addi $sp, $sp, -4		# push na pilha
	sw $t0, 0($sp)			# int i = $t0 = 0
	# $t0 e salvo na pilha devido a uma chamada de funcao dentro do loop_t, valor do registrador usado pode acabar sendo alterado
	
# loop_t: for(i = 0, $t2 = 64; (i * 4) < $t2; i++)
loop_t:					# while(1)
	lw $t0, 0($sp)			#	load $t0 da pilha
	add $a1, $zero, $t0		#	$a1 = $t0
	addi $t0, $t0, 1		#	$t0 += 1
	sw $t0, 0($sp)			#	salva $t0 na pilha	
	mul $t0, $a1, 4			#	$t0 = $a1 * 4
	bge $t0, $t2, exit_loop_t	#	se ($t0 >= $t2) goto exit_loop_t
	add $a0, $t1, $t0		#	$a0 = ponteiro para o endereco de uma das listas(hash[$a1])
	lw $a0, 0($a0)			#	$a0 = endereco de uma das listas(hash[$a1]->list)
	jal print_list			#	print_list(List *$a0, int $a1)

	j loop_t			# }
	
exit_loop_t:
	addi $sp, $sp, 4	# pop na pilha
	j menu			# volta para o menu

# Funcao:	void print_list(List *list, int index)
# Argumentos:	                $a0         $a1
# Descricao:	Recebe um ponteiro para uma lista, e um inteiro que representa seu indice em hash e imprime no formato:
#->"index\telemento1 elemento2 elemento3 ...\n"
# Obs: Esta funcao nao chama outras, entao e desnecessario colocar os argumentos na pilha
print_list:
	lw $t0, 4($a0)	# $t0 = hash[index]->list->first
	
	# imprime o indice referente a lista em hash
	li $v0, 1
	add $a0, $zero, $a1
	syscall
	
	# print um tab
	li $v0, 4
	la $a0, tab
	syscall
	
# loop_all_nodes: percorre todo os nos da lista
loop_all_nodes:					# while(1) {
	beq $t0, $zero, print_enter 	#	if($t0 == null) goto print_enter
	
	# print do n�mero relativo ao n�
	li $v0, 1
	lw $a0, 0($t0)
	syscall				#	printf("%d", $t0.item);
			
	# print do espaco
	li $v0, 4
	la $a0, espaco
	syscall				#	printf(" ");
	
	lw $t0, 8($t0)			# 	$t0 = $t0->next
	j loop_all_nodes		# }
	
print_enter:
	li $v0, 4
	la $a0, enter
	syscall				# printf("\n");

	jr $ra				# retorna


exit: # terminar programa
	li $v0, 10
	syscall
