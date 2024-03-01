;LABELS				;INSTRUCTIONS		OPERANDS				COMMENTS
					.include			"m328Pdef.inc"			;files which defines register names and addresses specific to the ATmega328P.

					.equ				HeartbeatSensorPin = 0  ;Equates are used to assign symbolic names to constants, such as pin numbers
					.equ				ButtonStartPin = 1

																;register definitions
					.def				HBCount = r16			;register to store the heartbeat count 
					.def				HBCheck = r17			;flags a new heartbeat 
					.def				TimeinSec = r18			;keeps track of the time in seconds 
					.def				HBperMin = r19			;heartbeat per minute 
					.org				0x0000
					rjmp				init					;relative jump 
					.org				0x0016
					call				timerIsr
					reti

init:
																;Initialize variables
					ldi					HBCount, 0				; load immediate  HBCount <-- 0
					ldi					HBCheck, 0
					ldi					TimeinSec, 0
					ldi					HBperMin, 0

																; Set HeartbeatSensorPin and ButtonStartPin as inputs
					cbi					DDRC, HeartbeatSensorPin
					cbi					DDRC, ButtonStartPin																
					sbi					PORTC, ButtonStartPin	; Enable pull-up resistor for ButtonStartPin

																; Initialize Timer1
    
					ldi					r21, 0x00				;clear Timer/Counter1 register 
					sts					TCNT1H, r21 
					sts					TCNT1L, r21 
	

					ldi					r21,0x0D
					sts					TCCR1B, r21				;CTC mode, 1024 prescaler
					ldi					r21,0x00
					sts					TCCR1A, r21
					ldi					r21, 0x36     
					ldi					r22,0x11
					sts					OCR1AH, r22
					sts					OCR1AL,r21
					ldi					r21, 0b00000010
					sts					TIMSK1,r21
					sei

startCounting:
																;Check for heartbeat
					in					r20, PINC
					sbrs				r20, HeartbeatSensorPin
					rjmp				noHeartbeat
					cpi					HBCheck,0x00
					brne				startCounting

																;there is heartbeat :
					inc					HBCount
					ldi					HBCheck,0x01
					rjmp				startCounting

noHeartbeat:
					cpi					HBCheck,0x01
					brne				startCounting 
					ldi					HBCheck, 0x00
					rjmp				startCounting


timerIsr:
					inc					TimeinSec
					inc					TimeinSec
					inc					TimeinSec
					inc					TimeinSec
					inc					TimeinSec
					cpi					TimeinSec,0x0F
					brne				continue
					rjmp				printLCD
continue:	
					ldi					r21, 0x36
					ldi					r22,0x11 
					sts					OCR1AH, r22
					sts					OCR1AL,r21
					reti

printLCD:
					LDI					R20,4
					MUL					HBCount ,R20
					MOV					HBperMin,R0
					SBI					DDRB, 0					; Define B0 as output
					SBI					DDRB, 1					;Define B1 as output
					CBI					DDRC, 0					; Define C0 as input
					LDI					R17,0XFF
					OUT					DDRD, R17
					RJMP				INITIALIZELCD

INITIALIZELCD:
					LDI					R18, 0X02
					CALL				CMNDLCD
					LDI					R18, 0X22          
					CALL				CMNDLCD

					LDI					R18, 0X0E				;R18 = 0X0E
					CALL				CMNDLCD

					LDI					R18, 0X06
					CALL				CMNDLCD
					rjmp				MAIN





DATALCD:
					SWAP				R18
					SBI					PORTB, 1				;B1 = 1
					OUT					PORTD, R18				; PORTD = R18
					SBI					PORTB, 0				; B0 = 1
					CBI					PORTB, 0				; B0 = 0
					LDI					R16,HIGH(64286)			;20 MS delay
					LDI					R17,LOW(64286)			;20 MS delay
					CALL				Delay

					SWAP				R18
					OUT 				PORTD, R18				;PORTD = R18
					SBI 				PORTB, 0				;B0 = 1
					CBI 				PORTB, 0				;B0 = 0
					LDI 				R16,HIGH(64286)			;20 MS delay
					LDI 				R17,LOW(64286)			;20 MS delay
					CALL 				Delay
					RET

CMNDLCD:
					SWAP 				R18						;swap nibbles(bits)
					CBI 				PORTB, 1				;B1 =0
					OUT 				PORTD, R18				;PORTD = R18
					SBI 				PORTB, 0				;B0 =1
					CBI 				PORTB, 0				;B0 =0(send a pulse)

					LDI 				R16,HIGH(64286)			;20 MS delay
					LDI 				R17,LOW(64286)			;20 MS delay
					CALL 				Delay

					SWAP 				R18				
					OUT 				PORTD, R18				;PORTD = R18
					SBI 				PORTB, 0				;B0 =1
					CBI 				PORTB, 0				;B0 =0

					LDI					R16,HIGH(64286)			;20 MS delay
					LDI					R17,LOW(64286)			;20 MS delay
					CALL				Delay
					RET

Delay:
					STS					TCNT1H,R16
					STS					TCNT1L,R17
					LDI					R16,0					;Normal mode
					STS					TCCR1A,R16
					LDI					R16,4
					STS					TCCR1B,R16				;256 Pre-scaler
again1:
					SBIS				TIFR1,TOV1
					JMP					again1
					LDI					R16,0
					STS					TCCR1B,R16
					SBI					TIFR1,TOV1
					RET

TOASCII:
					LDI					R23, 0					;R23 = 0 (tens counter)
					LDI					R24, 0					;R24 = 0 (hundreds counter)

					CALL				CHECK100
					CALL				CHECK10

					LDI					R21, 0X30				;R21 = 0X30 (ASCII common value)
					ADD					R24, R21				;R24 = R24 + R21
					MOV					R18, R24				;R18 = R24
					CALL				DATALCD

					ADD					R23, R21				;R23 = R23 + R21
					MOV					R18, R23				;R18 = R23
					CALL				DATALCD

					ADD					R20, R21				;R20 = R20 + R21
					MOV					R18, R20				;R18 = R20
					CALL				DATALCD
					RET

CHECK100:
					CPI					R20, 100				;compare R20 with 100
					BRSH				HUN						;if R20 >= 100 BRANCH to Hun subroutine
					RET

CHECK10:
					CPI					R20, 10					;compare R20 with 10
					BRSH				TENS					;if R20 >= 10 BRANCH To tens subroutine
					RET

TENS:
					INC					R23						;R23 = R23 + 1
					SUBI				R20, 10					;R20 = R20 - 10
					CPI					R20, 10					;compare R20 with 10
					BRSH				tens					;if R20 >= 10 BRANCH to tens subroutine
					RET

HUN:
					INC					R24						;R24= R24 + 1
					SUBI				R20, 100				;R20 = R20 - 100
					CPI					R20, 100				;compare R20 with 100
					BRSH				Hun						;if R20 >= 100 Branch to HUN subroutine
					RET
MAIN:
    
																; Display "Heart Beats per Minute: "
					LDI					R18, 'H'
					CALL				DATALCD
					LDI					R18, 'B'
					CALL				DATALCD
					LDI					R18, ' '
					CALL				DATALCD
					LDI					R18, 'p'
					CALL				DATALCD
					LDI					R18, 'e'
					CALL				DATALCD
					LDI					R18, 'r'
					CALL				DATALCD
					LDI					R18, ' '
					CALL				DATALCD
					LDI					R18, 'M'
					CALL				DATALCD
					LDI					R18, 'i'
					CALL				DATALCD
					LDI					R18, 'n'
					CALL				DATALCD
					LDI					R18, ':'
					CALL				DATALCD
					LDI					R18, ' '
					CALL				DATALCD

																;Display the ASCII characters for the heart rate value
																;LDI R20, 120
					mov					R20,HBperMin
					CALL				TOASCII
					LDI					R18, 0X01
					CALL				CMNDLCD

					rjmp				init
	


	