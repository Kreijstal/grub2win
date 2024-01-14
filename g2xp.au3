#include-once
#include <g2common.au3>

Func XPSetup ()
	Dim $xpoldrelarray[1]
	_ArrayAdd ($xpoldrelarray, $xptargetstub)
EndFunc

Func XPGetPrevious ()
	Local $gpgendfound
	Dim $xpiniarray     [1]
	Dim $xpinbackiarray [1]
	$gpfilearray = BaseFuncArrayRead ($xpinifile, "XPGetPrevious", "", "no")
	If @error Then
		CommonWriteLog  ("                *** Error reading " & $xpinifile)
		BaseFuncShowError  ("The " & $xpinifile & " file is missing", "XPGetPrevious")
	EndIf
	For $gpsub = 0 To Ubound ($gpfilearray) - 1
		$gplineini = $gpfilearray [$gpsub]
		$gplineini = StringStripWS($gplineini, 3)
		Select
			Case StringLeft($gplineini, 13) = "[boot loader]"
			Case StringLeft($gplineini, 19) = "[operating systems]"
			Case StringLeft($gplineini, 1)  = "["
				$gpgendfound = "yes"
		EndSelect
		If $gpgendfound = "yes" Then
			_ArrayAdd ($xpinbackiarray, $gplineini)
		Else
			_ArrayAdd ($xpiniarray,     $gplineini)
		EndIf
		Select
			Case StringLeft ($gplineini, 8) = "timeout="
				$xpiniprevtime  = StringMid($gplineini, 9, 7)
				$timeoutwin  = $xpiniprevtime
			Case StringLeft($gplineini, StringLen ($xpstubfile)) = $xpstubfile
				$inistring    = StringTrimLeft ($gplineini, StringLen($xpstubfile))
				$iniprevdesc  = _StringBetween($inistring, '"', '"')
				$iniprevdesc  = $iniprevdesc[0]
				$xpiniprevitem  = $gplineini
			EndSelect
	Next
	If $xpiniarray [Ubound ($xpiniarray) -1] = "" Then _ArrayDelete ($xpiniarray, Ubound ($xpiniarray) -1)
EndFunc

Func XPUpdate ($xutimeout = $timeoutwin, $xpsetup = "yes")
	$xpinibootstring = $xpstubfile & '="' & $biosdesc & '"'
	$xptimemsg       = $xutimeout & " seconds"
	If $timewinenabled <> "yes" Then
		$xutimeout   = $shortbootoff
		$xptimemsg   = "disabled"
	EndIf
	XPIniCleanup()
	$xurc = XPCreateLoader ()
	If $xurc = 1 Then Return 1
	If $xutimeout = $xpiniprevtime And $xpinibootstring = $xpiniprevitem And $xpinibackedup = "" And $xpoldfound = ""  Then
		If $xpsetup = "yes" Then CommonWriteLog ("          The Grub2Win entry already exists. No " & $xptargetini & " changes are required")
		Return 0
	EndIf
	If $xutimeout <> $xpiniprevtime Then
		$bootitem = _ArraySearch($xpiniarray, "Timeout=", 0, 0, 0, 1)
		If $bootitem >= 0 Then
			$xpiniarray [$bootitem] = "Timeout=" & $xutimeout
			CommonWriteLog ("           The Windows " & $xptargetini & " timeout has been set to " & $xptimemsg)
			CommonWriteLog ()
		EndIf
	EndIf
	If $xpinibootstring <> $xpiniprevitem Then
		CommonWriteLog("          Adding the new  Grub2Win entry to " & $xpinifile)
		CommonWriteLog('                The title is -  "' & $biosdesc & '"')
		CommonWriteLog("                The Windows boot timeout is " & $xptimemsg)
		_ArrayAdd ($xpiniarray, "")
		_ArrayAdd ($xpiniarray, $xpinibootstring)
		_ArrayAdd ($xpiniarray, "")
	EndIf
	If $xpiniarray [Ubound ($xpiniarray) - 1] = "" Then _ArrayDelete ($xpiniarray, Ubound ($xpiniarray) - 1)
	FileDelete($xpinifile)
	BaseFuncArrayWrite ($xpinifile, $xpiniarray)
	If @error Then
		CommonWriteLog("                *** Error writing " & $xpinifile & "  " & @error)
		Return 1
	EndIf
	CommonWriteLog()
	CommonWriteLog("          " & $xpinifile & " update was successful", 2)
	Return 0
EndFunc

Func XPIniCleanup ($xpuninstall = "")
	$inibootfound = "no"
	$inisub = 1
	While 1
		If $inisub > UBound($xpiniarray) - 1 Then ExitLoop
		$iniline = $xpiniarray[$inisub]
		$iniline = StringStripWS($iniline, 3)
		For $xpsub = 1 To UBound ($xpoldrelarray) - 1
			$prevname = $xpoldrelarray[$xpsub]
			If FileExists ($windowsdrive & "\" & $prevname) Then FileDelete ($windowsdrive & "\" & $prevname)
			If Not StringInStr ($iniline, $prevname)  Then ContinueLoop
			If     StringInStr ($iniline, "default=") And $xpuninstall = "" Then ContinueLoop
			If $iniline = $xpinibootstring And $inibootfound = "no" And $xpuninstall = "" Then
				$inibootfound = "yes"
				ContinueLoop
			EndIf
			_ArrayDelete($xpiniarray, $inisub)
			$xpoldfound = "yes"
			$inisub -= 1
			If $inisub <= UBound($xpiniarray) - 1 And $xpiniarray [$inisub] = "" Then
				_ArrayDelete($xpiniarray, $inisub)
				$inisub -= 1
			EndIf
			CommonWriteLog("                A previous Grub2Win entry has been deleted. Line = " & $iniline)
		Next
		$inisub += 1
	WEnd
EndFunc

Func XPCreateLoader()
	$xcrc = FileCopy ($bootmanpath & "\" & $xpstubsource, $xpstubfile, 1)
	If $xcrc = 1 Then
		CommonWriteLog('                The XP stub file ' & $xpstubfile & ' was created', 2)
	Else
		CommonWriteLog("                *** XP stub creation failed   RC = " & $xcrc & " ***", 2)
		Return 1
	EndIf
	$xcrc = FileCopy($bootmanpath & "\" & $bootloaderbios, $xploadfile, 1)
	If $xcrc = 1 Then
		CommonWriteLog('                The XP loader file ' & $xploadfile & ' was created', 2)
	Else
		CommonWriteLog("                *** XP loader creation failed   RC = " & $xcrc & " ***", 2)
		Return 1
	EndIf
	Return 0
EndFunc