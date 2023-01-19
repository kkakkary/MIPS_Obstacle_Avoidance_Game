.data
	setting: .byte '-', '-' ,'-' ,'-' ,'-', '-', '-' ,'-' 
		.byte ' ', ' ', ' ', ' ', ' ' ,' ' ,' ' ,']' 
		.byte ' ' ,' ' ,' ' ,' ' ,' ', ' ', ' ', ']' 
		.byte ' ' ,' ', ' ' ,' ' ,' ' ,' ' ,' ' ,']' 
		.byte ' ' ,' ', ' ' ,' ', ' ',' ' ,' ', ' ', 	
		.byte ' ' ,' ', 'O' ,' ', ' ', ' ', ' ', ']'	
		.byte ' ', ' ', ' ' ,' ', ' ', ' ', ' ', ']'
		.byte '-', '-', '-', '-', '-', '-', '-', '-' #2d array for game, player, and obstacles
	newline: .asciiz "\n" #text for newline
	up: .byte 'w' #input for moving up
	left: .byte 'a' #input for moving left
	right: .byte 'd' #input for moving right
	down: .byte 's'	#input for moving down					
	space: .byte ' ' #char used to represent empty space in 2d array
	circle: .byte 'O' #char to represent the player
	staple: .byte ']' #char to represent the obstacles
	Ready: .asciiz "Ready?\n" #line to signal the start of the game
	gameend: .asciiz "GAMEOVER\n" #line to signal end of the game
	score: .asciiz "Score: " #string to be printed for the score
	scorenum: .word 0 #the actual score
	height: .word 8 #height of the array
	width: .word 8 #width of the array
	currx: .word 2 #current x coordinate of player
	curry: .word 5 #current y coordinate of player
	stapler1curx: .word 7 #curx is the current x coordinate of the designated stapler/obstacle
	stapler1cury: .word 1 #cury is the current y coordinate of the designated stapler/obstacle
	stapler2curx: .word 7
	stapler2cury: .word 2
	stapler3curx: .word 7
	stapler3cury: .word 3
	stapler4curx: .word 7
	stapler4cury: .word 5
	stapler5curx: .word 7
	stapler5cury: .word 6
	TimePrint: .asciiz "Time: " #string to print out time
	ms: .asciiz "ms" #prints the designated unit for time
	pitch: .byte 60 #pitch of sound wind sound
	duration: .byte 1000 #duration of each sound
	instrument1: .byte 122 #byte value for wind sound
	volume: .byte 60 #volume for wind sound
	volume2: .byte 100 #volume for synth pad sound at the end of the game
	instrument2: .byte 124 #byte value for synth pad instrument
	red: .word 0xFF0000 #hex value for red in bitmap display
	green: .word 0x00FF00 #hex value for green in bitmap display
	black: .word 0x000000 #hex value for black in btmap display
	blue: .word 0x0000FF #hex vlaue fo blue in bitmap display
	.text
	main:#main function



	li $v0, 4
	la $a0, Ready #prints out "ready?" 
	syscall
	jal Print# prints out 2d array
	jal BitStart #loads the setting in bitmap display
	while: 
	jal Timebefore #calculates the time before player's move
	jal Input #processes player's input to move the player's position
	jal Stapler1Contact #checks for contact between designated stapler and player
	jal Stapler2Contact
	jal Stapler3Contact
	jal Stapler4Contact
	jal Stapler5Contact
	jal Stapler1#moves designated stapler 
	jal Stapler2
	jal Stapler3
	jal Stapler4
	jal Stapler5
	jal Stapler1Contact #checks for contact again
	jal Stapler2Contact
	jal Stapler3Contact
	jal Stapler4Contact
	jal Stapler5Contact
	jal Print #prints current setting
	jal Sound #plays a wind sound
	jal Scoreboard #displays score
	jal Timeafter #displays time between each move


	j while #loops until one of hte functions branch to gameover

	BitStart: 
	li $t3, 0
	li $t4, 0
	lw $s2, width
		BitWhile: #start of nested while loops to print out the blue on top and bottom
		bge $t4, $s2, bitexit #t4 = j

		mul $t5, $t3, $s2	#calculation for exact location of wher each blue square should be 
		add $t5, $t5, $t4
		sll $t5, $t5, 2
		add $t5,$gp, $t5 #base address+width*i+j)
		lb $t2, blue
		sb $t2, 0($t5)

		addi $t4, $t4, 1
		j BitWhile

		bitexit:

		li $t3, 7
		li $t4, 0
		lw $s2, width
		BitWhile2: 
		bge $t4, $s2, bitexit2 #t4 = j

		mul $t5, $t3, $s2
		add $t5, $t5, $t4
		sll $t5, $t5, 2
		add $t5,$gp, $t5 #base address+width*i+j)
		lb $t2, blue
		sb $t2, 0($t5)

		addi $t4, $t4, 1
		j BitWhile2
		bitexit2:

	jr $ra


	Sound: 
	li $v0, 31 
	lb $a0, pitch
	lb $a1, duration #loading the neccessary arguments for wind sound
	lb $a2, instrument1
	lb $a3, volume  
	syscall  #plays sound
	jr $ra
	Timebefore: 
	li $v0, 30
	syscall
	move $t8, $a0 #using syscall to get the time before the player makes a move
	jr $ra
	Timeafter: #using syscall to get the time after the player makes a move 
	li $v0, 30
	syscall
	sub $t8, $a0,$t8
	li $v0, 4
	la $a0, TimePrint #the rest is just syscalls to print out the time
	syscall
	li $v0, 1
	move $a0, $t8
	syscall
	li $v0, 4
	la $a0, ms
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	li $t1, 2000
	bgt $t8, $t1, gameover
	jr $ra




	Input:# asks for input and calls appropriate movement function
	li $v0, 12
	syscall

	addi $sp, $sp, -12 #using a stack to store the return addresses since there are functions in this function
	sw $ra , 8($sp)
	lb $t0, up
	bne $v0, $t0, elseif #what happens when input is 'w'
	jal MoveUp
	elseif:
	lb $t0, down
	bne $v0, $t0, elseif2
	jal MoveDown	#what happens when input is 's'
	elseif2:
	lb $t0, left
	bne $v0, $t0, elseif3
	jal MoveLeft #what happens when input is 'a'
	elseif3: 
	lb $t0, right
	bne $v0, $t0 else
	jal MoveRight	#what happens when input is 'd'
	else: 
	lw $ra, 8($sp)
	addi $sp, $sp, 12#pops return address
	jr $ra















	Print:#prints out 2d array
	la $s0, setting
	lw $s2 width
	lw $s1, height
	li $v0, 4
	la $a0, newline
	syscall
	li $t3, 0
	while1: 
	bge $t3, $s1, exit1 #$t3 = i
	li $t4, 0
	while2: 
	bge $t4, $s2, exit2 #t4 = j

	mul $t5, $t3, $s2
	add $t5, $t5, $t4
	add $t5,$s0, $t5 #base address+width*i+j)

	li $v0, 11
	lb $a0, 0($t5)
	syscall

	addiu $t4, $t4, 1
	b while2

	exit2: 
	li $v0, 4
	la $a0, newline
	syscall

	addiu $t3, $t3, 1
	b while1

	exit1:

	jr $ra
	


	MoveUp: #how the player moves up
	la $s0, setting
	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 #updates black square in bitmap display
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, black
	sw $t2, 0($t5)

	addi $t1, $t1, -1
	beq $t1, $zero, gameover
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t7, circle
	sb  $t7, 0($t5)	

	sw $t0, currx
	sw $t1, curry

	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 #updates red in bitmap display to represent player
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, red
	sw $t2, 0($t5)

	jr $ra

	MoveDown: #how the player moves down
	la $s0, setting
	lw $s2, width
	lw $t0, currx
	lw $t1, curry

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, currx
	lw $t1, curry 	#updates black to where the player used to be in bitmap display
	mul $t5, $t1, $s2 
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, black
	sw $t2, 0($t5)

	addi $t1, $t1, 1
	li $t2, 7
	beq $t1, $t2, gameover
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t7, circle
	sb  $t7, 0($t5)	

	sw $t0, currx
	sw $t1, curry

	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 #updates red square on the player's current position in bitmap display
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, red
	sw $t2, 0($t5)

	jr $ra

	MoveLeft:#how hte player moves left
	la $s0, setting
	lw $s2, width
	lw $t0, currx
	lw $t1, curry

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, currx
	lw $t1, curry	#updates black square on where the player used to be in bitmap display
	mul $t5, $t1, $s2 
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, black
	sw $t2, 0($t5)

	addi $t0, $t0, -1
	blt  $t0, $zero, gameover
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t7, circle
	sb  $t7, 0($t5)	

	sw $t0, currx
	sw $t1, curry

	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 #updates red square on where the player is in bitmap display
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, red
	sw $t2, 0($t5)

	jr $ra

	MoveRight:#how the player moves right
	la $s0, setting
	lw $s2, width
	lw $t0, currx
	lw $t1, curry

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, currx
	lw $t1, curry
	mul $t5, $t1, $s2 #updates black square on where the player was in bitmap display
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, black
	sw $t2, 0($t5)

	addi $t0, $t0, 1
	li $t2, 9
	beq $t0, $t2, gameover
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, circle
	sb  $t2, 0($t5)

	sw $t0, currx
	sw $t1, curry

	lw $s2, width
	lw $t0, currx 	#updates red square on where the player is in bitmap display
	lw $t1, curry
	mul $t5, $t1, $s2 
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5 #base address+width*i+j)
	lw $t2, red
	sw $t2, 0($t5)

	jr $ra

	Stapler1:
	#much like the code for the player movement, stapler movements move left and when x value is 0, it resets
	#the green tiles represent 
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	
	la $s0, setting
	lw $s2, width
	lw $t0, stapler1curx 	#puts space in arrray
	lw $t1, stapler1cury
	mul $t5, $t1, $s2 #t1 == $s5 #t0 == $s4
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width	#buts black in bitmap display
	lw $t0, stapler1curx
	lw $t1, stapler1cury
	mul $t5, $t1,$s2 
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, black
	sw $t2, 0($t5) 

	addi $t0, $t0, -1
	blt $t0, $zero, reset1 #puts staple in 2d array
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, staple
	sb  $t2, 0($t5)	
	b skip1
	reset1: #for when staple reaches end of screen
	li $t0, 7
	jal random #calls for random number
	addi $t1, $t1, 1 #adds 1
	divu $t1, $t3 #does mod 6
	mfhi $t1
	addi $t1, $t1, 1 #adds 1 to modded value
	skip1:
	sw $t0, stapler1curx
	sw $t1, stapler1cury

	lw $s2, width
	lw $t0, stapler1curx
	lw $t1, stapler1cury
	mul $t5, $t1,$s2 #places green square in bitmap display
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, green
	sw $t2, 0($t5) 

	lw $ra 8($sp) #returns return address for stapler function
	addi $sp, $sp, 12
	jr $ra


	Stapler2: #all stapler functions are nearly identical
	addi $sp, $sp, -12
	sw $ra 8($sp)
	
	la $s0, setting
	lw $s2, width
	lw $t0, stapler2curx
	lw $t1, stapler2cury 

	mul $t5, $t1, $s2 #t1 == $s5 #t0 == $s4
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, stapler2curx
	lw $t1, stapler2cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, black
	sw $t2, 0($t5) 

	addi $t0, $t0, -1
	blt $t0, $zero, reset2
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, staple
	sb  $t2, 0($t5)	
	b skip2
	reset2:
	li $t0, 7
	jal random
	addi $t1, $t1, 2
	divu $t1, $t3
	mfhi $t1
	addi $t1, $t1, 1
	skip2:
	sw $t0, stapler2curx
	sw $t1, stapler2cury

	lw $s2, width
	lw $t0, stapler2curx
	lw $t1, stapler2cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, green
	sw $t2, 0($t5) 
	
	lw $ra 8($sp)
	addi $sp, $sp, 12
	jr $ra

	Stapler3:
	#movement of 3rd stapler
	addi $sp, $sp, -12
	sw $ra 8($sp)
	la $s0, setting
	lw $s2, width
	lw $t0, stapler3curx
	lw $t1, stapler3cury
	mul $t5, $t1, $s2 #t1 == $s5 #t0 == $s4
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, stapler3curx
	lw $t1, stapler3cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, black
	sw $t2, 0($t5) 

	addi $t0, $t0, -1
	blt $t0, $zero, reset3
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, staple
	sb  $t2, 0($t5)	
	b skip3
	reset3:
	li $t0, 7
	jal random
	addi $t1, $t1, 3
	divu $t1, $t3
	mfhi $t1
	addi $t1, $t1, 1
	skip3:
	sw $t0, stapler3curx
	sw $t1, stapler3cury

	lw $s2, width
	lw $t0, stapler3curx
	lw $t1, stapler3cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, green
	sw $t2, 0($t5) 

	lw $ra 8($sp)
	addi $sp, $sp, 12
	jr $ra

	Stapler4:
	#movement of 3rd stapler
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	
	la $s0, setting
	lw $s2, width
	lw $t0, stapler4curx
	lw $t1, stapler4cury
	mul $t5, $t1, $s2 #t1 == $s5 #t0 == $s4
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, stapler4curx
	lw $t1, stapler4cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, black
	sw $t2, 0($t5) 

	addi $t0, $t0, -1
	blt $t0, $zero, reset4
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, staple
	sb  $t2, 0($t5)	
	b skip4
	reset4:
	li $t0, 7
	jal random
	addi $t1, $t1, 4
	divu $t1, $t3
	mfhi $t1
	addi $t1, $t1, 1
	skip4:
	sw $t0, stapler4curx
	sw $t1, stapler4cury

	lw $s2, width
	lw $t0, stapler4curx
	lw $t1, stapler4cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, green
	sw $t2, 0($t5) 

	lw $ra 8($sp)
	addi $sp, $sp, 12
	jr $ra

	Stapler5:
	#movement of 3rd stapler
	addi $sp, $sp, -12
	sw $ra , 8($sp)#stores return address
	la $s0, setting
	lw $s2, width
	lw $t0, stapler5curx
	lw $t1, stapler5cury
	mul $t5, $t1, $s2 #t1 == $s5 #t0 == $s4
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, space
	sb $t2, 0($t5)

	lw $s2, width
	lw $t0, stapler5curx
	lw $t1, stapler5cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, black
	sw $t2, 0($t5) 

	addi $t0, $t0, -1
	blt $t0, $zero, reset5
	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5 #base address+width*i+j)
	lb $t2, staple
	sb  $t2, 0($t5)	
	b skip5
	reset5:
	li $t0, 7
	jal random
	addi $t1, $t1, 5
	divu $t1, $t3
	mfhi $t1
	addi $t1, $t1, 1
	
	lw $t7, scorenum
	addi $t7, $t7, 1
	sw $t7, scorenum
	move $t7, $zero # $a1 is where you set the upper bound
	skip5:
	sw $t0, stapler5curx
	sw $t1, stapler5cury

	lw $s2, width
	lw $t0, stapler5curx
	lw $t1, stapler5cury
	mul $t5, $t1,$s2
	add $t5, $t5, $t0
	sll $t5, $t5, 2
	add $t5,$gp, $t5
	lw $t2, green
	sw $t2, 0($t5) 
	
	lw $ra, 8($sp)
	addi $sp, $sp, 12#pops return address
	jr $ra



	Stapler1Contact: #checks if the curx and cury of the player is the same as the curx and cury of staple
	la $s0, setting
	lw $s2, width
	lw $t1, curry
	lw $t0, currx
	lw $s5, stapler1cury
	lw $s4, stapler1curx

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5

	mul $t6, $s5, $s2
	add $t6, $t6, $s4
	add $t6,$s0, $t6
	beq $t5, $t6, gameover

	sw $t1, curry
	sw $t0, currx
	sw $s5, stapler1cury
	sw $s4, stapler1curx
	jr $ra 

	Stapler2Contact:
	la $s0, setting
	lw $s2, width
	lw $t1, curry
	lw $t0, currx
	lw $s5, stapler2cury
	lw $s4, stapler2curx

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5

	mul $t6, $s5, $s2
	add $t6, $t6, $s4
	add $t6,$s0, $t6
	beq $t5, $t6, gameover

	sw $t1, curry
	sw $t0, currx
	sw $s5, stapler2cury
	sw $s4, stapler2curx
	jr $ra 

	Stapler3Contact:
	la $s0, setting
	lw $s2, width
	lw $t1, curry
	lw $t0, currx
	lw $s5, stapler3cury
	lw $s4, stapler3curx

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5

	mul $t6, $s5, $s2
	add $t6, $t6, $s4
	add $t6,$s0, $t6
	beq $t5, $t6, gameover

	sw $t1, curry
	sw $t0, currx
	sw $s5, stapler3cury
	sw $s4, stapler3curx
	jr $ra

	Stapler4Contact:
	la $s0, setting
	lw $s2, width
	lw $t1, curry
	lw $t0, currx
	lw $s5, stapler4cury
	lw $s4, stapler4curx

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5

	mul $t6, $s5, $s2
	add $t6, $t6, $s4
	add $t6,$s0, $t6
	beq $t5, $t6, gameover

	sw $t1, curry
	sw $t0, currx
	sw $s5, stapler4cury
	sw $s4, stapler4curx
	jr $ra


	Stapler5Contact:
	la $s0, setting
	lw $s2, width
	lw $t1, curry
	lw $t0, currx
	lw $s5, stapler5cury
	lw $s4, stapler5curx

	mul $t5, $t1, $s2
	add $t5, $t5, $t0
	add $t5,$s0, $t5

	mul $t6, $s5, $s2
	add $t6, $t6, $s4
	add $t6,$s0, $t6
	beq $t5, $t6, gameover

	sw $t1, curry
	sw $t0, currx
	sw $s5, stapler5cury
	sw $s4, stapler5curx
	jr $ra
	Scoreboard:	#displays score after every move
	li $v0, 4
	la $a0, score
	syscall
	li $v0, 1
	lw $a0, scorenum
	syscall
	li $v0, 4
	la $a0,newline
	syscall
	jr $ra
	
	random: #random num generator using lfsr from hw(has comments that were used for the hw)
	li $v0, 30
	syscall
	move $s1, $a0
	move $t9, $s1 ##XOR1 
	move $t8, $s1 ##XOR2 
	move $t7, $s1 ##XOR3 
	move $t6, $s1 ##XOR4
	srl $t9, $t9, 31
	andi $t9, $t9, 1 ### num.y >> 31 & 0x1 
	srl $t8, $t8, 30
	andi $t8,$t8, 1 ##num.y>>30&0x1
	srl $t7,$t7,10
	andi $t7, $t7, 1 #num.y>>10&0x1 
	srl $t6, $t6, 0
	andi $t6, $t6, 1 ##num.y & 0x1
	xor $t9, $t8, $t9 ##num.z = xor bits 32, 22, 2, 1
	xor $t9, $t9, $t7 ## bit 1 is the left bit and bit 32 is the right most so we do 32-bit index 
	xor $t2, $t9, $t6## num.z is assigned to $t2
	bnez $t2, randomelse ##if(n==69) branch in c code
	srl $s1, $s1, 1 ##move bit over for 0 bit since 0 is easier than using 69 
	move $v0, $s1
	li $t3, 6
	move $t1, $v0
	jr $ra
	randomelse:
	srl $s1, $s1, 1 #num.y>>1 sll $t2, $t2, 31 #num.y<<31 
	or $v0, $t2, $s1
	move $s1, $v0 
	li $t3, 6
	move $t1, $v0
	jr $ra


	gameover: #plays game over sound, gameover string, and ends the program
	li $v0, 31 
	lb $a0, pitch
	lb $a1, duration 
	lb $a2, instrument2
	lb $a3, volume2
	syscall 
	li $v0, 4
	la $a0, gameend
	syscall
	#end of program
	li $v0, 10
	syscall	