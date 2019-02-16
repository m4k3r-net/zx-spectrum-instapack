; Loader ��� ZX Spectrum Navigator [SN.PRG]   BETA-�����  ! ������� 2 !
;                                             v0.12.2 (16-12-98 17:00)

; Loader (f)98 Mihal Soft�  ��客 ��堨�  (2:5093/6.1 aka /9.1)
; ZX Spectrum Navigator v1.10 Copyright (c) 1997-98 RomanRoms Software Co.

;� �஬� ��ࢮ�� "�㦥�����" ��ࠬ��� SN.COM ������ � SN.PRG
;� ᢮� ��������� ��ப�. �� ��ࢮ� ����᪥ SN.PRG �㦥��� ��ࠬ���
;� �� 6 ᨬ����� "������" (��� ࠭��), �� ��஬ � ����� ����᪠�
;� ���� ��ࠬ��� � ��������� ��ப� ���������� � SN.PRG �� ����
;� ᨬ����� "������E" ��� "E" - ������ ��⨭᪠� �㪢� "E"
;� (�ਧ��� 㦥 �� ��ࢮ�� ����᪠ SN.PRG �����稪��)
;� ���� � ����� ��ࠬ��ࠬ� ��������� ��ப� � SN.PRG ��������
;� ��ࠬ����, ����� �뫨 ���࠭� � ��������� ��ப� �����稪� SN.COM

; �� ���祭�� ���⠢����� ������ !!!  �� �⮬ ���� �㬠�� ������� !!!
; �� ࠧ��� "१����⭮�" ��� LOADER'� � �������� �� �� ᬥ饭��
; End_Of_Resident_Part ���� �⥪ � ���㣫��� �� 10h � ������� ��஭� !!!

End_Of_Memory_Block EQU 310h

.8086  ;�� ��⨪��ਠ�
;=========================================================
SN_Run segment byte public 'CODE'
       assume cs:SN_Run, es:SN_Run, ds:SN_Run

        ORG    2Ch
EnvSeg  DW     ?

        ORG    100h

Start:  JMP Short Init
        DB '(f)Mihal Soft�' ;�� ����� �� �뤠����, �� � ⥫� SN.COM ����
COMMAND_ComStr  DB 0        ;����� ��������� ��ப� ��� COMMAND.COM
                DB ' /c'

StrLen  LABEL BYTE
SWPFile LABEL WORD

;����� ���樠����樮��� ��� (��� �� ��⪨ NextRun) ��ࠡ�⠥�,
;�� �㤥� 㦥 �� �㦥� � �㤥� �ᯮ�짮������ ��� ���� �⥭�� ��
;SWP-䠩�� (128 ����) ���⮬� ����⭥�, �� ��⪨ NextRun
;������ ���� �� ����� 128 ���� !

Init:
        mov     ah, 9
        mov     dx, offset Copyrt_Roman
        int     21h            ;�뤠�� ����ࠩ⭮� ᮮ�饭��

        std                    ;����/��७�� �����
        mov     si, 255-8      ;�������� ��������� ��ப� ������� � SN.COM
        mov     di, 255        ;�� 8 ᨬ�����, �⮡ ������ � ��砫�
        mov     cx, 128-8      ;��ࠬ��� '������x ' ��� SN.PRG
        REP movsb              ;�ᯮ��㥬� ��� ᮧ����� ���� �६.䠩���
        mov     ax, '  '       ;����ᨬ ��� �஡��� ����� ��ன ��� ��ப��
        stosw                  ;� �㦥��� ��ࠬ��஬ ��� SN.PRG
        mov     ax, '00'       ;����ᨬ �㦥��� ��ࠬ���, ���� = '000000'
        stosw
        stosw
        stosw
        add BYTE PTR DS:[80h], 8  ;����� ��������� ��ப� 㢥������ �� 8
        cmp BYTE PTR DS:[80h], 128;�� ��ॢ����� �� ����� ࠧ㬭� �।���?
        jl  Len_OK
        mov BYTE PTR DS:[80h], 127;"�ᥪ���" ��������� ��ப�
Len_OK:
        cld                    ;� ⥯��� ���� ���।

        mov     ax, CS         ;����塞 ࠧ��� ���㦥��� DOS
        sub     ax, EnvSeg     ;�⮡� �� ���᪥ ��ப � Environment
        mov     cl, 4          ;�� ��ॢ������� �� �।��� Environment'�
        shl     ax, cl
        mov     ENV_Size, ax   ;������ = (��葥�����-������⎪�㦥���)*16

        mov     ah, 2ch         ;��稭��� ������� ��� SWP-䠩��...
        int     21h             ;������ ⥪�饥 �६� (CH:CL:DH = ��:��:��)
        mov     dl, 10          ;�� �ਢ몫� � �����筮� ��⥬�
        xor     ax, ax          ;�⮡ ��������
        mov     al, CH          ;����
        div     dl              ;al := ��� DIV 10 ;   ah := ��� MOD 10
        add WORD PTR DS:[81h], ax  ;�ॢ�頥� � 2 ᨬ����
        xor     ax, ax
        mov     al, CL          ;������ �������筮
        div     dl
        add WORD PTR DS:[81h+2], ax
        xor     ax, ax
        mov     al, DH          ;���㭤� �������筮
        div     dl
        add WORD PTR DS:[81h+4], ax

        mov     ComStr_Seg, cs ; ������� ���� ��ࠬ��஢ EXEC
        mov     FCB1_Seg, cs   ; (EPB - EXEC Parameter Block)
        mov     FCB2_Seg, cs   ; ��� �㭪樨 DOS 4Bh - ����� �ணࠬ�

        mov     ah, 4Ah     ; �����蠥� ࠧ��� �뤥������ �ணࠬ�� �����
        mov     bx, End_Of_Memory_Block / 10h   ;���-�� ��ࠣ�䮢
        mov     sp, End_Of_Memory_Block - 2     ;��� ���� �⥪
        int     21h

        mov     cx, ENV_Size   ;CX := ������ ��থ��� DOS
        mov     ds, EnvSeg     ;DS := ������� ���㦥��� DOS
        xor     ax, ax         ;�饬 0
        mov     si, ax         ;��稭�� � DS:0

Find_EXEC:                     ;�饬 � ���㦥��� ���� ����᪠ Loader'�
        lodsb
        or      al, [si]       ;�������� ��� �㫥��� ���� �����?
        loopne  Find_EXEC

        add     si, 3           ;�ய�᪠�� DW 1 ��। ��⥬ ����᪠
                                ;�⠪ ���� ����᪠  Loader'� ������.
        mov     CS:ExPathDX, si ;���祬 ᬥ饭�� ��� ����᪠  Loader'�

Find_EXEC_end:
        lodsb
        or      al, al
        loopne  Find_EXEC_end   ;�饬 ����� ��� ����᪠

        mov WORD PTR [si-4], 'RP'   ;� �����塞 � ���
        mov BYTE PTR [si-2], 'G'    ;���७�� '.COM' �� '.PRG'

        mov     di, OFFSET ENV_COMSPEC
        mov     dx, 8+1         ;����� ��ப� 'COMSPEC=' ���� ������
        call    Get_ENV_Str     ;��室�� ��६����� ���㦥��� COMSPEC

        push    CS
        pop     DS

        mov     COMSPEC_Adr, si ;� ���������� �� ���� � ���㦥���

NextRun:
        mov     ComStr_Ofs, 80h ;���� ��������� ��ப�
        mov     dx, ExPathDX    ;DS:DX 㪠�뢠�� �� ��ப� � ������ �ணࠬ��
        CALL    RunProgram      ;����᪠�� SN.PRG
        jc      WasErr          ;�뫠 �訡�� �� ����᪥ ?

        mov BYTE PTR DS:[87h], 'E' ;"������塞" � ��������� ��ப� 'E'
                                ;�.�. �ॢ�蠥� "�第��" � "�第��E"

        mov     ah, 4Dh         ;������ ERRORLEVEL
        int     21h             ;��᫥���� �����訢襩�� �ணࠬ�� (SN.PRG)
        or      al, al
        jz      Quit            ;�᫨ ERRORLEVEL=0 ����� ᮢ� ��室�� �� SN

        CLD                     ;���� ���।
        CALL    Get_SWP_Name    ;��室�� ���� � ����� SWP-䠩��, �����⥭��㥬
                                ;��� � ������ SWP-䠩�� � ��ப� SWPFile
        mov     ax, 3D00H       ;������ 䠩� �� �⥭��
        mov     dx, OFFSET SWPFile ;���� ��ப� � ��⥬/������ SWP-䠩��
        int     21H
        jc      NextRun         ;�᫨ �訡�� ������ SWP - ������ � SN
        mov     bx,ax           ;��࠭塞 handle ����⮣� 䠩��

        mov     ax, 4200h       ;��⠭����� 㪠��⥫� � 䠩�� (SEEK)
        xor     cx, cx          ;㪠��⥫� � CX:DX (� ��襬 ��砥 CX=0
        mov     dx, 766         ;� DX ᬥ饭�� � SWP-䠩�� ��ப�
        int     21H             ;� ������ ����᪠���� �ணࠬ��
                                ;(��� ���ᨩ �� SN1.022 �����⥫쭮 = 0)
                                ;(��� SN1.10 = 766)

        mov     ah, 3Fh         ;����� 䠩�
        mov     dx, OFFSET StrLen ;� ����, ����� �.���
        mov     cx, 128         ;�ࠧ� �� ���ᨬ�� �⠥� - 128 ����
        int     21H

        mov     ah, 3Eh         ;������� 䠩�
        int     21H

        mov     bl, StrLen      ;��� ���� ��⠭�� ��᪠���᪮� ��ப�
        add     bl, 4           ;㢥��稢��� �� 4 (' /c ' + ...)
        mov     COMMAND_ComStr, bl ;� ����ᨬ �㬬���� ���� �㤠 ᫥���

;����᪠�� �ணࠬ��...

        mov     ComStr_Ofs, OFFSET COMMAND_ComStr ;���.��ப� ��� COMMAND.COM
        mov     StrLen, ' '                       ;᪫������ ' /c' � ��ப�
        mov     dx, COMSPEC_Adr                   ;����/��� COMMAND.COM
        CALL    RunProgram      ;����᪠�� COMMAND.COM /c <��_�ਪ�����>

        jmp     NextRun         ;���� ᭮�� ����᪠�� SN.PRG

WasErr:
        mov     ah, 9           ;�᫨ �뫠, �訡�� (SN.PRG �� �����⨫��)...
        mov     dx, OFFSET ErrMess
        int     21h             ;�뤠�� ᮮ�饭��
Quit:
        int     20h             ;�����襭�� �ணࠬ�� SN.COM

;---------------------------------------------------------
; ��楤�� ����᪠ ���譥� �ணࠬ�
; DS:DX - 㪠�뢠�� �� ��ப� '����/���' ����᪠���� �ண�
; ES:BX - 㪠�뢠�� �� EPB (�. ���ਬ�� TechHelp)

RunProgram PROC NEAR
        mov     ds, CS:EnvSeg   ;DS := ᥣ���� ���㦥��� DOS
        mov     bx, offset EPB  ;ES:BX - 㪠��⥫� �� EPB
        mov     CS:Old_SP, sp   ;���࠭塞 㪠��⥫� �� �⥪
        mov     ax, 4B00h       ;�������� �ணࠬ�� (EXEC)
        int     21h             ;DS:DX -> ASCIZ ��� ����᪠����� 䠩��
                                ;ES:BX -> EPB
        mov     ax, CS          ;����⠭�������� �⥪
        push    cs
        mov     DS, ax          ;����⠭���� �ᯮ�祭�� DS
        mov     ES, ax          ;����⠭���� �ᯮ�祭�� ES
        cli
        mov     SS, ax          ;����⠭���� �ᯮ�祭�� SS
        mov     sp, Old_SP      ;� ������ � SP
        sti
        retn                    ;��室��
RunProgram endp

;---------------------------------------------------------
; ��楤�� ���᪠ ��ப� � ���㦥��� DOS
; �� �室� : ES:DI - 㪠�뢠�� �� ��ப� � ������ ��६����� ���㦥���
;                    ������ �� �⮫� ���⮩稢� �饬
;              DX  - ����� ����� ��६����� (���� � ���� "=")
; �� ��室�: ���� CF=1 - ��६����� �� �������
;            ���� CF=0 - ��६����� ������� � ⮣��:
;            DS:SI - 㪠�뢠�� �� ��砫� ��ப� � ���祭���
;                    �᪮��� ��६���� � ���㦥��� DOS

Get_ENV_Str PROC NEAR

        mov     ds, CS:EnvSeg   ;DS := ������� ���㦥��� DOS
        xor     si, si          ;DS:SI -> ��砫� ���㦥��� DOS

FindVAR_Loop:
        mov     cx, dx          ;����ᨬ ����� ����� �᪮��� ��६����� � CX
        push    si
        push    di
        REPE cmpsb              ;�ࠢ���� ��ப� ��稭��騥�� � DS:DI � ES:DI
        pop     di
        jcxz    Found_VAR       ;�᫨ CX=0 (��ப� ᮢ���� �� �ᥩ �����)
        pop     si              ;�᫨ �� ��諨...
        inc     si              ;��室�� � ᫥���饬� ����� ���㦥���
        cmp     si, CS:ENV_Size ;����� �� ���� ���㦥���?
        jne     FindVAR_Loop    ;�᫨ �� ��諨 - �த����� ���᪨
        stc                     ;�� ��諨 ��६���� ���㦥���, ��⠭���� 䫠�
        retn                    ;��室

Found_VAR:                      ;��६����� �������!
        pop     ax              ;���⨬ �⥪ (⠬ �뫮 SI)
        dec     si              ;DS:SI ᥩ�� 㪠�뢠�� �� ��砫� ��ப�
                                ;� ���祭��� �᪮��� ��६�����
        clc                     ;���� "��६����� �������"
        retn                    ;��室��

Get_ENV_Str endp

;---------------------------------------------------------
; ��楤�� ��宦����� ����� �६������ 䠩��
; ��室�� ���� � �६������ ��⠫���, �����뢠�� � ���� ��� SWP-䠩��
; � ����頥� ��ப�-१���� � SWPFile

Get_SWP_Name PROC NEAR

        mov     di, OFFSET ENV_TEMP
        mov     dx, 5+1         ;����� �ப� 'TEMP=' ���� ������
        call    Get_ENV_Str     ;�饬 ��६����� ���㦥��� 'TEMP'
        jnc     TMP_OK          ;�᫨ ��諨

        mov     di, OFFSET ENV_TMP
        mov     dx, 4+1         ;����� �ப� 'TMP=' ���� ������
        call    Get_ENV_Str     ;� �饬 ��६����� ���㦥��� 'TMP'
        jnc     TMP_OK

        mov     SWPFile, ':C'   ;�᫨ ��६���� ���㦥��� TEMP � TMP
                                ;�� �������, � �६��� ��⠫�� = C:\
        mov     di, (OFFSET SWPFile) + 3
        jmp short IS_Slash

TMP_OK:                         ;DS:SI 㪠�뢠�� �� ��६����� ���㦥���
        mov     di, OFFSET SWPFile   ;ES:DI - �㤠 ����஢���
CopyVAR:                        ;�����㥬 ��६����� ���㦥���
        lodsb                   ;(TEMP ��� TMP) � ���� ����� SWP-䠩��
        stosb
        or      al, al          ;����� ��ப�?   (ASCIIZ)
        jnz     CopyVAR

IS_Slash:
        push    CS
        pop     DS
        cmp byte PTR [di-2], '\';���� �� � ���� ��ப� � ��⥬ ���?
        je      NoSlash         ;�᫨ ���� - �⫨筮
        mov byte PTR [di-1], '\';�᫨ ��� - �������
        inc     di
NoSlash:
        dec     di
        mov     ax, 'NS'        ;������塞 ��� SWP-䠩�� (SN�第��.SWP)
        stosw
        mov     si, 81h         ;���� 6-ᨬ���쭮� ��ப� � �६����
        movsw                   ;����᪠ Loader'� (��� �����䨪���)
        movsw
        movsw
        mov     ax, 'S.'        ;�� � ����᫥��� - ���७��
        stosw
        mov     ax, 'PW'
        stosw
        xor     ax, ax          ;ASCIIZ, � ��� �� ����
        stosb

        retn

Get_SWP_Name endp
;---------------------------------------------------------
ErrMess         DB 0Ah,0Dh,'Can`t run SN.PRG$'
ENV_TEMP        DB 'TEMP='     ;����� ��६����� ���㦥��� ��� ���᪠
ENV_TMP         DB 'TMP='      ;��� � �६������ 䠩��
ENV_Size        DW ?           ;������ ���㦥��� DOS
COMSPEC_Adr     DW ?           ;���� ��ப� COMSPEC � ���㦥��� DOS
ExPathDX        DW ?           ;���� ��� ����㧪� SN.COM � ���㦥��� DOS
Old_SP          DW ?           ;��� �६������ �࠭���� SP �� �맮�� 4B00
;---------------------------------------------------------

EPB:            ; ���� ��ࠬ��஢ EXEC
DescEnvSeg      DW 0     ;0 - �ᯮ�짮���� ����� � ⥪�饣� ���������
ComStr_Ofs      DW 0     ;���� ��������� ��ப� (ᬥ饭��)
ComStr_Seg      DW 0     ;���� ��������� ��ப� (ᥣ����)
FCB1_Ofs        DW 5Ch   ;���� ��ࢮ�� FCB (ᬥ饭��)  !�ᯮ��㥬 ���!
FCB1_Seg        DW 0     ;���� ��ࢮ�� FCB (ᥣ����)
FCB2_Ofs        DW 6Ch   ;���� ��ࢮ�� FCB (ᬥ饭��)
FCB2_Seg        DW 0     ;���� ��ࢮ�� FCB (ᥣ����)
;---------------------------------------------------------

End_Of_Resident_Part:

ENV_COMSPEC     DB 'COMSPEC=' ;��� ��६����� ��� ���᪠ ���������� �����.
Copyrt_Roman    DB 'ZX Spectrum Navigator  Version 1.12';�� ��� �� ��� �⮣�!
                DB '  Copyright (c) 1999 RomanRoms Software Co.',0Ah,0Dh,'$'

SN_Run        ends
              end    Start
