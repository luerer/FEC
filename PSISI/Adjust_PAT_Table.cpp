#include "stdafx.h"

void Adjust_PAT_Table(unsigned char * buffer, unsigned char *src_buf, unsigned int *count, unsigned int *PID_video, unsigned int *PID_audio)
{
 
	unsigned char *Data;
	unsigned int i = 0;
	
   	PAT_Table packet;
	TS_header header;	
	unsigned char *buf_temp = (unsigned char*)malloc(188);
	unsigned int Data_length = 0;

	packet.table_id                      = buffer[0];
    packet.section_syntax_indicator      = buffer[1] >> 7;
    packet.zero                          = buffer[1] >> 6 & 0x1;
    packet.reserved_1                    = buffer[1] >> 4 & 0x3;
    packet.section_length                = (buffer[1] & 0x0F) << 8 | (buffer[2] & 0xFF);    
    packet.transport_stream_id           = buffer[3] << 8 | buffer[4];
    packet.reserved_2                    = buffer[5] >> 6;
    packet.version_number                = buffer[5] >> 1 &  0x1F;
    packet.current_next_indicator        = (buffer[5] << 7) >> 7;
    packet.section_number                = buffer[6];
    packet.last_section_number           = buffer[7]; 
    	

    // Parse network_PID or program_map_PID
    for ( int n = 0; n < ((packet.section_length - 5)/4 - 1); n ++ )
    {
       
		packet.program_number            = (buffer[8+n*4] & 0xFF)<< 8 | buffer[9+n*4] & 0xFF;
        packet.reserved_3                = buffer[10+n*4] >> 5; 
        if ( packet.program_number == 0x00 )
		{
			packet.network_PID = (buffer[10+n*4]) << 8 | buffer[11+n*4];
            printf("Program.number:0x0%03x     Network->PID:0x%03x\n\n",packet.program_number,packet.network_PID);
		}
		else
		{   
			packet.program_map_PID = (buffer[10+n*4] & 0xFF) << 8 | buffer[11+n*4] & 0xff; 
			printf("Program.number:0x%03x    PMT->PID:0x%03x\n\n",packet.program_number,packet.program_map_PID);
        } 
		
		if(packet.program_number!=0)  //如果program_number不为0，解析该段的PID所对应的PMT表
		{
			
			memcpy(buf_temp, src_buf + 188 * i , 188);
			*count ++;
			Adjust_TS_packet_header( &header, buf_temp);
			unsigned short int adap_field = header.adaptation_field_control;
			unsigned int flag = 0;
			if(header.PID == packet.program_map_PID)
			{
				if((Data = Get_payload(buf_temp, &Data_length, adap_field, flag))==NULL)
				{
					printf("PID=0x%03x  Can't find int the file\n");
					continue;

					i ++;
				}

				Adjust_PMT_Table (Data,PID_video,PID_audio);
			}
			
		}
		printf("\n_________________________________________________\n");
    }
	free(buffer);
	free(buf_temp);
} 