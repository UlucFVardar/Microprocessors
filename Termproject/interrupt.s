.include    "address_map_arm.s"
/* ********************************************************************************
 Microprocessors Term Project : Real-Time Stopwatch
 
 LONG Description:
 A stopwatch that counts the clock in real-time, allowing the user to set the clock between 0 seconds and 1 hour.
 Starts the time in real-time with the user pushing the start button.
 A stopwatch Which stops when it is set Time.
 - Uluc
 - Anıl
 ********************************************************************************/

.global     KEY_ISR
KEY_ISR:
    LDR R0, =KEY_BASE // base address of pushbutton KEY port
    PUSH {R1-R2, LR}
    LDR R1, [R0,#0xC] // read edge capture register
    MOV R2, #0xF
    STR R2, [R0,#0xC] // clear the flags
    MOV R0,#0

/*Change the State to ALARM SET STATE*/
CHECK_KEY0:
    MOV R3,#0x1
    ANDS R3, R3, R1 // check for KEY0
    BEQ CHECK_KEY1 // if pressde key is not key0 go to next
    //---------------
    MOV R12,#0      //HIGH timer counter
    MOV R7, #0      //LOW timer counter
    MOV R0, #3      //ALARM STATE
    //---------------
    B END_KEY_ISR  // Brach to end


/*Change the State to ALARM SET STATE
    INCREASE the alarm time value by 30 seconds for every press to key1*/
CHECK_KEY1:
    MOV R3,#0x2
    ANDS R3, R3, R1 // check for KEY1
    BEQ CHECK_KEY3 // if pressde key is not key1 go to next
    //CMP R0, #3
    //BNE CHECK_KEY3
    //---------------
    MOV R0, #3      //ALARM STATE
    LDR R3, =3000   // load value 30 seconds
    ADD R7,R7,R3   // low level counter 0
    //---------------
    B END_KEY_ISR  // Brach to end

/*Change the State to STOPWATCH state
    and setted alrm values*/
CHECK_KEY3:
    MOV R3,#0x8
    ANDS R3, R3, R1 // check for KEY3
    BEQ END_KEY_ISR // if pressde key is not key3 go to END_KEY_ISR
    //---------------
    POP {R1-R2, LR}   //to change alarm time reload from stack
    MOV R0, #2         // TIMER STATE
    MOV R1, R12       // Timer Counter HIGH
    MOV R2, R7        // Timer Counter LOW
    MOV R12, #0        // Timer counteter reset
    MOV R7, #0         // Timer counteter reset
    PUSH {R1-R2, LR}  // load values stack back
    //---------------
    B END_KEY_ISR    // Brach to end

//return main
END_KEY_ISR:
    POP {R1-R2, LR} //Load the values
    BX LR           // brach maın back
.end
