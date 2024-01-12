#include <iostream.h>
#include <iomanip.h>
#include <fstream.h>
#include <string.h>
#include <stdlib.h>
#include <io.h>
#include "filespec.hpp"

typedef unsigned long dword;

struct NPInfoStruct
{
	char Copyright[28];
	unsigned long ProgramCounter;
	unsigned short CatalogID;
	unsigned char SubVersion;
	unsigned char ColorRom;
	char GameName[12];
};

struct GameListInfoStruct
{
	char *gameName;
	int language; /* 1 = ja, 2 = en, 3 = ja+en */ 
};

struct pbOptionsStruct
{
	unsigned int format;
	char *formatStr;
	bool sweep;
};


// Function Prototypes
int printTableInfo(pbOptionsStruct, char *);
int printFormattedInfo(pbOptionsStruct, char *);
char *returnPlatform(int);
char *returnRealName(unsigned short);



// Constants, Including game list. Yes, I know this is bad.. c.c

const int ColorRomConst = 0x10;
const int GameListSize = 125;

const GameListInfoStruct GameList[126] = {
/* 000 */ "Unknown",0,
/* 001 */	"The King of Fighters R-1",3,
/* 002 */	"NeoGeo Cup '98",3,
/* 003 */ "Unknown",0,
/* 004 */	"Melon-chan's Growth Diary",1,
/* 005 */	"Master of Syogi",1,
/* 006 */ "Unknown",0,
/* 007 */	"Baseball Stars",3,
/* 008 */	"Samurai Spirits!",3,
/* 009 */	"Pocket Tennis",3,
/* 010 */	"Biomotor Unitron",1,
/* 011 */	"Real Bout Fatal Fury First Contact",3,
/* 012 */	"Renketsu Puzzle Tsunagete Pon!",1,
/* 013 */ "Unknown",0,
/* 014 */	"Neo Cherry Master",3,
/* 015 */	"Neo Dragon's Wild",3,
/* 016 */	"Neo Mystery Bonus",3,
/* 017 */	"Neo Derbychamp",1,
/* 018 */ "Unknown",0,
/* 019 */ "Unknown",0,
/* 020 */	"Puzzle Bobble Mini",1,
/* 021 */	"Metal Slug 1st Mission",3,
/* 022 */ "Unknown",0,
/* 023 */	"The King of Fighters R-2",3,
/* 024 */	"Neo Cherry Master Color",3,
/* 025 */	"Baseball Stars Color",3,
/* 026 */	"Neo Pocket Pro Yakyuu",1,
/* 027 */	"Master of Syougi",1,
/* 028 */	"Pocket Tennis Color",3,
/* 029 */	"Renketsu Puzzle Tsunagete Pon! Color",1,
/* 030 */	"Samurai Spirits! 2",3,
/* 031 */	"Bust-A-Move Pocket",2,
/* 032 */	"Party Mail",1,
/* 033 */	"Dokodemo Mahjong",1,
/* 034 */ "Unknown",0,
/* 035 */	"Neo Turf Masters",3,
/* 036 */	"Dive Alert - Burn",1,
/* 037 */	"Dive Alert - Rebecca",1,
/* 038 */	"Crush Roller",3,
/* 039 */	"Neogeo Cup '98 Plus Color",3,
/* 040 */	"Shanghai Mini",3,
/* 041 */	"PuyoPuyo 2",3,
/* 042 */ "Unknown",0,
/* 043 */ "Unknown",0,
/* 044 */	"Pocket Love if",1,
/* 045 */	"Dark Arms (Beast Busters '99)",3,
/* 046 */	"Pachinko Hisshou Guide Pocket Parlor",1,
/* 047 */ "Unknown",0,
/* 048 */	"Magical Drop Pocket",1,
/* 049 */	"Tsunagete Pon! 2",1,
/* 050 */	"Kikou Seiki Unitron",1,
/* 051 */	"Faselei!",1,
/* 052 */	"Pachinko Slot ARUZE Oukoku Pocket Hanabi",1,
/* 053 */	"Biomotor Unitron",2,
/* 054 */	"Puzzle Link",2,
/* 055 */	"Pac-Man",3,
/* 056 */	"SNK Vs. Capcom - Card Fighters [SNK Ver.]",1,
/* 057 */	"SNK Vs. Capcom - Card Fighters [Capcom Ver.]",1,
/* 058 */	"Magical Drop Pocket",2,
/* 059 */	"Sonic the Hedgehog - Pocket Adventure",2,
/* 060 */	"Densha de GO! 2 on Neogeo Pocket",1,
/* 061 */	"Metal Slug 2nd Mission",3,
/* 062 */	"Mizuki Shigeru Youkai Shashinkan",1,
/* 063 */	"Mezase! Kanjiou",1,
/* 064 */	"Gekka no Kenshi",1,
/* 065 */	"SNK Gals Fighters",1,
/* 066 */	"Wrestling Madness",2,
/* 067 */	"SNK Vs. Capcom - Card Fighters [SNK Ver.]",2,
/* 068 */	"SNK Vs. Capcom - Card Fighters [Capcom Ver.]",2,
/* 069 */	"SNK Vs. Capcom - The Match of the Millenium",3,
/* 070 */	"Neo 21",3,
/* 071 */	"Dynamite Slugger",1,
/* 072 */ "Unknown",0,
/* 073 */ "Unknown",0,
/* 074 */	"Pachinko Slot ARUZE Oukoku Pocket Azteca",1,
/* 075 */	"Cool Boarders Pocket",3,
/* 076 */	"Puzzle Link 2",2,
/* 077 */ "Unknown",0,
/* 078 */	"Soreike! Hanafuda Doujou",1,
/* 079 */	"Pocket Reversi",1,
/* 080 */	"Cotton - Fantastic Night Dreams",1,
/* 081 */	"Oekaki Puzzle",1,
/* 082 */	"Kamihata Seiki Evolution",1,
/* 083 */	"Bikkuriman 2000 - Viva! Pocket Festiva!",1,
/* 084 */	"Pachinko Slot ARUZE Oukoku Pocket Ward of Lights",1,
/* 085 */	"Densetsu no Ogre Battle Gaiden",1,
/* 086 */ "Unknown",0,
/* 087 */	"Memories Off Pure",1,
/* 088 */	"Dive Alert - Matt's Version",2,
/* 089 */	"Dive Alert - Becky's Version",2,
/* 090 */	"Faselei!",2,
/* 091 */	"Koi Koi Mah-jong",1,
/* 092 */	"The King of Fighters Battle de Paradise",1,
/* 093 */	"SNK Gals Figthers",2,
/* 094 */	"Rockman Battle and Fighters",1,
/* 095 */	"Last Blade, The",2,
/* 096 */ "Unknown",0,
/* 097 */	"Ganbare NeoPoke-kun",1,
/* 098 */	"Neo Baccarat",0,
/* 099 */	"Evolution Eternal Dungeons",2,
/* 100 */ "Cool Cool Jam",1,
/* 101 */ "Unknown",0,
/* 102 */ "Pachinko Slot ARUZE Oukoku Pocket Porcano 2",1,
/* 103 */ "Delta Warp",1,
/* 104 */	"Pocket Reversi",2,
/* 105 */	"Cotton: Fantastic Night Dreams",2,
/* 106 */	"Picture Puzzle",2,
/* 107 */ "Unknown",0,
/* 108 */ "Unknown",0,
/* 109 */ "Unknown",0,
/* 110 */ "Unknown",0,
/* 111 */ "Unknown",0,
/* 112 */ "Unknown",0,
/* 113 */ "Unknown",0,
/* 114 */ "Unknown",0,
/* 115 */ "Unknown",0,
/* 116 */ "Unknown",0,
/* 117 */ "Unknown",0,
/* 118 */ "Unknown",0,
/* 119 */ "Unknown",0,
/* 120 */ "Unknown",0,
/* 121 */ "Unknown",0,
/* 122 */ "Unknown",0,
/* 123 */ "Unknown",0,
/* 124 */ "Unknown",0,
/* 125 */ "Unknown",0,
};

/* this is the CRC32 lookup table
 * thanks to Gary S. Brown 
 * 64 lines of 4 values for a 256 dword table (1024 bytes)
 */
const unsigned long crc_table[256] = {
  0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
  0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
  0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
  0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
  0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
  0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
  0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
  0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
  0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
  0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
  0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
  0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
  0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
  0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
  0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
  0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
  0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
  0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
  0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
  0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
  0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
  0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
  0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
  0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
  0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
  0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
  0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
  0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
  0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
  0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
  0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
  0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
  0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
  0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
  0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
  0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
  0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
  0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
  0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
  0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
  0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
  0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
  0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
  0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
  0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
  0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
  0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
  0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
  0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
  0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
  0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
  0x2d02ef8dL
};


unsigned int FileCRC(fstream &File)
{
	unsigned char c;
	unsigned int crc;

	File.seekg(0, ios::beg);

	crc = 0xFFFFFFFF;

	while(!File.eof())
	{
		File.read((char *)&c, 1);
		if(!File.eof())
			crc =  crc_table[(crc ^ c) & 0xff] ^ (crc >> 8);
	};

	return crc ^ 0xffffffff;
}


void main (int argc, char *argv[])
{
	fstream ImageFile;
	NPInfoStruct ImageInfo;
	unsigned int errno, currArg, dropOut = 0;
	pbOptionsStruct pbOptions;
	char firstChar[2];
	
	pbOptions.format=0;

    if (argc < 2)
    {
        cout << "Error in number of arguments.\n";
		exit(1);
	}

    for (currArg=1;(currArg < (argc - 1))&&(dropOut == 0); currArg++)
    {
		strncpy (firstChar, argv[currArg], 1);
		if (strstr(firstChar, "-"))
		{
			switch (argv[currArg][1])
			{
			case 'f':
				if (argc < (currArg + 3))
				{
					cout << "Error in number of arguments.\n";
					exit(1);
				}
					pbOptions.format = 1;
					currArg++;
					pbOptions.formatStr = argv[currArg];
					break;
			default:
					;
			}


		}
		else
			dropOut = 1;
	}


	if (strstr(argv[currArg],".rom"))
	{
		cout << "|nformant is a DORK!!!\n";
		exit(0);
	}

	ImageFile.open(argv[currArg], ios::in | ios::binary | ios::nocreate);
	if (ImageFile.fail())
	{
		cout << "Error opening file.\n";
	}
	else
	{

		ImageFile.read((char *)&ImageInfo, sizeof(ImageInfo));


		if (pbOptions.format == 1)
		{
			errno = printFormattedInfo(pbOptions, argv[currArg]);
		}
		else
		{
			errno = printTableInfo(pbOptions, argv[currArg]);
		}

	}
}


// This function prints out a nice table of the header info.


int printTableInfo(pbOptionsStruct pbOptions, char *ImageName)
{
	NPInfoStruct ImageInfo;
	fstream ImageFile;
	int j, k, l;

	ImageFile.open(ImageName, ios::in | ios::binary | ios::nocreate);
	if (ImageFile.fail())
	{
		cout << "Error opening file.\n";
		return -1;
	};

	ImageFile.read((char *)&ImageInfo, sizeof(ImageInfo));

	cout << ImageName << "\n";
	cout << "Int. Name:   ";
	for (j=0;j < sizeof(ImageInfo.GameName);j++)
		cout << ImageInfo.GameName[j];
	cout << "\n";
	cout << "Liscence:    ";
	for (j=0;j < sizeof(ImageInfo.Copyright);j++)
	     cout << ImageInfo.Copyright[j];
	cout << "\n"; 
	cout << "Image CRC:   " << setiosflags(ios::hex | ios::uppercase | ios::internal ) << "0x" << FileCRC(ImageFile) << "\n";
	cout << "Wacky Byte:  " << ((ImageInfo.ProgramCounter & 0xFF000000) >> 6) << "\n";
	cout << "Initial PC:  " << "0x" << (ImageInfo.ProgramCounter &0x00FFFFFF) << "\n";
	cout << "Catalog ID:  " << setiosflags(ios::dec) << ImageInfo.CatalogID << "\n";
	cout << "Version #:   " << setiosflags(ios::dec) << int(ImageInfo.SubVersion) << "\n";
	cout << "Color ROM?:  ";
	if(int(ImageInfo.ColorRom))
	{
		cout << "True:(";
	}
	else
	{
		cout << "False:(";
	}
	cout << setiosflags(ios::dec) << int(ImageInfo.ColorRom) << ")\n";
			
	ImageFile.close();
	return(0);
};


// This option is called when the user specifies the format.

int printFormattedInfo(pbOptionsStruct pbOptions, char *FileName)
{

	NPInfoStruct ImageInfo;
	fstream ImageFile;
	int j, k, l, m;

	ImageFile.open(FileName, ios::in | ios::binary | ios::nocreate);
	if (ImageFile.fail())
	{
		cout << "Error opening file.\n";
		return -1;
	};

	ImageFile.read((char *)&ImageInfo, sizeof(ImageInfo));


	for(k=0;k<strlen(pbOptions.formatStr);k++)
	{
		if (pbOptions.formatStr[k] == '^')
		{
			k++;
			switch (pbOptions.formatStr[k])
			{
			case 't': // Tab
				cout << '\t';
				break;

			case 'l': // Long Name
				cout << returnRealName(ImageInfo.CatalogID);
				break;

			case 'o': // Original Name
				cout << FileName;
				break;

			case 'c': // CRC
				cout << setiosflags(ios::hex) << "0x" << FileCRC(ImageFile);
				break;

			case 'v': // Sub Version ID
				cout << setiosflags(ios::hex) << int(ImageInfo.SubVersion);
				break;

			case 'i': // Catalog ID
				cout << setiosflags(ios::hex) << ImageInfo.CatalogID ;
				break;

			case 'n': // Internal Name
				for (l=0;l<12;l++)
					cout << ImageInfo.GameName[l];
				break;

			case 'p': // Platform
				cout << returnPlatform(int(ImageInfo.ColorRom));
				break;

			default: // Der.. just print the char.
				cout << pbOptions.formatStr[k];
			}
		}
		else
		{
			cout << pbOptions.formatStr[k];
		}

	}
	cout << '\n';
	return(0);
};


// This function returns the platfor the cart was designed for.

char *returnPlatform(int pn)
{
	switch (pn)
	{
	case 0:
		return "NGP";
		break;
	case 16:
		return "NGPC";
		break;
	default:
		return "INVALID";
	}
};

// This returns the real name from the table.

char *returnRealName(unsigned short id)
{
	int m;
	m =  ((id & 0x000f) +
		(((id & 0x00f0) / 0x10)*10) +
		(((id & 0x0f00) / 0x100 )*100) +
		(((id & 0xf000) / 0x1000 )*1000));
	if (m <= GameListSize)
		return GameList[m].gameName;
	else
		return "Unknown";
		// In other words, don't crash.. :p

};
