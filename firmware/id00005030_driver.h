#ifndef __ID00005030_DRIVER_H__
#define __ID00005030_DRIVER_H__

#include <stdint.h>

typedef enum {
  VECTORIZATION,
  ROTATION
} op_mode_t;

/** Public functions declaration */

/* Driver initialization
 * NOTE: With the "aip" library the IP is addressed directly through its
 * memory-mapped port, so init only needs the aip port number (same pattern
 * used by ID0000100A_init(uint8_t port)). */
int32_t id00005030_init(uint8_t port);

/* Start processing*/
int32_t id00005030_startIP(void);

/* Enable interruption notification "Done"*/
int32_t id00005030_enableINT(void);

/* Clear interruption notification "Done"*/
int32_t id00005030_clearINT(void);

/* Disable interruption notification "Done"*/
int32_t id00005030_disableINT(void);

/* Show status*/
int32_t id00005030_status(void);

/* Wait interruption*/
int32_t id00005030_waitINT(void);

int32_t id00005030_cordic_process(const uint32_t x, const uint32_t y, const uint32_t z, const op_mode_t op_mode);
int32_t id00005030_read_results(uint32_t *x_out, uint32_t *y_out, uint32_t *z_out);

#endif // __ID00005030_DRIVER_H__
