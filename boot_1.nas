; haribote-ipl
; TAB=4

CYLS	EQU		10				; ����CYLS=10
BOTPAK	EQU		0x00280000		; ����bootpack
DSKCAC	EQU		0x00100000		; ���̻����λ��
DSKCAC0	EQU		0x00008000		; ���̻����λ�ã�ʵģʽ��

; BOOT_INFO���
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; ������ɫ����Ϣ
SCRNX	EQU		0x0ff4			; �ֱ���X
SCRNY	EQU		0x0ff6			; �ֱ���Y
VRAM	EQU		0x0ff8			; ͼ�񻺳�������ʼ��ַ

		ORG		0x7c00			; ָ������װ�ص�ַ		
		
; ��׼FAT12��ʽ����ר�õĴ��� Stand FAT12 format floppy code
		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; �����������ƣ�8�ֽڣ�
		DW		512				; ÿ��������sector����С������512�ֽڣ�
		DB		1				; �أ�cluster����С������Ϊ1��������
		DW		1				; FAT��ʼλ�ã�һ��Ϊ��һ��������
		DB		2				; FAT����������Ϊ2��
		DW		224				; ��Ŀ¼��С��һ��Ϊ224�
		DW		2880			; �ô��̴�С������Ϊ2880����1440*1024/512��
		DB		0xf0			; �������ͣ�����Ϊ0xf0��
		DW		9				; FAT�ĳ��ȣ���??9������
		DW		18				; һ���ŵ���track���м�������������Ϊ18��
		DW		2				; ��ͷ������??2��
		DD		0				; ��ʹ�÷�����������0
		DD		2880			; ��дһ�δ��̴�С
		DB		0,0,0x29		; ���岻�����̶���
		DD		0xffffffff		; �������ǣ�������
		DB		"HARIBOTEOS "	; ���̵����ƣ�����Ϊ11��?��������ո�
		DB		"FAT12   "		; ���̸�ʽ���ƣ���??8��?��������ո�
		RESB	18				; �ȿճ�18�ֽ�

; ��������
entry:
		MOV		AX,0			; ��ʼ���Ĵ���
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ��ȡ����
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; ����0
		MOV		DH,0			; ��ͷ0
		MOV		CL,2			; ����2

readloop:
		MOV		SI,0			; ��¼ʧ�ܴ����Ĵ���

retry:
		MOV		AH,0x02			; AH=0x02 : �������
		MOV		AL,1			; 1������
		MOV		BX,0
		MOV		DL,0x00			; A������
		INT		0x13			; ���ô���BIOS
		JNC		next			; û��������ת��fin
		ADD		SI,1			; ��SI��1
		CMP		SI,5			; �Ƚ�SI��5
		JAE		error			; SI >= 5 ��ת��error
		MOV		AH,0x00
		MOV		DL,0x00			; A������
		INT		0x13			; ����������
		JMP		retry
next:
		MOV		AX,ES			; ���ڴ��ַ����0x200��512/16ʮ������ת����
		ADD		AX,0x0020
		MOV		ES,AX			; ADD ES,0x020��Ϊû��ADD ES��ֻ��ͨ��AX����
		ADD		CL,1			; ��CL�����1
		CMP		CL,18			; �Ƚ�CL��18
		JBE		readloop		; CL <= 18 ��ת��readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; DH < 2 ��ת��readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS ��ת��readloop

; ��ȡ��ϣ���ת��haribote.sysִ�У�
		MOV		[0x0ff0],CH		; IPL���ɤ��ޤ��i����Τ�����
				
; �����`�ɤ��O��
		;MOV		AL,0x13			; VGA�Կ���320x200x8bit
		;MOV		AH,0x00
		
        MOV        BX,0x105+0x4000
        MOV        AX,0x4f02
		INT		0x10
		
		MOV		BYTE [VMODE],8	; ��Ļ��ģʽ���ο�C���Ե����ã�
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; ͨ��BIOS��ȡָʾ��״̬
		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL
				
; ��ֹPIC���������ж�
;	AT���ݻ��Ĺ淶��PIC��ʼ��
;	Ȼ��֮ǰ��CLI�����κ��¾͹���
;	PIC��ͬ����ʼ��
		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; ����ִ��OUTָ��
		OUT		0xa1,AL

		CLI						; ��һ���ж�CPU

; ��CPU֧��1M�����ڴ桢����A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout
		
[INSTRSET "i486p"]				; ˵��ʹ��486ָ��		
		LGDT	[GDTR0]			; ������ʱGDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; ʹ��bit31�����÷�ҳ��
		OR		EAX,0x00000001	; bit0��1ת��������ģʽ���ɣ�
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			;  д32bit�Ķ�
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX
		
; ����������ʼ
		MOV		ESI,0x7c00		; Դ
		MOV		EDI,DSKCAC		; Ŀ��
		MOV		ECX,512/4
		CALL	memcpy
		
		MOV		ESI,DSKCAC0+512	; Դ
		MOV		EDI,DSKCAC+512	; Ŀ��
		MOV		ECX,0
		MOV		CL, 10   ;  BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ����4�õ��ֽ���
		SUB		ECX,512/4		; IPLƫ����
		CALL	memcpy
						
		MOV		ESI, 0000C208h; �����ַ��asmhead��bootpack:�����ĵ�ַ����Ҫ�鿴asmhead.lst�� 6 0000C208   bootpack:
		MOV		EDI,BOTPAK		; Ŀ��
		MOV		ECX,512*1024/4
		CALL	memcpy
		
		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; �������
		MOV		ESI,[EBX+20]	; Դ
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; Ŀ��
		CALL	memcpy
						
		JMP		0xc200
				
skip:
		MOV		ESP,[EBX+12]	; ��ջ�ĳ�ʼ��
		JMP		DWORD 2*8:0x01b
		
memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; ��������Ϊ0��ת��memcpy
		RET

		ALIGNB	16
GDT0:
		RESB	8				; ��ʼֵ
		DW		0xffff,0x0000,0x9200,0x00cf	; д32bitλ�μĴ���
		DW		0xffff,0x0000,0x9a28,0x0047	; ��ִ�е��ļ���32bit�Ĵ�����bootpack�ã�

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; AND�����Ϊ0��ת��waitkbdout
		RET

error:
		MOV		SI,msg

putloop:
		MOV		AL,[SI]
		ADD		SI,1			; ��SI��1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ��ʾһ������
		MOV		BX,15			; ָ���ַ���ɫ
		INT		0x10			; �����Կ�BIOS
		JMP		putloop

fin:
		HLT						; ��CPUֹͣ���ȴ�ָ��
		JMP		fin				; ����ѭ��

msg:
		DB		0x0a, 0x0a		; ��������
		DB		"load error"
		DB		0x0a			; ����
		DB		0

		RESB	0x7dfe-$		; ��д0x00ֱ��0x001fe

		DB		0x55, 0xaa
