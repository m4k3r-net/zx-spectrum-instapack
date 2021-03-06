;**************************************************************************
;
;������� ��� ���㫥� ������ ZX-Spectrum
;
;**************************************************************************

;��।������ ����⠭�
AY_REG0=00h
AY_REG1=01h
AY_REG2=02h
AY_REG3=03h
AY_REG4=04h
AY_REG5=05h
AY_REG6=06h
AY_REG7=07h
AY_REG8=08h
AY_REG9=09h
AY_REGA=0Ah
AY_REGB=0Bh
AY_REGC=0Ch
AY_REGD=0Dh
AY_ON=0Eh
AY_OFF=0Fh
AY_RESET=10h
AY_INIT=11h
AY_ENVELOPE=12h

DC_READSTATUS=00h
DC_WRITECOMMAND=01h
DC_READTRACK=02h
DC_WRITETRACK=03h
DC_READSECTOR=04h
DC_WRITESECTOR=05h
DC_READDATA=06h
DC_WRITEDATA=07h
DC_READDRQINTRQ=08h
DC_WRITESYSTEM=09h
DC_INIT=0Ah
DC_UNINIT=0Bh
DC_RESET=0Ch

TTxt=0
TTbl=1
TNum=2

;����� ���䨣��樨
STRUC CnTxt
Dst		DD ? ;���� ��ப�
Siz		DD ? ;���ᨬ��쭠� ����� ��ப�
ENDS

STRUC CnTbl
Dst		DD ? ;���� ���祭��
Val		DD ? ;���� ⠡����, ᮤ�ঠ騩 ���� ⥪�⮢�� ���祭��
ValN		DD ? ;������⢮ ���祭��
ENDS

STRUC CnNum
Dst		DD ? ;���� ���祭��
Min		DD ? ;�������쭮� ���祭��
Max		DD ? ;���ᨬ��쭮� ���祭��
ENDS

STRUC CfgS
Type		DB ? ;��� ������� ���䨣��樨
Txt		DD ? ;���� ��ப� ��� ��樨
C		DD ? ;���� ⠡���� ������
ENDS

STRUC CfgDat
Cfg		DD ? ;���� ⠡���� ������ ���䨣��樨
Num		DD ? ;������⢮ ������⮢
ENDS

;����� ������
STRUC DatCPU
RegPC		DD ? ;������� PC
RegSP		DD ? ;������� SP
RegIX		DD ? ;������� IX
RegIY		DD ? ;������� IY
UNION
 RegAF		DD ? ;�������� AF
 STRUC
  RegF		DB ? ;������� F
  RegA		DB ? ;������� A
 ENDS
ENDS
UNION
 RegBC		DD ? ;�������� BC
 STRUC
  RegC		DB ? ;������� C
  RegB		DB ? ;������� B
 ENDS
ENDS
UNION
 RegDE		DD ? ;�������� DE
 STRUC
  RegE		DB ? ;������� E
  RegD		DB ? ;������� D
 ENDS
ENDS
UNION
 RegHL		DD ? ;�������� HL
 STRUC
  RegL		DB ? ;������� L
  RegH		DB ? ;������� H
 ENDS
ENDS
UNION
 RegAFa		DD ? ;�������� AF'
 RegAFAlt	DD ? ;�������� AF' (��⠢���� ��� ᮢ���⨬���)
 STRUC
  RegFa		DB ? ;������� F'
  RegAa		DB ? ;������� A'
 ENDS
ENDS
UNION
 RegBCa		DD ? ;�������� BC'
 RegBCAlt	DD ? ;�������� BC' (��⠢���� ��� ᮢ���⨬���)
 STRUC
  RegCa		DB ? ;������� C'
  RegBa		DB ? ;������� B'
 ENDS
ENDS
UNION
 RegDEa		DD ? ;�������� DE'
 RegDEAlt	DD ? ;�������� DE' (��⠢���� ��� ᮢ���⨬���)
 STRUC
  RegEa		DB ? ;������� E'
  RegDa		DB ? ;������� D'
 ENDS
ENDS
UNION
 RegHLa		DD ? ;�������� HL'
 RegHLAlt	DD ? ;�������� HL' (��⠢���� ��� ᮢ���⨬���)
 STRUC
  RegLa		DB ? ;������� L'
  RegHa		DB ? ;������� H'
 ENDS
ENDS
RegR		DB ? ;������� R
RegI		DB ? ;������� I
Halt		DW ? ;���� ������� HALT: 000h - ���; 001h - ����
UNION
 IFF		DD ? ;�ਣ���� ���뢠���: 00h - ����饭�; 04h - ࠧ�襭�
 STRUC
  IFF2		DB ? ;�ਣ��� ���뢠��� IFF2
  IFF1		DB ? ;�ਣ��� ���뢠��� IFF1
 ENDS
ENDS
IM		DB ? ;����� ��ࠡ�⪨ ���뢠���
		DB ?,?,?
ENDS

;����� AY
STRUC DatAY
RegData		DB 010h DUP (?) ;���祭�� ॣ���஢ AY
RegIndex	DD ? ;��࠭�� ॣ���� AY
EnvCurrent	DD ? ;����饥 ���祭�� ������饩
EnvDelta	DD ? ;��������� ���祭�� ������饩 ����� ���뢠��ﬨ
EnvStatus	DB ? ;0-���������, 1-�����⠭��, 2-�뢠���
		DB ?,?,?
ENDS

;����� ����஫��� ��᪮����
STRUC DatVG
DataIO		DB ? ;���祭��, ���஥ ��।����� �१ ����
OperIO		DB ? ;������ ��
RegStatus	DB ? ;������� ���ﭨ� ��
RegCom		DB ? ;������� ������� ��
RegTrack	DB ? ;������� ��஦�� ��
RegSect		DB ? ;������� ᥪ�� ��
RegData		DB ? ;������� ������ ��
System		DB ? ;���⥬�� ॣ���� ����஫��� ��᪮����
StepDirect	DB ? ;���ࠢ����� 蠣�: -01 - �����; 01 - ���।
TrackReal	DB 4 DUP (?) ;��������� ������� ��᪮�����
		DB ?,?,?
ENDS

;����� ������
RECORD EMUFLAGS Lang:1,IntLast:1,Trace:1,IntWait:1

STRUC EmuData
DataCPU		DatCPU <> ;������ ������ CPU
AY		DatAY <> ;������ ������ AY
VG		DatVG <> ;������ ������ ����஫��� ��᪮����
SpecRAM		DD ? ;RAM Spectrum
SpecROM		DD ? ;ROM Spectrum
SpecSeg		DD ?,?,?,? ;������ ᥣ���⮢ Spectrum
TimerRate	DD ? ;���祭�� ���稪� ⠩���
OpCPU		DD ? ;���� ����ணࠬ� ��ࠡ�⪨ ������ ������
MemAlloc	DD ? ;�뤥����� �����
MemFree		DD ? ;�᢮�������� �����
TextMode	DD ? ;����祭�� ⥪�⮢��� �����०���
SpecMode	DD ? ;����祭�� �����०��� Spectrum
SetSpec		DD ? ;����祭�� ����樨 Spectrum
CPUTraceOn	DD ? ;����祭�� ����஢�� ������
CPUTraceOff	DD ? ;�몫�祭�� ����஢�� ������
WinCreate	DD ? ;�������� ����
WinRemove	DD ? ;�������� ����
WinTitle	DD ? ;�������� ��������� ����
WinHelp		DD ? ;��⠭���� ����� ��� ����
WinText		DD ? ;����� ⥪�� � ����
WinExe		DD ? ;����� ����䥩�
WinResult	DD ? ;��⠭���� १���⮢
SetButton	DD ? ;������
SetCheckBox	DD ? ;������
SetRadio	DD ? ;��४���⥫�
SetInputTxt	DD ? ;��ப� �����
SetInputNum	DD ? ;��ப� ��� �᫠
FileBox		DD ? ;�롮� 䠩�� � ��ப� �����
MessageBox	DD ? ;����饭��
VidByte		DD ? ;������ � ����������� ZX-Spectrum
Keys		DD ? ;���� ⠡���� ��������� ������
Port7FFD	DB ? ;���祭�� ���� 7FFD
Flags		EMUFLAGS <> ;����� ������
		DB 3 DUP (?)
PortFE		DB ? ;���祭�� ���� FE (������)
VerMinor	DB ? ;�������� ������
VerMajor	DB ? ;����� ������
ProcVG		DD ? ;�맮� ����樨 ����஫��� ��᪮����
Disks		DD 4 DUP (?) ;�����⥫� �� ����� 䠩��� ��ࠧ� ��᪠
ArgC		DD ? ;������⢮ ��ࠬ��஢ ��������� ��ப�
ArgV		DD ? ;���� ���ᨢ� 㪠��⥫�� �� ��ࠬ���� ��������� ��ப�
PortIn		DD ? ;�⥭�� �� ����
PortOut		DD ? ;������ � ����
VidByteAdv	DD ? ;������ � ����������� ZX-Spectrum � �஢�મ� ���������
ENDS

;������ ��� �ᯮ�짮����� ����䥩�

MACRO MWinCreate Reg,X,Y,dX,dY,C
	mov	eax,X
	mov	ebx,Y
	mov	ecx,dX
	mov	edx,dY
	mov	esi,C
	call	[Reg+EmuData.WinCreate]
ENDM

MACRO MWinRemove Reg,Pnt
	mov	eax,Pnt
	call	[Reg+EmuData.WinRemove]
ENDM

MACRO MWinTitle Reg,Pnt,Txt,C
IFDIF <Pnt>,<eax>
	mov	eax,Pnt
ENDIF
	mov	ebx,Txt
	mov	ecx,C
	call	[Reg+EmuData.WinTitle]
ENDM

MACRO MWinHelp Reg,Pnt,dX,dY,Txt
	mov	eax,Pnt
	mov	ebx,dX
	mov	ecx,dY
	mov	edx,Txt
	call	[Reg+EmuData.WinHelp]
ENDM

MACRO MWinText Reg,Pnt,X,Y,Txt
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	call	[Reg+EmuData.WinText]
ENDM

MACRO MWinExe Reg,Pnt
	mov	eax,Pnt
	call	[Reg+EmuData.WinExe]
ENDM

MACRO MWinResult Reg,Pnt
	mov	eax,Pnt
	call	[Reg+EmuData.WinResult]
ENDM

MACRO MSetButton Reg,Pnt,X,Y,dX,Txt,Id
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	mov	esi,dX
IFIDN <Id>,<0>
	xor	edi,edi
ELSE
	mov	edi,Id
ENDIF
	call	[Reg+EmuData.SetButton]
ENDM

MACRO MSetCheckBox Reg,Pnt,X,Y,Txt,Dst
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	mov	edi,Dst
	call	[Reg+EmuData.SetCheckBox]
ENDM

MACRO MSetRadio Reg,Pnt,X,Y,Txt,Dst
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	mov	edi,Dst
	call	[Reg+EmuData.SetRadio]
ENDM

MACRO MSetInputTxt Reg,Pnt,X,Y,dX,Txt,Dst
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	mov	esi,dX
	mov	edi,Dst
	call	[Reg+EmuData.SetInputTxt]
ENDM

MACRO MSetInputNum Reg,Pnt,X,Y,Txt,Dst
	mov	eax,Pnt
	mov	ebx,X
	mov	ecx,Y
	mov	edx,Txt
	mov	edi,Dst
	call	[Reg+EmuData.SetInputNum]
ENDM

MACRO MFileBox Reg,Pnt,Mask,Path
	mov	eax,Pnt
	mov	ebx,Mask
	mov	ecx,Path
	call	[Reg+EmuData.FileBox]
ENDM

MACRO MMessageBox Reg,C,Txt0,Txt1
	mov	eax,C
	mov	ebx,Txt0
	mov	edx,Txt1
	call	[Reg+EmuData.MessageBox]
ENDM

;��।������ ����ணࠬ�, ��뢠���� �����஬
GLOBAL _DSC:BYTE,_CFG:CfgDat,_SET:NEAR,_INI:NEAR,_UNI:NEAR
GLOBAL _ON_:NEAR,_OFF:NEAR,_RES:NEAR,_CPU:NEAR,_INT:NEAR,_ITP:NEAR
GLOBAL _IN_:NEAR,_INP:NEAR,_OUT:NEAR,_OUP:NEAR,_MEM:NEAR
GLOBAL _AY_:NEAR,_VG_:NEAR,_VGP:NEAR,_INS:NEAR
GLOBAL _F7_:NEAR,_F8_:NEAR,_F9_:NEAR,_F10:NEAR,_F11:NEAR,_F12:NEAR
