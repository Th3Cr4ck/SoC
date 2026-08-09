#include <stdint.h>
#include "firmware.h"

#define UART_BASE_ADDR    ((volatile uint32_t *)0x50002004UL)
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

#define PWM_CCONFREG 0
#define PWM_ACONFREG 1

#define GPIO_MMEMOUT  0 
#define GPIO_AMEMOUT  1
#define GPIO_CCONFREG 2
#define GPIO_ACONFREG 3

#define CORDIC_MMEMOUT  0
#define CORDIC_AMEMOUT  1
#define CORDIC_CCONFREG 2
#define CORDIC_ACONFREG 3

#define CONV_MMEMX    0
#define CONV_AMEMX    1
#define CONV_MMEMY    2
#define CONV_AMEMY    3
#define CONV_MMEMOUT  4
#define CONV_AMEMOUT  5
#define CONV_CCONFREG 6
#define CONV_ACONFREG 7

#define STATUS 30
#define IDREG  31

#define INT_BIT_DONE (1U << 0)
#define INT_EN_DONE  (1U << 16)
#define STATUS_BIT_BUSY (1U << 8)

void test_pwm(void);
void test_gpio(void);
void test_cordic(void);
void test_conv(void);
void delay(uint32_t count);

int main (int argc, char * argv[]) {

  reg_uart_clkdiv = 104;//for simulation only - 5208 for 9600;//104 is 12 MHz for 115200, and 434 is 50Mhz for 115200
  
  test_pwm();

  test_gpio();

  test_cordic();

  return 0;
}

void test_pwm(void) {
  PWM_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = PWM_BASE_ADDR[AIP_DATA_OUT];

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0;

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x000A0002;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030002;

  *(PWM_BASE_ADDR+AIP_START) = 1; // Start
  delay(200);
  *(PWM_BASE_ADDR+AIP_START) = 1; // Stop


  PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0;

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00080003;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030006;

  *(PWM_BASE_ADDR+AIP_START) = 1; // Start
  delay(200);
}

void test_gpio(void) {

  GPIO_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = GPIO_BASE_ADDR[AIP_DATA_OUT];

  // GPIO como entrada / salida
  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_ACONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_CCONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x0000BEAF; // ODR
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x0000FF00; // {8b output(ODR), 8b input}

  delay(200);

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_AMEMOUT;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_MMEMOUT;
  uint32_t memVal = GPIO_BASE_ADDR[AIP_DATA_OUT]; // {16b ODR 16b IDR}

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_ACONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_CCONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x00000100; // BSRR (Set bit 8)
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x0001FF00; // {8b output(BSSR), 8b input}
  
  delay(200);


}

void test_cordic(void) {
  
  /* CASO ROTACION */
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_ACONFREG;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0;

  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_CCONFREG;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0x00000400;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0x00010324;

  // Enable INT
  CORDIC_BASE_ADDR[AIP_CONFIG] = STATUS;
  uint32_t status = CORDIC_BASE_ADDR[AIP_DATA_OUT]; // get status reg

  status |= INT_EN_DONE;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = status;

  // START
  CORDIC_BASE_ADDR[AIP_START] = 1;

  // Wait INT
  uint32_t status_read;
    CORDIC_BASE_ADDR[AIP_CONFIG] = STATUS;
  do {
    status_read = CORDIC_BASE_ADDR[AIP_DATA_OUT]; // get status reg
  } while (!(status_read & INT_BIT_DONE));
  
  // Clean INT
  uint32_t clean_status = 0x00010001;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = clean_status;

  // Read results
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_AMEMOUT;;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0;
  
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_MMEMOUT;
  uint32_t x_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  uint32_t y_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  uint32_t z_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];

  /* CASO VECTORIZACION */
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_ACONFREG;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0;

  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_CCONFREG;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0x04000400;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0x00000000;
  
  // START
  CORDIC_BASE_ADDR[AIP_START] = 1;

  // Wait INT
  CORDIC_BASE_ADDR[AIP_CONFIG] = STATUS;
  do {
    status_read = CORDIC_BASE_ADDR[AIP_DATA_OUT]; // get status reg
  } while (!(status_read & INT_BIT_DONE));
  
  // Clean INT
  CORDIC_BASE_ADDR[AIP_DATA_IN] = clean_status;

  // Read results
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_AMEMOUT;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0;

  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_MMEMOUT;
  uint32_t memVal = CORDIC_BASE_ADDR[AIP_DATA_OUT]; //x
  print_hex(memVal, 8);
  delay(1000);
// ----
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_AMEMOUT;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 0;
  
  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_MMEMOUT;
  x_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];

  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_AMEMOUT;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 1;
  y_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];

  CORDIC_BASE_ADDR[AIP_CONFIG] = CORDIC_AMEMOUT;
  CORDIC_BASE_ADDR[AIP_DATA_IN] = 2;
  z_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];

}

void test_conv(void) {
  CONV_BASE_ADDR[AIP_CONFIG] = CONV_ACONFREG;
  CONV_BASE_ADDR[AIP_DATA_IN] = 0;

  CONV_BASE_ADDR[AIP_CONFIG] = CONV_CCONFREG;
  CONV_BASE_ADDR[AIP_DATA_IN] = 0x145; // sizeX=5; sizeY=10;

  CONV_BASE_ADDR[AIP_CONFIG] = CONV_AMEMX;
  CONV_BASE_ADDR[AIP_DATA_IN] = 0;

  CONV_BASE_ADDR[AIP_CONFIG] = CONV_MMEMX;
  for (int i = 0 ; i < 5; i++) {
    CONV_BASE_ADDR[AIP_DATA_IN] = i;
  }

  CONV_BASE_ADDR[AIP_CONFIG] = CONV_AMEMY;
  CONV_BASE_ADDR[AIP_DATA_IN] = 0;

  CONV_BASE_ADDR[AIP_CONFIG] = CONV_MMEMY;
  for (int i = 0 ; i < 10; i++) {
    CONV_BASE_ADDR[AIP_DATA_IN] = i;
  }

  CONV_BASE_ADDR[AIP_START] = 1;

}

void delay(uint32_t count) {
  for (volatile int i = 0; i < count; i++)
    __asm__("nop");
}
