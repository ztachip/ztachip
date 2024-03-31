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

    .file "setjmp.s"
    .option nopic
    .attribute arch,"rv32i2p0_m2p0"
    .attribute unaligned_access, 0
    .attribute stack_align, 16
    .text
    .align 2

    .globl setjmp
    .type setjmp, @function

setjmp:
                 sw    ra,0(a0)
                 sw    s0,4(a0)
                 sw    s1,8(a0)
                 sw    s2,12(a0)
                 sw    s3,16(a0)
                 sw    s4,20(a0)
                 sw    s5,24(a0)
                 sw    s6,28(a0)
                 sw    s7,32(a0)
                 sw    s8,36(a0)
                 sw    s9,40(a0)
                 sw    s10,44(a0)
                 sw    s11,48(a0)
                 sw    sp,52(a0)
                 li    a0,0
                 ret
    .size setjmp, .-setjmp
    .align 2


    .globl longjmp
    .type longjmp, @function

longjmp:
                lw        ra,0(a0)
                lw        s0,4(a0)
                lw        s1,8(a0)
                lw        s2,12(a0)
                lw        s3,16(a0)
                lw        s4,20(a0)
                lw        s5,24(a0)
                lw        s6,28(a0)
                lw        s7,32(a0)
                lw        s8,36(a0)
                lw        s9,40(a0)
                lw        s10,44(a0)
                lw        s11,48(a0)
                lw        sp,52(a0)
                seqz      a0,a1
                add       a0,a0,a1
                ret
    .size longjmp, .-longjmp

    .ident "GCC: (GNU) 10.2.0"
