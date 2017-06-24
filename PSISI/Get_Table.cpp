#include "stdafx.h"

#include "TS_header.h"
extern void Adjust_TS_packet_header(TS_header *pheader,unsigned char * buffer);
extern unsigned long GenerateCRC32(unsigned char * DataBuf,unsigned long  len);

//记录TS包的个数
//extern unsigned int count;

unsigned char * Get_Table(unsigned short int PPID, unsigned char *src_buf)
{
	unsigned char buffer[188]={0};
	unsigned char * Tab=NULL;
	//unsigned char *Temp=NULL;
	unsigned short int field_length;
	unsigned int section_length;
	unsigned int table_length;
	unsigned int crc;
    unsigned int data_length=0;
	unsigned int len=0;

    TS_header Data;    

		memcpy( buffer, src_buf , 188);    //read memory
		//count ++;

		if( buffer == 0)
		{
			//printf("read file error or EOF\n");
			return(NULL);
		}
            
		Adjust_TS_packet_header(&Data,buffer);
		
		if( Data.PID == PPID && Data.payload_unit_start_indicator == 1 )
		{
			switch(Data.adaptation_field_control)
			{
			case  0:    break;
			
			case  1:    data_length += 183;                   //已提取长度，包括1B的pointer_field
						Tab = (unsigned char *)malloc(183*sizeof(char));
						if( Tab == NULL)
						{
							printf("Can't get memory!\n");
							return (NULL);
						}
						
						//memset(Temp, data_length, 0);   
						memcpy(Tab, buffer+5, 183);
						break;
			
			case  2:    break;
			
			case  3:	field_length = buffer[4] & 0xff;
						len = 183 - field_length;
												
						if(( Tab=(unsigned char *)malloc(len*sizeof(char)))==NULL )
						{
							printf("Can't get memory!\n");
							return (NULL);
						}
						
                      //  memset(Temp, data_length, 0);
                        memcpy(Tab, buffer+5+field_length, len);
						data_length += len;
					    break;
			}
		}

	
		
		
		if(Data.PID == PPID && Data.payload_unit_start_indicator == 1)    //至下一个包的start_indicator,如果取得整张表，进行CRC校验
		{ 
			//并未Adjust_packet_header,未更新
			section_length  = (Tab[1] & 0x0F) << 8 | (Tab[2] & 0xFF); //取得表CRC校验值
			table_length	= 3 +section_length;
			crc			    = (Tab[table_length-4] & 0x000000FF) << 24
		                                  | (Tab[table_length-3] & 0x000000FF) << 16
                                          | (Tab[table_length-2] & 0x000000FF) << 8 
                                          | (Tab[table_length-1] & 0x000000FF); 

			if(crc == GenerateCRC32((unsigned char *)Tab,table_length-4))  //如果校验失败，处理存表头，继续读取表剩余部分
			{
				return Tab;
			}
			else
			{
				free(Tab);
				data_length = 0;
				len = 0;
				switch(Data.adaptation_field_control)
				{
				case  0:    break;
			
				case  1:    data_length = 183;
						
							if((Tab=(unsigned char *)malloc(183*sizeof(char)))==NULL)
							{
								printf("Can't get memory!\n");
								return (NULL);
							}
							memcpy(Tab,buffer+5,183);
							break;
			
				case  2:    break;
			
				case  3:	field_length=buffer[4] & 0xff;
							len=183-field_length;
							data_length=len;
						
							if((Tab=(unsigned char *)malloc(len*sizeof(char)))==NULL)
							{
								printf("Can't get memory!\n");
								return (NULL);
							}

						    memcpy(Tab,buffer+5+field_length,len);
						    break;
				}
			}
		}
		
	
		
    return (Tab);
}