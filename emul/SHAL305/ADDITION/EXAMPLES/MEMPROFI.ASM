;*********************************************************************
;
;�����প� ���७��� ����� Profi
;
;*********************************************************************

;����� ����� - �����প� ���७��� ����� Profi.

IDEAL
P386
MODEL USE32 SMALL
ASSUME cs:@code,ds:@data,es:@data
INCLUDE "EMUDATA.INC"

DATASEG
Mem		DD 003h

TblMem		DB 00h,01h,03h,07h

LABEL _DSC BYTE ;���ᠭ��
	DB "�����প� ���७��� ����� Profi",0

;��ப� ��� ���䨣��樨
TxtCfgMem	DB "Memory=",0
TxtCfg128	DB "128k",0
TxtCfg256	DB "256k",0
TxtCfg512	DB "512k",0
TxtCfg1024	DB "1024k",0

;����� ���䨣��樨
TblTCMem	DD OFFSET TxtCfg128,OFFSET TxtCfg256
		DD OFFSET TxtCfg512,OFFSET TxtCfg1024

CfgMem		CnTbl <OFFSET Mem,OFFSET TblTCMem,4>

;������ ���䨣��樨
CfgTable	CfgS <TTbl,OFFSET TxtCfgMem,OFFSET CfgMem>

;����� � ���䨣��樨
_CFG		CfgDat <OFFSET CfgTable,1>

;��ப� ��� ����䥩�
TxtTitle	DB 1,"������ Profi",0
TxtMem		DB "�",1,"�ꥬ",0Ah,"128k",0Ah,"256k",0Ah,"512k",0Ah,"1024k",0
TxtOk		DB 1,"OK",0
TxtCancel	DB "�",1,"⬥��",0

UDATASEG
TblData		DD ? ;���� ⠡���� ������ ������
PortDFFD	DB ? ;���祭�� ���� DFFDh

CODESEG

;���樠������ (��࠭���� ���� ������ ������)
PROC _INI
	mov	[TblData],eax
	ret
ENDP

;Reset (��⠭���� �㫥���� ���祭�� ����)
PROC _RES
	mov	[PortDFFD],000h
	ret
ENDP

;������ � ����
PROC _OUT
	cmp	bx,0DFFDh
	jnz	@@Ret
	mov	[PortDFFD],al

;��⠭���� ᥣ���⮢ �����
_MEM:	mov	eax,[Mem]
	mov	ah,[TblMem+eax]
	mov	ebx,[TblData]
	mov	al,[PortDFFD]
	and	al,ah
	mov	ah,[ebx+EmuData.Port7FFD]
	and	ah,007h
	shl	al,03h
	or	al,ah
	xor	ah,ah
	shl	eax,0Eh
	add	eax,[ebx+EmuData.SpecRAM]
	mov	[(ebx+EmuData.SpecSeg)+0Ch],eax
	mov	ah,001h
@@Ret:	ret
ENDP

;���䨣��஢����
UDATASEG
WinPnt		DD ? ;���� ������ ������ �������
CODESEG

PROC _SET
	push	ebp

;�������� ����
	mov	ebp,[TblData]
	MWinCreate ebp,016h,005h,01Fh,00Bh,01Fh
	mov	[WinPnt],eax

;��⠭���� ��������� ����
	MWinTitle ebp,eax,<OFFSET TxtTitle>,0F0h

;��⠭���� ��४���⥫� "��ꥬ"
	MSetRadio ebp,[WinPnt],006h,002h,<OFFSET TxtMem>,<OFFSET CfgMem>

;��⠭���� ������ "�⬥��"
	MSetButton ebp,[WinPnt],011h,008h,00Ah,<OFFSET TxtCancel>,0

;��⠭���� ������ "OK"
	MSetButton ebp,[WinPnt],004h,008h,00Ah,<OFFSET TxtOk>,1

;��ࠡ�⪠ ����
	MWinExe ebp,[WinPnt]

;�஢�ઠ १���� ����
	test	eax,eax
	jz	@@Exit

;���࠭���� ��⠭���� ����
	MWinResult ebp,[WinPnt]

;�������� ����
@@Exit:	MWinRemove ebp,[WinPnt]

	pop	ebp
	ret

ENDP

END
