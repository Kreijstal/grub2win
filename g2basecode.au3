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

#include <g2arrays.au3>
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
Const  $workdir           = BaseCodeGetWorkDir     ()
Const  $masterpath        = $masterdrive      & "\" & $masterstring
Const  $todayjul          = Int (_DateToDayValue (@YEAR, @MON, @MDAY)) + 1
Const  $starttimetick     = _TimeToTicks         (@HOUR, @MIN, @SEC) + @MSEC
Const  $stamptemp         = StringTrimLeft       (@YEAR, 2) & @MON & @MDAY & @HOUR & @MIN & @SEC & StringLeft (@MSEC, 2)
Const  $windowstempgrub   = $workdir & "\" &      @ScriptName & "." & $stamptemp
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
Const  $maxosbuild        = 26100
Const  $highnumber        = 10 ^ 10
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
Const  $textstring        = "** Text **"
Const  $bootmandir        = "g2bootmgr"
Const  $exestring         = "grub2win.exe"
Const  $syntaxorigname    = "syntax.orig.txt"
Const  $filesuffixin      = ".in.txt"
Const  $filesuffixout     = ".out.txt"
Const  $backupdelim       = "<g2b>"
Const  $setuplogstring    = "\grub2win.setup.log.txt"
Const  $extractlogstring  = "\grub2win.extract.log.txt"
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
Const  $custworkstring    = "--grubwork--.cfg"
Const  $layoutrootonly    = "Root Partition Only"
Const  $layoutboth        = "Root and Boot Partitions"
Const  $layoutstring      = "|" & $layoutrootonly & "|" & $layoutboth
Const  $selnewfile        = "Select" & @CR & "A New" & @CR ; & "Kernel File"
Const  $selisofile        = "Select ISO File"
Const  $currentstring     = "**Current**"
Const  $edemail           = "edphere@users.sourceforge.net"
Const  $sysmemorybytes    = MemGetStats () [1] * $kilo
Const  $sysmemorygb       = Int (($sysmemorybytes / $giga) + 0.999) & " GB"
Const  $bootmanid         = "{9dea862c-5cdd-4e70-acc1-f32b344d4795}"
Const  $firmmanid         = "{a5a30fa2-3d06-4e9f-b5f4-a01df9d1fcba}"
Const  $firmmanstring     = "firm-bootmgr"
Const  $wmisvc            = ObjGet     ("winmgmts:\\" & @ComputerName & "\root\cimv2")
Const  $runpath           = StringLeft (@ScriptDir, 9) & "\"
Const  $windowsdrive      = EnvGet     ("SystemDrive")
Const  $efibootstring     = "/efi/"
Const  $bootmanstring     = "bootmgr"
Const  $cloverbootfile    = $efibootstring   & "CLOVER/CLOVERX64.efi"
Const  $useridorig        = @UserName
Const  $graphsize         = @DesktopWidth    & "x" & @DesktopHeight
Const  $cleanupbat        = $workdir         & "\Cleanup.Grub2Win." & $stamptemp  & ".bat"
Const  $enqueuefile		  = $workdir         & "\Enqueue.Grub2Win." & @ScriptName & ".txt"
Const  $enqueuegeneric	  = $workdir         & "\Enqueue.Grub2Win.*.*"
Const  $extracttempdir    = $workdir         & "\grub2win.ExtractTemp." & $stamptemp
Const  $templogfile       = $windowstempgrub & "\temp.log"
Const  $commandtemppath   = $windowstempgrub & "\commands"
Const  $statsdatastring   = $workdir         & "\stats.grub2win."
Const  $statsdatageneric  = $statsdatastring & "*.*"
Const  $bcdprefix         = $commandtemppath & "\bcd."
Const  $zipmodule         = "zip7za.runtime"
Const  $licensewarn       = "LicenseWarning.txt"
Const  $graphautostandard = "1600x1200,1280x1024,1152x864,1024x768,auto"
Const  $graphnotset       = "not set"
Const  $fontunicode       = "Unifont" & _StringRepeat (" ", 25) & "16"
Const  $nowallpaperdesc   = "** No Wallpaper - Text Only **"
Const  $nowallpaper       = "nowallpaper"
Const  $noface            = "** No Clock Face **"
Const  $ticksonly         = "** Clock Ticks Only **"
Const  $langspacer        = "  -  "
Const  $bcddashline       = "-----"
Const  $langenglish       = "English"
Const  $langdefcode       = "en"
Const  $winbootmgr        = "bootmgfw.efi"
Const  $winloaderefi      = "winload.efi"
Const  $winloaderbios     = "winload.exe"
Const  $shortcutfile      = @DesktopDir        & "\Grub2Win.lnk"
Const  $winshortcut       = @ProgramsCommonDir & "\Grub2Win.lnk"
Const  $automenustart     = "start-grub2win-auto-menu-section"
Const  $automenuend       = "end-grub2win-auto-menu-section"
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
Const  $encryptstring     = "\encryption.status.txt"
Const  $efibootdir        = "\EFI\Boot\"
Const  $bootmanefi32      = "gnugrub.kernel32.efi"
Const  $bootmanefi64      = "gnugrub.kernel64.efi"
Const  $bootmanagerbios   = "gnugrub.kernel.bios"
Const  $microsoftbios     = "microsoft.bootmgr.bios"
Const  $microsoftxpbios   = "microsoft.ntldr.xp.bios"
Const  $notepadexec       = "notepad.exe"
Const  $efitargetstring   = "\efi\grub2win"
Const  $efibootmanstring  = $efitargetstring & "\g2bootmgr"
Const  $efidescwindows    = "Windows EFI Boot Manager"
Const  $efipathwindows    = '\efi\microsoft\boot\bootmgfw.efi'
Const  $bootmenunoshow    = "Do Not Show The Boot Manager Menu"
Const  $bootmenutext      = "Text Boot Manager Menu"
Const  $bootmenugraph     = "Metro Graphics Boot Manager Menu (Slower)"
Const  $xpmanager         = $windowsdrive & "\ntldr"
Const  $xpstubfile        = $windowsdrive & "\g2wxpstub"
Const  $xploadfile        = $windowsdrive & "\g2wxp"
Const  $xpinifile         = $windowsdrive & "\boot.ini"
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
Const  $fedoraflags       = "rootflags=subvol=root"
Const  $efiignorefs       = "** Ignored EFI FS **"
Const  $efiignoremedia    = "** Ignored EFI Media **"
Const  $efiignorelimit    = "** Ignored Extra EFI **"
Const  $invalchardisp     = '\  /  :  *  $  ?  &&  "  >  <  |  }  {' & "  '"
Const  $invalchar         = '[\' & StringReplace ($invalchardisp, " ", "") & ']'
Const  $vowelchar         = "[a e i o u]"

Const  $updatechangelog = $windowstempgrub & "\changelog.txt"
Const  $updatenever     = "** Never **"
Const  $updatedefault   = "30 Days"
Const  $updateversion   = "You are running Grub2Win version " & $basrelcurr
Const  $updateconnmsg   = @CR & "Please Check The SourceForge Site Status, Your Firewall Software"

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
Global $netlogdesc        = "Grub2Win Network Log"
Global $diagemail         = "drummerdp@users.sourceforge.net"
Global $netlogmode        = $FO_OVERWRITE
Global $statslog          = $workdir & $statslogstring
Global $langfullselector  = $langenglish
Global $ftptimerstart, $ftptimeout, $ftpseconds
Global $nethandlegui, $nethandlecancel, $nethandlebar, $nethandleprogtext
Global $netdownsite, $netsecsave, $nettimer, $netshortlimit, $netfreespace
Global $scalehsize, $scalevsize, $scalepcthorz, $scalepctvert, $graphconfigauto, $graphstring
Global $graphmessage, $fontsizenormal, $fontsizesmall, $fontsizemedium, $fontsizelarge
Global $loadtime, $scantime, $bypassmsg, $statsdatafile
Global $progexistinfo, $progexistversion, $progruninfo, $progrunversion, $securesuffix
Global $bcdallarray, $bcdfirstrun, $bcderrorfound, $prevgrubinfo, $newwindisplayboot, $prevwindisplayboot
Global $prevstatushiber, $prevstatuswinmenu, $newstatushiber, $newstatuswinmenu, $winmenustring
Global $bcdtimetotal, $bcdtimecount, $bcdtimestatus, $refreshdiff
Global $parmarraywork, $parmstringwork, $parmstringinbox, $parmlog, $parmsdisplay
Global $statuszulu, $statusgeo, $geoarray, $geoipaddress, $georawcountry, $geocountry, $georegion, $geocity, $geototalretrys
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
Global $selectionautohigh, $selectionautocount, $selectionusercount, $selectionwinentry
Global $upmesstexthandle1, $upmesstexthandle2, $bcdwinmenuhold, $importtype
Global $bcdarray, $bcdwinorder, $bcdwinorderflag, $backuptrigger, $backupcomplete
Global $bcdwindisplayorig, $bcdcleanuparray, $screenpicturehandle, $screenshothandle, $screenpreviewhandle
Global $handlemaingui, $buttondefault, $bcdorderarray, $efiutilmsg
Global $buttonok, $buttonselection, $buttoncancel, $buttonrunefi, $buttonsetorder, $buttondiag
Global $promptg, $promptl, $promptt, $promptd, $promptbt, $parmstripped, $sysinfomessage, $sysinfotitle
Global $arrowbt, $updownbt, $arrowgt, $updowngt, $timeoutgrub, $timeoutwin, $timeoutwinprev
Global $handlewintimeout, $labelbt2, $labelgt1, $winmenupolicy
Global $checkshortcut, $buttonpartlist, $buttonsysinfo, $autohighsub, $buttonwinopt, $dummyparm
Global $grubcfgefilevel, $timeoutok, $timegrubenabled, $partscanned
Global $warnhandle, $genline, $typestring, $typestringcust, $windowstypecount, $syslineos, $syslinesecure
Global $defaulthandle, $defaultstring, $defaultset, $defaultselect
Global $graphhandle, $graphset, $usergraphset, $diagcomplete, $diagrun, $diagmailcount, $vacationflag, $kernelwarn
Global $origdefault, $origlangset
Global $progvermessage, $headermessage, $focushandle, $focushandlelast
Global $esctype, $osfound, $oswarned, $cloverfound, $cloverload, $firmmoderc, $firmcancel
Global $selectionstatus, $handleselectionup, $handleselectiondown, $buttonimportlinux, $buttonimportchrome
Global $handleselectiondefault, $buttonselectioncancel, $buttonselectionadd, $buttonselectionapply, $buttonselectionremove

Global $edithandlegui, $editholdarray, $editlimit, $selectionlimit, $selectionentrycount, $selectionmisccount
Global $editpictureicon, $edittitlemax
Global $edittype, $editdupmessage
Global $editsearchok, $editsearchfilled, $editbootroot
Global $editholdentry, $editnewentry
Global $linuxpartarray, $editlinpartcount, $editlinuuidcount, $editlinlabelcount, $editlinwarned, $editmenuerrors
Global $editpartselected
Global $editerrorok, $editparmok, $editparmlength, $edittitleok
Global $edithandlewinset, $edithandlewininst, $edithandlewintitle
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
Global $langcomboarray, $langcombo, $langheader, $langhandle, $langselectedcode, $langauto, $langautostring
Global $langfound, $langline1, $langline2, $langline3, $langline4
Global $handlegrubtimeout, $controlhorizhold, $gfxmode, $securebootwarned
Global $custparsearray, $setupstatus, $setuprefreshefi, $setuplogfile, $encryptionstatus
Global $setuphandlegui, $setupbuttoncancel, $setupbuttoninstall, $setupbuttonhelp, $setuphandlerun
Global $setupdisableprm, $setuphelploc, $setupdownload, $setuphandledel, $setupbypass
Global $setuphandledrive, $setuptargetdriveold, $setuphandleshort, $setupolddir, $setuptempdir
Global $setuphandleefimsg, $setupmbrequired, $setupvalueautoresdir
Global $setuphandlelabel, $setuphandleprompt, $setupvaluedrive, $setupvalueshort
Global $setuptargetdir, $setuptargetstore, $setupbuttonclose, $setuphandlewarn, $setupbuttonconfirm
Global $buttonwallpaperhelp, $handlewallpapercenter, $handlewallpaperdark, $handlewallpaperscroll, $handlewallpapershot, $handlewallpaperface, $handlewallpapertime
Global $buttonwallpaperok, $wallpapertempoptarray, $handlewallpapervers, $handlewallpapermode, $handlewallpaperstyle, $handlewallpaperlines, $handlewallpaperlabs
Global $handlewallpapersecs, $handlewallpaperseclab, $handlewallpapersecud, $handlewallpaperlab1, $handlewallpaperdesc, $handlewallpaperpic, $wallpaperdefarray
Global $handlewallpaperfont, $handlefontprompt, $wallpaperfont, $wallpaperfontstring, $wallpaperfontlimit, $wallpaperfontsave, $wallpaperfontauto, $wallpaperautosave
Global $handlewallpaperauto, $buttonwallpaperreset, $wallpaperoptarray, $wallpapercenterstart, $wallpapercentersize, $handlewallpapergui, $handlewallpaperhilite, $buttonwallpapercancel
Global $buttonwallpapercolgrp, $buttonwallpapercoltit, $buttonwallpapercolsel, $buttonwallpapercoltxt, $buttonwallpapercolclk, $wallpapermatrixarray
Global $wallpaperselecthandleadd, $wallpaperselecthandlescroll, $wallpaperselecthandlegui, $wallpaperselecthandledone, $wallpaperselectarray, $wallpaperselectcurrsub
Global $brushtitle, $brushselect, $brushtext, $brushclock, $usercopied, $envarray, $envchanged, $wallpapermatrixarray, $wallpapergraphname
Global $gdicontextin, $gdihandlein, $gdiformat, $gdifontfam, $gdifont, $gdilayout, $gdimeasure
Global $updatehandlegui, $updatebuttoncancel, $updatehandledown, $updatehandleview, $updatehandlevisit, $updatehandlemsg
Global $updatehandleclose, $upautohandle, $updatehandlecheck, $updatehandleremind, $updatehandlefreq, $updatehandlerefresh
Global $updatehandleok, $updatehandlehelp, $updatehandlenext, $changelogarray, $forcecleaninstall, $latestsetup
Global $gendatedisp, $gendatetime, $gendatefull, $gendatejul, $gendateage
Global $handleimportgui, $handleimportscroll, $handleimportbottom, $buttonimport, $buttonimportcancel, $importhelphandle
Global $directdisk, $directpart, $directletter, $directretain
Global $handleimportcheck, $importarray, $importstatus, $importcode, $importfilepath, $importloaderarray
Global $partitionarray, $partscanbuffer, $partdisknumber, $partdiskhandle, $partgptcodes
Global $partdumppath,   $partlistfile,   $partlistlffile, $partsectorsize, $useridformat
Global $masterlogfile, $datapath, $storagepath,	$settingspath, $configfile, $masterexe, $sourcepath, $wallpaperpath
Global $bootmanpath, $envfile, $userfiles, $diagpath, $userbackgrounds, $userclockfaces, $usericons, $usericonscheck, $userthemes
Global $usermiscfiles, $usermiscimport, $usersectionfile, $usersectionexp, $usergfxmodefile, $usersectionorig
Global $custconfigs, $custconfigstemp, $systemdatafile, $systempartfile, $backuppath, $backupmain, $backupefipart
Global $winefiletter, $winefistatus, $winefiuuid, $efiassignlogarray, $backuplogs, $backupbcds, $backupcustom, $updatedatapath
Global $commandpath, $bcdcleanuplog, $bcddiaginlog, $efilogfile, $syntaxorigfile, $customworkfile, $sysinfotempfile
Global $utillogfile, $wallpaperbackgrounds, $wallpapertempback,	$iconpath, $fontpath, $wallpaperconfig, $screenshotfile, $wallpapercustopt
Global $wallpapercustback, $wallpaperstandpath, $wallpaperlocalpath, $wallpapercommon, $wallpapermasterpath, $wallpaperfaces, $wallpapercolorsource
Global $wallpapercolorcustom, $wallpaperstatic,	$wallpaperempty, $wallpaperdeffile, $wallpapertemplate,	$wallpapertemp,	$wallpapertempfiles, $wallpapertemplocal
Global $wallpapertempcust, $samplecustcode, $sampleisocode, $samplesubcode, $uninstinfo
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

Func BaseCodeGetWorkDir ()
	$gwreturn = @AppDataCommonDir & "\Grub2Win"
	If @OSVersion = "WIN_XP" Then $gwreturn = "C:\grub2.work"
	Return $gwreturn
EndFunc

Func BaseCodeEditHandles ()
	Global $editbuttoncancel   = ""
	Global $edithandletitle    = "", $edithandletype     = "", $editbuttonok       = "", $edithandleentry    = "", $edithandlefix = ""
	Global $editpromptchaindrv = "", $edithandlechaindrv = "", $editupdownchaindrv = ""
	Global $editpromptdiskr    = "", $editpromptdiskb    = "", $edithandlediskr    = "", $edithandlewarn     = ""
	Global $editpromptparm     = "", $edithandleparm     = "", $editpromptsrchr    = "", $editpromptsrchl    = ""
	Global $edithandlediskb    = "", $editbuttonstand    = "", $editmessageparm    = ""
	Global $edithandlesrchr    = "", $edithandleselfile  = "", $edithandleseliso   = "", $editpromptgraph    = "", $edithandlegraph = ""
	Global $edithandlefilea    = "", $edithandlesrchl    = "", $editbuttonapply    = "", $edithandlehotkey   = ""
	Global $edithandlepause    = "", $edithandlechknv    = "", $editprompticon     = "", $edithandledevice   = ""
	Global $editlistcustedit   = "", $editpromptcust     = "", $editpromptsample   = ""
	Global $editpromptloadby   = "", $edithandleloadby   = "", $edithandleloadlab  = "", $editpromptlayout   = "", $edithandlelayout = ""
	Global $edithandlehiber    = "", $edithandlewinmenu  = ""
EndFunc