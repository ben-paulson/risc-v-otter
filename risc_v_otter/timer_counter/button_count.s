#------------------------------------------
# Counts the number of interrupts received
# via debounced button presses and displays
# the number on the 7-segment display using
# a lookup table. After reaching 49 counts,
# the display resets to zero and continues.
#------------------------------------------

# BCD to decimal conversions for the 7-segment display
.data
seg:        .space 11   # Save space for 10-byte lookup table 
an:         .space 4    # 4-byte LUT for anodes

.text
#------------------------------------------------------------
# Subroutine: main
#
# Handles the background task of multiplexing the display.
#------------------------------------------------------------
main:
init:       call        load_lut                # Load values into LUT
            li          x15, 0x1100C004         # segments port addr
            li          x16, 0x1100C008         # anodes port addr
            li          x17, 0x1100D000         # TC CSR port addr
            li          x18, 0x1100D004         # TC count port addr
            li          x19, 0x11008004         # Buttons port addr
            li          sp, 0x0000A000          # init stack pointer
            la          x6, ISR                 # Load ISR addr 
            csrrw       x0, mtvec, x6           # Put ISR addr in mtvec
            li          x20, 0x00000159         # FF + avg clock cycles of ISR
            sw          x20, 0(x18)             # Store as timer count
            li          x20, 0x01               # TC CSR value
            sw          x20, 0(x17)             # No prescale, enable TC
            la          x29, an                 # LUT anodes base address
            la          x30, seg                # LUT segments base address
            li          x25, 0                  # 10s digit
            li          x26, 0                  # 1s digit
            li          x27, 3                  # Current anode (3 -> 0: L -> R)
            li          x28, 0xF                # All anodes off
            li          x20, 1                  # 10s digit anode
            mv          x7, x0                  # Most recent button value
            mv          x8, x0                  # Previous button value
            mv          x9, x0                  # Last debounced state
            mv          x11, x0                 # Current debounced state
            li          x13, 0x3E8              # Number of loop cycles the button 
                                                # value should be consistent before
                                                # it is "debounced"
            li          x5, 1                   # Keep a 1 in x5
            csrrw       x0, mie, x5             # Enable interrupts

loop:       mv          x9, x11                 # Move current db'd state to prev db'd state
            call        debounce                # Get current debounced output
            beq         x11, x9, loop           # Current same as previous db'd value
chk_prev:   bnez        x9, loop                # Prev db'd value was pressed
            call        btn_count               # Count button press
            j           loop                    # Check button again
            
#------------------------------------------------------------
# Subroutine: debounce
#
# Debounces the buttons (only the LSB) by ensuring the value
# of the button is consistent for a certain amount of time.
# Returns the debounced output in x11
#------------------------------------------------------------
debounce:
db_init:    mv          x12, x13                # Number of cycles before debounced
db_loop:    beqz        x12, upd_out            # Debounced if output consistent x12 times thru
            lw          x7, 0(x19)              # Current button value
            andi        x7, x7, 1               # Only need LSB of buttons
            beq         x7, x8, db_eq           # If current is same as previous
            addi        x12, x13, 1             # Reset w/ 1 greater than original loop cycles
db_eq:      addi        x12, x12, -1            # Decrement counter
            mv          x8, x7                  # Store button value as previous value
            j           db_loop                 # Next check

upd_out:    mv          x11, x8                 # Output previous value (same as current)
            ret                                 # Done

#------------------------------------------------------------
# ISR
#
# Handles display multiplexing using the timer-counter module
# which sends an interrupt after a predetermined amount of time.
#------------------------------------------------------------
ISR:
            sw          x28, 0(x16)             # Turn off all anodes
            addi        sp, sp, -4              # Adjust sp
            sw          ra, 0(sp)               # Push return address
            call        choose_seg              # Choose correct value to display
            call        update_seg              # Update the current segment
            call        update_an               # Enable the currrent anode
            csrrw       x0, mie, x5             # Enable interrupts
            lw          ra, 0(sp)               # Pop return address
            addi        sp, sp, 4               # Restore sp
            mret                                # Done with ISR

#------------------------------------------------------------
# Subroutine: btn_count
#
# Increments the total button couunt. Rolls over to zero after
# 49 interrupts.
#------------------------------------------------------------
btn_count:
            addi         x26, x26, 1            # Add 1 to 1s digit
            li           x20, 10                # Max 1s digit value
            bltu         x26, x20, cnt_done     # If 1s digit goes to 10
            mv           x26, x0                # Clear 1s digit
            addi         x25, x25, 1            # Increment 10s digit
            li           x20, 5                 # Max 10s digit value
            bltu         x25, x20, cnt_done     # If 10s digit goes to 5
            mv           x25, x0                # Clear 10s digit
cnt_done:   li           x20, 1                 # Restore x20
            ret                                 # Done


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
            sw          x20, 0(x16)             # Store value to anodes addr
            sub         x29, x29, x27           # Restore LUT addr
            addi        x27, x27, -1            # Go to next anode
            bgez        x27, next_an            # If not at last anode, continue to next
            li          x27, 3                  # Start at anode 3 again
next_an:    lw          x20, 0(sp)              # Pop x20
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
            sw          x20, 0(x15)             # Store value to segments addr
            sub         x30, x30, x10           # Restore LUT addr
            lw          x20, 0(sp)              # Pop x20
            addi        sp, sp, 4               # Adjust sp
            ret                                 # Done
            
#------------------------------------------------------------
# Subroutine: choose_seg
#
# Fills register x10 with the correct value to be displayed
# based on the current anode. Leftmost anodes are blank,
# while rightmost are the 10s digit and 1s digit.
#------------------------------------------------------------
choose_seg:
            addi        sp, sp, -4              # Adjust sp
            sw          x20, 0(sp)              # Push x20
            li          x20, 1                  # 1 is the 10s digit anode
            beq         x27, x20, do_10s        # If currently on 10s digit
            beq         x27, x0, do_1s          # If currently on 1s digit
            li          x10, 0xA                # All segments off otherwise
            j           c_done                  # Update segment
do_10s:     beqz        x25, c_done             # lead-zero blanking on 10s digit (if 0)
            mv          x10, x25                # Update segments to value in 10s digit
            j           c_done                  # Update segment
do_1s:      mv          x10, x26                # Update segments to value in 1s digit
c_done:     lw          x20, 0(sp)              # Pop x20
            addi        sp, sp, 4               # Restore sp
            ret                                 # Done

#--------------------------------------------------------------
# Subroutine: load_lut
# 
# Loads the LUT with values for seg and an
#--------------------------------------------------------------
load_lut:
            la          x10, seg
            li          x11, 0x03
            sb          x11, 0(x10)
            li          x11, 0x9F
            sb          x11,1(x10)
            li          x11,0x25
            sb          x11,2(x10)
            li          x11,0x0D
            sb          x11,3(x10)
            li          x11,0x99
            sb          x11,4(x10)
            li          x11,0x49
            sb          x11,5(x10)
            li          x11,0x41
            sb          x11,6(x10)
            li          x11,0x1F
            sb          x11,7(x10)
            li          x11,0x01
            sb          x11,8(x10)
            li          x11,0x09
            sb          x11,9(x10) 
            li          x11,0xFF
            sb	        x11,10(x10)         # Value 10 will be blank

            la          x10, an
            li          x11, 0x07
            sb          x11, 0(x10)
            li          x11, 0x0B
            sb          x11, 1(x10)
            li          x11, 0x0D
            sb          x11, 2(x10)
            li          x11, 0x0E
            sb          x11, 3(x10)
            ret
