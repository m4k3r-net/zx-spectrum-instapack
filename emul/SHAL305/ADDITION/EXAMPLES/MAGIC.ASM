;*********************************************************************
;
;������ Magic (NMI TR-DOS)
;
;*********************************************************************

;�����প� ������ Magic.

IDEAL
P386
MODEL USE32 SMALL
ASSUME cs:@code,ds:@data,es:@data
INCLUDE "EMUDATA.INC"

DATASEG

LABEL _DSC BYTE ;���ᠭ��
	DB "������ Magic (NMI TR-DOS)",0

;��ப� ��� ���䨣��樨
TxtCfgKey	DB "Key=",0
TxtCfgF7	DB "F7",0
TxtCfgF8	DB "F8",0
TxtCfgF9	DB "F9",0
TxtCfgF10	DB "F10",0
TxtCfgF11	DB "F11",0
TxtCfgF12	DB "F12",0

;����� ���䨣��樨
TblTCKey	DD OFFSET TxtCfgF7,OFFSET TxtCfgF8,OFFSET TxtCfgF9
		DD OFFSET TxtCfgF10,OFFSET TxtCfgF11,OFFSET TxtCfgF12

CfgKey		CnTbl <OFFSET Key,OFFSET TblTCKey,6>

CfgTable	CfgS <TTbl,OFFSET TxtCfgKey,OFFSET CfgKey>

_CFG		CfgDat <OFFSET CfgTable,1>

;��ப� ��� ����䥩�
TxtTitle	DB "Magic",0
TxtKey		DB 1,"������",0Ah,"F7",0Ah,"F8",0Ah,"F9",0Ah
		DB "F10",0Ah,"F11",0Ah,"F12",0
TxtOk		DB 1,"OK",0
TxtCancel	DB "�",1,"⬥��",0

UDATASEG
TblData		DD ? ;���� ⠡���� ������ ������
Key		DD ? ;������ ������

CODESEG

;���樠������ (��࠭���� ���� ������ ������)
PROC _INI
	mov	[TblData],eax
	ret
ENDP

;��⠭���� ���䨣��樨
UDATASEG
WinPnt		DD ? ;���� ������ ������ �������
CODESEG

PROC _SET
	push	ebp

;�������� ����
	mov	ebp,[TblData]
	MWinCreate ebp,016h,005h,01Fh,00Dh,01Fh
	mov	[WinPnt],eax ;���࠭���� ���� ������ ����

;��⠭���� ��������� ����
	MWinTitle ebp,eax,<OFFSET TxtTitle>,0F0h

;��⠭���� ��४���⥫� "������"
	MSetRadio ebp,[WinPnt],006h,002h,<OFFSET TxtKey>,<OFFSET CfgKey>

;��⠭���� ������ "�⬥��"
	MSetButton ebp,[WinPnt],011h,00Ah,00Ah,<OFFSET TxtCancel>,0

;��⠭���� ������ "OK"
	MSetButton ebp,[WinPnt],004h,00Ah,00Ah,<OFFSET TxtOk>,1

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

;��ࠡ�⪠ ������
MACRO KeyProc KeyP,Num
PROC KeyP
	cmp	[Key],Num ;�஢�ઠ: �� �� ������ ��࠭� ?
	jz	Magic
	ret
ENDP
ENDM

	KeyProc _F7_,000h
	KeyProc _F8_,001h
	KeyProc _F9_,002h
	KeyProc _F10,003h
	KeyProc _F11,004h
	KeyProc _F12,005h

;������ ���� � ������
MACRO PushBytePC Byt
LOCAL @@Cont

;�����襭�� ॣ���� SP
	dec	[WORD ebp+EmuData.DataCPU.RegSP]

;���᫥��� ���� SP
	mov	ebx,[ebp+EmuData.DataCPU.RegSP]
	mov	eax,ebx
	shr	eax,0Eh
	and	bh,03Fh
	add	ebx,[ebp+eax*4+EmuData.SpecSeg]

;�஢�ઠ ��������� � ROM
	cmp	ebx,[ebp+EmuData.SpecROM]
	jnc	@@Cont

;������ ����
	mov	al,[BYTE Byt WORD LOW ebp+EmuData.DataCPU.RegPC]
	mov	[ebx],al

;�⮡ࠦ���� ��������� � ����������
	push	ebp
	call	[ebp+EmuData.VidByteAdv]
	pop	ebp
@@Cont:
ENDM

PROC Magic
	push	ebp

;�⥭�� ���� ������ ������
	mov	ebp,[TblData]

;�஢�ઠ ��⨢���� TR-DOS
	mov	eax,[ebp+EmuData.SpecROM]
	add	eax,08000h
	cmp	eax,[ebp+EmuData.SpecSeg]
	jz	@@Exit

;���࠭���� � �⥪� ॣ���� PC
	PushBytePC HIGH
	PushBytePC LOW

;����祭�� TR-DOS
	mov	eax,[ebp+EmuData.SpecROM]
	add	eax,08000h
	mov	[ebp+EmuData.SpecSeg],eax

;��⠭���� PC � 0066h
	mov	[ebp+EmuData.DataCPU.RegPC],00066h

;����饭�� ���뢠��� (NMI - ��� ⮫쪮 IFF1)
	mov	[ebp+EmuData.DataCPU.IFF1],000h
@@Exit:	pop	ebp
	ret
ENDP

END
