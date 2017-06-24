// PSI.cpp : 定义控制台应用程序的入口点。
//
#include "stdafx.h"

int _tmain(int argc, _TCHAR* argv[])
{	
	FLLE *config;
	config = fopen("C:/Users/ldw47/Desktop/config.txt","w+");

   	unsigned int PID_PAT=0x00;
	unsigned int PID_video = 0, PID_audio = 0;
	unsigned char *Table = NULL;
	unsigned int count = 0;

	FILE *fp_r, *fp_w_v, *fp_w_a;
	//if(( fp_r = fopen("original.ts","rb")) == NULL)
	if(( fp_r = fopen("C:/Users/ldw47/Desktop/13sec.ts","rb")) == NULL)
	{
		printf("open file error\n");
		return(NULL);
	}
	fp_w_v = fopen("C:/Users/ldw47/Desktop/es_video.bin", "wb+");
	fp_w_a = fopen("C:/Users/ldw47/Desktop/es_audio.bin", "wb+");

	fseek(fp_r, 0L ,2);
	long file_size = ftell(fp_r)+1;
	unsigned char *src_file = (unsigned char*)malloc(file_size);

	rewind(fp_r);
	fread(src_file, sizeof(unsigned char), file_size, fp_r);//将内容放入内存
	fclose(fp_r);

	unsigned int src_buf_pos = 0;
	//unsigned int buf_pos_audio = 0;                 //get the length of audio_buf/video_buf
	//unsigned int buf_pos_video = 0;                 
	//unsigned int buf_pos_audio = 0;
	//unsigned char *audio_buffer = (unsigned char*)malloc(file_size);     //store the audio/video data
	//unsigned char *video_buffer = (unsigned char*)malloc(file_size);
	unsigned char *audio_header_res = NULL;                  //get the res audio/video data of the PES packet header
	unsigned char *video_header_res = NULL;

	unsigned char *packet = (unsigned char *)malloc(188);   
	unsigned char *packet_data = NULL;
	unsigned int Data_length = 0;       
	unsigned int len = 0, len_res = 0;   

	TS_header header;

	unsigned int init_flag = 0;
	unsigned short int adap_field = 0;
	//unsigned int point_field_flag = 0;
	//unsigned int frame_flag = 0;

	while( src_buf_pos < file_size)
	{
		if(0x47 == *(src_file + src_buf_pos))
		{
			memcpy(packet, src_file + src_buf_pos, 188);
			count++;	
			Adjust_TS_packet_header( &header, packet);
			adap_field = header.adaptation_field_control;

			//get PAT first then set init_flag to 1   //if(packet_data != NULL)
		
			if(header.PID == PID_PAT)
			{
				init_flag = 0;
				packet_data = Get_payload(packet, &Data_length, adap_field, init_flag);
				if (packet_data == NULL)
				{
					printf("PID=0x%0x Can't find in the file\n",PID_PAT);
				}
				src_buf_pos = 188 * count;

				Adjust_PAT_Table(packet_data, src_file + src_buf_pos,&count,&PID_video,&PID_audio);
				init_flag = 1;

			}
			if(init_flag == 1)
			{
				packet_data = Get_payload(packet, &Data_length, adap_field, init_flag);
				if (packet_data == NULL)
				{
					printf("Can't find audio/video data in the file\n");
				}

				if(header.PID == PID_audio)
				//if((packet_data = Get_payload(PID_audio, packet, Data_length, adap_field)) != NULL)
				{
					if (header.payload_unit_start_indicator == 1)
					{
						audio_header_res = Analyse_PES_header(packet_data, &Data_length);
						len_res = Data_length;

						//for(int i = 0; i < len_res; i ++)
						//{
						//	*(audio_buffer + buf_pos_audio +i)= *(audio_header_res + i);	
						//}

						fwrite(audio_header_res,sizeof(unsigned char),len_res,fp_w_a);
						free(audio_header_res);
						//buf_pos_audio += len_res;
					}else
					{
						len = Data_length;
						//for (int j = 0 ; j < len; j++)
						//{
						//	*(audio_buffer + buf_pos_audio + j) = *(packet_data + j);      
						//
						//}

						fwrite(packet_data,sizeof(unsigned char),len,fp_w_a);
						//buf_pos_audio += len;
					}

					fprintf(config,'A,%d\n',count);



				}else if(header.PID == PID_video)
				//if((packet_data = Get_payload(PID_video, packet, Data_length, adap_field)) != NULL)
				{
					if (header.payload_unit_start_indicator == 1)
					{
						video_header_res = Analyse_PES_header(packet_data, &Data_length);  //the value of Data_length changed in this function
						len_res = Data_length;                                              // then get rid of the PES header and represent the res data length

						//for(int i = 0; i < len_res; i ++)
						//{
						//	*(video_buffer  + buf_pos_video + i) = *(video_header_res + i);	//maybe replaced with memcpy()
						//}

						fwrite(video_header_res,sizeof(unsigned char),len_res,fp_w_v);

						free(video_header_res);
						//buf_pos_video += len_res;
					}else
					{
						len = Data_length;
						//for(int j = 0; j < len; j ++)
						//{
						//	*(video_buffer  + buf_pos_video + j) = *(packet_data + j); //maybe replaced with memcpy()     
						//}

						fwrite(packet_data,sizeof(unsigned char),len,fp_w_v);
						//buf_pos_video += len;
					}
					fprintf(config,'V,%d\n',count);
				}
			
			}
			free(packet_data);		
			src_buf_pos = 188 * count;
		}else
		{
			src_buf_pos ++;
		}
	}
	free(packet);
	free(src_file);

//写入视、音频文件
	//rewind(fp_w_a);
	//fwrite(audio_buffer, sizeof(unsigned char), buf_pos_audio + 1, fp_w_a);
	fclose(fp_w_a);

	//rewind(fp_w_v);
	//fwrite(video_buffer, sizeof(unsigned char), buf_pos_video + 1, fp_w_v);
	fclose(fp_w_v);

	//free(audio_buffer);
	//free(video_buffer);
   	//getchar();
   	fclose(config);
	return 0;
}

