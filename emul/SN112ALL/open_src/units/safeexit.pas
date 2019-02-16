{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{****************************************************}
{***	����� �ਫ�筮�� �뫥⠭�� �� �訡��	  ***}
{***	��� ����⥫쭮 ��������� � Uses ����   ***}
{*** ��ࣥ� �����娭, ����, 2:5035/18.33@FidoNet ***}
{**************************************************}
Unit SafeExit; interface

const MaxLenExitMsg = 52;      { ���ᨬ��쭠� ����� ��஢ �ணࠬ��   }
const ExitMsg : ^string = nil; { ���쭠� ��ப� �ணࠬ�� �� ��室� }

implementation      {�������������������������ͻ}


const
   fCrLf    = #$0D;   { �ਧ��� ���室� � ����� ��ப� }
   fColor   = #$26;   { �ਧ��� ��������� 梥� 	}

		      { 梥�				}
   cTitle   ={#$FE}4*16+15;   {      ���쭠� ��ப� ����	}
   cNormal  = #$4F;   {      ��ଠ��� ⥪��		}
   cPRGName = #$4B;   {      ��� �ணࠬ��		}
   cErrCode = #$4A;   {      ����� �訡��		}
   cAnyKey  = 4*16+15;   {      ᮮ�饭�� �� Enter	}

   kbEnter  = $1C0D;  { ��� ������ Enter		}
   MSGWidth = 56;     { �ਭ� ���� ᮮ�饭��		}

const
   OldExit : pointer = nil;

procedure NewExit; far; assembler;
{$IFDEF DPMI}
const cS1 = fColor+cTitle+
	   '������������������� A t t e n t i o n ����������������ͻ'+fCrLf+
	   fColor+cNormal+'� '+fColor+cPrgName;
      cS2 ='                                                    '+
	   fColor+cNormal+' �'+fCrLf+
	   '������������������������������������������������������Ķ'+fCrLf+
	   '�     Internal error '+fColor+cErrCode;
      cS3 ='XXX'+
	   fColor+cNormal+'.'+fColor+cAnyKey+'       Please, press Enter ...  '+
	   fColor+cNormal+'�'+fCrLf+
	   '������������������������������������������������������ͼ'+#0;
const
    MSG : array[1..Length(cS1)] of char = cS1;
    Tit : array[1..Length(cS2)] of char = cS2;
    ENo : array[1..Length(cS3)] of char = cS3;

asm
{$ELSE}
    label MSG,Tit,ENo;
asm
   jmp	    @M0
MSG:
   db	 fColor,cTitle
   db	 '������������������ A t t e n t i o n ! ���������������ͻ',fCrLf
   db	 fColor,cNormal,'� ',fColor,cPrgName
Tit:
   db	 '                                                    '
   db	 fColor,cNormal,' �',fCrLf
{   db	   '������������������������������������������������������Ķ',fCrLf}
   db	   '�     Internal error ',fColor,cErrCode
ENo:
   db	 'XXX'
   db	 fColor,cNormal,'.',fColor,cAnyKey,'  Please, press Enter ...     '
   db	 fColor,cNormal,'�',fCrLf
   db	 fColor,cNormal,'� ',fColor,cPrgName
   db	 '                                                    '
   db	 fColor,cNormal,' �',fCrLf
   db	 '������������������������������������������������������ͼ',0;
@M0:
{$ENDIF}




   mov	  ax,Seg @Data		{ �� ��砩, �᫨ � �ணࠬ��	}
   mov	  ds,ax 		{ �ᯮ�祭 ds			}
   mov	  ax,ErrorAddr.word[0]	{ �஢�ઠ ������ �訡��	}
   or	  ax,ErrorAddr.word[2]
   jz	  @M8
db 66h
   xor	  ax,ax 		{ ��� �訡��			}
db 66h
   mov	  ErrorAddr.word,ax
   mov	  ax,ExitCode		{ �८�ࠧ������ ExitCode	}
   aam
   add	  al,'0'
   mov	  ENo.byte[2],al
   mov	  al,ah
   aam
   add	  ax,'00'
   xchg   al,ah
   mov	  ENo.word[0],ax

   push   ds			{ ������ ������������ �ணࠬ�� }
   lds	  si,ExitMsg
   mov	  ax,ds
   or	  ax,si
   jz	  @M2			{ �᫨ ���� nil - ��� ��ப�	}
   cld
   lodsb
   xor	  cx,cx
   mov	  cl,al
   jcxz   @M2			{ �᫨ ����� 0 - ��� ��ப�	}
   cmp	  cl,MaxLenExitMsg
   jbe	  @M1
   mov	  cl,MaxLenExitMsg	{ ��࠭���� ������ ��ப�	}
@M1:
   mov	  di,Seg Tit
   mov	  es,di
   lea	  di,Tit
   mov	  ax,MaxLenExitMsg
   sub	  al,cl
   shr	  ax,1
   add	  di,ax 		{ ��ப� ������ �� 業���	}
   rep	  movsb 		{ ��९���� ��ப�		}
@M2:
   pop	  ds

   mov	  ah,0Fh
   int	  10h
{}
   xor	  ah,ah{}
   mov	  es,SegB000
   cmp	  al,7
   je	  @M21
   mov	  al,3{}
   mov	  es,SegB800{}
@M21:
{
   int	  10h
{}
   mov	  di,(10*80+(80-MSGWidth)/2)*2 { �뢮� ᮮ�饭�� �� �࠭      }
   lea	  si,MSG
   mov	  ah,cNormal

  mov ah,1
  mov ch,32
  mov cl,14
  Int 10h      {Cursor OFF}

@M3:
{$IFNDEF DPMI}
   SegCS
{$ENDIF}
   lodsb
   or	  al,al
   jz	  @M6
   cmp	  al,fColor
   jne	  @M4
{$IFNDEF DPMI}
   SegCS
{$ENDIF}
   lodsb
   mov	  ah,al
   jmp	  @M3
@M4:
   cmp	  al,fCrLf
   jne	  @M5
   add	  di,(80-MSGWidth)*2
   jmp	  @M3
@M5:
   stosw
   jmp	  @M3
@M6:
   xor	  ax,ax
   int	  16h
   cmp	  ax,kbEnter
   jne	  @M6

  mov ax,6*256
  mov cx,0
  mov dx,3280h
  int 10h      {Clear Screen}

  mov ah,1
  mov ch,13
  mov cl,14
  Int 10h      {ON}

@M8:
db 66h
   mov	  ax,OldExit.word
db 66h
   mov	  ExitProc.word,ax



end;

begin			   { ᮡ�⢥��� �᭮���� �ଥ� ��� }
  asm			   { � �� �।��饥 - �� proc   }
   mov	 ax,Seg NewExit    { ��ࠡ�⪨ �� ��室� ;)	   }
db 66h
   shl	 ax,16
   lea	 ax,NewExit
db 66h
   xchg  ExitProc.word,ax
db 66h
   mov	 OldExit.word,ax
  end;
end.
