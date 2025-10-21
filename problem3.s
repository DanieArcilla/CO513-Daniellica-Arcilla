.global _start
_start:
        MOV     r0, #7          // Input number: 7 (binary 0111)
        MOV     r1, #0          // Parity tracker: start with 0

loop:
        CMP     r0, #0          // Check if r0 is zero
        BEQ     done            // If yes, tapos na

        AND     r2, r0, #1      // Check least significant bit
        EOR     r1, r1, r2      // Flip parity if bit is 1

        LSR     r0, r0, #1      // Shift r0 right by 1
        B       loop            // Repeat loop

done:
        B       done            // r1 now contains parity			
	