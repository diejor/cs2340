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
medl:   .space  48                      # Allocate space for maximum possible merged list size (11 words)
fl:     .word   6, 3, 4, 5, 8, 9, 14    # First list (first element is the size of the list)
sl:     .word   5, 6, 7, 8, 12, 20      # Second list (first element is the size of the list)

lm:     .asciiz "printing list: "       # Message to user


.text   
        .globl  main
main:   
    la      $a0,    fl                  # address of the first list
    la      $a1,    sl                  # address of the second list
    la      $a2,    medl                # address of the merged list

    jal     mls                         # merge the two lists

    la      $a0,    medl                # address of the merged list
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
    addi    $sp,    $sp,        -24     # allocate space for mutated registers
    sw      $s0,    0($sp)
    sw      $s1,    4($sp)
    sw      $s2,    8($sp)
    sw      $s4,    12($sp)
    sw      $s5,    16($sp)
    sw      $ra,    20($sp)

    # s0 = index for first list
    # s1 = index for second list
    # s2 = index for merged list
    move    $s0,    $zero               # initialize index for first list
    move    $s1,    $zero               # initialize index for second list
    move    $s2,    $zero               # initialize index for merged list

    # ---------------------- Merge loop ----------------------
ml:     
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a0)              # size of first
    bge     $s0,    $t0,        mrs     # end of first list -> append remaining elements from second list

    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)              # size of second
    bge     $s1,    $t0,        mrf     # end of second list -> append remaining elements from first list

    # Load current elements from both lists
    # s4 = first list element
    # s5 = second list element

    # --------- Load first element ---------
    move    $t0,    $a0                 # address of the first list
    move    $t1,    $s0                 # index of the first list
    jal     ial                         # get the element at the index of the first list
    move    $s4,    $v0                 # store first list element in s4

    # --------- Load second element ---------
    move    $t0,    $a1                 # address of the second list
    move    $t1,    $s1                 # index of the second list
    jal     ial                         # get the element at the index of the second list
    move    $s5,    $v0                 # store second list element in s5

    # Compare and store the smaller element
    blt     $s4,    $s5,        sf      # first element is smaller -> store it

ss:                                     # store second element
    move    $t2,    $s5                 # value to store
    addi    $s1,    $s1,        1       # Increment index of the second list
    j       mi

sf:                                     # store first element
    move    $t2,    $s4                 # value to store
    addi    $s0,    $s0,        1       # increment index of the first list

mi:                                     # increment index of the merged list, note index is incremented once
    # --------- Store the smaller element ---------
    move    $t0,    $a2                 # address of the merged list
    move    $t1,    $s2                 # index of the merged list
    jal     ias                         # store the value in the merged list, note that the value to store was set in $t2

    addi    $s2,    $s2,        1       # increment index of the merged list
    j       ml                          # continue merging, loop is broken when one of the lists is empty
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ml

    # ------------- Append remaining elements from first list -------------
mrf:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a0)              # size of first list
    bge     $s0,    $t0,        md      # end of first list -> append remaining elements from second list

    # --------- Load first element ---------
    move    $t0,    $a0                 # address of the first list
    move    $t1,    $s0                 # index of the first list
    jal     ial                         # get the element at the index of the first list

    # --------- Store the element ---------
    move    $t0,    $a2                 # address of the merged list
    move    $t1,    $s2                 # index of the merged list
    move    $t2,    $v0                 # value to store
    jal     ias                         # store the value in the merged list

    addi    $s0,    $s0,        1       # increment index of the first list
    addi    $s2,    $s2,        1       # increment index of the merged list
    j       mrf                         # continue appending remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrf

    # ------------- Append remaining elements from second list ----------
mrs:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)              # size of second list
    bge     $s1,    $t0,        md      # end of second list -> merge is complete

    # --------- Load second element ---------
    move    $t0,    $a1                 # address of the second list
    move    $t1,    $s1                 # index of the second list
    jal     ial                         # get the element at the index of the second list

    # --------- Store the element ---------
    move    $t0,    $a2                 # address of the merged list
    move    $t1,    $s2                 # index of the merged list
    move    $t2,    $v0                 # value to store
    jal     ias                         # store the value in the merged list

    addi    $s1,    $s1,        1       # increment index of the second list
    addi    $s2,    $s2,        1       # increment index of the merged list
    j       mrs
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrs

md:     
    sw      $s2,    0($a2)              # store size of merged list
    move    $v0,    $a2                 # return address of merged list

    lw      $s0,    0($sp)              # restore mutated registers
    lw      $s1,    4($sp)
    lw      $s2,    8($sp)
    lw      $s4,    12($sp)
    lw      $s5,    16($sp)
    lw      $ra,    20($sp)
    addi    $sp,    $sp,        24      # deallocate space for mutated registers
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mls

    # ------------------- Index array load -------------------
    # Returns to $v0 the value of the element at the index of the array
    # Note that the first element of the array is the size of the list
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
ial:    
    addi    $sp,    $sp,        -4      # allocate space
    sw      $ra,    0($sp)

    addi    $t1,    $t1,        1       # increment index to skip the first element
    sll     $t1,    $t1,        2       # index in bytes
    add     $t0,    $t0,        $t1     # address of the element
    lw      $v0,    0($t0)              # load element

    lw      $ra,    0($sp)              # restore ra
    addi    $sp,    $sp,        4       # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ia

    # ------------------- Index array store -------------------
    # Stores the value of $a0 at the index of the array
    # Note that the first element of the array is the size of the list
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
    #   $t2 = value to store
ias:    
    addi    $sp,    $sp,        -4      # allocate space
    sw      $ra,    0($sp)

    addi    $t1,    $t1,        1       # increment index to skip the first element
    sll     $t1,    $t1,        2       # index in bytes
    add     $t1,    $t0,        $t1     # address of the element
    sw      $t2,    0($t1)              # store element

    lw      $ra,    0($sp)              # restore ra
    addi    $sp,    $sp,        4       # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ias

    # ------------------- Print list -------------------
    # used preserved registers:
    #   $a0 = address of the array to print (unmutated)
    #   $s0 = address of array to print moved (mutated)
    #   $s1 = index for the array to print  (mutated)
pa:     
    addi    $sp,    $sp,        -12      # allocate space for mutated registers
    sw      $s0,    0($sp)
    sw      $s1,    4($sp)
    sw      $ra,    8($sp)

    move    $s0,    $a0               # initialize index for the array

    la      $a0,    lm                  # msg to user, lm = "printing list: "
    li      $v0,    4
    syscall 


    # ------------------- Print loop -------------------
pl:     
    lw      $t0,    0($s0)              # size of the list
    bge     $s1,    $t0,        ep      # end of the list

    # --------- Load element ---------
    move    $t0,    $s0                 # address of the array
    move    $t1,    $s1                 # index of the array
    jal     ial                         # get the element at the index of the array

    move    $a0,    $v0                 # value to print
    li      $v0,    1
    syscall 

    li      $a0,    ' '       # print separator
    li      $v0,    11
    syscall 

    addi    $s1,    $s1,        1       # increment index
    b       pl
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pl

    # ------------------- End print list -------------------
ep:     
    lw      $s0,    0($sp)
    lw      $s1,    4($sp)
    lw      $ra,    8($sp)
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pa





