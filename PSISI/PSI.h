#include "stdafx.h"

void Adjust_PAT_Table (unsigned char *buffer, unsigned char *src_buf, unsigned int *count,\
	unsigned int *PID_video, unsigned int *PID_audio);

void Adjust_PMT_Table (unsigned char *buffer, unsigned int *PID_video, unsigned int *PID_audio);

void Adjust_TS_packet_header(TS_header *pheader, unsigned char *buffer);

unsigned char * Analyse_PES_header (unsigned char *buffer, unsigned int *Data_length );

unsigned char * Get_Table(unsigned short int PPID, unsigned char *buffer);

unsigned char * Get_payload(unsigned char *buffer, unsigned int *Data_length,\
	unsigned short int adap_field, unsigned int flag);