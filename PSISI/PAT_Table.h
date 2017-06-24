typedef struct PAT_Table
{
    unsigned table_id                        : 8;
    unsigned section_syntax_indicator        : 1;
    unsigned zero                            : 1;
    unsigned reserved_1                      : 2;
    unsigned section_length                  : 12;
    unsigned transport_stream_id             : 16;
    unsigned reserved_2                      : 2;
    unsigned version_number                  : 5;
    unsigned current_next_indicator          : 1;
    unsigned section_number                  : 8;
    unsigned last_section_number             : 8; 
    unsigned program_number                  : 16;
    unsigned reserved_3                      : 3;
    unsigned network_PID                     : 13;
    unsigned program_map_PID                 : 13; 
    unsigned CRC_32                          : 32; 
} PAT_Table; 