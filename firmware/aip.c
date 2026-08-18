//#include "stdio.h"
#include "aip.h"
#include "firmware.h"
#include "stdlib.h"
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#define AIP_CONFIG_STATUS 30
#define AIP_CONFIG_ID 31

#define AIP_STATUS_MASK_NU 0xff000000
#define AIP_STATUS_MASK_MASK 0x00ff0000
#define AIP_STATUS_MASK_NOTIFICATION 0x0000ff00
#define AIP_STATUS_MASK_INT 0x000000ff

#define AIP_STATUS_SHIFT_NU 24
#define AIP_STATUS_SHIFT_MASK 16
#define AIP_STATUS_SHIFT_NOTIFICATION 80
#define AIP_STATUS_SHIFT_INT 0

#define AIP_PORTS 3

#define AIP_IP_0 0x80001000 // PWM
#define AIP_IP_1 0x80002000 // GPIO
#define AIP_IP_2 0x80003000 // CORDIC
#define AIP_IP_3 0x83000100

typedef struct aip_portConfig {
  uint8_t amount;
  aip_config_t *configs;
} aip_portConfig_t;

static const uint32_t AIP_PORT_BASE[] = {AIP_IP_0, AIP_IP_1, AIP_IP_2,
                                         AIP_IP_3};

static aip_portConfig_t aip_portConfigs[AIP_PORTS];

static uint8_t aip_aipRead(void *baseAddr, uint8_t config, uint32_t *data,
                           uint16_t size);

static uint8_t aip_aipWrite(void *baseAddr, uint8_t config, uint32_t *data,
                            uint16_t size);

static uint8_t aip_aipStart(void *baseAddr);

static uint8_t aip_getPortAdders(uint8_t aipPort, uint32_t *aipBaseAddr);

static uint8_t aip_getConfig(uint8_t aipPort, char *mnemonic,
                             uint8_t *configID);

int8_t aip_init(uint8_t aipPort, aip_config_t *aip_configs,
                uint8_t configAmount) {
  aip_portConfigs[aipPort].amount = configAmount;

  aip_portConfigs[aipPort].configs = aip_configs;

  return 0;
}

int8_t aip_readMem(uint8_t aipPort, char configMem, uint32_t *dataRead,
                   uint16_t amountData, uint32_t offset) {
  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, configMem, &configID);
  configID = configMem;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  /* set addrs */
  aip_aipWrite((void *)aipBaseAddr, configID + 1, &offset, 1);

  /* write data */
  aip_aipRead((void *)aipBaseAddr, configID, dataRead, amountData);

  return 0;
}

int8_t aip_writeMem(uint8_t aipPort, char configMem, uint32_t *dataWrite,
                    uint16_t amountData, uint32_t offset) {
  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, configMem, &configID);
  configID = configMem;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  /* set addrs */
  aip_aipWrite((void *)aipBaseAddr, configID + 1, &offset, 1);

  /* write data */
  aip_aipWrite((void *)aipBaseAddr, configID, dataWrite, amountData);

  return 0;
}

int8_t aip_writeConfReg(uint8_t aipPort, char configConfReg,
                        uint32_t *dataWrite, uint16_t amountData,
                        uint32_t offset) {
  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, configConfReg, &configID);
  configID = configConfReg;
  aip_getPortAdders(aipPort, &aipBaseAddr);

  /* set addrs */
  aip_aipWrite((void *)aipBaseAddr, configID + 1, &offset, 1);

  /* write data */
  aip_aipWrite((void *)aipBaseAddr, configID, dataWrite, amountData);

  return 0;
}

int8_t aip_start(uint8_t aipPort) {
  uint32_t aipBaseAddr = 0;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipStart((void *)aipBaseAddr);

  return 0;
}

int8_t aip_getID(uint8_t aipPort, uint32_t *id) {
  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "IPID", &configID);
  configID = 31;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, id, 1);

  return 0;
}

int8_t aip_getStatus(uint8_t aipPort, uint32_t *status) {
  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, status, 1);

  return 0;
}

int8_t aip_enableINT(uint8_t aipPort, uint8_t idxInt) {
  uint32_t status = 0;

  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, &status, 1);

  status &= AIP_STATUS_MASK_MASK;

  status |= (1 << (idxInt + AIP_STATUS_SHIFT_MASK));

  aip_aipWrite((void *)aipBaseAddr, configID, &status, 1);

  return 0;
}

int8_t aip_disableINT(uint8_t aipPort, uint8_t idxInt) {
  uint32_t status = 0;

  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, &status, 1);

  status &= AIP_STATUS_MASK_MASK;

  status &= ~(uint32_t)(1 << (idxInt + AIP_STATUS_SHIFT_MASK));

  aip_aipWrite((void *)aipBaseAddr, configID, &status, 1);

  return 0;
}

int8_t aip_clearINT(uint8_t aipPort, uint8_t idxInt) {
  uint32_t status = 0;

  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, &status, 1);

  status = (status & (AIP_STATUS_MASK_NU | AIP_STATUS_MASK_MASK |
                      AIP_STATUS_MASK_NOTIFICATION)) |
           (uint32_t)(1 << idxInt);

  aip_aipWrite((void *)aipBaseAddr, configID, &status, 1);

  return 0;
}

int8_t aip_getINT(uint8_t aipPort, uint8_t *intVector) {
  uint32_t status = 0;

  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, &status, 1);

  *intVector = (uint8_t)(status & AIP_STATUS_MASK_INT);

  return 0;
}

int8_t aip_getNotifications(uint8_t aipPort, uint8_t *notificationsVector) {
  uint32_t status = 0;

  uint32_t aipBaseAddr = 0;

  uint8_t configID = 0;

  // aip_getConfig(aipPort, "STATUS", &configID);
  configID = 30;

  aip_getPortAdders(aipPort, &aipBaseAddr);

  aip_aipRead((void *)aipBaseAddr, configID, &status, 1);

  *notificationsVector = (uint8_t)((status & AIP_STATUS_MASK_NOTIFICATION) >>
                                   AIP_STATUS_SHIFT_NOTIFICATION);

  return 0;
}

static uint8_t aip_aipRead(void *baseAddr, uint8_t config, uint32_t *data,
                           uint16_t size) {

  // IOWR(baseAddr,config_a,config);
  *((uint32_t *)baseAddr + AIP_CONFIG) = (uint32_t)config;
  for (uint32_t i = 0; i < size; i++) {
    // data[i] = IORD(baseAddr, read_a);
    data[i] = *((uint32_t *)baseAddr + AIP_DATAOUT);
  }

  return 0;
};

static uint8_t aip_aipWrite(void *baseAddr, uint8_t config, uint32_t *data,
                            uint16_t size) {

  // IOWR(baseAddr, config_a, config);
  *((uint32_t *)baseAddr + AIP_CONFIG) = config;
  // print("The configID is: ");
  // print_hex(config,2);

  for (uint32_t i = 0; i < size; i++) {
    // IOWR(baseAddr, write_a, data[i]);
    *((uint32_t *)baseAddr + AIP_DATAIN) = data[i];
    // print("\nThe data: ");
    // print_hex(data[i],8);
  }

  return 0;
};

static uint8_t aip_aipStart(void *baseAddr) {
  // IOWR(baseAddr,start_a,1);
  *((uint32_t *)baseAddr + AIP_START) = 1;
  return 0;
};

static uint8_t aip_getPortAdders(uint8_t aipPort, uint32_t *aipBaseAddr) {
  *aipBaseAddr = AIP_PORT_BASE[aipPort];

  return 0;
}

static uint8_t aip_getConfig(uint8_t aipPort, char *mnemonic,
                             uint8_t *configID) {
  volatile int8_t idx = 0;
  uint32_t i = 0;

  for (i = 0; i < aip_portConfigs[aipPort].amount; i++) {
    idx = strcmp(aip_portConfigs[aipPort].configs[i].mnemonic, mnemonic);

    if (!idx) {
      *configID = aip_portConfigs[aipPort].configs[i].config;

      return 0;
    }
  }

  return 1;
}
