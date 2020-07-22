void io_hlt(void);
void io_cli(void);
void io_out8(int port, int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);

#define COL8_000000		0
#define COL8_FF0000		1
#define COL8_00FF00		2
#define COL8_FFFF00		3
#define COL8_0000FF		4
#define COL8_FF00FF		5
#define COL8_00FFFF		6
#define COL8_FFFFFF		7
#define COL8_C6C6C6		8
#define COL8_840000		9
#define COL8_008400		10
#define COL8_848400		11
#define COL8_000084		12
#define COL8_840084		13
#define COL8_008484		14
#define COL8_848484		15


void putfont8(char *vram, int uiScreenWidth, int x, int y, char c, char *font)
{
    int i = 0;
    char *p0 = 0, *p = 0, *p1 = 0, d = 0;
	
	p0 = vram + y * uiScreenWidth + x;
	
    for (i = 0; i < 32; i += 2) 
	{
        p = p0 + i / 2 * uiScreenWidth;
        d  = font[i];
        if ((d & 0x80) != 0) { p[0] = c; }
        if ((d & 0x40) != 0) { p[1] = c; }
        if ((d & 0x20) != 0) { p[2] = c; }
        if ((d & 0x10) != 0) { p[3] = c; }
        if ((d & 0x08) != 0) { p[4] = c; }
        if ((d & 0x04) != 0) { p[5] = c; }
        if ((d & 0x02) != 0) { p[6] = c; }
        if ((d & 0x01) != 0) { p[7] = c; }
		
		p1 = p + 8;
        d  = font[i + 1];
        if ((d & 0x80) != 0) { p1[0] = c; }
        if ((d & 0x40) != 0) { p1[1] = c; }
        if ((d & 0x20) != 0) { p1[2] = c; }
        if ((d & 0x10) != 0) { p1[3] = c; }
        if ((d & 0x08) != 0) { p1[4] = c; }
        if ((d & 0x04) != 0) { p1[5] = c; }
        if ((d & 0x02) != 0) { p1[6] = c; }
        if ((d & 0x01) != 0) { p1[7] = c; }
		
    }
}

void PrintChineseChar(char *ucVideoMemoryStartAddress, int iSreenWidth, int iStartDisplayX, int iStartDisplayY, char cColor, unsigned int uiAreaCode, unsigned int uiBitCode)
{
	extern char hzk16[6700 * 32];
    
    putfont8(ucVideoMemoryStartAddress, iSreenWidth, iStartDisplayX, iStartDisplayY, 
	cColor, hzk16 + ((uiAreaCode - 1) * 94 + (uiBitCode - 1)) * 32);	
}

void Main(void)
{
	char *vram;/* ��������vram������BYTE [...]��ַ */
	int xsize, ysize;

	init_palette();/* �趨��ɫ�� */
	//vram = (char *) 0xa0000;/* ��ַ������ֵ */
	//xsize = 320;
	//ysize = 200;
	
	vram = (char *) 0xe0000000;
	xsize = 1024;
	ysize = 768;

	/* ���� 0xa0000 + x + y * 320 �������� 8*/
	boxfill8(vram, xsize, COL8_000000,  0,         0,          xsize -  1, ysize - 29);
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 28, xsize -  1, ysize - 28);
	boxfill8(vram, xsize, COL8_FFFFFF,  0,         ysize - 27, xsize -  1, ysize - 27);
	boxfill8(vram, xsize, COL8_C6C6C6,  0,         ysize - 26, xsize -  1, ysize -  1);

	boxfill8(vram, xsize, COL8_FFFFFF,  3,         ysize - 24, 59,         ysize - 24);
	boxfill8(vram, xsize, COL8_FFFFFF,  2,         ysize - 24,  2,         ysize -  4);
	boxfill8(vram, xsize, COL8_848484,  3,         ysize -  4, 59,         ysize -  4);
	boxfill8(vram, xsize, COL8_848484, 59,         ysize - 23, 59,         ysize -  5);
	boxfill8(vram, xsize, COL8_000000,  2,         ysize -  3, 59,         ysize -  3);
	boxfill8(vram, xsize, COL8_000000, 60,         ysize - 24, 60,         ysize -  3);

	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 24, xsize -  4, ysize - 24);
	boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize -  4);
	boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize -  3, xsize -  4, ysize -  3);
	boxfill8(vram, xsize, COL8_FFFFFF, xsize -  3, ysize - 24, xsize -  3, ysize -  3);
	
	int i = 0;
	int j = 0;
	
	//for (i = 0; i < 63; i++)
	//	for (j = 0; j < 46; j++)
	//		PrintChineseChar(vram, xsize, i * 16 , j * 16 , COL8_FFFFFF, j, i);
		
	//PrintChineseChar(vram, xsize, 64, 64, COL8_FFFFFF, 17, 46);
	int Length = 5;
	int Placeholder = 2;
	int ChineseCharAreaBitCodes[] = {54, 48, 25, 90, 3, 12, 36, 67, 26, 35}; //zhongguo,nihao
	int i_StartX = 16;
	int i_StartY = 16;
	for (i = 0; i < 6; i++, i_StartX += 16)
		PrintChineseChar(vram, xsize, i_StartX, i_StartY, COL8_FFFFFF, ChineseCharAreaBitCodes[i * 2],  ChineseCharAreaBitCodes[i * 2 + 1]);
	
	for (;;) {
		io_hlt();
	}
}


void init_palette(void)
{
	static unsigned char table_rgb[16 * 3] = {
		0x00, 0x00, 0x00,	/*  0:�� */
		0xff, 0x00, 0x00,	/*  1:���� */
		0x00, 0xff, 0x00,	/*  2:���� */
		0xff, 0xff, 0x00,	/*  3:���� */
		0x00, 0x00, 0xff,	/*  4:���� */
		0xff, 0x00, 0xff,	/*  5:���� */
		0x00, 0xff, 0xff,	/*  6:ǳ���� */
		0xff, 0xff, 0xff,	/*  7:�� */
		0xc6, 0xc6, 0xc6,	/*  8:���� */
		0x84, 0x00, 0x00,	/*  9:���� */
		0x00, 0x84, 0x00,	/* 10:���� */
		0x84, 0x84, 0x00,	/* 11:���� */
		0x00, 0x00, 0x84,	/* 12:���� */
		0x84, 0x00, 0x84,	/* 13:���� */
		0x00, 0x84, 0x84,	/* 14:ǳ���� */
		0x84, 0x84, 0x84	/* 15:���� */
	};
	set_palette(0, 15, table_rgb);
	return;

	/* C�����е�static char���ֻ���������ݣ��൱�ڻ���е�DBָ�� */
}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	eflags = io_load_eflags();	/* ��¼�ж���ɱ�־��ֵ */
	io_cli(); 					/* ���ж���ɱ�־��Ϊ0,��ֹ�ж� */
	io_out8(0x03c8, start);
	for (i = start; i <= end; i++) {
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	io_store_eflags(eflags);	/* ��ԭ�ж���ɱ�־ */
	return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1)
{
	int x, y;
	for (y = y0; y <= y1; y++) {
		for (x = x0; x <= x1; x++)
			vram[y * xsize + x] = c;
	}
	return;
}


