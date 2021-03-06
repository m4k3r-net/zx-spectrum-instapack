;����� �����প� ���७��� ����� ���⠣���.

IDEAL
P386
MODEL USE32 SMALL
ASSUME cs:@code,ds:@data,es:@data
INCLUDE '..\EMUDATA.INC'

DATASEG
LABEL _DSC BYTE ;���ᠭ��
                db 'Pentagon RAM Support ['
Preview         db '512K]',0

txtHelp         db 'Pentagon RAM emulation module v1.0',10,'(c) Hexman/BYTEX, 2:469/32.7@Fidonet',0

TblData         dd ? ;���� ⠡���� ������ ������
WinPnt          dd ? ;���� ������ ������ �������
Mem             dd 2 ;���祭�� ���䨣��樨
TblMem          db 0,8,24 ;��᪨ ��� ����� ��⮢ ����

;��ப� ��� ���䨣��樨
TxtCfgMem       db 'PentagonRAM=',0
TxtCfg128       db '128K',0
TxtCfg256       db '256K',0
TxtCfg512       db '512K',0

;����� � ���䨣��樨
_CFG            CfgDat <OFFSET CfgTable,1>
CfgTable        CfgS <TTbl,OFFSET TxtCfgMem,OFFSET CfgMem>
CfgMem          CnTbl <OFFSET Mem,OFFSET TblTCMem,3>
TblTCMem        dd OFFSET TxtCfg128, OFFSET TxtCfg256, OFFSET TxtCfg512

;��ப� ��� ����䥩�
TxtTitle        db 'Pentagon RAM',0
TxtMem          db 'RAM ',1,'size:',0Ah,'128K',0Ah,'256K',0Ah,'512K',0
TxtOk           db 1,'OK',0
TxtCancel       db 1,'Cancel',0

CODESEG


;���樠������ (��࠭���� ���� ������ ������)
PROC _INI
        mov     [TblData],eax
        ret

;��⠭���� ᥣ���⮢ �����
_MEM:   mov     ebx,[TblData]
        mov     eax,[Mem]
        mov     ah,[TblMem+eax]
        mov     al,[ebx+EmuData.Port7FFD]
        shr     al,3
        and     al,ah
        mov     ah,[ebx+EmuData.Port7FFD]
        and     ah,007h
        or      al,ah
        xor     ah,ah
        shl     eax,0Eh
        add     eax,[ebx+EmuData.SpecRAM]
        mov     [(ebx+EmuData.SpecSeg)+0Ch],eax
        mov     ah,1
        ret

;���䨣��஢����
_SET:   push    ebp

        ;�������� ����
        mov ebp,[TblData]
        MWinCreate ebp,01Ah,008h,01Bh,008h,01Fh
        mov [WinPnt],eax

        ;���������
        MWinTitle ebp,eax,<OFFSET TxtTitle>,0F0h

        ;"Cancel"
        MSetButton ebp,[WinPnt],00Dh,005h,00Ah,<OFFSET TxtCancel>,0

        ;"OK"
        MSetButton ebp,[WinPnt],00Dh,003h,00Ah,<OFFSET TxtOk>,001h

        ;"RAM size"
        MSetRadio ebp,[WinPnt],3,002h,<OFFSET TxtMem>,<OFFSET CfgMem>

        ;���᪠���
        MWinHelp ebp,[WinPnt],44,6,<OFFSET txtHelp>

        ;��ࠡ�⪠ ����
        MWinExe ebp,[WinPnt]

        ;�஢�ઠ १���� ����
        test    eax,eax
        jz      @@Exit

        ;���࠭���� १����
        MWinResult ebp,[WinPnt]

        ;�������� ����
@@Exit: MWinRemove ebp,[WinPnt]
        pop ebp
        ret

;��⠭���� ���� ����� � �������� �����
_INS:   mov     eax,[Mem]
        mov     ebx,eax
        add     eax,eax
        add     eax,eax
        add     eax,ebx ;eax=[Mem]*5
        mov     ebx,eax
        mov     cx,3
        xor     eax,eax
        mov     eax,0
@@Loop: mov     dl,[(TxtCfg128+ebx)+eax]
        mov     [Preview+eax],dl
        inc     eax
        dec     cx
        jnz     @@Loop
        ret
ENDP
END
