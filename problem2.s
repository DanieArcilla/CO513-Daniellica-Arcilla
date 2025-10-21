.global _start
_start:
        MOV     r0, #36         // a = 36
        MOV     r1, #24         // b = 24

loop:
        CMP     r1, #0          // Step 1: Check if b == 0
        BEQ     done            // Step 2: If yes, tapos na

        MOV     r2, r1          // Step 3: temp = b

mod_loop:
        CMP     r0, r1          // Step 4: Compare a and b
        BLT     mod_done        // Step 5: If a < b, done
        SUB     r0, r0, r1      // Step 6: a = a - b
        B       mod_loop        // Step 7: Repeat until a < b

mod_done:
        MOV     r1, r0          // Step 8: b = a mod b
        MOV     r0, r2          // Step 9: a = temp
        B       loop            // Step 10: Repeat main loop

done:
        B       done            // Step 11: Halt program	
	