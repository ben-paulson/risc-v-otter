#------------------------------------------
# Counts the number of interrupts received
# via debounced button presses and displays
# the number on the 7-segment display using
# a lookup table. After reaching 49 counts,
# the display resets to zero and continues.
#------------------------------------------

# BCD to decimal conversions for the 7-segment display
.data
seg:        .byte       0x03, 0x9F, 0x25, 0x0D, 0x99
            .byte       0x49, 0x41, 0x1F, 0x01, 0x19, 0xFF

an:         .byte       0x07, 0x0B, 0x0D, 0x0E

.text

main:
init:       li          x15, 0x1100C004         # segments port addr
            li          x16, 0x1100C008         # anodes port addr
            li          sp, 0x0000FFFF          # init stack pointer
            la          x29, an                 # LUT anodes base address
            la          x30, seg                # LUT segments base address
            li          x25, 0                  # 10s digit
            li          x26, 3                  # 1s digit
            li          x27, 0                  # Current anode (0 -> 4: L -> R)
            li          x28, 0xF                # All anodes off
            li          x20, 2                  # 10s digit anode
            li          x21, 3                  # 1s digit anode

loop:       sb          x28, 0(x16)             # Turn off all anodes
            beq         x27, x20, do_10s        # If currently on 10s digit
            beq         x27, x21, do_1s         # If currently on 1s digit
            li          x10, 0xA                # All segments off otherwise
            j           update                  # Update segment
do_10s:     mv          x10, x25                # Update segments to value in 10s digit
            j           update                  # Update segment
do_1s:      mv          x10, x26                # Update segments to value in 1s digit
update:     call        update_seg              # Update the current segment
            call        update_an               # Enable the current anode
            call        delay_ff                # Delay
            j           loop                    # Do it again

#------------------------------------------------------------
# Subroutine: update_an
#
# Updates the current anode using the LUT according to the
# value passed in x27.
#------------------------------------------------------------
update_an:
            addi        sp, sp, -4              # adjust sp
            sw          x20, 0(sp)              # Push x20
            add         x29, x29, x27           # Get correct LUT addr
            lbu         x20, 0(x29)             # Get value from LUT
            sb          x20, 0(x16)             # Store value to anodes addr
            sub         x29, x29, x27           # Restore LUT addr
            lw          x20, 0(sp)              # Pop x20
            addi        sp, sp, 4               # Restore sp
            ret                                 # Done

#------------------------------------------------------------
# Subroutine: update_seg
# 
# Updates the 7-segment output (address in x15)
# to the value passed in x10
#------------------------------------------------------------
update_seg:
            addi        sp, sp, -4              # Adjust sp
            sw          x20, 0(sp)              # Push x20
            add         x30, x30, x10           # Get correct LUT addr
            lbu         x20, 0(x30)             # Get value from LUT
            sb          x20, 0(x15)             # Store value to segments addr
            sub         x30, x30, x10           # Restore LUT addr
            lw          x20, 0(sp)              # Pop x20
            addi        sp, sp, 4               # Adjust sp
            ret                                 # Done

#------------------------------------------------------------
# Subroutine: delay_ff
#
# Delays for a count of FF. Unknown how long that is but it
# is plenty of time for display multiplexing
#
# tweaked registers: x31
#------------------------------------------------------------
delay_ff:
            li          x31,0xFF        # load count
d_loop:     beq         x31,x0,d_done   # leave if done
            addi        x31,x31,-1      # decrement count
            j           d_loop          # rinse, repeat
d_done:     ret                         # leave it all behind
#--------------------------------------------------------------
