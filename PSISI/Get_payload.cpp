#include "stdafx.h"

unsigned char *Get_payload(unsigned char *buffer, unsigned int *Data_length, unsigned short int adap_field, unsigned int flag)
{
	
	unsigned char *Tab=NULL;
	unsigned short int field_length;	
    unsigned int data_length = 0;
	unsigned int len = 0;

	if(flag == 0)
	{
		switch( adap_field )
		{
			case  0:    break;
			
			case  1:    data_length += 183;                   //����ȡ���ȣ�����1B��pointer_field
						Tab = (unsigned char *)malloc(183*sizeof(char));
						if(Tab == NULL)
						{
							printf("Can't get memory!\n");
							return (NULL);
						}			
						memcpy(Tab, buffer+5, 183);
						break;
			
			case  2:    break;
			
			case  3:	field_length = buffer[4] & 0xff;
						len = 183 - field_length;
												
						if((Tab=(unsigned char *)malloc(len*sizeof(char)))==NULL)
						{
							printf("Can't get memory!\n");
							return (NULL);
						}
						
						memcpy(Tab, buffer+5+field_length, len);
						data_length += len;
						break;
		}
			
	    *Data_length = data_length;    

		return(Tab);
	}

	else
	{
		switch( adap_field )
		{
			case  0:    break;
			
			case  1:    data_length += 184;                   //����ȡ���ȣ�PES����start_indicator=0�İ�û��point_field
						Tab = (unsigned char *)malloc(184*sizeof(char));
						if(Tab == NULL)
						{
							printf("Can't get memory!\n");
							return (NULL);
						}			
						memcpy(Tab, buffer+4, 184);
						break;
			
			case  2:    break;
			
			case  3:	field_length = buffer[4] & 0xff;
						len = 184 -1 - field_length;
												
						if((Tab=(unsigned char *)malloc(len*sizeof(char)))==NULL)
						{
							printf("Can't get memory!\n");
							return (NULL);
						}
						
						memcpy(Tab, buffer+5+field_length, len);
						data_length += len;
						break;
		}
			
	    *Data_length = data_length;    
		
		return(Tab);
	}

}