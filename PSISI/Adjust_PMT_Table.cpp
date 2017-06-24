#include "stdafx.h"

void Adjust_PMT_Table (unsigned char * buffer, unsigned int *PID_video, unsigned int *PID_audio)
{
    unsigned int pos = 12;
	PMT_Table packet;
  
    packet.table_id                              = buffer[0];
    packet.section_syntax_indicator              = buffer[1] >> 7;
    packet.zero                                  = buffer[1] >> 6; 
    packet.reserved_1                            = buffer[1] >> 4;
    packet.section_length                        = (buffer[1] & 0x0F) << 8 | buffer[2];    
    packet.program_number                        = buffer[3] << 8 | buffer[4] & 0xFF;
    packet.reserved_2                            = buffer[5] >> 6;
    packet.version_number                        = buffer[5] >> 1 & 0x1F;
    packet.current_next_indicator                = (buffer[5] << 7) >> 7;
    packet.section_number                        = buffer[6];
    packet.last_section_number                   = buffer[7];
    packet.reserved_3                            = buffer[8] >> 5;
    packet.PCR_PID                               = ((buffer[8] & 0x1F)<< 8) | (buffer[9] & 0xFF); 
	packet.reserved_4                            = buffer[10] >> 4;
    packet.program_info_length                   = (buffer[10] & 0x0F) << 8 | buffer[11]; 
   
	   
	// program info descriptor
    
    pos += packet.program_info_length;    
    
	// Get stream type and PID    
    
	printf("Program.number:0x%03x    PCR_PID:0x%03x\n",packet.program_number,packet.PCR_PID);
	for ( ; pos <= (packet.section_length +2 ) - 4; )  //ad reserved 2B and minus CRC 4B
    {
        packet.stream_type                       =		buffer[pos];
        packet.reserved_5                        =		buffer[pos+1] >> 5;
        packet.elementary_PID                    =		((buffer[pos+1] & 0x1F) << 8) | (buffer[pos+2] & 0xFF);
		packet.reserved_6                        =		buffer[pos+3] >> 4;
        packet.ES_info_length                    =		(buffer[pos+3] & 0x0F) << 8 | buffer[pos+4]; 
        
	
       switch(packet.stream_type)
	   {
	   case  0x01:      printf("ISO/IEC 11172ÊÓÆµ->0x%03x\n",packet.elementary_PID);
		                *PID_video  = packet.elementary_PID ;
						break;
	   case  0x02:		printf("ISO/IEC 13818-2ÊÓÆµ->0x%03x\n",packet.elementary_PID);
						*PID_video  = packet.elementary_PID ;
						break;
	   case  0x03:		printf("ISO/IEC 11172ÒôÆµ->0x%03x\n",packet.elementary_PID);
						*PID_audio  = packet.elementary_PID ;
						break;
	   case  0x04:      printf("ISO/IEC 13818-2ÒôÆµ->0x%03x\n",packet.elementary_PID);
						*PID_audio  = packet.elementary_PID ;
						break;
	   case  0x81:      printf("AC3ÒôÆµ->0x%03x\n",packet.elementary_PID);
					    *PID_audio  = packet.elementary_PID ;
					    break;
	   }
       pos = pos+5;
       pos += packet.ES_info_length; 
    }
	free(buffer);
} 
