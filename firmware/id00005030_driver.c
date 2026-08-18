#include "id00005030_driver.h"
#include "aip.h"
#include "firmware.h"
#include <stdint.h>
#include <stdbool.h>

// Defines
#define INT_DONE 0
#define ONE_FLIT 1
#define ZERO_OFFSET 0
#define STATUS_BITS 8
#define INT_DONE_BIT 0x00000001
// MAX_CONV_SIZE

/* Config/register map for the id00005030 (cordic) IP, following the
 * same addressing scheme used by the aip library: each "config" occupies
 * two consecutive config IDs -> config (data) / config+1 (address). This
 * mirrors what ID0000100A_gpio.c does for the GPIO IP. */

#define MMEMOUT 0
#define CCONFREG 2
#define STATUS_REG 30
#define IPID_REG 31

#define ID00005030_CONFIG_AMOUNT 4

/** Global variables declaration (private) */
static aip_config_t id00005030_csv[] = {{"MMemOut", MMEMOUT, 'R', 4},
                                        {"CConfReg", CCONFREG, 'W', 2},
                                        {"STATUS", STATUS_REG, 'B', 1},
                                        {"IPID", IPID_REG, 'R', 1}};

static uint8_t id00005030_port;

/*********************************************************************/
/** Private functions declaration */
static uint32_t id00005030_getID(uint32_t *id);
/*********************************************************************/

int32_t id00005030_init(uint8_t port) {

  id00005030_port = port;

  aip_init(id00005030_port, id00005030_csv, ID00005030_CONFIG_AMOUNT);

  uint32_t id;
  id00005030_getID(&id);
  
  print("\nIP CORDIC INIT\n");
  return id;
}

/* Start processing*/
int32_t id00005030_startIP(void) {
  aip_start(id00005030_port);
  return 0;
}

/* Enable interruption notification "Done"*/
int32_t id00005030_enableINT(void) {
  aip_enableINT(id00005030_port, INT_DONE);
  // print("\nINT Done enabled");
  return 0;
}

/* Disable interruption notification "Done"*/
int32_t id00005030_disableINT(void) {
  aip_disableINT(id00005030_port, INT_DONE);
  // print("\nINT Done disabled");
  return 0;
}

/* Show status*/
int32_t id00005030_status(void) {
  uint32_t status;
  aip_getStatus(id00005030_port, &status);
  return 0;
}

/* Wait interruption*/
int32_t id00005030_waitINT(void) {
  bool waiting = true;
  uint32_t status;

  while (waiting) {
    aip_getStatus(id00005030_port, &status);

    if ((status & INT_DONE_BIT) > 0)
      waiting = false;
  }

  aip_clearINT(id00005030_port, INT_DONE);

  return 0;
}

/* Clear interruption*/
int32_t id00005030_clearINT(void) {

  aip_clearINT(id00005030_port, INT_DONE);

  return 0;
}

/* Do cordic operation */
int32_t id00005030_cordic_process(const uint32_t x, const uint32_t y, const uint32_t z, const op_mode_t op_mode) {
  
  // Set Initial Values
  uint32_t data_config[2];
  data_config[0] = (y << 16) | x;
  data_config[1] = (op_mode << 16) | z;
  aip_writeConfReg(id00005030_port, CCONFREG, data_config, 2, 0);

  id00005030_enableINT();
  
  id00005030_startIP();

  id00005030_waitINT();

  id00005030_clearINT();

  id00005030_disableINT();

  return 0;
}

/* Read cordic operation results */
int32_t id00005030_read_results(uint32_t *x_out, uint32_t *y_out, uint32_t *z_out) {
  uint32_t mem[3];
  aip_readMem(id00005030_port, MMEMOUT, mem, 3, 0);
  *x_out = mem[0];
  *y_out = mem[1];
  *z_out = mem[2];
  return 0;
}

// PRIVATE FUNCTIONS
uint32_t id00005030_getID(uint32_t *id) {
  aip_getID(id00005030_port, id);
  return 0;
}
