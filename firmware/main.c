#include "firmware.h"
#include "id00005010_driver.h"
#include "id00005020_driver.h"
#include "id00005030_driver.h"
#include <stdint.h>

void test_pwm(void);
void test_gpio(void);
void test_cordic(void);
void delay(uint64_t count);
void delay_ms(uint32_t ms);

int main(int argc, char *argv[]) {

  reg_uart_clkdiv = 104; // for simulation only - 5208 for 9600;//104 is 12 MHz
                         // for 115200, and 434 is 50Mhz for 115200

  test_pwm();

  test_gpio();

  test_cordic();

  return 0;
}

void test_pwm(void) {

  uint8_t started = 0;
  uint32_t id = 0;
  id = id00005010_init(0);
  print_hex(id, 8);
  putchar('\n');

  // while (1) {
  
    id00005010_set_prescaler(2);
    id00005010_set_period(100);
    id00005010_set_duty(30);
    id00005010_set_polarity(POL_HIGH);
    id00005010_enable();

    if (started == 0) {
      started = 1;
      id00005010_startIP();
    }

    delay(100);

    id00005010_set_duty(75);
  // }
}

void test_gpio(void) {

  uint32_t id = id00005020_init(1);
  print_hex(id, 8);
  putchar('\n');

  // GPIO como entrada / salida
  /* ------- ODR CAFE ---------- */
  id00005020_set_iomode(0xFF00); // {8b output(ODR), 8b input}
  id00005020_set_odr(0xBEAF); // ODR

  delay(100);

  // Leer IDR y ODR
  uint16_t idr;
  id00005020_get_idr(&idr);
  print("IDR:");
  print_hex(idr, 4);
  putchar('\n');

  uint16_t odr;
  id00005020_get_odr(&odr);
  print("ODR:");
  print_hex(odr, 4);
  putchar('\n');

  /* ------- BSSR SET ---------- */
  id00005020_bsrr_set(0x00000100); // BSRR (Set bit 8)

  // Leer IDR y ODR
  id00005020_get_idr(&idr);
  print("IDR:");
  print_hex(idr, 4);
  putchar('\n');

  id00005020_get_odr(&odr);
  print("ODR:");
  print_hex(odr, 4);
  putchar('\n');
  delay(100);

  /* ------- ODR CAFE ---------- */
  id00005020_set_odr(0xCAFE);

  // Leer IDR y ODR
  id00005020_get_idr(&idr);
  print("IDR:");
  print_hex(idr, 4);
  putchar('\n');

  id00005020_get_odr(&odr);
  print("ODR:");
  print_hex(odr, 4);
  putchar('\n');
}

void test_cordic(void) {

  uint32_t id = id00005030_init(2);
  print_hex(id, 8);
  putchar('\n');

  /* CASO ROTACION */
  id00005030_cordic_process(0x0400, 0, 0x324, ROTATION);
  uint32_t x_out, y_out, z_out;
  id00005030_read_results(&x_out, &y_out, &z_out);
  print("\nX=");
  print_hex(x_out, 4);
  putchar('\n');
  print("Y=");
  print_hex(y_out, 4);
  putchar('\n');
  print("Z=");
  print_hex(z_out, 4);
  putchar('\n');

  delay(100);

  // /* CASO VECTORIZACION */
  id00005030_cordic_process(0x0400, 0x0400, 0, VECTORIZATION);
  id00005030_read_results(&x_out, &y_out, &z_out);
  print("X=");
  print_hex(x_out, 4);
  putchar('\n');
  print("Y=");
  print_hex(y_out, 4);
  putchar('\n');
  print("Z=");
  print_hex(z_out, 4);
  putchar('\n');
}

void delay_ms(uint32_t ms) {
  uint64_t count = (ms - 1UL) * 1000000UL /
                   820; // -1 para quitar el tiempo que toma el calculo
  delay(count);
}

void delay(uint64_t count) {
  for (volatile int i = 0; i < count; i++)
    __asm__("nop");
}
