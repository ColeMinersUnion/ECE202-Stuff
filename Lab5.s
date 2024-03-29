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
	
	;	Enable clocks for GPIOC, GPIOB
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	AND r1, #0xFFFFFFFA		;clear
	ORR r1, #0x00000006			;set
	STR r1, [r0, #RCC_AHB2ENR]
	;configure b to digital output
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER]
	AND r1, #0xFFFFFF00		;clear
	ORR r1, #0x000000CC			;set
	STR r1, [r0, #GPIO_MODER]
	; Set GPIOC pin 13 (blue button) as an input pin
	LDR r0, =GPIOC_BASE
	LDR r1, [r0, #GPIO_MODER]
	AND r1, #0xF3FFFFFF			;clear
	ORR r1, #0x00000000			;set
	STR	r1, [r0, #GPIO_MODER]
	
checkB	LDR r0, =GPIOC_BASE
		LDR r1, [r0, #GPIO_IDR]
		AND r1, #0x00002000		;isolates for just pin 13
		CMP r1, #0x00002000		;checks if  button pressed
		BNE start1				;moves into wiping loop
		B checkB				;goes back to check button again
			
start1	MOV r2, #820		;number of iterations for 140 degrees
comp1	CMP r2, #0
		BEQ start2			;forward wipe done, reverse it
forward	LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000084	;first step, AB'
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000044	;second step, AB
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000048	;third step, A'B
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000088	;third step, A'B'
		STR r1, [r0, #GPIO_ODR]
		
		SUB r2, #1			;decrement counter
		;;;;PUT BL TO TERTERM OUTPUT HERE;;;;;
		B comp1				;see if done yet
		
start2	MOV r2, #820
comp2	CMP r2, #0
		BEQ checkB			;done, back to start
		
reverse	LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000084	;first step, AB'
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000088	;second step, A'B'
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000048	;third step, A'B
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_ODR]
		AND r1, #00000044	;third step, AB
		STR r1, [r0, #GPIO_ODR]
		
		SUB r2, #1			;decrement counter
		
		;;;;PUT BL TO TERTERM OUTPUT HERE;;;;;
		B comp2				;see if done yet
	ENDP		
		
	
	ALIGN			
	AREA myData, DATA, READWRITE
	ALIGN
; Replace ECE1770 with your last name
str DCB "NeelyHansen",0
	END
