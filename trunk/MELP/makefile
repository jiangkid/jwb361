# ==================================================================
#
#    Microsoft Speech coder     ANSI-C Source Code
#    SC1200 1200 bps speech coder
#    Fixed Point Implementation      Version 7.0
#    Copyright (C) 2000, Microsoft Corp.
#    All rights reserved.
#
# ==================================================================

#------------------------------------------------------------------
#
#  Makefile for SC1200 1200 bps speech coder
#
#------------------------------------------------------------------

#------------------------------------------------------------------
#   Turn on dependency tracking (for include files).
#------------------------------------------------------------------
.KEEP_STATE:

#------------------------------------------------------------------
#   Specify names of source files and executable.
#------------------------------------------------------------------
OBJS = classify.o coeff.o dsp_sub.o fec_code.o fft_lib.o \
       fs_lib.o fsvq_cb.o global.o harm.o lpc_lib.o mathdp31.o \
       mathhalf.o math_lib.o mat_lib.o melp_ana.o melp_chn.o melp_sub.o \
       melp_syn.o msvq_cb.o npp.o pitch.o pit_lib.o postfilt.o qnt12.o \
       qnt12_cb.o transcode.o vq_lib.o
	   
#add by JiangWenbin	   
ENC =  classify.o coeff.o dsp_sub.o fec_code.o fft_lib.o \
       fs_lib.o fsvq_cb.o global.o lpc_lib.o mathdp31.o \
       mathhalf.o math_lib.o mat_lib.o melp_ana.o melp_chn.o melp_sub.o \
       msvq_cb.o npp.o pitch.o pit_lib.o qnt12.o \
       qnt12_cb.o vq_lib.o 
	   
DEC =  coeff.o dsp_sub.o fec_code.o fft_lib.o\
       fs_lib.o fsvq_cb.o global.o harm.o lpc_lib.o mathdp31.o \
       mathhalf.o math_lib.o mat_lib.o melp_chn.o melp_sub.o \
       melp_syn.o msvq_cb.o pit_lib.o postfilt.o qnt12.o \
       qnt12_cb.o vq_lib.o
	   
SCMAIN      = sc1200.o 
SC12ENCMAIN = sc12enc.o 
SC12DECMAIN = sc12dec.o 
SC24ENCMAIN = sc24enc.o 
SC24DECMAIN = sc24dec.o 

#------------------------------------------------------------------------------
#   Specify options for compiling, linking, and archiving.  
#------------------------------------------------------------------------------
CC         = gcc 
CFLAGS     = -O3 -Wall 
LIBS	   = -lm
COMPILE.c  = $(CC) $(CFLAGS) -c
LINK.c     = $(CC) $(CFLAGS) 

#all: sc sc12enc sc12dec sc24enc sc24dec 
all: sc12enc sc12dec 
	size sc12enc
	size sc12dec

sc: ${SCMAIN} ${OBJS}
	${CC} -o $@ ${CFLAGS} ${SCMAIN} ${OBJS} ${LIBS}

sc12enc: ${SC12ENCMAIN} ${ENC}
	${CC} -o $@ ${CFLAGS} ${SC12ENCMAIN} ${ENC} ${LIBS}

sc12dec: ${SC12DECMAIN} ${DEC}
	${CC} -o $@ ${CFLAGS} ${SC12DECMAIN} ${DEC} ${LIBS}

sc24enc: ${SC24ENCMAIN} ${OBJS}
	${CC} -o $@ ${CFLAGS} ${SC24ENCMAIN} ${OBJS} ${LIBS}

sc24dec: ${SC24DECMAIN} ${OBJS}
	${CC} -o $@ ${CFLAGS} ${SC24DECMAIN} ${OBJS} ${LIBS}
clean:
	rm *.o -rf
#------------------------------------------------------------------------------
#	Header Dependences
#------------------------------------------------------------------------------

classify.o : classify.c sc1200.h cprv.h global.h mat_lib.h macro.h mathhalf.h constant.h math_lib.h dsp_sub.h coeff.h melp_sub.h 
coeff.o : coeff.c sc1200.h
dsp_sub.o : dsp_sub.c sc1200.h macro.h mathhalf.h mat_lib.h math_lib.h dsp_sub.h constant.h global.h
fec_code.o : fec_code.c sc1200.h mathhalf.h
fft_lib.o : fft_lib.c sc1200.h mathhalf.h mat_lib.h math_lib.h constant.h global.h fft_lib.h
fs_lib.o : fs_lib.c sc1200.h mathhalf.h mat_lib.h math_lib.h fs_lib.h constant.h global.h dsp_sub.h macro.h fft_lib.h 
fsvq_cb.o : fsvq_cb.c sc1200.h 
global.o : global.c sc1200.h
harm.o : harm.c sc1200.h constant.h mathhalf.h mat_lib.h math_lib.h
lpc_lib.o : lpc_lib.c sc1200.h macro.h mathhalf.h mathdp31.h math_lib.h mat_lib.h lpc_lib.h constant.h global.h dsp_sub.h 
mat_lib.o : mat_lib.c sc1200.h mathhalf.h mat_lib.h 
math_lib.o : math_lib.c sc1200.h mathhalf.h mathdp31.h math_lib.h constant.h global.h macro.h 
mathdp31.o : mathdp31.c sc1200.h mathhalf.h 
mathhalf.o : mathhalf.c sc1200.h constant.h mathhalf.h mathdp31.h global.h macro.h 
melp_ana.o : melp_ana.c sc1200.h mathhalf.h macro.h lpc_lib.h mat_lib.h vq_lib.h fs_lib.h fft_lib.h pit_lib.h math_lib.h constant.h global.h cprv.h pitch.h qnt12_cb.h qnt12.h msvq_cb.h fsvq_cb.h melp_sub.h dsp_sub.h coeff.h 
melp_chn.o : melp_chn.c sc1200.h vq_lib.h melp_sub.h math_lib.h constant.h global.h qnt12_cb.h mathhalf.h mat_lib.h qnt12.h msvq_cb.h fsvq_cb.h dsp_sub.h 
melp_sub.o : melp_sub.c sc1200.h mathhalf.h math_lib.h mat_lib.h dsp_sub.h melp_sub.h pit_lib.h constant.h coeff.h 
melp_syn.o : melp_syn.c sc1200.h mathhalf.h macro.h lpc_lib.h mat_lib.h vq_lib.h fs_lib.h math_lib.h constant.h global.h harm.h fsvq_cb.h dsp_sub.h melp_sub.h coeff.h postfilt.h 
msvq_cb.o : msvq_cb.c sc1200.h
npp.o : npp.c npp.h sc1200.h mathhalf.h math_lib.h mathdp31.h mat_lib.h dsp_sub.h fs_lib.h global.h
pit_lib.o : pit_lib.c sc1200.h mathhalf.h mathdp31.h mat_lib.h math_lib.h dsp_sub.h pit_lib.h constant.h global.h coeff.h 
pitch.o : pitch.c sc1200.h cprv.h macro.h mat_lib.h pitch.h mathhalf.h math_lib.h constant.h dsp_sub.h melp_sub.h 
postfilt.o : postfilt.c sc1200.h mathhalf.h macro.h constant.h mat_lib.h dsp_sub.h math_lib.h lpc_lib.h 
qnt12.o : qnt12.c sc1200.h lpc_lib.h vq_lib.h global.h macro.h qnt12_cb.h mat_lib.h math_lib.h qnt12.h constant.h mathhalf.h msvq_cb.h fsvq_cb.h dsp_sub.h melp_sub.h 
qnt12_cb.o : qnt12_cb.c sc1200.h 
sc1200.o : sc1200.c sc1200.h mat_lib.h global.h macro.h mathhalf.h dsp_sub.h melp_sub.h constant.h npp.h math_lib.h mathdp31.h
transcode.o : transcode.c sc1200.h mathhalf.h mat_lib.h math_lib.h constant.h global.h dsp_sub.h qnt12_cb.h qnt12.h msvq_cb.h fsvq_cb.h melp_sub.h dsp_sub.h coeff.h macro.h transcode.h lpc_lib.h fs_lib.h cprv.h vq_lib.h
vq_lib.o : vq_lib.c sc1200.h macro.h mathhalf.h mat_lib.h math_lib.h lpc_lib.h constant.h

#------------------------------------------------------------------------------
#   End of Makefile.
#------------------------------------------------------------------------------

