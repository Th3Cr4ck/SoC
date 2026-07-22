	.file	"irqb.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	2
.LC0:
	.string	" IRQ 7 -- Start Ipcore"
	.align	2
.LC1:
	.string	"\n"
	.align	2
.LC2:
	.string	"Mismatch between q0 LSB and decoded instruction word! q0=0x"
	.align	2
.LC3:
	.string	", instr=0x"
	.align	2
.LC4:
	.string	"------------------------------------------------------------\n"
	.align	2
.LC5:
	.string	"EBREAK instruction at 0x"
	.align	2
.LC6:
	.string	"Illegal Instruction at 0x"
	.align	2
.LC7:
	.string	": 0x"
	.align	2
.LC8:
	.string	"Bus error in Instruction at 0x"
	.align	2
.LC9:
	.string	"irqs: "
	.text
	.align	2
	.globl	irq
	.type	irq, @function
irq:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	addi	s0,sp,64
	sw	a0,-52(s0)
	sw	a1,-56(s0)
	lw	a5,-56(s0)
	andi	a5,a5,7
	beq	a5,zero,.L2
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	print
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
.L2:
	lw	a5,-56(s0)
	andi	a5,a5,6
	beq	a5,zero,.L3
	lw	a5,-52(s0)
	lw	a5,0(a5)
	andi	a5,a5,1
	beq	a5,zero,.L4
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-3
	sw	a5,-20(s0)
	j	.L5
.L4:
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-4
	sw	a5,-20(s0)
.L5:
	lw	a5,-20(s0)
	lhu	a5,0(a5)
	sw	a5,-24(s0)
	lw	a5,-24(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L6
	lw	a5,-20(s0)
	addi	a5,a5,2
	lhu	a5,0(a5)
	slli	a5,a5,16
	lw	a4,-24(s0)
	or	a5,a4,a5
	sw	a5,-24(s0)
.L6:
	lw	a5,-24(s0)
	andi	a5,a5,3
	addi	a5,a5,-3
	snez	a5,a5
	andi	a4,a5,0xff
	lw	a5,-52(s0)
	lw	a5,0(a5)
	andi	a5,a5,1
	andi	a5,a5,0xff
	xor	a5,a4,a5
	andi	a5,a5,0xff
	beq	a5,zero,.L3
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
	lw	a5,-52(s0)
	lw	a5,0(a5)
	li	a1,8
	mv	a0,a5
	call	print_hex
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	print
	lw	a5,-24(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L7
	li	a1,8
	lw	a0,-24(s0)
	call	print_hex
	j	.L8
.L7:
	li	a1,4
	lw	a0,-24(s0)
	call	print_hex
.L8:
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
 #APP
# 35 "firmware/irqb.c" 1
	ebreak
# 0 "" 2
 #NO_APP
.L3:
	lw	a5,-56(s0)
	andi	a5,a5,6
	beq	a5,zero,.L9
	lw	a5,-52(s0)
	lw	a5,0(a5)
	andi	a5,a5,1
	beq	a5,zero,.L10
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-3
	sw	a5,-28(s0)
	j	.L11
.L10:
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-4
	sw	a5,-28(s0)
.L11:
	lw	a5,-28(s0)
	lhu	a5,0(a5)
	sw	a5,-32(s0)
	lw	a5,-32(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L12
	lw	a5,-28(s0)
	addi	a5,a5,2
	lhu	a5,0(a5)
	slli	a5,a5,16
	lw	a4,-32(s0)
	or	a5,a4,a5
	sw	a5,-32(s0)
.L12:
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	print
	lw	a5,-56(s0)
	andi	a5,a5,2
	beq	a5,zero,.L13
	lw	a4,-32(s0)
	li	a5,1048576
	addi	a5,a5,115
	beq	a4,a5,.L14
	lw	a4,-32(s0)
	li	a5,36864
	addi	a5,a5,2
	bne	a4,a5,.L15
.L14:
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	print
	li	a1,8
	lw	a0,-28(s0)
	call	print_hex
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	j	.L13
.L15:
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	print
	li	a1,8
	lw	a0,-28(s0)
	call	print_hex
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	print
	lw	a5,-32(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L16
	li	a5,8
	j	.L17
.L16:
	li	a5,4
.L17:
	mv	a1,a5
	lw	a0,-32(s0)
	call	print_hex
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
.L13:
	lw	a5,-56(s0)
	andi	a5,a5,4
	beq	a5,zero,.L9
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	print
	li	a1,8
	lw	a0,-28(s0)
	call	print_hex
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	print
	lw	a5,-32(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L18
	li	a5,8
	j	.L19
.L18:
	li	a5,4
.L19:
	mv	a1,a5
	lw	a0,-32(s0)
	call	print_hex
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
.L24:
	li	a5,-2130706432
	lw	a5,0(a5)
	bne	a5,zero,.L20
	li	a5,-2130706432
	li	a4,1
	sw	a4,0(a5)
	j	.L21
.L20:
	li	a5,-2130706432
	sw	zero,0(a5)
.L21:
	li	a5,200
	sw	a5,-36(s0)
	j	.L22
.L23:
 #APP
# 79 "firmware/irqb.c" 1
	nop
# 0 "" 2
 #NO_APP
	lw	a5,-36(s0)
	addi	a5,a5,-1
	sw	a5,-36(s0)
.L22:
	lw	a5,-36(s0)
	bgt	a5,zero,.L23
	j	.L24
.L9:
	lui	a5,%hi(.LC9)
	addi	a0,a5,%lo(.LC9)
	call	print
	li	a1,8
	lw	a0,-56(s0)
	call	print_hex
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lw	a5,-52(s0)
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	irq, .-irq
	.ident	"GCC: (g6afcc4f6d) 16.1.0"
	.section	.note.GNU-stack,"",@progbits
