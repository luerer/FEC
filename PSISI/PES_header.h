#pragma once
typedef struct PES_header
{
    unsigned packet_start_code_prefix          : 24;
    unsigned stream_id                         : 8;
    unsigned PES_packet_length                 : 16;
    unsigned one_zero                          : 2;
    unsigned PES_scrambling_control            : 2;
    unsigned PES_priority                      : 1;
    unsigned data_alignment_indicator          : 1;
    unsigned copyright                         : 1;
    unsigned original_or_copy                  : 1;
    unsigned PTS_DTS_flag                      : 2;
    unsigned ESCR_flag                         : 1;
    unsigned ES_rate_flag                      : 1;
    unsigned DSM_trick_mode_flag               : 1;
    unsigned additional_copy_info_flag         : 1;
    unsigned PES_RCR_flag                      : 1;
	unsigned PES_extension_flag                : 1;
	unsigned PES_header_data_length            : 8;

}PES_header; 