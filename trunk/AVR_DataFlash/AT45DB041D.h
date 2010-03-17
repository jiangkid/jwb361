#ifndef _AT45DB041D_H
#define _AT45DB041D_H
#include <avr/io.h>
#include <util/delay.h>

//AT45DB041D有两个缓冲区Buffer1和Buffer2 (SRAM)

#define Buffer1       1
#define Buffer2       2
#define ReadBuffer    1
#define WriteBuffer   2

/******************************
*opcode-操作码
******************************/
//读取状态的操作码
#define Status_Register_Opcode   0xD7
//读取ID的操作码
#define Device_ID_Opcode         0x9F

//Read from buffer
#define Read_Data_from_Buffer1  0xD4
#define Read_Data_from_Buffer2  0xD6
#define Read_Data_from_Buffer1_lower_Frequency  0xD1   //lower frequency
#define Read_Data_from_Buffer2_lower_Frequency  0xD3   //lower frequency

//Write to buffer
#define Write_Data_to_Buffer1   0x84
#define Write_Data_to_Buffer2   0x87

//Read page to buffer
#define Read_Page_to_Buffer1   0x53
#define Read_Page_to_Buffer2   0x55

//Write buffer to page
#define Write_Buffer1_to_Page_whin_Erase   0x83
#define Write_Buffer2_to_Page_whin_Erase   0x86

//Continuous Array Read
#define Continuous_Array_Read_Command   0xE8

//Page to Buffer Compare
#define Page_to_Buffer1_Compare   0x60
#define Page_to_Buffer2_Compare   0x61

//Main Memory Page Program Through Buffer
#define Main_Memory_Page_Program_Through_Buffer1   0x82
#define Main_Memory_Page_Program_Through_Buffer2   0x85

//Main Memory Page Read
#define Main_Memory_Page_Read_Command   0xD2

/************************************************************
*SPI宏定义，ATmega128
************************************************************/
#define  SPI_DDR    	 DDRB
#define  SPI_PORT   	 PORTB

#define  RESET           4      //没有接ATmega128的IO口，接VCC3.3
#define  SS              0
#define  SCK             1
#define  MOSI            2
#define  MISO            3

void SPI_Init(void);
void DF_Manufacturer_and_Device_ID(unsigned char *ID);
void DF_Chip_Erase(void);
void Main_Memory_Page_Program_Through_Buffer(unsigned char BufferX,
                                             unsigned int PA,unsigned char BA,
	 						                 unsigned char *wData,unsigned int DataLen);
void DF_Continuous_Array_Read(unsigned int PA,unsigned char BA,
	 						  unsigned char *rData,unsigned int DataLen);
void DF_Main_Memory_Page_Read(unsigned int PA,unsigned char BA,
	 						  unsigned char *rData,unsigned int DataLen);
void DF_Read_Buffer_from_Page(unsigned char BufferX,unsigned int PA);
void DF_Write_Buffer_to_Page(unsigned char BufferX,unsigned int PA);
void DF_Read_from_Buffer(unsigned char BufferX,unsigned int BFA,
                         unsigned char *rData,unsigned int rDataLen);
void DF_Write_to_Buffer(unsigned char BufferX,unsigned int BFA,
                        unsigned char *wData,unsigned int wDataSize);
//test function
void Test_Flash_Buffer_to_Buffer();
void Test_Flash_Page_to_Page();	
void Test_Flash_Buffer_Page_to_Page();
void Test_Flash_Buffer_Page_to_Page_Buffer();

#endif
