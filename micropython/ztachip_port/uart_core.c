#include <unistd.h>
#include "py/mpconfig.h"

/*
 * Core UART functions to implement for a port
 */

#define APB ((volatile unsigned int *)0xC0000000)

// APB register map

#define APB_LED               0

#define APB_PB                2

#define APB_VIDEO_BUFFER      11

#define APB_VIDEO_ENABLE      9

#define APB_CAMERA_BUFFER     5

#define APB_CAMERA_ENABLE     3

#define APB_CAMERA_CURR_FRAME 4

#define APB_UART_READ         15

#define APB_UART_WRITE        16

#define APB_UART_READ_AVAIL   17

#define APB_UART_WRITE_AVAIL  18




#if MICROPY_MIN_USE_STM32_MCU
typedef struct {
    volatile uint32_t SR;
    volatile uint32_t DR;
} periph_uart_t;
#define USART1 ((periph_uart_t *)0x40011000)
#endif

// Receive single character
int mp_hal_stdin_rx_chr(void) {
while(APB[APB_UART_READ_AVAIL]==0);
return APB[APB_UART_READ];
}

// Send string of given length
mp_uint_t mp_hal_stdout_tx_strn(const char *str, mp_uint_t len) {
int i;
for(i=0;i < len;i++)
{
   while(APB[APB_UART_WRITE_AVAIL]==0);
   APB[APB_UART_WRITE]=str[i]; 
}
return len;
}
