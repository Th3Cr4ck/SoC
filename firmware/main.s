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
	li	a5,1342185472
	li	a4,104
	sw	a4,0(a5)
	call	test_pwm
	call	test_gpio
	call	test_cordic
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
	sb	zero,-17(s0)
	sw	zero,-24(s0)
	li	a0,0
	call	id00005010_init
	mv	a5,a0
	sw	a5,-24(s0)
	li	a1,8
	lw	a0,-24(s0)
	call	print_hex
	li	a0,10
	call	putchar
	li	a0,2
	call	id00005010_set_prescaler
	li	a0,100
	call	id00005010_set_period
	li	a0,30
	call	id00005010_set_duty
	li	a0,1
	call	id00005010_set_polarity
	call	id00005010_enable
	lbu	a5,-17(s0)
	bne	a5,zero,.L4
	li	a5,1
	sb	a5,-17(s0)
	call	id00005010_startIP
.L4:
	li	a0,100
	li	a1,0
	call	delay
	li	a0,75
	call	id00005010_set_duty
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	test_pwm, .-test_pwm
	.section	.rodata
	.align	2
.LC0:
	.string	"IDR:"
	.align	2
.LC1:
	.string	"ODR:"
	.text
	.align	2
	.globl	test_gpio
	.type	test_gpio, @function
test_gpio:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a0,1
	call	id00005020_init
	mv	a5,a0
	sw	a5,-20(s0)
	li	a1,8
	lw	a0,-20(s0)
	call	print_hex
	li	a0,10
	call	putchar
	li	a5,65536
	addi	a0,a5,-256
	call	id00005020_set_iomode
	li	a5,49152
	addi	a0,a5,-337
	call	id00005020_set_odr
	li	a0,100
	li	a1,0
	call	delay
	addi	a5,s0,-22
	mv	a0,a5
	call	id00005020_get_idr
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	print
	lhu	a5,-22(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	addi	a5,s0,-24
	mv	a0,a5
	call	id00005020_get_odr
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lhu	a5,-24(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	li	a0,256
	call	id00005020_bsrr_set
	addi	a5,s0,-22
	mv	a0,a5
	call	id00005020_get_idr
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	print
	lhu	a5,-22(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	addi	a5,s0,-24
	mv	a0,a5
	call	id00005020_get_odr
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lhu	a5,-24(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	li	a0,100
	li	a1,0
	call	delay
	li	a5,53248
	addi	a0,a5,-1282
	call	id00005020_set_odr
	addi	a5,s0,-22
	mv	a0,a5
	call	id00005020_get_idr
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	print
	lhu	a5,-22(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	addi	a5,s0,-24
	mv	a0,a5
	call	id00005020_get_odr
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lhu	a5,-24(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	test_gpio, .-test_gpio
	.section	.rodata
	.align	2
.LC2:
	.string	"\nX="
	.align	2
.LC3:
	.string	"Y="
	.align	2
.LC4:
	.string	"Z="
	.align	2
.LC5:
	.string	"X="
	.text
	.align	2
	.globl	test_cordic
	.type	test_cordic, @function
test_cordic:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a0,2
	call	id00005030_init
	mv	a5,a0
	sw	a5,-20(s0)
	li	a1,8
	lw	a0,-20(s0)
	call	print_hex
	li	a0,10
	call	putchar
	li	a3,1
	li	a2,804
	li	a1,0
	li	a0,1024
	call	id00005030_cordic_process
	addi	a3,s0,-32
	addi	a4,s0,-28
	addi	a5,s0,-24
	mv	a2,a3
	mv	a1,a4
	mv	a0,a5
	call	id00005030_read_results
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
	lw	a5,-24(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	print
	lw	a5,-28(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	print
	lw	a5,-32(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	li	a0,100
	li	a1,0
	call	delay
	li	a3,0
	li	a2,0
	li	a1,1024
	li	a0,1024
	call	id00005030_cordic_process
	addi	a3,s0,-32
	addi	a4,s0,-28
	addi	a5,s0,-24
	mv	a2,a3
	mv	a1,a4
	mv	a0,a5
	call	id00005030_read_results
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	print
	lw	a5,-24(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	print
	lw	a5,-28(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	print
	lw	a5,-32(s0)
	li	a1,4
	mv	a0,a5
	call	print_hex
	li	a0,10
	call	putchar
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	test_cordic, .-test_cordic
	.align	2
	.globl	delay_ms
	.type	delay_ms, @function
delay_ms:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	lw	a5,-36(s0)
	addi	a3,a5,-1
	mv	a4,a3
	slli	a5,a4,5
	mv	a4,a5
	sub	a4,a4,a3
	slli	a5,a4,6
	sub	a5,a5,a4
	slli	a5,a5,3
	add	a5,a5,a3
	slli	a5,a5,6
	li	a1,820
	mv	a0,a5
	call	__udivsi3
	mv	a5,a0
	sw	a5,-24(s0)
	sw	zero,-20(s0)
	lw	a0,-24(s0)
	lw	a1,-20(s0)
	call	delay
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	delay_ms, .-delay_ms
	.align	2
	.globl	delay
	.type	delay, @function
delay:
	addi	sp,sp,-48
	sw	ra,44(sp)
	sw	s0,40(sp)
	addi	s0,sp,48
	sw	a0,-40(s0)
	sw	a1,-36(s0)
	sw	zero,-20(s0)
	j	.L9
.L10:
 #APP
# 154 "firmware/main.c" 1
	nop
# 0 "" 2
 #NO_APP
	lw	a3,-20(s0)
	addi	a3,a3,1
	sw	a3,-20(s0)
.L9:
	lw	a3,-20(s0)
	mv	a4,a3
	srai	a3,a3,31
	mv	a5,a3
	lw	a3,-36(s0)
	mv	a2,a5
	bgtu	a3,a2,.L10
	lw	a3,-36(s0)
	mv	a2,a5
	bne	a3,a2,.L12
	lw	a3,-40(s0)
	mv	a2,a4
	bgtu	a3,a2,.L10
.L12:
	nop
	lw	ra,44(sp)
	lw	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	delay, .-delay
	.globl	__udivsi3
	.ident	"GCC: (g6afcc4f6d) 16.1.0"
	.section	.note.GNU-stack,"",@progbits
