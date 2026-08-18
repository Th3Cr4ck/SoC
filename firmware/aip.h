/*
 * aip.h
 *
 *  Created on: Feb 2, 2024
 *      Author: Daniel Abisaid Hernandez
 */

#ifndef AIP_H_
#define AIP_H_
#include "stdint.h"
#include <stdint.h>


#define AIP_PORT_1 1
#define AIP_PORT_2 2
#define AIP_PORT_3 3

#define AIP_DATAOUT  0
#define AIP_DATAIN   1
#define AIP_CONFIG   2
#define AIP_START    3

#define MNEMONIC_MAX_LEN 16

typedef struct aip_config
{
    char mnemonic[MNEMONIC_MAX_LEN];
    uint8_t config;
    uint8_t mode;
    uint8_t size;
} aip_config_t;

typedef struct aip_regs
{
    uint32_t aip_dataOut;
    uint32_t aip_dataIn;
    uint32_t aip_config;
    uint32_t aip_start;
} aip_regs_t;

#define read_a      0
#define write_a     4
#define config_a    8
#define start_a     12


int8_t aip_init (uint8_t aipPort, aip_config_t *aip_configs, uint8_t configAmount);

int8_t aip_readMem (uint8_t aipPort, char configMem, uint32_t* dataRead, uint16_t amountData, uint32_t offset);

int8_t aip_writeMem (uint8_t aipPort, char configMem, uint32_t* dataWrite, uint16_t amountData, uint32_t offset);

int8_t aip_writeConfReg (uint8_t aipPort, char configConfReg, uint32_t* dataWrite, uint16_t amountData, uint32_t offset);

int8_t aip_start (uint8_t aipPort);

int8_t aip_getID (uint8_t aipPort, uint32_t *id);

int8_t aip_getStatus (uint8_t aipPort, uint32_t* status);

int8_t aip_enableINT (uint8_t aipPort, uint8_t idxInt);

int8_t aip_disableINT (uint8_t aipPort, uint8_t idxInt);

int8_t aip_clearINT (uint8_t aipPort, uint8_t idxInt);

int8_t aip_getINT (uint8_t aipPort, uint8_t* intVector);

int8_t aip_getNotifications(uint8_t aipPort, uint8_t* notificationsVector);

#endif /* AIP_H_ */
