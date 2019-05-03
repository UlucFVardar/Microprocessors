.include    "address_map_arm.s" 

/* ********************************************************************************
 T3:  Real time clock using interrupts.
 
 LONG Description:
 Using Timer and Interruped service a real time clock must be implemented.
 Key3 is the start-stop button for the realtime clock.
 - Uluc
 - Anıl
 ********************************************************************************/

.global     KEY_ISR
KEY_ISR:

LDR R0, =KEY_BASE // base address of pushbutton KEY port
LDR R1, [R0,#0xC] // read edge capture register
MOV R2, #0xF
STR R2, [R0,#0xC] // clear the flags
LDR R0, =HEX3_HEX0_BASE // base address of LED display

CHECK_KEY3:
    MOV R3,#0x8
    ANDS R3, R3, R1 // check for KEY0
    BEQ END_KEY_ISR // if pressde key is not key3 go toEND_KEY_ISR
    //---------------
    /*Timer update line given in the next line. This line gives the ablity of the timer,
     Stop and Start. R7 is acculy 1 BUT when the ınterrupt is comes,
     The value of the R7 is replaces by 0 so the addision of the counter is not change so the mactine allways shows the same time. When ever the Key pressed again the value R7 is replaced by 1 and the timer countinues.*/
    // The adding number of the timer is flipped with using XOR operation.
    EOR R7,R7,#1
    //---------------
    B END_KEY_ISR

//return main
END_KEY_ISR:
    BX LR
.end
