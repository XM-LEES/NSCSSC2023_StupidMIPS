### 所有支持的指令及格式：

```
#跳转
beq
bgtz				if rs>0 then branch
bgez				if rs≥0 then branch
bne					bne   $v0, $v1, loop	#loop不需要知道offset是多少，只作为标签

j		转移到新的指令地址，其中新指令地址的低28位是指令中的target（也就是上图中的instr_index）左移两位的值，新指令地址的高4位是跳转指令后面延迟槽指令的地址高4位
jal		jal还要将跳转指令后面第2条指令的地址作为返回地址保存到寄存器$31
jr				    jr    $ra	一般用不着

lui					lui   $a0, 0x8040		#a0 = 0x80400000 高16位，常用来加载地址

#基本的逻辑运算
andi				andi   $t0, $zero, 0x1
ori					ori   $t0, $zero, 0x1	加载寄存器参数
					ori   $t0, $t1, 0x0     # t0 = t1
xori				xori   $t0, $zero, 0x1

and					and    $a2, $a0, $a2
or					or  $t0, $t0, $s1
xor					xor $t0, $t0, $s3


# 基本的算数运算
addiu				$a0, $a0, 4     # a0 += 4	加寄存器和立即数
addu				addu  $t2, $t0, $t1   # t2 = t0+t1	加两个寄存器
mul					mul   $t5, $t7, $t5		乘法 保存低32位


# 访存相关
lb					lb    $a0, 0($s0)
sb					sb    $a0, 0x03F8($s1)
lw					lw    $t3, 0($a0)
sw					sw    $t1, 0($a0)



sll					sll    $t0, $v1, 2
将地址为rt(v0)的通用寄存器的值向左移sa(2)位，空出来的位置使用0填充，结果保存到地址为rd(t0)的通用寄存器中
srl




程序执行完加这么一段防止乱飞
end:
    bne   $s1, $zero, end
    ori   $zero, $zero, 0   # noop
```









```
题目：a mod b 给定32位非负整数a、b，计算a mod b，即a对b取模，其中a>=0，b>0，结果为4字节无符号整型。
示例： 0x9%0x3=0; 0x9%0x2=1; 0x2A3495AF%0x4CD267FF=0x2A3495AF; 0%0x21587853=0
规定： 测试中给出三个数组地址A、B、C。你需要计算A[i] % B[i]，并将结果存到C[i]，直到将数组计算完 A地址为0x80400000，B地址为0x80500000，C地址为0x80600000，数组长度均为0x100000字节，共0x40000个4字节无符号数。 即A的范围是0x80400000-0x804fffff；B是0x80500000-0x805fffff；C是0x80600000-0x806fffff 示例若0x80400000处4字节无符号数值为9，0x80500000处4字节无符号数值为2，则将1写入80600000开始的4个字节，以此类推
提示： 测试数据为随机数据，所以结果只能通过计算得到 有多种方法完成题目，可以通过现有指令代替没有的指令，也可以现场增加指令
提交说明
实现汇编程序完成指定要求，汇编程序写在仓库根目录下asm文件夹内的user-sample.s文件里，汇编程序最后的jr ra指令不要更改，最后标记 最终版本。
user-sample.s文件里提供了一个模板汇编程序，这段程序的功能是计算斐波那契数并存入SRAM
汇编程序的运行流程：写好的程序提交到ci后自动编译，平台测试时先用监控程序加载汇编程序，然后跳转到汇编程序处运行，最后检查结果。
允许更改硬件设计，保证独立完成设计即可。如果thinpad_top.srcs下的文件没有变动，Gitlab平台不会生成新的bit可以节省时间。
SysErr:系统执行你的程序时出错或超时，注意越界、死循环、变量复用等问题
比赛分数:未通过测试0分，通过测试的按执行时间映射到[50,100]，最短时间为100分，最长时间为50分
测试要求
虚拟内存空间为0x80000000～0x807FFFFF，共8MB，要求整个内存空间均可读可写可执行。其中
0x80000000～0x803FFFFF映射到BaseRAM；
0x80400000～0x807FFFFF映射到ExtRAM。
CPU字节序为小端序。
CPU时钟使用外部时钟输入，50MHz / 11MHz两路时钟输入均可使用。
在复位按钮按下时（高电平）CPU处于复位状态，松开后解除。
CPU复位后从0x80000000开始取指令执行。
```











### for循环

```
.for_loop:

    # $a0 - Start value
    # $a1 - End value
    
    ori   $t0, $zero, 0x100 # t0 = 0x100		length
    lui   $a0, 0x8040       # a0 = 0x80400000	Start
    addu  $a1, $a0, $t0     # a1 = 0x80400100 	end
    ori   $s1, $zero, 0x4   # s1 = 4


	ori   $t1, $a0, 0x0

loop:
	#
    # Loop body
    # $t1 as loop counter
	#


	bne   $t1, $t3, end
    ori   $zero, $zero, 0   # noop
    addu  $a0, $a0, $s1     # a0 += 4
    beq   $t1, $a1, end   	# if loop counter == end value, exit loop
    ori   $zero, $zero, 0   # noop

end:
    bne   $s1, $zero, end
    ori   $zero, $zero, 0   # noop
```

### 冒泡排序

```
.bubble_sort:

    # $a0 - Base address of the array
    # $a1 - End (or Array length)

    ori   $t0, $a1, 0x0          # Initialize outer loop counter

outer_loop:
    ori   $t1, $t0, 0x0          # Initialize inner loop counter

inner_loop:
    lw      $t3, 0($t2)      # Load current element
    lw      $t4, 4($t2)      # Load next element

    bge     $t3, $t4, skip_swap    # If current element >= next element, skip swap

    sw      $t4, 0($t2)      # Swap current element and next element
    sw      $t3, 4($t2)


	addu  $a0, $a0, $s1     #0x4     # a0 += 4
    beq   $t1, $a1, outer_increment   	# if inner loop counter == end value, exit inner loop
    ori   $zero, $zero, 0   # noop





    addu  $a0, $a0, $s1     #0x4     # a0 += 4
    beq   $t0, $a1, end   	# if outer loop counter == end value, exit loop
    ori   $zero, $zero, 0   # noop



skip_swap:
    addiu   $t1, $t1, 1     # Increment inner loop counter
    j       inner_loop

outer_increment:
    addiu   $t0, $t0, 1     # Increment outer loop counter
    j       outer_loop



end:
    bne   $s1, $zero, end
    ori   $zero, $zero, 0   # noop
```



### 二分查找

```
.binary_search:
    # $a0 - Base address of the array
    # $a1 - End (or Array length)
    # $a2 - Search key

	#...
	#...
	#...

    ori   $t0, $a1, 0x0     # left index
    ori   $t1, $a2, 0x0      # right index

loop:
    bge     $t0, $t1, not_found   # If left index >= right index, exit loop

    addu    $t2, $t0, $t1    # Calculate mid = (left + right) / 2
    srl     $t2, $t2, 1

    sll     $t3, $t2, 2      # Calculate byte offset = mid * 4
    addu    $t3, $t3, $a0

    lw      $t4, 0($t3)      # Load value at mid

    bne     $t4, $a2, adjust_indices  # If value != search key, adjust indices
    move    $v0, $t2         # If value == search key, return mid
    jr      $ra

adjust_indices:
    bgt     $t4, $a2, decrease_right   # If value > search key, decrease right index
    addiu   $t0, $t2, 1      # If value < search key, increase left index
    j       loop

decrease_right:
    addiu   $t1, $t2, -1     # Decrease right index
    j       loop

not_found:
    li      $v0, -1          # Return -1 if not found
    jr      $ra

```



### 递归

```
.recursive_factorial:
    # Input:
    # $a0 - Input value (n)

    # Base case: factorial(0) = 1
    beq     $a0, $zero, factorial_one

    # Recursive case: factorial(n) = n * factorial(n - 1)
    addiu   $sp, $sp, -4     # Allocate space on the stack
    sw      $ra, 0($sp)      # Save return address

    addiu   $a0, $a0, -1     # n - 1
    jal     .recursive_factorial   # Recursive call
    mul     $v0, $v0, $a0    # n * factorial(n - 1)

    lw      $ra, 0($sp)      # Restore return address
    addiu   $sp, $sp, 4      # Deallocate space on the stack
    jr      $ra

factorial_one:
    li      $v0, 1           # Return 1 for factorial(0)
    jr      $ra

```

















































































```
.binary_search:
    # Input:
    # $a0 - Base address of the array
    # $a1 - Array length
    # $a2 - Search key

    li      $t0, 0          # Initialize left index
    move    $t1, $a1        # Initialize right index

loop:
    bge     $t0, $t1, not_found   # If left index >= right index, exit loop

    addu    $t2, $t0, $t1    # Calculate mid = (left + right) / 2
    srl     $t2, $t2, 1

    sll     $t3, $t2, 2      # Calculate byte offset = mid * 4
    addu    $t3, $t3, $a0

    lw      $t4, 0($t3)      # Load value at mid

    bne     $t4, $a2, adjust_indices  # If value != search key, adjust indices
    move    $v0, $t2         # If value == search key, return mid
    jr      $ra

adjust_indices:
    bgt     $t4, $a2, decrease_right   # If value > search key, decrease right index
    addiu   $t0, $t2, 1      # If value < search key, increase left index
    j       loop

decrease_right:
    addiu   $t1, $t2, -1     # Decrease right index
    j       loop

not_found:
    li      $v0, -1          # Return -1 if not found
    jr      $ra

```





```
.for_loop:
    # Input:
    # $a0 - Start value
    # $a1 - End value

    move    $t0, $a0        # Initialize loop counter with start value

loop:
    bgt     $t0, $a1, end_loop   # If loop counter > end value, exit loop

    # Loop body here
    # Perform operations using $t0 as the loop counter

    addiu   $t0, $t0, 1      # Increment loop counter
    j       loop

end_loop:
    # Loop finished
    jr      $ra

```





```
.recursive_factorial:
    # Input:
    # $a0 - Input value (n)

    # Base case: factorial(0) = 1
    beq     $a0, $zero, factorial_one

    # Recursive case: factorial(n) = n * factorial(n - 1)
    addiu   $sp, $sp, -4     # Allocate space on the stack
    sw      $ra, 0($sp)      # Save return address

    addiu   $a0, $a0, -1     # n - 1
    jal     .recursive_factorial   # Recursive call
    mul     $v0, $v0, $a0    # n * factorial(n - 1)

    lw      $ra, 0($sp)      # Restore return address
    addiu   $sp, $sp, 4      # Deallocate space on the stack
    jr      $ra

factorial_one:
    li      $v0, 1           # Return 1 for factorial(0)
    jr      $ra

```



```
.bubble_sort:
    # Input:
    # $a0 - Base address of the array
    # $a1 - Array length

    li      $t0, 0          # Initialize outer loop counter with 0

outer_loop:
    bge     $t0, $a1, done_sort   # If outer loop counter >= array length, exit loop

    li      $t1, 0          # Initialize inner loop counter with 0

inner_loop:
    bge     $t1, $a1, outer_increment   # If inner loop counter >= array length, exit inner loop

    sll     $t2, $t1, 2     # Calculate byte offset = inner loop counter * 4
    addu    $t2, $t2, $a0

    lw      $t3, 0($t2)      # Load current element
    lw      $t4, 4($t2)      # Load next element

    bge     $t3, $t4, skip_swap    # If current element >= next element, skip swap

    sw      $t4, 0($t2)      # Swap current element and next element
    sw      $t3, 4($t2)

skip_swap:
    addiu   $t1, $t1, 1     # Increment inner loop counter
    j       inner_loop

outer_increment:
    addiu   $t0, $t0, 1     # Increment outer loop counter
    j       outer_loop

done_sort:
    jr      $ra

```

