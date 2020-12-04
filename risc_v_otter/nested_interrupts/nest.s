#--------------------------------------------
# Allow for nested interrupt service routines
# by utilizing the stack to store previous
# mepc register values.
# It assumes that an interrupt will only be
# received during the body of the ISR, and
# not during the push/pop phase, so that the
# current ISR can be properly completed.
#--------------------------------------------
.text
init:           la          x6, ISR             # Load ISR address
                csrrw       x0, mtvec, x6       # Put in mtvec
                li          x5, 1               # Keep a 1 in x5
                li          sp, 0x0000A000      # Init stack pointer
                li          x20, 50             # For main
                csrrw       x0, mie, x5         # Enable interrupts

main:           beqz        x20, reload         # Worthless bgnd task
                addi        x20, x20, -1        #
                j           main                #
reload:         li          x20, 50             #
                j           main                #

ISR:
isr_push:       addi        sp, sp, -4          # Adjust sp
                csrrw       x15, mepc, x15      # Get mepc value
                sw          x15, 0(sp)          # Push mepc
                csrrw       x0, mie, x5         # Enable interrupts
do_stuff:       nop                             #
                nop                             # Body of ISR, assume it is useful
                nop                             # Assume interrupts happen in body only
                nop                             #
isr_pop:        lw          x15, 0(sp)          # Pop mepc
                csrrw       x0, mepc, x15       # Restore mepc
                addi        sp, sp, 4           # Adjust sp
                mret                            # Done w/ ISR
