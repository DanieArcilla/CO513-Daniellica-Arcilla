.global _start
_start:
        .data
my_array:   .word 4, 5, 9, 1, 0, -2, 3     // Sample array
array_size: .word 7                        // Number of elements

        .text
        .global _start

_start:
        LDR     r0, =my_array              // r0 = base address of array
        LDR     r1, =array_size
        LDR     r1, [r1]                   // r1 = number of elements

        LDR     r2, [r0], #4               // r2 = first element (initial max), post-increment r0
        SUB     r1, r1, #1                 // Decrement count (first element already loaded)

loop:
        CMP     r1, #0                     // Check if count == 0
        BEQ     done                       // If yes, we're done

        LDR     r3, [r0], #4               // Load next element into r3
        CMP     r3, r2                     // Compare r3 with current max
        MOVGT   r2, r3                     // If r3 > r2, update max

        SUB     r1, r1, #1                 // Decrement count
        B       loop                       // Repeat

done:
        // r2 now contains the maximum value
        B       done                       // Infinite loop to halt	
	
