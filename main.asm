SYS_EXIT equ 0x1
SYS_READ equ 0x3
SYS_WRITE equ 0x4

STDIN equ 0x0
STDOUT equ 0x1
STDERR equ 0x2

section .data
	inputMsg db "> ", 0x0
	inputLen equ $ - inputMsg
	endlMsg db 0xA, 0x0
	endlLen equ $ - endlMsg

section .bss
	input resb 64
	acronym resb 16
	exitCode resb 1

section .text
	global _start

_start:
	mov r8, 0
	mov [exitCode], r8

	mov rax, SYS_WRITE
	mov rbx, STDOUT
	mov rcx, inputMsg
	mov rdx, inputLen
	int 0x80

	mov rax, SYS_READ
	mov rbx, STDIN
	mov rcx, input
	mov rdx, 64
	int 0x80

	xor r8, r8 ; index of loop
	xor r9, r9 ; index of acronym
	xor r10, r10 ; add coefficient
	loop:
	cmp byte[input+r8], 0x0 ; end of str
	je end
	cmp byte[input+r8], 0xA ; newline
	je end

	cmp r8, 0 ; first character
	je addCurrent
	cmp byte[input+r8], 0x20 ; space
	je addPrevious

	jmp continue

	addCurrent:
	mov r10, 0x0
	jmp add

	addPrevious:
	mov r10, 0x1
	jmp add

	add:
	mov r11, r8
	add r11, r10
	mov r12, [input+r11]
	mov r13, 0x20 ; case indicator
	not r13 ; negate all bits
	and r12, r13 ; uppercase
	mov [acronym+r9], r12

	inc r9
	jmp continue

	continue:
	inc r8
	jmp loop

	end:
	mov r12, 0x0
	mov [acronym+r9], r12

	mov rax, SYS_WRITE
	mov rbx, STDOUT
	mov rcx, acronym
	mov rdx, 16
	int 0x80

	mov rax, SYS_WRITE
	mov rbx, STDOUT
	mov rcx, endlMsg
	mov rdx, endlLen
	int 0x80

	exit:
	mov rax, SYS_EXIT
	mov rbx, [exitCode]
	int 0x80

