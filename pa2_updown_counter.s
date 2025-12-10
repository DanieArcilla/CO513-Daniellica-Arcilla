    .global _start

/* ================================
 *  I/O base addresses
 * ================================ */

.equ HEX_BASE,  0xFF200020   @ HEX3-0 base (we use HEX1:0)
.equ KEY_BASE,  0xFF200050   @ pushbuttons KEY0..KEY3
.equ SW_BASE,   0xFF200040   @ switches (we only use SW0)

/* ================================
 *  Program entry
 * ================================ */

_start:
    @ initialize: counter = 0, running = 0
    LDR     r0, =COUNTER
    MOV     r1, #0
    STR     r1, [r0]

    LDR     r0, =RUN_FLAG
    STR     r1, [r0]

    BL      show_counter      @ display "00" at start

wait_for_start:
    @ debounce KEY0 to start counting
    MOV     r0, #1            @ key mask for KEY0 (bit 0)
    BL      debounce_key
    CMP     r0, #1
    BNE     wait_for_start    @ stay idle if no valid press

    @ set running flag
    LDR     r1, =RUN_FLAG
    MOV     r2, #1
    STR     r2, [r1]

main_loop:
    @ first, check if KEY0 pressed again -> pause
    MOV     r0, #1
    BL      debounce_key
    CMP     r0, #1
    BNE     check_reset_and_dir

    @ pressed: go back to idle state
    LDR     r1, =RUN_FLAG
    MOV     r2, #0
    STR     r2, [r1]
    B       wait_for_start

check_reset_and_dir:
    @ check KEY1 for reset (with debounce)
    MOV     r0, #2            @ mask for KEY1 (bit 1)
    BL      debounce_key
    CMP     r0, #1
    BNE     after_reset

    @ if KEY1 pressed: reset counter to 0 and update display
    LDR     r1, =COUNTER
    MOV     r2, #0
    STR     r2, [r1]
    BL      show_counter

after_reset:
    @ delay ~1 second between steps
    BL      delay_1s

    @ -------------------------------
    @ Direction Control (per cycle)
    @   SW0 = 0 -> count up
    @   SW0 = 1 -> count down
    @ -------------------------------
    LDR     r3, =SW_BASE
    LDR     r4, [r3]
    AND     r4, r4, #1        @ r4 = 0 (up) or 1 (down), read once each cycle

    @ get current counter value
    LDR     r5, =COUNTER
    LDR     r6, [r5]          @ r6 = 0..59

    CMP     r4, #0
    BEQ     do_count_up
    B       do_count_down

/* ================================
 *  Up-counting: 00..59 then wrap
 * ================================ */
do_count_up:
    ADD     r6, r6, #1
    CMP     r6, #60
    BLT     store_new_count
    MOV     r6, #0            @ wrap 59 -> 0
    B       store_new_count

/* ================================
 *  Down-counting: 59..00 then wrap
 * ================================ */
do_count_down:
    SUB     r6, r6, #1
    CMP     r6, #0
    BGE     store_new_count
    MOV     r6, #59           @ wrap 0 -> 59

store_new_count:
    STR     r6, [r5]          @ store updated counter
    BL      show_counter      @ update HEX display
    B       main_loop

/* ===========================================
 *  Subroutine: debounce_key
 *  r0 = key mask (1->KEY0, 2->KEY1)
 *  return r0 = 1 if stable press detected,
 *           = 0 otherwise
 * =========================================== */
debounce_key:
    PUSH    {r1-r3, lr}

    @ read current key state
    LDR     r1, =KEY_BASE
    LDR     r2, [r1]
    TST     r2, r0            @ active-LOW: 0 = pressed
    BNE     no_valid_press    @ bit is 1 -> not pressed

    @ small delay to filter bounce
    BL      delay_5ms

    @ read again to confirm
    LDR     r2, [r1]
    TST     r2, r0
    BNE     no_valid_press    @ released again -> glitch/bounce

    @ wait until key is released before returning
wait_release:
    LDR     r2, [r1]
    TST     r2, r0
    BEQ     wait_release      @ still 0 -> still held

    MOV     r0, #1
    POP     {r1-r3, lr}
    BX      lr

no_valid_press:
    MOV     r0, #0
    POP     {r1-r3, lr}
    BX      lr

/* ===========================================
 *  Subroutine: delay_5ms
 *  crude busy-wait loop (~5ms)
 * =========================================== */
delay_5ms:
    PUSH    {r0, lr}
    LDR     r0, =DEBOUNCE_CNT
d5_loop:
    SUBS    r0, r0, #1
    BNE     d5_loop
    POP     {r0, lr}
    BX      lr

/* ===========================================
 *  Subroutine: delay_1s
 *  crude busy-wait loop (~1 second)
 * =========================================== */
delay_1s:
    PUSH    {r0, lr}
    LDR     r0, =10000000

delay_1s_loop:
    SUBS    r0, r0, #2
    BNE     delay_1s_loop

    POP     {r0, lr}
    BX      lr


/* ===========================================
 *  Subroutine: show_counter
 *  Reads COUNTER (0..59), splits into tens and
 *  ones, converts via 7-seg table, and sends
 *  the combined pattern to HEX1:HEX0.
 * =========================================== */
show_counter:
    PUSH    {r0-r7, lr}

    @ load counter
    LDR     r0, =COUNTER
    LDR     r0, [r0]          @ r0 = 0..59

    @ divide by 10 using repeated subtraction
    BL      div10             @ r1 = tens, r0 = ones
    MOV     r3, r1            @ r3 = tens
    MOV     r4, r0            @ r4 = ones

    @ base of 7-seg pattern table
    LDR     r5, =SEG_PATTERNS

    @ lookup ones digit pattern
    LDR     r6, [r5, r4, LSL #2]  @ active-HIGH pattern

    @ lookup tens digit pattern
    LDR     r7, [r5, r3, LSL #2]

    @ pack into 16 bits: [HEX1][HEX0] = [tens][ones]
    LSL     r7, r7, #8
    ORR     r6, r6, r7

    @ write to HEX3-0 (we only care about low 16 bits)
    LDR     r2, =HEX_BASE
    STR     r6, [r2]

    POP     {r0-r7, lr}
    BX      lr

/* ===========================================
 *  Subroutine: div10
 *  Input : r0 = 0..59
 *  Output: r1 = quotient (tens)
 *          r0 = remainder (ones)
 *  Simple repeated subtraction (no UDIV).
 * =========================================== */
div10:
    PUSH    {r2, lr}
    MOV     r1, #0         @ quotient
div10_loop:
    CMP     r0, #10
    BLT     div10_done
    SUB     r0, r0, #10
    ADD     r1, r1, #1
    B       div10_loop
div10_done:
    POP     {r2, lr}
    BX      lr

/* ================================
 *  Data section
 * ================================ */
    .data

RUN_FLAG:      .word 0       @ 0 = paused, 1 = running
COUNTER:       .word 0       @ 0..59

@ 7-seg patterns for digits 0-9 (active-HIGH)
SEG_PATTERNS:
    .word 0x3F    @ 0
    .word 0x06    @ 1
    .word 0x5B    @ 2
    .word 0x4F    @ 3
    .word 0x66    @ 4
    .word 0x6D    @ 5
    .word 0x7D    @ 6
    .word 0x07    @ 7
    .word 0x7F    @ 8
    .word 0x6F    @ 9

@ tweak these constants in the simulator if timing feels off
DEBOUNCE_CNT:  .word 40000      @ ~5ms (depends on CPUlator speed)
ONESEC_CNT:    .word 10000000   @ ~1s (also approximate)
