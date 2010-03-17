/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <joerg@FreeBSD.ORG> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.        Joerg Wunsch
 * ----------------------------------------------------------------------------
 *
 * Stdio demo, UART implementation
 *
 * $Id: uart.c,v 1.1 2005/12/28 21:38:59 joerg_wunsch Exp $
 */
#include <stdint.h>
#include <stdio.h>
#include <avr/io.h>
#include "uart.h"

FILE uart_str = FDEV_SETUP_STREAM(uart_putchar, 0, _FDEV_SETUP_RW);
int uart_putchar(char c, FILE *stream)
{

  if (c == '\a')
    {
      fputs("*ring*\n", stderr);
      return 0;
    }

  if (c == '\n')
    uart_putchar('\r', stream);
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;

  return 0;
}
//*串口初始化函数*/
void uart_init(void)
{
	/* 初始化串口0 */
	UCSR0A = (1 << U2X0);								/*倍速*/
	UCSR0B = (1 << TXEN0) | (1 << RXEN0)| (1<<RXCIE0); 				/*允许接收和发送，中断接收*/
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);				/*8位数据、1 位停止、异步、无校验*/
	UBRR0L = Crystal/8/(Baud0+1) % 256;   //若为正常异步模式USX0=0则位(Crystal/16/(Baud+1))%BUFFSIZE
	UBRR0H = Crystal/8/(Baud0+1) / 256;   //
	
	/* 初始化串口1 */
	UCSR0A = (1 << U2X1);								/*倍速*/
	UCSR1B = (1 << TXEN1) | (1 << RXEN1) | (1<<RXCIE1);				/*允许接收和发送，中断接收*/
	UCSR1C = (1 << UCSZ11) | (1 << UCSZ10);				/*8位数据、1 位停止、异步、无校验*/
	UBRR1L = Crystal/8/(Baud1+1) % 256;   //若为正常异步模式USX0=0则位(Crystal/16/(Baud+1))%BUFFSIZE
	UBRR1H = Crystal/8/(Baud1+1) / 256;   //
	stdout = stdin = &uart_str;
	printf("USART Init OK!\n");

}

//****************发送一个字符******************************
void usart0_char_send(unsigned char data)
{
	/* 等待发送缓冲区为空 */
	while (!(UCSR0A & (1<<UDRE0)));
	/* 将数据放入缓冲区，发送数据 */
	UDR0 = data;
}
//****************发送一个字符******************************
void usart1_char_send(unsigned char data)
{
	/* 等待发送缓冲区为空 */
	while (!(UCSR1A & (1<<UDRE1)));
	/* 将数据放入缓冲区，发送数据 */
	UDR1 = data;
}

//******************发送字符串*************************/
void usart_send(char *s, unsigned int len, char channel)
{
	void (*f)(unsigned char data);
	//unsigned int i;
	if (CH_USART1 == channel)
		f = usart1_char_send;
	else
		f = usart0_char_send;

	while(len--)
	{
		(*f)(*s);
		s++;
	}
}

/*****************接收一个字符****************************/
unsigned char usart0_char_receive(void)
{
	while (!(UCSR0A & (1<<RXC0)));
	return UDR0;
}





