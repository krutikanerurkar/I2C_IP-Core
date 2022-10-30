// I2C IP Example, i2c.c
// I2C Shell Command
// Krutika Nerurkar

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// GPIO Port:
//   GPIO_1[31-0] is used as a general purpose GPIO port


//-----------------------------------------------------------------------------

#include <stdlib.h>          // EXIT_ codes
#include <stdio.h>           // printf
#include "i2c_ip.h"         // I2C IP library

int main(int argc, char* argv[])
{
    uint32_t value;
    if (argc == 4)
    {
        i2cOpen();
        value = atoi(argv[3]);
        if (strcmp(argv[1], "write") == 0 && strcmp(argv[2], "control") == 0)
         {
            write_i2c_control(value);
         }
        else if (strcmp(argv[1], "write") == 0 && strcmp(argv[2], "data") == 0)
         {
             write_i2c_data(value);
         }

    }
     

    else if(argc == 3)
    {
       i2cOpen();
       if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "control") == 0)
          {
            printf("The value is %d \n",read_i2c_control()); 
          }

      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "tx_overflow_status") == 0)//decimal 8
         {
                value = (read_i2c_status()&0x00000008);
              
              printf("The value is %d \n", value); 
         }
       
      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "tx_full_status") == 0)// decimal 16
         {
               value = (read_i2c_status()&0x00000010);
              
              printf("The value is %d \n",value); 
         }
      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "tx_empty_status") == 0)// decimal 32
         {
                 value = (read_i2c_status()& 0x00000020);
                 
              
              printf("The value is %d \n",(value>>5)); 
         }
      
      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "wr_index_status") == 0)
         {
               value = (read_i2c_status()&0x00003F00);
               
              
              printf("The value is %d \n",(value>>8)); 
         }
      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "rd_index_status") == 0)
         {
               value = (read_i2c_status()&0x000FC000);
              
              printf("The value is %d \n", (value>>14)); 
         }
      else if (strcmp(argv[1], "read") == 0 && strcmp(argv[2], "data") == 0)
         {
              uint8_t  val = read_i2c_data();
              
              printf("The value is %d \n",val); 
         } 
      else if (strcmp(argv[1], "write") == 0 && strcmp(argv[2], "status_overflow") == 0)
         {
           write_i2c_status_overflow_flag();
         }  
      
    }    
   
     else if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0))
       {
        printf("  usage:\n");
        printf("  i2c write control  value                          \n");
        printf("  i2c read control                                  \n");
        printf("  i2c read tx_overflow_status                       \n");
        
        printf("  i2c read tx_overflow_status                       \n");
        printf("  i2c read tx_full_status                           \n");
        printf("  i2c read tx_empty_status                          \n");
        printf("  i2c read wr_index_status                          \n");
        printf("  i2c read rd_index_status                          \n");
        printf("  i2c write status_overflow                         \n");
        printf("  i2c read data                                     \n");
        printf("  i2c write data value                              \n");    
        
      }
   
    else
        printf("  command not understood\n");
    return EXIT_SUCCESS;
}

