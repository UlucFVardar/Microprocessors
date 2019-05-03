.include    "address_map_arm.s" 
.include    "interrupt_ID.s" 

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


/* IF you want to timer for delay
ldr r11, =0xfffec600   // set up for timer
ldr r12, =10000        // ~10 ms (value could be wrong now.)
str r12,[r11]          // save the timer count
add r11,r11,#8
ldr r12, =0000003      // Timer set up
str r12,[r11]
add r11,r11,#4         // R11 has the flag address of the timer
*/

IDLE:                   //My MAIN CODE
	MOV R9,#0            //Initial Fliped bit counter for STUA
    MOV R8,#0            //Initial Fliped bit counter for STUA
    MOV R1, #1           //Initial Timer plus number (interrupt will change this)
	LDR R0, =LED_BASE   // LED BASE ADDRESS

    // Shift loop
    shift:
        STR R1,[R0]		    // led assign
        LSL R1,R1,#1			// sifht number to left 1 digit
        CMP R1,#1024			// if sifted . number is 1024 2^10 (10. led)
        MOVEQ R1, #1         // if yesi number is 1 again
        Bllt DO_DELAY       // wait ~10 ms
        B  shift            // loop return


//doing with counter
DO_DELAY:
    LDR R7, =200000000 // delay counter
    SUB_LOOP: SUBS R7, R7, #1
    BNE SUB_LOOP

/* Delay with Timer
 DO_DELAY:
 ldr r12, [r11]
 and r12,r12,#1
 cmp r12, #1
 bne dump_l
 ldr r12, =0000001
 str r12,[r11]
 BX    LR
 */
// main program simply idles
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
            PUSH    {R0-R7, LR}             

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

            POP     {R0-R7, LR}             
            SUBS    PC, LR, #4
/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:                                
            B       SERVICE_FIQ
.end         
