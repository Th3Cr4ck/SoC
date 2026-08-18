#include "id00005010_driver.h"
#include "aip.h"
#include "firmware.h"
#include <stdbool.h>
#include <stdint.h>

// Defines
#define ONE_FLIT 1
#define TWO_FLIT 2
#define ZERO_OFFSET 0
#define ONE_OFFSET 1

/* Config/register map for the id00005010 (convolution) IP, following the
 * same addressing scheme used by the aip library: each "config" occupies
 * two consecutive config IDs -> config (data) / config+1 (address). This
 * mirrors what ID0000100A_gpio.c does for the GPIO IP. */
#define CCONFREG 0
#define STATUS_REG 30
#define IPID_REG 31
#define ID00005010_CONFIG_AMOUNT 3

/** Global variables declaration (private) */
static aip_config_t id00005010_csv[] = {{"CConfigReg", CCONFREG, 'W', 2},
                                        {"STATUS", STATUS_REG, 'B', 1},
                                        {"IPID", IPID_REG, 'R', 1}};

static uint8_t id00005010_port;
uint32_t id00005010_id = 0;

typedef struct {
  uint16_t duty;
  uint16_t prescaler;
  uint16_t period;
  uint8_t enable;
  polarity_e polarity;
} pwm_config_t;

static pwm_config_t pwm_config;

/*********************************************************************/

/** Private functions declaration */
static uint32_t id00005010_getID(uint32_t *id);
static void update_offset0(void);
static void update_offset1(void);
/*********************************************************************/

/** Global variables declaration (public)*/

/*********************************************************************/

int32_t id00005010_init(uint8_t port) {
  id00005010_port = port;

  aip_init(id00005010_port, id00005010_csv, ID00005010_CONFIG_AMOUNT);

  id00005010_getID(&id00005010_id);

  print("\nIP PWM Init!\n");
  return id00005010_id;
}

/* Start processing*/
int32_t id00005010_startIP(void) {
  aip_start(id00005010_port);
  return 0;
}

/* Set config */
int32_t id00005010_set_prescaler(uint16_t prescaler) {
  pwm_config.prescaler = prescaler;
  update_offset0();
  return 0;
}

int32_t id00005010_set_period(uint16_t period) {
  pwm_config.period = period;
  update_offset0();
  return 0;
}

int32_t id00005010_set_duty(uint16_t duty) {
  pwm_config.duty = duty;
  update_offset1();
  return 0;
}

int32_t id00005010_set_polarity(polarity_e polarity) {
  pwm_config.polarity = polarity;
  update_offset1();
  return 0;
}

int32_t id00005010_enable(void) {
  pwm_config.enable = TRUE;
  update_offset1();
  return 0;
}

int32_t id00005010_disable(void) {
  pwm_config.enable = FALSE;
  update_offset1();
  return 0;
}

int32_t id00005010_set_config(uint64_t config) {
  uint32_t config_array[2];
  config_array[0] = (uint32_t)(config & 0xFFFFFFFF);
  config_array[1] = (uint32_t)(config >> 32);
  aip_writeConfReg(id00005010_port, CCONFREG, config_array, TWO_FLIT,
                   ZERO_OFFSET);
  return 0;
}

// PRIVATE FUNCTIONS
uint32_t id00005010_getID(uint32_t *id) {
  aip_getID(id00005010_port, id);
  return 0;
}

// Función auxiliar para actualizar el registro en offset 0 (prescaler + period)
static void update_offset0(void) {
  uint32_t config_flit =
      ((uint32_t)pwm_config.period << 16) | pwm_config.prescaler;
  aip_writeConfReg(id00005010_port, CCONFREG, &config_flit, ONE_FLIT,
                   ZERO_OFFSET);
}

// Función auxiliar para actualizar el registro en offset 1 (duty + polarity +
// enable)
static void update_offset1(void) {
  uint32_t config_flit = ((uint32_t)pwm_config.enable << 17) |
                         (((uint32_t)pwm_config.polarity & 0x0001) << 16) |
                         pwm_config.duty;
  aip_writeConfReg(id00005010_port, CCONFREG, &config_flit, ONE_FLIT,
                   ONE_OFFSET);
}
