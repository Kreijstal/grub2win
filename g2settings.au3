#include-once
#include <g2basefunc.au3>

Const  $setefideployed        = 0
Const  $setefionpartition     = 1
Const  $setefiforceload       = 2
Const  $setefidefaulttype     = 3
Const  $setefioldpath         = 4
Const  $setefiolddesc         = 5

Const  $setcloverdeployed     = 6
Const  $setcloveronpartition  = 7

Const  $setupnextremind       = 8
Const  $setupremindfreq       = 9
Const  $setuplastcheck        = 10

Const  $setdailylastused      = 11
Const  $setusecount           = 12

Const  $setdonatestatus       = 13
Const  $setdonatedate         = 14

Const  $setstattype           = 15
Const  $setstatcountry		  = 16
Const  $setstatregion	      = 17
Const  $setstatcity           = 18
Const  $setstattimezone       = 19
Const  $setstattimeoffset     = 20
Const  $setstatipaddress      = 21
Const  $setstatusgeo          = 22

Const  $setwarnedclover       = 23
Const  $setwarnedfirmearly    = 24
Const  $setwarnedkernel       = 25
Const  $setwarnedbootmenu     = 26

Const  $setinstalldate        = 27
Const  $setlatestsetup        = 28

Const  $setgnugrubversion     = 29
Const  $setgnugrubprevinfo    = 30
Const  $setwallpaperfont      = 31
Const  $setwallpaperfontauto  = 32

Const  $setefilvlstring       = "\EFI\grub2win\g2bootmgr\gnugrub.efipart.settings.txt"
Const  $setcloverlvlstring    = "\grub2win.clover.settings.txt"

Const  $setno                 = "No"

Const  $SettingsKey = 1, $SettingsNegative = 2, $SettingsValue = 3, $SettingsFlag = 4, $SettingsFieldCount = 5

Global $setloadedpath

Global $settingsarray [33] [$SettingsFieldCount] = [ _
    [$setefideployed,       "EFILevelDeployed",    $unknown], [$setefionpartition,    "EFILevelOnPartition",    $unknown], [$setefiforceload,    "EFIForceLoad",     $setno],   _
	[$setefidefaulttype,    "EFIDefaultType",      $unknown], [$setefioldpath,        "EFIOldPath",             $unknown], [$setefiolddesc,      "EFIOldDesc",       $unknown], _
	[$setcloverdeployed,    "CloverLevelDeployed", $unknown], [$setcloveronpartition, "CloverLevelOnpartition", $unknown], [$setupnextremind,    "UpdateNextRemind", $unknown], _
	[$setupremindfreq,      "UpdateRemindFreq",    $unknown], [$setuplastcheck,       "UpdateLastCheck",        $unknown], [$setdailylastused,   "DailyLastUsed",    $unknown], _
	[$setusecount,          "UseCount",            $unknown], [$setdonatestatus,      "DonateStatus",           $unknown], [$setdonatedate,      "DonateDate",       $unknown], _
	[$setstattype,          "StatType",            $unknown], [$setstatcountry,       "StatCountry",            $unknown], [$setstatregion,      "StatRegion",       $unknown], _
	[$setstatcity,          "StatCity",            $unknown], [$setstattimezone,      "StatTimezone",           $unknown], [$setstattimeoffset,  "StatTimeOffset",   $unknown], _
	[$setstatipaddress,     "StatIPAddress",       $unknown], [$setstatusgeo,         "StatusGeo",              $unknown], [$setwarnedclover,    "WarnedClover",     $setno],   _
	[$setwarnedfirmearly,   "WarnedFirmEarly",     $setno],   [$setwarnedkernel,      "WarnedKernel",           $setno],   [$setwarnedbootmenu,  "WarnedBootMenu",   $setno],   _
	[$setinstalldate,       "InstallDate",         $unknown], [$setlatestsetup,       "LatestSetup",            $unknown], [$setgnugrubversion,  "GNUGrubVersion",   $unknown], _
	[$setgnugrubprevinfo,   "GNUGrubPrevInfo",     $unknown], [$setwallpaperfont,     "WallpaperFont",              StringStripWS ($fontunicode, 7)],                               _
	[$setwallpaperfontauto, "WallpaperFontAuto",       $unknown]]

_ArraySort ($settingsarray)

;_ArrayDisplay ($settingsarray)

Const $settingsemptyarray = $settingsarray

Func SettingsGet ($sgsearch, $sgloadpath = "")
	If $sgloadpath <> "" Then SettingsLoad ($sgloadpath, "", $sgsearch)
	$sgvalue = $settingsarray [$sgsearch] [$SettingsValue]
	If $sgvalue = "" Then $sgvalue = $settingsarray [$sgsearch] [$SettingsNegative]
	;MsgBox (1, "Get " & $sgloadpath, $sgsearch & @CR & @CR & $settingsarray [$sgsearch] [$SettingsKey] & @CR & @CR & $sgvalue)
	Return $sgvalue
EndFunc

Func SettingsPut ($spsearch, $spvalue)
	;MsgBox (1, "Put", $spsearch & @CR & @CR & $settingsarray [$spsearch] [$SettingsKey] & @CR & @CR & $spvalue)
	If $settingsarray [$spsearch] [$SettingsFlag] = "" Then $settingsarray [$spsearch] [$SettingsValue] = $spvalue
	Return $spvalue
EndFunc

Func SettingsLoad ($slpath, $slflag = "", $slupdatekey = "")
	If $slpath     = $setloadedpath Then Return
	$setloadedpath = $slpath
	If Not FileExists ($slpath) Then
		$settingsarray = $settingsemptyarray
		Return
	EndIf
	$slhandle = FileOpen ($slpath)
	While 1
		$slrecord    = FileReadLine ($slhandle)
		If @error Then ExitLoop
		$slrecord    = StringStripWS ($slrecord, 7)
		$slrecarray  = StringSplit   ($slrecord, "|", 2)
		If @error Then ContinueLoop
		$slkey       = $slrecarray [0]
		$slvalue     = $slrecarray [1]
		If $slupdatekey <> "" And $slkey <> $slupdatekey Then ContinueLoop
		$slloc       = _ArraySearch ($settingsarray, $slkey, 0, 0, 0, 0, 1, $SettingsKey)
		If @error Then ContinueLoop
		If $settingsarray [$slloc] [$SettingsFlag] <> "" And $slupdatekey = "" And $slflag = "" Then ContinueLoop
		$settingsarray [$slloc] [$SettingsValue] = $slvalue
		If $slflag <> "" Then $settingsarray [$slloc] [$SettingsFlag] = $slflag
	WEnd
	FileClose ($slhandle)
	;_ArrayDisplay ($settingsarray, "Load A" &  $slflag & "  " & $slupdatekey & "  " &  $slpath)
	If $settingsarray  [$setgnugrubprevinfo] [3] <> "" And $runtype <> $parmsetup Then
		$slprevgrubefi = StringRight         ($settingsarray [$setgnugrubprevinfo] [3], 3)
		$prevgrubinfo  = StringTrimRight     ($settingsarray [$setgnugrubprevinfo] [3], 3)
		$settingsarray [$setefideployed]     [3] = $slprevgrubefi
		$settingsarray [$setefionpartition]  [3] = $slprevgrubefi
		$basefifromrelease                       = $slprevgrubefi
	EndIf
	;_ArrayDisplay ($settingsarray, "Load B" &  $slflag & "  " & $slupdatekey & "  " &  $slpath)
EndFunc

Func SettingsWriteFile ($wfpath)
	$wfarray = $settingsarray
	_ArraySort ($wfarray, 0, 0, 0, $SettingsKey)
	$wfhandle = FileOpen ($wfpath, $FO_OVERWRITE)
	If $wfhandle = -1 Then Return
	For $wfsub = 0 To Ubound ($wfarray) - 1
		$wfcr     = @CR
		If $wfsub = Ubound ($wfarray) - 1 Then $wfcr = ""
		$wfrecord = $wfarray [$wfsub] [$SettingsKey] & "|" & $wfarray [$wfsub] [$SettingsValue]
		FileWrite ($wfhandle, $wfrecord & $wfcr)
	Next
	FileClose ($wfhandle)
EndFunc

Func SettingsSingleGet ($sgfilepath, $sgkey)
	$sgloc = _ArraySearch ($settingsarray, $sgkey)
	If @error Then Return $unknown
	$sgdesc     = $settingsarray [$sgloc] [$SettingsKey]
	$sgvalue    = BaseFuncSingleRead ($sgfilepath)
	If $sgvalue = "" Then Return $settingsarray [$sgloc] [$SettingsNegative]
	Return StringReplace ($sgvalue, $sgdesc & "|", "")
EndFunc

Func SettingsSinglePut ($spfilepath, $spkey, $spvalue)
	$sploc = _ArraySearch ($settingsarray, $spkey)
	If @error Then Return
	$spdesc = $settingsarray [$sploc] [$SettingsKey]
	BaseFuncSingleWrite ($spfilepath, $spdesc & "|" & $spvalue)
EndFunc