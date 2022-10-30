
// I2C Library (i2c.h)
// Krutika Nerurkar

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// HPS interface:
//   Mapped to offset of 0x8000 in light-weight MM interface aperature

//-----------------------------------------------------------------------------

#ifndef I2C_H_
#define I2C_H_

#include <stdint.h>
#include <stdbool.h>

//-----------------------------------------------------------------------------
// Subroutines
//-----------------------------------------------------------------------------

void write_i2c_control(uint32_t value);
uint32_t read_i2c_control();
uint32_t read_i2c_status();
void write_i2c_status_overflow_flag();
void write_i2c_data(uint8_t value);
uint8_t read_i2c_data();

#endif
