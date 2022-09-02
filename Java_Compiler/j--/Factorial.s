# ./Factorial.s
# Source file: Factorial.java
# Compiled: Mon Dec 20 03:02:15 EST 2021

.text

Factorial.computeRec:
    subu    $sp,$sp,8 	 # Stack frame is 8 bytes long
    sw      $ra,4($sp) 	 # Save return address
    sw      $fp,0($sp) 	 # Save frame pointer
    addiu   $fp,$sp,4 	 # Save frame pointer

Factorial.computeRec.0:

Factorial.computeRec.1:
    li null,0
    bgt null,null,Factorial.computeRec.4
    j Factorial.computeRec.2

Factorial.computeRec.2:
    li null,1
    move null,null
    j Factorial.computeRec.restore

Factorial.computeRec.4:
    li null,1
    sub null,null,null
    move null,null
    move null,null
    jal Factorial.computeRec
    move null,null
    move null,null
    mul null,null,null
    move null,null
    j Factorial.computeRec.restore

Factorial.computeRec.restore:
    lw      $ra,4($sp) 	 # Restore return address
    lw      $fp,0($sp) 	 # Restore frame pointer
    addiu   $sp,$sp,8 	 # Pop stack
    jr      $ra 	 # Return to caller



.text

main:
    subu    $sp,$sp,8 	 # Stack frame is 8 bytes long
    sw      $ra,4($sp) 	 # Save return address
    sw      $fp,0($sp) 	 # Save frame pointer
    addiu   $fp,$sp,4 	 # Save frame pointer

main.0:

main.1:
    li null,7
    move null,null
    move null,null
    jal Factorial.computeRec
    move null,null
    move null,null
    move null,null
    move null,null
    jal jminusminus.SPIM.printInt
    move null,null
    li null,10
    move null,null
    move null,null
    jal jminusminus.SPIM.printChar
    move null,null
    move null,null
    move null,null
    jal Factorial.computeIter
    move null,null
    move null,null
    move null,null
    move null,null
    jal jminusminus.SPIM.printInt
    move null,null
    li null,10
    move null,null
    move null,null
    jal jminusminus.SPIM.printChar
    move null,null
    j main.restore

main.restore:
    lw      $ra,4($sp) 	 # Restore return address
    lw      $fp,0($sp) 	 # Restore frame pointer
    addiu   $sp,$sp,8 	 # Pop stack
    jr      $ra 	 # Return to caller



.text

Factorial.computeIter:
    subu    $sp,$sp,8 	 # Stack frame is 8 bytes long
    sw      $ra,4($sp) 	 # Save return address
    sw      $fp,0($sp) 	 # Save frame pointer
    addiu   $fp,$sp,4 	 # Save frame pointer

Factorial.computeIter.0:

Factorial.computeIter.1:
    li null,1
    move null,null
    move null,null

Factorial.computeIter.2:
    li null,0
    ble null,null,Factorial.computeIter.4
    j Factorial.computeIter.3

Factorial.computeIter.3:
    li null,-1
    add null,null,null
    mul null,null,null
    move null,null
    move null,null
    j Factorial.computeIter.2

Factorial.computeIter.4:
    move null,null
    j Factorial.computeIter.restore

Factorial.computeIter.restore:
    lw      $ra,4($sp) 	 # Restore return address
    lw      $fp,0($sp) 	 # Restore frame pointer
    addiu   $sp,$sp,8 	 # Pop stack
    jr      $ra 	 # Return to caller



# SPIM Runtime

# Copyright 2012- Bill Campbell, Swami Iyer and Bahar Akbal-Delibas
#
# The SPIM runtime file.

.text

# Prints the integer value passed as parameter.
jminusminus.SPIM.printInt:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,3      # Set up frame pointer

    li $v0,1            # Syscall code to print an integer
    syscall             # Prints the arg value

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Prints the float value passed as parameter.
jminusminus.SPIM.printFloat:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,2            # Syscall code to print a float
    syscall             # Prints the arg value

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Print the double value passed as parameter.
jminusminus.SPIM.printDouble:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,3            # Syscall code to print a double
    syscall             # Prints the arg value

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # restore the stack pointer
    jr $ra              # Return to caller

# Print the string value passed as parameter.
jminusminus.SPIM.printString:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,4            # Syscall code to print a string
    syscall             # Print the arg value

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Print the char value passed as parameter.
jminusminus.SPIM.printChar:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,11           # Syscall code to print a char
    syscall             # Print the arg value

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Read the integer value from the user through console.
jminusminus.SPIM.readInt:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,5            # Syscall code to read an integer
    syscall             # Load the integer value read from console into $v0

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Read the float value from the user through console.
jminusminus.SPIM.readFloat:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,6            # Syscall code to read a float
    syscall             # Load the float value read from console into $v0

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Read the double value from the user through console.
jminusminus.SPIM.readDouble:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,7            # Syscall code to read a double
    syscall             # Load the double value read from console into $v0

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Read the string value from the user through console.
jminusminus.SPIM.readString:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,8            # Syscall code to read a string
    syscall             # Load the string value read from console; $a0 = buffer, $a1 = length

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Read the char value from the user through console.
jminusminus.SPIM.readChar:

    subu $sp,$sp,32     # Stack frame is 32 bytes long
    sw $fp,28($sp)      # Save frame pointer
    addu $fp,$sp,32     # Set up frame pointer

    li $v0,12           # Syscall code to read a char
    syscall             # Load the char value read from console into $v0

    lw $fp,28($sp)      # Restore frame pointer
    addiu $sp,$sp,32    # Restore the stack pointer
    jr $ra              # Return to caller

# Exits SPIM.
jminusminus.SPIM.exit:

    li $v0,10           # Syscall code to exit
    syscall

# Exits SPIM with a specified code (in $a0).
jminusminus.SPIM.exit2:

    li $v0,17           # Syscall code to exit2
    syscall

