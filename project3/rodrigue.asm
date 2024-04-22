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
list:   .space  128                                             # Allocate space for list to sort

newline:    .asciiz "\n"
es:     .asciiz "Enter size of list: \n"
fl:     .asciiz "Enter consecutive integers to fill list: \n"
dr:     .asciiz "Done reading... \n"
ms:     .asciiz "Sorting list: "
dmer:   .asciiz "Done merging, merged list: \n"



.text   
        .globl  main
main:   

    # ------------------ Read integers -------------------
    la      $a1,    list                                        # base address of the list
    jal     ri                                                  # read integers

    la      $a0,    ms                                          # message to user
    la      $a1,    list                                        # address of the list
    jal     pa                                                  # print list


    # ------------------ Read integers -------------------
    # used preserved registers:
    #   $a1 = address of the list
    #   $s1 = index for the list
ri:     
    addi    $sp,    $sp,        -12                             # allocate space
    sw      $ra,    0($sp)
    sw      $a1,    4($sp)
    sw      $s1,    8($sp)

    # prompt user to enter the number of integers
    li      $v0,    4                                           # syscall to print string
    la      $a0,    es                                          # load "Enter size of list: "
    syscall 

    # Read size of the list
    li      $v0,    5                                           # syscall to read integer
    syscall 
    sw      $v0,    0($a1)                                      # store the size at the beginning of the list

    # prompt user to enter the integers
    li      $v0,    4                                           # syscall to print string
    la      $a0,    fl                                          # load "Enter consecutive integers to fill list: "
    syscall 

    move    $s1,    $zero                                       # initialize index for the list

rl:     
    lw      $t0,    0($a1)                                      # size of the list
    beq     $s1,    $t0,        doner                           # done reading

    li      $v0,    5                                           # syscall to read integer
    syscall 

    move    $t0,    $a1                                         # address of the list
    move    $t1,    $s1                                         # index of the list
    move    $t2,    $v0                                         # value to store
    jal     ias                                                 # store the value in the list

    addi    $s1,    $s1,        1                               # increment index
    b       rl                                                  # continue reading

    # ---------------------- Done reading -------------
doner:  
    li      $v0,    4                                           # syscall to print string
    la      $a0,    dr                                          # msg to user, dmer = "Done reading... "
    syscall 

    lw      $ra,    0($sp)                                      # restore ra
    lw      $a1,    4($sp)                                      # restore a1
    lw      $s1,    8($sp)                                      # restore s1
    addi    $sp,    $sp,        12                              # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end rl


    # ---------------------- Merge Sort ------------------
    # used preserved registers:



    # ---------------------- Merge two sorted lists -------
    # used preserved registers:
    #   $a1 = address of the first list     (unmutated)
    #   $a2 = address of the second list    (unmutated)
    #   $a3 = address of the merged list    (unmutated)
    #   $s1 = index for first list          (mutated)
    #   $s2 = index for second list         (mutated)
    #   $s3 = index for merged list         (mutated)
    #   $s5 = first list element            (mutated)
    #   $s6 = second list element           (mutated)
mls:    
    addi    $sp,    $sp,        -24                             # allocate space for mutated registers
    sw      $s1,    0($sp)
    sw      $s2,    4($sp)
    sw      $s3,    8($sp)
    sw      $s5,    12($sp)
    sw      $s6,    16($sp)
    sw      $ra,    20($sp)

    # s0 = index for first list
    # s1 = index for second list
    # s2 = index for merged list
    move    $s1,    $zero                                       # initialize index for first list
    move    $s2,    $zero                                       # initialize index for second list
    move    $s3,    $zero                                       # initialize index for merged list

    # ---------------------- Merge loop ----------------
ml:     
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)                                      # size of first
    bge     $s1,    $t0,        mrs                             # end of first list -> append remaining elements from second list

    # ------------- checking out of bounds -------------
    lw      $t0,    0($a2)                                      # size of second
    bge     $s2,    $t0,        mrf                             # end of second list -> append remaining elements from first list

    # Load current elements from both lists
    # s5 = first list element
    # s6 = second list element

    # --------- Load first element ---------
    move    $t0,    $a1                                         # address of the first list
    move    $t1,    $s1                                         # index of the first list
    jal     ial                                                 # get the element at the index of the first list
    move    $s5,    $v0                                         # store first list element in s4

    # --------- Load second element ---------
    move    $t0,    $a2                                         # address of the second list
    move    $t1,    $s2                                         # index of the second list
    jal     ial                                                 # get the element at the index of the second list
    move    $s6,    $v0                                         # store second list element in s5

    # Compare and store the smaller element
    blt     $s5,    $s6,        sf                              # first element is smaller -> store it

ss:                                                             # store second element
    move    $t2,    $s6                                         # value to store
    addi    $s2,    $s2,        1                               # Increment index of the second list
    j       mi

sf:                                                             # store first element
    move    $t2,    $s5                                         # value to store
    addi    $s1,    $s1,        1                               # increment index of the first list

mi:                                                             # increment index of the merged list, note index is incremented once
    # --------- Store the smaller element ---------
    move    $t0,    $a3                                         # address of the merged list
    move    $t1,    $s3                                         # index of the merged list
    jal     ias                                                 # store the value in the merged list, note that the value to store was set in $t2

    addi    $s3,    $s3,        1                               # increment index of the merged list
    j       ml                                                  # continue merging, loop is broken when one of the lists is empty
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ml

    # ------------- Append remaining elements from first list ----
mrf:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a1)                                      # size of first list
    bge     $s1,    $t0,        md                              # end of first list -> append remaining elements from second list

    # --------- Load first element ---------
    move    $t0,    $a1                                         # address of the first list
    move    $t1,    $s1                                         # index of the first list
    jal     ial                                                 # get the element at the index of the first list

    # --------- Store the element ---------
    move    $t0,    $a3                                         # address of the merged list
    move    $t1,    $s3                                         # index of the merged list
    move    $t2,    $v0                                         # value to store
    jal     ias                                                 # store the value in the merged list

    addi    $s1,    $s1,        1                               # increment index of the first list
    addi    $s3,    $s3,        1                               # increment index of the merged list
    j       mrf                                                 # continue appending remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrf

    # ------------- Append remaining elements from second list ----------
mrs:    
    # ------------- checking out of bounds -------------
    lw      $t0,    0($a2)                                      # size of second list
    bge     $s2,    $t0,        md                              # end of second list -> merge is complete

    # --------- Load second element ---------
    move    $t0,    $a2                                         # address of the second list
    move    $t1,    $s2                                         # index of the second list
    jal     ial                                                 # get the element at the index of the second list

    # --------- Store the element ---------
    move    $t0,    $a3                                         # address of the merged list
    move    $t1,    $s3                                         # index of the merged list
    move    $t2,    $v0                                         # value to store
    jal     ias                                                 # store the value in the merged list

    addi    $s2,    $s2,        1                               # increment index of the second list
    addi    $s3,    $s3,        1                               # increment index of the merged list
    j       mrs
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrs

md:     
    sw      $s3,    0($a3)                                      # store size of merged list
    move    $v0,    $a3                                         # return address of merged list

    lw      $s1,    0($sp)                                      # restore mutated registers
    lw      $s2,    4($sp)
    lw      $s3,    8($sp)
    lw      $s5,    12($sp)
    lw      $s6,    16($sp)
    lw      $ra,    20($sp)
    addi    $sp,    $sp,        24                              # deallocate space for mutated registers
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mls

    # ------------------- Index array load -------------------
    # Returns to $v0 the value of the element at the index of the array
    # Note that the first element of the array is the size of the list
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
ial:    
    addi    $sp,    $sp,        -4                              # allocate space
    sw      $ra,    0($sp)

    addi    $t1,    $t1,        1                               # increment index to skip the first element
    sll     $t1,    $t1,        2                               # index in bytes
    add     $t0,    $t0,        $t1                             # address of the element
    lw      $v0,    0($t0)                                      # load element

    lw      $ra,    0($sp)                                      # restore ra
    addi    $sp,    $sp,        4                               # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ia

    # ------------------- Index array store -------------------
    # Stores the value of $a2 at the index of the array
    # Note that the first element of the array is the size of the list
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
    #   $t2 = value to store
ias:    
    addi    $sp,    $sp,        -4                              # allocate space
    sw      $ra,    0($sp)

    addi    $t1,    $t1,        1                               # increment index to skip the first element
    sll     $t1,    $t1,        2                               # index in bytes
    add     $t1,    $t0,        $t1                             # address of the element
    sw      $t2,    0($t1)                                      # store element

    lw      $ra,    0($sp)                                      # restore ra
    addi    $sp,    $sp,        4                               # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ias

    # ------------------- Print list -------------------
    # used preserved registers:
    #   $a0 = message to user (unmutated)
    #   $a1 = address of the array to print (unmutated)
    #   $s1 = index for the array to print  (mutated)
pa:     
    addi    $sp,    $sp,        -12                             # allocate space for mutated registers
    sw      $a0,    0($sp)
    sw      $s1,    4($sp)
    sw      $ra,    8($sp)

    # Print message to user, note that $a0 is passed as an argument
    li      $v0,    4
    syscall 

    move    $s1,    $zero                                       # initialize index for the list

    # ------------------- Print loop -------------------
pl:     
    lw      $t0,    0($a1)                                      # size of the list
    bge     $s1,    $t0,        ep                              # end of the list

    # --------- Load element ---------
    move    $t0,    $a1                                         # address of the array
    move    $t1,    $s1                                         # index of the array
    jal     ial                                                 # get the element at the index of the array

    move    $a0,    $v0                                         # value to print
    li      $v0,    1
    syscall 

    li      $a0,    ' '                               # print separator
    li      $v0,    11
    syscall 

    addi    $s1,    $s1,        1                               # increment index
    b       pl
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pl

    # ------------------- End print list -------------------
ep:     
    la      $a0,    newline                                          # print newline, ASCII code for newline is 10
    li      $v0,    4
    syscall 

    lw      $a0,    0($sp)                                      # restore unmutated registers
    lw      $s1,    4($sp)
    lw      $ra,    8($sp)
    addi    $sp,    $sp,        12                              # deallocate space


    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pa





