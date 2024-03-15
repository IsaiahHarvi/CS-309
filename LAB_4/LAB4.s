@ LAB 5
@ ISAIAH HARVILLE
@ 10/23/2023
@
@ TO ASSEMBLE, LINK, RUN, AND DEBUG
@	gcc -g -nostartfiles -o LAB4 LAB4.s -lc
@	gdb LAB4
@	(gdb) run
@

.equ READERROR, 0 @ Check for scanf read error

.section .data
.balign 4
promptStr: .asciz "\nEnter an integer between 1 and 100: " @ Prompt for user input

.balign 4
outputNumStr: .asciz "You entered %d.\n" @ Output the number the user entered

.balign 4
errorStr: .asciz "\nError: Enter an integer between 1 and 100.\n\n" @ Error message

.balign 4
evenIntroStr: .asciz "\nThe even numbers from 1 to %d are:\n" @ Intro message for even numbers

.balign 4
oddIntroStr: .asciz "\nThe odd numbers from 1 to %d are:\n" @ Intro message for odd numbers

.balign 4
evenNumStr: .asciz "%d\n" @ Print the current even number

.balign 4
oddNumStr: .asciz "%d\n" @ Print the current odd number

.balign 4
evenSumStr: .asciz "The even sum is: %d\n" @ Print the sum of the even numbers

.balign 4
oddSumStr: .asciz "The odd sum is: %d\n\n" @ Print the sum of the odd numbers

.balign 4
numInputPattern: .asciz "%d" @ Int format for read

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input

.balign 4
strInputError: .skip 100*4 @ Used to clear the input buffer for invalid input

.balign 4
intInput: .word 0	@ Located used to store the user input

.balign 4
evenSum: .word 0	@ Store the sum of even numbers

.balign 4
oddSum: .word 0		@ Store the sum of odd numbers


.section .text
@ C LIBRARY FUNCTIONS
.global printf
	@ r0 - Contains the starting address of the string to be printed
	@ r1 - If the string contains a %d, %c, etc. register r1 must contain the value to be printed
	@ When the call returns: registers r0-r3 and r12 are changed.

.global scanf
	@ r0 - Contains the address of the input format string used to read the input value (numInputPattern)
	@ r1 - Contains the address where the input value is going to be saved (intInput)
	@ When the call returns: registers r0-r3 and r12 are changed.
	@ Does not conform to input pattern: r0 has 0, otherwise r0 has 1.
	@ The input buffer will NOT be cleared of the invalid input.

.global main @ This is the entry point for the program because we link with C libraries

@ PROGRAM STARTS HERE
main:

@ ---
prompt:
@ ---
	ldr r0, =promptStr	@ Print the prompt
	bl printf		@ Call the C printf to display the prompt

@ ---
get_input:
@ ---
	@ Set r0 with address of input pattern
	@ scanf puts the input value at the address stored in r1. We are going to use the address
	@ for our declared variable in the data section - intInput

	ldr r0, =numInputPattern @ Read one number
	ldr r1, =intInput	 @ Load r1 with the address of input value storage

	bl scanf
	cmp r0, #READERROR 	 @ Check for readerror
	beq readerror		 @ If error
	ldr r1, =intInput	 @ Have to reload r1 because it is wiped
	ldr r1, [r1]		 @ Read contents of intInput and store in r1 for print
	
	cmp r1, #1		 @ Check if the number is less than 1
	blt inputerror		 @ If less go to error
	cmp r1, #100		 @ Check if number is greater than 100
	bgt inputerror		 @ If greater go to error
	
	ldr r0, =outputNumStr	 @ Print the number the user just entered
	@ r1 already has the input number
	bl printf
	
	b printEven		 @ Go to print even numbers

@ ---
printEven:
@ ---
	ldr r0, =evenIntroStr	 @ Print intro msg for even
	ldr r1, =intInput	 @ Load memory address of the input number
	ldr r1, [r1]		 @ Read contents of intInput and store in r1
	bl printf

	mov r2, #0		 @ Initialize the even sum to 0
	mov r3, #2 		 @ Initialize the loop counter to 2
	
	b evenLoop		 @ Branch to print even numbers

@ ---
evenLoop:
@ ---
	ldr r4, =intInput	 @ Load r4 with the address of intInput
	ldr r4, [r4]		 @ Load userInput number from intInput into r4
	cmp r3, r4 		 @ Compare the loop counter to the input number
	bgt finishEvenLoop	 @ If greater exit the loop

	push {r3}		 @ Save r3 to the stack
	ldr r0, =evenNumStr	 @ Print current even num
	mov r1, r3		 @ Current number is the argument for printf
	bl printf
	pop {r3}		 @ Restore r3 from stack
	
	ldr r5, =evenSum	 @ Load the address of evenSum into r5
	ldr r2, [r5]		 @ Load current sum from memory into r2
	add r2, r2, r3		 @ Add current even number to the sum
	str r2, [r5]		 @ Store the updated sum in memory

	add r3, r3, #2		 @ Increment loop counter by 2 (skip the odd number)
	
	b evenLoop		 @ Repeat

@ ---
finishEvenLoop:
@ ---
	ldr r0, =evenSumStr 	 @ Print even number sum
	ldr r1, =evenSum    	 @ Load the address of evenSum into r1
	ldr r1, [r1]	    	 @ Load the valuye at the address into r1
	bl printf
	
	b printOdd		 @ Go to print odd numbers

@ ---
printOdd:
@ ---
	ldr r0, =oddIntroStr 	 @ Print odd intro str
	ldr r1, =intInput    	 @ Load the address of intInput into r1
	ldr r1, [r1]	     	 @ Load the value at the address into r1
	bl printf

	mov r2, #0 	     	 @ Intialize odd sum to 0
	mov r3, #1	    	 @ Intialize the loop counter to 1
	
	b oddLoop	    	 @ Start the odd loop

@ ---
oddLoop:
@ ---
	ldr r4, =intInput	 @ Load r4 with address of intInput
	ldr r4, [r4]		 @ Load user input number from intInput into r4
	cmp r3, r4		 @ Compare the loop counter to the input number
	bgt finishOddLoop	 @ If greater exit the loop

	push {r3}		 @ Save r3 to the stack
	ldr r0, =oddNumStr	 @ Print current odd num
	mov r1, r3		 @ Current odd number is argument for printf
	bl printf
	pop {r3}		 @ Restore r3 from stack

	ldr r5, =oddSum		 @ Load the address of oddSum into r5
	ldr r2, [r5]		 @ Load current sum from memory into r2
	add r2, r2, r3		 @ Add current odd number to the sum
	str r2, [r5]		 @ Store the updated sum in memory

	add r3, r3, #2		 @ Skip the even numbers
	
	b oddLoop		 @ Repeat

@ ---
finishOddLoop:
@ ---
	ldr r0, =oddSumStr	 @ Print odd number sum
	ldr r1, =oddSum		 @ Load address of the sum into r5
	ldr r1, [r1]		 @ Load sum int into r1 to be argument for printf
	bl printf

	b myexit 		 @ End of Program

@ ---
readerror:
@ ---
	@ Recieved readerror from scanf, clean input buffer and branch back for input
	ldr r0, =strInputPattern
	ldr r1, =strInputError   @ Put address into r1 for read
	bl scanf		 @ Scan keyboard
	b prompt		 @ Return to the prompt

@ ---
inputerror:
@ ---
	ldr r0, =errorStr	 @ Load address of error message str
	bl printf		 @ Print the error message
	b prompt		 @ Go back to prompt to get a new input

@ ---
myexit:
@ ---
	@ End of Program.  Force exit
	mov r7, #0x01 @ SVC call to exit
	svc 0	      @ Make system call

@ END OF FILE

