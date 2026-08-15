#include <stdint.h>
#include "gpio_uart.h"
#include "firmware.h"

static void write_gpio_dataConfigReg(uint64_t reg);

void handle_uart(void) {
  print("Esperando 8 bytes");
  uint8_t buf[8];

  // Wait for 8 bytes of wrDataConfigReg of GPIO
  // LSB first
  for (int i = 0; i < 8; i++) {
    buf[i] = *(uint8_t*)reg_uart_data;
  }
  uint64_t rx = *(uint64_t*)buf;
  write_gpio_dataConfigReg(rx);
}

static void write_gpio_dataConfigReg(uint64_t reg){
  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_ACONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;
  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_CCONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = (uint32_t)(reg & 0xFFFFFFFF);
  GPIO_BASE_ADDR[AIP_DATA_IN] = (uint32_t)((reg >> 32) & 0xFFFFFFFF);
}
