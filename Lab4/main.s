;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M
;           Microcontrollers in Assembly Language and C, Yifeng Zhu,
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be
;           held liable for any direct, indirect or consequential damages, for any
;           reason whatever. More information can be found from book website:
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************
	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s
	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	BL System_Clock_Init
	BL UART2_Init
	;BL displaykey
;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;;
	;enable clock to gpio c and b
startWhile
	MOV r2, #0x0000002E			;this is default state
	LDR r4, =str				;string address loaded to r4
	;while loop is where it will sit until a button is pressed, button press indicated by B IDR not being 1 1 1 1 for relevant pins
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E				;isolates for just the pins we want
	CMP r1, r2					;checks for equivalence
	BNE startWhile

	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	AND r1, #0xFFFFFFFA		;clear
	ORR r1, #0x00000006			;set
	STR r1, [r0, #RCC_AHB2ENR]
	;configure port c to digital output
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	AND r1, #0xFFFFFF00		;clear
	ORR r1, #0x00000055			;set
	STR r1, [r0, #GPIO_MODER]
	;configure port b to digital input
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	MOV r3, #0x00000CFC			;clear
	BIC r1, r3
	AND r1, #0x00000000			;set
	STR r1, [r0, #GPIO_MODER]
	;pull down all port c for initial state
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0xFFFFFFF0			;clear
	ORR r1, #0x00000000			;set to pull down
	STR r1, [r0, #GPIO_ODR]
	
	MOV r2, #0x0000002E			;this is default state
	LDR r4, =str				;string address loaded to r4
	;while loop is where it will sit until a button is pressed, button press indicated by B IDR not being 1 1 1 1 for relevant pins
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E				;isolates for just the pins we want
	CMP r1, r2					;checks for equivalence
	BNE row1Check
	B startWhile
	
	
;debounces button press
delay	PROC
	; Delay for software debouncing
	LDR	r8, =0x9999
delayloop
	SUBS	r8, #1
	BNE	delayloop
	BX LR
	
	;checks if row 1 has the pressed button
row1Check
	BL delay
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0x00000000			;sets us back to a starting point
	ORR r1, #0xFFFFFFFE			;pulls up everything except row 1
	STR r1, [r0, #GPIO_ODR]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E
	CMP r1, r2					;checks for equivalence
	BNE check11
	B row2Check

	
check11
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits i want
    MOV r2, #0x0000002C ;I think I got this right
    CMP r1, r2
    BNE check12
    MOV r5, #0x00000031 ;1
	STR r5, [r4]
    B displaykey

check12
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits I want
    MOV r2, #0x0000002A
    CMP r1, r2
    BNE check13
    MOV r5, #0x00000032 ;2
    STR r5, [r4]
	B displaykey

check13
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
    AND r1, #0x2E ; I think I need this here
    MOV r2, #0x00000026
    CMP r1, r2
    BNE check14
    MOV r5, #0x00000033 ;3
    STR r5, [r4]
	B displaykey

check14
    MOV r5, #0x00000041 ;a
    STR r5, [r4]
    B displaykey


row2Check
	BL delay
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0x00000000			;sets us back to a starting point
	ORR r1, #0xFFFFFFFD 		;pulls up everything except row 2
	STR r1, [r0, #GPIO_ODR]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E
	CMP r1, r2					;checks for equivalence
	BNE check21
	B row3Check
	
	AND r1, #0x2E


check21
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits i want
    MOV r2, #0x0000002C ;I think I got this right
    CMP r1, r2
    BNE check22
    MOV r5, #0x00000034 ;4
    STR r5, [r4]
    B displaykey

check22
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits I want
    MOV r2, #0x0000002A
    CMP r1, r2
    BNE check23
    MOV r5, #0x00000035 ;5
    STR r5, [r4]
    B displaykey

check23
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
    AND r1, #0x2E ; I think I need this here
    MOV r2, #0x00000026
    CMP r1, r2
    BNE check24
    MOV r5, #0x00000036 ;6
    STR r5, [r4]
    B displaykey

check24
    MOV r5, #0x00000042 ;b
    STR r5, [r4]
    B displaykey

row3Check
	BL delay
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0x00000000			;sets us back to a starting point
	ORR r1, #0xFFFFFFFB			;pulls up everything except row 3
	STR r1, [r0, #GPIO_ODR]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E
	CMP r1, r2					;checks for equivalence
	BNE check31
	B row4Check
	


check31
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits i want
    MOV r2, #0x0000002C ;I think I got this right
    CMP r1, r2
    BNE check32
    MOV r5, #0x00000037 ;7
    STR r5, [r4]
    B displaykey

check32
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits I want
    MOV r2, #0x0000002A
    CMP r1, r2
    BNE check33
    MOV r5, #0x00000038 ;8
    STR r5, [r4]
	B displaykey

check33
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
    AND r1, #0x2E ; I think I need this here
    MOV r2, #0x00000026
    CMP r1, r2
    BNE check34
    MOV r5, #0x00000039 ;9
    STR r5, [r4]
	B displaykey

check34
    MOV r5, #0x00000043 ;c
    STR r5, [r4]
	B displaykey

row4Check
	BL delay
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_ODR]
	AND r1, #0x00000000			;sets us back to a starting point
	ORR r1, #0xFFFFFFF7			;pulls up everything except row 4
	STR r1, [r0, #GPIO_ODR]
	
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E
	CMP r1, r2					;checks for equivalence
	BNE check41

check41
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits i want
    MOV r2, #0x0000002C ;I think I got this right
    CMP r1, r2
    BNE check42
    MOV r5, #0x0000002A ;+ I forgot what the keypad looked like so put some unique characters here sorry
    STR r5, [r4]
	B displaykey
	
check42
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
	AND r1, #0x2E ;selecting the bits I want
    MOV r2, #0x0000002A
    CMP r1, r2
    BNE check43
    MOV r5, #0x00000030 ;0
    STR r5, [r4]
    B displaykey

check43
    LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_IDR]
    AND r1, #0x2E ; I think I need this here
    MOV r2, #0x00000026
    CMP r1, r2
    BNE check44
    MOV r5, #0x00000023 ;-
    STR r5, [r4]
	B displaykey
	
check44
    MOV r5, #0x00000044 ;d
    STR r5, [r4]
	B displaykey

displaykey
;char1 DCD 43
	;PUSH {LR}
	BL delay
	STR	r5, [r8]
	;LDR	r0, =char1
	LDR r0, =str   ; First argument
	MOV r1, #1    ; Second argument
	BL USART2_Write
 	;POP{PC}
	BL delay
	B startWhile
	ENDP		
	
	ALIGN			
	AREA myData, DATA, READWRITE
	ALIGN
;char1	DCD	0x43
str 	DCB 'x', 0
	END


