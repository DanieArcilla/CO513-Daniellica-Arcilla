.global _start
_start:
        MOV     r0, #7          // Step 1: Load n = 7 into r0
        MOV     r1, #1          // Step 2: Initialize result = 1 in r1

        CMP     r0, #0          // Step 3: Check if n == 0
        BEQ     done            // Step 4: If yes, jump to done

loop:
        MUL     r1, r1, r0      // Step 5: Multiply result by current n
        SUB     r0, r0, #1      // Step 6: Decrement n
        CMP     r0, #0          // Step 7: Check if n == 0
        BNE     loop            // Step 8: If not, repeat loop

done:
        B       done            // Step 9: Infinite loop to end program	
	
