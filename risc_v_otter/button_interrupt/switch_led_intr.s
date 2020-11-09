#----------------------------------------------
# Outputs the most recent value on the switches
# to the LEDs upon receiving an interrupt. If
# the same output is found on two consecutive
# interrupts, the program stops until a button
# is pressed, then returns to normal processing
#----------------------------------------------
.text
init:       li          x10, 0x1100C000     # LEDS address
            li          x11, 0x11008000     # SWITCHES address
            li          x12, 0x11008004     # BUTTONS address
            la          x6, ISR             # Load ISR address
            mv          x15, x0             # Most recent switches value
            mv          x16, x0             # Previous switches value
            mv          x17, x0             # Number of interrupts
            csrrw       x0, mtvec, x6       # Load ISR address to mtvec
            li          x8, 0               # Interrupt flag
            li          x9, 1               # Interrupt enable
            csrrw       x0, mie, x9         # Enable interrupts
            
loop:       beqz        x8, loop            # Interrupt flag not set

intr:       lw          x15, 0(x11)         # Load current switches
            sw          x15, 0(x10)         # Most recent switches -> LEDs
            beqz        x17, intr_1         # If this is the first interrupt (avoid
                                            # stopping if first switches value is zero)
            beq         x15, x16, pause     # If switch value is same as previous
            j           intr_done           # Finish interrupt processing as usual
intr_1:     addi        x17, x17, 1         # First interrupt complete            
intr_done:  mv          x16, x15            # Most recent is now previous
            mv          x8, x0              # Clear interrupt flag
            csrrw       x0, mie, x9         # Enable interrupts again
            j           loop                # Wait for another interrupt
            

pause:      lw          x18, 0(x12)         # Load buttons value
            andi        x18, x18, 1         # Only care about LSB
            beq         x18, x9, loop       # If button[0] was pressed (x9 will be 1)
            j           pause               # Otherwise keep checking

ISR:        li          x8, 1               # Set interrupt flag
            mret                            # Return from ISR
