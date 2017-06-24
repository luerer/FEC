
#include "stdafx.h" 
//#define FRAME 10000

unsigned char * Analyse_PES_header(unsigned char * buffer, unsigned int *Data_length)
{
	int n = 0,  i = 0;
	PES_header header;
	unsigned char *PTS = (unsigned char*)malloc(5);  //the original value of aggregation data
	unsigned char *DTS = (unsigned char*)malloc(5);

	unsigned int buffer_length;
	buffer_length = *Data_length;      //transmit the length of PES buffer without adaptation field

	header.packet_start_code_prefix      = (buffer[0] & 0xFF) << 16 | (buffer[1] & 0xFF)<< 8 | buffer[2] & 0xFF;
	header.stream_id                     = buffer[3];
	header.PES_packet_length             = buffer[4] << 8 | buffer[5]& 0xFF;
	header.one_zero                      = buffer[6] >> 6 & 0x03;
	header.PES_scrambling_control        = buffer[6] >> 4 & 0x03;
	header.PES_priority                  = buffer[6] >> 3 & 0x01;
	header.data_alignment_indicator      = buffer[6] >> 2 & 0x01;
	header.copyright                     = buffer[6] >> 1 & 0x01;
	header.original_or_copy              = buffer[6] & 0x01;
	header.PTS_DTS_flag                  = buffer[7] >> 6 & 0x03;
	header.ESCR_flag                     = buffer[7] >> 5 & 0x01;
	header.ES_rate_flag                  = buffer[7] >> 4 & 0x01;
	header.DSM_trick_mode_flag           = buffer[7] >> 3 & 0x01;
	header.additional_copy_info_flag     = buffer[7] >> 2 & 0x1;
	header.PES_RCR_flag                  = buffer[7] >> 1 & 0x1;
	header.PES_extension_flag            = buffer[7] & 0x01;
	header.PES_header_data_length        = buffer[8];

	n = 9;
	switch (header.PTS_DTS_flag)
	{
        case 0x00:    *PTS = 0x0000000000;
			          *DTS = 0x0000000000;
					   
					   break;

		case 0x01:    break;

		case 0x02:    *PTS = (buffer[9] >> 1 & 0x000000007) << 30 |  (buffer[10] & 0x0000000FF) << 22
			                    | (buffer[11] >> 1 & 0x00000007F) << 15 |  (buffer[12] & 0x0000000FF) <<7
			                    | (buffer[13] & 0x0000000FE);
					  
					  break;

		case 0x03:    *PTS = (buffer[9] >> 1 & 0x000000007) << 30 | (buffer[10] & 0x0000000FF) << 22
			                    | (buffer[11] >> 1 & 0x00000007F) << 15 | (buffer[12] & 0x0000000FF) <<7
			                    | (buffer[13] & 0x0000000FE);
					  *DTS = (buffer[14] >> 1 & 0x000000007) << 30 | (buffer[15] & 0x0000000FF) << 22
					         | (buffer[16] >> 1 & 0x00000007F) << 15 | (buffer[17] & 0x0000000FF) <<7
					         | (buffer[18] & 0x0000000FE);    
					
					  break;


	}
	
	n += header.PES_header_data_length;     //skip and read data from this position   
	unsigned char *data_header = (unsigned char*)malloc(buffer_length - n);

	//保存该TS包中剩余的数据
	for (n; n < buffer_length; n++)
	{
		*(data_header +i) = buffer[n];
		i ++;
	}

	*Data_length = i;         //return the length of the res data
	free(DTS);
	free(PTS);
	return(data_header);


}