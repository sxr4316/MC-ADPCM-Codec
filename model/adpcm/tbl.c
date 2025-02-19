
/*
 *
 *  @(#) tbl.c 1.2@(#)
 *
 */

#include "encode.h"

struct tbl quan_tbl[QTBL_LEN] = {
/*	DS	  DLN		I	ID	*/
	0,	400,2047,	7,	15,
	0,	349,399,	6,	14,
	0,	300,348,	5,	13,
	0,	246,299,	4,	12,
	0,	178,245,	3,	11,
	0,	80,177,		2,	10,
	0,	0,79,		1,	 9,
	0,	3972,4095,	1,	 9,
	0,	2048,3971,	0xf,	 7,
	1,	2048,3971,	0xf,	 7,
	1,	3972,4095,	0xe,	 6,
	1,	0,79,		0xe,	 6,
	1,	80,177,		0xd,	 5,
	1,	178,245,	0xc,	 4,
	1,	246,299,	0xb,	 3,
	1,	300,348,	0xa,	 2,
	1,	349,399,	0x9,	 1,
	1,	400,2047,	0x8,	 0};


long recon_tbl[RTBL_LEN] = {
/*	DQLN		*/
	2048,
	4,
	135,
	213,
	273,
	323,
	373,
	425,
	425,
	373,
	323,
	273,
	213,
	135,
	4,
	2048};

long mult_tbl[MTBL_LEN] = {
/*	WI		*/
 	4084,		/* 4084  12 bit signed TC */
	18,
	41,
	64,
	112,
	198,
	355,
	1122 };
