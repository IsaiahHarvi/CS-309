@ LAB 5
@ ISAIAH HARVILLE
@ 11/06/2023
@
@ TO ASSEMBLE, LINK, RUN, AND DEBUG
@	gcc -g -nostartfiles -o LAB5 LAB5.s -lc
@	gdb LAB4
@	(gdb) run
@

.equ READERROR, 0 @ Check for scanf read error

.section .data
.balign 4
promptStr: .asciz "\nEnter the length of the board to cut in inches (at least six and no more than 144):\n" @ Prompt for user input

.balign 4
errorStr: .asciz "\nError: Enter an integer between 6 and 144.\n" @ Error message

.balign 4
noBoardLongEnoughStr: .asciz "No boards long enough. Cut shorter."

.balign 4
ciusStr: .asciz "\n\nCut-It-Up Saw\n"

.balign 4
boardsCutStr: .asciz "Boards cut so far: %d\n"

.balign 4
outOfBoardsStr: .asciz "\nInventory levels have dropped below minimum levels and will now terminate.\nWaste is %d inches. \n\n"

.balign 4
linearLengthStr: .asciz "Linear length of boards cut so far: %d inches\n"

.balign 4
currentBoardLengthsStr: .asciz "Current Board Lengths:\n"

.balign 4
boardLengthsStr: .asciz "One:   %d inches\nTwo:   %d inches\nThree: %d inches\n"

.balign 4
numInputPattern: .asciz "%d" @ Int format for read

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear input buffer for invalid input

.balign 4
strInputError: .skip 100*4 @ used to clear the input buffer for invalid input

.balign 4
intInput: .word 0 @ Used to store the user input

.balign 4
boardsCut: .word 0

.balign 4
linearLength: .word 0

.balign 4
boardLengths: @ Array of boards
	.word 144 
	.word 144
	.word 144


.section .text
@ C LIBRARY FUNCTIONS
.global printf
	@ r0 - Contains starting address of the string to be printed
	@ r1 - Contains the value to be printed at a %
	@ When the call returns: registers r0-r3, r12 are changed

.global scanf
	@ r0 - Contains the address of the input format string used to read the input value
	@ r1 - Contains the address where the input value is going to be saved
	@ When the call returns: registers r0-r3, r12 are changed
	@ Does not conform to the input pattern r0 has 0, otherwise r0 has 1
	@ The input bufffer will not be cleared of the invalid input

.global main @ Entry point

@ PROGRAM STARTS HERE
main:

@ ---
inventory:
@ ---
	@ Print Cut-It-Up Saw
	ldr r0, =ciusStr
	bl printf

	@ Print Boards cut so far
	ldr r0, =boardsCutStr
	ldr r1, =boardsCut	@ Address of boardsCut variable
	ldr r1, [r1]		@ Value at boardsCut address
	bl printf

	@ Print Linear Length of boards cut
	ldr r0, =linearLengthStr
	ldr r1, =linearLength
	ldr r1, [r1]
	bl printf

	@ Print current board lengths
	ldr r0, =currentBoardLengthsStr
	bl printf

	@ Show each board's length
	ldr r0, =boardLengthsStr
	ldr r5, =boardLengths	@ Load address of array into r5
	ldr r1, [r5]		@ First element of array is in r1
	ldr r2, [r5, #4]	@ Load the second length into r2
	ldr r3, [r5, #8]	@ Load the third length into r3

	bl printf		@ Call printf to print the formatted string with the lengths
	
	add sp, sp, #8		@ Adjust stack pointer back
	b check_lengths		@ Make sure there are boards greater than 6"


@ ---
prompt:
@ ---
	ldr r0, =promptStr	@ Print the prompt
	bl printf		@ Call the C printf to display the prompt
	b get_input		@ Get the user input


@ ---
get_input:
@ ---
	@ Set r0 with address of the input pattern
	@ Scanf puts the input value at the address stored in r1

	ldr r0, =numInputPattern
	ldr r1, =intInput	@ Store the input at this address
	bl scanf

	cmp r0, #0 		@ Check if scanf read 0 items
	beq inputerror 		@ If 0, it is not a number
	
	cmp r0, #READERROR	@ Check for readerror
	beq readerror		@ If error
	ldr r1, =intInput	@ r1 is wiped, so reload
	ldr r1, [r1]		@ Read contents of intInput and store in r1

	cmp r1, #6		@ Check if num is < 1
	blt inputerror		@ If error
	cmp r1, #144		@ Check if num is > 144
	bgt inputerror		@ If error

	b cut_board		@ Cut the board


@ ---
cut_board:
@ ---
	ldr r4, =boardLengths	@ Load board array into r4
	mov r6, #0		@ Count index of board length array
	b cut_loop		@ Loop through the array and find a board of acceptable length


@ ---
cut_loop:
@ ---
	cmp r6, #3		 @ Have we checked all boards
	bge cut_too_short	 @ If all boards are checked and none are long enough

	ldr r2, [r4, r6, lsl #2] @ Load current board length into r2
	cmp r2, r1		 @ Compare board length with requested length
	bge cut_made		 @ If board is long enough
	
	add r6, #1		 @ Move to next board if we didnt branch
	blt cut_loop		 @ Loop back for next board


@ ---
cut_too_short:
@ ---
	ldr r0, =noBoardLongEnoughStr
	bl printf 		 @ Print error message if a board wasnt long enough 
	b prompt 		 @ Branch back for input 


@ ---
cut_made:
@ ---
	sub r2, r2, r1		 @ Subtract the requested length from the board
	str r2, [r4, r6, lsl #2] @ Store the new length in the array
	ldr r3, =boardsCut	 @ Tracks the amount of cut boards
	ldr r3, [r3]		 @ Load the value 
	add r3, r3, #1		 @ Add 1 to the total number of boards cut
	ldr r2, =boardsCut	 @ Store the new value
	str r3, [r2]		 
	ldr r3, =linearLength	 @ Tracks the total amount cut
	ldr r3, [r3]		 @ Load the value
	add r3, r3, r1		 @ Add requested length to linear length
	ldr r2, =linearLength	 @ Store new length
	str r3, [r2]

	b inventory		 @ Print the inventory after the cut


@ ---
check_lengths:
@ ---
	ldr r5, =boardLengths	@ Array of boards
	mov r6, #0		@ Index is 0
	mov r7, #1		@ If < 6 flag
	b check_lengths_loop	@ Iterate through the boards


@ ---
check_lengths_loop:
@ ---
	cmp r6, #3 		@ Checked all boards
	bge checked_all		@ If we checked all of the boards
	
	ldr r2, [r5, r6, lsl #2]
	cmp r2, #6		@ Compare board 
	bge greater_than	@ If it is greater than 6

	add r6, r6, #1		@ increment index
	b check_lengths_loop	@ Loop again


@ ---
greater_than:
@ ---
	mov r7, #0		@ A board is greater than 6, so 0
	b checked_all		@ No point in checking the rest, so move on


@ ---
checked_all:
@ ---
	cmp r7, #1		@ If 1: none of the boards were greater than 6
	beq exit		@ Boards are too short
	b prompt		@ Get input to cut more boards


@ ---
exit:
@ ---
	ldr r0, =outOfBoardsStr @ Print the inventory levels str
	ldr r5, =boardLengths	@ Array of boards
	ldr r4, [r5]
	ldr r3, [r5, #4]
	ldr r2, [r5, #8]
	add r1, r4, r3		@ Add the value in r4 to the value in r3, store the result in r1
	add r1, r1, r2		@ Add the value in r1 to r2 and store it in r1
	bl printf
	
	mov r7, #0x01		@ SVC Call to exit
	svc 0			@ END PROGRAM


@ ---
readerror:
@ ---
	@ Recieved error from scanf, clean input buffer and branch back for input
	ldr r0, =strInputPattern
	ldr r1, =strInputError
	bl scanf
	b prompt		@ Go back to prompt for a new input


@ ---
inputerror:
@ ---
	@ User broke parameters of input
	ldr r0, =errorStr
	bl printf		@ Print erorr msg
	
	ldr r0, =strInputPattern
	ldr r1, =strInputError
	bl scanf

	b prompt		@ Go back to prompt for a new input


@ END OF FILE

