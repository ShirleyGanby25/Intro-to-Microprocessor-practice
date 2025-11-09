GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
;PF0                EQU 0x40025004	; 	SW2 - negative logic
PF1                EQU 0x40025008	;	RED LED
PF2                EQU 0x40025010	; 	BLUE LED - ORIG
PF3                EQU 0x40025020	;	GREEN LED
;PF4                EQU 0x40025040	;	SW1 - ORIG -negative logic
PFA		   EQU 0x40025038	; 	3 colours :
	
GPIO_PORTA_DATA_R  	EQU 0x400043FC
GPIO_PORTA_DIR_R   	EQU 0x40004400
GPIO_PORTA_AFSEL_R 	EQU 0x40004420
GPIO_PORTA_PUR_R   	EQU 0x40004510
GPIO_PORTA_DEN_R   	EQU 0x4000451C
GPIO_PORTA_AMSEL_R 	EQU 0x40004528
GPIO_PORTA_PCTL_R  	EQU 0x4000452C
PA_4567				EQU 0x400043C0		; PortA bit 4-7
	
SYSCTL_RCGCGPIO_R  EQU 0x400FE608	


		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4

		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start
			
Start

; initialize PF 1-3 output, PF4 an input, 
; enable digital I/O, ensure alt. functions off.
; Input: none, Output: none, Modifies: R0, R1

	; activate clock for Port F
    LDR R1, =SYSCTL_RCGCGPIO_R      
    LDR R0, [R1]                 
    ORR R0, R0, #0x20               ; set bit 5 to turn on clock
    STR R0, [R1]                  
    NOP								; allow time for clock to finish
    NOP
    NOP        
	
    ; no need to unlock PF2
	
	; disable analog functionality
    LDR R1, =GPIO_PORTF_AMSEL_R     
    LDR R0, [R1]                    
    BIC R0, #0x0E                  	; 0 means analog is off
    STR R0, [R1]       
	
	;configure as GPIO
    LDR R1, =GPIO_PORTF_PCTL_R      
    LDR R0, [R1]   
    BIC R0, R0, #0x00000FF0		; Clears bit 1 & 2
    BIC R0, R0, #0x000FF000	        ; Clears bit 3 & 4
    STR R0, [R1]     
    
	;set direction register
    LDR R1, =GPIO_PORTF_DIR_R       
    LDR R0, [R1]                    
    ORR R0, R0, #0x0E               	; PF 1,2,3 output 
    BIC R0, R0, #0x10               	; Make PF4 built-in button input
    STR R0, [R1]    
	
	; regular port function
    LDR R1, =GPIO_PORTF_AFSEL_R     
    LDR R0, [R1]                     
    BIC R0, R0, #0x1E               ; 0 means disable alternate function
    STR R0, [R1] 
	
	; pull-up resistors on switch pins
    LDR R1, =GPIO_PORTF_PUR_R       ; R1 = &GPIO_PORTF_PUR_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable pull-up on PF4)
    STR R0, [R1]                    ; [R1] = R0

	; enable digital port
    LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
    LDR R0, [R1]                    
    ORR R0,#0x0E                    ; 1 means enable digital I/O
    ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable digital I/O on PF4)
    STR R0, [R1]    
    	
	
	; activate clock for PortA
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R 
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x01           	; turn on GPIOA clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		
; no need to unlock Port A bits

; disable analog mode
		LDR R1, =GPIO_PORTA_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0    			; disable analog mode on PortA bit 4-7
		STR R0, [R1]       
	
;configure as GPIO
		LDR R1, =GPIO_PORTA_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x00FF0000			; clear PortA bit 4 & 5
		BIC R0, R0,#0XFF000000			; clear PortA bit 6 & 7 
		STR R0, [R1]     
    
;set direction register
		LDR R1, =GPIO_PORTA_DIR_R       
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0     			; set PortA bit 4-7 input (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTA_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0xF0      			; disable alternate function on PortA bit 4-7
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTA_PUR_R      	; 
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0xF0              	; enable pull-up on PortA bit 4-7
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTA_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0xF0               ; enable digital I/O on PortA bit 4-7
		STR R0, [R1]    
    	    
		LDR R5, =PA_4567
	
loop                                
	LDR R0, [R5]					; R0 = dip switch status
	LDR R2, =Result
	STR R0,[R2]						; store data

;LED
    LDR R1, =PFA     ; PF data register
    LSR R0, R0, #2                 ; shift right 1 bit
    ;AND R0, R0, #0x0F              ; keep only 4 bits
    STR R0, [R1]                   ; output to LED (PF1–3)
    B loop                         ; go back to read DIP again
	
;----LED1
;    LDR R1, =PFA 
;	ADD R0, R1, R0, LSL #1
;	STR R0, [R1]                    ; [R1] = R0, write to PF
;
;LED2
;    CMP R0, #0x02                   ; second bit
;    BNE LED2              			; if so, spin
;	BL LED_RED
;LED3
;	CMP R0, #0x01                   ; first bit
;    BNE LED2              			; if so, spin
;	BL LED_RED

;    B   loop



;------------LED------------
;LED_RED
;    LDR R1, =PFA                    
;    MOV R0, #0x02                   ; turn on RED
;    STR R0, [R1]                    ; [R1] = R0, write to PF2
;    BX  LR                          ; return
    
;LED_White
;    LDR R1, =PFA                    
;    MOV R0, #0x04                   ; turn on Blue
;    STR R0, [R1]                    ; [R1] = R0, write to PF2
;    BX  LR                          ; return
	
;*/

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
