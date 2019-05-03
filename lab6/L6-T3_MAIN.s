.include    "address_map_arm.s"
.include    "interrupt_ID.s"
/* ********************************************************************************
 T3:  Real time clock using interrupts.
 
 LONG Description:
    Using Timer and Interruped service a real time clock must be implemented.
    Key3 is the start-stop button for the realtime clock.
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
MOV     R1, #0b11010010           // interrupts masked, MODE = IRQ
MSR     CPSR_c, R1              // change to IRQ mode
LDR     SP, =A9_ONCHIP_END - 3  // set IRQ stack to top of A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
MOV     R1, #0b11010011           // interrupts masked, MODE = SVC
MSR     CPSR, R1                // change to supervisor mode
LDR     SP, =DDR_END - 3        // set SVC stack to top of DDR3 memory

BL      CONFIG_GIC              // for set config the ARM generic interrupt controller

// write to the pushbutton KEY interrupt mask register
LDR     R0, =KEY_BASE           // KEY base address
MOV     R1, #0xF                  // set interrupt mask bits
STR     R1, [R0, #0x8]            // interrupt mask register is (base + 8)

// enable IRQ interrupts in the processor
MOV     R0, #0b01010011           // IRQ unmasked, MODE = SVC
MSR     CPSR_c, R0
# ------------------------------------ Code starts after here



IDLE:
//--------------------------
    Bl initial       // Register that will be used will be assign as 0
    ldr R8 ,=0       //counter starts from 0

    //next 3 line for Timer setUp
    ldr r9, =0xfffec600  // Timer address load
    ldr r10, =2000000    // timer time value
    str r10,[r9]        // set Timer time

    add r9,r9,#8        // Timer config set
    ldr r10, =0000003
    str r10,[r9]

    add r9,r9,#4       // Timer finish Flag address

    loop:
        //digit0
        mov r6,r8   // mov counter to r6 as a paramater of the mod_div_subroitne
        bl mod_div  // Subrouitine gives mod10 and division
        mov r3,r6   // function gives digit for display -> digit stored in a diffrent register

        //digit1
        mov r6,r5   // mov counter to r6 as a paramater of the mod_div_subroitne
        bl mod_div  // subrouitine gives mod and division
        mov r2,r6   // function gives digit for display -> digit stored in a diffrent register


        //digit2
        mov r6,r5   // mov counter to r6 as a paramater of the mod_div_subroitne
        bl mod_div  // subrouitine gives mod and division
        mov r1,r6   // function gives digit for display -> digit stored in a diffrent register

        //digit3
        mov r0,r5   // rest is the digit 3

        Bl number2code   // map to numbers to 7-segment code
        Bl disp_number   // number display

        //-------- Timer Wait
        dump_l:
            ldr r12, [r9]  //load flag
            and r12,r12,#1 //look last elemnt of the flag
            cmp r12, #1    // if flag == 1 means time is up
            bne dump_l     // if time is not up try again
        //---------------------------------------------------

        // To restart Timer flag must be replaced 1 by hand
        ldr r10, =0000001
        str r10,[r9]

        //-----
        /*Timer update line given in the next line. This line gives the ablity of the timer,
         Stop and Start. R7 is acculy 1 BUT when the ınterrupt is comes,
         The value of the R7 is replaces by 0 so the addision of the counter is not change so the mactine allways shows the same time. When ever the Key pressed again the value R7 is replaced by 1 and the timer countinues.*/
        add r8,r8, R7
        //-----

        // countrol for the timer limit. 6000 is acculy 1 minute.
        // if the counter comes here counter returns 0 again
        ldr r10 , =6000
        cmp r8,r10
        moveq r8 , #0
        b loop


// ------------------ Subroutines ---------------------
// r5 bolm
// r6 input and mod10
mod_div:
    mov r5,#0           // mod10 is stored here

    // next little part of the code finds the mod 10 of anay number
    mod_div_l:
        subs r6,r6,#10      // -10 from number
        add r5,r5,#1        // modNUmber  +1
        bgt mod_div_l      // if number > 0 go to mod_div_l

    // check an edit the true values. when subing the value code can find -.. values to fix this.
    cmp r6,#0           // number  == 0
    addne r6,r6,#10     // if  ==0 number  +10
    subne r5,r5,#1      // if not modNumber  -1
    bx lr       // go to main

initial:
    // initial values as 0
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0
    MOV R5, #0
    MOV R6, #0
    MOV R7,#1 // Timer incrementer Register
    Bx lr

number2code:
    // next 5 line finds the input group 7-segment code in a list
    LDR R10, =BITCODES // loading the first addres of list
    LDRB R0, [R10, R0] // finding to true code
    LDRB R1, [R10, R1] // finding to true code
    LDRB R2, [R10, R2] // finding to true code
    LDRB R3, [R10, R3] // finding to true code
    Bx lr

// ---------------------- DSPLY CODE ------------------------------
disp_number:
    MOV R4, #0        //  = 0
    LSL R4,R0,#24     // shift 7-segmnet code to rigth place
    LSL R1,R1,#16     // shift 7-segmnet code to rigth place
    LSL R2,R2,#8      // shift 7-segmnet code to rigth place
    ADD R4,r4,r1     // Sum Shifted 7-segment codes to one register
    ADD R4,R4,R2     // Sum Shifted 7-segment codes to one register
    ADD R4,R4,R3     // Sum Shifted 7-segment codes to one register
    LDR R11, =HEX3_HEX0_BASE   // loading the dsply list head address
    STR R4,[R11]     // Set Displays
    Bx lr
// --------- Static Values Parts ----------

BITCODES:
    //numbers to display types 0-9
    .byte 0b00111111 ,0b00000110,0b01011011,0b01001111,0b01100110
    .byte 0b01101101,0b01111101,0b00000111,0b01111111,0b01100111    , 0b01100111, 0b01100111

// ------------------------------------------- MAIN CODE FINISH ----------------


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

PUSH {R0-R5, LR}


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


POP  {R0-R5, LR}


SUBS    PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
B       SERVICE_FIQ
.end
