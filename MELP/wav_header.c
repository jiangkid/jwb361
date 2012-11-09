#include <stdio.h>
#include <stdlib.h>
#include "wave_header.h"

#define ANA_SYN 0
#define ANALYSIS 1
#define SYNTHESIS 2

unsigned long wav_header_len(FILE* infile, FILE* outfile, int melpmode)
{
	unsigned long i;
    unsigned long wfmtlen; //fmt chunk数据字节数
	unsigned long wpcmlen; //实际PCM语音数据字节数
	unsigned long wavheadlen; //wav文件头字节数
	char datacheck[4];
	char temp;

     fseek(infile, 16L, 0);
	 fread(&wfmtlen, sizeof(unsigned long), 1, infile);
 
	 //printf("wfmtlen = %d\n",wfmtlen);////

	 rewind(infile);
	 fseek(infile, wfmtlen+16L+4L, 0);
	 fread(datacheck, sizeof(char), 4, infile);
     wavheadlen = wfmtlen+16L+4L;

	 /*查看是否包含fact chunk*/
	 if(datacheck[0] == 'f' && datacheck[1] == 'a' && datacheck[2] == 'c' && datacheck[3] == 't'){
		 fseek(infile, wfmtlen+16L+4L+12L, 0);
	     fread(datacheck, sizeof(char), 4, infile);
		 wavheadlen = wfmtlen+16L+4L+12L;
	 }
	 /*处理不正常的pcm文件*/
	 if(datacheck[0] != 'd' || datacheck[1] != 'a' || datacheck[2] != 't' || datacheck[3] != 'a'){
         printf("please input the right wave format(pcm)\n");
		 exit(1);
	 } 

		 

	 //printf("%c %c %c %c\n",datacheck[0],datacheck[1],datacheck[2],datacheck[3]);/////

     fseek(infile, wavheadlen + 4L, 0);
	 fread(&wpcmlen, sizeof(unsigned long), 1, infile);
	 if(melpmode != SYNTHESIS)
         printf("\n   the length of the original wave(pcm) data is %d\n", wpcmlen);
	 else
         printf("\n   the length of the original synthese code is %d\n", wpcmlen);

	 rewind(infile);
     rewind(outfile);
	 wavheadlen = wavheadlen + 8L;

	 //把wav文件头写入输出文件顶端
	 for(i = 0; i < wavheadlen; i++){
	 fread(&temp, sizeof(char), 1, infile);
     fwrite(&temp, sizeof(char), 1, outfile);
     }

     return wavheadlen; //返回wav文件头长度

}


void out_wav_len(FILE* outfile, unsigned long whlen)
{
	 unsigned long datalen;
     unsigned long wavelen;
	 
	 fseek(outfile, 0, 2);//文件指针指到文件底
	 datalen = ftell(outfile) - whlen;//合成语音字节数
	 //printf("whlen = %d\n",whlen);
	 //printf("%d",datalen);
	 fseek(outfile, whlen-4L, 0);
     fwrite(&datalen, sizeof(unsigned long), 1, outfile);//修正合成语音字节数
     
     wavelen = datalen + whlen - 8;
	 fseek(outfile, 4L, 0);
     fwrite(&wavelen, sizeof(unsigned long), 1, outfile);//修正wav文件总数据大小

}

 