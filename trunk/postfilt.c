/* ================================================================== */
/*                                                                    */ 
/*    Microsoft Speech coder     ANSI-C Source Code                   */
/*    SC1200 1200 bps speech coder                                    */
/*    Fixed Point Implementation      Version 7.0                     */
/*    Copyright (C) 2000, Microsoft Corp.                             */
/*    All rights reserved.                                            */
/*                                                                    */ 
/* ================================================================== */

/*------------------------------------------------------------------*/
/*																	*/
/* File:		"postfilt.c"										*/
/*																	*/
/* Description: 	postfilter and postprocessing in decoder		*/
/*																	*/
/* Function:														*/
/*		postfilt()													*/
/*		postproc()													*/
/*																	*/
/*------------------------------------------------------------------*/

#include "sc1200.h"
#include "constant.h"
#include "postfilt.h"
#include "dsp_sub.h"
#include "mat_lib.h"
#include "math_lib.h"
#include "lpc_lib.h"
#include "mathhalf.h"

/* ---- Postfilter ---- */
#define ALPH			18678                                    /* 0.57, Q15 */
#define BETA			24576                                    /* 0.75, Q15 */

#define SMOOTH_LEN		20
#define X05_Q12			2048

/* ===== Prototypes ===== */
static void		hpf60(Shortword speech[]);
static void		lpf3500(Shortword speech[]);


/****************************************************************
**
** Function:		postfilt()
**
** Description: 	postfilter including short term postfilter
**				and tilt compensation
**
** Arguments:
**
**	Shortword	speech[]	: input/output synthesized speech (Q0)
**
** Return value:	None
**
*****************************************************************/

void postfilt(Shortword speech[], Shortword prev_lsf[], Shortword cur_lsf[])
{
	register Shortword	i, j, k;
	static const Shortword	syn_inp[SYN_SUBNUM] = {                    /* Q15 */
								4096, 12288, 20480, 28672
	};
	static BOOLEAN	postfilt_firsttime = TRUE;
	static Shortword	hpm = 0;                                        /* Q0 */
	static Shortword	mem1[LPC_ORD] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	static Shortword	mem2[LPC_ORD] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	static Shortword	gain = 0;                                      /* Q14 */
	static Shortword	alphaipFIR[LPC_ORD];                           /* Q12 */
	static Shortword	alphaipIIR[LPC_ORD];
	static Shortword	window[SMOOTH_LEN];                            /* Q15 */
	Shortword	temp, temp_shift;
	Shortword	temp1, temp2;
	Longword	L_temp;
	Shortword	synLPC[LPC_ORD];                                       /* Q12 */
	Shortword	inplsf[LPC_ORD];

	/* ---- High frequency emphasis ---- */
	Shortword	emph;                                                  /* Q15 */
	Shortword	synhp[SYN_SUBFRAME];                                    /* Q0 */

	/* ---- FIR, IIR filter ---- */
	Longword	L_sum;
	Shortword	mem1old[LPC_ORD];
	Shortword	mem2old[LPC_ORD];

	Shortword	nokori[SMOOTH_LEN];
	Shortword	sp, sp_shift;
	Shortword	op, op_shift;


	if (postfilt_firsttime){
		/* ======== Compute smoothing window ======== */
		temp = 0;                                                      /* Q15 */
		for (i = 0; i < SMOOTH_LEN; i++){
			window[i] = temp;
			temp = add(temp, 1638);            /* 1638 is 1/SMOOTH_LEN in Q15 */
		}
		postfilt_firsttime = FALSE;
	}

	/* Computing sp, the sum of squares of speech[].  We would treat speech[] */
	/* as if it is Q15, and we will do the same thing when computing op.      */

	sp = 0;
	for (i = 0; i < FRAME; i++){
		temp = abs_s(speech[i]);
		if (sp < temp)
			sp = temp;
	}
	temp_shift = norm_s(sp);
	L_sum = 0;
	for (i = 0; i < FRAME; i++){
		temp = shl(speech[i], temp_shift);                             /* Q15 */
		L_temp = L_mult(temp, temp);                                   /* Q31 */
		L_temp = L_shr(L_temp, 8);                                     /* Q23 */
		L_sum = L_add(L_sum, L_temp);                                  /* Q23 */
	}
	temp_shift = shl(temp_shift, 1);                  /* Squaring of speech[] */
	sp_shift = sub(8, temp_shift);                   /* Aligning Q23 with Q31 */
	temp_shift = norm_l(L_sum);
	sp_shift = sub(sp_shift, temp_shift);
	sp = extract_h(L_shl(L_sum, temp_shift));                          /* Q15 */

	/* ======== Compute filter coefficients ======== */
	for (i = 0; i < SYN_SUBNUM; i++){
		for (j = 0; j < LPC_ORD; j++){
			temp = sub(ONE_Q15, syn_inp[i]);                           /* Q15 */
			temp1 = mult(prev_lsf[j], temp);                           /* Q15 */
			temp2 = mult(cur_lsf[j], syn_inp[i]);                      /* Q15 */
			inplsf[j] = add(temp1, temp2);                             /* Q15 */
		}
		lpc_lsp2pred(inplsf, synLPC, LPC_ORD);

		/* ======== Filter main loop ======== */

		/* ------ Tilt compesation ------ */
		temp = mult(X015_Q15, synLPC[1]);                              /* Q12 */
		if (temp > X05_Q12)
			temp = X05_Q12;
		if (temp < 0)
			temp = 0;
		emph = shl(temp, 3);                                           /* Q15 */

		/* It is unlikely for synhp[] to saturate -- emph is confined between */
		/* 0 and 0.5.  To saturate synhp[] the input speech[] should be of a  */
		/* large magnitude and the next sample should be of opposite sign,    */
		/* which should not be frequent.                                      */

		for (j = 0; j < SYN_SUBFRAME; j++){
			temp = mult(emph, hpm);                                     /* Q0 */
			hpm = speech[i*SYN_SUBFRAME + j];
			synhp[j] = sub(hpm, temp);                                  /* Q0 */
		}

		/* ------ Short-term postfilter ------ */

		/* Here we assume that SMOOTH_LEN (== 20) is smaller than             */
		/* SYN_SUBFRAME (== 45) so we only need to compute nokori[] when k is */
		/* 0.                                                                 */

		if (i == 0){
			v_equ(mem1old, mem1, LPC_ORD);
			v_equ(mem2old, mem2, LPC_ORD);

			for (j = 0; j < SMOOTH_LEN; j++){
				L_sum = 0;
				for (k = 0; k < LPC_ORD; k++){
					L_temp = L_mult(mem1old[k], alphaipFIR[k]);        /* Q13 */
					L_sum = L_add(L_sum, L_temp);                      /* Q13 */
				}
				for (k = LPC_ORD - 1; k > 0; k--)
					mem1old[k] = mem1old[k - 1];
				mem1old[0] = synhp[j];
				L_temp = L_shl(L_deposit_l(synhp[j]), 13);             /* Q13 */
				L_sum = L_add(L_sum, L_temp);

				for (k = 0; k < LPC_ORD; k++){
					L_temp = L_mult(mem2old[k], alphaipIIR[k]);        /* Q13 */
					L_sum = L_sub(L_sum, L_temp);
				}
				for (k = LPC_ORD - 1; k > 0; k--)
					mem2old[k] = mem2old[k - 1];
				temp1 = extract_l(L_shr(L_sum, 13));                    /* Q0 */
				mem2old[0] = temp1;                                     /* Q0 */
				temp = sub(ONE_Q15, window[j]);

				/* Experiments based on the 16 speech data used for testing   */
				/* show that nokori[] is within the range -15000 to 12000 or  */
				/* so.  Therefore using Q0 for nokori[] should be             */
				/* appropriate.                                               */

				temp1 = mult(temp, temp1);                              /* Q0 */
				L_temp = L_mult(gain, temp1);                          /* Q15 */
				nokori[j] = extract_l(L_shr(L_temp, 15));               /* Q0 */
			}
		}

		temp1 = ALPH;                                                  /* Q15 */
		temp2 = BETA;
		for (j = 0; j < LPC_ORD; j++){
			alphaipFIR[j] = mult(synLPC[j], temp1);                    /* Q12 */
			alphaipIIR[j] = mult(synLPC[j], temp2);
			temp1 = mult(ALPH, temp1);
			temp2 = mult(BETA, temp2);
		}

		for (j = 0; j < SYN_SUBFRAME; j++){
			L_sum = 0;
			for (k = 0; k < LPC_ORD; k++){
				L_temp = L_mult(mem1[k], alphaipFIR[k]);               /* Q13 */
				L_sum = L_add(L_sum, L_temp);                          /* Q13 */
			}
			for (k = LPC_ORD - 1; k > 0; k--)
				mem1[k] = mem1[k - 1];
			mem1[0] = synhp[j];
			L_temp = L_shl(L_deposit_l(synhp[j]), 13);                 /* Q13 */
			L_sum = L_add(L_sum, L_temp);

			for (k = 0; k < LPC_ORD; k++){
				L_temp = L_mult(mem2[k], alphaipIIR[k]);               /* Q13 */
				L_sum = L_sub(L_sum, L_temp);                          /* Q13 */
			}
			for (k = LPC_ORD - 1; k > 0; k--)
				mem2[k] = mem2[k - 1];
			L_sum = L_shr(L_sum, 13);                                   /* Q0 */
			mem2[0] = extract_l(L_sum);                                 /* Q0 */
			speech[i*SYN_SUBFRAME + j] = extract_l(L_sum);              /* Q0 */
		}
	}

	/* Computing op, the sum of squares of processed speech[].  We would      */
	/* treat speech[] as if it is Q15.                                        */

	op = 0;
	for (i = 0; i < FRAME; i++){
		temp = abs_s(speech[i]);
		if (op < temp)
			op = temp;
	}
	temp_shift = norm_s(op);
	L_sum = 0;
	for (i = 0; i < FRAME; i++){
		temp = shl(speech[i], temp_shift);                             /* Q15 */
		L_temp = L_mult(temp, temp);                                   /* Q31 */
		L_temp = L_shr(L_temp, 8);                                     /* Q23 */
		L_sum = L_add(L_sum, L_temp);                                  /* Q23 */
	}
	temp_shift = shl(temp_shift, 1);                  /* Squaring of speech[] */
	op_shift = sub(8, temp_shift);                   /* Aligning Q23 with Q31 */
	temp_shift = norm_l(L_sum);
	op_shift = sub(op_shift, temp_shift);
	op = extract_h(L_shl(L_sum, temp_shift));                          /* Q15 */

	/* According to the statistics collected from the 16 noisy speech files,  */
	/* gain ranges between 0.41 and 1.10.  It is difficult to estimate the    */
	/* absolute upper and lower bounds for gain, because we only know emph    */
	/* is between 0 and 0.5 when we filter speech[] into synhp[], and the     */
	/* filters formed with alphaipFIR[] and alphaipIIR[] form another problem */
	/* where we cannot easily predict how the roots for the polynomials       */
	/* formed with alphaipFIR[] and alphaipIIR[] are distributed, other than  */
	/* the ratio among them (determined by ALPH and BETA).  Therefore, we     */
	/* will simply use Q14 for gain and apply the necessary truncations.      */

	/* The original condition here compares op against 256 == 2^8.  Since we  */
	/* treated speech[] as Q15 instead of Q0, the computed op will be only    */
	/* 2^{-30} of the original value.  Therefore we only need to compare      */
	/* op_shift with -22 instead of calling comp_data_shift().                */

	if (op_shift >= -22){

		/* gain = sqrt(sp/op); */
		sp = shr(sp, 1);
		sp_shift = add(sp_shift, 1);
		temp_shift = sub(sp_shift, op_shift);
		if (temp_shift & 0x0001){                        /* temp_shift is odd */
			sp = shr(sp, 1);
			temp_shift = add(temp_shift, 1);
		}
		temp = divide_s(sp, op);                                       /* Q15 */
		temp_shift = shr(temp_shift, 1);
		temp = sqrt_Q15(temp);		                                  /* Q15 */
		temp_shift = sub(temp_shift, 1);

		/* There is no vigorous proof that the following left shift will      */
		/* never overflow.  However, experiences say that this is unlikely    */
		/* that is, sp/op is larger than 4, where the input speech[] has a    */
		/* larger energy than the processed one.  If we want to make the code */
		/* "bullet-proof", we can saturate gain computed below.               */

		gain = shl(temp, temp_shift);                                  /* Q14 */
	} else
		gain = 0;

	for (i = 0; i < FRAME; i++){
		L_temp = L_mult(gain, speech[i]);                              /* Q15 */
		speech[i] = extract_l(L_shr(L_temp, 15));                       /* Q0 */
	}

	/* The add() used for pos[i] below should not result in saturations.      */
	/* pos[] is multiplied by window[], while when we computed nokori[] it    */
	/* was multiplied by (1 - window[]).  gain multiplied by the filter       */
	/* output does not seem to saturate.                                      */

	for (i = 0; i < SMOOTH_LEN; i++){
		temp = mult(speech[i], window[i]);                              /* Q0 */
		speech[i] = add(temp, nokori[i]);                               /* Q0 */
	}

	/* 0.88770 = 0.9672 * 0.9178, where 0.9672 and 0.9178 come from the two   */
	/* filters below.  29088 is 0.8877 in Q15.                                */

	v_scale(speech, 29088, FRAME);

	/* Previous implementation of lpf3500() and hpf60() used iir_2nd_s().  It */
	/* was found that the accuracy is not sufficient and both low-frequency   */
	/* and high-frequency oscillations are found in the filtered signal.  Our */
	/* solutions are three-folds:                                             */
	/* (1) Using iir_2nd_d() instead of iir_2nd_s().                          */
	/* (2) We avoid the 2nd-order filter regarding the numerator              */
	/*     coefficients.  We use {1, -2, 1} and {1, 2, 1} (Q13) inside the    */
	/*     filter and move the gain multiplication out of the filters.        */
	/* (3) Both filters contribute a gain of 0.88770.  This gain is applied   */
	/*     before we feed the signal into the filters.  This tends to reduce  */
	/*     the likelihood of saturation.                                      */

	lpf3500(speech); 
	hpf60(speech);
}


/* The filter hpf60() can be rewritten as                                     */
/*                                                                            */
/*        Y(z)        (1 + AH z^{-1} + BH z^{-2})                             */
/* H(z) = ---- = GH * ---------------------------    (refer to the floating   */
/*        X(z)        (1 + CH z^{-1} + DH z^{-2})              point version) */
/*                                                                            */
/*                 (1 - 2 z^{-1} + z^{-2})                                    */
/*      = ---------------------------------------- * 0.9672                   */
/*          (1.0 - 1.9334 z^{-1} + 0.9355 z^{-2})                             */

static void		hpf60(Shortword speech[])
{
	static const Shortword  hpf60_num[3] = {                           /* Q13 */
								8192, -16384, 8192
	};
	static const Shortword  hpf60_den[3] = {                  /* Negated; Q13 */
								-8192, 15838, -7664
	};
	static Shortword	hpf60_delin[2] = {0, 0};                       /* Q13 */
	static Shortword	hpf60_delout_hi[2] = {0, 0};
	static Shortword	hpf60_delout_lo[2] = {0, 0};


	iir_2nd_d(speech, hpf60_den, hpf60_num, speech, hpf60_delin,
			  hpf60_delout_hi, hpf60_delout_lo, FRAME);
}


/* Refer to the comment for hpf60(), this filter can be rewritten as          */
/*                                                                            */
/*        Y(z)        (1 + AL z^{-1} + BL z^{-2})                             */
/* H(z) = ---- = GL * ---------------------------    (refer to the floating   */
/*        X(z)        (1 + CL z^{-1} + DL z^{-2})              point version) */
/*                                                                            */
/*                (1 + 2 z^{-1} + z^{-2})                                     */
/*      = ---------------------------------------- * 0.9178                   */
/*          (1.0 + 1.8307 z^{-1} + 0.8446 z^{-2})                             */

static void		lpf3500(Shortword speech[])
{
	static const Shortword	lpf3500_num[3] = {                         /* Q13 */
								8192, 16384, 8192
	};
	static const Shortword	lpf3500_den[3] = {                /* Negated; Q13 */
								-8192, -14997, -6919
	};
	static Shortword	lpf3500_delin[2] = {0, 0};                     /* Q13 */
	static Shortword	lpf3500_delout_hi[2] = {0, 0};
	static Shortword	lpf3500_delout_lo[2] = {0, 0};


	iir_2nd_d(speech, lpf3500_den, lpf3500_num, speech, lpf3500_delin,
			  lpf3500_delout_hi, lpf3500_delout_lo, FRAME);
}
