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
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	sw	a1,-24(s0)
	call	test_pwm
	call	test_gpio
	li	a5,0
	mv	a0,a5
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.align	2
	.globl	test_pwm
	.type	test_pwm, @function
test_pwm:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,-2147479552
	addi	a5,a5,8
	li	a4,31
	sw	a4,0(a5)
	li	a5,-2147479552
	lw	a5,0(a5)
	sw	a5,-20(s0)
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
	li	a0,200
	call	delay
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
	li	a0,200
	call	delay
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	test_pwm, .-test_pwm
	.align	2
	.globl	test_gpio
	.type	test_gpio, @function
test_gpio:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,-2147475456
	addi	a5,a5,8
	li	a4,31
	sw	a4,0(a5)
	li	a5,-2147475456
	lw	a5,0(a5)
	sw	a5,-20(s0)
	li	a5,-2147475456
	addi	a5,a5,8
	li	a4,3
	sw	a4,0(a5)
	li	a5,-2147475456
	addi	a5,a5,4
	sw	zero,0(a5)
	li	a5,-2147475456
	addi	a5,a5,8
	li	a4,2
	sw	a4,0(a5)
	li	a5,-2147475456
	addi	a5,a5,4
	li	a4,49152
	addi	a4,a4,-337
	sw	a4,0(a5)
	li	a5,-2147475456
	addi	a5,a5,4
	li	a4,65536
	addi	a4,a4,-256
	sw	a4,0(a5)
	li	a0,200
	call	delay
	li	a5,-2147475456
	addi	a5,a5,8
	li	a4,1
	sw	a4,0(a5)
	li	a5,-2147475456
	addi	a5,a5,4
	sw	zero,0(a5)
	li	a5,-2147475456
	addi	a5,a5,8
	sw	zero,0(a5)
	li	a5,-2147475456
	lw	a5,0(a5)
	sw	a5,-24(s0)
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	test_gpio, .-test_gpio
	.align	2
	.globl	delay
	.type	delay, @function
delay:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L6
.L7:
 #APP
# 88 "firmware/main.c" 1
	nop
# 0 "" 2
 #NO_APP
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L6:
	lw	a5,-20(s0)
	lw	a4,-36(s0)
	bgtu	a4,a5,.L7
	nop
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	delay, .-delay
	.ident	"GCC: (g6afcc4f6d) 16.1.0"
	.section	.note.GNU-stack,"",@progbits
