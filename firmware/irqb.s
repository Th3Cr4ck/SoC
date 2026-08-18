	.file	"irqb.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.local	irq_vector
	.comm	irq_vector,12,4
	.section	.rodata
	.align	2
.LC0:
	.string	"Mismatch between q0 LSB and decoded instruction word! q0=0x"
	.align	2
.LC1:
	.string	", instr=0x"
	.align	2
.LC2:
	.string	"\n"
	.align	2
.LC3:
	.string	"------------------------------------------------------------\n"
	.align	2
.LC4:
	.string	"EBREAK instruction at 0x"
	.align	2
.LC5:
	.string	"Illegal Instruction at 0x"
	.align	2
.LC6:
	.string	": 0x"
	.align	2
.LC7:
	.string	"Bus error in Instruction at 0x"
	.align	2
.LC8:
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
	li	a5,5
	sb	a5,-17(s0)
	j	.L2
.L4:
	lbu	a5,-17(s0)
	li	a4,1
	sll	a5,a4,a5
	mv	a4,a5
	lw	a5,-56(s0)
	and	a5,a4,a5
	beq	a5,zero,.L3
	lbu	a5,-17(s0)
	addi	a5,a5,-5
	lui	a4,%hi(irq_vector)
	addi	a4,a4,%lo(irq_vector)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	beq	a5,zero,.L3
	lbu	a5,-17(s0)
	addi	a5,a5,-5
	lui	a4,%hi(irq_vector)
	addi	a4,a4,%lo(irq_vector)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a5,0(a5)
	jalr	a5
.L3:
	lbu	a5,-17(s0)
	addi	a5,a5,1
	sb	a5,-17(s0)
.L2:
	lbu	a4,-17(s0)
	li	a5,7
	bleu	a4,a5,.L4
	lw	a5,-56(s0)
	andi	a5,a5,6
	beq	a5,zero,.L5
	lw	a5,-52(s0)
	lw	a5,0(a5)
	andi	a5,a5,1
	beq	a5,zero,.L6
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-3
	sw	a5,-24(s0)
	j	.L7
.L6:
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-4
	sw	a5,-24(s0)
.L7:
	lw	a5,-24(s0)
	lhu	a5,0(a5)
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L8
	lw	a5,-24(s0)
	addi	a5,a5,2
	lhu	a5,0(a5)
	slli	a5,a5,16
	lw	a4,-28(s0)
	or	a5,a4,a5
	sw	a5,-28(s0)
.L8:
	lw	a5,-28(s0)
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
	beq	a5,zero,.L5
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	print
	lw	a5,-52(s0)
	lw	a5,0(a5)
	li	a1,8
	mv	a0,a5
	call	print_hex
	lui	a5,%hi(.LC1)
	addi	a0,a5,%lo(.LC1)
	call	print
	lw	a5,-28(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L9
	li	a1,8
	lw	a0,-28(s0)
	call	print_hex
	j	.L10
.L9:
	li	a1,4
	lw	a0,-28(s0)
	call	print_hex
.L10:
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
 #APP
# 45 "firmware/irqb.c" 1
	ebreak
# 0 "" 2
 #NO_APP
.L5:
	lw	a5,-56(s0)
	andi	a5,a5,6
	beq	a5,zero,.L11
	lw	a5,-52(s0)
	lw	a5,0(a5)
	andi	a5,a5,1
	beq	a5,zero,.L12
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-3
	sw	a5,-32(s0)
	j	.L13
.L12:
	lw	a5,-52(s0)
	lw	a5,0(a5)
	addi	a5,a5,-4
	sw	a5,-32(s0)
.L13:
	lw	a5,-32(s0)
	lhu	a5,0(a5)
	sw	a5,-36(s0)
	lw	a5,-36(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L14
	lw	a5,-32(s0)
	addi	a5,a5,2
	lhu	a5,0(a5)
	slli	a5,a5,16
	lw	a4,-36(s0)
	or	a5,a4,a5
	sw	a5,-36(s0)
.L14:
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
	lui	a5,%hi(.LC3)
	addi	a0,a5,%lo(.LC3)
	call	print
	lw	a5,-56(s0)
	andi	a5,a5,2
	beq	a5,zero,.L15
	lw	a4,-36(s0)
	li	a5,1048576
	addi	a5,a5,115
	beq	a4,a5,.L16
	lw	a4,-36(s0)
	li	a5,36864
	addi	a5,a5,2
	bne	a4,a5,.L17
.L16:
	lui	a5,%hi(.LC4)
	addi	a0,a5,%lo(.LC4)
	call	print
	li	a1,8
	lw	a0,-32(s0)
	call	print_hex
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
	j	.L15
.L17:
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	print
	li	a1,8
	lw	a0,-32(s0)
	call	print_hex
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	print
	lw	a5,-36(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L18
	li	a5,8
	j	.L19
.L18:
	li	a5,4
.L19:
	mv	a1,a5
	lw	a0,-36(s0)
	call	print_hex
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
.L15:
	lw	a5,-56(s0)
	andi	a5,a5,4
	beq	a5,zero,.L11
	lui	a5,%hi(.LC7)
	addi	a0,a5,%lo(.LC7)
	call	print
	li	a1,8
	lw	a0,-32(s0)
	call	print_hex
	lui	a5,%hi(.LC6)
	addi	a0,a5,%lo(.LC6)
	call	print
	lw	a5,-36(s0)
	andi	a4,a5,3
	li	a5,3
	bne	a4,a5,.L20
	li	a5,8
	j	.L21
.L20:
	li	a5,4
.L21:
	mv	a1,a5
	lw	a0,-36(s0)
	call	print_hex
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
.L11:
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	print
	li	a1,8
	lw	a0,-56(s0)
	call	print_hex
	lui	a5,%hi(.LC2)
	addi	a0,a5,%lo(.LC2)
	call	print
	lw	a5,-52(s0)
	mv	a0,a5
	lw	ra,60(sp)
	lw	s0,56(sp)
	addi	sp,sp,64
	jr	ra
	.size	irq, .-irq
	.align	2
	.globl	irq_register_handler
	.type	irq_register_handler, @function
irq_register_handler:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	mv	a5,a0
	sw	a1,-24(s0)
	sb	a5,-17(s0)
	lbu	a5,-17(s0)
	addi	a5,a5,-5
	seqz	a5,a5
	andi	a4,a5,0xff
	lbu	a5,-17(s0)
	addi	a5,a5,-6
	seqz	a5,a5
	andi	a5,a5,0xff
	or	a5,a4,a5
	andi	a5,a5,0xff
	bne	a5,zero,.L24
	lbu	a4,-17(s0)
	li	a5,7
	bne	a4,a5,.L26
.L24:
	lbu	a5,-17(s0)
	addi	a5,a5,-5
	lui	a4,%hi(irq_vector)
	addi	a4,a4,%lo(irq_vector)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a4,-24(s0)
	sw	a4,0(a5)
.L26:
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	irq_register_handler, .-irq_register_handler
	.ident	"GCC: (g6afcc4f6d) 16.1.0"
	.section	.note.GNU-stack,"",@progbits
