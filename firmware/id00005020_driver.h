#ifndef id00005020_GPIO_H_
#define id00005020_GPIO_H_

#include <stdint.h>

int32_t id00005020_init(uint8_t port);
int32_t id00005020_set_iomode(uint32_t data);
int32_t id00005020_set_odr(uint16_t data);
int32_t id00005020_get_idr(uint16_t *data);
int32_t id00005020_get_odr(uint16_t *data);
int32_t id00005020_bsrr_set(uint16_t data);
int32_t id00005020_bsrr_rst(uint16_t data);

#endif //id00005020_GPIO_H_
