// I2C IP Library Registers
// Krutika Nerurkar

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board
// Target uC:       -
// System Clock:    -

// Hardware configuration:
// I2C IP core connected to light-weight Avalon bus

//-----------------------------------------------------------------------------
// Device includes, defines, and assembler directives
//-----------------------------------------------------------------------------

#ifndef I2C_REGS_H_
#define I2C_REGS_H_

#define OFS_ADDRESS           0
#define OFS_DATA              1
#define OFS_STATUS            2
#define OFS_CONTROL           3

#define SPAN_IN_BYTES 16

# define Control_WRITE  0x00000001
# define STATUS_OVERFLOW_WRITE  0x00000008

#endif

