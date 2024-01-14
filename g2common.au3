#include-once
#include <g2basecode.au3>
#include <g2basefunc.au3>
#include <g2time.au3>
#include <g2settings.au3>
#include <g2partscan.au3>
#include <g2language.au3>

If StringInStr (@ScriptName, "g2common") Then Exit

Const  $temploghandle     = FileOpen            ($templogfile, $FO_OVERWRITE)

                            CommonCheckMode     ()
                            CommonGetAllInfo    ()
Const  $runcolor          = CommonGetColor      ()
                            CommonScaleIt       ()
							CommonInitMessage   ()
Const  $diskpartprefix    = $commandtemppath    & "\diskpart."

Const  $setupmasterpath   = CommonGetSetupPath  ()
Const  $helppath          = CommonGetHelpPath   ()

Const  $parmmaster        = CommonParmTemplate  ()
Const  $parmsyntax        = CommonParmSyntax    ($parmmaster)
                            CommonParmsParse    ("", "yes")
Const  $parmstring        = StringStripWS           ($parmstringwork, 7)
Global $parmarray         = $parmarraywork
Const  $bcdteststatus     = CommonParms         ($parmbcdtest)
                            CommonGetGeo        ()
	                        CommonGetLetterEFI  ()
Const  $backupmode        = CommonGetBackupMode ()
Const  $securebootstatus  = CommonGetSecureBoot ()

Const  $efiutilexec       = $sysutilpath     & "\diskpart.exe"
Const  $encryptexec       = $sysutilpath     & "\manage-bde.exe"
Const  $syslinepath       = "The utility run path is " & $sysutilpath
Const  $efimasterstring   = $efibootdir & CommonGetMasterEFI () & ".efi"
Const  $bootmanefi        = "gnugrub.kernel" & $osbits & ".efi"
Const  $efidescgrub       = "Grub2Win EFI - " & $osbits & " Bit"
Const  $efipathgrub       = $efibootmanstring & "\" & $bootmanefi

Global $installstatus     =	$progexistinfo [$iStatus]
Global $graphstandard     = SpecFuncGetResolutions ()

#include <g2xp.au3>
#include <g2bcd.au3>
#include <g2theme.au3>
#include <g2setup.au3>
#include <g2custom.au3>
#include <g2guiefi.au3>
#include <g2syntax.au3>
#include <g2update.au3>
#include <g2posrog.au3>
#include <g2guiedit.au3>
#include <g2guiicon.au3>
#include <g2getprev.au3>
#include <g2guimain.au3>
#include <g2network.au3>
#include <g2utility.au3>
#include <g2diagnose.au3>
#include <g2backrest.au3>
#include <g2genconfig.au3>
#include <g2guiimport.au3>
#include <g2uninstall.au3>
#include <g2guieditpanel.au3>
#include <g2guifirmorder.au3>
#include <g2guiselection.au3>

CommonPathSet      ()

CommonCheckRunning ($runtype)

Func CommonPathSet ($spmasterpath = $masterpath)
	Dim                 $themematrixarray [0] [4]
	$masterlogfile    = $spmasterpath    & "\update.log"
	$datapath         = $spmasterpath    & "\windata"
	$storagepath      = $datapath        & "\storage"
	$settingspath     = $storagepath     & "\settings.txt"
	$configfile       = $spmasterpath    & "\" & $configstring
	$masterexe        = $spmasterpath    & "\" & $exestring
	$sourcepath       = $spmasterpath    & "\winsource"
   	$themepath        = $spmasterpath    & "\themes"
    $bootmanpath      = $spmasterpath    & "\" & $bootmandir
	$envfile          = $spmasterpath    & "\grubenv"
	$userfiles        = $spmasterpath    & "\userfiles"
	$diagpath         = $spmasterpath    & "\diagnose"
	$userbackgrounds  = $userfiles       & "\user.backgrounds"
	$userclockfaces   = $userfiles       & "\user.clockfaces"
	$usericons        = $userfiles       & "\user.icons"
	$userfonts        = $userfiles       & "\user.fonts"
	$usermiscfiles    = $userfiles       & "\user.misc.files"
	$usermiscimport   = $usermiscfiles   & "\import.source"
	$usersectionfile  = $userfiles       & "\usersection.cfg"
	$usersectionexp   = $userfiles       & "\usersection.expanded.cfg"
	$usergfxmodefile  = $userfiles       & "\gfxmode.cfg"
	$usergfxcmdfile   = $userfiles       & "\gfxcommands.cfg"
	$usersectionorig  = $windowstempgrub & "\usersection.original"
	$custconfigs      = $datapath        & "\customconfigs"
	$custconfigstemp  = $windowstempgrub & "\customconfigs"
	$systemdatafile   = $datapath        & "\system.info.txt"
	$systempartfile   = $datapath        & "\system.partitions.array"
	$backuppath       = $datapath        & "\backups"
	$backupmain       = $backuppath      & "\main"
	$backupefipart    = $backuppath      & "\efi.partitions"
	$backuplogs       = $backuppath      & "\logs"
	$backupbcds       = $backuppath      & "\bcds"
	$backupcustom     = $backuppath      & "\custom"
	$updatedatapath   = $datapath        & "\updatedata"
	$commandpath      = $datapath        & "\commands"
	$bcdcleanuplog    = $storagepath     & "\bcdcleanup.log"
	$bcddiaginlog     = $storagepath     & "\bcddiaginput.log"
	$efilogfile       = $storagepath     & "\EFIUpdate.log"
	$syntaxorigfile   = $windowstempgrub & "\" & $syntaxorigname
	$customworkfile   = $custconfigstemp & "\" & $custworkstring
    $sysinfotempfile  = $windowstempgrub & "\system.info.temp.txt"
	$utillogfile      = $windowstempgrub & "\utilityscan.log.txt"
    $themebackgrounds = $themepath       & "\backgrounds"
	$themetempback    = $windowstempgrub & "\backgrounds"
	$iconpath         = $themepath       & "\icons"
    $fontpath         = $spmasterpath    & "\fonts"
    $themeconfig      = $themepath       & "\custom.config"
    $screenshotfile   = $themepath       & "\custom.screenshot.jpg"
	$themecustopt     = $themepath       & "\custom.options.txt"
    $themecustback    = $themepath       & "\custom.background.png"
    $themestandpath   = $themepath       & "\options.standard"
    $themelocalpath   = $themepath       & "\options.local"
	$themecommon      = $themepath       & "\common"
	$thememasterpath  = $themepath       & "\master"
    $themefaces       = $themecommon     & "\clockfaces"
    $themecolorsource = $themecommon     & "\colorsource"
	$themecolorcustom = $themecommon     & "\colorcustom"
	$themestatic      = $themecommon     & "\static"
	$themeempty       = $themestatic     & "\image.empty.png"
	$themedeffile     = $thememasterpath & "\options.txt"
    $themetemplate    = $thememasterpath & "\config.template.txt"
	$themetemp        = $windowstempgrub & "\themes"
	$themetempfiles   = $themetemp       & "\files"
	$themetemplocal   = $themetemp       & "\options.local"
	$themetempcust    = $themetemp       & "\colorcustom"
	$samplecustcode   = $sourcepath      & "\sample.customcode.txt"
    $sampleisocode    = $sourcepath      & "\sample.isoboot.txt"
    $samplesubcode    = $sourcepath      & "\sample.submenu.txt"
	$zippath          = $sourcepath      & "\" & $zipmodule
	$partlistfile     = $datapath        & "\partlist.txt"
	$partlistlffile   = $storagepath     & "\partlist.linefeed.txt"
	$partdumppath     = $datapath        & "\partdump"
	If $timezonedisplay = "" Then $timezonedisplay  = $alttimezone
	If FileExists ($usergfxmodefile) Then $graphstandard = BaseFuncGetUserGFX ($usergfxmodefile, $graphstandard)
	$graphconfigauto  = $graphautostandard
	$graphstring      = $graphstandard
	FileDelete        ($bcddiaginlog)
	DirRemove         ($commandpath, 1)
EndFunc

Func CommonPrepareAll  ()
	CommonHotKeys ()
	TimeGetCurrent ()
	If $firmwaremode = "EFI" And ($osbits = 32 Or $procbits = 32) Then $efimodemixed = "yes"
	If Not CommonCheckResolution () Then Exit
	If @DesktopWidth > 1600 And Not StringInStr ($graphstring, $graphsize) Then
		$graphstring     &= "|" & $graphsize
		$graphconfigauto  = $graphsize & "," & $graphconfigauto
	EndIf
	LangSetup      ()
	CommonDatabase ()
EndFunc

Func CommonHotKeys ($hktype = "on")
	If StringInStr ($CmdLineRaw, "Quiet") Or $hktype <> "on" Then
		HotKeySet ("{ESC}")
		HotKeySet ("{F1}")
		HotKeySet ("{F2}")
		Return
	EndIf
	HotKeySet ("{ESC}", "CommonEscape")
	HotKeySet ("{F1}",  "CommonEscape")
	HotKeySet ("{F2}",  "CommonParmUpdate")
EndFunc

Func CommonDisplayLog ()
	$cdlimit = Ubound ($templogarray) - 1
	If $cdlimit = $mainlogcount Then return
	$mainlogcount = $cdlimit
	;_ArrayDisplay ($logarraytemp)
	GUICtrlSetData ($mainloghandle, "")
	For $dlsub = 0 To $cdlimit
		$dlrecord  = $templogarray [$dlsub] & " |"
		GuiCtrlSetData  ($mainloghandle, " " & StringReplace ($dlrecord, @CR, "| "))
	Next
	If $cdlimit > 12 Then
		GUICtrlSetBkColor ($mainloghandle, $mywhite)
		_GUICtrlListBox_SetTopIndex ($mainloghandle, $cdlimit)
	EndIf
	GUISetState(@SW_SHOW, $handlemaingui)
EndFunc

Func CommonCheckpointLog ($cllogfilename, ByRef $cllogfilehandle)
	FileClose ($cllogfilehandle)
	$cllogfilehandle = FileOpen ($cllogfilename, 1)
EndFunc

Func CommonInitialize  ()
	CommonSetHeaders   ()
	If Not FileExists  ($backuppath)      Then DirCreate ($backuppath)
	If Not FileExists  ($storagepath)     Then DirCreate ($storagepath)
	If Not FileExists  ($custconfigstemp) Then DirCreate ($custconfigstemp)
	CommonBackStep (5, "update", "log", $backuplogs, $masterpath, "yes")
	CommonWriteLog ("***  "                          & $progvermessage & "  ***", Default, "")
	CommonWriteLog ("                   Graphics   " & $graphmessage,             Default, "")
	CommonWriteLog ("                   Gen Stamp  " & $genstampdisp,             Default, "")
	CommonWriteLog ("",                                                           Default, "")
	CommonWriteLog ("Grub2Win Is Starting")
	CommonWriteLog (TimeLine ("", "", "yes"))
	If $parmlog <> "" Then CommonWriteLog ('Parms are "' & $parmlog & '"')
	CommonWriteLog ("")
EndFunc

Func CommonSetHeaders ()
	$shname     = "Grub2Win   Version " & $basrelcurr & "   Build " & $basrelbuild
	$headermessage    = "     " & $shname & "       G=" & $graphmessage
	If $parmsdisplay <> "" Then $headermessage &= "     P=" & $parmsdisplay
	$progvermessage  = "Generated by " & $shname & "   from directory  " & @ScriptDir
	For $shsub = 0 To Ubound ($osparmarray) - 1
		If $osparmarray [$shsub] [$pFamily] = "" Then ContinueLoop
		If $firmwaremode = "EFI"  And $osparmarray [$shsub] [$pFirmMode] = "BIOS" Then ContinueLoop
		If $firmwaremode = "BIOS" And $osparmarray [$shsub] [$pFirmMode] = "EFI"  _
			And Not CommonParms ($parmefiaccess) Then ContinueLoop
		If $procbits     =  32    And $osparmarray [$shsub] [$pFirmMode] = "64B"  Then ContinueLoop
		$typestring &= $osparmarray [$shsub] [$pType] & "|"
	Next
	;MsgBox ($mbontop, "String", $typestring)
EndFunc

Func CommonSubdirCopy ($sddir, $sdfrompath, $sdtopath, $sdwritelog = "")
	If $sdwritelog <> "" Then CommonWriteLog ("Copying subdirectory " & $sddir)
	If FileExists ($sdtopath & "\" & $sddir) Then DirRemove ($sdtopath & "\" & $sddir, 1)
	$ssrcsubdircopy = DirCopy  ($sdfrompath & "\" & $sddir, $sdtopath & "\" & $sddir, 1)
	If $ssrcsubdircopy = 1 Then Return
	BaseFuncShowError ('Subdir Copy Failed "' & $sdfrompath  & "\" & $sddir & '" to "' _
		                                  & $sdtopath    & "\" & $sddir & '" ' & $ssrcsubdircopy, "CommonSubdirCopy")
EndFunc

Func CommonSaveListings ()
	Dim $slfrontarray [1]
	Dim $slbackarray  [0]
	_ArrayAdd ($slfrontarray, @CRLF)
	_ArrayAdd ($slfrontarray, "******      End of Grub2Win log       ****** ")
	If $firmwaremode = "EFI" Then
		If FileExists ($efilogfile) Then CommonLogStack ($slfrontarray, $efilogfile, "EFI Update")
		_ArrayAdd ($slfrontarray, _StringRepeat (@CRLF, 5))
	EndIf
	If $bootos = $xpstring Then
		_ArrayAdd ($slfrontarray, _StringRepeat (@CRLF, 5))
		_ArrayAdd ($slfrontarray, "                       ******  Start " & $xpinifile & " Listing  ******")
		$slinitime    = FileGetTime ($xpinifile, 0, 1)
		$slinistamp   = StringLeft ($slinitime, 4) & " - " & StringMid ($slinitime, 5, 4) & " - " & StringMid ($slinitime, 9, 6)
		_ArrayAdd ($slfrontarray, "                              Stamp = " & $slinistamp)
		$slbackarray = BaseFuncArrayRead ($xpinifile, "CommonSaveListings")
		_ArrayAdd ($slbackarray,  "                       ******   End "  & $xpinifile & " Listing   ******")
		_ArrayConcatenate ($slfrontarray, $slbackarray)
	Else
		_ArrayAdd ($slfrontarray, "******  Start BCD Detail Listing  ******")
		_ArrayAdd ($slfrontarray, "As of " & $nytimeus)
		$slbackarray = CommonBCDRun ("/v", "detail")
		_ArrayAdd ($slbackarray, "")
		If $firmwaremode = "EFI" Then
			_ArrayAdd ($slbackarray,  "")
			_ArrayAdd ($slbackarray,  "                               BCD Firmware entries")
			_ArrayAdd ($slbackarray,  _StringRepeat ("_", 85))
			_ArrayConcatenate ($slbackarray, CommonBCDRun ("/enum all", "enum"))
			_ArrayAdd ($slbackarray, "")
		EndIf
		_ArrayAdd ($slbackarray,  "******   End BCD Detail Listing   ******")
		_ArrayConcatenate ($slfrontarray, $slbackarray)
	EndIf
	DirCopy         ($commandtemppath, $commandpath, 1)
	FileCopy        ($workdir & "\grub2win.*.txt", $datapath & "\", 1)
	FileDelete      ($workdir & "\grub2win.*.txt")
	If FileExists   ($systemdatafile) Then CommonLogStack ($slfrontarray, $systemdatafile, "System and Secure Boot Information")
	If FileExists   ($configfile)     Then CommonLogStack ($slfrontarray, $configfile,     "grub.cfg")
	If FileExists   ($datapath & $setuplogstring) Then CommonLogStack ($slfrontarray, $datapath & $setuplogstring, "Grub2Win Setup")
	BaseFuncArrayWrite ($masterlogfile, $slfrontarray, 1)
EndFunc

Func CommonLogStack (ByRef $lsfrontarray, $lsfile, $lsmessage)
	$lsbackarray = BaseFuncArrayRead ($lsfile, "CommonLogStack")
	If @error Then Return
	_ArrayAdd ($lsfrontarray, _StringRepeat (@CRLF, 5))
	_ArrayAdd ($lsfrontarray,     "******   Start " & $lsmessage & " listing   ******")
	_ArrayAdd ($lsfrontarray, "")
	_ArrayAdd ($lsbackarray,  "")
	_ArrayAdd ($lsbackarray,      "******    End " & $lsmessage & " listing    ******")
	_ArrayConcatenate ($lsfrontarray, $lsbackarray)
EndFunc

Func CommonBackStep ($bscount, $bsname, $bsext, $bsbackdir, $bsfromdir = $masterpath, $bskeeporig = "")
	; MsgBox ($mbontop, "Back", $bsname & @CR & $bsext & @CR & $bsbackdir & @CR & $bsfromdir & @CR & $bskeeporig)
	If Not FileExists ($bsbackdir) Then DirCreate ($bsbackdir)
	If Not FileExists ($bsfromdir & "\" & $bsname & "." & $bsext) Then Return
	For $bssub = $bscount To 2 Step -1
		$bsoldfile = $bsbackdir & "\" & $bsname & ".previous-" & $bssub - 1 & "." & $bsext
		$bsnewfile = $bsbackdir & "\" & $bsname & ".previous-" & $bssub     & "." & $bsext
		If FileExists ($bsoldfile) Then FileMove ($bsoldfile, $bsnewfile, 1)
	Next
	FileCopy ($bsfromdir & "\" & $bsname & "." & $bsext, $bsbackdir & "\" & $bsname & ".previous-1." & $bsext, 1)
	If $bskeeporig = "" Then FileDelete ($bsfromdir & "\" & $bsname & "." & $bsext)
EndFunc

Func CommonDirStep ($dscount, $dsname, $dsbackdir)
	If Not FileExists ($dsbackdir & "\" & $dsname) Then Return
	DirRemove ($dsbackdir & "\" & $dsname & ".previous-" & $dscount, 1)
	For $dssub = $dscount To 2 Step -1
		$dsolddir = $dsbackdir & "\" & $dsname & ".previous-" & $dssub - 1
		$dsnewdir = $dsbackdir & "\" & $dsname & ".previous-" & $dssub
		If FileExists ($dsolddir) Then DirMove ($dsolddir, $dsnewdir, 1)
	Next
	DirMove ($dsbackdir & "\" & $dsname, $dsbackdir & "\" & $dsname & ".previous-1.", 1)
EndFunc

Func CommonAddFileToArray ($afinput, ByRef $afarray, $afspace = "")
	$aftemparray = BaseFuncArrayRead ($afinput, "CommonAddFileToArray")
	_ArrayConcatenate ($afarray, $aftemparray)
	If $afspace <> "" Then _ArrayAdd ($afarray, "")
	Return 0
EndFunc

Func CommonParseStrip($pptext, $ppsearch)
	$pptext = StringReplace($pptext, '"', "")
	$pptext = StringReplace($pptext, "'", "")
	$pploc  = StringInStr($pptext, $ppsearch)
	If $pploc = 0 Then Return 0
	$parmstripped = StringReplace($pptext, $ppsearch, "")
	Return $parmstripped
EndFunc

Func CommonSelArraySync ($sasrenametemp = "")
	;_ArrayDisplay ($selectionarray, "Sync Before")
	$defaultstring      = $lastbooted & "|"
	$selectionautocount = 0
	$selectionusercount = 0
	$cloverfound        = ""
	$osfound            = ""
	For $sassub = 0 To Ubound ($selectionarray) - 1
		If $selectionarray [$sassub] [$sAutoUser] =  "auto" Then
			$autohighsub         = $sassub
			$selectionautocount += 1
		Else
			$selectionusercount += 1
		EndIf
		If $selectionarray [$sassub] [$sOSType] =  "clover"  Then $cloverfound = "yes"
		If $selectionarray [$sassub] [$sFamily] <> "windows" And $selectionarray [$sassub] [$sFamily] <> "standfunc" Then $osfound = "yes"
		If $selectionarray [$sassub] [$sBootDisk] <> "" Then $selectionarray [$sassub] [$sBootFileSystem] = CommonGetSearch ($selectionarray [$sassub] [$sBootDisk], "FSys")
		If $selectionarray [$sassub] [$sRootDisk] <> "" Then $selectionarray [$sassub] [$sRootFileSystem] = CommonGetSearch ($selectionarray [$sassub] [$sRootDisk], "FSys")
		If $sassub = 0 Or $selectionarray [$sassub] [$sDefaultOS] = "DefaultOS" Then
			$defaultos    = $sassub
			$defaultset   = $sassub & "  -  " & $selectionarray [$sassub][$sEntryTitle]
		EndIf
		$defaultstring   &= $sassub & "  -  " & $selectionarray [$sassub][$sEntryTitle] & "|"
		$sasoldcust = $selectionarray[$sassub] [$sCustomName]
		$sasnewcust = ""
		If $selectionarray [$sassub] [$sOSType] = $modecustom And $selectionarray[$sassub] [$sAutoUser] = "auto" Then _
			$sasnewcust = CommonCustomName ($selectionarray [$sassub] [$sEntryTitle])
		$selectionarray [$sassub] [$sCustomName] = $sasnewcust
		;MsgBox ($mbontop, "Cust " & $sassub, $selectionarray [$sassub] [$sOSType] & @CR & @CR & CommonCustomName ($selectionarray [$sassub] [$sEntryTitle]) & @CR & @CR & $selectionarray [$sassub] [$sEntryTitle])
		If $sasrenametemp = "" Or $sasnewcust = $sasoldcust Then ContinueLoop
		FileMove ($custconfigstemp & "\" & $sasoldcust, $custconfigstemp & "\" & $sasnewcust, 9)
	Next
	If $defaultlastbooted = "yes" Then $defaultset = $lastbooted
	; _ArrayDisplay ($selectionarray, "Sync After " & $osfound & "  " & $selectionusercount)
EndFunc

Func CommonCustomName ($cnnamein)
	$cnnamein   = StringStripWS ($cnnamein, 8)
	If StringRight ($cnnamein, 4) = ".cfg" Then $cnnamein = StringTrimRight ($cnnamein, 4)
	$cnnameout = BaseFuncRemoveCharSpec ($cnnamein)
	If StringLen ($cnnameout) < 6 Then $cnnameout = "custom." & $cnnameout
	Return $cnnameout & ".cfg"
EndFunc

Func CommonSetupDefault ()
	CommonSelArraySync ("yes")
	GUISwitch       ($handlemaingui)
	BaseFuncGUICtrlDelete   ($defaulthandle)
	$defaulthandle = CommonScaleCreate("Combo", "", 58, 62.3, 39, 15, -1)
	If Ubound ($selectionarray) = 1 Then $defaultset = "0  -  " & $selectionarray [0] [$sEntryTitle]
	GUICtrlSetData ($defaulthandle, $defaultstring, $defaultset)
EndFunc

Func CommonDefaultSync ()
	For $dfsub = 0 To Ubound ($selectionarray) -1
		$selectionarray [$dfsub] [$sDefaultOS] = ""
		If $dfsub = $defaultos Then $selectionarray [$dfsub] [$sDefaultOS] = "DefaultOS"
	Next
EndFunc

Func CommonParmCalc ($pcmenusub, $pcgroup = "Held", $pccontrol = "")
	If $pccontrol = "Reset" Then
		For $lpasub = 0 To Ubound ($osparmarray) - 1
			$osparmarray [$lpasub] [$pHoldParms] = $osparmarray [$lpasub] [$pBootParms]
		Next
	EndIf
	$pctype    = $selectionarray[$pcmenusub][$sOSType]
	If $selectionarray [$pcmenusub] [$sBootParm] = $nullparm And $pcgroup <> "Standard" Then Return ""
	If $selectionarray [$pcmenusub] [$sLoadBy]   = $modeuser Then Return $selectionarray[$pcmenusub][$sBootParm]
	$pclpasub    = _ArraySearch($osparmarray, $pctype, 0, 0, 0, 0, 1, 0)
	If $pclpasub < 0 Then Return ""
	If $pccontrol = "Store"    Then $osparmarray [$pclpasub] [$pHoldParms] = $selectionarray[$pcmenusub][$sBootParm]
	If $pcgroup   = "Held"     Then Return $osparmarray [$pclpasub] [$pHoldParms]
	If $pcgroup   = "Standard" Then Return CommonSetBitmode ($osparmarray [$pclpasub] [$pBootParms], $procbits)
	If $pcgroup   = "Previous" Then Return $selectionarray[$pcmenusub][$sBootParm]
EndFunc

Func CommonSetBitmode ($sbstring, $sbmode = 32)
	$sbstring = StringReplace ($sbstring, "_x86_64 ", "_x86 ")
	If $sbmode = 64 Then $sbstring = StringReplace ($sbstring, "_x86 ", "_x86_64 ")
	Return $sbstring
EndFunc

Func CommonGetOSParms ($gopsub)
	$goptype = $selectionarray [$gopsub] [$sOSType]
	$goploc  = _ArraySearch ($osparmarray, $goptype)
	If @error Then $goploc = Ubound ($osparmarray) - 1
	Return $goploc
EndFunc

Func CommonCheckUpDown ($cudcontrolhandle, ByRef $cudlastdata, $cudlowlimit = 0, $cudhighlimit = 99)
	;If $cudcontrolhandle = $edithandledrva Then MsgBox ($mbontop, "Drive X " & $edithandledrva, GUICtrlRead ($edithandledrva))
	$cudnewdata = StringReplace (GUICtrlRead ($cudcontrolhandle), ",", "")
	If $cudnewdata < $cudlowlimit  Then $cudnewdata = $cudlowlimit
	If $cudnewdata > $cudhighlimit Then $cudnewdata = $cudhighlimit
	GUICtrlSetData ($cudcontrolhandle, $cudnewdata)
	$cudstatus   = ""
	If $cudlastdata <> "" And $cudnewdata <> $cudlastdata Then $cudstatus = 1
	$cudlastdata = $cudnewdata
	Return $cudstatus
EndFunc

Func CommonCheckBox ($cbhandle)
	$cbstatus = 0
	If BitAND (GUICtrlRead ($cbhandle), $GUI_CHECKED) = $GUI_CHECKED Then $cbstatus = 1
	Return $cbstatus
EndFunc

Func CommonConvDevAddr ($cdadisk, $cdatype = "Device", $cdafs = "")
	$cdaparse = StringSplit ($cdadisk, " ")
	If @error Or $cdaparse [1] <> "Disk" Then Return ""
	$cdadrive     = $cdaparse [2]
	$cdapartition = $cdaparse [4]
	$cddisk       = CommonConvDisk  ($cdadrive, $cdapartition)
	If $cdatype = "hd" Then
		$cdaout = "'(hd" & $cdadrive & "," & $cdapartition & ")'"
	ElseIf $cdatype = "Device" Then
		$cdaletters = "abcdefghij"
		$cdaout = "/dev/sd" & StringMid($cdaletters, $cdadrive + 1, 1) & $cdapartition
	Else
		$cdaout = CommonGetSearch ($cddisk, $cdatype)
	EndIf
	If $cdafs <> "" Then $cdaout &= @TAB & "  FS Type = " & CommonGetSearch ($cddisk, "FSys")
	Return $cdaout
EndFunc

Func CommonConvDisk ($cdadrive, $cdapartition = "1")
	$cdaout = "Disk " & $cdadrive & " Partition " & $cdapartition
	Return $cdaout
EndFunc

Func CommonGetSearch ($gsdisk, $gstype)
	$gsloc = _ArraySearch ($linuxpartarray, $gsdisk)
	If @error Then Return $partnotfound
	If $gstype = "FSys"  Then Return $linuxpartarray [$gsloc] [4]
	If $gstype = "Full"  Then Return $linuxpartarray [$gsloc] [3]
	If $gstype = "Label" Then Return $linuxpartarray [$gsloc] [2]
	If $gstype = "UUID"  Then Return $linuxpartarray [$gsloc] [1]
EndFunc

Func CommonGetDisk ($gdsearch, $gdtype)
	If $gdtype = "Full"  Then $gdloc = _ArraySearch ($linuxpartarray, $gdsearch, 0, 0, 0, 0, 0, 3)
	If $gdtype = "Label" Then $gdloc = _ArraySearch ($linuxpartarray, $gdsearch, 0, 0, 0, 0, 0, 2)
	If $gdtype = "UUID"  Then $gdloc = _ArraySearch ($linuxpartarray, $gdsearch, 0, 0, 0, 0, 0, 1)
	If $gdtype = "Disk"  Then $gdloc = _ArraySearch ($linuxpartarray, $gdsearch)
	If @error Or $gdsearch = "" Then Return $partnotfound
	Return $linuxpartarray [$gdloc] [0]
EndFunc

Func CommonSelectVerify ()
	$svmsg = ""
	For $sfsub = 0 To Ubound ($selectionarray) - 1
		$sfstatus = CommonDiskVerify ($sfsub)
		If $sfstatus <> "" Then
			$svmsg &= $sfsub & ", "
		EndIf
	Next
	If $svmsg <> "" Then
		$svmsg = StringTrimRight ($svmsg, 2)
		$svmsg = StringReplace   ($svmsg, ", ", " and ", -1)
		$svmsg = "menu entry " & $svmsg
		If StringInStr ($svmsg, "and") Then $svmsg = StringReplace ($svmsg, "entry", "entries")
	EndIf
	Return $svmsg
EndFunc

Func CommonDiskVerify ($dvsub)
	$dverror = ""
	If StringInStr ($selectionarray [$dvsub] [$sAutoUser], "auto") Then
		$dvclass      = $selectionarray [$dvsub] [$sClass]
		$dvloadby     = $selectionarray [$dvsub] [$sLoadBy]
		$dvfamily     = $selectionarray [$dvsub] [$sFamily]
		$dvrootdisk   = $selectionarray [$dvsub] [$sRootDisk]
		$dvbootdisk   = $selectionarray [$dvsub] [$sBootDisk]
		$dvsearch     = $selectionarray [$dvsub] [$sRootSearchArg]
		Select
			Case $dvfamily = "windows"   Or $dvclass  = "custom" Or $dvloadby = $modecustom
			Case $dvclass  = "chaindisk" Or $dvloadby = "no"
			Case $dvfamily = "linux-android" Or $dvclass = "chainfile"
				CommonEFIMountWin ()
				If StringMid (CommonGetBootFile ($dvsearch), 2, 1) <> ":" Then $dverror = "search"
				If $selectionarray [$dvsub] [$sFileLoadCheck] = $fileloaddisable Then $dverror = ""
			Case $selectionarray [$dvsub] [$sLayout] = $layoutboth
				If $dvrootdisk = "" Or $dvrootdisk = $partnotfound Then $dverror &= "search"
				If $dvbootdisk = "" Or $dvbootdisk = $partnotfound Then $dverror &= "boot"
			Case $dvrootdisk = "" Or $dvrootdisk = $partnotfound
				$dverror = "search"
		EndSelect
	EndIf
	$selectionarray [$dvsub] [$sDiskError] = $dverror
	Return $dverror
EndFunc

Func CommonArraySetDefaults($asdsub, $asdreset = "")
	CommonSetDefault ($selectionarray [$asdsub] [$sOSType], "unknown")
	$asdparmloc = CommonGetOSParms ($asdsub)
	$asdtype    = $osparmarray [$asdparmloc] [$pType]
	$asdtitle   = $osparmarray [$asdparmloc] [$pTitle]
	$asdclass   = $osparmarray [$asdparmloc] [$pClass]
	If $asdclass    = "windows"   Then $selectionarray[$asdsub][$sLoadBy] = $modewinauto
	If $asdtype     = "android"   Then $selectionarray[$asdsub][$sLoadBy] = $modeandroidfile
	If $asdtype     = "phoenix"   Then $selectionarray[$asdsub][$sLoadBy] = $modephoenixfile
	If $asdclass    = "chaindisk" Then $selectionarray[$asdsub][$sLoadBy] = $modechaindisk
	If $asdclass    = "chainfile" Then $selectionarray[$asdsub][$sLoadBy] = $modechainfile
	If ($asdclass   = "custom" And  $selectionarray [$asdsub][$sLoadBy] <> $modeuser) Or _
	    $asdclass   = "isoboot" Or $asdclass   = "submenu"  _
		Then $selectionarray [$asdsub][$sLoadBy] = $modecustom
	If $selectionarray [$asdsub] [$sLoadBy] = "" And $selectionarray [$asdsub] [$sFamily] <> "standfunc" And _
		$selectionarray [$asdsub][$sOSType] <> "unknown" Then  _
		$selectionarray[$asdsub] [$sLoadBy] = $modehardaddress
	CommonSetDefault ($selectionarray [$asdsub] [$sLoadBy],     $modeno)
	CommonSetDefault ($selectionarray [$asdsub] [$sEntryTitle], $asdtitle,     $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sSortSeq],    $asdsub * 100, $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sGraphMode],  $graphnotset,  $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sHotKey],     "no", $asdreset)
	If  $selectionarray [$asdsub] [$sOSType] = $typechaindisk Then _
		CommonSetDefault ($selectionarray [$asdsub] [$sChainDrive], "0", $asdreset)
	If $selectionarray [$asdsub] [$sLoadBy] = $modehardaddress Or $selectionarray [$asdsub] [$sLoadBy] = $modepartlabel Then _
		CommonSetDefault ($selectionarray [$asdsub] [$sLayout], $layoutrootonly,   $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sRootSearchArg], "",             $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sReviewPause], "",                $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sIcon], CommonGetIcon ($asdsub), $asdreset)
	CommonSetDefault ($selectionarray [$asdsub] [$sAutoUser], "auto",              $asdreset)
EndFunc

Func CommonGetIcon ($gisub)
	$giicon  = $selectionarray [$gisub] [$sOSType]
	If $selectionarray [$gisub] [$sFamily] = "custom" Then $giicon = "custom"
	If StringLeft ($selectionarray [$gisub] [$sFamily], 5) = "chain"  Then $giicon = "chain"
	If $selectionarray [$gisub] [$sOSType] = "clover" Then $giicon = "clover-osx"
	If StringInStr ($selectionarray[$gisub][$sIcon],  "windows") Then $giicon = "windows"
	Return "icon-" & $giicon
EndFunc

Func CommonSetupSysLines ($sslefilevel, $ssletype = "")
	$syslineos = "The OS is " & $bootos & "   " & $osbits & " bit   "
	$cemode    = "Boot mode is " & $systemmode
	If $firmwaremode   = "EFI" Then
		$cemode        = $ssletype & "EFI level is " & $sslefilevel
		$syslinesecure = "Secure Boot is " & $securebootstatus
		EndIf
	$syslineos &= $cemode
EndFunc

Func CommonEndIt ($eiresult, $eireturnit = "no", $eifailmsg = "", $eipause = "yes")
	CommonFlashEnd  ("")
	BaseFuncGUIDelete ($handlemaingui)
	$handlemaingui  = CommonScaleCreate ("GUI", $headermessage & "      L=" & $langheader, -1, -1, 100, 100, -1)
	BaseFuncGUICtrlDelete ($mainloghandle)
	$mainloghandle  = CommonScaleCreate ("List", "", 2, 5, 95, 85, 0x00200000, "")
    $eiclose        = CommonScaleCreate ("Button", "Close", 47, 92, 10, 3.5)
	CommonWriteLog ()
	$eitime  = TimeLine ("", "", "yes")
	$eicolor = $mygreen
	SettingsPut        ($setefidefaulttype, CommonGetEFIDefaultType ())
	SettingsWriteFile  ($settingspath)
	Select
		Case $eiresult =  "Success"
			If $cloverload <> "" Then $eicolor = $myorange
			CommonWriteLog      ("The Grub2Win run was successful on " & $eitime)
			; _ArrayDisplay ($settingsarray, "EndIt Write")
		Case $eiresult =  "Failed"
			CommonWriteLog("*** Grub2Win failed ***   on " & $eitime)
			If $eifailmsg <> "" Then CommonWriteLog ("*** " & $eifailmsg & " ***")
			$eicolor = $myred
		Case $eiresult =  "Diagnostics"
			CommonWriteLog("Grub2Win diagnostics were run on " & $eitime)
			$eicolor = $myorange
		Case $eiresult <> "Restart" And $eiresult <> "Reboot"
			CommonWriteLog("*** Grub2Win was cancelled ***  on " & $eitime)
			$eicolor = $myyellow
	EndSelect
	CommonWriteLog     ("Run duration was " & CommonCalcDuration ($starttimetick), Default, "yes", "")
	GUICtrlSetFont     ($mainloghandle, $fontsizemedium)
	CommonDisplayLog   ()
	GUICtrlSetBkColor  ($mainloghandle, $eicolor)
	GUISetBkColor      ($eicolor, $handlemaingui)
	GUISetState        (@SW_SHOW, $handlemaingui)
	FileClose          ($temploghandle)
	FileCopy           ($templogfile, $masterlogfile, 1)
	WinClose           ("System Information", "")
	If $eireturnit = "yes" Then Return
	If $eipause    = "yes" And $efiexit <> "yes" Then CommonGUIPause ($eiclose)
	BaseFuncGUIDelete     ($handlemaingui)
	CommonSaveListings  ()
	If $eiresult = "Reboot"  Then Return
	If $eiresult = "Restart" Then
		Run ($masterexe)
		Exit
	EndIf
	$cetype = "Daily"
	If $runtype  =  $parmsetup       Then $cetype = "Setup"
	If CommonParms ($parmfromupdate) Then $cetype = "Update"
	If $eiresult =    "Success" Then
		If $firmwaremode    = "BIOS" And SettingsGet ($setwarnedbios)   = $setno Then
		   CommonWarn ("BIOS System Boot", $setwarnedbios,                       _
					   "    ** This is a BIOS firmware System **"  & @CR & @CR & _
	                   "Microsoft Windows must be loaded by the"   & @CR & @CR & _
	                   "              Windows Boot Manager"        & @CR & @CR)
	    ElseIf $kernelwarn  = "yes"  And SettingsGet ($setwarnedkernel) = $setno Then
		   CommonWarn ("Fedora And Manjaro", $setwarnedkernel,                             _
					   "Fedora and Manjaro installs require an additional step." & @CR & _
		               "You must run the Grub2Win kernset.sh script in Linux.")
		EndIf
		If $runtype = "grub2win"     Then CommonCheckFirmDate ()
		CommonDonate ()
	EndIf
	CommonStatsBuild ($cetype)
	CommonBackStep   (5, $cetype, "txt", $updatedatapath, $updatedatapath)
	FileCopy         ($statsdatafile, $updatedatapath & "\" & $cetype & ".txt", 1)
	FileDelete       ($updatedatapath & "\grub2win.*")
	CommonStatsPut   ()
	BaseFuncCleanupTemp ("CommonEndIt")
EndFunc

Func CommonWarn ($cwhelp, $cwsetting, $cwmsg)
	Sleep (100)
	$cwmsg  = @CR & $cwmsg & @CR & @CR & @CR
	$cwmsg &= 'Click "Yes" for a help page with further details.'  & @CR & @CR
	$cwmsg &= 'Or click "No" to stop this message.'
	$cwrc   = MsgBox ($mbinfoyesnocan, "        ** Grub2Win **   Please Note", $cwmsg)
	If $cwrc = $IDYES Then CommonHelp   ($cwhelp)
	If $cwrc = $IDNO  Then SettingsPut ($cwsetting, TimeFormatDate ($todayjul, "", "", "juldatetime"))
	Return $cwrc
EndFunc

Func CommonThemeGetOption ($tgoparm, $tgolower = "", $tgoarray = $themetempoptarray)
	$tgoloc = _ArraySearch ($tgoarray, $tgoparm, 0, 0, 0, 0, 0, 2)
	If @error Then Return ""
	$tgovalue = $tgoarray [$tgoloc] [3]
	If $tgolower <> "" Then $tgovalue = StringLower ($tgovalue)
	Return $tgovalue
EndFunc

Func CommonThemePutOption ($tpoparm, $tpovalue, ByRef $tpoarray)
	$tpoloc = _ArraySearch ($tpoarray, $tpoparm, 0, 0, 0, 0, 0, 2)
	If @error Then Return ""
	$tpoarray [$tpoloc] [3] = StringLower ($tpovalue)
EndFunc

Func CommonKernelArray ($kasub, $kaparm = $selectionarray [$kasub] [$sBootParm])
	$selectionarray[$kasub] [$sNvidia] = "no"
	If StringInStr ($kaparm, $parmnvidia) Then $selectionarray[$kasub][$sNvidia] = "yes"
EndFunc

Func CommonControlGet ($cghandlewindow, $cghandlecontrol, ByRef $cgabspos)
	$cgworkhandle = ControlGetHandle ($cghandlewindow, "",$cghandlecontrol)
	$cgabspos     = WinGetPos ($cgworkhandle)
	If @error Then Return 0
	$controlhorizhold = $cgabspos [0]
	Return $cgabspos [1]
EndFunc

Func CommonMouseMove ($mmhandlewindow, $mmhandlecontrol)
	$mmnewposvert  = CommonControlGet ($mmhandlewindow, $mmhandlecontrol, $dummyparm)
	MouseMove ($controlhorizhold, $mmnewposvert, 1)
EndFunc

Func CommonScrollDelete ($sdhandle)
	$sdtoppos = _GUIScrollBars_GetScrollPos ($sdhandle, $SB_VERT)
	If $sdtoppos < 0 Then $sdtoppos = 0
	BaseFuncGUIDelete ($sdhandle)
	Return $sdtoppos
EndFunc

Func CommonScrollGenerate ($sghandlescroll, $sghsize, $sgmaxvsize)
	SpecFunc_GUIScrollbars_Generate ($sghandlescroll, $sghsize, $sgmaxvsize)
	If _GUIScrollBars_GetScrollInfoPage ($sghandlescroll, $SB_VERT) < 1 Then Return
	If $scrolltoppos > 0 Then _GUIScrollBars_SetScrollInfoPos ($sghandlescroll, $SB_VERT, $scrolltoppos)
EndFunc

Func CommonScrollMove ($smhandlewindow, $smhandlescroll, $smhandlecontrol, $smupdown, $smminbumppos)
	$smpagepos    = _GUIScrollBars_GetScrollInfoPage ($smhandlescroll, $SB_VERT)
	If $smpagepos = 0 Then
		CommonMouseMove ($smhandlewindow, $smhandlecontrol)
		Return
	EndIf
	$smtag         = _GUIScrollBars_GetScrollBarInfoEx($smhandlescroll, $OBJID_VSCROLL)
	$smscrollvtop  =  DllStructGetData ($smtag, "Top")
	$smscrollvbot  =  DllStructGetData ($smtag, "Bottom")
	$smthumbvbot   =  DllStructGetData ($smtag, "xyThumbBottom") - $smscrollvtop
    $smmaxpos      = _GUIScrollBars_GetScrollInfoMax  ($smhandlescroll, $SB_VERT)
	$smbumppos     = Int ($smmaxpos * .10)
	$smrangev      = $smscrollvbot - $smscrollvtop
	$smlimtopv     = Int (0.25 * $smrangev) + $smscrollvtop
	$smlimbotv     = Int (0.75 * $smrangev) + $smscrollvtop
	$smmouseabs    = MouseGetPos (1)
	If $smbumppos  < $smminbumppos Then $smbumppos = $smminbumppos
	$smnewtoppos   = $scrolltoppos
	;MsgBox ($mbontop, "Mouse " & $smmouseabs, $smlimtopv & @CR & $smlimbotv & @CR & $smupdown)
	If $smmouseabs > $smlimbotv And $smupdown = "down" Then
		$smnewtoppos = $scrolltoppos + $smbumppos
		If $smthumbvbot > $smlimbotv Then $smnewtoppos = $smmaxpos - $smpagepos + 1
	EndIf
	If $smmouseabs < $smlimtopv And $smupdown = "up"   Then $smnewtoppos = $scrolltoppos - $smbumppos
	If $smnewtoppos < $smminbumppos Then $smnewtoppos = 0
	If $smnewtoppos <> $scrolltoppos Then _GUIScrollBars_SetScrollInfoPos ($smhandlescroll, $SB_VERT, $smnewtoppos)
	CommonMouseMove ($smhandlewindow, $smhandlecontrol)
EndFunc

Func CommonScrollCenter ($schandlewindow, $schandlescroll, $schandletarget, ByRef $scarray)
	$sctag         = _GUIScrollBars_GetScrollBarInfoEx($schandlescroll, $OBJID_VSCROLL)
	$scscrollvtop  =  DllStructGetData ($sctag, "Top")
	$scscrollvbot  =  DllStructGetData ($sctag, "Bottom")
	If $scscrollvbot < 1 Then Return
	$scrangev      = $scscrollvbot - $scscrollvtop
	$sclimtopv     = Int (0.45 * $scrangev) + $scscrollvtop
	$sclimbotv     = Int (0.75 * $scrangev) + $scscrollvtop
	$scbumper      = Int ($scrangev  / UBound ($scarray)) * 2
	$sctoppos      = 0
	$sclastabs1    = ""
	$sclastabs2    = ""
	For $scsub = 1 To 100
		_GUIScrollBars_SetScrollInfoPos ($schandlescroll, $SB_VERT, $sctoppos)
		$sccontrolabs    = CommonControlGet ($schandlewindow, $schandletarget, $dummyparm)
		;MsgBox ($mbontop, "Control " & $sccontrolabs, $sclimtopv & @CR & $sclimbotv & @CR & $scbumper & @CR & $sctoppos & @CR & $scsub & @CR & $sclastabs1)
		Select
			Case ($sccontrolabs > $sclimtopv And $sccontrolabs < $sclimbotv) Or _
				$sccontrolabs = $sclastabs1 Or $sccontrolabs = $sclastabs2
				ExitLoop
			Case $sccontrolabs < $sclimtopv
				$sctoppos  -= $scbumper
            Case $sccontrolabs > $sclimbotv
				$sctoppos  += $scbumper
		EndSelect
		$sclastabs1 = $sclastabs2
		$sclastabs2 = $sccontrolabs
		If $sctoppos < 1 Then $sctoppos = 1
	Next
	;MsgBox ($mbontop, "Control end " & $sccontrolabs, $sclimtopv & @CR & $sclimbotv & @CR & $scbumper & @CR & $sctoppos & @CR & $scsub)
EndFunc

Func CommonPrevParse ($cpptext, $cppsearch, $cppfindposition = "*")
	If StringLeft ($cpptext, 1) = "#" Then Return 0
	If Not StringInStr($cpptext, $cppsearch) Then Return 0
	$cpptext = CommonStripSpecial($cpptext)
	$parsearray = _StringBetween ($cpptext, "'", "'")
	If Not @error And StringLen ($parsearray [0]) <> 0 Then
		For $cppsub = 0 To Ubound ($parsearray) - 1
			$cppfrom = $parsearray [$cppsub]
			$cppto   = StringReplace ($cppfrom, " ", "%")
			$cpptext = StringReplace ($cpptext, $cppfrom, $cppto, 1)
		Next
	EndIf
	$parsearray = StringSplit ($cpptext, " ")
	If @error Then Return 0
	$cppsub = 1
	$cpplimit = UBound ($parsearray) - 1
	While $cppsub < $cpplimit
		$cppnull = StringStripWS ($parsearray [$cppsub], 3)
		If $cppnull = "" Then
			_ArrayDelete ($parsearray, $cppsub)
			$cpplimit -= 1
			ContinueLoop
		EndIf
		$cppnull              = StringReplace ($cppnull, "%", " ")
		$parsearray [$cppsub] = StringReplace ($cppnull, "'", "")
		If $cppfindposition = "*" And $parsearray[$cppsub] = $cppsearch Then $cppfindposition = $cppsub
		$cppsub += 1
	Wend
	If $cppfindposition > $cpplimit Then Return 0
	If $parsearray[$cppfindposition] <> $cppsearch Then Return 0
	$parseposition = $cppfindposition
	$parseresult1 = ""
	If $parseposition + 1 < UBound($parsearray) Then $parseresult1 = $parsearray[$parseposition + 1]
	$parseresult2 = ""
	If $parseposition + 2 < UBound($parsearray) Then $parseresult2 = $parsearray[$parseposition + 2]
	$parseresult3 = ""
	If $parseposition + 3 < UBound($parsearray) Then $parseresult3 = $parsearray[$parseposition + 3]
	Return 1
EndFunc

Func CommonDatabase  ()
	If $partscanned   = "" Then
		CommonFlashStart  ($runtype & " Is Scanning Your Disks And Partitions", "", 1000, "", "keep")
		PartBuildDatabase ()
		CommonFlashStart  ("Loading Resources", "", "", "", "keep")
		;If $cdkeepmessage <> "" Then CommonFlashEnd     ("", 0)
	EndIf
	$partscanned      = "yes"
EndFunc

Func CommonMailIt ($miattachtype, $miattachdata, $mierrdesc = "")
	$midatamsg = " "
	$minormal  = ""
	$midouble  = @CRLF & @CRLF
	$miquad    = $midouble & $midouble
	$mispacer  = ":" & $midouble & @TAB
	If $miattachtype = "file" Then
		$midatamsg   = $mispacer & $miattachdata & $midouble
	Else
		$minormal     &= @CRLF & "Please zip up directory" & $mispacer & $miattachdata & @CRLF
	EndIf
	$mimanual    = "Create an email and send it to to:"
	$mimanual   &= $midouble & $myemail & $midouble & "for diagnostic analysis." & $midouble
	$minormal   &= @CRLF & "Please make sure the zipped diagnostic file" & $midatamsg
	$minormal   &= "is attached when you send the email !!"
	$micommand = CommonGetMailCommand ()
	If $micommand <> "" Then
		$misubject = "Grub2Win Diagnostic File"
		$mibody = $minormal & $miquad
		If $mierrdesc <> "" Then $mibody &= "Problem Description: " & $mierrdesc & $midouble
		$mibody    &= "Please add any additional notes below."
		$miparms    = "to='"      & $myemail   & "',"
		$miparms   &= "subject='" & $misubject & "',"
		$miparms   &= "body='"    & $mibody    & "',"
		;If $miattachdata <> "" Then $miparms   &= _                 Awaiting Mozilla fix 9/10/19
		;	"attachment='file:///" & $miattachdata & "',"
		$miparms   &= "format='2'"
		$mistring   = $micommand & '"' & $miparms & '"'
		Run ($mistring)
	EndIf
	$mimsgtext = StringReplace ($mimanual & $minormal, @TAB, "")
	If @error Or $micommand = "" Then MsgBox ($mbinfook, "Diagnostic Email", _
		$mimsgtext & $miquad)
EndFunc

Func CommonGetMailCommand ()
	$gmcexec    = ""
	$gmcclass   = RegRead _
		('HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice', 'Progid')
	$gmccommand = RegRead ('HKCR\' & $gmcclass & '\shell\open\command', '')
	$gmcsplit   = StringSplit   ($gmccommand, '"')
	$gmccommand = StringReplace ($gmccommand, '"',  '')
	$gmccommand = StringReplace ($gmccommand, '%1', '')
	If Not @error And Ubound ($gmcsplit) > 2 Then $gmcexec = $gmcsplit [2]
	If Not FileExists ($gmcexec) Then $gmccommand = ""
	Return $gmccommand
EndFunc

Func CommonShortcut ($csmakeshortcut)
	If $csmakeshortcut = "yes" Then
		$csshortmsg  = "The Grub2Win Desktop Shortcut Was Created."
		If FileExists   ($shortcutfile) Then $csshortmsg = "The Existing Grub2Win Desktop Shortcut Was Kept."
		CommonShortLink ($shortcutfile)
	Else
		$csshortmsg   = "The Grub2Win Desktop Shortcut Was Not Requested."
		If FileExists ($shortcutfile) Then $csshortmsg = "The Grub2Win Desktop Shortcut Was Removed."
		FileDelete    ($shortcutfile)
	EndIf
	Return $csshortmsg
EndFunc

Func CommonShortLink ($slfile)
	$slshortlink       = StringTrimRight ($slfile, 4)
	$slshorticon       = $sourcepath & "\xxgrub2win.ico"
	FileDelete         ($slfile)
	FileCreateShortcut ($masterexe, $slshortlink, "", "", "", $slshorticon)
EndFunc

Func CommonRunBat ($rbpath, $rbname, $rbvar = "", $rbshow = @SW_SHOW, $rbexit = "yes")
	$rbarray = BaseFuncArrayRead ($rbpath, "CommonRunBat")
	_ArrayInsert ($rbarray, 0, "")
	_ArrayInsert ($rbarray, 2, "set basepath=" & $masterpath)
	If $rbvar <> "" Then _ArrayInsert ($rbarray, 2, $rbvar)
	$rbtemp     = @TempDir & "\" & $rbname
	BaseFuncArrayWrite ($rbtemp, $rbarray)
	Run ($rbtemp, "", $rbshow)
	If $rbexit = "yes" Then Exit
EndFunc

Func CommonGetLabel ($gldrive)
	$gllabel = DriveGetLabel ($gldrive)
	If @error Or $gllabel = "" Then $gllabel = "** Unlabeled **"
	Return $gllabel
EndFunc

Func CommonFormatSize ($fsbytes, $fsjustify = "")
	$fsoutstring =                           StringFormat ("%4.0f", $fsbytes)         & " Bytes"
	If $fsbytes >= $kilo Then $fsoutstring = StringFormat ("%4.0f", $fsbytes / $kilo) & " KB"
	If $fsbytes >= $mega Then $fsoutstring = StringFormat ("%4.0f", $fsbytes / $mega) & " MB"
	If $fsbytes >= $giga Then $fsoutstring = StringFormat ("%4.0f", $fsbytes / $giga) & " GB"
	If $fsbytes >= $tera Then $fsoutstring = StringFormat ("%4.1f", $fsbytes / $tera) & " TB"
	$fsoutstring = StringStripWS ($fsoutstring, 3)
	$fsoutstring = StringReplace ($fsoutstring, ".0", "")
	If $fsjustify <> "" Then $fsoutstring = _StringRepeat (" ", 6 - StringLen ($fsoutstring)) & $fsoutstring
	Return $fsoutstring
EndFunc

Func CommonStripSpecial ($csstext)
	$csstext = StringReplace($csstext, '"', "'")
	$csstext = StringReplace($csstext, '{', "")
	$csstext = StringReplace($csstext, '}', "")
	Return $csstext
EndFunc

Func CommonEscape ()
	If (Not CommonParms ("Setup") And WinGetState ($handlemaingui)  <> 15) Or   _
		   (CommonParms ("Setup") And WinGetState ($setuphandlegui) <> 15) Then
		    CommonEscapeOut ()
			Return
	EndIf
	CommonEscapeOut ()
EndFunc

Func CommonEscapeOut ()
	If CommonQuestion ($mbquestyesno, "", "Do you want to cancel Grub2Win?") Then _
		CommonEndit ("Cancelled")
EndFunc

Func CommonSearchDrives ($sdsearch, $sdfound, ByRef $sdstring, $sdefifamily = "EFI")
	$sdstring = ""
	$sdarray  = $partitionarray
	_ArraySort ($sdarray, 0, 0, 0, $pDriveLetter)
	For $sdsub = 1 To Ubound ($sdarray) - 1
		$sddisk    = $sdarray [$sdsub] [$pDriveLetter]
		$sdfs      = $sdarray [$sdsub] [$pPartFileSystem]
		$sdfamily  = $sdarray [$sdsub] [$pPartFamily]
		If $sddisk = "" Then ContinueLoop
		If $sdarray [$sdsub] [$pDriveMediaDesc] = "Flash" Then
			If CommonParms ($parmadvanced) Then	$sdstring &= $sddisk & "|"
			ContinueLoop
		EndIf
		If $sdfamily <> "Windows" And $sdfamily <> $sdefifamily     Then ContinueLoop
		If $sdfs <> "NTFS" And Not StringInStr ($sdfs, "FAT")       Then ContinueLoop
		If $sdfound = "" And FileExists ($sddisk & "\" & $sdsearch) Then $sdfound = $sddisk
		$sdstring &= $sddisk & "|"
	Next
	Return $sdfound
EndFunc

Func CommonCheckFirmDate ()
	If $firmwaremode <> "EFI" Or SettingsGet ($setwarnedfirmearly) <> $setno Then Return
	If $regbiosdate = "" Or StringRight ($regbiosdate, 4) >= $firmcutdate Then Return
	$cfdatedisp = TimeFormatDate ("", StringRight ($regbiosdate, 4) & StringLeft ($regbiosdate, 5), "", "daydate", "yes")
	$cfmsg  = "** Your EFI Firmware Date Is  " & $cfdatedisp & " **"                         & @CR & @CR
	$cfmsg &= "Please Note: The EFI firmware on this system is quite old."                   & @CR & @CR
    $cfmsg &= "EFI firmware written before " & $firmcutdate & " often causes boot problems." & @CR & @CR
	$cfmsg &= "The most common symptom is that your machine always"                          & @CR
	$cfmsg &= "boot Windows and the Grub2Win menu never appears."                            & @CR & @CR
	$cfrc  = CommonWarn ("EFI Firmware Issues", $setwarnedfirmearly, $cfmsg)
	If $cfrc = $IDCANCEL Then CommonEndIt ("Cancelled")
EndFunc

Func CommonGetBootFile ($gbfpathin)
	$gbffound  = ""
	$gbffileout = StringReplace ($gbfpathin, "/", "\")
	If StringMid ($gbffileout, 2, 2) = ":\" Then $gbffileout = StringTrimLeft ($gbffileout, 2)
	$gbffound = CommonSearchDrives ($gbffileout, $gbffound, $dummy)
	Return $gbffound & $gbffileout
EndFunc

Func CommonGetBootPath ($gbpfilein)
	If StringMid ($gbpfilein, 2, 2) = ":\" Then $gbpfilein = StringTrimLeft ($gbpfilein, 2)
	$gbppathout = StringReplace ($gbpfilein, "\", "/")
	Return $gbppathout
EndFunc

Func CommonNotepad ($cnnotefile, $cnnotetitle = "", $cncallerhandle = "", $cnhandlea = "", $cnhandleb = "")
	$cnnotehandle = $tera
	$cnpid        = ShellExecute ($notepadexec, $cnnotefile)
	If @error Then CommonEndIt ("Failed")
	If $cncallerhandle <> "" Then CommonWaitForNotepad ($cnpid, $cncallerhandle, $cnnotetitle, $cnhandlea, $cnhandleb)
	If $cnpid = 0 Or $cnnotehandle = 0 Then
		MsgBox ($mbwarnok, "** Notepad Error **",                                                    _
			"The Windows Notepad program did not initialize properly, run cancelled." & @CR  & @CR & _
			$cnnotefile & @CR & @CR & "RC=" & $cnpid & "-" & $cnnotehandle)
		Exit
	EndIf
	Return $cnpid
EndFunc

Func CommonWaitForNotepad ($wfnpid, $wfncallerhandle, $wfnnotetitle, $wfnhandlea = "", $wfnhandleb = "")
	GUISetBkColor  ($myred, $wfncallerhandle)
	$wfncallertitle = WinGetTitle ($wfncallerhandle)
	WinSetTitle    ($wfncallerhandle, "", "    ****  Waiting for the Notepad window to appear ****")
	$wfnnotehandle = CommonPIDGetWinHandle ($wfnpid)
	WinSetTitle    ($wfncallerhandle, "", "    ****  Waiting for you to finish editing the code in Notepad ****")
	WinSetTitle    ($wfnnotehandle, "", $wfnnotetitle)
	If $wfnhandlea <> "" Then GUICtrlSetState ($wfnhandlea, $guishowdis)
	If $wfnhandleb <> "" Then GUICtrlSetState ($wfnhandleb, $guishowdis)
	$wfnloc         = WinGetPos ($wfncallerhandle)
	If Not @error Then WinMove ($wfnnotehandle, "", $wfnloc [0] - 10, $wfnloc [1] - 10, $wfnloc [2], $wfnloc [3], 1)
	While ProcessExists ($wfnpid) And $wfnnotehandle <> 0
		Sleep (200)
	Wend
	WinSetTitle   ($wfncallerhandle, "", $wfncallertitle)
	If $wfnhandlea <> "" Then GUICtrlSetState ($wfnhandlea, $guishowit)
	If $wfnhandleb <> "" Then GUICtrlSetState ($wfnhandleb, $guishowit)
EndFunc

Func CommonCopyUserFiles ($uficonsonly = "")
	If $usercopied = "" Then CommonCopyUserIcons ()
	If $usercopied = "yes" Or $uficonsonly = "yes" Then Return
	DirCreate ($themetempback)
	FileCopy  ($userbackgrounds  & "\*.jpg", $themetempback & "\", 1)
	FileCopy  ($themebackgrounds & "\*.jpg", $themetempback & "\", 1)
	FileCopy  ($userclockfaces   & "\*.png", $themefaces    & "\", 1)
	FileCopy  ($userfonts        & "\*.*",   $fontpath      & "\", 1)
	$usercopied = "yes"
EndFunc

Func CommonCopyUserIcons ()
	$uihandle = FileFindFirstFile ($usericons & "\*.png")
	If @error Then Return
	$usericonscheck = "yes"
	While 1
		$uifile = FileFindNextFile ($uihandle)
		If @error Then ExitLoop
		$uioutfile = $uifile
		If StringInStr ($uioutfile, "icon-") Then
			$uioutfile = StringReplace ($uioutfile, "user-", "")
			$uioutfile = StringReplace ($uioutfile, "icon-", "")
			FileMove ($usericons & "\" & $uifile, $usericons & "\" & $uioutfile, 1)
		EndIf
		FileCopy ($usericons & "\" & $uioutfile, $iconpath & "\user-icon-" & $uioutfile, 1)
	Wend
	FileClose ($uihandle)
EndFunc

Func CommonPIDGetWinHandle ($gwhpid, $gwhtimeout = 10)
	For $gwhcount = 1 To $tera
		If $gwhcount > $gwhtimeout * 10 Then Return 0
		$gwhwinarray = WinList ()
		For $gwhsub = 1 To Ubound ($gwhwinarray) - 1
			$gwhwinhandle = $gwhwinarray [$gwhsub] [1]
			$gwhwinpid    = WinGetProcess ($gwhwinhandle)
			If $gwhwinpid = $gwhpid Then Return $gwhwinhandle
		Next
		Sleep (100)
	Next
EndFunc

Func CommonSetupCloseOut ()
	CommonWriteLog    ("End Setup - " & TimeLine ("", "", "yes"), "", "", "")
	BaseFuncArrayWrite   ($setuplogfile, $templogarray)
	FileClose         ($temploghandle)
	FileCopy          ($templogfile,  $setuplogfile, 1)
	If $setupstatus = "complete" Then
		FileCopy           ($setuplogfile,   $datapath & "\", 1)
		$costatshandle = FileOpen ($datapath & $statslogstring, $FO_OVERWRITE)
		CommonStatsDownload ($costatshandle)
		FileClose          ($costatshandle)
		FileCopy           ($downloadjulian, $datapath & "\", 1)
		FileCopy           ($windowstempgrub & $encryptstring, $storagepath & $encryptstring, 1)
		$cotype = "Setup"
		If CommonParms ($parmfromupdate)   Then $cotype = "Update"
		SettingsPut    ($setstattype, $cotype)
		CommonSaveListings ()
	EndIf
	FileDelete        ($downloadjulian)
EndFunc

Func CommonDonate ()
	$cdstatus   = SettingsGet ($setdonatestatus)
	$cdusecount = SettingsGet ($setusecount)
	If $cdstatus = "dontask" Or $cdstatus = "paypal" Then Return
	$cddonatejul = StringLeft (SettingsGet ($setdonatedate), 7)
	;MsgBox ($mbontop, "Donate", SettingsGet ($setdonatestatus) & @CR & $cdusecount & @CR & $cddonatejul & @CR & $todayjul)
	If $cdusecount < 5 Or $cdusecount = $unknown Or $cddonatejul > $todayjul Then Return
	BaseFuncGUIDelete ($handlemaingui)
	$cdhandlegui   = CommonScaleCreate ("GUI",    "", -1,   -1,   50, 85)
	GUISetBkColor  ($mymedblue, $cdhandlegui)
	$cdhandlemsg = CommonBorderCreate ($sourcepath & "\xxdonate.png", 3, 3, 44, 31, $dummy, "", 0.5)
    GUICtrlSetBkColor ($cdhandlemsg, $mymedgray)
	$cdhandlepaypal  = CommonScaleCreate ("Button", "Donate To Grub2Win Via PayPal",   9,  40, 33,    8)
	GUICtrlSetBkColor ($cdhandlepaypal, $mygreen)
	$cdhandleremind  = CommonScaleCreate ("Button", "Remind Me In 30 Days",           17,  65, 18,    4)
	GUICtrlSetBkColor ($cdhandleremind, $mymedblue)
	$cdhandledontask = CommonScaleCreate ("Button", "Don't Ask Me Again",             17,  75, 18,    4)
	GUICtrlSetBkColor ($cdhandledontask, $mymedblue)
	GUISetState (@SW_SHOW, $cdhandlegui)
	$cddatebump = 0
	$cdstatus   = ""
	While 1
		$cdgetmsg = GUIGetMsg ()
		Select
			Case $cdgetmsg  = $cdhandledontask
				$cdstatus   = "dontask"
			Case $cdgetmsg  = $GUI_EVENT_CLOSE
				$cddatebump = 7
				$cdstatus   = "closed"
			Case $cdgetmsg  = $cdhandleremind
				$cddatebump = 30
				$cdstatus   = "remind"
			Case $cdgetmsg  = $cdhandlepaypal
				$cdstatus   = "paypal"
				ShellExecute ($donateurl)
			Case Else
				ContinueLoop
		EndSelect
		ExitLoop
	Wend
	SettingsPut ($setdonatestatus, $cdstatus)
	SettingsPut ($setdonatedate, TimeFormatDate ($todayjul + $cddatebump, "", "", "juldatetime"))
	Sleep       (200)
EndFunc

Func CommonWriteLog ($wlrecord = "", $wladvance = 1, $wldisplay = "yes", $wlendchar = @CR)
	FileWrite ($temploghandle, $wlrecord & $wlendchar)
	If $wladvance = 2 Then
		_ArrayAdd ($templogarray, "")
		FileWrite ($temploghandle, $wlendchar)
	EndIf
	If $wldisplay <> "yes" Or CommonParms  ($parmautoinstall) Then Return
	_ArrayAdd ($templogarray, $wlrecord)
	If $setupinprogress = "" Then Return
	GuiCtrlSetData  ($setuphandlelist, " " & StringReplace ($wlrecord, @CR, "| ") & "|")
	GUICtrlSetState ($setuphandlelist, $guishowit)
EndFunc

Func CommonCheckRunning ($crdupname = "")
	FileDelete ($enqueuegeneric)
	If $duprunstatus <> "" Or CommonParms ($parmuninstall) Then Return
	If $crdupname <> "" And _Singleton ($crdupname, 1) = 0 Then
		BaseFuncGUIDelete ($upmessguihandle)
		$crduphdr = "Stamp = " & $stamptemp
		$crdupmsg = $crdupname & " Is Already Running !!" & @CR & @CR & "This Run Cannot Continue."
		MsgBox ($mbwarnok, $crduphdr, $crdupmsg)
		BaseFuncCleanupTemp ("CommonCheckRunningCancel", "Exit", "directory", $stamptemp)
	EndIf
	$duprunstatus = "Checked"
EndFunc

Func CommonEnqueue ($bemessage1 = "", $bemessage2 = "", $bemindelay = 750, $beheader = "")
	$behandle = FileOpen ($enqueuefile, $FO_OVERWRITE)
	FileWrite ($behandle, @ScriptName & "  " & @AutoItPID)
	FileClose ($behandle)
	;MsgBox (1, "Started", @AutoItPID & @CR & @CR & @ScriptName & @CR & @CR &  $enqueuefile, 30)
	CommonFlashStart ($bemessage1, $bemessage2, $bemindelay, $beheader)
	CommonFlashEnd ("")
	For $dummy = 1 To 300
		;MsgBox ($mbontop, "ENQ", FileExists ($enqueuegeneric))
		If Not FileExists ($enqueuegeneric) Then ExitLoop
		Sleep (100)
	Next
	;MsgBox (1, "Ended " & $dummy, @AutoItPID & @CR & @CR & @ScriptName)
	FileDelete ($enqueuegeneric)
EndFunc

Func CommonBCDError ($betext)
	$befile = $masterdrive & "\grub2win.error\BCD.diagnostic.txt"
	$bearray = BaseFuncArrayRead ($bcdprefix   & "detail.command.txt", "CommonBCDError")
	_ArrayInsert ($bearray, 1, @CR & @CR & "** Util String ** " & $bcdexec & @CR & @CR)
	_ArrayInsert ($bearray, 1, @CR & @CR & "** Error Type  ** " & $betext)
	_ArrayInsert ($bearray, 1, @CR & @CR & "** Program     ** " & @ScriptFullPath & "  Ver " & FileGetVersion (@ScriptFullPath))
	BaseFuncArrayWrite ($befile, $bearray)
	CommonHelp ("BCD Issues")
	$bemsg  = "Grub2Win Detected An Error In Your BCD." & @CR & @CR
	$bemsg &= $betext                                   & @CR & @CR & @CR  & @TAB
	$bemsg &= "A Diagnostic File Was Created."          & @CR & @CR & @TAB & $befile & @CR & @CR & @CR
	$bemsg &= "Refer to the BCD Issues help page for further details." & @CR  & @CR & "Run Cancelled."
	MsgBox ($mbwarnok, "** Severe BCD Error **", $bemsg)
	Exit
EndFunc

Func CommonBCDRun ($brcommand, $brtempfile = "temp", $brcheckerr = "yes")
	If $bcderrorfound <> "" Then Return 1
	Sleep (100)   ;100 ms delay to allow any previous BCD commands to complete
	If Not FileExists ($commandtemppath) Then DirCreate ($commandtemppath)
    $broutpath   = $bcdprefix & $brtempfile & ".command.txt"
	$brstring    = $bcdexec & " " & $brcommand
	$brrc        = ""
	$brlistarray = BaseFuncShellWait ($brstring, $broutpath, $brrc, "CommonBCDRun")
	_ArrayInsert ($brlistarray, 0, "")
	_ArrayInsert ($brlistarray, 0, "  The Command Is - bcdedit " & $brcommand)
	_ArrayInsert ($brlistarray, 0, "")
	_ArrayInsert ($brlistarray, 0, "")
	BaseFuncArrayWrite ($broutpath, $brlistarray)
	If $brcheckerr <> "" Then
		If $brrc <> 0 And Ubound ($brlistarray) < 30 Then
			$bcderrorfound = "yes"
			MsgBox ($mbwarnok, " ** BCD Command Failed **   " & $brrc & @CR & "  Error " & @error & "  " & $brtempfile, _
				"BCDExec " & $bcdexec & @CR & @CR & FileRead ($broutpath), 300)
			SetError (1)
		EndIf
	EndIf
	Return $brlistarray
EndFunc

Func CommonGetHelpPath ()
	If FileExists ($setupmasterpath & "\winhelp") Then Return $setupmasterpath & "\winhelp"
	Return $masterpath & "\winhelp"
EndFunc

Func CommonHelp ($bhtopic)
	WinClose      ($helptitle)
	WinWaitClose  ($helptitle, "", 10)
	$bhstring     = $helppath
	If $runtype = $parmsetup Then $bhstring = $setupmasterpath & "\winhelp"
	$bhstring    &= "\usermanual\" & StringStripWS ($bhtopic, $STR_STRIPALL) & ".html"
	ShellExecute  ($bhstring)
	If @error Then MsgBox ($mbwarnok, _
		"Grub2Win Help Error", "The Help HTML File Was Not Found" & @CR &@CR & $bhstring)
EndFunc

Func CommonGetLetterEFI ()
	$winefistatus = ""
	$winefiletter = ""
	Dim $efiassignlogarray [0]
	If $firmwaremode <> "EFI" Then Return ""
	If Not FileExists ($commandtemppath) Then DirCreate ($commandtemppath)
	$gleoutpath = $commandtemppath & "\mountvol.getletter.output.txt"
	$glrc       = ""
	$glearray   = BaseFuncShellWait ($mountvolexec, $gleoutpath, $glrc, "CommonGetLetterEFI")
	For $glesub = 1 To Ubound ($glearray) - 1
		$glerec = StringStripWS ($glearray [$glesub], 2)
		If Not StringInStr ($glerec, "EFI") Then ContinueLoop
		If StringRight ($glerec, 1) <> "\" Then ContinueLoop
		$winefiletter = StringRight ($glerec, 3)
		$winefiletter = StringLeft  ($winefiletter, 2)
		$winefistatus = "pre-mounted"
	Next
	If $winefiletter = "" Then $winefiletter = CommonEFIMountWin ()
EndFunc

Func CommonEFIMountWin ()
	If $firmwaremode <> "EFI" Then Return
	If $winefistatus <> "" And DriveStatus ($winefiletter) = "Ready" Then Return
	$mwletter   = CommonDriveLetter ()
	$mwoutpath  = $commandtemppath & "\mountvol.mount.output.txt"
	$mwstring   = $mountvolexec & " " & $mwletter & " /S"
	$mwrc       = ""
	$mwarrayout = BaseFuncShellWait ($mwstring, $mwoutpath, $mwrc, "CommonEFIMountWin", "yes")
	If $mwrc <> 0 Then
		$mwerror   = "Microsoft MountVol Error - Drive = " & $mwletter & "  RC = " & $mwrc
		_ArrayAdd ($efiassignlogarray, _StringRepeat ("_", 80))
		_ArrayAdd ($efiassignlogarray, "")
		_ArrayAdd ($efiassignlogarray, "New York Time = " & $nytimeus)
		_ArrayAdd ($efiassignlogarray, $mwerror)
		_ArrayConcatenate ($efiassignlogarray, $mwarrayout)
		Return
	EndIf
	$winefistatus = "mounted"
	Return $mwletter
EndFunc

Func CommonDriveLetter ($glpartarray = "")
	$glstring = "mnopqrstuvwxyz"
	$glarray  = DriveGetDrive ("ALL")
	For $glsub = 1 To StringLen ($glstring)
		$gldisk = StringMid ($glstring, $glsub, 1) & ":"
		If _ArraySearch ($glarray, $gldisk) >= 0 Then ContinueLoop
		If $glpartarray <> "" And _ArraySearch ($glpartarray, $gldisk, 0, 0, 0, 0, 0, 2) >= 0 Then ContinueLoop
		$glstring = StringReplace ($glstring, $gldisk, "")
		Return StringUpper ($gldisk)
	Next
	MsgBox ($mbwarnok, "Not enough available drive letters were found!", "Run Aborted")
	Exit
EndFunc

Func CommonGetBackupMode ()
	$bmstring = ""
	If $firmwaremode <> "EFI" Then $bmstring = "bios."
	Return $bmstring
EndFunc

Func CommonGetMasterEFI ()
	If $procbits = 64 Then Return "bootx64"
	Return "bootia32"
EndFunc

Func CommonGetSecureBoot ()
	If $firmwaremode = "EFI" And RegRead ($regkeysecure, "UEFISecureBootEnabled") = 1 Then Return "Enabled"
	Return "Not Enabled"
EndFunc

Func CommonGetSetupPath ()
	Select
		Case $runtype <> $parmsetup
			Return ""
		Case FileExists (@ScriptDir & "\WinSource\Grub2Win.exe")
			Return @ScriptDir
		Case FileExists (@ScriptDir & "\Grub2Win.exe")
			Return StringTrimRight (@ScriptDir, 10)
		Case Else
			Return $windowstempgrub & "\install"
	EndSelect
EndFunc

Func CommonCheckEmail (ByRef $ceaddress)
	$ceaddress = StringStripWS ($ceaddress, $STR_STRIPALL)
	$cepos     = StringInStr   ($ceaddress, "@")
    If $cepos < 2 Then Return
	If CommonStringCount ($ceaddress, "@") > 1 Then Return
	$cesite = StringTrimLeft ($ceaddress, $cepos)
    TCPStartup  ()
    $ceaddr = TCPNameToIP ($cesite)
	TCPShutdown ()
	If $ceaddr = "" Then Return
	Return 1
EndFunc

Func CommonStringCount ($scstring, $scsearch)
	StringReplace ($scstring, $scsearch, "")
	Return @extended
EndFunc

Func CommonSetDefault (ByRef $sdfield, $sdvalue = "", $sdreset = "")
	If $sdfield = "" Or $sdreset <> "" Then $sdfield = $sdvalue
EndFunc

Func CommonCalcDuration ($cdstarttimer, $cddurticks = "")
	$cdmilsecs = (Int (TimeTickDiff ($cdstarttimer))) + 500
	If $cddurticks <> "" Then $cdmilsecs = $cddurticks
	Return TimeFormatTicks ($cdmilsecs)
EndFunc

Func CommonInetRead ($irurl, $irdesc, ByRef $irstatus, $irtimeoutsec = 1)
	Local $irreturn, $irtickdiff
	$irtimeoutticks = $irtimeoutsec * 1000
	$irfile   = $windowstempgrub & "\inet.work." & $irdesc & ".txt"
	FileDelete ($irfile)
	$irtickstart   = TimeTickInit ()
	;Sleep (2000)                                ; To Test Load
	$irhandle      = InetGet ($irurl, $irfile, _
		$INET_FORCERELOAD + $INET_IGNORESSL + $INET_FORCEBYPASS, $INET_DOWNLOADBACKGROUND)
	Do
		Sleep (100)
		$irtickdiff = TimeTickDiff ($irtickstart)
	Until        InetGetInfo ($irhandle, $INET_DOWNLOADCOMPLETE) = True Or $irtickdiff > $irtimeoutticks
	$irerrcode = InetGetInfo ($irhandle, $INET_DOWNLOADERROR)
	InetClose  ($irhandle)
	Select
		Case $irerrcode     = 0 And $irtickdiff < $irtimeoutticks
			 $irstatus      = "Conn"
			 $irreturn      = BinaryToString (BaseFuncSingleRead ($irfile))
			 If StringInStr ($irreturn, "<") Then $irstatus = "Error - Corrupt"
		Case $irerrcode     = 0
			$irstatus  = "Timeout " & $irtimeoutsec & " /"
		Case Else
			 $irstatus = "Error-" & $irerrcode & " - " & $irtimeoutsec & " /"
	EndSelect
	If $irstatus <> "Conn" Then $irreturn = ""
	$irstatus  = BaseFuncCapIt ($irdesc & " " & $irstatus)
	Return SetError ($irerrcode, "", $irreturn)
EndFunc

Func CommonGetGeo ($ggtimeout = 3, $ggcheckerror = "yes")
	Dim $geoarray [4]
	If  FileExists ("C:\" & $masterstring & $settingsstring) Then SettingsLoad ("C:\" & $masterstring & $settingsstring)
	$geoipaddress  = SettingsGet ($setstatipaddress)
	$geocountry    = SettingsGet ($setstatcountry)
	$georegion     = SettingsGet ($setstatregion)
	$geocity       = SettingsGet ($setstatcity)
	$geotimezone   = SettingsGet ($setstattimezone)
	$geotimeoffset = SettingsGet ($setstattimeoffset)
	$gglastjul     = StringLeft  (SettingsGet ($setdailylastused), 7)
	$statusgeo     = SettingsGet ($setstatusgeo)
	If $gglastjul  = $unknown Then $gglastjul = 0
	If $geotimezone = $unknown Or $runtype <> "Grub2Win" Or Not StringInStr ($statusgeo, "Conn") _
		Or $todayjul - $gglastjul > 30 Or CommonParms ($parmuninstall) Then
		For $gginetread = 1 To 6
			If $ggtimeout > 1 Then CommonFlashStart ("Checking Internet Connection - Takes Up To " & $ggtimeout & " Seconds", "", "", "", "keep")
			$ggtimeinit     = TimeTickInit      ()
			$ggdata			= CommonInetRead      ($locationurl, "internet", $statusgeo, $ggtimeout)
			$ggduration     = TimeFormatSeconds ($ggtimeinit)
			$statusgeo     &= " " & $ggduration
			If $ggcheckerror = "" Then ExitLoop
			If StringInStr ($statusgeo, "Conn") Then ExitLoop
			If Not StringInStr ($runtype, "Download") And Not StringInStr ($runtype, "Setup") And Not $geocountry = $unknown Then ExitLoop
			$gglicstatus = SecureCheckLicensed ()
			If $gglicstatus = $licensed Then ExitLoop
			If $gglicstatus <> "" Then MsgBox ($mbontop, "", $gglicstatus, 5)
			$ggtimeout  = 5 * $gginetread
			If CommonParms ("Uninstall") Then Return
			$gginetmsg  = "Please Check Your Internet Connection" & @CR & "And Firewall Settings" & @CR & @CR & @CR
			$gginetmsg &= "Status Code = " & $statusgeo & @CR & @CR & @CR & 'Click "Yes" To Retry '
			If StringInStr ($statusgeo, "Timeout") Then $gginetmsg &= 'For ' & $ggtimeout & ' Seconds'
			$gginetmsg &=  @CR & @CR & 'Click "No" To Cancel'
			If $gginetread < 6 Then
				$gginetrc = MsgBox ($mbwarnyesno, "Internet Connection Error     Retry Attempt " & $gginetread & " Of 3", $gginetmsg)
				If $gginetrc = $IDYES Then ContinueLoop
			EndIf
			MsgBox ($mbwarnok, "", "Grub2Win Run Cancelled Due To Internet Errors" & @CR & "Retry Attempts = " & $gginetread - 1, 5)
			BaseFuncCleanupTemp ("CommonGetGeo")
		Next
		$ggretrys = $gginetread - 1
		If $ggretrys > $geototalretrys Then $geototalretrys = $ggretrys
		$ggstatusput    = $statusgeo
		If $runtype <> "Grub2Win" Then  $ggstatusput = ""
		SettingsPut     ($setstatusgeo, $ggstatusput)
		$locinarray     = StringSplit ($ggdata, @LF, $STR_NOCOUNT)
		If Not @error And Ubound ($locinarray) > 8 Then
			;_ArrayDisplay ($locinarray)
			$geoipaddress   = $locinarray [8]
			$geocountry     = $locinarray [1]
			$geocity        = $locinarray [5]
			$georegion      = $locinarray [4]
			$geotimezone    = $locinarray [6]
			$geotimeoffset  = $locinarray [7]
			$geotimezone    = $geotimezone & "   " & TimeOffset ()
			SettingsPut    ($setstattimezone,   $geotimezone)
			SettingsPut    ($setstattimeoffset, $geotimeoffset)
			SettingsPut    ($setstatcity,       $geocity)
			SettingsPut    ($setstatregion,     $georegion)
			SettingsPut    ($setstatcountry,    $geocountry)
			SettingsPut    ($setstatipaddress,  $geoipaddress)
		EndIf
	EndIf
	If $geocountry = $unknown And $regcountry <> "" Then
		$geocountry = $regcountry
		SettingsPut ($setstatcountry, $geocountry)
	EndIf
	$geoarray [$gIPAddress] = $geoipaddress
	$geoarray [$gCountry]   = $geocountry
	$geoarray [$gRegion ]   = $georegion
	$geoarray [$gCity]      = $geocity
	If StringInStr ($statusgeo, "Conn") Then $timezonedisplay = $geotimezone
EndFunc

Func CommonScaleIt ()
	$siwidth    = Int (@DesktopHeight * 1.30)
	If $siwidth >      @DesktopWidth Then $siwidth = @DesktopWidth
	$siheight   = Int ($siwidth * 0.75)
	$scalehsize = Int(((0.9 * $siwidth)  / 100) * 85)
	$scalevsize = Int(((0.9 * $siheight) / 100) * 90)
	If $scalehsize < 763 Or $scalevsize < 605 Or StringInStr ($CmdLineRaw, $parmlowresmode) Then
		$scalehsize = 763
		$scalevsize = 605
	EndIf
	$scalepcthorz      = $scalehsize / 100
	$scalepctvert      = $scalevsize / 100
	$graphmessage      = $graphsize & " (" & $scalehsize & "x" & $scalevsize & ")"
	$fontsizenormal    = StringLeft ($scalehsize / 90, 4)
	$fontsizesmall     = $fontsizenormal * 0.8
	$fontsizemedium    = $fontsizenormal * 1.3
	$fontsizelarge     = $fontsizenormal * 2.0
	;MsgBox ($mbontop, "Scale", $scalehsize & @CR & @CR & $fontsizenormal & @CR & CommonParms ($parmlowresmode))
EndFunc

Func CommonScaleCreate ($scguitype, $sctext, $scleft, $sctop, $scwidth = "", $scheight = $scalehsize, $scstyle = Default, $scexstyle = Default, $scguiparent = Default)
	If $scleft > 100 Or $sctop > 100 Or $scwidth > 100 Or $scheight > 100 Then
		;CommonShowError ("ScaleCreate Error" & @CR & $scleft & @CR & $sctop & @CR & $scwidth & @CR & $scheight)
	EndIf
	$schandle = ""
	$scleft   = Int ($scalepcthorz * $scleft)
	$sctop    = Int ($scalepctvert * $sctop)
	$scwidth  = Int ($scalepcthorz * $scwidth)
	$scheight = Int ($scalepctvert * $scheight)
	If $scleft   < 0 Then $scleft   = -1
	If $sctop    < 0 Then $sctop    = -1
	If $scwidth  < 1 Then $scwidth  =  1
	If $scheight < 1 Then $scheight =  1
	Select
		Case $scguitype  = "GUI"
			$schandle = GUICreate           ($sctext, $scwidth, $scheight, $scleft, $sctop, $scstyle, $scexstyle, $scguiparent)
			            GUISetFont          ($fontsizenormal, 0, 0, "", $schandle)
		Case $scguitype  = "Label"
			$schandle = GUICtrlCreateLabel  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Button"
			$schandle = GUICtrlCreateButton ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Checkbox"
			$schandle = GUICtrlCreateCheckbox ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Input"
			$schandle = GUICtrlCreateInput  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Edit"
			$schandle = GUICtrlCreateEdit   ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Combo"
			$schandle = GUICtrlCreateCombo  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Picture"
			$schandle = GUICtrlCreatePic    ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Group"
			$schandle = GUICtrlCreateGroup  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Radio"
			$schandle = GUICtrlCreateRadio  ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "List"
			$schandle = GUICtrlCreateList   ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "Progress"
			$schandle = GUICtrlCreateProgress ($scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case $scguitype  = "PicturePNG"
			$schandle = SpecFuncGUICtrlPicCreate ($sctext, $scleft, $sctop, $scwidth, $scheight, $scstyle, $scexstyle)
		Case Else
			BaseFuncShowError ("Invalid type = " & $scguitype, "CommonScaleCreate")
	EndSelect
	Return $schandle
EndFunc

Func CommonBorderCreate ($bcimagefile, $bcleft, $bctop, $bcwidth, $bcheight, ByRef $bctexthandle, $bctext = "", $bcpix = 0.6)
	$bcborderhandle  = CommonScaleCreate ("Label", "", $bcleft, $bctop, $bcwidth + $bcpix, $bcheight + $bcpix)
	$bcinleft        = $bcleft   + $bcpix
	$bcintop         = $bctop    + $bcpix
	$bcinwidth       = $bcwidth  - $bcpix
	$bcinheight      = $bcheight - $bcpix
	$borderpichandle = CommonScaleCreate ("PicturePNG", $bcimagefile, $bcinleft, $bcintop, $bcinwidth, $bcinheight)
	If $bctext <> "" Then $bctexthandle = CommonScaleCreate _
		("Label", $bctext, $bcinleft - $bcpix, $bctop + $bcheight + $bcpix, $bcinwidth + ($bcpix * 2), 8, $SS_CENTER)
	Return $bcborderhandle
EndFunc

Func CommonLabelJustify ($ljhandle, $ljtext, $ljvertlines)
	$ljbumper = Int ($ljvertlines / 2) - CommonStringCount ($ljtext, @CR) + 1
    ;MsgBox ($mbontop, "Lines", $ljtext & @CR & CommonStringCount ($ljtext, @CR) & @CR & $ljbumper)
	If $ljbumper > 0 Then $ljtext = _StringRepeat (@CR, $ljbumper) & $ljtext
	GUICtrlSetData ($ljhandle, $ljtext)
EndFunc

Func CommonGetColor ()
	If StringInStr ($CmdLineRaw, "Quiet") Or StringInStr ($CmdLineRaw, "Help")  Then Return ""
	If $runtype = "Grub2Win" Then Return $mygreen
	Return $mymedblue
EndFunc

Func CommonInitMessage ()
	If $runcolor = "" Then Return
    Global $upmessguihandle, $upmessgstart, $upmessagevert = 8
	BaseFuncGUIDelete      ($upmessguihandle)
	$upmessguihandle   = CommonScaleCreate ("GUI", "", -1,  -1, 47, 36, "", $WS_EX_STATICEDGE)
	CommonFlashStart     ("** Starting " & $runtype & " **", "", "", "", "keep")
EndFunc

Func CommonFlashStart ($fstext1 = "", $fstext2 = "", $fsmindelay = 750, $fsheader = "Update In Progress", $fskeep = "")
	If $runcolor = "" Or Eval ("flashstatus") = "off" Then Return
	If $fskeep  <> "" Then
		GUISetBkColor       ($runcolor, $upmessguihandle)
		GUICtrlSetBKColor   ($upmessguihandle, $runcolor)
	Else
		BaseFuncGUIDelete ($upmessguihandle)
		$upmessguihandle  = CommonScaleCreate ("GUI", "", -1,  -1, 47, 36, "", $WS_EX_STATICEDGE + $WS_EX_TOPMOST)
		$upmessagevert = 8
	EndIf
	If $fstext1 <> "" Then CommonScaleCreate ("Label", $fstext1, 1, $upmessagevert + 3, 44, 6, $SS_CENTER)
	If $fstext2 <> "" Then CommonScaleCreate ("Label", $fstext2, 1, $upmessagevert + 6, 44, 6, $SS_CENTER)
	$upmessagevert += 3
	;MsgBox ($mbontop, "Label " & $upmessagevert, $upmessguihandle & @CR & $fstext1 & @CR & $fstext2 & @CR & $fskeep)
	GUISetState      (@SW_SHOW,  $upmessguihandle)
	GUISetBkColor    ($runcolor, $upmessguihandle)
	$upmessgstart    = TimeTickInit ()
	$upmessgmindelay = $fsmindelay
EndFunc

Func CommonFlashEnd ($feendmessage = "*** EFI Updates Are Complete ***", $fesleep = 750)
	If CommonParms <> ($parmquiet) And $upmessgstart <> "" Then
		While TimeTickDiff ($upmessgstart) < $upmessgmindelay
			Sleep (100)
		Wend
		If $feendmessage <> "" Then
			GUICtrlSetData ($upmesstexthandle1, $feendmessage)
			GUICtrlSetData ($upmesstexthandle2, "")
			Sleep ($fesleep)
		EndIf
		BaseFuncGUIDelete ($upmessguihandle)
	EndIf
	$upmessgstart    = ""
	$upmessgmindelay = ""
	$upmessagevert   = 0
EndFunc

Func CommonFlashButton ($fbhandle, ByRef $fbcolorhigh, $fboffset = 30)
	$fbinterval      = Int (TimeTickDiff ($starttimetick) / 1000)
	If $fbinterval   = $flashbuttonlast Then Return $fbcolorhigh
	$flashbuttonlast = $fbinterval
	$fbcolornew      = $fbcolorhigh
	If $fbcolorhigh = "" Then
		$fbcolorhigh = SpecFuncGUICtrlGetBkColor ($fbhandle)
		$fbred       = _WinAPI_GetRValue ($fbcolorhigh)
		$fbgreen     = _WinAPI_GetGValue ($fbcolorhigh)
		$fbblue      = _WinAPI_GetBValue ($fbcolorhigh)
		If $fbred    - $fboffset >= 0 Then $fbred   -= $fboffset
		If $fbgreen  - $fboffset >= 0 Then $fbgreen -= $fboffset
		If $fbblue   - $fboffset >= 0 Then $fbblue  -= $fboffset
		$fbcolornew  = _WinAPI_RGB ($fbred, $fbgreen, $fbblue)
	Else
		$fbcolorhigh = ""
	EndIf
	;MsgBox ($mbontop, "Color", $fbcolornew)
	GUICtrlSetBkColor ($fbhandle, $fbcolornew)
	Return $fbcolorhigh
EndFunc

Func CommonQuestion ($bqtype, $bqheader = "", $bqtext1 = "", $bqtext2 = "", $bqaction = "")
	If CommonParms ($parmquiet) Then Return 1
	$bqrc = MsgBox ($bqtype, $bqheader, $bqtext1 & " " & $bqaction & @CR & @CR & $bqtext2)
	If $bqrc = $IDYES Or $bqrc = $IDOK Or $bqrc = $IDRETRY Then Return 1
	Return 0
EndFunc

Func CommonGUIPause ($gpclosehandle, $gpokhandle = "")
	Do
		$gpstatus = GUIGetMsg ()
	Until $gpstatus <> "" And ($gpstatus = $GUI_EVENT_CLOSE Or $gpstatus = $gpclosehandle Or $gpstatus = $gpokhandle)
	Return $gpstatus
EndFunc

Func CommonPathToWin ($twinpath)
	$twoutpath = StringReplace ($twinpath, "/",       "\")
	$twoutpath = StringReplace ($twoutpath, " \grub2\",        " " & $masterpath & "\")
	$twoutpath = StringReplace ($twoutpath, " ($root)\grub2\", " " & $masterpath & "\")
	$twoutpath = StringReplace ($twoutpath, "$prefix",        $masterpath)
	$twoutpath = StringReplace ($twoutpath, "$cmdpath",       $masterpath & "\" & $bootmandir)
	$twoutpath = StringStripWS (StringReplace ($twoutpath, "source ", ""), 7)
	;MsgBox ($mbontop, "Path To Win", $twinpath & @CR & @CR & $twoutpath)
	Return $twoutpath
EndFunc

Func CommonParms ($cpparm, $cpvalue = "")
	$cploc = _ArraySearch ($parmarray, $cpparm)
	If $cpvalue = "" Then
		If @error Then Return
		$parmvalue = $parmarray [$cploc] [1]
		Return 1
	Else
		If @error Then
			_ArrayAdd ($parmarray, $cpparm & "|" & $cpvalue)
		Else
			$parmarray [$cploc] [1] = $cpvalue
		EndIf
	EndIf
EndFunc

Func CommonParmUpdate ()
	$puerrormsg     = ""
	$parmstringinbox = $parmstring
	$parmstringwork  = $parmstring
	$parmarraywork   = $parmarray
	$puname          = BaseFuncCapIt ($runtype)
	$pustartmsg      = $parmsyntax
	$puheader        = "Enter " & $puname & " Parms"
	$pustartmsg     &= @CR & @CR & @CR & 'Click "OK" when you are done.          '
	$pustartmsg     &= $puname & ' will then restart with your selected parms.'
	While 1
		$pudisplaymsg = $pustartmsg & $puerrormsg
		If Not @Compiled Then $pudisplaymsg &= @CR & @CR & @CR & @CR & @TAB & "**** Not Compiled For Restart ****    " & @ScriptName
		$parmstringinbox = InputBox ($puheader, $pudisplaymsg, StringStripWS ($parmstringinbox, 7) & " ", "", 600, 550)
		If @error = 1 Then
			If $puerrormsg = "" Then Return
			$puerrormsg    = ""
			ContinueLoop
		EndIf
		$puerrormsg = CommonParmsParse ($parmstringinbox)
		If $puerrormsg <> "" Then ContinueLoop
		If StringStripWS ($parmstringinbox, 8) = "" Then $parmstringwork = ""
		If $puerrormsg = "" Then ExitLoop
	Wend
	If $runtype = $parmsetup And Not StringInStr ($parmstringwork , $parmsetup) Then $parmstringwork &= " " & $parmsetup
	$pumessage  = "Now Restarting"
	If StringStripWS ($parmstringwork, 7) = $parmstring Then _
		$pumessage &= @CR & @CR & @CR & @CR & "** Note That The Parms Are Unchanged **" & @CR & @CR
	$puoriginal = $parmstring
	$punewmsg   = StringStripWS ($parmstringwork, 7)
	If $punewmsg     = "" Then $punewmsg   = "** None **"
	If $parmstring   = "" Then $puoriginal = "** None **"
	$purc = MsgBox ($mbinfookcan, "** Restarting " & $puname & " **", $pumessage & @CR & @CR & "Original Parms = " & $puoriginal & _
		@CR & @CR & "Parms For Restart = " & $punewmsg & @CR & @CR & @CR & 'Click "OK" or "Cancel"')
	If $purc <> $IDOK Then Return
	CommonQuickRestart ($parmstringwork)
EndFunc

Func CommonParmsParse ($ppparmstring = "", $ppcommandline = "")
	$parmlog        = ""
	$ppsetup        = ""
	$pperrmsg       = ""
	$parmstringwork = ""
	Dim $parmarraywork [0] [2]
	If $ppparmstring = "" Then
		$ppparsearray = $CmdLine
		$ppparmstring = StringReplace ($CmdLineRaw, '"' & @ScriptFullPath & '"', "")
	Else
		$ppparsearray = StringSplit   ($ppparmstring & " ", " ")
		If @error Then Dim $ppparsearray [0]
	EndIf
	If  StringInStr ($ppparmstring, $parmsetup)      Or StringInStr ($ppparmstring, $parmautoinstall) Or _
		StringInStr ($ppparmstring, $parmcodeonly) Then $ppsetup = $parmsetup
	If Ubound ($ppparsearray) = 0 Then Return $parmarraywork
	For $ppsub = 1 To Ubound ($ppparsearray) - 1
		$pprec           = $ppparsearray [$ppsub]
		$ppparm          = $pprec
		$pperrmsg       &= CommonParmValidate ($pprec, $ppsetup, $parmarraywork, $ppparm)
		$parmstringwork &= $ppparm & " "
		If CommonStringCount ($pperrmsg, @CR) > 4 Then
			$pperrmsg   &= "** Too Many Errors - Parm Scan Abandoned **"
			ExitLoop
		EndIf
	Next
	If $pperrmsg <> "" Then
		$pperrmsg =	@CR & @CR & @CR & 'The Parms String Submitted Is:  "' & $ppparmstring & '"' & @CR & @CR & @CR & @TAB & _
		'** Parm Errors **' & @CR & @CR & $pperrmsg
		If $ppcommandline = "" Then Return $pperrmsg
		MsgBox ($mbontop, "** Invalid Parm **", $parmsyntax & @CR & @CR & $pperrmsg)
		Exit 99
	EndIf
	;_ArrayDisplay ($ppparsearray, $parmstring)
	$parmlog = StringStripWS ($parmlog, 7)
	Return $pperrmsg
EndFunc

Func CommonQuickRestart ($qrparms = "")
	BaseFuncUnmountWinEFI ()
	Run  ('"' & @ScriptFullPath & '" ' & $qrparms)
	Exit
EndFunc

Func CommonParmValidate ($pvstring, $pvsetup, ByRef $pvarray, ByRef $pvrec)
	If $pvstring = $parmhelp Then
		CommonHelp ("Automatic Setup and Parms")
		MsgBox ($mbontop, "Grub2Win Parm Help", $parmsyntax)
		Exit
	EndIf
	$pverrmsg   = ""
	$pvvalue    = ""
	$pvstripped = $pvstring
	$pvloc      = StringInStr ($pvstring, "=")
	If $pvloc  <> 0 Then
		$pvstripped = StringLeft     ($pvstring, $pvloc - 1)
		$pvvalue    = StringTrimLeft ($pvstring, $pvloc)
	EndIf
	$pventry    = _ArraySearch ($parmmaster, $pvstripped)
	If @error Then
		$pverrmsg &= '"' & $pvstripped & '"' & @TAB & 'Is Not A Valid Parm' & @CR & @CR
	Else
		$pvparm = $parmmaster [$pventry] [0]
		$pvrec           = StringReplace ($pvrec,           $pvparm, $pvparm)
		$parmstringinbox = StringReplace ($parmstringinbox, $pvparm, $pvparm)
		If $parmmaster [$pventry] [3] = $parmsetup And $pvsetup = "" Then _
			$pverrmsg &= '"' & $pvparm & '"   Must be used with the "' & $parmsetup & '" or "' & $parmautoinstall & '" parm' & @CR & @CR
		If StringInStr ($parmstringwork, $pvstripped) Then $pverrmsg &= '"' & $pvparm & '"   Is A Duplicate Parm' & @CR & @CR
	EndIf
    If $pvloc > 0 And $pventry >= 0 Then
		Select
			Case $pvvalue = ""
													 	   $pverrmsg &= '"' & $pvparm & '"   The "=" Must Be Followed By A Value'            & @CR & @CR
			Case Not StringInStr ($parmmaster [$pventry] [5], '"' & $pvvalue & '"')
				Select
					Case $pvparm = $parmreboot And StringIsDigit ($pvvalue)
					Case StringInStr ($parmmaster   [$pventry] [5], "example") And StringInStr ($pvvalue, ":")
						If $pvparm = $parmdrive Then
							If Not FileExists ($pvvalue)       Then $pverrmsg &= '"' & $pvparm & '"   Disk Drive '   & $pvvalue & ' Is Not Available'               & @CR & @CR
							If $pvvalue & "\grub2\" = $runpath Then $pverrmsg &= '"' & $pvparm & '"   Setup Target ' & $pvvalue & '\grub2 - Overwrite Not Allowed'  & @CR & @CR
						EndIf
					Case Else
						                                  $pverrmsg &= '"' & $pvparm & '"   Value Must Be ' & $parmmaster   [$pventry] [5]    & @CR & @CR
				EndSelect
			Case Else
		EndSelect
	Else
		If $pverrmsg = "" And  $parmmaster [$pventry] [1] <> "" Then $pverrmsg &= '"' & $pvparm & '"   Must Be Followed By "=" And A Value' & @CR & @CR
	EndIf
	If $pverrmsg = "" Then
		_ArrayAdd ($pvarray, $pvparm & "|" & $pvvalue)
		$parmlog &= $pvparm & "   "
	EndIf
	Return $pverrmsg
EndFunc

Func CommonParmTemplate ()
	Dim $psarray [0] [6]
    _ArrayAdd ($psarray, $parmadvanced     & "|||"  & "StandAlone" & "|" & "Valid Standalone Parms Are:" & @CR & @CR & @CR & "     ")
	_ArrayAdd ($psarray, $parmhelp         & "|||"  & "StandAlone" & "|" & "    ")
	_ArrayAdd ($psarray, $parmlowresmode   & "|||"  & "StandAlone" & "|" & "    ")
	_ArrayAdd ($psarray, $parmquiet        & "|||"  & "StandAlone" & "|" & "    ")
	_ArrayAdd ($psarray, $parmreboot       & "|=||" & "StandAlone" & "|" & "    " & '|A Number or "query" or "no"')
	_ArrayAdd ($psarray, $parmuninstall    & "|||"  & "StandAlone" & "|" & "    ")
	If $runtype = $parmsetup Then
		_ArrayAdd ($psarray, $parmsetup        & "|||"  & "StandAlone" & "|" & @CR & @CR & @CR & @CR & @CR & "Valid Setup Parms Are:" & @CR & @CR & @CR & "     ")
		_ArrayAdd ($psarray, $parmautoinstall  & "|||"  & "StandAlone" & "|" & "")
		_ArrayAdd ($psarray, $parmautoresdir   & "|=||" & "Setup"      & "|" & @CR & @CR & @CR & "          " & '|A Directory   example autoresdir=C:\temp')
		_ArrayAdd ($psarray, $parmdrive        & "|=||" & "Setup"      & "|" & "    " & '|A Drive   example drive=C:')
		_ArrayAdd ($psarray, $parmcodeonly     & "|||"  & "Setup"      & "|" & "    ")
		_ArrayAdd ($psarray, $parmshortcut     & "|=||" & "Setup"      & "|" & "    " & '|"yes" or "no"')
		If $firmwaremode = "EFI" Then _ArrayAdd ($psarray, $parmrefreshefi   & "|||"  & "Setup"  & "|" & "    ")
	EndIf
	_ArrayAdd ($psarray, $parmcleanupdir   & "|=||" & "UnDoc"      & '||A Directory   example cleanupdir=C:\temp')
   	_ArrayAdd ($psarray, $parmfromupdate   & "|||"  & "UnDoc")
	_ArrayAdd ($psarray, $parmbcdtest      & "|||"  & "UnDoc")
	If $bootos <> $xpstring Then _ArrayAdd ($psarray, $parmefiaccess & "|||" & "UnDoc")
	$psarray [7] [4] = " | "
	;_ArrayDisplay ($psarray)
	Return  $psarray
EndFunc

Func CommonParmSyntax ($psarray)
	$psparms  = ""
	For $pssub = 0 To Ubound ($psarray) - 1
		If $psarray [$pssub] [3] = "UnDoc" Then ContinueLoop
		$psparms &= $psarray [$pssub] [4] & $psarray [$pssub] [0] & $psarray [$pssub] [1]
	Next
	Return $psparms
EndFunc

Func CommonCheckResolution ()
	If @DesktopWidth < 800 Or @Desktopheight < 700 Then
		$pamsg  = "The minimum recommended display size is 800 x 700"                         & @CR & @CR
		$pamsg &= "Your current display setting is " & @DesktopWidth & " x " & @DesktopHeight & @CR & @CR
		$pamsg &= "Grub2Win screens may not display properly"                                 & @CR & @CR & @CR
		$pamsg &= 'Click "OK" to continue anyway, or click "Cancel"'
		$parc  = MsgBox ($mbwarnokcan, "***  Grub2Win Warning  ***", $pamsg, 60)
		If $parc <> $IDOK Then Return 0
	EndIf
	Return 1
EndFunc

Func CommonFileDialog ($fdtitle, ByRef $fdinitdir, $ftfilter = "", $ftoptions = 0, $ftdefault = "", $fthwnd = "")
	Dim $fdarray [0]
	Local $fddrive, $fdfolder, $fdfile, $fdext
	$fdstring = FileOpenDialog ($fdtitle, $fdinitdir, $ftfilter, $ftoptions, $ftdefault, $fthwnd)
	If @error Then Return $fdarray
	_ArrayAdd ($fdarray, $fdstring)
	If Ubound ($fdarray) = 1 Then
		_PathSplit ($fdstring, $fddrive, $fdfolder, $fdfile, $fdext)
		$fdarray [0] = StringTrimRight ($fddrive & $fdfolder, 1)
		_ArrayAdd ($fdarray, $fdfile & $fdext)
	EndIf
	$fdinitdir = $fdarray [0]
	Return $fdarray
EndFunc

Func CommonReleaseFormat ($rfarray, $rfshowtime = "")
	If Not IsArray ($rfarray) Then Return ""
	$rfstring  = $rfarray [$iVersion]
	If $progexistversion <> "" And $progexistversion = $basrelcurr Then $rfstring &= "   Build " & $rfarray [$iBuild]
	$rfstring  = BaseFuncPadRight ($rfstring, 26)
	$rfstamp   = BaseFuncPadRight ($rfarray [$iDate], 28)
	If $rfshowtime <> "" Then $rfstamp = _
		BaseFuncPadRight ($rfarray [$iDate] & " At " & $rfarray [$iTime], 35)
	$rfstring &= $rfstamp  & $rfarray [$iJul] & @TAB
	$rfage     = $nyjulian - $rfarray [$iJul]
	If $rfage  < 0 Then $rfage = 0
	$rfstring &= TimeFormatDays ($rfage)
	Return $rfstring
EndFunc

Func CommonStatsBuild ($cstype = "Daily", $csupdatesettings = "yes", $csinetget = "yes")
	$cstesting       =  ""
	$csuserstatus    =  ""
	$csrestflag      =  $securesuffix
	$csinstallupdate =  ""
	$csforcedaily    =  ""
	If $csinetget <> "" Or $statuszulu = "" Then TimeGetCurrent  ("ZuluNet")
	If $csinetget <> "" Then CommonGetGeo (10, "")
	If $progexistversion > $basrelcurr Then $progexistversion = ""
	If $cstype =  "Update" And $progexistversion = "" Then Return
	If $cstype <> "Daily" And $cstype <> "Restrict" And $cstype <> $parmuninstall Then
		$csuserstatus = $installstatus & "."
		If $progexistversion = $basrelcurr Then $csuserstatus = "Refresh."
	EndIf
	;MsgBox ($mbontop, "New", $csuserstatus & @CR & $cstype & @CR & $progrunversion & @CR & $progcurrversion)
	$csinstalled    = SettingsGet ($setinstalldate)
	If $csinstalled = $unknown Then
		$csinstalled     = $nytimefulljul
		$csinstallupdate = "yes"
	EndIf
	$csinstalledjul = StringLeft  ($csinstalled, 7)
	$cslastused     = SettingsGet ($setdailylastused)
	$cslastusedjul  = StringLeft  ($cslastused, 7)
	If $cslastusedjul < $csinstalledjul Then
		$csinstalled     = TimeFormatDate ($cslastusedjul, "", "", "juldatetime")
		$csinstallupdate = "yes"
	EndIf
	If $cstype <> "Download" And $csinstallupdate <> "" Then SettingsPut ($setinstalldate, $csinstalled)
	$csinstjulian   = StringLeft  ($csinstalled, 7)
	$csusecount     = SettingsGet ($setusecount)
	If $csusecount  = $unknown Then $csusecount = 0
	$csinstage      = $nyjulian - $csinstjulian
	$csstatage      = $nyjulian - $cslastusedjul
	If $cslastused  = $unknown Then $csstatage = 0
	If $cstype      = "Daily" Then
		If $csstatage > 0 Or ($csinstage = 0 And $csusecount = 5) Then $csforcedaily = "yes"
		SettingsPut ($setdailylastused, $nytimefulljul)
		SettingsPut ($setusecount, $csusecount + 1)
	EndIf
	; $csforcedaily = "yes"                    ;   Use for testing. Check SpecialSecure status
	SecureRestrict ("")
	If $csupdatesettings <> "" Then SettingsWriteFile ($settingspath)
	If $cstype      = "Daily" And $securesuffix = "" And $csforcedaily = "" And $setuperror = "" And FileGetSize ($statslog) < 4096 Then Return
	If $regtesting  <> "" Then $cstesting = "Testing."
	$csparmprint    = $parmstring
	If $parmstring  = ""    Then $csparmprint = $runtype
	If $cstype      = "Restrict" Then $csrestflag  = "." & $runtype
	$csstamp   = StringMid ($nytimestamp, 3, 2) & StringMid ($nytimestamp, 8, 4) & "-" & StringRight ($nytimestamp, 6) _
	            & "-" & $useridalpha & "-" & $cstesting & $csuserstatus & $cstype & $csrestflag & ".txt"
	$statsdatafile  = $statsdatastring & $csstamp
	$csmachguid     = "None"
	If $regmachguid <> "" Then $csmachguid = $regmachguid
	$cshandle       = FileOpen ($statsdatafile, $FO_OVERWRITE )
	FileWrite ($cshandle, @TAB & @TAB & @TAB & "New York Time  " & $nytimeus & @CR)
	FileWrite ($cshandle, @CR & "System"              & @CR)
	FileWrite ($cshandle, @CR & "    WindowsVersion"  & @TAB & $bootos)
	FileWrite ($cshandle, @CR & "    WindowsBuild"    & @TAB & @OSBuild)
	FileWrite ($cshandle, @CR & "    FirmwareMode"    & @TAB & $firmwaremode)
	FileWrite ($cshandle, @CR & "    CPUBits"    & @TAB & @TAB & $procbits)
	FileWrite ($cshandle, @CR & "    OSBits"     & @TAB & @TAB & $osbits)
	FileWrite ($cshandle, @CR & "    Memory"     & @TAB & @TAB & $sysmemorygb)
	FileWrite ($cshandle, @CR & "    BIOSDate"   & @TAB & @TAB & $regbiosdate)
	FileWrite ($cshandle, @CR & "    CPU" & @TAB & @TAB & @TAB & $regcpuname)
	FileWrite ($cshandle, @CR & "    GUID"       & @TAB & @TAB & $csmachguid)
	FileWrite ($cshandle, @CR & "    Parms"      & @TAB & @TAB & $csparmprint)
	FileWrite ($cshandle, @CR & @CR & @CR  & "Grub" & @CR)
	;MsgBox ($mbontop, "Base B", "Curr " & $csrelcurr & @CR & "New " & $basrelcurr & @CR & @CR & $basepath & "\" & $exestring)
	$csrelprevout  = ""
	$csrelshowtime = ""
	;_ArrayDisplay ($progexistinfo, "Exist " & $cstype)
	;_ArrayDisplay ($progruninfo,   "Run   " & $cstype)
	If $cstype <> "Daily" And $cstype <> "Uninstall" And $progexistversion <> "" Then
		If $progexistversion <> "" And $progexistversion = $basrelcurr Then $progexistinfo [$iVersion] = "Refresh"
		If $progexistinfo [$iJul] = $progruninfo [$iJul] Then $csrelshowtime = "yes"
		$csrelprevout = CommonReleaseFormat ($progexistinfo, $csrelshowtime) & @CR
		If $progruninfo [$iStamp] = $progexistinfo [$iStamp] Then $csrelprevout = "*** Unchanged ***" & @CR
	EndIf
	$csrelcurrout     = CommonReleaseFormat ($progruninfo, $csrelshowtime) & @CR
	FileWrite ($cshandle, @CR & "    Grub2WinReleaseCurr" & @TAB & @TAB & $csrelcurrout)
	If StringStripWS ($csrelprevout, 8) <> "" And $cstype <> "Restrict" _
		Then FileWrite ($cshandle, @CR & "    Grub2WinReleasePrev" & @TAB & @TAB & $csrelprevout)
	FileWrite     ($cshandle, @CR & "    Grub2GenStamp"       & @TAB & @TAB & StringLeft ($genstampdisp, 36) & @CR)
	$csuseline = ""
	If $csusecount > 0 Then $csuseline  = "    UseCount"      & @TAB & @TAB & @TAB & $csusecount
	If $csstatage  > 0 Or $csinstage > 0 Then $csuseline &= "    LastUsed  " & TimeFormatDays ($csstatage)
    If $cstype <> "Download" And $csuserstatus <> "NewUser." Then
		FileWrite ($cshandle, @CR & "    InstallDate"  & @TAB & @TAB & @TAB & $csinstalled  & "     " & TimeFormatDays ($csinstage) & @CR)
	    If $csuseline <> "" Then FileWrite ($cshandle, @CR & $csuseline & @CR)
	EndIf
	If $setupmodlist <> "" Then
		FileWrite ($cshandle,      @CR & "    SetupError"                                      & _
			@TAB & @TAB & @TAB & StringReplace ($setuperror, @CR, " ") & $bypassmsg & @CR & @CR)
		If $setupvaluecleanupdir <> "" Then FileWrite _
			($cshandle, @TAB & @TAB & @TAB & @TAB & "Dir = " & $setupvaluecleanupdir & @CR & $setupmodlist)
	EndIf
	If $uninstinfo     <> "" Then FileWrite ($cshandle, @CR & @CR & $uninstinfo     & @CR)
	If $securediaginfo <> "" Then FileWrite ($cshandle, @CR & @CR & $installmessage & @CR & @CR & $securediaginfo & @CR)
	FileWrite ($cshandle, @CR & @CR & "Geo" & @CR)
	$cscity = $geocity
	$csloc  = $cscity & "," & @TAB & $georegion & "," & @TAB & $geocountry
	FileWrite ($cshandle, @CR & "    Location" & @TAB & @TAB & $csloc & @TAB  & @CR)
	If $cscity = $unknown Or $cscity = "" Then $cscity = "Local"
	$cstime = "    " & StringStripWS ($cscity, 7) & " Time"
	If StringLen ($cstime) > 22 Then
		FileWrite ($cshandle, @CR & $cstime)
		$cstime = ""
	EndIf
	FileWrite ($cshandle, @CR & BaseFuncPadRight ($cstime, 22) & @TAB & $loctimeline               & @CR)
	FileWrite ($cshandle, @CR & "    ZULU "         & @TAB   & @TAB & $zulutimeus                  & @CR)
	FileWrite ($cshandle, @CR & "    New York Time" & @TAB          & $nytimeus                    & @CR)
	$cstimezone = "    Time Zone"     & @TAB  &  @TAB  & $timezonedisplay & @TAB & @TAB & "Language  " & $languserdesc
	$cstimezone &= @TAB  & "IP Address  " & $geoipaddress & @TAB & " User ID  " & $useridformat
	FileWrite ($cshandle, @CR & $cstimezone & @CR)
	FileWrite ($cshandle, @CR & "    " & CommonLoadFormat ())
	CommonStatsDownload ($cshandle)
	FileClose           ($cshandle)
	If $cstype = "Daily" Then FileDelete ($statslog)
EndFunc

Func CommonStatsPut ()
	$sfhandle = FileFindFirstFile ($statsdatageneric)
	If $sfhandle = -1 Then Return
	While 1
		$sfname  = FileFindNextFile ($sfhandle)
		If @error Then ExitLoop
		$sfstamp = StringTrimLeft ($sfname, 15)
		SecurePutFTP ($workdir & "\" & $sfname, $sfstamp)
		;MsgBox ($mbontop, "FTP Put", $sfname & @CR & $sfstamp)
	Wend
    FileClose  ($sfhandle)
	FileDelete ($statsdatageneric)
EndFunc

Func CommonStatsDownload ($sdhandle)
	If Not FileExists ($statslog) Then $statslog = $datapath & $statslogstring
	If Not FileExists ($statslog) Then Return
	FileWrite ($sdhandle, @CR & @CR & @CR)
	$sdarray = FileReadToArray ($statslog)
	_ArraySort ($sdarray, 1)
	For $sdsub = 0 To Ubound ($sdarray) - 1
		$sdlines = StringSplit ($sdarray [$sdsub], "|")
		If @error Then ContinueLoop
		For $sdlinesub = 1 To Ubound ($sdlines) - 1
			$linerec = $sdlines [$sdlinesub]
			If StringLeft ($linerec, 6) = "Stamp " Then ContinueLoop
			FileWriteLine ($sdhandle, $linerec)
		Next
	Next
EndFunc

Func CommonLoadFormat ()
	$lfloadline         = $loadtime
	If $scantime       <> ""          Then $lfloadline &= "     " & $scantime
	If $bcdtimestatus  <> ""          Then $lfloadline &= "     " & $bcdtimestatus
	If $statuszulu     <> ""          Then $lfloadline &= "     " & $statuszulu
	If $statusgeo      <> $unknown    Then $lfloadline &= "     " & $statusgeo
	If $geototalretrys <> "" 		  Then $lfloadline &= "  Retry = " & $geototalretrys
	Return $lfloadline
EndFunc

Func CommonGetInitTime ($ittick, $itdiff = "")
	$ittime = TimeFormatSeconds ($ittick, $itdiff)
	Return "Total Init Time " & $ittime
EndFunc

Func CommonCalcPercent ($cpdividend, $cpdivisor)
	$cpresult = Int (($cpdividend / $cpdivisor) * 100)
	If $cpresult < 0  Then $cpresult = 0
	If $cpresult > 98 Then $cpresult = 99
	Return $cpresult
EndFunc

Func CommonCheckRestrict ()
	If CommonParms   ($parmuninstall) Then Return
	SecureRestrict   ("yes")
	If Not @error Then Return
	;_ArrayDisplay ($licmsgarray)
	CommonFlashEnd   ("")
	CommonHotKeys    ("off")
	HotKeySet        ("{F2}", "CommonLicInc")
	DirRemove        ($masterpath & ".old", 1)
	$loadtime        = CommonGetInitTime ($starttimetick)
	If $securestats = "" Then
		CommonStatsBuild ("Restrict", "")
		CommonStatsPut   ()
	EndIf
	$securestats     = "done"
	$licmsgarray [1] = @CRLF & @CRLF & $licmsgarray [1] & @CRLF & @CRLF
	If $installstatus = $statuscurr Then
		CommonLicWarn ()
		Run ($masterpath & "\" & $exestring & " Uninstall Quiet")
	EndIf
	If @error Or StringInStr ($installstatus, $statusobsolete) Then
		DirRemove ($masterpath, 1)
		CommonLicWarn (20)
	EndIf
	If $installstatus = $statusnew Then
		$licmsgarray   [3]  = ""
		$licmsgarray   [6]  = ""
		CommonLicWarn  (20)
		If StringInStr ($runtype, "Download") Then _
			BaseFuncCleanupTemp ("CommonCheckRestrict", "Exit", "setupfiles", @ScriptDir)
	EndIf
	Exit
EndFunc

Func CommonLicWarn ($lwtimeout = "")
	$lwpid        = CommonLicDisplay ($licmsgarray, $licensewarn, "Grub2Win License Warning")
	EnvSet        ("LicenseWarnPID", $lwpid)
	If $lwtimeout = "" Then Return
	Sleep         ($lwtimeout * 1000)
	ProcessClose  ($lwpid)
EndFunc

Func CommonLicInc ()
	WinClose          ("Grub2Win License Warning")
	$licmsgarray [6]  &= $licmsginc
	CommonLicDisplay  ($licmsgarray, $licensewarn, "Grub2Win License Incident")
	BaseFuncCleanupTemp ("CommonLicInc")
EndFunc

Func CommonLicDisplay ($ldarray, $ldfilename, $ldtitle)
	$ldtemppath   = $workdir & "\" & $ldfilename
	BaseFuncArrayWrite ($ldtemppath, $ldarray)
	Opt           ("WinTitleMatchMode", 2)
	$ldpid        = Run ("notepad.exe " & $ldtemppath)
	$ldhandle     = WinWait ($ldfilename, "", 5)
	WinSetTitle   ($ldhandle, "", $ldtitle)
	WinSetOnTop   ($ldhandle, "", 1)
	WinMove       ($ldhandle, "", 450, 150, 670, 570)
	Sleep         (250)
	FileDelete    ($ldtemppath)
	Return         $ldpid
EndFunc

Func CommonFormatComment ($fcinput, $fcspacer = @TAB & @TAB & @TAB, $fclimit = 40)
	$fcinput    = StringReplace ($fcinput, @CR, " ")
	$fcinput    = StringStripWS ($fcinput, 7)
	$fcoutput   = ""
	$fcarray    = StringSplit ($fcinput, " ")
	If @error Then
		$fcoutput = $fcinput
	Else
		$fccharno  = 0
		For $fcsub = 1 To Ubound ($fcarray) - 1
			$fcrec     = $fcarray [$fcsub]
			If $fccharno > $fclimit Then
				$fcoutput &= @CR & $fcspacer & $fcrec & " "
				$fccharno  = 0
				ContinueLoop
			EndIf
			$fcoutput &= $fcrec & " "
			$fccharno += StringLen ($fcrec) + 1
		Next
	EndIf
	Return $fcoutput
EndFunc

Func CommonGetEFIDefaultType ()
	If $firmwaremode <> "EFI" Then Return ""
	$dckernelpath = $bcdorderarray [0] [$bPath]
	Select
		Case StringInStr ($dckernelpath, $bootmanefi64) Or StringInStr ($dckernelpath, $bootmanefi32)
			Return "Grub2Win"
		Case StringInStr ($dckernelpath, $winbootmgr)
			Return "Windows"
		Case Else
			Return "Linux"
	EndSelect
EndFunc

Func CommonGetAllInfo ($aipath = $masterpath & "\" & $exestring)
	$progruninfo       = BaseFuncGetVersion (@ScriptFullPath, $progrunversion)
	                     TimeGetInfo        ($progruninfo)
	If @ScriptFullPath = $aipath Then
		$progexistinfo    = $progruninfo
		$progexistversion = $progrunversion
	Else
		$progexistinfo = BaseFuncGetVersion ($aipath, $progexistversion)
		                 TimeGetInfo        ($progexistinfo)
	EndIf
	$installstatus     = $progexistinfo [$iStatus]
	;_ArrayDisplay ($progexistinfo, "Exist Common"  & $progexistversion)
	;_ArrayDisplay ($progruninfo,   "Run   Common"  & $progrunversion)
EndFunc

Func CommonCheckDescription ($cdtext)
	$cdstrip = StringStripCR ($cdtext)
	$cdvowel = StringStripWS ($cdstrip, $STR_STRIPALL)
	If StringLen ($cdstrip) > 10 And Ubound (StringRegExp ($cdvowel, $vowelchar, 3)) > 1 _
		And CommonStringCount ($cdstrip, " ") > 2 Then Return ""
	Return "Enter a description of your problem" & @CR & "Please provide as much detail as possible"
EndFunc

Func CommonCheckMode ()
	If @OSBuild > 20000 And $firmwaremode <> "EFI" Then
		$ccunsuppmsg  = "Windows 11 Must Run In EFI Mode"    & @CR & @CR & "Your Machine Is Improperly Configured For BIOS Firmware" & @CR & @CR
		$ccunsuppmsg &= "Grub2Win Will Not Run In This Mode" & @CR & @CR & "Run Cancelled"
		MsgBox ($mbwarnok, "** Microsoft Does Not Support Windows 11 In BIOS Mode **", $ccunsuppmsg, 60)
		BaseFuncCleanupTemp ("CommonCheckMode")
	EndIf
EndFunc