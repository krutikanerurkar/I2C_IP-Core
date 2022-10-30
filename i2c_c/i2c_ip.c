// I2C IP Example
// I2C IP Library (i2c_ip.c)
// Krutika Nerurkar

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board


// HPS interface:
//   Mapped to offset of 0 in light-weight MM interface aperature

//-----------------------------------------------------------------------------

#include <stdint.h>          // C99 integer types -- uint32_t
#include <stdbool.h>         // bool
#include <fcntl.h>           // open
#include <sys/mman.h>        // mmap
#include <unistd.h>          // close
#include "address_map.h"  // address map
#include "i2c_ip.h"         // i2c
#include "i2c_regs.h"       // registers

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------

uint32_t *base = NULL;

//-----------------------------------------------------------------------------
// Subroutines
//-----------------------------------------------------------------------------

bool i2cOpen()
{
    // Open /dev/mem
    int file = open("/dev/mem", O_RDWR | O_SYNC);
    bool bOK = (file >= 0);
    if (bOK)
    {
        // Create a map from the physical memory location of
        // /dev/mem at an offset to LW avalon interface
        // with an aperature of SPAN_IN_BYTES bytes
        // to any location in the virtual 32-bit memory space of the process
        base = mmap(NULL, SPAN_IN_BYTES, PROT_READ | PROT_WRITE, MAP_SHARED,
                    file, LW_BRIDGE_BASE +I2C_BASE_OFFSET);
        bOK = (base != MAP_FAILED);

        // Close /dev/mem
        close(file);
    }
    return bOK;
}




uint32_t read_i2c_status()
{
  uint32_t value = *(base+OFS_STATUS);
  return value;

}


void write_i2c_status_overflow_flag()
{
  *(base+OFS_STATUS) |= STATUS_OVERFLOW_WRITE;  
}


void write_i2c_data(uint8_t value)
{
  *(base+OFS_DATA) = value;
}

uint8_t read_i2c_data()
{
    uint8_t value = *(base+OFS_DATA);
    return value;
}

void write_i2c_control(uint32_t value)
{
     *(base+OFS_CONTROL) = value;
}

uint32_t read_i2c_control()
{
    uint32_t value = *(base+OFS_CONTROL);
    return value;
}
