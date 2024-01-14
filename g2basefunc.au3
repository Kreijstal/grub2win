#include-once
#include <g2basecode.au3>

Const  $procbits         = BaseFuncGetBits        ()
Const  $osbits           = BaseFuncGetBits        ("OS")
Const  $firmwaremode     = BaseFuncGetFirmMode    ()
Const  $runtype          = BaseFuncGetRunType     ()
Const  $bootos           = BaseFuncGetOSVersion   ()
Const  $systemmode       = BaseFuncGetSysMode     ()
Const  $alttimezone      = BaseFuncTimeZoneAlt    ()
Const  $useridalpha      = BaseFuncMakeAlphaNum   ($useridorig)
Const  $sysutilpath      = BaseFuncGetUtilPath    ()
Const  $mountvolexec     = $sysutilpath           & "\mountvol.exe"
Const  $bcdexec          = $sysutilpath           & "\bcdedit.exe"
Global $cleanuparray     = BaseFuncGetCleanup     ()

Func BaseFuncGetOSVersion ()
	Select
		Case @OSVersion = "WIN_11"
			$govos = "Windows 11"
			If @OSBuild > $maxosbuild And $runtype = "Setup" Then _
				MsgBox ($mbwarnok, "** Warning **", "    Grub2Win Has Not Been Tested" _
				& @CR & "With This Windows Preview Version"                            _
				& @CR & @CR & "     " & $govos & "    Build " & @OSBuild)
		Case @OSVersion = "WIN_10"
			$govos = "Windows 10"
		Case @OSVersion = "WIN_7"
			$govos = "Windows 7"
		Case @OSVersion = "WIN_2022"
			$govos = "Windows 2022 Server"
		Case @OSVersion = "WIN_2019"
			$govos = "Windows 2019 Server"
		Case @OSVersion = "WIN_2016"
			$govos = "Windows 2016 Server"
		Case @OSVersion = "WIN_2012" Or @OSVersion = "WIN_2012R2"
			$govos = "Windows 2012 Server"
		Case @OSVersion = "WIN_8"    Or @OSVersion = "WIN_81"
			$govos = "Windows 8"
		Case @OSVersion = "WIN_2008" Or @OSVersion = "WIN_2008R2"
			$govos = "Windows 2008 Server"
		Case @OSVersion = "WIN_VISTA"
			$govos = "Windows Vista"
		Case @OSVersion = "WIN_2003"
			$govos = "Windows 2003 Server"
		Case @OSVersion = "WIN_XP"   Or @OSVersion = "WIN_XPe"
			$govos = $xpstring
	    Case Else
			$govmsg = @OSVersion & "     " & $osbits & " bit     build " & @OSBuild
			BaseFuncShowError ("Grub2Win does not support this OS build " & @CR & @CR & $govmsg, "BaseFuncGetOSVersion")
		EndSelect
	Return $govos
EndFunc

Func BaseFuncGetBits ($gbtype = "")
	If @OSArch  = "X64" Then Return 64
	If @CPUArch = "X64" And $gbtype = "" Then Return 64
	Return 32
EndFunc

Func BaseFuncGetFirmMode ()
	$gfmreturn = "EFI"
	Select
		Case @OSBuild >  9000   ; Windows 11, 10 or 8
			$gfmarray = DllCall ("Kernel32.dll", "int", "GetFirmwareType", "int*", 0)
			If @error Or Ubound ($gfmarray) < 2 Then Return "Error"
			If $gfmarray [1] <> 2 Then $gfmreturn = "BIOS"
		Case @OSBuild >  6000   ; Windows 7 or Vista
			DllCall ("kernel32.dll", "int", "GetFirmwareEnvironmentVariableA", "str", "",   "str", _
	                                 "{00000000-0000-0000-0000-000000000000}", "ptr", Null, "dword", 0)
			$gfmcode    = _WinAPI_GetLastError ()
			If $gfmcode = 1 Then $gfmreturn = "BIOS"
		Case Else				; XP
			$gfmreturn = "BIOS"
	EndSelect
	Return $gfmreturn
EndFunc

Func BaseFuncGetSysMode ()
	If $bootos = $xpstring Then Return "BIOS XP"
	Return $firmwaremode
EndFunc

Func BaseFuncTimeZoneAlt ()
	$gtzarray    = _Date_Time_GetTimeZoneInformation ()
	If Ubound ($gtzarray) < 8 Then Return ""
	$gtzoffset  = $gtzarray [1] * -1
	$gtzdescalt = $gtzarray [2]
	If $gtzarray [0] = 2 Then
		$gtzdescalt  = $gtzarray [5]
		$gtzoffset  -= $gtzarray [7]
	EndIf
	If $gtzdescalt    = "" Then Return "** Alternate Not Found **"
	$altoffsethours   = StringFormat ("%+d", $gtzoffset / 60)
	$altoffsetmins    = Mod ($gtzoffset, 60)
	Return  $gtzdescalt & "  ** Alternate **  ( " & _
		$altoffsethours & ":" & StringFormat ("%02i",$altoffsetmins) & " )"
EndFunc

Func BaseFuncSingleRead ($srfile, $srfirstonly = "")
	$srhandle = FileOpen ($srfile, $FO_READ)
	If $srhandle = -1 Then Return ""
	If $srfirstonly = "" Then
		$srdata   = FileRead     ($srhandle)
	Else
		$srdata   = FileReadLine ($srhandle)
	EndIf
	If @error Then $srdata = ""
	FileClose ($srhandle)
	Return $srdata
EndFunc

Func BaseFuncSingleWrite ($swfile, $swdata, $swmode = $FO_OVERWRITE, $swcr = "")
	$swhandle = FileOpen ($swfile, $swmode)
	If $swhandle = -1 Then Return
	FileWrite ($swhandle, $swdata & $swcr)
	FileClose ($swhandle)
EndFunc

Func BaseFuncSing ($bscount, $bsmsg)
	If $bscount <> 1 Then Return $bsmsg
	$bsmsg = StringReplace ($bsmsg, "days",       "day")
	$bsmsg = StringReplace ($bsmsg, "these",      "this")
	$bsmsg = StringReplace ($bsmsg, "entries",    "entry")
	$bsmsg = StringReplace ($bsmsg, "were",       "was")
	$bsmsg = StringReplace ($bsmsg, "files",      "file")
	$bsmsg = StringReplace ($bsmsg, "drives",     "drive")
	$bsmsg = StringReplace ($bsmsg, "partitions", "partition")
	Return $bsmsg
EndFunc

Func BaseFuncArrayRead ($arinput, $arcaller, $arconvert = "", $arerrdisp = "", $ardim = "", $arfixlf = "")
	$arhandle    = FileOpen ($arinput, 0)
	If $arhandle = -1 Then
		If $arerrdisp = "" Then BaseFuncShowError ("Input file was not found " & @CR & @CR & $arinput, "BaseFuncArrayRead   " & $arcaller)
		SetError (1)
		Return
	EndIf
	$arstring = FileRead ($arhandle)
	FileClose ($arhandle)
	If $arfixlf <> "" And Not StringInStr ($arstring, @CR & @LF) Then _
		$arstring = StringReplace ($arstring, @LF, @CR & @LF)
	$arstring = StringReplace ($arstring, @LF,  @CR)
	$arstring = StringReplace ($arstring, @CR & @CR, @CR)
	If $arconvert   <> "" Then $arstring = _WinAPI_OemToChar ($arstring)
	$ararray  = StringSplit   ($arstring, @CR, 2)
	If @error Then
		Dim $ararray [1]
		If StringStripWS ($arstring, 3) <> "" Then $ararray [0] = $arstring
	EndIf
	If $ardim = "" Then Return $ararray
	Dim $armulti [0] [$ardim]
	For $arsub = 0 To Ubound ($ararray) - 1
		_ArrayAdd ($armulti, $ararray [$arsub])
	Next
	Return $armulti
EndFunc

Func BaseFuncArrayWrite ($awoutfile, ByRef $awarray, $awopenmode = $FO_OVERWRITE, $awdesc = "", $awstartsub = 1)
	$awhandleout = FileOpen ($awoutfile, $awopenmode + $FO_CREATEPATH)
	If $awhandleout = -1 Then BaseFuncShowError ("Output file open error" & @CR & @CR & $awoutfile, "BaseFuncArrayWrite", $awarray)
	;If $awdesc <> "" Then _ArrayInsert ($awarray, 1, @CR & @CR & "****  " & $awdesc & "  " & BaseFuncTimeLine () & "  ****" & @CR)
	If $awdesc <> "" Then _ArrayInsert ($awarray, 1, @CR & @CR & "****  " & $awdesc & "  " & "  ****" & @CR)
	$awbound = UBound ($awarray) - 1
	For $awsub = $awstartsub To $awbound
		$awline = $awarray[$awsub]
		If $awsub < $awbound Then $awline &= @CRLF
		FileWrite ($awhandleout, $awline)
	Next
	FileClose($awhandleout)
EndFunc

Func BaseFuncGetVersion ($gvpath, ByRef $gvversion)
	Dim $gvarray [8]
	$gvarray [$iPath] = $gvpath
	$gvversion        = ""
	If StringRight ($gvpath, 4) = ".exe" Then
		$gvversion = FileGetVersion ($gvpath)
		If @error Or $gvversion = "0.0.0.0" Then $gvversion = $unknown
	EndIf
	If StringLen ($gvversion) > 18 Then
		$gvverstring  = StringMid ($gvversion, 1, 1) & "." & StringMid ($gvversion, 2, 1) & "."
		$gvverstring &= StringMid ($gvversion, 3, 1) & "." & StringMid ($gvversion, 4, 1)
		$gvarray [$iBuild]    = StringMid ($gvversion, 6, 4)
		$gvarray [$iStamp]    = "202" & StringMid ($gvversion, 11, 1) & StringMid ($gvversion, 12, 2) & StringMid ($gvversion, 14, 2)
		$gvhrdig    = StringMid ($gvversion, 17, 1)
		If $gvhrdig = 5 Then $gvhrdig = 0
		$gvarray [$iStamp]  &= $gvhrdig & StringMid ($gvversion, 18, 4) & "0"
		$gvversion           = $gvverstring
	EndIf
	$gvarray [$iVersion] = $gvversion
	$gvarray [$iStatus]  = $statusobsolete
	If $gvversion >= "2.3.5.0" Then $gvarray [$iStatus]  = $statuscurr
	If $gvversion  = $unknown  Then $gvarray [$iStatus]  = $statusnew
	;_ArrayDisplay ($gvarray, $gvpath & "  " & $gvversion)
	Return $gvarray
EndFunc

Func BaseFuncShowError ($semessage, $sefuncname = @ScriptName, $searray = "", $setitle = "** Grub2Win Error **", $seline = @ScriptLineNumber)
	$semessage &= @CR & @CR & "Function = " & $sefuncname
	If Not @Compiled Then $semessage &= @CR & @CR & "Source Line = " & $seline
	$semessage &= @CR & @CR & "OS = "       & $bootos     & "     Firmware Mode = " & $firmwaremode
	$semessage &= @CR & @CR & "Grub2Win = " & $basrelcurr & "   Stamp = " & $basgenstamp
	MsgBox ($mbwarnok, $setitle, $semessage, 120)
	If $searray <> "" Then _ArrayDisplay ($searray, "Array Size " & Ubound ($searray) -1)
	Exit
EndFunc

Func BaseFuncCapIt ($cifield)
	Return StringUpper(StringLeft($cifield, 1)) & StringTrimLeft($cifield, 1)
EndFunc

Func BaseFuncPadRight ($prinput, $prlength, $prchar = " ")
	$prinput     = StringLeft ($prinput, $prlength)
	$prexpand    = $prlength - StringLen ($prinput)
	If $prexpand > 0 Then $prinput = $prinput & _StringRepeat ($prchar, $prexpand)
	Return ($prinput)
EndFunc

Func BaseFuncPadLeft ($plinput, $pllength, $plchar = " ")
	$plinput     = StringRight ($plinput, $pllength)
	$prexpand    = $pllength - StringLen ($plinput)
	If $prexpand > 0 Then $plinput = _StringRepeat ($plchar, $prexpand) & $plinput
	Return ($plinput)
EndFunc

Func BaseFuncCheckCharSpec ($csinput)
	Return StringRegExp ($csinput, $invalchar)
EndFunc

Func BaseFuncRemoveCharSpec ($csinput)
	Return StringRegExpReplace ($csinput, $invalchar, "")
EndFunc

Func BaseFuncMakeAlphaNum ($mastring)
	$useridformat = StringStripWS ($mastring, 8)
	If StringIsASCII     ($mastring) Then
		If StringIsAlpha ($mastring) Then Return $mastring
		If StringIsAlNum ($mastring) Then Return $mastring
	EndIf
	$mainarray    = StringSplit ($useridformat, "", 2)
	If @error Or $useridformat = "" Then Return "XXXXXX"
	$maoutstring  = ""
	For $masub = 0 To Ubound ($mainarray) - 1
		$mainchar = $mainarray [$masub]
        $maascii    = AscW ($mainchar)
		If $maascii > 128 Then $maascii = Mod ($maascii, 128)
		If $maascii <  48 Then $maascii += 48
		If $maascii > 122 Then $maascii -=  5
		If $maascii >  57 And  $maascii <  65 Then $maascii += 7
		If $maascii >  90 And  $maascii <  97 Then $maascii -= 7
		$maoutchar  = Chr ($maascii)
		$maoutstring &= $maoutchar
	Next
	If $useridformat <> $maoutstring Then $useridformat = $maoutstring & "  -  Original ID  " & $mastring
	Return $maoutstring
EndFunc

Func BaseFuncGetRunType ()
	If IsDeclared  ("downloadmode") Then Return Eval ("downloadmode")
	If StringInStr ($CmdLineRaw, $parmsetup) Or StringInStr (@ScriptName, $parmsetup) _
		Or StringInStr ($CmdLineRaw, $parmautoinstall) Then Return $parmsetup
	Return "Grub2Win"
EndFunc

Func BaseFuncGetUserGFX ($gufile, $gustandard)
	$gugarray = BaseFuncArrayRead ($gufile, "BaseFuncGetUserGFX")
	For $gugsub = 0 To Ubound ($gugarray) - 1
		If $gugsub > 4 Then ExitLoop
		$gustandard &= "|" & StringStripWS ($gugarray [$gugsub], 8)
	Next
	Return $gustandard
EndFunc

Func BaseFuncShellWait ($bscommand, $bsoutpath, ByRef $bsrc, $bscaller, $bsconvert = "")
	Dim $bsarray [1]
	If $bsoutpath <> "" Then $bscommand &= " > " & $bsoutpath
	$bsrc = ShellExecuteWait (@Comspec, " /c " & $bscommand, "", "", @SW_HIDE)
	If @error Then MsgBox ($mbwarnok, "** Shell Command Failed ** - Caller is " & $bscaller, @ComSpec & @CR & @CR & $bscommand)
	If FileExists ($bsoutpath) Then $bsarray = BaseFuncArrayRead ($bsoutpath, $bscaller, $bsconvert)
	;_ArrayDisplay ($bsarray, $bsrc & " shell  " & $bscommand)
	Return $bsarray
EndFunc

Func BaseFuncCheckVirtual ()
	; Check for VM BIOS
   $cvitems = $wmisvc.ExecQuery ("SELECT * FROM Win32_BIOS", "WQL", 0x10 + 0x20)
   If IsObj ($cvitems) Then
        For $dummy In $cvitems
			If StringInStr ($dummy.BIOSVersion (0), "Vbox") Or StringInStr ($dummy.SMBIOSBIOSVersion, "virt") Then _
				Return @CRLF & @CRLF & "** This Machine Appears To Be Running Under VirtualBox **"
			If StringInStr ($dummy.Manufacturer,    "VMware")                                                 Then _
				Return @CRLF & @CRLF & "** This Machine Appears To Be Running Under VMware **"
		Next
   EndIf
   Return ""
EndFunc

Func BaseFuncGetUtilPath () ; Required for mixed 32/64 bit execution of utilities
	$gupath = @SystemDir
	If StringInStr (@SystemDir, "SysWOW64") Then $gupath = @WindowsDir & "\Sysnative"
	$gupath = BaseFuncCapIt (StringLower ($gupath ))
	Return $gupath
EndFunc

Func BaseFuncCleanupTemp ($cbsource, $cbexitcode = "Exit", $cbtype = "directory", $cbdirectory = "")
	BaseFuncUnmountWinEFI ()
	$cleanuparray [2] = "set cleantype="   & $cbtype
	$cleanuparray [3] = "set cleandir="    & $cbdirectory
	$cleanuparray [4] = "set lateststamp=" & $stamptemp
	$cleanuparray [5] = "set masterpath="  & $masterpath
	$cleanuparray [6] = "set workdir="     & '"' & $workdir & '"'
	$cbfilename = StringTrimRight ($cleanupbat, 4) & "." & $cbtype & "." & $cbsource & ".bat"
	BaseFuncArrayWrite ($cbfilename, $cleanuparray)
	Run ($cbfilename, "", @SW_HIDE)
	If $cbexitcode =  "Exit" Then Exit
	If $cbexitcode <> ""     Then Exit $cbexitcode
EndFunc

Func BaseFuncUnmountWinEFI ()
	If $winefistatus <> "mounted" Then Return
	$westring     = $mountvolexec & " " & $winefiletter & " /D"
	$werc         = ""
    BaseFuncShellWait ($westring, "", $werc, "BaseFuncUnmountWinEFI")
	$winefistatus = ""
EndFunc

Func BaseFuncGetCleanup ()
	$gcrc = FileInstall ("xxcleanup.txt",    $cleanupbat)     ; Include the xxcleanup.txt file
	If $gcrc = 0 Then BaseFuncShowError ("** FileInstall Failed **", "BaseFuncGetCleanup")
	$gcarray        = BaseFuncArrayRead ($cleanupbat, "BaseFuncGetCleanup")
	FileDelete      ($cleanupbat)
	_ArrayInsert    ($gcarray, 0, "")
    Return $gcarray
EndFunc

Func BaseFuncGUIDelete (ByRef $gdhandle)
	If $gdhandle <> "" Then GUIDelete ($gdhandle)
	$gdhandle     = ""
EndFunc

Func BaseFuncGUICtrlDelete (ByRef $cdhandle)
	If $cdhandle <> "" Then GUICtrlDelete ($cdhandle)
	$cdhandle     = ""
EndFunc