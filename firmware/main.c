#include <stdint.h>

#define PWM_BASE_ADDR     ((volatile uint32_t *)0x80001000UL)
#define GPIO_BASE_ADDR    ((volatile uint32_t *)0x80002000UL)
#define CORDIC_BASE_ADDR  ((volatile uint32_t *)0x80003000UL)

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

#define STATUS 30
#define IDREG  31

void test_pwm(void);
void test_gpio(void);
void delay(uint32_t count);

int main (int argc, char * argv[]) {
  
  test_pwm();

  test_gpio();

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
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0x0000FF00; // {8b input, 8b output(ODR)}

  delay(200);

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_AMEMOUT;
  GPIO_BASE_ADDR[AIP_DATA_IN] = 0;

  GPIO_BASE_ADDR[AIP_CONFIG] = GPIO_MMEMOUT;
  uint32_t memVal = GPIO_BASE_ADDR[AIP_DATA_OUT]; // {16b ODR 16b IDR}
}


void delay(uint32_t count) {
  for (int i = 0; i < count; i++)
    __asm__("nop");
}
