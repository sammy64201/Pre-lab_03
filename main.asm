//*****************************************************************************
// Universidad del Valle de Guatemala
// IE2023 Programacion de Microcontroladores
// Autor: Edgar Chavarria 22055
// Proyecto: PM-Lab_01.asm
// Descripcion: Contador binario de 4 bits
// Hardware: ATMega328P
// Created: 1/28/2024 7:08:48 PM
// Author : Samuel
//*****************************************************************************
// ENCABEZADO
//*****************************************************************************

.INCLUDE "M328PDEF.inc"
.CSEG
.ORG 0x00
JMP SETUP
.ORG 0x0006 ; VECTOR PARA ISR: PCINT0
JMP ISR_PCINT0

MAIN:
//*****************************************************************************
// STACK POINTER 
//*****************************************************************************

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17 

//*****************************************************************************
// CONFIGURACION DE MCU
//*****************************************************************************
SETUP:

	; DECLARACION DE PUERTOS DE SALIDA
	SBI DDRC, PC0
	SBI DDRC, PC1
	SBI DDRC, PC2
	SBI DDRC, PC3
	
	; DECLARACION DE PUERTOS DE ENTRADA Y COMO PULL-UPS
	SBI PORTB, PB0
	CBI DDRB, PB0
	SBI PORTB, PB1
	CBI DDRB, PB1

	; HABILITAR PCINT0 Y PCINT1
	LDI R16, (1 << PCINT1)|(1 << PCINT0)
	STS PCMSK0, R16
	
	; HABILITAMOS LA ISR PCINT[7:0] O SEA HABILITAR LA INTERRUPCION
	LDI R16, (1 << PCIE0)
	STS PCICR, R16

	; HABILITAMOS LAS INTERRUPCIIONES GLOBALES
	SEI

	LDI R20, 0x00
//*****************************************************************************
// LOOP 
//*****************************************************************************


LOOP2:
	OUT PORTC, R20
	RJMP LOOP2



//*****************************************************************************
// SUBRUTINA DE ISR INT0
//*****************************************************************************
ISR_PCINT0:
	PUSH R16
	IN R16, SREG
	PUSH R16 
	
	IN R18, PINB

	SBRC R18, PB1
	RJMP CHECKPB0 
	INC R20
	CPI R20, 0b0000_1111
	BRNE SALIR
	CLR R20
	JMP SALIR

CHECKPB0:
	SBRC R18, PB0
	JMP SALIR
	DEC R20
	BRNE SALIR
	CLR R20
	
SALIR:
	SBI PINB, PB5
	SBI PCIFR, PCIF0

	POP R16
	OUT SREG, R16
	POP R16
	RETI


//*****************************************************************************
