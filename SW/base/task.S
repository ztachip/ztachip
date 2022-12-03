#----------------------------------------------------------------------------
# Copyright [2014] [Ztachip Technologies Inc]
#
# Author: Vuong Nguyen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except IN compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to IN writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#------------------------------------------------------------------------------

    STACK_SIZE=2048
    .file "task.s"
    .option nopic
    .attribute arch,"rv32i2p0_m2p0"
    .attribute unaligned_access, 0
    .attribute stack_align, 16
    .text
    .align 2
    .globl _taskYield
    .type _taskYield, @function

############################################
# Switch task
############################################

_taskYield:
    addi     sp,sp,(-64)
    sw       ra,0(sp)
    sw       s0,4(sp)
    sw       s1,8(sp)
    sw       s2,12(sp)
    sw       s3,16(sp)
    sw       s4,20(sp)
    sw       s5,24(sp)
    sw       s6,28(sp)
    sw       s7,32(sp)
    sw       s8,36(sp)
    sw       s9,40(sp)
    sw       s10,44(sp)
    sw       s11,48(sp)

    addi     t0,sp,0
    addi     sp,tp,0
    addi     tp,t0,0

    lw       ra,0(sp)
    lw       s0,4(sp)
    lw       s1,8(sp)
    lw       s2,12(sp)
    lw       s3,16(sp)
    lw       s4,20(sp)
    lw       s5,24(sp)
    lw       s6,28(sp)
    lw       s7,32(sp)
    lw       s8,36(sp)
    lw       s9,40(sp)
    lw       s10,44(sp)
    lw       s11,48(sp)
    addi     sp,sp,(64)
    jr       ra
    .size _taskYield, .-_taskYield
    .align 2

###############################
# Launch a task
###############################

    .globl _taskSpawn
    .type _taskSpawn, @function
_taskSpawn:
    lui      t1,%hi(task_sp)
    addi     t1,t1,%lo(task_sp)
    addi     t0,sp,0
    addi     t0,t0,-STACK_SIZE
    addi     tp,t0,0
    sw       a0,0(t0)
    sw       s0,4(t0)
    sw       s1,8(t0)
    sw       s2,12(t0)
    sw       s3,16(t0)
    sw       s4,20(t0)
    sw       s5,24(t0)
    sw       s6,28(t0)
    sw       s7,32(t0)
    sw       s8,36(t0)
    sw       s9,40(t0)
    sw       s10,44(t0)
    sw       s11,48(t0)
    sw       t0,4(t1)
    jr       ra
    .size _taskSpawn, .-_taskSpawn
    .comm task_sp,8,8
    .ident "GCC: (GNU) 10.2.0"
