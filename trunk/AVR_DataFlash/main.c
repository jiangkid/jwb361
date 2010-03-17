/******** 串口通信 中断接收 **********/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>
#include <string.h>
#include "uart.h"
#include "AT45DB041D.h"

//函数声明
void io_init(void);


/*IO口初始化函数*/
void io_init(void) {

	DDRA = 0x00;										
	PORTA = 0xFF;										
	DDRB = 0x00;										
	PORTB = 0xFF;										
	DDRC = 0x00;										/*不用的IO口建议设置为输入带上拉*/
	PORTC = 0xFF;
	DDRD = 0x00;
	PORTD = 0xFF;
	DDRE = 0x00;
	PORTE = 0xFF;
	DDRF = 0x00;
	PORTF = 0xFF;
	DDRG = 0x00;
	PORTG = 0xFF;
}


//define status
#define R_NULL		0x00
#define R_CMD		0x01
#define R_LEN_H		0x02
#define R_LEN_L		0x03
#define R_CONTENT	0x04

//define command
#define CMD_NULL		0x00
#define WR_DF			0x01	//write dataFlash
#define WR_DF_RSP		0x02	//write dataFlash response
#define RD_CHECK		0x03	//check dataFlash
#define RD_CHECK_RSP	0x04	//check dataFlash response

unsigned char r_status = R_NULL, cData = 0;
unsigned int currentLen = 0, tempData = 0;

//S_UARTFrame结构体定义
//command(1byte)		dataLen(2bytes)			data的内容
//WR_DF						2~266			页(2bytes,0~1013)+写入到flash的数据
//WR_DF_RSP					0					无
//RD_CHECK					4				页（2bytes,0~1013)+读取的数据量(2bytes,0~264)
//RD_CHECK_RSP				0~264			从flash读取的数据
struct S_UARTFrame{
	unsigned char cmd;		//1byte
	unsigned int dataLen;	//2bytes
	unsigned char *data;	//dataLen指定	
};

struct S_UARTFrame recvFrame;
struct S_UARTFrame sendFrame;
//接收中断，串口0
SIGNAL(SIG_UART0_RECV)
{
	cData = UDR0;
	switch(r_status)
	{
		case R_CMD:
			recvFrame.cmd = cData;
			r_status = R_LEN_L;
			break;
		case R_LEN_L:
			tempData = cData;
			r_status = R_LEN_H;
			break;
		case R_LEN_H:
			recvFrame.dataLen = cData;
			recvFrame.dataLen <<= 8;
			recvFrame.dataLen |= tempData;
			tempData = 0;
			currentLen = 0;
			recvFrame.data = malloc(recvFrame.dataLen);
			if(recvFrame.data != 0)
			{
				memset(recvFrame.data, 0, recvFrame.dataLen);
				r_status = R_CONTENT;
			}
			else
				printf("malloc error!\n");
			
			break;
		case R_CONTENT:
			*(recvFrame.data + currentLen) = cData;
			currentLen++;
			if (currentLen == recvFrame.dataLen)//接收完成
			{
				r_status = R_NULL;
			}
			break;
		default:
			break;
	}
}

/***************主函数****************************/

int main(void)
{
	unsigned char readBuffer[264] ={0};
	unsigned int page = 0, dataNum = 0;
	unsigned char *pData = 0;
	recvFrame.cmd = CMD_NULL;
	recvFrame.dataLen = 0;
	recvFrame.data = 0;
	//io_init();
	uart_init();
	SPI_Init();
	sei();				//总中断标志置位
	printf("Init OK!\n");
	
	 //擦除FLASH全部内容
	/*DF_Chip_Erase();
	//测试FLASH读写
	Test_Flash_Buffer_to_Buffer();			//ok
	Test_Flash_Page_to_Page();				//ok	
	Test_Flash_Buffer_Page_to_Page();			//ok
	Test_Flash_Buffer_Page_to_Page_Buffer();	//ok
*/
	r_status = R_CMD;
	while(1)
	{
		switch(recvFrame.cmd)
		{
			case WR_DF:
				if ((currentLen == recvFrame.dataLen) && (r_status == R_NULL))
				{					
					//将数据写到内存中(自动先写到BUFFER1 OR BURRER2中再将数据写到内存中)
					page = *(unsigned int *)recvFrame.data; 
					pData = recvFrame.data+2;
					Main_Memory_Page_Program_Through_Buffer(Buffer1, page, 0, pData, recvFrame.dataLen-2);
					currentLen = 0;
					recvFrame.cmd = CMD_NULL;
					recvFrame.dataLen = 0;
					r_status = R_CMD;
					free(recvFrame.data);
					
					//写dataFlash应答
					sendFrame.cmd = WR_DF_RSP;
					sendFrame.dataLen = 0;
					usart_send((char *)&sendFrame, sendFrame.dataLen+3, CH_USART0);		
				}
				break;
			case RD_CHECK:
				if ((currentLen == recvFrame.dataLen) && (r_status == R_NULL))				
				{
					currentLen = 0;
					recvFrame.cmd = CMD_NULL;
					recvFrame.dataLen = 0;
					r_status = R_CMD;
					//从内存中读取数据到数组rData中(直接读取数据不经过BUFFER1 OR BURRER2)
					page = *(unsigned int *)recvFrame.data;
					dataNum = *((unsigned int *)(recvFrame.data + 2));
					DF_Main_Memory_Page_Read(page, 0, readBuffer, dataNum);					
					sendFrame.cmd = RD_CHECK_RSP;
					sendFrame.dataLen = dataNum;
					sendFrame.data = readBuffer;
					usart_send((char *)&sendFrame, 3, CH_USART0);//send head
					usart_send((char *)&readBuffer, sendFrame.dataLen, CH_USART0);//send data
					free(recvFrame.data);//释放
				}
				break;
			default:
				break;

		}
		
		//DF_Main_Memory_Page_Read(page, 0, TestReadBuffer, 264);
		//page++;
		//count++;
		//c = usart0_char_receive();
		//usart0_char_send(c);
		//_delay_ms(1000);
	};
	return 0;
}
