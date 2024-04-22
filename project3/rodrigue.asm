    #---------------------------------------------------------------------------------
    # Project: Merge Sorted Lists
    # Course: CS 2340.002 - Computer Organization
    # Instructor: Prof. Yi Zhao
    # Student: Diego Rodrigues
    #       
    # Description:
    # This program uses MergeSort to sort a list of integers in ascending order.
    #---------------------------------------------------------------------------------

.data   
medl:   .space  44                      # Allocate space for maximum possible merged list size (11 words)
fl:     .word   6, 3, 4, 5, 8, 9, 14    # First list (first element is the size of the list)
sl:     .word   5, 6, 7, 8, 12, 20      # Second list (first element is the size of the list)

lm:     .asciiz "printing list: "       # Message to user


.text   
        .globl  main
main:   
    la      $a0,    fl                  # address of the first list
    la      $a1,    sl                  # address of the second list
    la      $a2,    medl                  # address of the merged list

    jal     mls                         # merge the two lists

    la      $a0,    medl                  # address of the merged list
    jal     pa                          # print the merged list

    li      $v0,    10                  # exit
    syscall 

    # ---------------------- Merge two sorted lists ----------------------
    # used preserved registers:
    #   $a0 = address of the first list     (unmutated)
    #   $a1 = address of the second list    (unmutated)
    #   $a2 = address of the merged list    (unmutated)
    #   $s0 = index for first list          (mutated)
    #   $s1 = index for second list         (mutated)
    #   $s2 = index for merged list         (mutated)
    #   $s4 = first list element            (mutated)
    #   $s5 = second list element           (mutated)
mls:    
    addi    $sp,    $sp,        -20     # allocate space for mutated registers
    sw      $s0,    0($sp)
    sw      $s1,    4($sp)
    sw      $s2,    8($sp)
    sw      $s4,    12($sp)
    sw      $s5,    16($sp)

    # s0 = index for first list
    # s1 = index for second list
    # s2 = index for merged list
    addi    $s0,    $a0,        4       # skip first first list element
    addi    $s1,    $a1,        4       # skip first second list element
    addi    $s2,    $a2,        4       # skip first merged list element

    # ---------------------- Merge loop ----------------------
ml:     
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a0)              # size of first list
    sll     $t0,    $t0,        2       # size of first list in bytes
    add     $t0,    $a0,        $t0     # address of the end of the first list
    beq     $s0,    $t0,        mrs     # end of first list -> append remaining elements from second list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end checking out of bounds

    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)              # size of second list
    sll     $t0,    $t0,        2       # size of second list in bytes
    add     $t0,    $a1,        $t0     # address of the end of the second list
    beq     $s1,    $t0,        mrf     # end of second list -> append remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end checking out of bounds

    # Load current elements from both lists
    # s4 = first list element
    # s5 = second list element
    lw      $s4,    0($s0)              # Load first list element
    lw      $s5,    0($s1)              # Load second list element

    # Compare and store the smaller element
    blt     $s4,    $s5,        sf      # first element is smaller -> store it

ss:                                     # store second element
    sw      $s5,    0($s2)              # store second element in merged list
    addi    $s1,    $s1,        4       # Increment index of the second list
    j       mi

sf:                                     # store first element
    sw      $s4,    0($s2)              # store first element in merged list
    addi    $s0,    $s0,        4       # increment index of the first list

mi:                                     # increment index of the merged list, note index is incremented once
    addi    $a2,    $a2,        4
    j       ml                          # continue merging, loop is broken when one of the lists is empty
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ml

    # ------------- Append remaining elements from first list -------------
mrf:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a0)              # size of first list
    sll     $t0,    $t0,        2       # size of first list in bytes
    add     $t0,    $a0,        $t0     # address of the end of the first list
    beq     $s0,    $t0,        md      # end of first list -> append remaining elements from second list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end checking out of bounds

    lw      $s4,    0($s0)              # load first list element
    sw      $s4,    0($s2)              # store first list element in merged list
    addi    $s0,    $s0,        4       # increment index of the first list
    addi    $a2,    $a2,        4       # increment index of the merged list
    j       mrf                         # continue appending remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrf

    # ------------- Append remaining elements from second list ----------
mrs:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)              # size of second list
    sll     $t0,    $t0,        2       # size of second list in bytes
    add     $t0,    $a1,        $t0     # address of the end of the second list
    beq     $s1,    $t0,        md      # end of second list -> append remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end checking out of bounds

    lw      $s5,    0($s1)              # load second list element
    sw      $s5,    0($s2)              # store second list element in merged list
    addi    $s1,    $s1,        4       # increment index of the second list
    addi    $a2,    $a2,        4       # increment index of the merged list
    j       mrs
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrs

md:     
    lw      $s0,    0($sp)              # restore mutated registers
    lw      $s1,    4($sp)
    lw      $s2,    8($sp)
    lw      $s4,    12($sp)
    lw      $s5,    16($sp)
    addi    $sp,    $sp,        20      # deallocate space for mutated registers

    move    $v0,    $a2                 # return address of merged list
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mls



    # ------------------- Print list -------------------
    # used preserved registers:
    #   $a0 = address of the array to print (unmutated)
    #   $s0 = address moved to this register
    #   $s1 = index for the array to print  (mutated)
pa:     
    addi    $sp,    $sp,        -8      # allocate space for mutated registers
    sw      $s0,    0($sp)
    sw      $s1,    4($sp)

    move    $s0,    $a0                 # move address to s0 because $a0 will be used to print messages
    addi    $s1,    $s0,        4       # index for the array to print, skip first element

    la      $a0,    lm                  # msg to user, lm = "printing list: "
    li      $v0,    4
    syscall 


    # ------------------- Print loop -------------------
pl:     
    # ------------- checking out of bounds -------------
    lw      $t0,    0($s0)              # size of list
    sll     $t0,    $t0,        2       # size of list in bytes
    add     $t0,    $s0,        $t0     # address of the end of list
    beq     $s0,    $t0,        ep      # end of lsit -> end printing
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end checking out of bounds

    lw      $a0,    0($s1)              # load integer from array
    li      $v0,    1
    syscall 

    li      $a0,    ','       # print separator
    li      $v0,    11
    syscall 

    addi    $s1,    $s1,        4       # increment index
    b       pl
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pl

    # ------------------- End print list -------------------
ep:     
    lw      $a1,    0($sp)
    lw      $a2,    4($sp)
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pa





