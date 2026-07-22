// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#ifndef FIRMWARE_H
#define FIRMWARE_H

#define reg_leds (*(volatile uint32_t*)0x81000000)

#include <stdint.h>
#include <stdbool.h>

// irq.c
uint32_t *irq(uint32_t *regs, uint32_t irqs);

// print.c
void putchar(char c);
void print(const char *p);
void print_hex(uint32_t v, int digits);
void print_dec(uint32_t v);

// main.c
void main(void);

#endif
