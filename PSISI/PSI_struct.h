#pragma once
typedef struct PMT_Section{
	char * type;
	unsigned int PCR_PID;
	unsigned int Program_number;
	unsigned int Elementary_PID;
	struct PMT_Section * next;
}PMT_Section;

typedef struct PAT_Section{
	unsigned int Program_number;
	unsigned int PMT_PID;
	struct PAT_Section * next;
	struct PMT_Section * Head;
}PAT_Section;