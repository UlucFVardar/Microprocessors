.global _start
_start:

MOV R12, #0 // For using button counter
loop:
    // ******** for student 1 *********
    // show 1 --------
    Bl initial       // R0-R3 initial as '0'
    MOV R3, #1        // set number as '0001'
    Bl number2code   // map to numbers to 7-segment code
    Bl disp_number   // number display
    Bl check_buttons // button press check
    // show 'ULUC'-----
    Bl initial       // R0-R3 initial as '0'
    LDR R4, #Students // First student name code load
    Bl disply        // display code of text
    Bl check_buttons // button press check
    // show 1029 ------
    Bl initial       // R0-R3 initial as '0'
    MOV R0, #1        // Loading registers number of first student
    MOV R1, #0     
    MOV R2, #2
    MOV R3, #9  
    Bl number2code   // map to numbers to 7-segment code
    Bl disp_number   // number display
    Bl check_buttons // button press check

    // ******** for student 2 *********    
    // show 2----------
    Bl initial       //R0-R3 initial as '0'
    MOV R3, #2        // set number as '0002'
    Bl number2code   // map to numbers to 7-segment code
    Bl disp_number   // number display
    Bl check_buttons // button press check
    // show 'ANIL'-----
    Bl initial       //R0-R3 initial as '0'
    LDR R4, =Students// Second student name code load
    LDR R4, [R4,#4]
    Bl disply        // display code of text
    Bl check_buttons // button press check
    // show 1009-------
    Bl initial       // R0-R3 initial as '0'
    MOV R0, #1        // Loading registers number of first student
    MOV R1, #0
    MOV R2, #0
    MOV R3, #9  
    Bl number2code   // map to numbers to 7-segment code
    Bl disp_number   // number display
    Bl check_buttons // button press check
    b loop
     
wait:
    LDR R11, #DSPLY   // loading the dsply list head address
    MOV R4,#0      
    STR R4,[R11]     // CLOSE ALL 7-SEGMENTS 
    Bl check_buttons // button press check  // if pressed again subroutine handles
    b wait           // CONTINUE TO wait


// ------------------ Subroutines ---------------------
check_buttons:      // for counting the press to any key
    LDR R5, #BTN     // edge res. address
    LDR R5, [R5]    // load edge address
    CMP R5, #0       // if edgeR>0 -means pressed
    BXEQ lr         // if not pressed - == 0 continue to work
    ADD R12,R12,#1  // if pressed part
    AND R9,R12,#1   // mod2 of counter
    CMP R9, #0
    BEQ loop        // mod2 of counter is 0 to loop
    B wait          // else wait

initial:
    // initial values as 0
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0    
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
disply:
    LDR R11, #DSPLY    // loading the dsply list head address
    STR R4,[R11] 
    LDR R7, =200000000 // delay counter
    SUB_LOOP:          // wait until counter reach 0
    SUBS R7, R7, #1 
    BNE SUB_LOOP         
    Bx lr  
disp_number:    
    MOV R4, #0        //  = 0
    LSL R0,R0,#24     // shift 7-segmnet code to rigth place
    LSL R1,R1,#16     // shift 7-segmnet code to rigth place
    LSL R2,R2,#8      // shift 7-segmnet code to rigth place
    ADD R4,r0,R1     // Sum Shifted 7-segment codes to one register
    ADD R4,R4,R2     // Sum Shifted 7-segment codes to one register
    ADD R4,R4,R3     // Sum Shifted 7-segment codes to one register
    LDR R11, #DSPLY   // loading the dsply list head address
    STR R4,[R11]     // Set Displays
    
    LDR R7, =200000000// delay counter
    SUB_LOOP1:       // wait until counter reach 0
    SUBS R7, R7, #1
    BNE SUB_LOOP1
    Bx lr  
// --------- Static Values Parts ---------- 
Students: 
    .word 0x3E383E39 // code of 'ULUC'
    .word 0x77373038 // code of 'ANIL'
DSPLY:   
    .word 0xFF200020 // Second dply mem. address
        
BTN:
    .word 0xFF200050 // Buttons edge capture address
BITCODES:
    //numbers to display types 0-9
    .byte 0b00111111 ,0b00000110,0b01011011,0b01001111,0b01100110
    .byte 0b01101101,0b01111101,0b00000111,0b01111111,0b01100111                


    
    
    
