// T3: write a subroutine called FINDSUM that uses a loop
// (i=1->N)∑i
.global _start
_start:
//-------------- MAIN CODE ------------------------
    // Loading to function parameter
    LDR R0,N   // the number that wanted to sum from 1
    BL FINDSUM // Going/Calling subroutine/function
    END:
    B END       // Wating in this line
//-------------- MAIN CODE -end--------------------


//-------------- FUNCTION CODE --------------------
FINDSUM:
    //  (i=1->N)∑i the formula wantted to implement
    MOV R1,#0 // loading 0 to R1 for using as SUM

    // -------- loop for summations(∑)
    loop:
        ADD R1,R1,R0  // R1 + R0 -->> R1
        SUBS R0,R0,#1 // R0 - 1  -->> R0
        BGT loop      // if (R0>0)then go to 'loop'
    // -------- end of loop

    MOV R0,R1  //storing the return values in R0
    Bx LR      // Brach back
//-------------- FUNCTION CODE -end----------------

N: .word 4 // the number that wanted to sum from 1
.end
