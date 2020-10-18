STACK_SIZE = 1000
.file  1 "task.s"
.section .mdebug.abi32
.previous
.nan legacy
.gnu_attribute 4,3
.text

### Yield and switch to another task.

.align 2
.globl _taskYield
.set nomips16
.set nomicromips
.ent _taskYield
.type _taskYield, @function

_taskYield:

.frame   $sp,0,$31
.mask    0x00000000,0
.fmask   0x00000000,0
.set     noreorder
.set     nomacro
.set     noat

### Save all registers to stack

addiu    $sp,$sp,(-40)
sw       $16,0($sp)
sw       $17,4($sp)
sw       $18,8($sp)
sw       $19,12($sp)
sw       $20,16($sp)
sw       $21,20($sp)
sw       $22,24($sp)
sw       $23,28($sp)
sw       $30,32($sp)
sw       $31,36($sp)

# Switch task to the other one 

sw       $29,0($27)
xori     $27,$27,4
lw       $29,0($27)
xori     $26,$26,1

# Restore all registers from stack

lw       $16,0($sp)
lw       $17,4($sp)
lw       $18,8($sp)
lw       $19,12($sp)
lw       $20,16($sp)
lw       $21,20($sp)
lw       $22,24($sp)
lw       $23,28($sp)
lw       $30,32($sp)
lw       $31,36($sp)
addiu    $sp,$sp,(40)
j        $31
nop
.set     macro
.set     reorder
.end     _taskYield
.size    _taskYield, .-_taskYield
.align   2

#### Launch a task #####

.globl   _taskSpawn
.set     nomips16
.set     nomicromips
.ent     _taskSpawn
.type    _taskSpawn, @function

_taskSpawn:

.frame   $sp,0,$31
.mask    0x00000000,0
.fmask   0x00000000,0
.set     noreorder
.set     nomacro

lui      $26,0
addiu    $27,$28,%gp_rel(task_sp)
lui      $3,%hi(task_stack+STACK_SIZE-4)
addiu    $3,$3,%lo(task_stack+STACK_SIZE-4)
addiu    $3,$3,(-40)
sw       $16,0($3)
sw       $17,4($3)
sw       $18,8($3)
sw       $19,12($3)
sw       $20,16($3)
sw       $21,20($3)
sw       $22,24($3)
sw       $23,28($3)
sw       $30,32($3)
sw       $4,36($3)
sw       $3,%gp_rel(task_sp+4)($28)
j        $31
nop
.set     macro
.set     reorder
.set     noat
.end     _taskSpawn
.size    _taskSpawn, .-_taskSpawn
.comm    task_stack,STACK_SIZE,4
.comm    task_sp,8,8
.ident   "GCC: (GNU) 4.9.0"
