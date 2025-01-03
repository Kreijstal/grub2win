#include-once
#include <Array.au3>
Const  $winstring         = "windows"
Const  $typewinboot       = "** Windows Boot **"
Const  $typechaindisk     = "chainload a disk"
Const  $typechainfile     =	"chainload a file"
Const  $typecustom        =	"custom code"
Const  $typeotherlin      =	"other linux **"
Const  $typeuser          =	"create user section"
Const  $typeimport        =	"import linux config"

Const  $selectionfieldcount = 31
Const  $sEntryTitle       =  1, $sOSType          =  2, $sClass           =  3, $sLoadBy          =  4, $sRootDisk        =  5
Const  $sRootFileSystem   =  6, $sBootDisk        =  7, $sBootFileSystem  =  8, $sLayout          =  9, $sRootSearchArg   = 10
Const  $sChainDrive       = 11, $sSortSeq         = 12, $sFamily          = 13, $sBootParm        = 14, $sGraphMode       = 15
Const  $sUpdateFlag       = 16, $sHotKey          = 17, $sReviewPause     = 18, $sIcon            = 19, $sDiskError       = 20
Const  $sMouseUpDown      = 21, $sNvidia          = 22, $sDefaultOS       = 23, $sReboot          = 24, $sSampleLoadby    = 25
Const  $sAutoUser         = 26, $sCustomName      = 27, $sFileLoadCheck   = 28, $sKernelName      = 29, $sInitrdName      = 30
Const  $sImported         = 31

Const  $bcdfieldcount     = 10
Const  $bOrderType        =  0, $bItemType   =  1, $bItemTitle     =  2, $bGUID        =  3, $bDrive      =  4, $bPath =  5   ; Array subscripts
Const  $bSortSeq          =  6, $bUpdateFlag =  7, $bItemTitlePrev =  8, $bMouseUpDown =  9, $bUpdateHold = 10

Const  $gIPAddress         = 0, $gCountry = 1,  $gRegion  = 2, $gCity  = 3

Const  $pType = 0, $pClass = 1, $pFamily  = 2, $pFirmMode = 3, $pTitle =  4, $pBootParms = 5, $pUtilCommand = 6, $pHoldParms = 7, $parmsfieldcount = 8

Const  $iPath = 0, $iVersion = 1, $iBuild = 2, $iStatus = 3, $iStamp = 4, $iJul = 5, $iDate = 6, $iTime = 7

Const  $sUpNextRemind = 0, $sUpRemindFreq    = 1, $sUpLastCheck = 2
Const  $sUpToGoDays   = 3, $sUpLastCheckDays = 4, $sUpOldRemind = 5

Global $osparmarray [26] [$parmsfieldcount] = [ _
    ["unknown",      "unknown",       "",               "ALL",  "Unknown OS",                     ""],                                   _
	["android",      "android",       "linux-android",  "64B",  "Android",                                                               _
	            "root=/dev/ram0 verbose androidboot.selinux=permissive vmalloc=256M buildvariant=userdebug"],                            _
	["debian",       "debian",        "linux-debian",   "ALL",  "Debian Linux",                   "verbose"],                            _
	["fedora",       "fedora",        "linux-fedora",   "ALL",  "Fedora Linux",                   "verbose"],                            _
	["manjaro",      "manjaro",       "linux-manjaro",  "ALL",  "Manjaro Linux",                  "rw verbose"],                         _
	["mint",         "mint",          "linux-mint",     "ALL",  "Mint Linux",                     "verbose"],                            _
	["phoenix",      "phoenix",       "linux-android",  "64B",  "PhoenixOS",                                                             _
	    "verbose root=/dev/ram0 androidboot.hardware=android_x86_64 SRC=/PhoenixOS"],                                                    _
	["posrog",       "posrog",        "other",          "ALL",  "POSROG",                         ""],                                   _
	["slackware",    "slackware",     "linux-slack",    "ALL",  "Slackware Linux",                "verbose"],                            _
	["suse",         "suse" ,         "linux-suse",     "ALL",  "Suse Linux",                     "splash=verbose showopts"],            _
	["ubuntu",       "ubuntu",        "linux-ubuntu",   "ALL",  "Ubuntu Linux",                   "verbose"],                            _
	[$typeotherlin,  "",              "standfunc",      "ALL",  "",                               ""],                                   _
	["bootfirmware", "bootfirmware",  "standfunc",      "EFI",  "Boot to your EFI firmware",      "", "g2wutil fwsetup"],                _
	["bootinfo",     "bootinfo",      "standfunc",      "ALL",  "Boot Information and Utilities", "", "g2wbootinfo"],                    _
	[$typechainfile, "chainfile",     "chainfile",      "EFI",  "Chainload a File",               ""],                                   _
	[$typechaindisk, "chaindisk",     "chaindisk",      "BIOS", "Chainload a BIOS Disk",          ""],                                   _
	["clover",       "clover",        "standfunc",      "EFI",  "Clover for OSX",                 ""],                                   _
	["custom code",  "custom",        "custom",         "ALL",  "My Custom Code",                 ""],                                   _
	["invaders",     "invaders",      "standfunc",      "BIOS", "Invaders Game",                  ""],                                   _
	["isoboot",      "isoboot",       "isoboot",        "ALL",  "Boot An ISO file",               ""],                                   _
	["reboot",       "reboot",        "standfunc",      "ALL",  "Reboot Your System",             "", "g2wutil reboot"],                 _
	["shutdown",     "shutdown",      "standfunc",      "ALL",  "Shutdown Your System",           "", "g2wutil halt"],                   _
	["submenu",      "submenu",       "other",          "ALL",  "Sub Menu",                       ""],                                   _
	[$typeuser,      $typeuser,       "standfunc",      "ALL",  "Create the user section",        ""],                                   _
	[$winstring,     $winstring,      $winstring,       "All",  "Windows Boot Manager",           ""]]

Const  $efiguid     = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
Const  $dynmetaguid = "5808C8AA-7E8F-42E0-85D2-E1E90434CFB3"

Const  $tGUID = 0, $tCode = 1, $tDesc = 2, $tFamily = 3, $tFileSystem = 4, $tFieldCount = 5

Const  $parttypearray [31] [$tFieldCount] = [ _
		["",                                      "",   "Unknown Filesystem",     "Misc",     ""],     _
		["",                                      "",   "Apple Filesystem",       "Apple",    "Misc"], _
		[$efiguid,                                "EF", "EFI Partition",          "EFI",      ""],     _
		["EBD0A0A2-B9E5-4433-87C0-68B6B72699C7",  "07", "Data",                   "Windows",  ""],     _
		[$dynmetaguid,                            "42", "LDM Meta - Unsupported", "Dynamic",  ""],     _
		["AF9B60A0-1431-4F62-BC68-3311714A69AD",  "",   "LDM Data - Unsupported", "Misc",     ""],     _
		["E3C9E316-0B5C-4DB8-817D-F92DF00215AE",  "73", "Microsoft Reserved",     "Reserved", ""],     _
		["DE94BBA4-06D1-4D40-A16A-BFD50179D6AC",  "27", "Windows Recovery",       "System",   ""],     _
		["21686148-6449-6E6F-744E-656564454649",  "",   "BIOS/GPT Boot",          "System",   ""],     _
		["0FC63DAF-8483-4772-8E79-3D69D8477DE4",  "83", "Linux Filesystem",       "Linux",    ""],     _
		["E6D6D379-F507-44C2-A23C-238F2A3DF928",  "8E", "Linux Logical Volume",   "Linux",    ""],     _
		["BC13C2FF-59E6-4262-A352-B275FD6F7172",  "EA", "Linux Boot",             "Linux",    ""],     _
		["44479540-F297-41B2-9AF7-D131D5F0458A",  "",   "Linux Root (x86)",       "Linux",    ""],     _
		["4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709",  "",   "Linux Root (x86-64)",    "Linux",    ""],     _
		["0657FD6D-A4AB-43C4-84E5-0933C84B4F4F",  "82", "Linux Swap",             "Swap",     "SWAP"], _
		["",                                      "FD", "Linux Filesystem",       "Linux",    "Raid"], _
		["48465300-0000-11AA-AA11-00306543ECAC",  "",   "Apple Filesystem",       "Apple",    "HFS+"], _
		["7C3457EF-0000-11AA-AA11-00306543ECAC",  "",   "Apple Filesystem",       "Apple",    "APFS"], _
		["426F6F74-0000-11AA-AA11-00306543ECAC",  "",   "Apple Filesystem",       "Apple",    "Boot"], _
		["83BD6B9D-7F41-11DC-BE0B-001560B84F0F",  "",   "FreeBSD Filesystem",     "BSD",      "Boot"], _
		["516E7CB4-6ECF-11D6-8FF8-00022D09712B",  "",   "FreeBSD Filesystem",     "BSD",      "Data"], _
		["516E7CB5-6ECF-11D6-8FF8-00022D09712B",  "",   "FreeBSD Swap",           "Swap",     "SWAP"], _
		["516E7CB6-6ECF-11D6-8FF8-00022D09712B",  "",   "FreeBSD Filesystem",     "BSD",      "UFS"],  _
		["516E7CBA-6ECF-11D6-8FF8-00022D09712B",  "",   "FreeBSD Filesystem",     "BSD",      "ZFS"],  _
		["42465331-3BA3-10F1-802A-4861696B7521",  "",   "Haiku BeOS Filesystem",  "Linux",    "BFS"],  _
		["F4019732-066E-4E12-8273-346C5641494F",  "",   "Sony Boot Partition",    "Misc",     ""],     _
		["BFBFAFE7-A34F-448A-9A5B-6213EB736C22",  "",   "Lenovo Boot Partition",  "Misc",     ""],     _
		["FE3A2A5D-4F32-41A7-B725-ACCC3285A309",  "",   "Chrome OS Kernel",       "Linux",    ""],     _
		["3CB8E202-3B7E-47DD-8A3C-7FF2A13CFCEC",  "",   "Chrome OS Root FS",      "Linux",    ""],     _
		["CAB6E88E-ABF3-4102-A07A-D4BB9BE3C1D3",  "",   "Chrome OS Firmware",     "Misc",     ""],     _
		["2E0A753D-9E48-43B0-8337-B15192CB1B5E",  "",   "Chrome OS Future Use",   "Misc",     ""]]

Const  $parthexheader       = "                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F"
Const  $partnotformatted    = "Not Formatted"

Const  $partfieldcount  = 32                  ; Partitition array subscripts
Const  $pDiskNumber     =  0, $pPartNumber     =  1, $pDriveLetter    =  2, $pPartFileSystem =  3, $pPartLabel      =  4
Const  $pStartLBA       =  5, $pEndLBA         =  6, $pPartOffset     =  7, $pPartSize       =  8, $pPartFreeSpace  =  9
Const  $pPartType       = 10, $pPartInfo       = 11, $pPartExtended   = 12, $pConfirmHandle  = 13, $pEFILevel       = 14
Const  $pEFIFlag        = 15, $pAction         = 16, $pGrubFound      = 17, $pSortPartID     = 18, $pDriveMediaDesc = 19
Const  $pDriveLabel     = 20, $pDriveSize      = 21, $pDriveUsed      = 22, $pDriveStyle     = 23, $pDrivePartCount = 24
Const  $pDriveSecSize   = 25, $pCloverLevel    = 26, $pBrowseHandle   = 27, $pPartUUID       = 28, $pPartFamily     = 29
Const  $pPartTypeCode   = 30, $pSortPhysical   = 31, $pDriveLoaded    = 32

Const  $sBackBorder = 0, $sBackSelect = 1, $sBackName  = 2, $sBackDelete    = 3, $sBackImage = 4

Const  $sFontName    = 0, $sHorizRes    = 1, $sBannerLeft = 2, $sClockLeft  = 3, $sBarLeft   = 4,  $sBarWidth     =  5
Const  $sSecondsLeft = 6, $sHotKeyLimit = 7, $sFontExpand = 8, $sFontNormal = 9, $sFontSmall = 10, $sFontSmallest = 11
Const  $sFontBold    = 12

Global  $fontarray   [15] [13] = [ _
		["Unifont 16",            1024,     84, 	  82,       20,		    60,	         79,          67],  _
		["DejaVu Sans Mono 12"                                                                          ],  _
		["DejaVu Sans Mono 14"                                                                          ],  _
		["DejaVu Sans Mono 16",   1024,     84,       82,       20,         60,          79,          52],  _
		["DejaVu Sans Mono 18",   1280,     84,       82,       20,         60,          81,          55],  _
		["DejaVu Sans Mono 20",   1440,     84,       82,       20,         60,          81,          52],  _
		["DejaVu Sans Mono 22",   1600,     84,       83,       18,         60,          82,          47],  _
		["DejaVu Sans Mono 24",   1920,     84,       83,       18,         60,          82,          52],  _
		["DejaVu Sans Mono 26",   2048,     84,       82,       20,         60,          83,          47],  _
		["DejaVu Sans Mono 28",   2160,     84,       82,       20,         60,          79,          52],  _
		["DejaVu Sans Mono 30",   2304,     84,       82,       20,         60,          79,          47],  _
		["DejaVu Sans Mono 32",   2560,     84,       82,       20,         60,          79,          52],  _
		["DejaVu Sans Mono 34",   2736,     84,       82,       20,         60,          83,          47],  _
		["DejaVu Sans Mono 38",   3000,     84,       82,       20,         60,          84,          55],  _
		["DejaVu Sans Mono 40",   3200,     84,       82,       20,         50,          85,          60]]
;	          Font Name          HorRes   Banner    Clock    Bar Left    Bar Width     Seconds    HotKeyLimit

Const  $sLangName = 0, $sLangCode = 1, $sLangNative = 2, $sLangCulture = 3, $sLangSubculture = 4

Const  $langarray [33] [5] =                                                             _
		   [["Catalan",                "ca",    "Catalá",               "  ",  "0403"],  _
			["Chinese (simplified)",   "zh_CN", "Zhongguó (Jianhuàzì)", "  ",  "0804"],  _
			["Chinese (traditional)",  "zh_TW", "Zhongguó (Chuántong)", "  ",  "0404"],  _
			["Croatian",               "hr",    "Hrvatski",             "  ",  "041a"],  _
			["Danish",                 "da",    "Dansk",                "  ",  "0406"],  _
		    ["Dutch",                  "nl",    "Nederlands",           "13"         ],  _
		    ["English",                "en",    "English",              "09"         ],  _
		    ["Esperanto",              "eo",    "Esperanton"                         ],  _
		    ["Finnish",                "fi",    "Suomen Kieli",         "  ",  "040b"],  _
   		    ["French",                 "fr",    "Français",             "0c"         ],  _
			["Galician",               "gl",    "Galego",               "  ",  "0456"],  _
		    ["German",                 "de",    "Deutsch",              "07"         ],  _
			["Hebrew",                 "he",    "עִבְרִית",                "  ",  "040d"],  _
			["Hungarian",              "hu",    "Magyar Nyelv",         "  ",  "040e"],  _
			["Indonesian",             "id",    "Bahasa Indonesia",     "  ",  "0421"],  _
		    ["Italian",                "it",    "Italiano",             "10"         ],  _
		    ["Japanese",               "ja",    "Nihongo",              "  ",  "0411"],  _
		    ["Korean",                 "ko",    "Pyojun-eo",            "  ",  "0412"],  _
		    ["Lithuanian",             "lt",    "Lietuviu",             "  ",  "0427"],  _
		    ["Norwegian",              "nb",    "Nynorsk",              "14"         ],  _
		    ["Polish",                 "pl",    "Jezyk Polski",         "  ",  "0415"],  _
		    ["Portuguese",             "pt",    "Português",            "16"         ],  _
		    ["Punjabi (India)",        "pa",    "Pajabi (India)",       "  ",  "0446"],  _
			["Romanian",               "ro",    "Româna",               "  ",  "0418"],  _
		    ["Russian",                "ru",    "Russkiy Yazyk",        "  ",  "0419"],  _
			["Serbian",                "sr",    "Srpski",               "1a"         ],  _
			["Slovenian",              "sl",    "Slovene",              "  ",  "0424"],  _
		    ["Spanish",                "es",    "Español",              "0a"         ],  _
		    ["Swedish",                "sv",    "Svenska",              "1d"         ],  _
		    ["Turkish",                "tr",    "Türkçe",               "  ",  "041f"],  _
		    ["Ukranian",               "uk",    "Ukrajinska",           "  ",  "0422"],  _
			["Vietnamese",             "vi",    "Viet",                 "  ",  "042a"],  _
			["** Unsupported **",      "en",    "English"]]

Global $hotkeyarray [38] [2] = _
		   [["no"], ["a"], ["b"], ["d"], ["f"], ["g"], ["h"], ["i"], ["j"], ["k"], ["l"], ["m"], ["n"], ["o"], ["p"], _
		    ["q"],  ["r"], ["s"], ["t"], ["u"], ["v"], ["w"], ["x"], ["y"], ["z"],                                    _
			["0"],  ["1"], ["2"], ["3"], ["4"], ["5"], ["6"], ["7"], ["8"], ["9"],                                    _
			["backspace"], ["delete"],   ["tab"]]




