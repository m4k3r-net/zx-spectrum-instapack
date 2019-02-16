{ࠡ�⠥� � �⠭���⭮� � ���饭���� ०���}
unit mouse;
interface
var kursor:^pointer;

function initmouse:boolean;{���뢠�� �ࠩ��� ��� �
                            �����頥� ���ﭨ� ���
                            initmouse=true -�ࠩ���
                            ��⠭����� ���� �� ��⠭��
                            ���}

procedure mouseon;         {��ᢥ稢��� ����� ���}

procedure mouseoff;        {���� ����� ���}

procedure getmouse(var mousex,mousey:word;var lpressed,rpressed:boolean);
                           {�����頥� ���न���� ���
                            � ������ ������:
                            mousex,mousey:���न���� ���
                            lpressed,rpressed:����⨥ ������}

procedure getmousepos(var mousex,mousey:word);
                           {�����頥� ���न���� ���
                            mousex,mousey:���न���� ���}
procedure setmousepos(mousex,mousey:word);
                           {��⠭�������� ���� � x,y ������
                            �� ��࠭�.
                            mousex,mousey:���न���� ���}

function getmousex:word;   {�����頥� ��ਧ��⠫��� ���न���� ���}

function getmousey:word;   {�����頥� ���⨪����� ���न���� ���}

function leftpressed:boolean;
                           {�᫨ ����� ������ �����
                            � �����頥� true       }

function rightpressed:boolean;
                           {�᫨ �ࠢ�� ������ �����
                            � �����頥� true       }

procedure setmouserange (minx,miny,maxx,maxy:word);
                           {������ �������� �������� ���}

procedure setmousespeed(speedx,speedy:byte);
                           {������ ᪮���� �������� ���}

procedure setmousepage(page:word);
                           {������ �������࠭��� ,�� ���ன �뢮����� ����}


implementation

function initmouse:boolean;assembler;
asm
   mov ax,0h;
   int 33h;
   mov bx,offset initmouse;
   cmp ax,0;
   jnz @@p;
   mov al,00h;
   jmp @@r;
@@p:mov al,01h;
@@r:
end;

procedure mouseon;assembler;
asm
   mov ax,01h;
   int 33h;
end;

procedure mouseoff;assembler;
asm
   mov ax,2h;
   int 33h;
end;

procedure getmouse(var mousex,mousey:word;var lpressed,rpressed:boolean);
var mousex1,mousey1:word;
var lpressed1,rpressed1:byte;
begin
asm
    mov lpressed1,00h;
    mov rpressed1,00h;
    mov ax,3h;
    int 33h;
    mov mousex1,cx;
    mov mousey1,dx;
    test bx,01h;
    jz @ea;
    mov lpressed1,0ffh;
@ea:test bx,02h;
    jz @eb;
    mov rpressed1,0ffh;
@eb:
end;
mousex:=mousex1;
mousey:=mousey1;
if lpressed1=0 then lpressed:=false else lpressed:=true;
if rpressed1=0 then rpressed:=false else rpressed:=true;
end;

procedure setmousepos (mousex,mousey:word);assembler;
asm
   mov ax,4h;
   mov cx,mousex;
   mov dx,mousey;
   int 33h;
end;

procedure getmousepos(var mousex,mousey:word);
var mousex1,mousey1:word;
begin
asm
   mov ax,03h;
   int 33h;
   mov mousey1,dx;
   mov mousex1,cx;
end;
mousex:=mousex1;
mousey:=mousey1;
end;

function getmousex:word;assembler;
asm
    mov ax,03h;
    int 33h;
    mov ax,cx;
end;

function getmousey:word;assembler;
asm
    mov ax,03h;
    int 33h;
    mov ax,dx;
end;

function leftpressed:boolean;assembler;
asm
   mov ax,03h;
   int 33h;
   mov al,00h;
   test bx,1h;
   jz @lp;
   mov al,01h;
@lp:
end;

function rightpressed:boolean;assembler;
asm
   mov ax,03h;
   int 33h;
   mov al,00h;
   test bx,2h;
   jz @rp;
   mov al,01h;
@rp:
end;

procedure setmouserange (minx,miny,maxx,maxy:word);assembler;
asm
   mov ax,07h;
   mov cx,minx;
   mov dx,maxx;
   int 33h;
   mov ax,08h;
   mov cx,miny;
   mov dx,maxy;
   int 33h;
end;

procedure setmousespeed(speedx,speedy:byte);assembler;
asm
   mov ax,01ah;
   mov bl,speedx;
   mov bh,00h;
   mov cl,speedy;
   mov ch,00h;
   mov dx,0;
   int 33h;
end;

procedure setmousepage(page:word);assembler;
asm
   mov ax,01dh;
   mov bx,page;
   int 33h;
end;
end.