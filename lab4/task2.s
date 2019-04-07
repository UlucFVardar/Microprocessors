.global _start
_start:
	MOV R0, #0 //Group Number 
   	Bl disp	   // branch to display subroutine

end: b end
   
// ---------------------- DSPLY CODE ------------------------------
disp:    
	// First dsply has only GR, so next 3 line
    // Displays GR letters
	LDR R10, =GROUPID // loading of 'GR' test code
	LDR R11, =DSPLY   // loading first dply mem. address
	STR R10,[R11]	  // Setting dsply codes
    
    
    // next 2 line finds the input group 7-segment code in a list
    LDR R10, =BITCODES // loading the first addres of list
    LDRB R1, [R10, R0] // finding to true code
    
    // next 2 line of code loads the 'OUP' text code to register R2
	LDR R10, =GROUPID  // loading to list head adress
    LDR R2, [R10, #4]  // loading the 'OUP' text code
    
    // adding the 'OUP' text and code of the goup number 
    ADD R3,R1,R2 // code of 'OUPX'
 
    // Displays OUPX code
	LDR R11, =DSPLY    // loading the dsply list head address
    LDR R11, [R11, #4] // loading the last 4 7-segment used mem address
	STR R3,[R11]       // Setting dsply codes
    
    
// --------- static values parts ---------- 
GROUPID:	
		// because of 32 bit mem we store static group names in 2 part
		.word 0x00003d33 // GR
		.word 0x3f3e7300 // OUPX
DSPLY:    
		.word 0xFF200030 // First dply mem. address
		.word 0xFF200020 // Second dply mem. address
BITCODES:
		//numbers to display types 0-9
		.byte 0b00111111 ,0b00000110,0b01011011,0b01001111,0b01100110
        .byte 0b01101101,0b01111101,0b00000111,0b01111111,0b01100111                

    
    
    
    