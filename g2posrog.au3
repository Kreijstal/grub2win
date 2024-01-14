#include-once
#include <g2common.au3>

;POSInstall ()

Func POSInstall ()
	$picopyflag = "yes"
	If FileExists ($custconfigs & "\" & $poscurrname) Then
		$pimsg   = "The POSROG configuration file is already installed on this computer" & @CR & @CR
		$pimsg  &= "Do you want to refresh it with the latest configuration file?"
		$pimsgrc = MsgBox ($mbwarnyesno, "** " & $poscurrname & " **", $pimsg)
		If $pimsgrc <> $IDYES Then $picopyflag = ""
		Sleep (500)
	EndIf
	$pimsg      = "The POSROG code for Grub2Win will now be"             & @CR
	$pimsg     &= "downloaded and installed."                            & @CR & @CR & @CR
	$pimsg     &= "Grub2Win will restart after the install is complete."
	$pimsgrc    = MsgBox ($mbinfookcan, "POSROG Install", $pimsg)
	If $pimsgrc = $IDCANCEL Then Return "Cancelled By The User"
	$pidownrc = POSDownload ()
	If $pidownrc <> "OK" Then Return "Download Failed"
	$pisassets = $extracttempdir & "\POSROG"
	DirCopy    ($pisassets & "\userfiles\user.icons",       $masterpath & "\userfiles\user.icons", 1)
	DirCopy    ($pisassets & "\userfiles\user.backgrounds", $masterpath & "\userfiles\user.backgrounds", 1)
	If $picopyflag <> "" Then
		FileCopy ($pisassets & "\windata\customconfigs\" & $poscurrname, $custconfigs & "\", 9)
		DirCopy  ($pisassets & "\themes",                  $masterpath & "\themes", 1)
	EndIf
	$picfginarray    = BaseFuncArrayRead ($configfile, "")
	;MsgBox ($mbontop, "Array Read", $configfile)
	$picfgcleanarray = POSCleanOldEntries ($picfginarray)
	;MsgBox ($mbontop, "Clean Old Entries", "")
	$picodearray     = POSCreateNewEntries ()
	;MsgBox ($mbontop, "Create New Entries", "")
	POSUpdateConfig    ($picfgcleanarray, $picodearray)
	MsgBox             ($mbontop, "", "POSROG setup for Grub2Win is complete." & @CR & @CR & 'Grub2Win will restart when you click "OK"' )
	CommonQuickRestart ()
EndFunc

Func POSDownload ()
	$pdresult    = NetFunctionGUI ("DownloadExtract", $windowstempgrub & "\Download\posrog", $downsourcesubproj, "GrubPOSROG", "POSROG Software")
	If $pdresult <> "OK" Then
		$cloverload = "Failed"
		UtilDiskWriteLog ()
		UtilDiskWriteLog ("The POSROG Software Download Or Extract Failed")
	EndIf
	Return $pdresult
EndFunc

Func POSCleanOldEntries ($coecfginarray)
	Dim $coecfgcleanarray [0]
	Dim $coeskiparray     [0] [2]
	$coeskipstart       = ""
	$coeskipend         = ""
	$coeposfound        = ""
	$coesourcefound     = ""
	For $coesub = 0 To Ubound ($coecfginarray) - 1
		$coerec = $coecfginarray [$coesub]
		$coestrip  = StringStripWS ($coerec, 8)
		If StringLeft ($coestrip, 10) = "#MenuEntry" Or StringLeft ($coestrip, 8) = "#SubMenu" Then
			$coeskipstart = $coesub - 1
			$coeposfound     = ""
			$coesourcefound  = ""
		EndIf
		If $coestrip = "}" Or ($coesourcefound <> "" And $coestrip = "") Then
			$coeskipend = $coesub + 1
			;If $coeposfound <> ""  Then _ArrayAdd ($coeskiparray, $coeskipstart & "|" & $coeskipend)
			If $coeposfound <> "" And $coeskipstart <> "" And $coeskipend <> "" Then _ArrayAdd ($coeskiparray, $coeskipstart & "|" & $coeskipend)
			$coeskipstart = ""
            $coeskipend   = ""
		EndIf
		If StringInStr ($coerec, "posrog")   Then $coeposfound    = "yes"
		If StringInStr ($coerec, " source ") Then $coesourcefound = "yes"
	Next
	;_ArrayDisplay ($coeskiparray, "skip")
	;_ArrayDisplay ($coecfginarray,  "In")
	$coeskipsub   = 0
	$coeskiplimit = Ubound ($coeskiparray)
	;MsgBox ($mbontop, "Limit", $coeskiplimit)
	For $coesub = 0 To Ubound ($coecfginarray) - 1
		$coeskipflag = ""
		Select
			Case $coeskiplimit = 0 Or $coeskipsub = $coeskiplimit
			Case $coeskiparray [$coeskipsub] [0] = "" Or $coeskiparray [$coeskipsub] [1] = ""
			Case $coesub >= $coeskiparray [$coeskipsub] [0] And $coesub <= $coeskiparray [$coeskipsub] [1]
				$coeskipflag = "yes"
			Case $coesub > $coeskiparray [$coeskipsub] [1]
				$coeskipsub += 1
		EndSelect
		$coerec = $coecfginarray [$coesub]
		If $coeskipflag = "" Then _ArrayAdd ($coecfgcleanarray, $coerec)
	Next
	;_ArrayDisplay ($coecfgcleanarray, "Cleaned")
	Return $coecfgcleanarray
EndFunc

Func POSCreateNewEntries ()
	;ListIt           ("Creating POSROG configuration code")
	Dim $cnenamearray [0]
	Dim $cnecodearray [0]
	$cnehandle = FileFindFirstFile ($custconfigs & "\POSROG*.cfg")
	If $cnehandle = -1 Then Return
	While 1
		$cnefilename = FileFindNextFile ($cnehandle)
		If @error Then ExitLoop
		_ArrayAdd ($cnenamearray, $cnefilename)
	Wend
	FileClose ($cnehandle)
	;_ArrayDisplay ($cnenamearray, "Name")
	For $cnesub = 0 To Ubound ($cnenamearray) - 1
		$cnename     = $cnenamearray [$cnesub]
		$cnedispname = StringLeft ($cnename, 6) & " " & StringTrimLeft ($cnename, 6)
		$cnedispname = StringTrimRight ($cnedispname, 4)
		_ArrayAdd ($cnecodearray, "#")
		_ArrayAdd ($cnecodearray, "#  Sub Menu " & $cnedispname)
		_ArrayAdd ($cnecodearray, "#")
		_ArrayAdd ($cnecodearray, "#  Menu Comment " & $cnedispname & "'                                         Hotkey=p'   --hotkey=p  --class submenu   --class user-icon-posrog  {")
		_ArrayAdd ($cnecodearray, "#")
		_ArrayAdd ($cnecodearray, "    source $prefix/windata/customconfigs/" & $cnename)
		_ArrayAdd ($cnecodearray, "")
		_ArrayAdd ($cnecodearray, "")
	Next
	;_ArrayDisplay ($cnecodearray)
	Return $cnecodearray
EndFunc

Func POSUpdateConfig ($uccfgtemparray, $uccodearray)
	;ListIt ("Creating the updated grub.cfg file")
	Dim $ucfinalarray [0]
	For $ucsub = 0 To Ubound ($uccfgtemparray) - 1
		$ucrec = $uccfgtemparray [$ucsub]
		_ArrayAdd ($ucfinalarray, $ucrec)
		If StringInStr ($ucrec,  "start-grub2win-auto-menu-section") Then
			_ArrayAdd ($ucfinalarray, "#")
			_ArrayAdd ($ucfinalarray, "")
			For $ucdesub = 0 To Ubound ($uccodearray) - 1
				_ArrayAdd ($ucfinalarray, $uccodearray [$ucdesub])
			Next
			$ucsub += 2
		EndIf
	Next
	;_ArrayDisplay ($ucfinalarray, "Final")
	BaseFuncArrayWrite ($masterpath & "\grub.cfg", $ucfinalarray, $FO_OVERWRITE, "", 0)
EndFunc