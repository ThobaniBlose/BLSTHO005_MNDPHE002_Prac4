/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:


write_leds:
	STR R2, [R1, #0x14]
	B main_loop

check_buttons:
    LDR R4, GPIOA_BASE          @ Load GPIOA base address
    LDR R5, [R4, #0x10]         @ Read input data register (IDR) of GPIOA into R5

    @ Check SW0 (bit 0 of IDR)
    ANDS R6, R5, #0x01          @ Mask bit 0 (SW0)
    CMP R6, #0                  @ Compare with 0
    BEQ check_sw1               @ If SW0 is not pressed, check SW1
    ADD R2, R2, #2              @ If SW0 is pressed, increment LEDs by 2

check_sw1:
    ANDS R6, R5, #0x02          @ Mask bit 1 (SW1)
    CMP R6, #0
    BEQ check_sw2
    LDR R5, SHORT_DELAY_CNT     @ If SW1 is pressed, load the short delay value

check_sw2:
    ANDS R6, R5, #0x04          @ Mask bit 2 (SW2)
    CMP R6, #0
    BEQ check_sw3
    MOVS R2, #0xAA              @ If SW2 is pressed, set LEDs to 0xAA

check_sw3:
    ANDS R6, R5, #0x08          @ Mask bit 3 (SW3)
    CMP R6, #0
    BEQ buttons_done            @ If SW3 is not pressed, continue
    B write_leds                @ If SW3 is pressed, freeze the LED state

buttons_done:
    BX LR                       @ Return from function


@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 0
SHORT_DELAY_CNT: 	.word 0
