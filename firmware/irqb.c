// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
	
	// checking compressed isa q0 reg handling
	if ((irqs & 7) != 0) {
		print(" IRQ 7 -- Start Ipcore");
		print("\n");
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
			while (1)
			{
				if(reg_leds== 0)
					reg_leds = 1;
				else
					reg_leds = 0;	
				for (int rep = 200; rep > 0; rep--)
				//	for (int rep = 100000; rep > 0; rep--)
				{
					__asm__ volatile ("nop");//asm volatile("");
				}
			}
		}
	}
	//print("Regs");
	//print_hex(regs[0], 8);
	print("irqs: ");
    print_hex(irqs, 8);
    print("\n");
	return regs;
}

