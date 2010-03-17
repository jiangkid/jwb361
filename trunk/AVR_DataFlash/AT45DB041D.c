/************************************************************
*������ֻ����AT45DB041DĬ��ҳ��СΪ264�����
*ҳ��Ϊ256�������Щ��ͬ
*ҳ�Ĵ�Сֻ�ܸ�һ��(��264��Ϊ256),���ܸĻ�
************************************************************/
//#include <iom16v.h>
//#include <macros.h>
#include "AT45DB041D.h"
//#include "eeprom.h"


/************************************************************
*ʹ��FLASH(�͵�ƽʹ��)
************************************************************/
void Enable_DFLASH(void)
{
  _delay_us(10);
  SPI_PORT &= ~(1<<SS);
}
/************************************************************
*��ֹFLASH(�ߵ�ƽ��ֹ)
************************************************************/
void Disable_DFLASH(void)
{
  SPI_PORT |= (1<<SS);
  _delay_us(10);
}

/************************************************************
*��ʼ��SPI
************************************************************/

void SPI_Init(void)
{
	SPI_DDR  |= ((1<<SS)|(1<<SCK)|(1<<MOSI));//��Ϊ���
	SPI_DDR  &=~ (1<<MISO);                  //��Ϊ����
	SPI_PORT |= (1<<SS)|(1<<SCK)|(1<<MOSI);  //����ߵ�ƽ
	SPI_PORT |= (1<<MOSI);				   //����
	SPI_DDR|=(1<<RESET);                     //��λ������Ϊ���
	//SPIʹ��, masterģʽ, MSB ǰ,  SPI ģʽ 3, SCKƵ��Ϊfosc/4 ƽʱSCKΪ�ߵ�ƽ
	SPCR |= (1<<SPE)|(1<<MSTR)|(1<<CPHA)|(1<<CPOL);
	//Ƶ�ʼӱ�,SCKƵ��Ϊfosc/2
	SPSR |= (1<<SPI2X);
	Disable_DFLASH();
}

unsigned char SPI_Transfer(unsigned char data)
{
    unsigned char tempData;
	//printf("spi_transfer:0x%02x \t ", data);
	SPDR = data;
    while(!(SPSR & (1<<SPIF))); // �ȴ��������
	tempData = SPDR;
	//printf("get 0x%02x\n", tempData);
	return tempData;
}

/************************************************************
*��ȡFLASH�ڲ�״̬�Ĵ���
*Bit 7:Ready/busy status (1:no busy ; 0:busy)
*Bit 6:Compare (1: no matche ; 0:matche) �����һ�αȽϽ��
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
*��ȡFLASH��ҳ��С
*����1��ʾÿһҳ�Ĵ�СΪ264 bytes,����Ϊ256 bytes
************************************************************/
unsigned char DF_Check_Page_Size(void)
{
  unsigned char Page_Size;
  Page_Size=DF_Read_status_Register();
  if(Page_Size&0x01) return 0;
  return 1;
}
/************************************************************
*��ȡFLASHæ��־λ(����ж�255��,���л��Ƿ����ҷ���0)
************************************************************/
unsigned char DF_Check_Busy_State(void)
{
  unsigned char state;
  unsigned char i=255;
  while(i)
  {
     state=DF_Read_status_Register();
	 if(state & 0x80) break;		//��ȡ�����λ0ʱ����æ
	 --i;
  }
  return i;
}
/************************************************************
*��ȡFLASH�Ĳ���ID��оƬID������;
*���º����᷵���ĸ�ֵ,��һ������AT45DB041D��˵Ϊ0x1F;
*���ĸ���Ϊ 0x00;
*�ô˺��������ж�оƬ�ĺû�,�Ƿ�����;
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
*ʹFLASH����Deep_Power_Down
************************************************************/
void DF_Deep_Power_Down(void)
{
  DF_Check_Busy_State();
  Enable_DFLASH();
  SPI_Transfer(0xB9);//дDeep Power-down������
  Disable_DFLASH();
}
/************************************************************
*ʹFLASH�˳�Deep_Power_Down
************************************************************/
void DF_Resume_from_Deep_Power_Down(void)
{
  DF_Check_Busy_State();
  Enable_DFLASH();
  SPI_Transfer(0xAB);//дResume from Deep Power-down������
  Disable_DFLASH();
}
/************************************************************
*ʹ����������
************************************************************/
void DF_Enable_Sector_Protection(void)
{
  unsigned char Enable_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xA9}; //ʹ����������������
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
	  SPI_Transfer(Enable_Sector_Protection_Command[i]);//дʹ����������������
  }
  Disable_DFLASH();
}
/************************************************************
*��ֹ��������
************************************************************/
void DF_Disable_Sector_Protection(void)
{
  unsigned char Disable_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0x9A};//��ֹ��������������
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Disable_Sector_Protection_Command[i]);//д��ֹ��������������
  }
  Disable_DFLASH();
}
/************************************************************
*������������
************************************************************/
void DF_Erase_Sector_Protection_Register(void)
{
  unsigned char Erase_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xCF};//������������������
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Erase_Sector_Protection_Command[i]);//д������������������
  }
  Disable_DFLASH();
}
/************************************************************
*������������
*ע��:��ı�BUFFER1�е�����
*Sector_Protection_Register:�����е�0~7�ֽڶԶ�Ӧ0~7������(0xFF:д����)(0x00:��������)

The Sector Protection Register can be reprogrammed while the sector protection enabled or dis-
abled. Being able to reprogram the Sector Protection Register with the sector protection enabled
allows the user to temporarily disable the sector protection to an individual sector rather than
disabling sector protection completely
************************************************************/
void DF_Program_Sector_Protection_Register(unsigned char *Sector_Protection_Register)
{
  unsigned char Program_Sector_Protection_Command[4]={0x3D,0x2A,0x7F,0xFC};//������������������
  unsigned char i;

  DF_Check_Busy_State();
  Enable_DFLASH();
  for(i=0;i<4;i++)
  {
      SPI_Transfer(Program_Sector_Protection_Command[i]);//д������������������
  }
  for(i=0;i<8;i++)
  {
      SPI_Transfer(Sector_Protection_Register[i]);//д����������������
  }
  Disable_DFLASH();
}
/************************************************************
*��ȡ���������Ĵ�������(����8���ֽ�,��Ӧ8�����������)
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
*ȡ��������������
*����1��ʾ�ɹ�ȡ���������Ա���
************************************************************/
unsigned char DF_Cancel_Sector_Protection(void)
{
  unsigned char Sector_Protection_Register_for_Write[8]={0,0,0,0,0,0,0,0};//д��0Ϊȥ����
  unsigned char Sector_Protection_Register_for_Read[8]={1,1,1,1,1,1,1,1};//��ֹĬ��ֵΪ0
  unsigned int i;
  unsigned char j=1;
  //ʹ����������
  DF_Enable_Sector_Protection();
  //������������

  DF_Program_Sector_Protection_Register(Sector_Protection_Register_for_Write);
  //��ȡ���������Ĵ�������
  DF_Read_Sector_Protection_Register(Sector_Protection_Register_for_Read);
  //�ж����������Ĵ�������
  for(i=0;i<8;i++)
  {
    if(Sector_Protection_Register_for_Read[i]!=0) j++;
  }
  //��ֹ��������
  DF_Disable_Sector_Protection();

  return j;
}
/************************************************************
*����������(���������ٴν���)
*�����õ�������ֻ�ܶ�����д
*��һ�������Ҫʹ��(�������ݲ����ٸ�)
*Sector_Addr :��ַ���ĸ������оͻ������Ǹ�����
************************************************************/
void DF_Program_Sector_Lockdown(unsigned long Sector_Addr)
{
  //unsigned char Sector_Lockdown_Command=[4]={0x3D,0x2A,0x7F,0x30};//����������
  unsigned char Sector_Lockdown_Command[4]={0x00,0x00,0x00,0x00};//��ֹд��,������д
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
*��ȡ���������Ĵ���(����8�������ļ����Ĵ���ֵ)
*����ж�����Ϊ0�ı�ʾ�ѱ�����
*(0�����ĸ���λΪ0Ҳ��ʾû����,��������һ��ҪȫΪO)
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
*д���ݵ�������(Buffer1��Buffer2)(��������СΪ264 bytes)
*BufferX   :ѡ�񻺳���(Buffer1��Buffer2)
*BFA       :Buffer�ڴ��ַ 0~263
*wData     :Ҫд�������
*wDataSize :Ҫд������ݳ���(1~264)
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

  for(i=0;i<wDataSize;i++)  SPI_Transfer(wData[i]);//д������

  Disable_DFLASH();
}
/************************************************************
*��ȡ������(Buffer1��Buffer2)(��������СΪ264 bytes)�е�����
*BufferX   :ѡ�񻺳���(Buffer1��Buffer2)
*BFA       :Buffer�ڴ��ַ 0~263
*wData     :��Ŷ���������
*wDataSize :Ҫд������ݳ���(1~264)
*ע��:���ٺ͵��ٷ��Ĳ������Ҫ���͵����ݳ��Ȳ�ͬ
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
  SPI_Transfer(0xFF);       				 //1 can't care byte (lower frequency ��������ֽ�)

  for(i=0;i<rDataLen;i++)  rData[i] = SPI_Transfer(0xFF);//��ȡ����

  Disable_DFLASH();
}
/************************************************************
*�ѻ�����(Buffer1��Buffer2)�е�����д���ڴ��ҳ��(д��ҳ)
*�Ȳ�����д����(Ӳ��֧�ֵĴ�����д)
*BufferX   :ѡ�񻺳���(Buffer1��Buffer2)
*PA        :�ڴ���ҳ�ĵ�ַ 0~2047
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
*��ȡ�ڴ��ҳ(��ҳ)�����ݵ�������(Buffer1��Buffer2)��
*BufferX   :ѡ�񻺳���(Buffer1��Buffer2)
*PA        :�ڴ���ҳ�ĵ�ַ 0~2047
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
*������д���ڴ���(�Զ���д��BUFFER1 OR BURRER2���ٽ�����д���ڴ���)
*BufferX   :ѡ���Զ���д��Ļ�����(Buffer1��Buffer2)
*PA        :�ڴ��е�ҳ��ַ0~2047
*BA        :��ҳ�е������ַ��ʼд����,���Զ�ת����һҳ(0~263)
*��д�����һҳ�����һ����ַʱ,���Զ�ת����һҳ��ʼд
*wData     :Ҫд�������
*DataLen   :Ҫд������ݳ���
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
*���ڴ��ж�ȡ���ݵ�����rData��(ֱ�Ӷ�ȡ���ݲ�����BUFFER1 OR BURRER2)
*PA        :�ڴ��е�ҳ��ַ0~2047
*BA        :��ҳ�е������ַ��ʼ������,���Զ�ת����һҳ(0~263)
*���������һҳ�����һ����ַʱ,���Զ�ת����һҳ��ʼ��ȡ
*rData     :��Ŷ���������
*DataLen   :Ҫ��ȡ�����ݳ���
*��DF_Continuous_Array_Readһ���Ĺ��ܵ���Buffer�й�,�����ı�Buffer�е�����
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
  //4 don��t care bytes
  for(i=0;i<4;i++)	SPI_Transfer(0xFF);

  for(i=0;i<DataLen;i++)  rData[i] = SPI_Transfer(0xFF);//��ȡ����

  Disable_DFLASH();
}
/************************************************************
*���ڴ��ж�ȡ���ݵ�����rData��(ֱ�Ӷ�ȡ���ݲ�����BUFFER1 OR BURRER2)
*PA        :�ڴ��е�ҳ��ַ0~2047
*BA        :��ҳ�е������ַ��ʼ������,���Զ�ת����һҳ(0~263)
*���������һҳ�����һ����ַʱ,���Զ�ת����һҳ��ʼ��ȡ
*rData     :��Ŷ���������
*DataLen   :Ҫ��ȡ�����ݳ���
*��DF_Main_Memory_Page_Readһ���Ĺ��ܵ���Buffer�޹�
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
  //4 don��t care bytes
  for(i=0;i<4;i++)	SPI_Transfer(0xFF);

  for(i=0;i<DataLen;i++)  rData[i] = SPI_Transfer(0xFF);//��ȡ����

  Disable_DFLASH();
}
/************************************************************
*����FLASHȫ������
*not affect sectors that are protected or locked down
************************************************************/
void DF_Chip_Erase(void)
{
  unsigned char Chip_Erase_Command[4]={0xC7,0x94,0x80,0x9A};//��Ƭ����������
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
*FLASH��λ
************************************************************/
void DF_Reset(void)
{
  SPI_PORT&=~(1<<RESET);	//ʹ�ܸ�λ
  _delay_us(10);
  SPI_PORT|=(1<<RESET);     //��ֹ��λ
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

  //д���ݵ�Buffer��
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //��Buffer�ж�ȡ����
  DF_Read_from_Buffer(Buffer1,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//��Ҫд��ĺͶ���������д��EEPROM���ڱȽ�
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
  
  //������д���ڴ���(�Զ���д��BUFFER1 OR BURRER2���ٽ�����д���ڴ���)
  Main_Memory_Page_Program_Through_Buffer(Buffer1,0,0,TestWriteBuffer,10);
  //���ڴ��ж�ȡ���ݵ�����rData��(ֱ�Ӷ�ȡ���ݲ�����BUFFER1 OR BURRER2)
  DF_Main_Memory_Page_Read(0,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//��Ҫд��ĺͶ���������д��EEPROM���ڱȽ�
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
  //д���ݵ�Buffer��
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //��Buffer�е�����д��DataFlash��
  DF_Write_Buffer_to_Page(Buffer1,0);
  //����DataFlash�е�����
  //DF_Main_Memory_Page_Read(0,0,TestReadBuffer,10);
  DF_Continuous_Array_Read(0,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//��Ҫд��ĺͶ���������д��EEPROM���ڱȽ�
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

  //д���ݵ�Buffer��
  DF_Write_to_Buffer(Buffer1,0,TestWriteBuffer,10);
  //��Buffer�е�����д��Page��
  DF_Write_Buffer_to_Page(Buffer1,0);
  //��Page�ж�ȡ���ݵ�Buffer��
  DF_Read_Buffer_from_Page(Buffer1,0);
  //��Buffer�ж�ȡ����
  DF_Read_from_Buffer(Buffer1,0,TestReadBuffer,10);
  /*
  for(i=0;i<10;i++)//��Ҫд��ĺͶ���������д��EEPROM���ڱȽ�
  {
    eeprom_write_byte((i+16*6),TestWriteBuffer[i]);
	eeprom_write_byte((i+16*7),TestReadBuffer[i]);
  }*/
}
/************************************************************
*������
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
  //PORTA=0X01;  //ָʾ����ʼ״̬
  uart_init();

  //FLASH��ʼ��(SPI��ʼ��)
  SPI_Init();
  //Flash��λ
  DF_Reset();

  //��ȡFLASH�ڲ�״̬�Ĵ���
  //unsigned char Test_Buf[4];
  //DF_Manufacturer_and_Device_ID(Test_Buf);


  //��ȡ���������Ĵ���
  //DF_Read_Sector_Lockdown_Register(Temp_Sector_Lockdown_Register);
  //for(i=0;i<8;i++)
  //{
  //  eeprom_write_byte(i,Temp_Sector_Lockdown_Register[i]);
  //}

  //ȡ��������������
  //if(DF_Cancel_Sector_Protection()) PORTA=0X18;//OK

  //����FLASH����ID  ����Ϊ0x1F��������
  //if(Test_Manufacturer_ID()) PORTA=0x1F;

  //ʹFLASH����Deep_Power_Down
  //DF_Deep_Power_Down();

  //ʹFLASH�˳�Deep_Power_Down
  //DF_Resume_from_Deep_Power_Down();

  //����FLASHȫ������
  DF_Chip_Erase();

  //����FLASH��д
  Test_Flash_Buffer_to_Buffer();			//ok
  Test_Flash_Page_to_Page();				//ok	
  Test_Flash_Buffer_Page_to_Page();			//ok
  Test_Flash_Buffer_Page_to_Page_Buffer();	//ok
  running();
  //PORTA=0X80;  //����ִ�����״̬
  while(1)
  {
    asm("sei");
  }
}
*/
