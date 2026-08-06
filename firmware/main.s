	.file	"main.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	li	a5,-2147479552
	addi	a5,a5,8
	li	a4,31
	sw	a4,0(a5)
	li	a5,-2147479552
	lw	a5,0(a5)
	sw	a5,-28(s0)
	li	a5,-2147479552
	addi	a5,a5,8
	li	a4,1
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	sw	zero,0(a5)
	li	a5,-2147479552
	addi	a5,a5,8
	sw	zero,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	li	a4,655360
	addi	a4,a4,2
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	li	a4,196608
	addi	a4,a4,2
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,12
	li	a4,1
	sw	a4,0(a5)
	sw	zero,-20(s0)
	j	.L2
.L3:
 #APP
# 30 "firmware/main.c" 1
	nop
# 0 "" 2
 #NO_APP
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,1999
	ble	a4,a5,.L3
	li	a5,-2147479552
	addi	a5,a5,12
	li	a4,1
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,8
	li	a4,1
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	sw	zero,0(a5)
	li	a5,-2147479552
	addi	a5,a5,8
	sw	zero,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	li	a4,524288
	addi	a4,a4,3
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,4
	li	a4,196608
	addi	a4,a4,6
	sw	a4,0(a5)
	li	a5,-2147479552
	addi	a5,a5,12
	li	a4,1
	sw	a4,0(a5)
	sw	zero,-24(s0)
	j	.L4
.L5:
 #APP
# 43 "firmware/main.c" 1
	nop
# 0 "" 2
 #NO_APP
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L4:
	lw	a4,-24(s0)
	li	a5,1999
	ble	a4,a5,.L5
	li	a5,0
	mv	a0,a5
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g6afcc4f6d) 16.1.0"
	.section	.note.GNU-stack,"",@progbits
