#ifndef __ID00005010_DRIVER_H__
#define __ID00005010_DRIVER_H__

#include <stdint.h>

typedef enum {
  POL_LOW,
  POL_HIGH
} polarity_e;

#define TRUE 1
#define FALSE 0

/** Global variables declaration (public) */
/* These variables must be declared "extern" to avoid repetitions. They are defined in the .c file*/
/******************************************/

/** Public functions declaration */

int parse_list(const char *input, uint32_t *arr, int max_size);

/* Driver initialization
 * NOTE: With the "aip" library the IP is addressed directly through its
 * memory-mapped port, so init only needs the aip port number (same pattern
 * used by ID0000100A_init(uint8_t port)). */
int32_t id00005010_init(uint8_t port);

/* Start processing*/
int32_t id00005010_startIP(void);

int32_t id00005010_set_duty(uint16_t duty);
int32_t id00005010_set_prescaler(uint16_t prescaler);
int32_t id00005010_set_polarity(polarity_e polarity);
int32_t id00005010_set_period(uint16_t period);
int32_t id00005010_set_config(uint64_t config);
int32_t id00005010_enable(void);
int32_t id00005010_disable(void);

#endif // __ID00005010_DRIVER_H__
