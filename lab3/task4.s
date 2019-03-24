// T4: write a program that sorts a list of numbers into descending order
	// Using bubble-sort algorithm.
.global _start
_start:
// ------------- BUBBLE-SORT CODE ------------------------ 
LDR R1,List              // R1 has the length of the data - List[0]
outer_loop:
	LDR R2, =List   	 // R2 has address of the list[0]
	MOV R4,#1 			 // R4 has counter index	
	MOV R0,#0       	 // R0 has FLAG    
	inner_loop:
    	ADD R2, R2, #4   // R2 has address of the list[i]
	    ADD R6, R2, #4   // R6 has address of the list[i+1]
	    BL SWAP			 // Swapping if needed
	    ADD R4,R4,#1	 // Inc. counter
		CMP R1,R4		 // if(length>counter) - checking 
	    BGT inner_loop
	// Algorithm provides that in every iteration one element finds its place         
	SUB R1,R1,#1		 
	// so iteration length can be decs
	CMP R0,#0	 // if no change in one epoch means that list already sorted
	BEQ END		 // break
	B outer_loop
// ------------- BUBBLE-SORT CODE --end------------------- 
// ------------ SWAP FUNCTION CODE -----------------------
/*
params:
    R6 and R2 addresses of swapped values
return:
	R0 returned as 1 or 0 
    	1 means swapped
        0 means no-need to swap
*/
SWAP:            
	LDR R5,[R2]  // R5 has the value of list[i]      	
    LDR R7,[R6]  // R7 has the value of list[i+1]
    CMP R5,R7 	 // if (list[1+i]>list[1+i+1])
    BXGE lr  	 // return without swapping
    STR R7,[R2]	 // in-place(in mem) swapping
	STR R5,[R6]  // in-place(in mem) swapping
    MOV R0,#1    // swapped applied - flag raise
    BX  lr		 // return
// ------------ SWAP FUNCTION CODE -end-------------------
END: B END  
List: .word 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,16
// List[0] is the length of the 'data'
.end
