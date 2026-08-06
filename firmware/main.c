#include <stdint.h>

#define PWM_BASE_ADDR     ((volatile uint32_t *)0x80001000UL)
#define GPIO_BASE_ADDR    ((volatile uint32_t *)0x80002000UL)
#define CORDIC_BASE_ADDR  ((volatile uint32_t *)0x80003000UL)

#define AIP_DATA_OUT 0
#define AIP_DATA_IN  1
#define AIP_CONFIG   2
#define AIP_START    3

#define PWM_ACONFREG 1
#define PWM_CCONFREG 0
#define IDREG 31

int main (int argc, char * argv[]) {
  
  PWM_BASE_ADDR[AIP_CONFIG] = IDREG;
  uint32_t id = PWM_BASE_ADDR[AIP_DATA_OUT];

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0;

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x000A0002;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030002;

  *(PWM_BASE_ADDR+AIP_START) = 1; // Start
  for (int i = 0; i < 2000; i++)
    __asm__("nop");
  *(PWM_BASE_ADDR+AIP_START) = 1; // Stop


  PWM_BASE_ADDR[AIP_CONFIG] = PWM_ACONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0;

  PWM_BASE_ADDR[AIP_CONFIG] = PWM_CCONFREG;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00080003;
  PWM_BASE_ADDR[AIP_DATA_IN] = 0x00030006;

  *(PWM_BASE_ADDR+AIP_START) = 1; // Start
  for (int i = 0; i < 2000; i++)
    __asm__("nop");
  // *(PWM_BASE_ADDR+AIP_START) = 1; // Stop

  return 0;
}
