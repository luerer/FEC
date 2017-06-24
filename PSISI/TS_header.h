typedef struct TS_header{
	unsigned short int sync_byte						:8;
	unsigned short int transport_error_indicator		:1;
	unsigned short int payload_unit_start_indicator		:1;
	unsigned short int transport_priority				:1;
	unsigned short int PID								:13;
	unsigned short int transport_scrambling_control		:2;
	unsigned short int adaptation_field_control			:2;
	unsigned short int continuity_counter				:4;
}TS_header;

