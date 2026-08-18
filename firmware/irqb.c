// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

#define NUM_IRQS 3
#define IRQ5 5
#define IRQ6 6
#define IRQ7 7

static irq_handler_t irq_vector[NUM_IRQS] = {0};

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
   for (uint8_t i = IRQ5; i <= IRQ7; i++)
    {
        if (irqs & (1 << i))
        {
            // Llamar a manejador si existe
            if (irq_vector[i-IRQ5])
                irq_vector[i-IRQ5]();
        }
    }

	if ((irqs & 6) != 0) {
		uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
		uint32_t instr = *(uint16_t*)pc;

		if ((instr & 3) == 3)
			instr = instr | (*(uint16_t*)(pc + 2)) << 16;

		if (((instr & 3) != 3) != (regs[0] & 1)) {
			print("Mismatch between q0 LSB and decoded instruction word! q0=0x");
			print_hex(regs[0], 8);
			print(", instr=0x");
			if ((instr & 3) == 3)
				print_hex(instr, 8);
			else
				print_hex(instr, 4);
			print("\n");
			__asm__ volatile ("ebreak");
		}
	}
	
	if ((irqs & 6) != 0)
	{
		uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
		uint32_t instr = *(uint16_t*)pc;

		if ((instr & 3) == 3)
			instr = instr | (*(uint16_t*)(pc + 2)) << 16;

		print("\n");
		print("------------------------------------------------------------\n");

		if ((irqs & 2) != 0) {
			if (instr == 0x00100073 || instr == 0x9002) {
				print("EBREAK instruction at 0x");
				print_hex(pc, 8);
				print("\n");
			} else {
				print("Illegal Instruction at 0x");
				print_hex(pc, 8);
				print(": 0x");
				print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
				print("\n");
			}
		}

		if ((irqs & 4) != 0) {
			print("Bus error in Instruction at 0x");
			print_hex(pc, 8);
			print(": 0x");
			print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
			print("\n");
		}
	}
	//print("Regs");
	//print_hex(regs[0], 8);
	print("irqs: ");
    print_hex(irqs, 8);
    print("\n");
	return regs;
}

void irq_register_handler(uint8_t irq_num, irq_handler_t handler)
{
    if (irq_num == IRQ5 | irq_num == IRQ6 || irq_num == IRQ7)
        irq_vector[irq_num-IRQ5] = handler;
}