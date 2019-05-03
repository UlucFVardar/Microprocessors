.include    "address_map_arm.s" 

/* ********************************************************************************
 // T2: Show names and numbers with KEY interrupts.
 
 LONG Description:
 For the second task, students are assigned to generate an interrupted assembly code.
 Main part of the code responsible for from LED0 to Led10 serial(rotating) burning.
 When interrupted comes from KEY0 and KEY3 HEX display displays to students names and number.
 One click displays student’s Name, second click displays student’s Number.
 Key0 is responsible from studentA,
 Key3 is responsible from studentB.
 
 DODELAY LOOP :  implemented with a loop and also timer.
 
 - Uluc
 - Anıl
 ********************************************************************************/

.global     KEY_ISR 
KEY_ISR:
	LDR R0, =KEY_BASE // base address of pushbutton KEY port
	LDR R1, [R0,#0xC]  // read edge capture register
	MOV R2, #0xF
	STR R2, [R0,#0xC] // clear the flags
	LDR R0, =HEX3_HEX0_BASE // base address of LED display


CHECK_KEY0:         // Control for if KEy0 pressed
	MOV R3,#0x1      // 0x1 means key 0 pressed?
	ANDS R3, R3, R1 // check for KEY0
	BEQ CHECK_KEY3
	//---------------
    LDR     R2, =0x3E383E39 // Student Name always assign to HEXCode Register (ULUC)
    // eger kontrolde 2. basis ise bu sefer numaranin disply hexini atiyoum.

    CMP     R9,#1           // if flippedBit is == 1 means
    LDREQ   R2, =0x63f5b67  //  that hexDSPLY must display number of the student so HEXCODE Update
    EOR     R9,#1           // For flipping the counter bit
    MOV     R8,#0           // Key0 pressed measn KEy3 reset
	//---------------

	B END_KEY_ISR

CHECK_KEY3:
	MOV R3,#0x8
	ANDS R3, R3, R1 // check for KEY0
	BEQ END_KEY_ISR
	//---------------
    LDR     R2, =0x77373038 // Student Name always assign to HEXCode Register (ANIL)
    CMP 	R8, #1          // if flippedBit is == 1 means
    LDREQ   R2, =0x63f3f67  //  that hexDSPLY must display number of the student so HEXCODE Update
    EOR     R8,#1           // For flipping the counter bit
    MOV 	R9,#0           // Key0 pressed measn KEy3 reset
	//---------------
	B END_KEY_ISR

END_KEY_ISR:                    
        STR     R2, [R0]        // HEXCODE stored to HEXDSPLY ADDRESS
        BX      LR              // RETURN TO MAIN
diplay_base: .word 0xff200020

.end         
    
