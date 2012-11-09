/*

2.4 kbps MELP Proposed Federal Standard speech coder

Fixed-point C code, version 1.0

Copyright (c) 1998, Texas Instruments, Inc.

Texas Instruments has intellectual property rights on the MELP
algorithm.	The Texas Instruments contact for licensing issues for
commercial and non-government use is William Gordon, Director,
Government Contracts, Texas Instruments Incorporated, Semiconductor
Group (phone 972 480 7442).

The fixed-point version of the voice codec Mixed Excitation Linear
Prediction (MELP) is based on specifications on the C-language software
simulation contained in GSM 06.06 which is protected by copyright and
is the property of the European Telecommunications Standards Institute
(ETSI). This standard is available from the ETSI publication office
tel. +33 (0)4 92 94 42 58. ETSI has granted a license to United States
Department of Defense to use the C-language software simulation contained
in GSM 06.06 for the purposes of the development of a fixed-point
version of the voice codec Mixed Excitation Linear Prediction (MELP).
Requests for authorization to make other use of the GSM 06.06 or
otherwise distribute or modify them need to be addressed to the ETSI
Secretariat fax: +33 493 65 47 16.

*/

/* ===================================== */
/* melp_sub.c: MELP-specific subroutines */
/* ===================================== */

#include "sc1200.h"
#include "mathhalf.h"
#include "math_lib.h"
#include "mat_lib.h"
#include "dsp_sub.h"
#include "melp_sub.h"
#include "pit_lib.h"
#include "constant.h"
#include "coeff.h"
#include "global.h"

/* Filter orders */

#define CONSTANT_SCALE		FALSE
#define MINGAIN				0
#define LOG10OF2X2			1233                         /* 2*log10(2) in Q11 */
#define GAIN_INT_DB_Q8		1280                              /* 5 * (1 << 8) */
#define ONE_Q8				256                                   /* (1 << 8) */
#define THREE_Q8			768                               /* 3 * (1 << 8) */
#define SIX_Q12				24576                            /* 6 * (1 << 12) */
#define TEN_Q11				20480                           /* 10 * (1 << 11) */
#define X0001_Q8			0                             /* 0.001 * (1 << 8) */
#define X01_Q14				1638                           /* 0.1 * (1 << 14) */
#define N2_Q11				-4096                           /* -2 * (1 << 11) */
#define M01_Q15				-3276                         /* -0.1 * (1 << 15) */
#define M10_Q11				-20480                         /* -10 * (1 << 11) */


/* Name: bpvc_ana.c                                                           */
/*  Description: Bandpass voicing analysis                                    */
/*  Inputs:                                                                   */
/*    speech[] - input speech signal                                          */
/*    fpitch[] - initial (floating point) pitch estimates                     */
/*  Outputs:                                                                  */
/*    bpvc[] - bandpass voicing decisions                                     */
/*    pitch[] - frame pitch estimates                                         */
/*  Returns: void                                                             */
/*                                                                            */
/*  Copyright (c) 1995,1997 by Texas Instruments, Inc.  All rights reserved.  */
/*                                                                            */
/* Q values: speech - Q0, fpitch - Q7, bpvc - Q14, pitch - Q7                 */

void bpvc_ana(Shortword speech[], Shortword fpitch[], Shortword bpvc[],
			  Shortword *pitch)
{
	register Shortword	i, section;
	static Shortword	bpfsp[NUM_BANDS][PITCH_FR - FRAME];
	static Shortword	bpfdelin[NUM_BANDS][BPF_ORD];
	static Shortword	bpfdelout[NUM_BANDS][BPF_ORD];
	static Shortword	envdel[NUM_BANDS][ENV_ORD];
	static Shortword	envdel2[NUM_BANDS];
	static BOOLEAN	firstTime = TRUE;
	Shortword	sigbuf[BPF_ORD + PITCH_FR];
	Shortword	pcorr, temp, scale;
	Shortword	filt_index;



	if (firstTime){
		for (i = 0; i < NUM_BANDS; i++){
			v_zap(bpfsp[i], PITCH_FR - FRAME);
			v_zap(bpfdelin[i], BPF_ORD);
			v_zap(bpfdelout[i], BPF_ORD);
		}
		for (i = 0; i < NUM_BANDS; i++)
			v_zap(envdel[i], ENV_ORD);
		v_zap(envdel2, NUM_BANDS);
		firstTime = FALSE;
	}

	/* Filter lowest band and estimate pitch */
	v_equ(&sigbuf[BPF_ORD], bpfsp[0], PITCH_FR - FRAME);
	v_equ(&sigbuf[BPF_ORD + PITCH_FR - FRAME],
		  &speech[PITCH_FR - FRAME - PITCHMAX], FRAME);

	for (section = 0; section < BPF_ORD/2; section ++){
		iir_2nd_s(&sigbuf[BPF_ORD + PITCH_FR - FRAME],
				  &bpf_den[section*3], &bpf_num[section*3],
				  &sigbuf[BPF_ORD + PITCH_FR - FRAME], &bpfdelin[0][section*2],
				  &bpfdelout[0][section*2], FRAME);
	}
	v_equ(bpfsp[0], &sigbuf[BPF_ORD + FRAME], PITCH_FR - FRAME);

	/* Scale signal for pitch correlations */
	f_pitch_scale(&sigbuf[BPF_ORD], &sigbuf[BPF_ORD], PITCH_FR);

	*pitch = frac_pch(&sigbuf[BPF_ORD + PITCHMAX], bpvc, fpitch[0], 5,
					  PITCHMIN, PITCHMAX, PITCHMIN_Q7, PITCHMAX_Q7,
					  MINLENGTH);

	for (i = 1; i < NUM_PITCHES; i++){
		temp = frac_pch(&sigbuf[BPF_ORD + PITCHMAX], &pcorr, fpitch[i], 5,
						PITCHMIN, PITCHMAX, PITCHMIN_Q7, PITCHMAX_Q7,
						MINLENGTH);

		/* choose largest correlation value */
		if (pcorr > bpvc[0]){
			*pitch = temp;
			bpvc[0] = pcorr;
		}
	}

	/* Calculate bandpass voicing for frames */
	for (i = 1; i < NUM_BANDS; i++){
		/* Bandpass filter input speech */
		v_equ(&sigbuf[BPF_ORD], bpfsp[i], PITCH_FR - FRAME);
		v_equ(&sigbuf[BPF_ORD + PITCH_FR - FRAME],
			  &speech[PITCH_FR - FRAME - PITCHMAX], FRAME);

		for (section = 0; section < BPF_ORD/2; section++){
			filt_index = (Shortword) (i*(BPF_ORD/2)*3 + section*3);
			iir_2nd_s(&sigbuf[BPF_ORD + PITCH_FR - FRAME],
					  &bpf_den[filt_index], &bpf_num[filt_index],
					  &sigbuf[BPF_ORD + PITCH_FR - FRAME],
					  &bpfdelin[i][section*2], &bpfdelout[i][section*2],
					  FRAME);
		}
		v_equ(bpfsp[i], &sigbuf[BPF_ORD + FRAME], PITCH_FR - FRAME);

		/* Scale signal for pitch correlations */
		scale = f_pitch_scale(&sigbuf[BPF_ORD], &sigbuf[BPF_ORD], PITCH_FR);

		/* Check correlations for each frame */
		temp = frac_pch(&sigbuf[BPF_ORD + PITCHMAX], &bpvc[i], *pitch, 0,
						PITCHMIN, PITCHMAX, PITCHMIN_Q7, PITCHMAX_Q7,
						MINLENGTH);

		/* Calculate envelope of bandpass filtered input speech */
		/* update delay buffers without scaling */
		temp = shr(envdel2[i], scale);
		envdel2[i] = shr(sigbuf[BPF_ORD + FRAME - 1], (Shortword) (-scale));
		v_equ_shr(&sigbuf[BPF_ORD - ENV_ORD], envdel[i], scale, ENV_ORD);
		envelope(&sigbuf[BPF_ORD], temp, &sigbuf[BPF_ORD], PITCH_FR);
		v_equ_shr(envdel[i], &sigbuf[BPF_ORD + FRAME - ENV_ORD],
				  (Shortword) (-scale), ENV_ORD);

		/* Scale signal for pitch correlations */
		f_pitch_scale(&sigbuf[BPF_ORD], &sigbuf[BPF_ORD], PITCH_FR);

		/* Check correlations for each frame */
		temp = frac_pch(&sigbuf[BPF_ORD + PITCHMAX], &pcorr, *pitch, 0,
						PITCHMIN, PITCHMAX, PITCHMIN_Q7, PITCHMAX_Q7,
						MINLENGTH);

		/* reduce envelope correlation */
		pcorr = sub(pcorr, X01_Q14);

		if (pcorr > bpvc[i])
			bpvc[i] = pcorr;
	}
}


/* Name: dc_rmv.c                                                             */
/*	Description: remove DC from input signal                                  */
/*	Inputs:                                                                   */
/*	  sigin[] - input signal                                                  */
/*	  dcdel[] - filter delay history (size DC_ORD)                            */
/*	  frame - number of samples to filter                                     */
/*	Outputs:                                                                  */
/*	  sigout[] - output signal                                                */
/*	  dcdel[] - updated filter delay history                                  */
/*	Returns: void                                                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */

/* DC removal filter                                                          */
/* 4th order Chebychev Type II 60 Hz removal filter                           */
/* cutoff = 60 Hz, stop = -30 dB                                              */
/* matlab commands: [z, p, k] = cheby2(4, 30, 0.015, 'high');                 */
/*						sos = zp2sos(z, p, k);                                */
/* order of sections swapped                                                  */

void dc_rmv(Shortword sigin[], Shortword sigout[], Shortword delin[],
			Shortword delout_hi[], Shortword delout_lo[],
			Shortword frame)
{
	static const Shortword	dc_num[(DC_ORD/2)*3] = {             /* Maybe Q13 */
#if NEW_DC_FILTER
		8192,  -16376, 8192,
		8192,  -16370, 8192,
		7353,  -14706, 7353
#else
		7769, -15534, 7769,
		8007, -15999, 8007
#endif
	};

	/* Signs of coefficients for dc_den are reversed.  dc_den[0] and          */
	/* dc_den[3] are ignored.                                                 */
	static const Shortword	dc_den[(DC_ORD/2)*3] = {
#if NEW_DC_FILTER
		-8192, 15729, -7569,
		-8192, 16111, -7959,
		-8192, 15520, -7353
#else
		-8192, 15521, -7358,
		-8192, 15986, -7836
#endif
	};
	register Shortword	section;

	/* Remove DC from input speech */
	v_equ(sigout, sigin, frame);
	for (section = 0; section < DC_ORD/2; section++)
		iir_2nd_d(sigout, &dc_den[section*3], &dc_num[section*3], sigout,
				  &delin[section*2], &delout_hi[section*2],
				  &delout_lo[section*2], frame);
}


/* This function removes the DC component of a given signal sigin[].  It      */
/* computes the offset Sum(sigin[])/len by                                    */
/* Sum(sigin[])/len = Sum(sigin[])/2^up_shift * (two_power_down/len) * 2      */
/* where two_power_down <= len < 2^up_shift.  This way we ensure that         */
/* Sum(sigin[])/up_shift does not overflow, (two_power_down/len) is a Q15     */
/* and the multiplication by 2 is straightforward.                            */
/*                                                                            */
/* Originally this function was written in such a way that we use a Shortword */
/* for "sum", and it is important to make sure there is no overflow with      */
/* "sum".  However, later it was found a siginificant inaccuracy is           */
/* introduced if we shift all sigin[] by up_shift (losing significant digits) */
/* and then add them.  This means when "len" is large the result could be     */
/* wrong.  Now "sum" is declared a Longword and all these problems disappear. */

void remove_dc(Shortword sigin[], Shortword sigout[], Shortword len)
{
	register Shortword	i;
	Shortword	up_shift, two_power_down;
	Longword	sum;
	Shortword	temp;
	Shortword	offset;


	/* Find up_shift and two_power_down.  Note that two_power_down can be     */
	/* equal to len.                                                          */

	temp = norm_s(len);
	up_shift = sub(15, temp);
	temp = sub(up_shift, 1);
	two_power_down = shl(1, temp);

	sum = 0;
	for (i = 0; i < len; i++)
		sum = L_add(sum, L_deposit_l(sigin[i]));
	sum = L_shr(sum, up_shift);

	/* if (len > two_power_down) */
	/* if condition has been removed 'cos it is always true */
	{
		temp = divide_s(two_power_down, len);                          /* Q15 */
		offset = mult(extract_l(sum), temp);
	}
	offset = shl(offset, 1);

	for (i = 0; i < len; i++)
		sigout[i] = sub(sigin[i], offset);
}


/* Name: gain_ana.c                                                           */
/*	Description: analyze gain level for input signal                          */
/*	Inputs:                                                                   */
/*	  sigin[] - input signal                                                  */
/*	  pitch - pitch value (for pitch synchronous window)                      */
/*	  minlength - minimum window length                                       */
/*	  maxlength - maximum window length                                       */
/*	Outputs:                                                                  */
/*	Returns: log gain in dB                                                   */
/*                                                                            */
/*  Copyright (c) 1997 by Texas Instruments, Inc.  All rights reserved.       */
/*                                                                            */
/*	Q values                                                                  */
/*	--------                                                                  */
/*	pitch - Q7                                                                */
/*	sigin (speech) - Q0                                                       */

Shortword gain_ana(Shortword sigin[], Shortword pitch, Shortword minlength,
				   Shortword maxlength)
{
	Shortword	length;                                                 /* Q0 */
	Shortword	flength;                                                /* Q6 */
	Shortword	gain;                                                   /* Q8 */
	Shortword	pitch_Q6;                                               /* Q6 */
	Shortword	scale;
	Shortword	tmp_minlength;
	Shortword	sigbegin;
	Shortword	*temp_buf, *tmp_sig;
	Shortword	S_temp1, S_temp2;
	Longword	L_temp;


	/* initialize scaled pitch and minlength */
	pitch_Q6 = shr(pitch, 1);                                       /* Q7->Q6 */

	tmp_minlength = shl(minlength, 6);

	/* Find shortest pitch multiple window length (floating point) */
	flength = pitch_Q6;
	while (flength < tmp_minlength){
		flength = add(flength, pitch_Q6);
	}

	/* Convert window length to integer and check against maximum */
	length = shr(add(flength, X05_Q6), 6);

	if (length > maxlength){
		/* divide by 2 */
		length = shr(length, 1);
	}

	/* Calculate RMS gain in dB */
	/*	gain = 10.0*log10(0.01 + */
	/*		   (v_magsq(&sigin[-(length/2)], length)/length)); */

	/* use this adaptive scaling if more precision needed at low levels.      */
	/* Seemed like it wasn't worth the mips */

	sigbegin = negate(shr(length, 1));

	/* Right shift input signal and put in temp buffer */
	temp_buf = v_get(length);

	scale = 3;
#if (!CONSTANT_SCALE)
	v_equ_shr(temp_buf, &sigin[sigbegin], scale, length);
	L_temp = L_v_magsq(temp_buf, length, 0, 1);

	if (L_temp){
		S_temp1 = norm_l(L_temp);
		scale = sub(scale, shr(S_temp1, 1));
		if (scale < 0)
			scale = 0;
	} else
		scale = 0;
#endif

	if (scale)
		v_equ_shr(temp_buf, &sigin[sigbegin], scale, length);
	else
		v_equ(temp_buf, &sigin[sigbegin], length);
	tmp_sig = temp_buf - sigbegin;

	if (scale){
		L_temp = L_v_magsq(&tmp_sig[sigbegin], length, 0, 0);
		S_temp1 = L_log10_fxp(L_temp, 0);
		S_temp2 = L_log10_fxp(L_deposit_l(length), 0);
		S_temp1 = sub(S_temp1, S_temp2);
		/* shift right to counter-act for the shift in L_mult */
		S_temp2 = extract_l(L_shr(L_mult(scale, LOG10OF2X2), 1));
		S_temp1 = add(S_temp1, S_temp2);
		S_temp1 = mult(TEN_Q11, S_temp1);
		gain = shl(S_temp1, 1);
	} else {
		L_temp = L_v_magsq(&tmp_sig[sigbegin], length, 0, 0);
		/* Add one to avoid log of a zero value */
		if (L_temp == 0)
			S_temp1 = N2_Q11;
		else
			S_temp1 = L_log10_fxp(L_temp, 0);
		S_temp2 = L_log10_fxp(L_deposit_l(length), 0);
		S_temp1 = sub(S_temp1, S_temp2);
		S_temp1 = mult(TEN_Q11, S_temp1);
		gain = shl(S_temp1, 1);
	}

	if (gain < MINGAIN){
		gain = MINGAIN;
	}

	v_free(temp_buf);

	return(gain);
}


/* Name: lin_int_bnd.c                                                        */
/*	Description: Linear interpolation within bounds                           */
/*	Inputs:                                                                   */
/*	  x - input X value                                                       */
/*	  xmin - minimum X value                                                  */
/*	  xmax - maximum X value                                                  */
/*	  ymin - minimum Y value                                                  */
/*	  ymax - maximum Y value                                                  */
/*	Returns: y - interpolated and bounded y value                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	x,xmin,xmax - Q8                                                          */
/*	y,ymin,ymax - Q15                                                         */

Shortword lin_int_bnd(Shortword x, Shortword xmin, Shortword xmax,
					  Shortword ymin, Shortword ymax)
{
	Shortword	y, temp1, temp2;


	if (x <= xmin)
		y = ymin;
	else if (x >= xmax)
		y = ymax;
	else {
		/* y = ymin + (x-xmin)*(ymax-ymin)/(xmax-xmin); */
		temp1 = sub(x, xmin);
		temp2 = sub(ymax, ymin);
		temp1 = mult(temp1, temp2);                            /* temp1 in Q8 */
		temp2 = sub(xmax, xmin);
		/* temp1 always smaller than temp2 */
		temp1 = divide_s(temp1, temp2);                       /* temp1 in Q15 */
		y = add(ymin, temp1);
	}

	return(y);
}


/* Name: noise_est.c                                                          */
/*	Description: Estimate long-term noise floor                               */
/*	Inputs:                                                                   */
/*	  gain - input gain (in dB)                                               */
/* 	  noise_gain - current noise gain estimate                                */
/*	  up - maximum up stepsize                                                */
/*	  down - maximum down stepsize                                            */
/*	  min - minimum allowed gain                                              */
/*	  max - maximum allowed gain                                              */
/*	Outputs:                                                                  */
/*	  noise_gain - updated noise gain estimate                                */
/*	Returns: void                                                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	gain - Q8, *noise_gain - Q8, up - Q19, down - Q17, min - Q8, max - Q8     */

void noise_est(Shortword gain, Shortword *noise_gain, Shortword up,
			   Shortword down, Shortword min, Shortword max)
{
	Shortword	temp1, temp2;
	Longword	L_noise_gain, L_temp;


	/* Update noise_gain */
	/*	temp1 = add(*noise_gain, up); */
	/*	temp2 = add(*noise_gain, down); */
	L_noise_gain = L_deposit_h(*noise_gain);           /* L_noise_gain in Q24 */
	L_temp = L_shl(L_deposit_l(up), 5);
	L_temp = L_add(L_noise_gain, L_temp);
	temp1 = round(L_temp);
	L_temp = L_shl(L_deposit_l(down), 7);
	L_temp = L_add(L_noise_gain, L_temp);
	temp2 = round(L_temp);

	if (gain > temp1)
		*noise_gain = temp1;
	else if (gain < temp2)
		*noise_gain = temp2;
	else
		*noise_gain = gain;

	/* Constrain total range of noise_gain */
	if (*noise_gain < min)
		*noise_gain = min;
	if (*noise_gain > max)
		*noise_gain = max;
}


/* Name: noise_sup.c                                                          */
/*	Description: Perform noise suppression on speech gain                     */
/*	Inputs: (all in dB)                                                       */
/*	  gain - input gain (in dB)                                               */
/*	  noise_gain - current noise gain estimate (in dB)                        */
/*	  max_noise - maximum allowed noise gain                                  */
/*	  max_atten - maximum allowed attenuation                                 */
/*	  nfact - noise floor boost                                               */
/*	Outputs:                                                                  */
/*	  gain - updated gain                                                     */
/*	Returns: void                                                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	*gain - Q8, noise_gain - Q8, max_noise - Q8, max_atten - Q8, nfact - Q8   */

void noise_sup(Shortword *gain, Shortword noise_gain, Shortword max_noise,
			   Shortword max_atten, Shortword nfact)
{
	Shortword	gain_lev, suppress, temp;
	Longword	L_temp;


	/* Reduce effect for louder background noise */
	if (noise_gain > max_noise)
		noise_gain = max_noise;

	/* Calculate suppression factor */
	gain_lev = sub(*gain, add(noise_gain, nfact));
	if (gain_lev > X0001_Q8){
		/*	suppress = -10.0*log10(1.0 - pow(10.0,-0.1*gain_lev));            */
		L_temp = L_mult(M01_Q15, gain_lev);                  /* L_temp in Q24 */
		temp = extract_h(L_shl(L_temp, 4));                    /* temp in Q12 */
		temp = pow10_fxp(temp, 14);
		temp = sub(ONE_Q14, temp);
		suppress = mult(M10_Q11, log10_fxp(temp, 14));     /* log returns Q12 */
		if (suppress > max_atten)
			suppress = max_atten;
	} else
		suppress = max_atten;

	/* Apply suppression to input gain */
	*gain = sub(*gain, suppress);
}


/* Name: q_bpvc.c, q_bpvc_dec.c                                               */
/* 	Description: Quantize/decode bandpass voicing                             */
/*	Inputs:                                                                   */
/*	  bpvc, bpvc_index                                                        */
/*	  num_bands - number of bands                                             */
/*	Outputs:                                                                  */
/*	  bpvc, bpvc_index                                                        */
/*	Returns: uv_flag - flag if unvoiced                                       */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	*bpvc - Q14                                                               */

BOOLEAN q_bpvc(Shortword bpvc[], Shortword *bpvc_index, Shortword num_bands)
{
	register Shortword	i;
	BOOLEAN		uv_flag;
	Shortword	index;


	if (bpvc[0] > BPTHRESH_Q14){

		/* Voiced: pack bandpass voicing */
		uv_flag = FALSE;
		index = 0;
		bpvc[0] = ONE_Q14;

		for (i = 1; i < num_bands; i++){
			index = shl(index, 1);                      /* left shift one bit */
			if (bpvc[i] > BPTHRESH_Q14){
				bpvc[i] = ONE_Q14;
				index |= 1;
			} else {
				bpvc[i] = 0;
				index |= 0;
			}
		}

		/* Don't use invalid code (only top band voiced) */
		if (index == INVALID_BPVC){
			bpvc[num_bands - 1] = 0;
			index = 0;
		}
	} else {
		/* Unvoiced: force all bands unvoiced */
		uv_flag = TRUE;
		index = 0;
		v_zap(bpvc, num_bands);
	}

	*bpvc_index = index;
	return(uv_flag);
}


void q_bpvc_dec(Shortword bpvc[], Shortword bpvc_index, BOOLEAN uv_flag,
				Shortword num_bands)
{
	register Shortword	i;


	if (uv_flag){                              /* Unvoiced: set all bpvc to 0 */
		bpvc_index = 0;
		bpvc[0] = 0;
	} else                                      /* Voiced: set bpvc[0] to 1.0 */
		bpvc[0] = ONE_Q14;

	if (bpvc_index == INVALID_BPVC){
		/* Invalid code received: set higher band voicing to zero */
		bpvc_index = 0;
	}

	/* Decode remaining bands */
	for (i = (Shortword) (num_bands - 1); i > 0; i--){
		if (bpvc_index & 1)
			bpvc[i] = ONE_Q14;
		else
			bpvc[i] = 0;
		bpvc_index = shr(bpvc_index, 1);
	}
}


/* Name: q_gain.c, q_gain_dec.c                                               */
/*	Description: Quantize/decode two gain terms using quasi-differential      */
/*               coding                                                       */
/*	Inputs:                                                                   */
/*	  gain[2],gain_index[2]                                                   */
/*	  gn_qlo, gn_qup, gn_qlev for second gain term                            */
/*	Outputs:                                                                  */
/*	  gain[2],gain_index[2]                                                   */
/*	Returns: void                                                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	*gain - Q8, gn_qlo - Q8, gn_qup - Q8, gn_qlev - Q10                       */

void q_gain(Shortword *gain, Shortword *gain_index, Shortword gn_qlo,
			Shortword gn_qup, Shortword gn_qlev, Shortword gn_qlev_q,
			Shortword double_flag, Shortword scale)
{
	static Shortword	prev_gain = 0;
	Shortword	temp, temp2;


	/* Quantize second gain term with uniform quantizer */
	quant_u(&gain[1], &gain_index[1], gn_qlo, gn_qup, gn_qlev, gn_qlev_q,
			double_flag, scale);

	/* Check for intermediate gain interpolation */
	if (gain[0] < gn_qlo){
		gain[0] = gn_qlo;
	}
	if (gain[0] > gn_qup){
		gain[0] = gn_qup;
	}

	/* if (fabs(gain[1] - prev_gain) < GAIN_INT_DB &&
		 fabs(gain[0] - 0.5*(gain[1]+prev_gain)) < 3.0) */
	temp = add(shr(gain[1], 1), shr(prev_gain, 1));
	if (abs_s(sub(gain[1], prev_gain)) < GAIN_INT_DB_Q8 &&
		abs_s(sub(gain[0], temp)) < THREE_Q8){

		/* interpolate and set special code */
		/* gain[0] = 0.5*(gain[1] + prev_gain); */
		gain[0] = temp;
		gain_index[0] = 0;
	} else {

		/* Code intermediate gain with 7-levels */
		if (prev_gain < gain[1]){
			temp = prev_gain;
			temp2 = gain[1];
		} else {
			temp = gain[1];
			temp2 = prev_gain;
		}
		temp = sub(temp, SIX_Q8);
		temp2 = add(temp2, SIX_Q8);
		if (temp < gn_qlo){
			temp = gn_qlo;
		}
		if (temp2 > gn_qup){
			temp2 = gn_qup;
		}
		quant_u(&gain[0], &gain_index[0], temp, temp2, 6, SIX_Q12, 0, 3);

		/* Skip all-zero code */
		gain_index[0] = add(gain_index[0], 1);
	}

	/* Update previous gain for next time */
	prev_gain = gain[1];
}


void q_gain_dec(Shortword *gain, Shortword *gain_index, Shortword gn_qlo,
				Shortword gn_qup, Shortword gn_qlev_q, Shortword scale)
{
	static Shortword	prev_gain = 0;
	static BOOLEAN	prev_gain_err = FALSE;
	Shortword	temp, temp2;


	/* Decode second gain term */
	quant_u_dec(gain_index[1], &gain[1], gn_qlo, gn_qup, gn_qlev_q, scale);

	if (gain_index[0] == 0){

		/* interpolation bit code for intermediate gain */
		temp = sub(gain[1], prev_gain);
		temp = abs_s(temp);
		if (temp > GAIN_INT_DB_Q8){
			/* Invalid received data (bit error) */
			if (!prev_gain_err){
				/* First time: don't allow gain excursion */
				gain[1] = prev_gain;
			}
			prev_gain_err = TRUE;
		} else
			prev_gain_err = FALSE;

		/* Use interpolated gain value */
		/* gain[0] = 0.5*(gain[1]+prev_gain); */
		gain[0] = add(shr(gain[1], 1), shr(prev_gain, 1));
	} else {
		/* Decode 7-bit quantizer for first gain term */
		prev_gain_err = FALSE;
		if (prev_gain < gain[1]){
			temp = prev_gain;
			temp2 = gain[1];
		} else {
			temp = gain[1];
			temp2 = prev_gain;
		}
		temp = sub(temp, SIX_Q8);
		temp2 = add(temp2, SIX_Q8);
		if (temp < gn_qlo)
			temp = gn_qlo;
		if (temp2 > gn_qup)
			temp2 = gn_qup;

		/* Previously we subtract 1 from gain_index[0] in this function. */
		/* Now to incorporate the transcoder, we want to avoid changing  */
		/* gain_index[0] in this function.                               */
		quant_u_dec(sub(gain_index[0], 1), &gain[0], temp, temp2, SIX_Q12, 3);
	}

	/* Update previous gain for next time */
	prev_gain = gain[1];
}


/* Name: scale_adj.c                                                          */
/*	Description: Adjust scaling of output speech signal.                      */
/*	Inputs:                                                                   */
/*	  speech - speech signal                                                  */
/*	  gain - desired RMS gain (log gain)                                      */
/*	  length - number of samples in signal                                    */
/*	  scale_over - number of points to interpolate scale factor               */
/*	Warning: scale_over is assumed to be less than length.                    */
/* 	Outputs:                                                                  */
/*	  speech - scaled speech signal                                           */
/*	Returns: void                                                             */
/*                                                                            */
/*	Copyright (c) 1995,1997 by Texas Instruments, Inc.	All rights reserved.  */
/*                                                                            */
/*	Q values:                                                                 */
/*	*speech - Q0                                                              */
/*	gain - Q12                                                                */

void scale_adj(Shortword *speech, Shortword gain, Shortword length,
			   Shortword scale_over, Shortword inv_scale_over)
{
	static Shortword	prev_scale;             /* Previous scale factor, Q13 */
	register Shortword	i;
	Shortword	scale, shift, log_magsq, log_length;
	Shortword	temp;
	Shortword	*tempbuf;
	Longword	L_magsq, L_length, interp1, interp2;
	Longword	L_temp;


	/* Calculate desired scaling factor to match gain level */
	/* scale = gain / (sqrt(v_magsq(&speech[0],length) / length) + .01); */
	/* find normalization factor for buffer */
	tempbuf = v_get(length);

	shift = 4;
	v_equ_shr(tempbuf, speech, shift, length);
	L_magsq = L_v_magsq(tempbuf, length, 0, 1);

	if (L_magsq){
		/* normalize with 1 bit of headroom */
		temp = norm_l(L_magsq);
		temp = sub(temp, 1);
		shift = sub(shift, shr(temp, 1));
	} else
		shift = 0;

	v_equ_shr(tempbuf, speech, shift, length);

	/* exp = log(2^shift) */
	shift = shl(shift, 1);                    /* total compensation = shift*2 */
	temp = shl(ONE_Q8, shift);
	shift = log10_fxp(temp, 8);                               /* shift in Q12 */

	L_magsq = L_v_magsq(tempbuf, length, 0, 0);
	L_magsq = L_add(L_magsq, 1);                /* ensure L_magsq is not zero */
	log_magsq = L_log10_fxp(L_magsq, 0);                  /* log_magsq in Q11 */
	/* L_magsq = log_magsq in Q12 */
	L_magsq = L_deposit_l(log_magsq);
	L_magsq = L_shl(L_magsq, 1);
	/* compensate for normalization */
	/* L_magsq = log magnitude/2 in Q13 */
	L_temp = L_deposit_l(shift);
	L_magsq = L_add(L_magsq, L_temp);

	temp = shl(length, 7);
	log_length = log10_fxp(temp, 7);                     /* log_length in Q12 */
	/* L_length = log_length/2 in Q13 */
	L_length = L_deposit_l(log_length);

	L_temp = L_deposit_l(gain);
	L_temp = L_shl(L_temp, 1);                               /* L_temp in Q13 */
	L_temp = L_sub(L_temp, L_magsq);
	L_temp = L_add(L_temp, L_length);
	L_temp = L_shr(L_temp, 1);                                  /* Q13 -> Q12 */
	temp = extract_l(L_temp);                                  /* temp in Q12 */
	scale = pow10_fxp(temp, 13);

	/* interpolate scale factors for first scale_over points */
	for (i = 1; i < scale_over; i++){
		/* speech[i-1] *= ((scale*i + prev_scale*(scale_over - i))
									  * (1.0/scale_over)); */
		temp = sub(scale_over, i);
		temp = shl(temp, 11);
		L_temp = L_mult(temp, inv_scale_over);               /* L_temp in Q30 */
		L_temp = L_shl(L_temp, 1);                           /* L_temp in Q31 */
		temp = extract_h(L_temp);                              /* temp in Q15 */
		interp1 = L_mult(prev_scale, temp);                /* interp1 in Q29 */

		temp = shl(i, 11);
		L_temp = L_mult(temp, inv_scale_over);               /* L_temp in Q30 */
		L_temp = L_shl(L_temp, 1);                           /* L_temp in Q31 */
		temp = extract_h(L_temp);                              /* temp in Q15 */
		interp2 = L_mult(scale, temp);                      /* interp2 in Q29 */
		L_temp = L_add(interp1, interp2);
		interp1 = extract_h(L_temp);                        /* interp1 in Q13 */

		L_temp = L_mult(speech[i - 1], (Shortword) interp1);
		L_temp = L_shl(L_temp, 2);
		speech[i-1] = extract_h(L_temp);
	}

	/* Scale rest of signal */
	v_scale_shl(&speech[scale_over - 1], scale, (Shortword) (length - scale_over + 1), 2);

	/* Update previous scale factor for next call */
	prev_scale = scale;

	v_free(tempbuf);
}

