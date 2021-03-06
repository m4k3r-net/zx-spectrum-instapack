/**************************************************************************

������ ����஫��� ��᪮�����

**************************************************************************/

#include <mem.h>
#include <stdio.h>
#include "main.hpp"
#include "emudata.h"
#include "addition.hpp"
#include "file.hpp"
#include "interfac.hpp"
#include "vg.hpp"

static unsigned char DiskBuf[0x100];

static char *DskFileName;
static FILE *Str;

unsigned FormatDatLen=0x1;

unsigned Ready=0x1;

unsigned ReadIndexTrack=0x0;

static unsigned char DskIndex[5]={0,1,1,0,0};

// ����ﭨ� ��᪠
// ���� 0-1 - ����� ��᪮����
// ��� 2 - �ଠ�஢��
// ��� 6 - ���� �����
// ��� 7 - ����� ���樠����஢��
static unsigned char DskStatus=0x00;

static byte DskIndexCounter;
static int CntData;
static int DskDataSize;
static byte DskCountDatLost;
static unsigned CntReady;

static unsigned DiskPosition(unsigned Sect) {
	return ((EmuTable.VG.RegTrack<<5)|(EmuTable.VG.System&0x10^0x10)|Sect)<<0x08;
}

static void SetStateStep() {
	if (EmuTable.VG.RegTrack<0)
		EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=EmuTable.VG.RegTrack=0;
	if (EmuTable.VG.RegTrack>0x4F)
		EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=EmuTable.VG.RegTrack=0x4F;
	EmuTable.VG.RegStatus=DskStatus&0x40;
	if (EmuTable.VG.RegCom&0x08) EmuTable.VG.RegStatus|=0x20;
	if (!EmuTable.VG.RegTrack) EmuTable.VG.RegStatus|=0x04;
		//// ���� 7,3,4
};

static void DskVG() {
	if (EmuTable.VG.RegStatus&0x01&&!--DskCountDatLost) EmuTable.VG.RegStatus=0x04;
	if (CntReady) if (!--CntReady) EmuTable.VG.RegStatus=0x03;
	switch (EmuTable.VG.OperIO) {
	 case 0x0: // �⥭�� ���ﭨ�
		EmuTable.VG.DataIO=EmuTable.VG.RegStatus;
		if (EmuTable.VG.RegCom&0x80) break;
		if (--DskIndexCounter&0xE) EmuTable.VG.DataIO|=0x02;
		break;
	 case 0x1: // ������ �������
		if (EmuTable.VG.RegStatus&0x01) {
		////�ਭ㤨⥫쭮� ���뢠���
		} else {
			if ((EmuTable.VG.DataIO&0xF0)==0xD0) return;
			switch ((EmuTable.VG.RegCom=EmuTable.VG.DataIO)>>4) {
			 case 0x0: // ����⠭�������
				EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=EmuTable.VG.RegTrack=0;
				EmuTable.VG.StepDirect=-1;
				SetStateStep();
				break;
			 case 0x1: // ����
				EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=EmuTable.VG.RegTrack=EmuTable.VG.RegData;
				if (EmuTable.VG.RegData-EmuTable.VG.RegTrack<0) EmuTable.VG.StepDirect=-1;
				if (EmuTable.VG.RegData-EmuTable.VG.RegTrack>0) EmuTable.VG.StepDirect=1;
				SetStateStep();
				break;
			 case 0x2:
			 case 0x3: // ���
				if (EmuTable.VG.StepDirect==-1) goto StepRear;
			 case 0x4:
			 case 0x5: // ��� ���।
				if (EmuTable.VG.RegTrack)
					EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=++EmuTable.VG.RegTrack;
				EmuTable.VG.StepDirect=1;
				SetStateStep();
				break;
			 case 0x6:
			 case 0x7: // ��� �����
				StepRear:
				if (EmuTable.VG.RegTrack)
					EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]=--EmuTable.VG.RegTrack;
				EmuTable.VG.StepDirect=-1;
				SetStateStep();
				break;
			 case 0x8:
			 case 0x9: // �⥭�� ᥪ��
				OpReadSector:
				if (EmuTable.VG.RegSect>0x10||
					EmuTable.VG.RegTrack!=EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]||
					(!(DskStatus&0x04))) goto OpNotFound;
				fseek(Str,DiskPosition(EmuTable.VG.RegSect-1),SEEK_SET);
				if (!fread(DiskBuf,0x100,1,Str)) goto OpContSum;
				DskDataSize=0x00FF;
				EmuTable.VG.RegData=DiskBuf[0];
				goto OpCom;
			 case 0xA:
			 case 0xB: // ������ ᥪ��
				OpWriteSector:
				if (DskStatus&0x40) goto OpWrProt;
				if (EmuTable.VG.RegSect>0x10||
					EmuTable.VG.RegTrack!=EmuTable.VG.TrackReal[EmuTable.VG.System&0x03]||
					(!(DskStatus&0x04))) goto OpNotFound;
				DskDataSize=0x0100;
				goto OpCom;
			 case 0xC: // �⥭�� ����
				DskDataSize=0x0005;
				EmuTable.VG.RegData=1;
				if (ReadIndexTrack) EmuTable.VG.RegData=EmuTable.VG.RegTrack;
				goto OpCom;
			 case 0xE: // �⥭�� ��஦��
				///????
				break;
			 case 0xF: // ������ ��஦��
				if (DskStatus&0x40) goto OpWrProt;
				DskDataSize=FormatDatLen;
				goto OpCom;
			}
		};
		break;
	 case 0x2: // �⥭�� ��஦��
		EmuTable.VG.DataIO=EmuTable.VG.RegTrack;
		break;
	 case 0x3: // ������ ��஦��
		if (!(EmuTable.VG.RegStatus&0x01)) EmuTable.VG.RegTrack=EmuTable.VG.DataIO;
		break;
	 case 0x4: // �⥭�� ᥪ��
		EmuTable.VG.DataIO=EmuTable.VG.RegSect;
		break;
	 case 0x5: // ������ ᥪ��
		if (!(EmuTable.VG.RegStatus&0x01)) EmuTable.VG.RegSect=EmuTable.VG.DataIO;
		break;
	 case 0x6: // �⥭�� ������
		if (EmuTable.VG.RegStatus&0x01) {
			switch (EmuTable.VG.RegCom>>4) {
			 case 0x8:
			 case 0x9: // �⥭�� ������ ������� "�⥭�� ᥪ��"
				EmuTable.VG.DataIO=EmuTable.VG.RegData;
				DskCountDatLost=0x10;
				if (CntData<DskDataSize) EmuTable.VG.RegData=DiskBuf[0x01+CntData++];
				else {
					if (EmuTable.VG.RegCom&0x10) {
						EmuTable.VG.RegSect++;
						goto OpReadSector;
					} else goto OpOk;
				}
				break;
			 case 0xC: // �⥭�� ������ ������� "�⥭�� ����"
				EmuTable.VG.DataIO=EmuTable.VG.RegData;
				DskCountDatLost=0x10;
				if (CntData<DskDataSize) EmuTable.VG.RegData=DskIndex[CntData++];
				else goto OpOk;
				break;
			}
		} else {
			EmuTable.VG.DataIO=EmuTable.VG.RegData;
		};
		break;
	 case 0x7: // ������ ������
		if (EmuTable.VG.RegStatus&0x01) {
			switch (EmuTable.VG.RegCom>>4) {
			 case 0xA:
			 case 0xB: // ������ ������ ������� "������ ᥪ��"
				DiskBuf[CntData++]=EmuTable.VG.RegData=EmuTable.VG.DataIO;
				DskCountDatLost=0x10;
				if (CntData>=DskDataSize) {
					fseek(Str,DiskPosition(EmuTable.VG.RegSect-1),SEEK_SET);
					if (!fwrite(DiskBuf,0x100,1,Str)) goto OpContSum;
					if (EmuTable.VG.RegCom&0x10) {
						EmuTable.VG.RegSect++;
						goto OpWriteSector;
					} else goto OpOk;
				}
				break;
			 case 0xF: // ������ ������ ������� "������ ��஦��"
				EmuTable.VG.RegData=EmuTable.VG.DataIO;
				DskCountDatLost=0x10;
				if (++CntData>=DskDataSize) {
					memset(DiskBuf,0,sizeof DiskBuf);
					if (DskStatus&0x04) {
						fseek(Str,DiskPosition(0),SEEK_SET);
						for (int i=0;i<0x10&&fwrite(DiskBuf,0x100,1,Str);i++);
					} else {
						if (!(Str=fopen(DskFileName,wbp))) goto OpOk;
						for (int i=0;i<0xA00&&fwrite(DiskBuf,0x100,1,Str);i++);
						DskStatus|=0x4;
					}
					goto OpOk;
				}
				break;
			}
		} else {
			EmuTable.VG.RegData=EmuTable.VG.DataIO;
		};
		break;
	 case 0x8: {// �⥭�� ᨣ����� Intrq � Drq
		unsigned char IntrqDrq=0xBF;
		if (EmuTable.VG.RegStatus&0x01) IntrqDrq=0x3F;
		if (EmuTable.VG.RegStatus&0x02) IntrqDrq=0x7F;
		EmuTable.VG.DataIO=IntrqDrq;
		break;
	 }
	 case 0x9: // ������ ��⥬���� ॣ���� ����஫��� ��᪮�����
		if (EmuTable.VG.RegStatus&0x01&&EmuTable.VG.RegCom&0x80) goto OpContSum;
		EmuTable.VG.System=EmuTable.VG.DataIO;
		if ((EmuTable.VG.System^DskStatus)&0x03) {
			DiskVG(0xB);
			DiskVG(0xA);
		}
		break;
	 case 0xA: {// ���樠������ ��᪠
		if (DskStatus&0x80) return;
		DskStatus=EmuTable.VG.System&0x03;
		DskFileName=EmuTable.Disks[DskStatus];
		int Attr=GetFileAttr(DskFileName);
		if (Attr!=-1) {
			Attr&=0x01;
			DskStatus|=(Attr)<<6;
			const char *AcsS=rbp;
			if (Attr) AcsS=rb;
			if (Str=fopen(DskFileName,AcsS)) DskStatus|=0x04;
		}
		DskStatus|=0x80;
		break;
	 }
	 case 0xB: // ���⨥ ��᪠
		if (!(DskStatus&0x80)) return;
		if (DskStatus&0x04) fclose(Str);
		DskStatus=0x00;
		break;
	 case 0xC: // Reset ��93
		EmuTable.VG.RegStatus=0x24;
		EmuTable.VG.RegCom=0x00;
		EmuTable.VG.RegTrack=0x00;
		EmuTable.VG.RegSect=0x01;
		EmuTable.VG.RegData=0x00;
		EmuTable.VG.System=0x3C;
		EmuTable.VG.StepDirect=0xFF;
		if (DskStatus&0x80&&DskStatus&0x03) {
			DiskVG(0xB);
			DiskVG(0xA);
		}
		break;
	}
	return;
	OpOk: // �ᯥ譮� �����襭��
		EmuTable.VG.RegStatus=0x00;
		return;
	OpWrProt: // ���� �����
		EmuTable.VG.RegStatus=0x40;
		return;
	OpNotFound: // ����� �� ������
		EmuTable.VG.RegStatus=0x10;
		return;
	OpContSum: // �訡�� ����஫쭮� �㬬�
		EmuTable.VG.RegStatus=0x08;
		return;
	OpCom: // ���� �������
		DskCountDatLost=0x00;
		CntData=0x0000;
		EmuTable.VG.RegStatus=0x03;
		if (!Ready) {
			EmuTable.VG.RegStatus=0x01;
			CntReady=0x10;
		}
}

void DiskVG(byte Oper) {
	EmuTable.VG.OperIO=Oper;
	if (Oper==0xA) ChDir(DskPth);
	if (PrFirst[P_VG_]) {
		Proc *PPnt=PrFirst[P_VG_];
		do if (((unsigned char(__pragma("ProgVG") *)())PPnt->Pr)()) goto ExitP;
		while (PPnt=PPnt->Next);
	}
	DskVG();
	ExitP:
	if (Oper==0xA) ChDir(StPth);
	CallAddition(PrFirst[P_VGP]);
}
