#include <stdint.h>
#include "firmware.h"
#include "gpio_uart.h"


void test_pwm(void);
void test_gpio(void);
void test_cordic(void);
void delay(uint64_t count);
void delay_ms(uint32_t ms);

int main (int argc, char * argv[]) {

  reg_uart_clkdiv = 434;//for simulation only - 5208 for 9600;//104 is 12 MHz for 115200, and 434 is 50Mhz for 115200
  
  print("Hola desde la UART\n");

  test_pwm();

  test_cordic();

  test_gpio();

  return 0;
}

void test_pwm(void) {
  PWM_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = PWM_BASE_ADDR[AIP_DATA_OUT];


  *(PWM_BASE_ADDR+AIP_START) = 1; // Start
  // while(1) {

    uint16_t prescaler = 2;
    uint16_t period = 1024;
    uint16_t duty = 0;

    PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG;
    PWM_BASE_ADDR[AIP_DATA_IN] = 0;
    PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
    PWM_BASE_ADDR[AIP_DATA_IN] = ((uint32_t)period << 16) | prescaler; // Prescaler=2; Period=1024
  
    for (duty = 0; duty <= period; duty += 64) {
      PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG; // 51 iteraciones
      PWM_BASE_ADDR[AIP_DATA_IN] = 1;
      PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
      PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030000 | duty; // Duty=64; Polarity=1; Enable=1
      delay_ms(40); // 51 * 40 = 2 segundos
    }
  
  
    for (duty = period; duty >= 0; duty -= 64) {
      PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG; // 15 iteraciones
      PWM_BASE_ADDR[AIP_DATA_IN] = 1;
      PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
      PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030000 | duty; // Duty=64; Polarity=1; Enable=1
      delay_ms(40); // 15 * 30 = 450 ms
    }
  // }
}

void test_gpio(void) {

  // Solo manejo 8 pines en la de1-soc

  GPIO_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = GPIO_BASE_ADDR[AIP_DATA_OUT];

  // Default -> Mitad salida, mitad entrada
  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_ACONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_CCONFREG;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x000000AF; // ODR (Solo la A sera visible en los pines)
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x000000F0; // 4 bits salida / 4 bits entrada
  
}

void test_cordic(void) {
  
  CORDIC_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  print_hex(id, 8);

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

  print_hex(x_out, 8);
  delay(500);
  print_hex(y_out, 8);
  delay(500);
  print_hex(z_out, 8);
  delay(500);

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
  x_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  y_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  z_out = CORDIC_BASE_ADDR[AIP_DATA_OUT];
  
  print_hex(x_out, 8);
  delay(500);
  print_hex(y_out, 8);
  delay(500);
  print_hex(z_out, 8);
  delay(500);

}

void delay_ms(uint32_t ms) {
  uint64_t count = (ms-1UL) * 290 / 1000; // -1 para quitar el tiempo que toma el calculo
  delay(count);
}

void delay(uint64_t count) {
  for (volatile int i = 0; i < count; i++)
    __asm__("nop");
}
