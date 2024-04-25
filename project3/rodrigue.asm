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
list:       .space  128                                             # Allocate space for list to sort
newline:    .asciiz "\n"
separator:  .asciiz ", "
ent_size:   .asciiz "Enter size of list: \n"
fill_list:  .asciiz "Enter consecutive integers to fill list: \n"
done_read:  .asciiz "Done reading... \n"
sorting:    .asciiz "Sorting list: "
invalid:    .asciiz "Invalid size, please enter powers of 2 \n"
done_merg:  .asciiz "Done merging, merged list: \n"



.text   
            .globl  main
main:       
    la      $s3,            list                                    # base address of the list

    # ------------------ Read integers -------------------
    move    $a1,            $s3                                     # address of the list
    jal     read_ints                                               # read integers

    # ------------------ Print list -------------------
    la      $a0,            sorting                                 # message to user
    move    $a1,            $s3
    jal     print_ary                                               # print list


    # ------------------ Print sublists -------------------
    addi    $sp,            $sp,        -12
    move    $a1,            $sp
    addi    $a2,            $s3,        8
    li      $a3,            2
    jal     copy_args

    jal     print_ary                                               # print list

    b       end                                                     # exit


    # ------------------ Merge Sort -------------------
    # Size of the list to sort is assumed to be a power of 2
    # used preserved registers:
    #   $a0 = address of the list to sort
    #   $s1 = index of subarray           (mutated)
    #   $s2 = size of subarray            (mutated)
    #   $s3 = size of the list            (mutated)
merge_sort: 
    addi    $sp,            $sp,        -16                         # allocate space
    sw      $s1,            0($sp)
    sw      $s2,            4($sp)
    sw      $s3,            8($sp)
    sw      $ra,            12($sp)

    li      $s2,            1                                       # initialize size of subarray
    lw      $s3,            0($a0)                                  # size of the list

sort_loop:  
    beq     $s2,            $s3,        sort_end                    # done sorting

    move    $s1,            $zero                                   # initialize index of subarray
    j       sort_subarrays                                          # sort subarrays

    sll     $s3,            $s3,        1                           # double the size of the subarray
    j       sort_loop                                               # continue sorting

    # -------------- Merge Subarrays ----------------
sort_subarrays:
    beq     $s1,            $s3,        sort_loop                   # end of the list

    # -------- Copy first subarray ---------
    addi    $t0,            $s2,        4                           # size of the first subarray including first element for tracking size
    sub     $sp,            $sp,        $t0                         # allocate space for the first subarray
    add     $a1,            $sp,        $s1                         # address of the first subarray

    move    $a2,            $a0                                     # address of the list
    move    $a3,            $s2                                     # size of the first subarray
jal     copy_sized                                              # copy the first subarray

    # -------- Copy second subarray ---------
    addi    $t0,            $s2,        4                           # size of the second subarray including first element for tracking size



    # -------------- Merge two subarrays ------------


sort_end:   
    lw      $s1,            0($sp)                                  # restore mutated registers
    lw      $s2,            4($sp)
    lw      $s3,            8($sp)
    lw      $ra,            12($sp)

    addi    $sp,            $sp,        8                           # deallocate space
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end merge_sort




    # ------------------ Read integers -------------------
    # used preserved registers:
    #   $a1 = address of the list
    #   $s1 = index for the list
read_ints:  
    addi    $sp,            $sp,        -12                         # allocate space
    sw      $ra,            0($sp)
    sw      $a1,            4($sp)
    sw      $s1,            8($sp)

    # prompt user to enter the number of integers
    li      $v0,            4                                       # syscall to print string
    la      $a0,            ent_size                                # load "Enter size of list: "
    syscall 

    # Read size of the list
    li      $v0,            5                                       # syscall to read integer
    syscall 
    sw      $v0,            0($a1)                                  # store the size at the beginning of the list

    # ------------ Check if size is a power of 2 ------------
    move    $t0,            $v0                                     # number to check
    jal     check_power2                                            # check if size is a power of 2

    # prompt user to enter the integers
    li      $v0,            4                                       # syscall to print string
    la      $a0,            fill_list                               # load "Enter consecutive integers to fill list: "
    syscall 

    move    $s1,            $zero                                   # initialize index for the list

read_loop:  
    lw      $t0,            0($a1)                                  # size of the list
    beq     $s1,            $t0,        read_end                    # done reading

    li      $v0,            5                                       # syscall to read integer
    syscall 

    move    $t0,            $a1                                     # address of the list
    move    $t1,            $s1                                     # index of the list
    move    $t2,            $v0                                     # value to store
    jal     ary_save                                                # store the value in the list

    addi    $s1,            $s1,        1                           # increment index
    b       read_loop                                               # continue reading

    # ---------------------- Done reading -------------
read_end:   
    li      $v0,            4                                       # syscall to print string
    la      $a0,            done_read                               # msg to user, dmer = "Done reading... "
    syscall 

    lw      $ra,            0($sp)                                  # restore ra
    lw      $a1,            4($sp)                                  # restore a1
    lw      $s1,            8($sp)                                  # restore s1
    addi    $sp,            $sp,        12                          # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end rl




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
merge_lists:
    addi    $sp,            $sp,        -24                         # allocate space for mutated registers
    sw      $s1,            0($sp)
    sw      $s2,            4($sp)
    sw      $s3,            8($sp)
    sw      $s5,            12($sp)
    sw      $s6,            16($sp)
    sw      $ra,            20($sp)

    move    $s1,            $zero                                   # initialize index for first list
    move    $s2,            $zero                                   # initialize index for second list
    move    $s3,            $zero                                   # initialize index for merged list

    # ---------------------- Merge loop ----------------
merge_loop: 
    # ------------- checking out of bounds -------------
    lw      $t0,            0($a1)                                  # size of first
    bge     $s1,            $t0,        merge_second                # end of first list -> append remaining elements from second list

    # ------------- checking out of bounds -------------
    lw      $t0,            0($a2)                                  # size of second
    bge     $s2,            $t0,        merge_first                 # end of second list -> append remaining elements from first list

    # Load current elements from both lists
    # s5 = first list element
    # s6 = second list element

    # --------- Load first element ---------
    move    $t0,            $a1                                     # address of the first list
    move    $t1,            $s1                                     # index of the first list
    jal     ary_load                                                # get the element at the index of the first list
    move    $s5,            $v0                                     # store first list element in s4

    # --------- Load second element ---------
    move    $t0,            $a2                                     # address of the second list
    move    $t1,            $s2                                     # index of the second list
    jal     ary_load                                                # get the element at the index of the second list
    move    $s6,            $v0                                     # store second list element in s5

    # Compare and store the smaller element
    blt     $s5,            $s6,        save_first                  # first element is smaller -> store it

save_second:                                                        # store second element
    move    $t2,            $s6                                     # value to store
    addi    $s2,            $s2,        1                           # Increment index of the second list
    j       merge_incre

save_first:                                                         # store first element
    move    $t2,            $s5                                     # value to store
    addi    $s1,            $s1,        1                           # increment index of the first list

merge_incre:                                                        # increment index of the merged list, note index is incremented once
    # --------- Store the smaller element ---------
    move    $t0,            $a3                                     # address of the merged list
    move    $t1,            $s3                                     # index of the merged list
    jal     ary_save                                                # store the value in the merged list, note that the value to store was set in $t2

    addi    $s3,            $s3,        1                           # increment index of the merged list
    j       merge_loop                                              # continue merging, loop is broken when one of the lists is empty
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ml

    # ------------- Append remaining elements from first list ----
merge_first:
    # ------------- checking out of bounds -------------
    lw      $t0,            0($a1)                                  # size of first list
    bge     $s1,            $t0,        merge_end                   # end of first list -> append remaining elements from second list

    # --------- Load first element ---------
    move    $t0,            $a1                                     # address of the first list
    move    $t1,            $s1                                     # index of the first list
    jal     ary_load                                                # get the element at the index of the first list

    # --------- Store the element ---------
    move    $t0,            $a3                                     # address of the merged list
    move    $t1,            $s3                                     # index of the merged list
    move    $t2,            $v0                                     # value to store
    jal     ary_save                                                # store the value in the merged list

    addi    $s1,            $s1,        1                           # increment index of the first list
    addi    $s3,            $s3,        1                           # increment index of the merged list
    j       merge_first                                             # continue appending remaining elements from first list
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrf

    # ------------- Append remaining elements from second list ----------
merge_second:
    # ------------- checking out of bounds -------------
    lw      $t0,            0($a2)                                  # size of second list
    bge     $s2,            $t0,        merge_end                   # end of second list -> merge is complete

    # --------- Load second element ---------
    move    $t0,            $a2                                     # address of the second list
    move    $t1,            $s2                                     # index of the second list
    jal     ary_load                                                # get the element at the index of the second list

    # --------- Store the element ---------
    move    $t0,            $a3                                     # address of the merged list
    move    $t1,            $s3                                     # index of the merged list
    move    $t2,            $v0                                     # value to store
    jal     ary_save                                                # store the value in the merged list

    addi    $s2,            $s2,        1                           # increment index of the second list
    addi    $s3,            $s3,        1                           # increment index of the merged list
    j       merge_second
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mrs

merge_end:  
    sw      $s3,            0($a3)                                  # store size of merged list
    move    $v0,            $a3                                     # return address of merged list

    lw      $s1,            0($sp)                                  # restore mutated registers
    lw      $s2,            4($sp)
    lw      $s3,            8($sp)
    lw      $s5,            12($sp)
    lw      $s6,            16($sp)
    lw      $ra,            20($sp)
    addi    $sp,            $sp,        24                          # deallocate space for mutated registers
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end mls




    # ------------------- Index array load -------------------
    # Returns to $v0 the value of the element at the index of the sized array
    # Note that the first element of the array is the size of the list
    # Sized array is a list with the first element being the size of the list.
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
ary_load:   
    addi    $sp,            $sp,        -4                          # allocate space
    sw      $ra,            0($sp)

    addi    $t1,            $t1,        1                           # increment index to skip the first element
    sll     $t1,            $t1,        2                           # index in bytes
    add     $t0,            $t0,        $t1                         # address of the element
    lw      $v0,            0($t0)                                  # load element

    lw      $ra,            0($sp)                                  # restore ra
    addi    $sp,            $sp,        4                           # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ia





    # ------------------- Index array store -------------------
    # Stores the value of $a2 at the index of the sized array
    # Note that the first element of the array is the size of the list
    # Sized array is a list with the first element being the size of the list.
    # used registers:
    #   $t0 = address of the array
    #   $t1 = index for the array
    #   $t2 = value to store
ary_save:   
    addi    $sp,            $sp,        -4                          # allocate space
    sw      $ra,            0($sp)

    addi    $t1,            $t1,        1                           # increment index to skip the first element
    sll     $t1,            $t1,        2                           # index in bytes
    add     $t1,            $t0,        $t1                         # address of the element
    sw      $t2,            0($t1)                                  # store element

    lw      $ra,            0($sp)                                  # restore ra
    addi    $sp,            $sp,        4                           # deallocate space
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end ias




    # ------------------- Print list -------------------
    # used preserved registers:
    #   $a0 = message to user (unmutated)
    #   $a1 = address of the array to print (unmutated)
    #   $s1 = index for the array to print  (mutated)
print_ary:  
    addi    $sp,            $sp,        -12                         # allocate space for mutated registers
    sw      $a0,            0($sp)
    sw      $s1,            4($sp)
    sw      $ra,            8($sp)

    # Print message to user, note that $a0 is passed as an argument
    li      $v0,            4
    syscall 

    li      $a0,            '['                                     # print opening bracket
    li      $v0,            11
    syscall 

    move    $s1,            $zero                                   # initialize index for the list

    # ------------------- Print loop -------------------
print_loop: 
    lw      $t0,            0($a1)                                  # size of the list
    subi    $t0,            $t0,        1                           # decrement size to get the last index
    bge     $s1,            $t0,        print_end                   # last element of the list

    # --------- Load element ---------
    move    $t0,            $a1                                     # address of the array
    move    $t1,            $s1                                     # index of the array
    jal     ary_load                                                # get the element at the index of the array

    move    $a0,            $v0                                     # value to print
    li      $v0,            1
    syscall 

    la      $a0,            separator                               # print separator
    li      $v0,            4
    syscall 

    addi    $s1,            $s1,        1                           # increment index
    b       print_loop
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pl

    # ------------------- End print list -------------------
print_end:  
    # --------- Load last element ---------
    move    $t0,            $a1                                     # address of the array
    move    $t1,            $s1                                     # index of the array
    jal     ary_load                                                # get the element at the index of the array

    move    $a0,            $v0                                     # value to print
    li      $v0,            1
    syscall 

    la      $a0,            ']'                                     # print closing bracket
    li      $v0,            11
    syscall 

    la      $a0,            newline                                 # print newline, ASCII code for newline is 10
    li      $v0,            4
    syscall 

    lw      $a0,            0($sp)                                  # restore unmutated registers
    lw      $s1,            4($sp)
    lw      $ra,            8($sp)
    addi    $sp,            $sp,        12                          # deallocate space


    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end pa



    # ------ Copies arg-sized list to sized list ------
    # A sized list is a list with the first element being the size of the list.
    # A arg-sized list has the size passed as an argument.

    # used preserved registers:
    #   $a1 = address to copy to the sized list
    #   $a2 = address of arg-sized list
    #   $a3 = size of the arg-sized list
    #   $s1 = index for the arg-sized list      (mutated)
copy_args:  
    addi    $sp,            $sp,        -8                          # allocate space
    sw      $s1,            0($sp)
    sw      $ra,            4($sp)

    move    $s1,            $zero                                   # initialize index for the arg-sized list

    # Copy size to sized list
    sw      $a3,            0($a1)                                  # store size of the list
    # ------------------- Copy loop -------------------
cargs_loop: 
    bge     $s1,            $a3,        cargs_end                   # end of the list

    # --------- Load element ---------
    sll     $t1,            $s1,        2                           # index in bytes
    add     $t1,            $a2,        $t1                         # address of the element
    lw      $t2,            0($t1)                                  # load element from arg-sized list

    # --------- Store element ---------
    move    $t0,            $a1                                     # address of the sized list
    move    $t1,            $s1                                     # index of the sized list
    jal     ary_save                                                # store the value in the sized list note that the value to store was set in $t2 previously

    addi    $s1,            $s1,        1                           # increment index
    b       cargs_loop                                              # continue copying
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end cl

    # ------------------- End copy list -------------------
cargs_end:  
    lw      $s1,            0($sp)                                  # restore mutated registers
    lw      $ra,            4($sp)
    addi    $sp,            $sp,        8                           # deallocate space

    move    $v0,            $a1                                     # return address of sized list
    move    $v1,            $a3                                     # return size of the list

    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end cas


    # ----- Copy sized list to arg-sized list ------
    # A sized list is a list with the first element being the size of the list.
    # An arg-sized list has the size passed as an argument.
    #       
    # Used preserved registers:
    #   $a1 = address of arg-sized list
    #   $a2 = address of sized list
    #   $s1 = index for the arg-sized list      (mutated)
copy_sized: 
    addi    $sp,            $sp,        -8                          # allocate space
    sw      $s1,            0($sp),     #
    sw      $ra,            4($sp)

    move    $s1,            $zero                                   # initialize index for the arg-sized list

    # Copy size to arg-sized list
    lw      $v1,            0($a2)                                  # save size of the list to return $v1

    # ------------------- Copy loop -------------------
csized_loop:
    bge     $s1,            $v1,        csized_end                  # end of the list

    # --------- Load element ---------
    move    $t0,            $a2                                     # address of the sized list
    move    $t1,            $s1                                     # index of the sized list
    jal     ary_load                                                # get the element at the index of the sized list

    # --------- Store element ---------
    sll     $t1,            $s1,        2                           # index in bytes
    add     $t1,            $a1,        $t1                         # address of the element
    sw      $v0,            0($t1)                                  # store element in arg-sized list

    addi    $s1,            $s1,        1                           # increment index
    b       csized_loop                                             # continue copying
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end cl

    # ------------------- End copy list -------------------
csized_end: 
    lw      $s1,            0($sp)                                  # restore mutated registers
    lw      $ra,            4($sp)
    addi    $sp,            $sp,        8                           # deallocate space

    move    $v0,            $a1                                     # return address of arg-sized list
    # note that $v1 is the size of the list

    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end csa




    # ------------- Check if number is a power of 2 ------------
    # used registers:
    #   $t0 = number to compare
    #   $t1 = used to divide by 2 and compare
check_power2:
    srl     $t1,            $t0,        1                           # divide by 2 test
    beq     $t1,            $zero,      done_check                  # done checking if jump to zero
    sll     $t1,            $t1,        1                           # multiply by 2 to compare if it has changed
    blt     $t1,            $t0,        invalid_size                # invalid size, not a power of 2
    srl     $t0,            $t0,        1                           # divide by 2 test
    j       check_power2                                            # continue checking

invalid_size:
    li      $v0,            4                                       # syscall to print string
    la      $a0,            invalid                                 # load "Invalid size, please enter powers of 2"
    syscall 
    j       main                                                    # restart the program

done_check: 
    jr      $ra
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ end check_power2





    # ------------------- End of program -------------------
end:        
    li      $v0,            10                                      # exit
    syscall 






