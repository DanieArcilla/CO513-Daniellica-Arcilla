.global _start
_start:
        MOV     r0, #0xA5       // Input byte: 0xA5 (binary 1010 0101)

        AND     r2, r0, #0xF0   // Mask upper nibble → r2 = 0xA0
        LSR     r2, r2, #4      // Shift right → r2 = 0x0A

        AND     r3, r0, #0x0F   // Mask lower nibble → r3 = 0x05
        LSL     r3, r3, #4      // Shift left → r3 = 0x50

        ORR     r1, r2, r3      // Combine → r1 = 0x5A

        B       done            // End program

done:
        B       done            // Infinite loop to halt	
	
