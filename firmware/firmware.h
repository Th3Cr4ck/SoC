// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#ifndef FIRMWARE_H
#define FIRMWARE_H

#include <stdint.h>
#include <stdbool.h>

#define reg_leds (*(volatile uint32_t*)0x81000000)

#define PWM_BASE_ADDR     ((volatile uint32_t *)0x80001000UL)
#define GPIO_BASE_ADDR    ((volatile uint32_t *)0x80002000UL)
#define CORDIC_BASE_ADDR  ((volatile uint32_t *)0x80003000UL)
#define CONV_BASE_ADDR    ((volatile uint32_t *)0x80004000UL)

#define reg_uart_clkdiv (*(volatile uint32_t*)0x50002000)
#define reg_uart_data (*(volatile uint32_t*)0x50002004)

#define AIP_DATA_OUT 0
#define AIP_DATA_IN  1
#define AIP_CONFIG   2
#define AIP_START    3


#define GPIO_MMEMOUT  0 
#define GPIO_AMEMOUT  1
#define GPIO_CCONFREG 2
#define GPIO_ACONFREG 3

#define CORDIC_MMEMOUT  0
#define CORDIC_AMEMOUT  1
#define CORDIC_CCONFREG 2
#define CORDIC_ACONFREG 3

#define STATUS 30
#define IDREG  31

#define INT_BIT_DONE (1U << 0)
#define INT_EN_DONE  (1U << 16)

typedef void (*irq_handler_t)(void);

// irq.c
uint32_t *irq(uint32_t *regs, uint32_t irqs);
void irq_register_handler(uint8_t irq_num, irq_handler_t handler);

// print.c
void putchar(char c);
void print(const char *p);
void print_hex(uint32_t v, int digits);
void print_dec(uint32_t v);

// main.c
int main(int argc, char * argv[]);

#endif
