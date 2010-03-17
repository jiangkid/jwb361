/************************************************************
*本驱动只用于AT45DB041D默认页大小为264的情况
*页改为256后可以有些不同
*页的大小只能改一次(从264改为256),不能改回
************************************************************/
//#include <iom16v.h>
//#include <macros.h>
#include "AT45DB041D.h"
//#include "eeprom.h"


/************************************************************
*使能FLASH(低电平使能)
************************************************************/
void Enable_DFLASH(void)
{
  _delay_us(10);
  SPI_PORT &= ~(1<<SS);
}
/************************************************************
*禁止FLASH(高电平禁止)
************************************************************/
void Disable_DFLASH(void)
{
  SPI_PORT |= (1<<SS);
  _delay_us(10);
}

/************************************************************
*初始化SPI
************************************************************/

void SPI_Init(void)
{
	SPI_DDR  |= ((1<<SS)|(1<<SCK)|(1<<MOSI));//设为输出
	SPI_DDR  &=~ (1<<MISO);                  //设为输入
	SPI_PORT |= (1<<SS)|(1<<SCK)|(1<<MOSI);  //输出高电平
	SPI_PORT |= (1<<MOSI);				   //上拉
	SPI_DDR|=(1<<RESET);                     //复位引脚设为输出
	//SPI使能, master模式, MSB 前,  SPI 模式 3, SCK频率为fosc/4 平时SCK为高电平
	SPCR |= (1<<SPE)|(1<<MSTR)|(1<<CPHA)|(1<<CPOL);
	//频率加倍,SCK频率为fosc/2
	SPSR |= (1<<SPI2X);
	Disable_DFLASH();
}

unsigned char SPI_Transfer(unsigned char data)
{
    unsigned char tempData;
	//printf("spi_transfer:0x%02x \t ", data);
	SPDR = data;
    while(!(SPSR & (1<<SPIF))); // 等待传输结束
	tempData = SPDR;
	//printf("get 0x%02x\n", tempData);
	return tempData;
}

/************************************************************
*读取FLASH内部状态寄存器
*Bit 7:Ready/busy status (1:no busy ; 0:busy)
*Bit 6:Compare (1: no matche ; 0:matche) 最近的一次比较结果
*Bit 0:PAGE SIZE (1:256 bytes ; 0:264 bytes)
************************************************************/
unsigned char DF_Read_status_Register(void)
{
  unsigned char rData=0;
  Enable_DFLASH();
  SPI_Transfer(Status_Register_Opcode);//write opcode
  rData = SPI_Transfer(0x00);//read device's status
  Disable_DFLASH();
  return rData;
}
/************************************************************
*读取FLASH的页大小
*返回1表示每一页的大小为264 bytes,否则为256 bytes
************************************************************/
unsigned char DF_Check_Page_Size(void)
{
  unsigned char Page_Size;
  Page_Size=DF_Read_status_Register();
  if(Page_Size&0x01) return 0;
  return 1;
}
/************************************************************
*读取FLASH忙标志位(最多判断255次,不行还是返回且返回0)
************************************************************/
unsigned char DF_Check_Busy_State(void)
{
  unsigned char state;
  unsigned char i=255;
  while(i)
  {
     state=DF_Read_status_Register();
	 if(state & 0x80) break;		//读取的最高位0时器件忙
	 --i;
  }
  return i;
}
/************************************************************
*读取FLASH的产家ID的芯片ID等内容;
*以下函数会返回四个值,第一个数对AT45DB041D来说为0x1F;
*第四个数为 0x00;
*用此函数可以判断芯片的好坏,是否正常;
************************************************************/
void DF_Manufacturer_and_Device_ID(unsigned char *ID)
{
  unsigned char i;

  DF_Check_Busy_State();

  Enable_DFLASH();

  SPI_Transfer(Device_ID_Opcode);

  for(i=0;i<4;i++)
  {
    ID[i] = SPI_Transfer(0);
  }

  Disable_DFLASH();
}

/************************************************************
*使FLASH进入Deep_Power_Down
************************************************************/
void DF_Deep_Power_Down(void)
{
  DF_Check_Busy_State();
  Enable_DFLASH();
  SPI_Transfer(0xB9);//写Deep Power-down操作码
  Disable_DFLASH();
}
/************************************************************
*使FLASH退出Deep_Power_Down
************************************************************/
void DF_Resume_from_Deep_Power_Down(void)
{
  DF_Check_Busy_State();
  Enable_DFLASH();
  SPI_Transfer(0xAB);//写Resume from Deep Power-down操作码
  Disable_DFLASH();
}
/************************************************************
*使能扇区保护
************************************************************/
void DF_Enable_Sector_Protection(void)
{
  unsigned char Enable_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xA9}; //使能扇区保护操作码
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
	  SPI_Transfer(Enable_Sector_Protection_Command[i]);//写使能扇区保护操作码
  }
  Disable_DFLASH();
}
/************************************************************
*禁止扇区保护
************************************************************/
void DF_Disable_Sector_Protection(void)
{
  unsigned char Disable_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0x9A};//禁止扇区保护操作码
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Disable_Sector_Protection_Command[i]);//写禁止扇区保护操作码
  }
  Disable_DFLASH();
}
/************************************************************
*擦除扇区保护
************************************************************/
void DF_Erase_Sector_Protection_Register(void)
{
  unsigned char Erase_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xCF};//擦除扇区保护操作码
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Erase_Sector_Protection_Command[i]);//写擦除扇区保护操作码
  }
  Disable_DFLASH();
}
/************************************************************
*设置扇区保护
*注意:会改变BUFFER1中的内容
*Sector_Protection_Register:数组中的0~7字节对对应0~7个扇区(0xFF:写保护)(0x00:擦除保护)

The Sector Protection Register can be reprogrammed while the sector protection enabled or dis-
abled. Being able to reprogram the Sector Protection Register with the sector protection enabled
allows the user to temporarily disable the sector protection to an individual sector rather than
disabling sector protection completely
************************************************************/
void DF_Program_Sector_Protection_Register(unsigned char *Sector_Protection_Register)
{
  unsigned char Program_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xFC};//设置扇区保护操作码
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Program_Sector_Protection_Command[i]);//写设置扇区保护操作码
  }
  for(i=0;i<8;i++)
  {
      SPI_Transfer(Sector_Protection_Register[i]);//写设置扇区保护数据
  }
  Disable_DFLASH();
}
/************************************************************
*读取扇区保护寄存器内容(返回8个字节,对应8个扇区的情况)
---------------------------------------
|Sector Number |0 (0a, 0b)  |1 to 7   |
---------------------------------------
|Protected	   |            | FFH     |
----------------   See PDF  -----------
|Unprotected   |            | 00H	  |
---------------------------------------
************************************************************/
void DF_Read_Sector_Protection_Register(unsigned char *Sector_Protection_Register)
{
  unsigned char Read_Sector_Protection_Register_Command[4]={0x32,0,0,0};
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();

  for(i=0;i<4;i++)//write
  {
    SPI_Transfer(Read_Sector_Protection_Register_Command[i]);
  }
  for(i=0;i<8;i++)//read
  {
    Sector_Protection_Register[i] = SPI_Transfer(0);
  }
  Disable_DFLASH();
}
/************************************************************
*取消所有扇区保护
*返回1表示成功取消扇区所以保护
************************************************************/
unsigned char DF_Cancel_Sector_Protection(void)
{
  unsigned char Sector_Protection_Register_for_Write[8]={0,0,0,0,0,0,0,0};//写入0为去保护
  unsigned char Sector_Protection_Register_for_Read[8]={1,1,1,1,1,1,1,1};//防止默认值为0
  unsigned int i;
  unsigned char j=1;
  //使能扇区保护
  DF_Enable_Sector_Protection();
  //设置扇区保护

  DF_Program_Sector_Protection_Register(Sector_Protection_Register_for_Write);
  //读取扇区保护寄存器内容
  DF_Read_Sector_Protection_Register(Sector_Protection_Register_for_Read);
  //判断扇区保护寄存器内容
  for(i=0;i<8;i++)
  {
    if(Sector_Protection_Register_for_Read[i]!=0) j++;
  }
  //禁止扇区保护
  DF_Disable_Sector_Protection();

  return j;
}
/************************************************************
*设置扇区锁(被锁后不能再次解锁)
*被设置的扇区就只能读不能写
*非一般情况不要使用(除非数据不用再改)
*Sector_Addr :地址在哪个扇区中就会锁上那个扇区
************************************************************/
void DF_Program_Sector_Lockdown(unsigned long Sector_Addr)
{
  //unsigned char Sector_Lockdown_Command=[4]={0x3D,0x2A,0x7F,0x30};//加锁操作码
  unsigned char Sector_Lockdown_Command[4]={0x00,0x00,0x00,0x00};//防止写到,这里乱写
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();

  for(i=0;i<4;i++)//write
  {
    SPI_Transfer(Sector_Lockdown_Command[i]);
  }

  //write address
  SPI_Transfer((unsigned char)(Sector_Addr>>16));
  SPI_Transfer((unsigned char)(Sector_Addr>>8));
  SPI_Transfer((unsigned char)Sector_Addr);

  Disable_DFLASH();
}
/************************************************************
*读取扇区加锁寄存器(返回8个扇区的加锁寄存器值)
*如果有读到不为0的表示已被加锁
*(0扇区的高四位为0也表示没加锁,其它扇区一定要全为O)
************************************************************/
void DF_Read_Sector_Lockdown_Register(unsigned char *Sector_Lockdown_Register)
{
  unsigned char Read_Sector_Lockdown_Register[4]={0x35,0x00,0x00,0x00};
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();

  for(i=0;i<4;i++)//write
  {
    SPI_Transfer(Read_Sector_Lockdown_Register[i]);
  }
  for(i=0;i<8;i++)//read
  {
    Sector_Lockdown_Register[i] = SPI_Transfer(0);
  }
  Disable_DFLASH();
}
/************************************************************
*写数据到缓冲器(Buffer1或Buffer2)(缓冲器大小为264 bytes)
*BufferX   :选择缓冲器(Buffer1或Buffer2)
*BFA       :Buffer内存地址 0~263
*wData     :要写入的数据
*wDataSize :要写入的数据长度(1~264)
************************************************************/
void DF_Write_to_Buffer(unsigned char BufferX,unsigned int BFA,
                        unsigned char *wData,unsigned int wDataSize)
{
  unsigned int i;

  DF_Check_Busy_State();            //check busy bit

  Enable_DFLASH();

  if(BufferX == Buffer1)  SPI_Transfer(Write_Data_to_Buffer1);//0x84
  else                    SPI_Transfer(Write_Data_to_Buffer2);//0x87

  //Page Size (264 Bytes)
  //15 don't care bits + 9 addrress
  SPI_Transfer(0xFF);                      //8 can't care bits
  SPI_Transfer((unsigned char)(BFA>>8));   //7 can't care bits + 1 bit address
  SPI_Transfer((unsigned char)BFA);        //address

  for(i=0;i<wDataSize;i++)  SPI_Transfer(wData[i]);//写入数据

  Disable_DFLASH();
}
/************************************************************
*读取缓冲器(Buffer1或Buffer2)(缓冲器大小为264 bytes)中的数据
*BufferX   :选择缓冲器(Buffer1或Buffer2)
*BFA       :Buffer内存地址 0~263
*wData     :存放读到的数据
*wDataSize :要写入的数据长度(1~264)
*注意:高速和低速发的操作码和要发送的数据长度不同
************************************************************/
void DF_Read_from_Buffer(unsigned char BufferX,unsigned int BFA,
                         unsigned char *rData,unsigned int rDataLen)
{
  unsigned int i;

  DF_Check_Busy_State();            //check busy bit

  Enable_DFLASH();

  if(BufferX == Buffer1)  SPI_Transfer(Read_Data_from_Buffer1);//0xD4 or 0xD1(lower frequency)
  else                    SPI_Transfer(Read_Data_from_Buffer2);//0xD6 or 0xD3(lower frequency)

  //Page Size (264 Bytes)
  //15 don't care bits + 9 addrress
  SPI_Transfer(0xFF);                      //8 can't care bits
  SPI_Transfer((unsigned char)(BFA>>8));   //7 can't care bits
  SPI_Transfer((unsigned char)BFA);        //address
  SPI_Transfer(0xFF);       				 //1 can't care byte (lower frequency 不用这个字节)

  for(i=0;i<rDataLen;i++)  rData[i] = SPI_Transfer(0xFF);//读取数据

  Disable_DFLASH();
}
/************************************************************
*把缓冲器(Buffer1或Buffer2)中的数据写到内存的页中(写整页)
*先擦除再写数据(硬件支持的带擦除写)
*BufferX   :选择缓冲器(Buffer1或Buffer2)
*PA        :内存中页的地址 0~2047
************************************************************/
void DF_Write_Buffer_to_Page(unsigned char BufferX,unsigned int PA)
{
  DF_Check_Busy_State();

  Enable_DFLASH();

  if(BufferX == Buffer1)  SPI_Transfer(Write_Buffer1_to_Page_whin_Erase);//0x83
  else                    SPI_Transfer(Write_Buffer2_to_Page_whin_Erase);//0x86

  //Page Size (264 Bytes)
  //4 don't care bits + 11 address + 9 don't care bits
  SPI_Transfer((unsigned char)(PA>>7));
  SPI_Transfer((unsigned char)(PA<<1));
  SPI_Transfer(0xFF);                         //8 don't care bits

  Disable_DFLASH();
}
/************************************************************
*读取内存的页(整页)的数据到缓冲器(Buffer1或Buffer2)中
*BufferX   :选择缓冲器(Buffer1或Buffer2)
*PA        :内存中页的地址 0~2047
************************************************************/
void DF_Read_Buffer_from_Page(unsigned char BufferX,unsigned int PA)
{
  DF_Check_Busy_State();

  Enable_DFLASH();

  if(BufferX == Buffer1)  SPI_Transfer(Read_Page_to_Buffer1);//0x53
  else                    SPI_Transfer(Read_Page_to_Buffer2);//0x55

  //Page Size (264 Bytes)
  //4 don't care bits + 11 address + 9 don't care bits
  SPI_Transfer((unsigned char)(PA>>7));
  SPI_Transfer((unsigned char)(PA<<1));
  SPI_Transfer(0xFF); //8 don't care bits

  Disable_DFLASH();
}
/************************************************************
*将数据写到内存中(自动先写到BUFFER1 OR BURRER2中再将数据写到内存中)
*BufferX   :选择自动先写入的缓冲器(Buffer1或Buffer2)
*PA        :内存中的页地址0~2047
*BA        :从页中的这个地址开始写数据,会自动转到下一页(0~263)
*当写到最后一页的最后一个地址时,会自动转到第一页开始写
*wData     :要写入的数据
*DataLen   :要写入的数据长度
************************************************************/
void Main_Memory_Page_Program_Through_Buffer(unsigned char BufferX,
                                             unsigned int PA,unsigned char BA,
	 						                 unsigned char *wData,unsigned int DataLen)
{
  unsigned int i;
  DF_Check_Busy_State();
  Enable_DFLASH();

  if(BufferX == Buffer1)  SPI_Transfer(Main_Memory_Page_Program_Through_Buffer1);//0x82
  else                    SPI_Transfer(Main_Memory_Page_Program_Through_Buffer2);//0x85

  //4 bits(don't care bits) + 11 bits(page address)+9(address in the page)
  SPI_Transfer((unsigned char)(PA>>7));
  SPI_Transfer((unsigned char)((PA<<1)|(BA>>8)));
  SPI_Transfer((unsigned char)BA);

  for(i=0;i<DataLen;i++)	SPI_Transfer(wData[i]);

  Disable_DFLASH();
}
/************************************************************
*从内存中读取数据到数组rData中(直接读取数据不经过BUFFER1 OR BURRER2)
*PA        :内存中的页地址0~2047
*BA        :从页中的这个地址开始读数据,会自动转到下一页(0~263)
*当读到最后一页的最后一个地址时,会自动转到第一页开始读取
*rData     :存放读到的数据
*DataLen   :要读取的数据长度
*与DF_Continuous_Array_Read一样的功能但与Buffer有关,但不改变Buffer中的数据
************************************************************/
void DF_Main_Memory_Page_Read(unsigned int PA,unsigned char BA,
	 						  unsigned char *rData,unsigned int DataLen)
{
  unsigned int i;
  DF_Check_Busy_State();

  Enable_DFLASH();

  SPI_Transfer(Main_Memory_Page_Read_Command);//0xD2

  //4 bits(don't care bits) + 11 bits(page address)+9(address in the page)
  SPI_Transfer((unsigned char)(PA>>7));
  SPI_Transfer((unsigned char)((PA<<1)|(BA>>8)));
  SPI_Transfer((unsigned char)BA);
  //4 don’t care bytes
  for(i=0;i<4;i++)	SPI_Transfer(0xFF);

  for(i=0;i<DataLen;i++)  rData[i] = SPI_Transfer(0xFF);//读取数据

  Disable_DFLASH();
}
/************************************************************
*从内存中读取数据到数组rData中(直接读取数据不经过BUFFER1 OR BURRER2)
*PA        :内存中的页地址0~2047
*BA        :从页中的这个地址开始读数据,会自动转到下一页(0~263)
*当读到最后一页的最后一个地址时,会自动转到第一页开始读取
*rData     :存放读到的数据
*DataLen   :要读取的数据长度
*与DF_Main_Memory_Page_Read一样的功能但与Buffer无关
************************************************************/
void DF_Continuous_Array_Read(unsigned int PA,unsigned char BA,
	 						  unsigned char *rData,unsigned int DataLen)
{
  unsigned int i;
  DF_Check_Busy_State();

  Enable_DFLASH();

  SPI_Transfer(Continuous_Array_Read_Command);//0xE8

  //4 bits(don't care bits) + 11 bits(page address)+9(address in the page)
  SPI_Transfer((unsigned char)(PA>>7));
  SPI_Transfer((unsigned char)((PA<<1)|(BA>>8)));
  SPI_Transfer((unsigned char)BA);
  //4 don’t care bytes
  for(i=0;i<4;i++)	SPI_Transfer(0xFF);

  for(i=0;i<DataLen;i++)  rData[i] = SPI_Transfer(0xFF);//读取数据

  Disable_DFLASH();
}
/************************************************************
*擦除FLASH全部内容
*not affect sectors that are protected or locked down
************************************************************/
void DF_Chip_Erase(void)
{
  unsigned char Chip_Erase_Command[4]={0xC7,0x94,0x80,0x9A};//整片擦除操作码
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();

  for(i=0;i<4;i++)
  {
     SPI_Transfer(Chip_Erase_Command[i]);
  }

  Disable_DFLASH();
}

/************************************************************
*FLASH复位
************************************************************/
void DF_Reset(void)
{
  SPI_PORT&=~(1<<RESET);	//使能复位
  _delay_us(10);
  SPI_PORT|=(1<<RESET);     //禁止复位
  _delay_us(10);
}
/************************************************************
*Test DataFlash
************************************************************/
//Test_Flash_Buffer_to_Buffer
void Test_Flash_Buffer_to_Buffer(void)
{
  unsigned char TestWriteBuffer[10]={1,2,3,4,5,6,7,8,9,10};
  unsigned char TestReadBuffer[10] ={0,0,0,0,0,0,0,0,0,0};

  //写数据到Buffer中
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //从Buffer中读取数据
  DF_Read_from_Buffer(Buffer1,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//把要写入的和读出的数据写入EEPROM用于比较
  {
    eeprom_write_byte((i+16*0),TestWriteBuffer[i]);
	eeprom_write_byte((i+16*1),TestReadBuffer[i]);
  }*/
}

//Test_Flash_Page_to_Page
void Test_Flash_Page_to_Page(void)
{
  unsigned char TestWriteBuffer[10]={10,9,8,7,6,5,4,3,2,1};
  unsigned char TestReadBuffer[10] ={0,0,0,0,0,0,0,0,0,0};
  
  //将数据写到内存中(自动先写到BUFFER1 OR BURRER2中再将数据写到内存中)
  Main_Memory_Page_Program_Through_Buffer(Buffer1,0,0,TestWriteBuffer,10);
  //从内存中读取数据到数组rData中(直接读取数据不经过BUFFER1 OR BURRER2)
  DF_Main_Memory_Page_Read(0,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//把要写入的和读出的数据写入EEPROM用于比较
  {
    eeprom_write_byte((i+16*2),TestWriteBuffer[i]);
	eeprom_write_byte((i+16*3),TestReadBuffer[i]);
  }*/
}

//Test_Flash_Buffer_Page_to_Page
void Test_Flash_Buffer_Page_to_Page(void)
{
  unsigned char TestWriteBuffer[10]={1,2,3,4,5,6,7,8,9,10};
  unsigned char TestReadBuffer[10] ={0,0,0,0,0,0,0,0,0,0};
  //写数据到Buffer中
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //将Buffer中的数据写到DataFlash中
  DF_Write_Buffer_to_Page(Buffer1,0);
  //读出DataFlash中的数据
  //DF_Main_Memory_Page_Read(0,0,TestReadBuffer,10);
  DF_Continuous_Array_Read(0,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//把要写入的和读出的数据写入EEPROM用于比较
  {
    eeprom_write_byte((i+16*4),TestWriteBuffer[i]);
	eeprom_write_byte((i+16*5),TestReadBuffer[i]);
  }*/
}

//Test_Flash_Buffer_Page_to_Page_Buffer
void Test_Flash_Buffer_Page_to_Page_Buffer(void)
{
  unsigned char TestWriteBuffer[10]={10,9,8,7,6,5,4,3,2,1};
  unsigned char TestReadBuffer[10] ={0,0,0,0,0,0,0,0,0,0};

  //写数据到Buffer中
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //将Buffer中的数据写到Page中
  DF_Write_Buffer_to_Page(Buffer1,0);
  //从Page中读取数据到Buffer中
  DF_Read_Buffer_from_Page(Buffer1,0);
  //从Buffer中读取数据
  DF_Read_from_Buffer(Buffer1,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//把要写入的和读出的数据写入EEPROM用于比较
  {
    eeprom_write_byte((i+16*6),TestWriteBuffer[i]);
	eeprom_write_byte((i+16*7),TestReadBuffer[i]);
  }*/
}
/************************************************************
*主函数
***********************************************************

void running(void)
{
	unsigned int count = 0;
	while(1)
	{
		count++;
		printf("count:%d\n",count);
		_delay_ms(1000);
	};
}
int main(void)
{
  unsigned int i, tempData;

  unsigned char Temp_Sector_Lockdown_Register[8];
  //DDRA =0XFF;
  //PORTA=0X01;  //指示灯起始状态
  uart_init();

  //FLASH初始化(SPI初始化)
  SPI_Init();
  //Flash复位
  DF_Reset();

  //读取FLASH内部状态寄存器
  //unsigned char Test_Buf[4];
  //DF_Manufacturer_and_Device_ID(Test_Buf);


  //读取扇区加锁寄存器
  //DF_Read_Sector_Lockdown_Register(Temp_Sector_Lockdown_Register);
  //for(i=0;i<8;i++)
  //{
  //  eeprom_write_byte(i,Temp_Sector_Lockdown_Register[i]);
  //}

  //取消所有扇区保护
  //if(DF_Cancel_Sector_Protection()) PORTA=0X18;//OK

  //测试FLASH产家ID  读到为0x1F才算正常
  //if(Test_Manufacturer_ID()) PORTA=0x1F;

  //使FLASH进入Deep_Power_Down
  //DF_Deep_Power_Down();

  //使FLASH退出Deep_Power_Down
  //DF_Resume_from_Deep_Power_Down();

  //擦除FLASH全部内容
  DF_Chip_Erase();

  //测试FLASH读写
  Test_Flash_Buffer_to_Buffer();			//ok
  Test_Flash_Page_to_Page();				//ok	
  Test_Flash_Buffer_Page_to_Page();			//ok
  Test_Flash_Buffer_Page_to_Page_Buffer();	//ok
  running();
  //PORTA=0X80;  //程序执行完成状态
  while(1)
  {
    asm("sei");
  }
}
*/
