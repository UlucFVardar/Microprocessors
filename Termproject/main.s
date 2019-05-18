.include    "address_map_arm.s"
.include    "interrupt_ID.s"

/* ********************************************************************************
 Microprocessors Term Project : Real-Time Stopwatch
 
 LONG Description:
        A stopwatch that counts the clock in real-time, allowing the user to set the clock between 0 seconds and 1 hour.
        Starts the time in real-time with the user pushing the start button.
        A stopwatch Which stops when it is set Time.
 - Uluc
 - Anıl
 ********************************************************************************/
.section    .vectors, "ax"
    B       _start                  // reset vector
    B       SERVICE_UND             // undefined instruction vector
    B       SERVICE_SVC             // software interrrupt vector
    B       SERVICE_ABT_INST        // aborted prefetch vector
    B       SERVICE_ABT_DATA        // aborted data vector
    .word       0 // unused vector
    B       SERVICE_IRQ             // IRQ interrupt vector
    B       SERVICE_FIQ             // FIQ interrupt vector

.text
.global     _start
_start:
    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV     R1, #0b11010010         // interrupts masked, MODE = IRQ
    MSR     CPSR_c, R1              // change to IRQ mode
    LDR     SP, =A9_ONCHIP_END - 3  // set IRQ stack to top of A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV     R1, #0b11010011         // interrupts masked, MODE = SVC
    MSR     CPSR, R1                // change to supervisor mode
    LDR     SP, =DDR_END - 3        // set SVC stack to top of DDR3 memory

    BL      CONFIG_GIC              // configure the ARM generic interrupt controller

    // write to the pushbutton KEY interrupt mask register
    LDR     R0, =KEY_BASE           // pushbutton KEY base address
    MOV     R1, #0xF               // set interrupt mask bits
    STR     R1, [R0, #0x8]          // interrupt mask register is (base + 8)

    // enable IRQ interrupts in the processor
    MOV     R0, #0b01010011         // IRQ unmasked, MODE = SVC
    MSR     CPSR_c, R0

// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    // Initial Register for project
    MOV R0, #0      // Initial State
    LDR R1, =6002   // TimerALRM Counter HIGH
    LDR R2, =6002   // TimerALRM Counter LOW
    MOV R3, #1      // Timer Plus Number

    LDR R12, =0     //HIGH timer counter
    MOV R6, #0      //HIGH timer HEX value
    LDR R7, =0      //LOW timer counter
    MOV R8, #0      //LOW timer HEX value

    // R4 Timer Flag
    Bl TIMER_SET

    // MAIN CODE ------------------------------
    IDLE:
        /* - State control -
            if machine state is 2, means timer must run and continue until the setted time*/
        CMP R0, #2
        BEQ TIMERCOUNT

        /* - State control -
            if machine state is 3, means timer must be setted by user button pressing. (Interrupts effects)*/
        CMP R0, #3
        BEQ SETALARM

        /* - State control -
            if machine state is 0, means timer starts new. And shows how to use the alarm by using 7-seg-display
            prints the responsibilities of key0-1-2-3 */
        CMP R0, #0
        BEQ HOW_to_USE


        B IDLE  // Brach to maın
    // MAIN CODE ------------------------------

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBROTINES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/* - State control -
 shows how to use the alarm by using 7-seg-display
 prints the responsibilities of key0-1-2-3.
 ---
 for
 alarm
 set
 press
 key1
 ----
 for
 start
 press
 key3
 */
HOW_to_USE:
    push {R14,LR}   // save last branch
    LDR R9, =HEX3_HEX0_BASE   // loading the dsply list head address
    LDR R6, =text_FOR
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_ALRM
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_SET
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_PRSS
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_KEY1
    STR R6,[R9]     // Set Displays
    bl delay
    bl delay
    bl delay
    LDR R6, =text_FOR
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_STRT
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_PRSS
    STR R6,[R9]     // Set Displays
    bl delay
    LDR R6, =text_KEY3
    STR R6,[R9]     // Set Displays
    pop {R14,LR}    // load last branch
    BX lr

/* Alarm setting state control subroutine */
SETALARM:
    MOV R3, #0             // Timer Plus Number is 0 because time must be stop when alarm setting state
    Bl TIMERCOUNTCHECKER  // Controls the Timer COunters goes upthe limits. (minutes 59.00 seconds 59.00  for every 6000second, minute+=1 and second=0)
    Bl Time2Hex_show      // Displays the Currnet value of Timer Counters
    B IDLE

/* Real-Time clock counting until 1 hour */
TIMERCOUNT:
    MOV R3, #1             // Timer Plus Number set to 1 for time flow
    Bl CheckTIMEforALARM  // Controls the time reach to ALARM TIME if yes, change the state to state0
    Bl Time2Hex_show      // Displays the Currnet value of Timer Counters
    ADD R7,R7,R3          // low level counter +1   (means minute counter, untill 6000)
    Bl TIMERCOUNTCHECKER  // Controls the Timer COunters goes upthe limits. (minutes 59.00 seconds 59.00  for every 6000second, minute+=1 and second=0)
    bl delay
    B IDLE

/* Real-Time clock counting Check for setted alarm time is reached? */
CheckTIMEforALARM:
    CMP R12, R1      // if hours == alarm_hours, flag =1
    CMPEQ R7, R2     // if flag == 1, check minutes == alarm_hours, if yes  flag=1 else0
    BXNE lr          // if flag is not equal no need to stop the timer and branch back.
    // if equal code continue
    MOV R0,#0        // machine state change to state0
    // ----  next 6 lines of code written for blink the 7-segment display -----
    BL delay
    LDR R9, =HEX3_HEX0_BASE   // loading the dsply list head address
    STR R0,[R9]     // Set Displays
    LDR R9, =HEX5_HEX4_BASE   // loading the dsply list head address
    STR R0,[R9]     // Set Displays
    BL delay
    Bl Time2Hex_show
    BX lr          // brach to maın back

/* Controls the Timer COunters goes upthe limits. (minutes 59.00 seconds 59.00  for every 6000second, minute+=1 and second=0)*/
TIMERCOUNTCHECKER:
    LDR R10, =6000
    CMP R7, R10      //control minutes reach to 6000
    MOVGE R7, #0      // if yes, minutes = 0
    ADDGE R12,R12,#1  // if yes, hours =+1

    LDR R10, =60
    CMP R12, R10     //control Hours reach to 60
    MOVGE R12, #0     // if yes, hours = 0
    BX lr            // brach to back


/* Delay with the Timer */
delay:
    //-------- Timer Wait
    ldr r10, [r4]  //load flag
    and r10,r10,#1 //look last elemnt of the flag
    cmp r10, #1    // if flag == 1 means time is up
    bne delay     // if time is not up try again
    //---------------------------------------------------
    ldr r10, =0000001 // To restart Timer flag must be replaced 1 by hand
    str r10,[r4]     // To restart Timer flag must be replaced 1 by hand
    bx lr            // brach to back


/* LOW and HIGH level Timer Counters (minute counter and Hour counter) digits shows in the 7 segment display*/
Time2Hex_show:
    PUSH {R14,LR}
    // ----------------------------------- LOW HEX -----------------------------------
    MOV R8,#0              // reset on display register value (7segmentCode register)
    //digit0 ---------
    mov r10,r7            // mov counter to r6 as a paramater of the mod_div_subroitne
    bl mod_div            // Subrouitine gives mod10 and division
    LDR R11, =BITCODES    // loading the first addres of list
    LDRB R10, [R11, R10 ] // finding to true code
    mov r8,r10            // function gives digit for display -> digit stored in a diffrent register
    //digit1 ---------
    mov r10,r9             // mov counter to r6 as a paramater of the mod_div_subroitne
    bl mod_div             // subrouitine gives mod and division
    LDR R11, =BITCODES     // loading the first addres of list
    LDRB R10, [R11, R10 ]  // finding to true code
    LSL R10,R10,#8          //shift
    ADD R8,R8,R10          // sum on display register value (7segmentCode register)
    //digit2 ---------
    mov r10,r9             // mov counter to r6 as a paramater of the mod_div_subroitne
    bl mod_div             // subrouitine gives mod and division
    LDR R11, =BITCODES     // loading the first addres of list
    LDRB R10, [R11, R10 ]  // finding to true code
    LSL R10,R10,#16         //shift
    ADD R8,R8,R10          // sum on display register value (7segmentCode register)
    //digit3 ---------
    LDR R11, =BITCODES      // loading the first addres of list
    LDRB R10, [R11, R9 ]    // finding to true code
    LSL R10,r10,#24          //shift
    ADD R8,R8,R10           // sum on display register calue (7segmentCode register)
    LDR R9, =HEX3_HEX0_BASE // loading the dsply list head address
    STR R8,[R9]             // Set Displays
    // -------------------------------------------

    // ----------------------------------- HIGH HEX -----------------------------------
    MOV R6,#0              // reset on display register value (7segmentCode register)
    //digit4 ---------
    mov r10,R12           // mov counter to r6 as a paramater of the mod_div_subroitne
    bl mod_div            // subrouitine gives mod and division
    LDR R11, =BITCODES    // loading the first addres of list
    LDRB R10, [R11, R10 ] // finding to true code
    ADD R6,R6,R10         // sum on display register value (7segmentCode register)
    //digit5 ---------
    LDR R11, =BITCODES    // loading the first addres of list
    LDRB R10, [R11, R9 ]  // finding to true code
    LSL R10,r10,#8         //shift
    ADD R6,R6,R10         // sum on display register calue (7segmentCode register)
    LDR R9, =HEX5_HEX4_BASE // loading the dsply list head address
    STR R6,[R9]             // Set Displays
    POP {R14,LR}   // Reload the lr value
    Bx lr          // Brach back

/* Calculate the mod10 and divide value by 10  (mod and div)
 r9 bolm
 r10 input and mod10*/
mod_div:
    mov r9,#0           // mod10 is stored here
    // next little part of the code finds the mod 10 of anay number
    mod_div_l:
    subs r10,r10,#10    // -10 from number
    add r9,r9,#1        // modNUmber  +1
    bgt mod_div_l      // if number > 0 go to mod_div_l

    // check an edit the true values. when subing the value code can find -.. values to fix this.
    cmp r10,#0           // number  == 0
    addne r10,r10,#10   // if  ==0 number  +10
    subne r9,r9,#1      // if not modNumber  -1
    bx lr               // go to main

/*Tımer of the processor will be initialize for count miliseconds */
TIMER_SET:
    // Next 3 line for Timer setUp
    LDR r4, =MPCORE_PRIV_TIMER  // Timer address load
    LDR r10, =2000000    // timer time value
    STR r10,[r4]        // set Timer time
    ADD r4,r4,#8         // Timer config set
    MOV r10, #3
    STR r10,[r4]
    ADD r4,r4,#4       // Timer finish Flag address
    BX lr
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBROTINES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BITCODES:
    //numbers to display types 0-9
    .byte 0b00111111 ,0b00000110,0b01011011,0b01001111,0b01100110
    .byte 0b01101101,0b01111101,0b00000111,0b01111111,0b01100111 , 0b01100111, 0b01100111

/*7-segment codes for texts*/
text_FOR:  .word 0x713F3300
text_SET:  .word 0x6D797800
text_KEY1: .word 0x75796e06
text_KEY2: .word 0x75796e5b
text_KEY3: .word 0x75796e4f
text_KEY4: .word 0x75796e66
text_STRT: .word 0x6d783378
text_INC:  .word 0x30373900
text_DESC: .word 0x5e796d39
text_PRSS: .word 0x73336d6d
text_ALRM: .word 0x77383315
/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
B       SERVICE_UND

/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
B       SERVICE_SVC

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
B       SERVICE_ABT_DATA

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
B       SERVICE_ABT_INST

/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
PUSH    {R3-R6, LR}

/* Read the ICCIAR from the CPU interface */
LDR     R4, =MPCORE_GIC_CPUIF
LDR     R5, [R4, #ICCIAR]       // read from ICCIAR

FPGA_IRQ1_HANDLER:
CMP     R5, #KEYS_IRQ
UNEXPECTED: BNE     UNEXPECTED              // if not recognized, stop here

BL      KEY_ISR
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
STR     R5, [R4, #ICCEOIR]      // write to ICCEOIR

POP     {R3-R6, LR}
SUBS    PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
B       SERVICE_FIQ

".end
