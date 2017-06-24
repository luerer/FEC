#include "stdafx.h"

void Adjust_TS_packet_header(TS_header *pheader,unsigned char * buffer)
{
	pheader->sync_byte							 = buffer[0];
    pheader->transport_error_indicator			 = buffer[1] >> 7;
    pheader->payload_unit_start_indicator		 = buffer[1] >> 6 & 0x01;
    pheader->transport_priority                  = buffer[1] >> 5 & 0x01;
    pheader->PID								 = ((buffer[1] & 0x1F) << 8) | (buffer[2] & 0xFF);
    pheader->transport_scrambling_control        = buffer[3] >> 6;
    pheader->adaptation_field_control            = (buffer[3] >> 4) & 0x03;
    pheader->continuity_counter                  = buffer[3] & 0x0F;
} 