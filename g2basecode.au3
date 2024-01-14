Opt ("TrayIconDebug", 1)                   ; 1=debug line number
If @Compiled Then Opt ("TrayIconHide", 1)  ; Get rid of the AutoIt tray icon
#include-once
#include <Date.au3>
#include <Misc.au3>
#include <File.au3>
#include <Array.au3>
#include <FTPEx.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <GuiButton.au3>
#include <GuiListBox.au3>
#include <GuiScrollBars.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <InetConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIFiles.au3>
#include <WinAPIGdi.au3>
#include <WinAPIGdiDC.au3>
#include <WinAPILocale.au3>
#include <UpDownConstants.au3>
#include <ProgressConstants.au3>

#include <basic.settings.txt>
#include <xxSpecialFunctions.au3>

Const  $masterstring      = "grub2"
Const  $mbontop           = 0x040000
Const  $mberrorok         = $mbontop  + $MB_ICONERROR
Const  $mbwarnok          = $mbontop  + $MB_ICONWARNING
Const  $mbwarnyesno       = $mbontop  + $MB_ICONWARNING     + $MB_YESNO
Const  $mbwarnokcan       = $mbontop  + $MB_ICONWARNING     + $MB_OKCANCEL
Const  $mbwarnretrycan    = $mbontop  + $MB_ICONWARNING     + $MB_RETRYCANCEL
Const  $mbquestyesno      = $mbontop  + $MB_ICONQUESTION    + $MB_YESNO
Const  $mbinfook          = $mbontop  + $MB_ICONINFORMATION
Const  $mbinfookcan       = $mbontop  + $MB_ICONINFORMATION + $MB_OKCANCEL
Const  $mbinfoyesno       = $mbontop  + $MB_ICONINFORMATION + $MB_YESNO
Const  $mbinfoyesnocan    = $mbontop  + $MB_ICONINFORMATION + $MB_YESNOCANCEL
Const  $guihideit         = $GUI_HIDE + $GUI_DISABLE
Const  $guishowit         = $GUI_SHOW + $GUI_ENABLE
Const  $guishowdis        = $GUI_SHOW + $GUI_DISABLE
Const  $regkeysysinfo     = "HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS"
Const  $regkeysecure      = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Secureboot\State"
Const  $regkeyemail       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\IdentityCRL\UserExtendedProperties"
Const  $reguninstall      = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Grub2Win"
Const  $regbiosdate       = RegRead ($regkeysysinfo, "BIOSReleaseDate")
Const  $regtesting        = RegRead ("HKEY_CURRENT_CONFIG\My Stuff\Grub2Win", "TestingStatus")
Const  $masterdrive       = BaseCodeGetMasterDrive ()
Const  $workdir           = @AppDataCommonDir & "\Grub2Win"
Const  $masterpath        = $masterdrive      & "\" & $masterstring
Const  $starttimetick     = _TimeToTicks   (@HOUR, @MIN, @SEC) + @MSEC
Const  $stamptemp         = StringTrimLeft (@YEAR, 2) & @MON & @MDAY & @HOUR & @MIN & @SEC & StringLeft (@MSEC, 2)
Const  $windowstempgrub   = $workdir & "\" & @ScriptName & "." & $stamptemp
DirCreate                 ($windowstempgrub)
Const  $dateformat        = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, $LOCALE_SSHORTDATE)
Const  $xpstring          = "Windows XP"
Const  $mywhite           = 0xFFFFFF ; White       RGB
Const  $myblack           = 0x000000 ; Black       RGB
Const  $myred             = 0xFF0000 ; Red         RGB
Const  $myyellow          = 0xFFFF00 ; Yellow      RGB
Const  $mygreen           = 0x13AA3A ; Green       RGB
Const  $myblue            = 0x95DDFF ; Blue        RGB
Const  $mymedblue         = 0x58A6D6 ; Medium Blue RGB
Const  $mypurple          = 0xCC00CC ; Purple      RGB
Const  $myorange          = 0xFF7710 ; Orange      RGB
Const  $mylightgray       = 0xEEEEEE ; Light  Gray RGB
Const  $mymedgray         = 0x777777 ; Medium Gray RGB
Const  $kilo              = 2     ^ 10  ; 1024
Const  $mega              = $kilo ^  2  ; 1,048,576
Const  $giga              = $kilo ^  3  ; 1,073,741,824
Const  $tera              = 10    ^ 12  ; 1,000,000,000,000   Decimal by convention
Const  $firmcutdate       = @YEAR - 6
Const  $downloadexpdays   = 30
Const  $oldreleasecutoff  = 2209
Const  $maxosbuild        = 22631
Const  $highnumber        = 10 ^ 10
Const  $winbootoff        = 999999999  ; Timeout of 31 years
Const  $shortbootoff      = 9999999    ; Timeout of 151 days for XP
Const  $julearly		  = 2451545    ; January 1, 2000

Const  $parmadvanced      = "Advanced"
Const  $parmautoinstall   = "AutoInstall"
Const  $parmautoresdir    = "AutoResDir"
Const  $parmbcdtest       = "BCDTest"
Const  $parmcleanupdir    = "CleanupDir"
Const  $parmcodeonly      = "CodeOnly"
Const  $parmdrive         = "Drive"
Const  $parmefiaccess     = "EFIAccess"
Const  $parmfromupdate    = "FromUpdate"
Const  $parmhelp          = "ParmHelp"
Const  $parmlowresmode    = "LowResMode"
Const  $parmquiet         = "Quiet"
Const  $parmreboot        = "ReBoot"
Const  $parmrefreshefi    = "RefreshEFI"
Const  $parmsetup         = "Setup"
Const  $parmshortcut      = "Shortcut"
Const  $parmuninstall     = "UnInstall"

Const  $unknown           = "Unknown"
Const  $configstring      = "grub.cfg"
Const  $autostring        = "** Auto **"
Const  $bootmandir        = "g2bootmgr"
Const  $exestring         = "grub2win.exe"
Const  $syntaxorigname    = "syntax.orig.txt"
Const  $filesuffixin      = ".in.txt"
Const  $filesuffixout     = ".out.txt"
Const  $backupdelim       = "<g2b>"
Const  $setuplogstring    = "\grub2win.setup.log.txt"
Const  $settingsstring    = "\windata\storage\settings.txt"
Const  $foundstring       = "Grub2Win-Found"
Const  $helptitle         = "Grub2Win User Manual"
Const  $lastbooted        = "** Last Booted OS **"
Const  $modewinauto       = "Windows Automatic"
Const  $modepartlabel     = "Partition Label"
Const  $modepartuuid      = "Partition UUID"
Const  $modehardaddress   = "Hard Address (Unreliable)"
Const  $modeandroidfile   = "Android Kernel File"
Const  $modephoenixfile   = "Phoenix Kernel File"
Const  $modewinefi        = "Windows EFI Boot Manager"
Const  $modechainfile     = "Chainloading A File"
Const  $modechaindisk     = "Chainloading A BIOS Disk"
Const  $modecustom        = "Custom Code"
Const  $nullparm          = "NullParm"
Const  $modeuser          = "Unsupported User Defined Code"
Const  $modeno            = "No"
Const  $partnotselected   = "** Not Selected **"
Const  $partnotfound      = "**-Not-Found-**"
Const  $partnotavail      = "** No Linux Partitions Available **"
Const  $typechaindisk     = "chainload a disk"
Const  $typechainfile     =	"chainload a file"
Const  $typecustom        =	"custom code"
Const  $typeotherlin      =	"other linux **"
Const  $typeuser          =	"create user section"
Const  $typeimport        =	"import linux config"
Const  $custworkstring    = "--grubwork--.cfg"
Const  $layoutrootonly    = "Root Partition Only"
Const  $layoutboth        = "Root and Boot Partitions"
Const  $layoutstring      = "|" & $layoutrootonly & "|" & $layoutboth
Const  $selnewfile        = "Select" & @CR & "A New" & @CR ; & "Kernel File"
Const  $selisofile        = "Select ISO File"
Const  $biosdesc          = "Grub 2 For Windows"
Const  $currentstring     = "**Current**"
Const  $myemail           = "drummerdp@users.sourceforge.net"
Const  $sysmemorybytes    = MemGetStats () [1] * $kilo
Const  $sysmemorygb       = Int (($sysmemorybytes / $giga) + 0.999) & " GB"
Const  $bootmanid         = "{9dea862c-5cdd-4e70-acc1-f32b344d4795}"
Const  $firmmanid         = "{a5a30fa2-3d06-4e9f-b5f4-a01df9d1fcba}"
Const  $firmmanstring     = "firm-bootmgr"
Const  $bootmanstring     = "bootmgr"
Const  $wmisvc            = ObjGet     ("winmgmts:\\" & @ComputerName & "\root\cimv2")
Const  $runpath           = StringLeft (@ScriptDir, 9) & "\"
Const  $windowsdrive      = EnvGet     ("SystemDrive")
Const  $efibootstring     = "/efi/"
Const  $cloverbootfile    = $efibootstring   & "CLOVER/CLOVERX64.efi"
Const  $useridorig        = @UserName
Const  $graphsize         = @DesktopWidth    & "x" & @DesktopHeight
Const  $cleanupbat        = @TempDir         & "\Cleanup.Grub2Win." & $stamptemp  & ".bat"
Const  $enqueuefile		  = $workdir         & "\Enqueue.Grub2Win." & @ScriptName & ".txt"
Const  $enqueuegeneric	  = $workdir         & "\Enqueue.Grub2Win.*.*"
Const  $extracttempdir    = $workdir         & "\grub2win.ExtractTemp." & $stamptemp
Const  $templogfile       = $windowstempgrub & "\temp.log"
Const  $uninstfile        = @TempDir         & "\xxgrubdelete.txt"
Const  $commandtemppath   = $windowstempgrub & "\commands"
Const  $statsdatastring   = $workdir         & "\stats.grub2win."
Const  $statsdatageneric  = $statsdatastring & "*.*"
Const  $bcdprefix         = $commandtemppath & "\bcd."
Const  $zipmodule         = "zip7za.runtime"
Const  $licensewarn       = "LicenseWarning.txt"
Const  $graphautostandard = "1600x1200,1280x1024,1152x864,1024x768,800x600,auto"
Const  $graphnotset       = "not set"
Const  $hotkeyalpha       = "|no|a|b|d|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|w|x|y|z"
Const  $hotkeystring      = $hotkeyalpha & "|0|1|2|3|4|5|6|7|8|9|backspace|delete|tab|"
Const  $nothemedesc       = "** No Theme - Text Only **"
Const  $notheme           = "notheme"
Const  $noface            = "** No Clock Face **"
Const  $ticksonly         = "** Clock Ticks Only **"
Const  $langspacer        = "  -  "
Const  $bcddashline       = "-----"
Const  $langenglish       = "English"
Const  $langdefcode       = "en"
Const  $winbootmgr        = "bootmgfw.efi"
Const  $winloaderefi      = "winload.efi"
Const  $shortcutfile      = @DesktopDir        & "\Grub2Win.lnk"
Const  $winshortcut       = @ProgramsCommonDir & "\Grub2Win.lnk"
Const  $customcodestart   = "# start-grub2win-custom-code"
Const  $customcodeend     = "# end-grub2win-custom-code"
Const  $usersectionstart  = "# start-grub2win-user-section   " & _StringRepeat("*", 56)
Const  $usersectionend    = "# end-grub2win-user-section     " & _StringRepeat("*", 56)
Const  $customsourcerec   = "source $prefix/windata/customconfigs/"
Const  $customfilestring  = "CustomFileString="
Const  $androidbootpath   = "/android-9.0-r2/kernel"
Const  $phoenixbootpath   = "/PhoenixOS/kernel"
Const  $chainbootpath     = "/efi"
Const  $parmnvidia        = "nouveau.modeset=1 i915.modeset=0"
Const  $poscurrname       = "POSROGV3U8.cfg"
Const  $statslogstring    = "\statslog.grub2win.txt"
Const  $downloadjulian    = $workdir & "\grub2win.download.julian.txt"
Const  $encryptstring     = "\encryption.status.txt"
Const  $efibootdir        = "\EFI\Boot\"
Const  $bootmanefi32      = "gnugrub.kernel32.efi"
Const  $bootmanefi64      = "gnugrub.kernel64.efi"
Const  $bootloaderbios    = "gnugrub.kernel.bios"
Const  $notepadexec       = "notepad.exe"
Const  $biosbootstring    = $masterstring    & "\" & $bootmandir & "\" & $bootloaderbios
Const  $efitargetstring   = "\efi\grub2win"
Const  $efibootmanstring  = $efitargetstring & "\g2bootmgr"
Const  $efidescwindows    = "Windows EFI Boot Manager"
Const  $efipathwindows    = '\efi\microsoft\boot\bootmgfw.efi'
Const  $xpstubsource      = "gnugrub.stub.xp"
Const  $xptargetstub      = "g2wxpstub"
Const  $xptargetload      = "g2wxp"
Const  $xptargetini       = "boot.ini"
Const  $xpstubfile        = $windowsdrive & "\" & $xptargetstub
Const  $xploadfile        = $windowsdrive & "\" & $xptargetload
Const  $xpinifile         = $windowsdrive & "\" & $xptargetini
Const  $templateuser      = "\template.user.cfg"
Const  $templatesetparms  = "\template.setparms.cfg"
Const  $templatewinauto   = "\template.windowsauto.cfg"
Const  $templateclover    = "\template.clover.cfg"
Const  $templateinvaders  = "\template.invaders.cfg"
Const  $templatetheme     = "\template.theme.cfg"
Const  $templateempty     = "\template.empty.cfg"
Const  $templategfxmenu   = "\template.gfxmenu.cfg"
Const  $licensed          = "Licensed"
Const  $callermain        = "Main"
Const  $rebootstring      = "Reboot"
Const  $firmwarestring    = "Firmware Order"
Const  $envparmreboot     = "grub2win_reboot"
Const  $envgfxmode        = "grub2win_gfxmode"
Const  $fileloaddisable   = "** disable fileloadcheck **"
Const  $statusnew         = "NewUser"
Const  $statuscurr        = "CurrUser"
Const  $statusobsolete    = "ObsoleteUser"
Const  $efivalid          = "EFI"
Const  $efiignorefs       = "** Ignored EFI FS **"
Const  $efiignoremedia    = "** Ignored EFI Media **"
Const  $efiignorelimit    = "** Ignored Extra EFI **"
Const  $invalchardisp     = '\  /  :  *  $  ?  &&  "  >  <  |  }  {' & "  '"
Const  $invalchar         = '[\' & StringReplace ($invalchardisp, " ", "") & ']'
Const  $vowelchar         = "[a e i o u]"

Const  $selectionfieldcount = 30
Const  $sEntryTitle       =  1, $sOSType          =  2, $sClass           =  3, $sLoadBy          =  4, $sRootDisk        =  5
Const  $sRootFileSystem   =  6, $sBootDisk        =  7, $sBootFileSystem  =  8, $sLayout          =  9, $sRootSearchArg   = 10
Const  $sChainDrive       = 11, $sSortSeq         = 12, $sFamily          = 13, $sBootParm        = 14, $sGraphMode       = 15
Const  $sUpdateFlag       = 16, $sHotKey          = 17, $sReviewPause     = 18, $sIcon            = 19, $sDiskError       = 20
Const  $sMouseUpDown      = 21, $sNvidia          = 22, $sDefaultOS       = 23, $sReboot          = 24, $sSampleLoadby    = 25
Const  $sAutoUser         = 26, $sCustomName      = 27, $sFileLoadCheck   = 28, $sKernelName      = 29, $sInitrdName      = 30

Const  $bcdfieldcount     = 10
Const  $bOrderType        =  0, $bItemType   =  1, $bItemTitle     =  2, $bGUID        =  3, $bDrive      =  4, $bPath =  5   ; Array subscripts
Const  $bSortSeq          =  6, $bUpdateFlag =  7, $bItemTitlePrev =  8, $bMouseUpDown =  9, $bUpdateHold = 10

Const  $gIPAddress         = 0, $gCountry = 1,  $gRegion  = 2, $gCity  = 3

Const  $pType = 0, $pClass = 1, $pFamily  = 2, $pFirmMode = 3, $pTitle =  4, $pBootParms = 5, $pUtilCommand = 6, $pHoldParms = 7, $parmsfieldcount = 8

Const  $iPath = 0, $iVersion = 1, $iBuild = 2, $iStatus = 3, $iStamp = 4, $iJul = 5, $iDate = 6, $iTime = 7

Const  $updatechangelog = $windowstempgrub & "\changelog.txt"
Const  $updatenever     = "** Never **"
Const  $updatedefault   = "30 Days"
Const  $updateversion   = "You are running Grub2Win version " & $basrelcurr
Const  $updateconnmsg   = @CR & "Please Check The SourceForge Site Status, Your Firewall Software"

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
	["windows",      "windows",       "windows",        "All",  "Windows EFI Boot Manager",       ""]]

Const  $efiguid     = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
Const  $dynmetaguid = "5808C8AA-7E8F-42E0-85D2-E1E90434CFB3"

Const  $tGUID = 0, $tCode = 1, $tDesc = 2, $tFamily = 3, $tFileSystem = 4, $tFieldCount = 5

Const  $parttypearray [30] [$tFieldCount] = [ _
		["",                                      "",   "Unknown Filesystem",     "Misc",     ""],     _
		["",                                      "",   "Apple Filesystem",       "Apple",    "Misc"], _
		[$efiguid,                                "EF", "EFI Partition",          "EFI",      ""],     _
		["EBD0A0A2-B9E5-4433-87C0-68B6B72699C7",  "07", "Data",                   "Windows",  ""],     _
		[$dynmetaguid,                            "",   "LDM Meta - Unsupported", "Dynamic",  ""],     _
		["AF9B60A0-1431-4F62-BC68-3311714A69AD",  "",   "LDM Data - Unsupported", "Misc",     ""],     _
		["E3C9E316-0B5C-4DB8-817D-F92DF00215AE",  "73", "Microsoft Reserved",     "Reserved", ""],     _
		["DE94BBA4-06D1-4D40-A16A-BFD50179D6AC",  "27", "Windows Recovery",       "System",   ""],     _
		["21686148-6449-6E6F-744E-656564454649",  "",   "BIOS/GPT Boot",          "System",   ""],     _
		["0FC63DAF-8483-4772-8E79-3D69D8477DE4",  "83", "Linux Filesystem",       "Linux",    ""],     _
		["E6D6D379-F507-44C2-A23C-238F2A3DF928",  "8E", "Linux Logical Volume",   "Linux",    ""],     _
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

Const  $actioninstall     = "Install GNU Grub EFI Modules"
Const  $actionuninstall   = "Uninstall"
Const  $actionrefresh     = "Refresh GNU Grub EFI Modules"
Const  $actiondelete      = "Delete  GNU Grub EFI Modules"
Const  $actionbackup      = "Back Up The EFI Partition Files"
Const  $actionrestore     = "Restore The EFI Partition Files"
Const  $actioncloverinst  = "Install Clover EFI Modules"
Const  $actioncloverrefr  = "Refresh Clover EFI Modules"
Const  $actioncloverdel   = "Delete Clover EFI Modules"
Const  $actionskip        = "Skip Partition - No EFI Directory"
Const  $actionno          = "No Action"
Const  $runpartops        = "EFI Partition Operations"

Global $defaultos         = 0
Global $templogarray      [0]
Global $zuluiparray       [4]
Global $dialogpathhold    = "C:\"
Global $defaultlastbooted = "no"
Global $statslog          = $workdir & $statslogstring
Global $langfullselector  = $langenglish
Global $scalehsize, $scalevsize, $scalepcthorz, $scalepctvert, $graphconfigauto, $graphstring
Global $graphmessage, $fontsizenormal, $fontsizesmall, $fontsizemedium, $fontsizelarge
Global $loadtime, $scantime, $bypassmsg, $statsdatafile
Global $progexistinfo, $progexistversion, $progruninfo, $progrunversion, $securesuffix
Global $bcdallarray, $bcdfirstrun, $bcderrorfound, $prevgrubinfo
Global $bcdtimetotal, $bcdtimecount, $bcdtimestatus, $refreshdiff
Global $parmarraywork, $parmstringwork, $parmstringinbox, $parmlog, $parmsdisplay
Global $statuszulu, $statusgeo, $geoarray, $geoipaddress, $geocountry, $georegion, $geocity, $geototalretrys
Global $duprunstatus, $zippath, $dummy, $settingspath, $basictargetdrive
Global $parmvalue,    $upmessgstart, $upmessgmindelay, $upmesstexthandle1, $upmesstexthandle2, $genstampdisp
Global $winbootdisk,  $winbootpart,  $upmessguihandle, $setupinprogress,   $setuphandlelist, $flashbuttonlast
Global $setuperror, $securediagcode, $securediaginfo, $securestats, $licmsgarray, $licmsginc
Global $setupvaluecleanupdir, $setupexeinfo, $setupmodlist, $borderpichandle
Global $nyjulian, $nyhour, $zulutimeline, $zulutimeus, $loctimeline, $altoffsethours, $altoffsetmins
Global $localhour, $localmin, $localsec, $localjul
Global $geotimezone, $geotimeoffset, $timezonedisplay, $timeoffhours, $timeoffmins, $nytimeus, $nytimefulljul, $nytimestamp
Global $mainhelphandle, $mainresthandle, $mainsynhandle, $mainupdhandle, $buttonreboot, $selectionhelphandle, $edithelphandle
Global $configarray, $userarray, $selectionarraysize, $handlelastbooted, $iconhelphandle, $mainloghandle, $mainlogcount, $miscarray
Global $handleselectiongui, $handleselectiondel, $handleselectionscroll, $handleselectionbox
Global $selectionarray, $selectionholdarray, $selectionholdlastbooted, $handleusergroup
Global $selectionautohigh, $selectionautocount, $selectionusercount
Global $upmesstexthandle1, $upmesstexthandle2, $bcdwinmenuhold, $importtype
Global $bcdarray, $bcdnewid, $bcdwinorder, $bcdwinorderflag, $backuptrigger, $backupcomplete
Global $bcdwindisplayorig, $bcdcleanuparray, $screenpicturehandle, $screenshothandle, $screenpreviewhandle
Global $handlemaingui, $buttondefault, $bcdorderarray, $efiutilmsg
Global $buttonok, $buttonselection, $buttoncancel, $buttonrunefi, $buttonsetorder, $buttondiag
Global $promptg, $promptl, $promptt, $promptd, $promptbt, $parmstripped, $sysinfomessage, $sysinfotitle
Global $arrowbt, $updownbt, $arrowgt, $updowngt, $timeoutgrub, $timeoutwin
Global $handlewintimeout, $labelbt2, $labelgt1
Global $checkshortcut, $buttonpartlist, $buttonsysinfo, $autohighsub, $dummyparm
Global $grubcfgefilevel, $timeoutok, $timegrubenabled, $timewinenabled, $partscanned
Global $warnhandle, $genline, $typestring, $typestringcust, $windowstypecount, $syslineos, $syslinesecure
Global $defaulthandle, $defaultstring, $defaultset, $defaultselect
Global $graphhandle, $graphset, $usergraphset, $diagcomplete, $kernelwarn
Global $origgraphset, $origdefault, $origlangset
Global $bcdprevtime, $progvermessage, $headermessage, $focushandle, $focushandlelast
Global $esctype, $osfound, $oswarned, $cloverfound, $cloverload, $firmmoderc, $firmcancel
Global $selectionstatus, $handleselectionup, $handleselectiondown, $buttonimportlinux, $buttonimportchrome
Global $handleselectiondefault, $buttonselectioncancel, $buttonselectionadd, $buttonselectionapply, $buttonselectionremove
Global $edithandlegui, $editbuttoncancel, $editholdarray, $editlimit, $selectionlimit, $selectionentrycount, $selectionmisccount
Global $edithandletitle, $edithandletype, $editbuttonok, $edithandleentry, $editpictureicon, $edithandlefix
Global $edittype, $editpromptchaindrv, $edithandlechaindrv, $editupdownchaindrv, $editdupmessage
Global $editpromptdiskr, $editpromptdiskb, $edithandlediskr, $edithandlewarn
Global $editpromptparm, $edithandleparm, $editsearchok, $editsearchfilled, $editpromptsrchr, $editbootroot, $editpromptsrchl
Global $edithandlediskb, $editbuttonstand, $editmessageparm, $editholdentry, $editnewentry
Global $edithandlesrchr, $edithandleselfile, $edithandleseliso, $editpromptgraph, $edithandlegraph, $edithandlefilea
Global $edithandlesrchl, $linuxpartarray, $editlinpartcount, $editlinuuidcount, $editlinlabelcount, $editlinwarned, $editmenuerrors
Global $edithandlepause, $edithandlechknv, $editprompticon, $edithandledevice, $editpartselected
Global $editbuttonapply, $editerrorok, $editparmok, $editparmlength, $edittitleok
Global $edithandlewinset, $edithandlewininst, $edithandlewintitle, $edithandlehotkey, $edithotkeywork
Global $editlistcustedit, $editpromptcust, $editpromptsample
Global $editpromptloadby, $edithandleloadby, $edithandleloadlab, $editpromptlayout, $edithandlelayout
Global $handleordergui, $handleorderup, $handleorderdown, $handleorderbottom
Global $handleorderscroll, $buttonorderreturn, $buttonorderapply, $buttonordercancel, $orderhelphandle
Global $orderfirmdisplay, $scrolltoppos, $scrollforcebottom, $scrollmaxvsize, $orderefiforce, $orderdefaultwin, $orderdefaultgrub
Global $orderbootman, $ordercurrentstring, $ordercurrbootpath
Global $parsearray, $parseposition, $parseresult1, $parseresult2, $parseresult3, $autoarray
Global $iconhandlegui, $iconhandlescroll, $iconbuttoncancel, $iconhold, $iconbuttonapply, $iconarray
Global $eficonfguihandle, $efimodemixed, $eficfgbefore, $eficancelled, $efideleted, $efiforceload
Global $efierrorsfound, $efiexit, $efimilsec, $efileveldeployed, $efidefaulttype, $efidefaultfix
Global $utillogfilehandle, $utillogtxthandle, $utillogct, $utilloglines, $utillogclosehandle, $utillogreturnhandle, $utillogguihandle
Global $utilreporthandle, $diagnosemiscarray, $diagerrorcode, $biosprevfound, $updatearray
Global $xpiniarray, $xpinbackiarray, $xpiniprevtime, $xpiniprevitem, $xpinibackedup, $xpoldrelarray, $xpinibootstring, $xpoldfound
Global $langcomboarray, $langcombo, $langheader, $langhandle, $langselectedcode, $langauto, $langautostring
Global $langfound, $langline1, $langline2, $langline3, $langline4
Global $handlegrubtimeout, $controlhorizhold, $gfxmode, $securebootwarned
Global $custparsearray, $setupstatus, $setuprefreshefi, $setuplogfile, $encryptionstatus
Global $setuphandlegui, $setupbuttoncancel, $setupbuttoninstall, $setupbuttonhelp, $setuphandlerun
Global $setupdisableprm, $setuphelploc, $setupdownload, $setuphandledel
Global $setuphandledrive, $setuptargetdriveold, $setuphandleshort, $setupolddir, $setuptempdir
Global $setuphandleefimsg, $setupmbrequired, $setupvalueautoresdir
Global $setuphandlelabel, $setuphandleprompt, $setupvaluedrive, $setupvalueshort
Global $setuptargetdir, $setuptargetstore, $setupbuttonclose, $setuphandlewarn, $setupbuttonconfirm
Global $buttonthemehelp, $handlethemecenter, $handlethemedark, $handlethemescroll, $handlethemeshot, $handlethemeface, $handlethemetime
Global $buttonthemeok, $themetempoptarray, $handlethemevers, $handlethememode, $handlethemestyle, $handlethemelines, $handlethemelabs
Global $handlethemesecs, $handlethemeseclab, $handlethemesecud, $handlethemelab1, $handlethemedesc, $handlethemepic, $themedefarray
Global $buttonthemereset, $themeoptarray, $themecenterstart, $themecentersize, $handlethemegui, $handlethemehilite, $buttonthemecancel
Global $buttonthemecolgrp, $buttonthemecoltit, $buttonthemecolsel, $buttonthemecoltxt, $buttonthemecolclk, $themematrixarray
Global $themeselecthandleadd, $themeselecthandlescroll, $themeselecthandlegui, $themeselecthandledone, $themeselectarray, $themeselectcurrsub
Global $brushtitle, $brushselect, $brushtext, $brushclock, $usercopied, $envarray, $envchanged, $themematrixarray
Global $gdicontextin, $gdihandlein, $gdiformat, $gdifontfam, $gdifont, $gdilayout, $gdimeasure
Global $updatehandlegui, $updatebuttoncancel, $updatehandledown, $updatehandleview, $updatehandlevisit, $updatehandlemsg
Global $updatehandleclose, $upautohandle, $updatehandlecheck, $updatehandleremind, $updatehandlefreq, $updatehandlerefresh
Global $updatehandleok, $updatehandlehelp, $updatehandlenext, $updatenewbuild, $forcecleaninstall, $latestsetup
Global $gendatedisp, $gendatetime, $gendatefull, $gendatejul, $gendateage
Global $handleimportgui, $handleimportscroll, $handleimportbottom, $buttonimport, $buttonimportcancel, $importhelphandle
Global $handleimportcheck, $importarray, $importstatus, $importcode, $importfilepath, $importfedorakernel
Global $partitionarray, $partscanbuffer, $partdisknumber, $partdiskhandle
Global $partdumppath,   $partlistfile,   $partlistlffile, $partsectorsize, $useridformat
Global $masterlogfile, $datapath, $storagepath,	$settingspath, $configfile, $masterexe, $sourcepath, $themepath
Global $bootmanpath, $envfile, $userfiles, $diagpath, $userbackgrounds, $userclockfaces, $usericons, $usericonscheck, $userfonts
Global $usermiscfiles, $usermiscimport, $usersectionfile, $usersectionexp, $usergfxmodefile, $usergfxcmdfile, $usersectionorig
Global $custconfigs, $custconfigstemp, $systemdatafile, $systempartfile, $backuppath, $backupmain, $backupefipart
Global $winefiletter, $winefistatus, $winefiuuid, $efiassignlogarray, $backuplogs, $backupbcds, $backupcustom, $updatedatapath
Global $commandpath, $bcdcleanuplog, $bcddiaginlog, $efilogfile, $syntaxorigfile, $customworkfile, $sysinfotempfile
Global $utillogfile, $themebackgrounds, $themetempback,	$iconpath, $fontpath, $themeconfig, $screenshotfile, $themecustopt
Global $themecustback, $themestandpath, $themelocalpath, $themecommon, $thememasterpath, $themefaces, $themecolorsource
Global $themecolorcustom, $themestatic,	$themeempty, $themedeffile, $themetemplate,	$themetemp,	$themetempfiles, $themetemplocal
Global $themetempcust, $samplecustcode, $sampleisocode,$samplesubcode, $uninstinfo
Global $partcountwin,  $partcountlinux, $partcountapple, $partcountother, $partcountbsd
Global $partcountdisk, $partcountmbr,   $partcountgpt,   $partcountpart,  $partcountefi
Global $partcountswap, $partcountflash, $drivecountcd, $installstatus, $installmessage

Func BaseCodeGetMasterDrive ()
	$mddrive = "C:"
	$mdloc   = RegRead ($reguninstall, "InstallLocation")
	If Not @error Then
		$mdfind = StringLeft ($mdloc, 2)
		If FileExists ($mdfind & "\" & $masterstring) Then $mddrive = $mdfind
	EndIf
	Return $mddrive
EndFunc