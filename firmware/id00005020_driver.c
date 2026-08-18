#include "id00005020_driver.h"
#include "aip.h"
#include "firmware.h"
#include "stdlib.h"
#include <stdint.h>

#define ID00005020_CONFIG_AMOUNT 5

#define MMEMOUT 0
#define CCONFREG 2
#define STATUS 30
#define IPID 31


static aip_config_t ID00005020_csv[] = {{"MMemOut_IDR", MMEMOUT, 'R', 2},
                                        {"CConfigReg", CCONFREG, 'W', 2},
                                        {"STATUS", STATUS, 'B', 1},
                                        {"IPID", IPID, 'R', 1}};

static uint8_t id00005010_port;
static uint16_t iomode = 0;

int32_t id00005020_init(uint8_t port) {

  id00005010_port = port;
  aip_init(id00005010_port, ID00005020_csv, ID00005020_CONFIG_AMOUNT);

  uint32_t id;
  aip_getID(id00005010_port, &id);

  print("\nIP GPIO Init!\n");
  return id;
}

int32_t id00005020_set_iomode(uint32_t data) {
  iomode = data;
  aip_writeConfReg(id00005010_port, CCONFREG, &data, 1, 1);
  return 0;
}

int32_t id00005020_set_odr(uint16_t data) {
  
  uint32_t data_array[2];
  data_array[0] = data;
  data_array[1] = iomode;

  aip_writeMem(id00005010_port, CCONFREG, data_array, 2, 0);
  return 0;
}

int32_t id00005020_get_idr(uint16_t *data) {
  uint32_t mem;
  aip_readMem(id00005010_port, MMEMOUT, &mem, 1, 0);
  *data = mem & 0x0000FFFF; 
  return 0;
}

int32_t id00005020_get_odr(uint16_t *data) {
  uint32_t mem;
  aip_readMem(id00005010_port, MMEMOUT, &mem, 1, 0);
  *data = mem >> 16; 
  return 0;
}

int32_t id00005020_bsrr_set(uint16_t data) {

  uint32_t data_array[2];
  data_array[0] = data;
  data_array[1] = (0x1 << 16) | iomode;

  aip_writeMem(id00005010_port, CCONFREG, data_array, 2, 0);
  return 0;
}

int32_t id00005020_bsrr_rst(uint16_t data) {

  uint32_t data_array[2];
  data_array[0] = data << 16;
  data_array[1] = (0x1 << 16) | iomode;

  aip_writeMem(id00005010_port, CCONFREG, data_array, 2, 0);
  return 0;
}

