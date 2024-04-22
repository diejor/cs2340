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
merged_list:    .space  44                                              # Allocate space for maximum possible merged list size (11 words)
first_list:     .word   3, 4, 5, 8, 9, 14
first_size:     .word   6

second_list:    .word   6, 7, 8, 12, 20
second_size:    .word   5

list_msg:       .asciiz "printing list: "


.text   
                .globl  main
merge_lists:    
    addi    $sp,                    $sp,            -4
    la      $a1,                    first_list
    lw      $a2,                    first_size
    la      $a3,                    second_list
    lw      $t0,                    second_size
    la      $t1,                    merged_list
    jal     merge

    # Now $v0 contains the size of the merged list
    move    $a2,                    $v0
    la      $a1,                    merged_list
    jal     print_array

    j       end_program                                                 # Corrected to jump to the defined label
merge:          
    # Arguments: $a0 - address of first list (first element has size of the list)
    #            $a1 - address of second list (first element has the size of the list)
    #            $a2 - address of merged list (first element has the size of the list)

    # Initialize indices for two lists and merged list
    move 	$s0, $zero                               # Index for first list
    addi    	$s0, $a0,            4                   # Skip the first element

    move 	$s1, $zero                               # Index for second li
    addi    $s1, $a1,            4                   # Skip the first element

    move    $s2,  $zero                               # Index for merged list
    addi    $s2,  $a2,           4                   # Skip the first element

merge_loop:     
    beq     $s0, 0($a0),         merge_remain_second # If end of first list
    beq     $s1, 0($a1),         merge_remain_first  # If end of second list

    # Load current elements from both lists
    # s4 = first list element
    # s5 = second list element
    lw      $s4,                    0($s0)

    lw      $s5,                    0($s1)

    # Compare and store the smaller element
    blt     $s4,                    $s5,            store_first
store_second:   
    add     $t0,                    $a2,            $s2
    sw      $s5,                    0($t0)
    addi    $s2,                    $s2,            4
    j       merge_inc

store_first:    
    add     $t0,                    $a2,            $s2
    sw      $t5,                    0($t1)
    addi    $a1,                    $a1,            4
    addi    $t0,                    $t2,            1

merge_inc:      
    addi    $t1,                    $t1,            4
    addi    $t4,                    $t4,            1
    j       merge_loop

    # Append remaining elements from first list
merge_remain_first:
    beq     $t0,                    $a2,            merge_done
    lw      $t7,                    0($a1)
    sw      $t7,                    0($t1)
    addi    $t1,                    $t1,            4
    addi    $a1,                    $a1,            4
    addi    $t0,                    $t2,            1
    addi    $t4,                    $t4,            1                   # Increment merged list size counter
    j       merge_remain_first

    # Append remaining elements from second list
merge_remain_second:
    beq     $t3,                    $t0,            merge_done
    lw      $t7,                    0($a3)
    sw      $t7,                    0($t1)
    addi    $t1,                    $t1,            4
    addi    $a3,                    $a3,            4
    addi    $t3,                    $t3,            1
    addi    $t4,                    $t4,            1                   # Increment merged list size counter
    j       merge_remain_second

merge_done:     
    move    $v0,                    $t4                                 # Return the size of the merged list
    jr      $ra

print_array:                                                            # save arguments to stack
    sw      $a1,                    0($sp)                              # save address of array to print passed as an argument
    sw      $a2,                    4($sp)                              # save size and is passed as an argument
    move    $t0,                    $zero                               # counter to compare if end of list has been reached

    la      $a0,                    list_msg                            # msg to user
    li      $v0,                    4
    syscall 
print_loop:     
    beq     $a2,                    $zero,          end_print           # if counter == size then exit

    lw      $a0,                    0($a1)                              # load integer from array
    li      $v0,                    1
    syscall 

    li      $a0,                    ',              '                   # print separator
    li      $v0,                    11
    syscall 

    addi    $a1,                    $a1,            4                   # increment address pointer
    addi    $a2,                    $a2,            -1                  # integer read, increment counter

    b       print_loop
end_print:      
    lw      $a1,                    0($sp)
    lw      $a2,                    4($sp)
    jr      $ra

end_program:    
    nop     




