/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <joerg@FreeBSD.ORG> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.        Joerg Wunsch
 * ----------------------------------------------------------------------------
 *
 * Stdio demo, UART declarations
 *
 * $Id: uart.h,v 1.1 2005/12/28 21:38:59 joerg_wunsch Exp $
 */

/*
 * Perform UART startup initialization.
 */
#include <stdio.h>
#define Crystal 11059200   //晶振11.059200MHZ 
#define Baud0 115200         //串口0波特率
#define Baud1 115200         //串口1波特率

#define CH_USART0 0
#define CH_USART1 1

void	uart_init(void);
void usart0_char_send(unsigned char data);
void usart1_char_send(unsigned char data);
void usart_send(char *s, unsigned int len, char channel);
/*
 * Send one character to the UART.
 */
int	uart_putchar(char c, FILE *stream);

/*
 * Size of internal line buffer used by uart_getchar().
 */
#define RX_BUFSIZE 80

/*
 * Receive one character from the UART.  The actual reception is
 * line-buffered, and one character is returned from the buffer at
 * each invokation.
 */
int	uart_getchar(FILE *stream);
