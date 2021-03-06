IDEAL
P386
MODEL USE32 SMALL
ASSUME cs:@code,ds:@data,es:@data
INCLUDE "EMUDATA.INC"

DATASEG

LABEL _DSC BYTE ;���ᠭ��
        DB "����� � ���⮩",0

;��ப� ��� ����䥩�

TxtTitle        DB "����� � ���⮩",0
TxtCfgKey       DB "Key=",0
TxtCfgF7        DB "F7",0
TxtCfgF8        DB "F8",0
TxtCfgF9        DB "F9",0
TxtCfgF10       DB "F10",0
TxtCfgF11       DB "F11",0
TxtCfgF12       DB "F12",0

;����� ���䨣��樨
TblTCKey        DD OFFSET TxtCfgF7,OFFSET TxtCfgF8,OFFSET TxtCfgF9
                DD OFFSET TxtCfgF10,OFFSET TxtCfgF11,OFFSET TxtCfgF12

CfgKey          CnTbl <OFFSET Key,OFFSET TblTCKey,6>

;������ ���䨣��樨
CfgTable        CfgS <TTbl,OFFSET TxtCfgKey,OFFSET CfgKey>

;����� � ���䨣��樨
_CFG            CfgDat <OFFSET CfgTable,1>

;��ப� ��� ����䥩�
TxtKey          DB "������",0Ah,"F7",0Ah,"F8",0Ah,"F9",0Ah
                DB "F10",0Ah,"F11",0Ah,"F12",0

TxtTimeNum      DB "�����",0
TxtOk           DB "OK",0
TxtCancel       DB "�⬥��",0
CfgTimeNum      CnNum <OFFSET TimeNum,400h,1000h>
TimeNum         DD 850h ;������⢮ ⠪⮢
UDATASEG
TblData         DD ? ;���� ⠡���� ������ ������


CODESEG
;���樠������ (��࠭���� ���� ������ ������)
PROC _INI
        mov     [TblData],eax
        ret
ENDP


;���䨣��஢����
CODESEG

PROC _INP
        cmp bx,7ffeh
        je P7FFE
        ret
P7FFE:  push ax
        mov dx,224h  ;Read LineIn
        mov al,3dh
        out dx,al
        inc dx
        mov al,10000b
        out dx,al

        mov ecx,[TimeNum] ;Freq
PauseF: loop PauseF

        mov dx,22ch  ;Read
        mov al,20h
        out dx,al
        mov dx,22ah
        in al,dx     ; to al
        test al,80h
        jz P7FFE_1
        pop ax
        and al,10111111b
        jmp P7FFE_2
P7FFE_1:pop ax
        or al,01000000b
P7FFE_2:ret
ENDP
;���䨣��஢����
UDATASEG
WinPnt          DD ? ;���� ������ ������ �������
Key             DD ? ;������ ������
CODESEG

PROC _SET
        push    ebp

;�������� ����
        mov     ebp,[TblData]
        mov     eax,016h
        mov     ebx,005h
        mov     ecx,01Fh
        mov     edx,00Dh
        mov     esi,01Fh
        call    [ebp+EmuData.WinCreate]
        mov     [WinPnt],eax ;���࠭���� ���� ������ ����

;��⠭���� ��������� ����
        mov     ebx,OFFSET TxtTitle
        mov     ecx,0F0h
        call    [ebp+EmuData.WinTitle]

;��⠭���� ��४���⥫� "������"
        mov     eax,[WinPnt]
        mov     ebx,006h
        mov     ecx,002h
        mov     edx,OFFSET TxtKey
        mov     edi,OFFSET CfgKey
        call    [ebp+EmuData.SetRadio]

;��⠭���� ������ "�⬥��"
        mov     eax,[WinPnt]
        mov     ebx,011h
        mov     ecx,00Ah
        mov     edx,OFFSET TxtCancel
        mov     esi,00Ah
        xor     edi,edi
        call    [ebp+EmuData.SetButton]

;��⠭���� ������ "OK"
        mov     eax,[WinPnt]
        mov     ebx,004h
        mov     ecx,00Ah
        mov     edx,OFFSET TxtOk
        mov     esi,00Ah
        mov     edi,001h
        call    [ebp+EmuData.SetButton]

;��ࠡ�⪠ ����
        mov     eax,[WinPnt]
        call    [ebp+EmuData.WinExe]

;�஢�ઠ १���� ����
        test    eax,eax
        jz      @@Exit

;���࠭���� १���� ����
        mov     eax,[WinPnt]
        call    [ebp+EmuData.WinResult]

;�������� ����
@@Exit: mov     eax,[WinPnt]
        call    [ebp+EmuData.WinRemove]

        pop     ebp
        ret
ENDP
;��ࠡ�⪠ ������
MACRO KeyProc KeyP,Num
PROC KeyP
        cmp     [Key],Num ;�஢�ઠ: �� �� ������ ��࠭� ?
        jz      Refresh
        ret
ENDP
ENDM

        KeyProc _F7_,000h
        KeyProc _F8_,001h
        KeyProc _F9_,002h
        KeyProc _F10,003h
        KeyProc _F11,004h
        KeyProc _F12,005h

PROC Refresh
        push    ebp


        mov     ebp,[TblData]
        call [ebp+EmuData.TextMode]

;�������� ����
        mov     eax,016h
        mov     ebx,007h
        mov     ecx,023h
        mov     edx,009h
        mov     esi,01Fh
        call    [ebp+EmuData.WinCreate]
        mov     [WinPnt],eax ;���࠭���� ���� ������ ����

;��⠭���� ��������� ����
        mov     ebx,OFFSET TxtTitle
        mov     ecx,0F0h
        call    [ebp+EmuData.WinTitle]


;��⠭���� ��ப� ����� ���� "������⢮ ���뢠���"
        mov     eax,[WinPnt]
        mov     ebx,00ch
        mov     ecx,003h
        mov     edx,OFFSET TxtTimeNum
        mov     edi,OFFSET CfgTimeNum
        call    [ebp+EmuData.SetInputNum]

;��⠭���� ������ "�⬥��"
        mov     eax,[WinPnt]
        mov     ebx,013h
        mov     ecx,006h
        mov     edx,OFFSET TxtCancel
        mov     esi,00Ch
        xor     edi,edi
        call    [ebp+EmuData.SetButton]

;��⠭���� ������ "OK"
        mov     eax,[WinPnt]
        mov     ebx,004h
        mov     ecx,006h
        mov     edx,OFFSET TxtOk
        mov     esi,00Ch
        mov     edi,001h
        call    [ebp+EmuData.SetButton]

;��ࠡ�⪠ ����
        mov     eax,[WinPnt]
        call    [ebp+EmuData.WinExe]

;�஢�ઠ १���� ����
        test    eax,eax
        jz      @@Exit

;���࠭���� १���� ����
        mov     eax,[WinPnt]
        call    [ebp+EmuData.WinResult]

;�������� ����
@@Exit: mov     eax,[WinPnt]
        call    [ebp+EmuData.WinRemove]
        mov eax,ebp
        pop     ebp
        jmp     [eax+EmuData.SpecMode]



ENDP

END
