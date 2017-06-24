typedef struct PMT_Table
{
    unsigned table_id                          : 8;
    unsigned section_syntax_indicator          : 1;
    unsigned zero                              : 1;
    unsigned reserved_1                        : 2;
    unsigned section_length                    : 12;
    unsigned program_number                    : 16;
    unsigned reserved_2                        : 2;
    unsigned version_number                    : 5;
    unsigned current_next_indicator            : 1;
    unsigned section_number                    : 8;
    unsigned last_section_number               : 8;
    unsigned reserved_3                        : 3;
    unsigned PCR_PID                           : 13;
    unsigned reserved_4                        : 4;
    unsigned program_info_length               : 12;
    
    unsigned stream_type                       : 8;
    unsigned reserved_5                        : 3;
    unsigned elementary_PID                    : 13;
    unsigned reserved_6                        : 4;
    unsigned ES_info_length                    : 12; 
    unsigned CRC_32                            : 32; 
}PMT_Table; 
