	.file	"main.s"
    .section .text
    .globl main

main:
  li t1, 0x81100000 # Direccion del periferico
  li t2, 255

restart:
  mv x28, t2

count:	
  addi x28, x28, -1 
  sw x28, 0(t1)
  beq x28, x0, restart
  j	count
