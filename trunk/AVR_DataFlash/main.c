/******** ����ͨ�� �жϽ��� **********/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdlib.h>
#include <string.h>
#include "uart.h"
#include "AT45DB041D.h"

//��������
void io_init(void);


/*IO�ڳ�ʼ������*/
void io_init(void) {

	DDRA = 0x00;										
	PORTA = 0xFF;										
	DDRB = 0x00;										
	PORTB = 0xFF;										
	DDRC = 0x00;										/*���õ�IO�ڽ�������Ϊ���������*/
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

//S_UARTFrame�ṹ�嶨��
//command(1byte)		dataLen(2bytes)			data������
//WR_DF						2~266			ҳ(2bytes,0~1013)+д�뵽flash������
//WR_DF_RSP					0					��
//RD_CHECK					4				ҳ��2bytes,0~1013)+��ȡ��������(2bytes,0~264)
//RD_CHECK_RSP				0~264			��flash��ȡ������
struct S_UARTFrame{
	unsigned char cmd;		//1byte
	unsigned int dataLen;	//2bytes
	unsigned char *data;	//dataLenָ��	
};

struct S_UARTFrame recvFrame;
struct S_UARTFrame sendFrame;
//�����жϣ�����0
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
			if (currentLen == recvFrame.dataLen)//�������
			{
				r_status = R_NULL;
			}
			break;
		default:
			break;
	}
}

/***************������****************************/

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
	sei();				//���жϱ�־��λ
	printf("Init OK!\n");
	
	 //����FLASHȫ������
	/*DF_Chip_Erase();
	//����FLASH��д
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
					//������д���ڴ���(�Զ���д��BUFFER1 OR BURRER2���ٽ�����д���ڴ���)
					page = *(unsigned int *)recvFrame.data; 
					pData = recvFrame.data+2;
					Main_Memory_Page_Program_Through_Buffer(Buffer1, page, 0, pData, recvFrame.dataLen-2);
					currentLen = 0;
					recvFrame.cmd = CMD_NULL;
					recvFrame.dataLen = 0;
					r_status = R_CMD;
					free(recvFrame.data);
					
					//дdataFlashӦ��
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
					//���ڴ��ж�ȡ���ݵ�����rData��(ֱ�Ӷ�ȡ���ݲ�����BUFFER1 OR BURRER2)
					page = *(unsigned int *)recvFrame.data;
					dataNum = *((unsigned int *)(recvFrame.data + 2));
					DF_Main_Memory_Page_Read(page, 0, readBuffer, dataNum);					
					sendFrame.cmd = RD_CHECK_RSP;
					sendFrame.dataLen = dataNum;
					sendFrame.data = readBuffer;
					usart_send((char *)&sendFrame, 3, CH_USART0);//send head
					usart_send((char *)&readBuffer, sendFrame.dataLen, CH_USART0);//send data
					free(recvFrame.data);//�ͷ�
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
