#include <unistd.h>
#include "py/mpconfig.h"
#include "mpy.h"

/*
 * Core UART functions to implement for a port
 */

#if MICROPY_MIN_USE_STM32_MCU
typedef struct {
    volatile uint32_t SR;
    volatile uint32_t DR;
} periph_uart_t;
#define USART1 ((periph_uart_t *)0x40011000)
#endif

// Receive single character
int mp_hal_stdin_rx_chr(void) {
    while(MPY_UartReadAvail()==0);
    return MPY_UartRead();
}

// Send string of given length
mp_uint_t mp_hal_stdout_tx_strn(const char *str, mp_uint_t len) {
int i;
for(i=0;i < len;i++)
{
   while(MPY_UartWriteAvail()==0);
   MPY_UartWrite(str[i]); 
}
return len;
}
