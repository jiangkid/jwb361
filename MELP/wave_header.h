




//unsigned long wav_header_len(FILE * infile, FILE* outfile, int melpmode);
unsigned long wav_header_len(FILE* infile, FILE* outfile, int melpmode, unsigned long wpcmlen);
void out_wav_len(FILE* outfile, unsigned long whlen);