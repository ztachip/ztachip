	.file	1 "test.c"
	.section .mdebug.abi32
	.previous
	.text
	.align	2
	.globl	foo
	.ent	foo
foo:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-8
	sw	$fp,0($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	lw	$2,8($fp)
	nop
	sw	$2,%gp_rel(x)($28)
	move	$sp,$fp
	lw	$fp,0($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	foo
	.size	foo, .-foo

	.comm	x,4,4
	.ident	"GCC: (GNU) 4.1.1"
