#-----------------------------------------
# Outputs the largest of the 3 most recent
# values that were on the switches when
# an interrupt was received to the LEDs.
# Switch values interpreted as unsigned
# 16-bit numbers.
#-----------------------------------------
.text
init:           li          x10, 0x1100C000         # LEDs port addr
                li          x11, 0x11008000         # Switches port addr
                la          x6, ISR                 # Load ISR address
                csrrw       x0, mtvec, x6           # Put ISR addr in mtvec register
                mv          x15, x0                 # Most recent switches
                mv          x16, x0                 # 2nd most recent switches
                mv          x17, x0                 # 3rd most recent switches
                li          x8, 0                   # Interrupt flag
                li          x9, 1                   # Load a 1
                csrrw       x0, mie, x9             # Enable interrupts
            
loop:           beqz        x8, loop                # Interrupt flag not set
            
                lw          x15, 0(x11)             # Get current switches
                bgt         x15, x16, chk_1         # If x15 > x16
                mv          x18, x16                # x16 current largest
                j           chk_2                   # Check current largest w/ x17
chk_1:          mv          x18, x15                # x15 current largest
chk_2:          bgt         x18, x17, done          # x18 > x17
                mv          x18, x17                # x18 holds largest
done:           sw          x18, 0(x10)             # Store largest output to LEDs
                mv          x17, x16                # Move 2nd to 3rd
                mv          x16, x15                # Move 1st to 2nd
                mv          x8, x0                  # Clear interrupt flag
                csrrw       x0, mie, x9             # Enable interrupts
                j           loop                    # Wait for another interrupt

ISR:            li          x8, 1                   # Set interrupt flag
                mret                                # Return from ISR
