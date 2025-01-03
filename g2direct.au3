#include-once
#include <g2common.au3>

If StringInStr (@ScriptName, "g2direct") And $systemmode = "BIOS" Then
	PartBuildDatabase   ("yes")
	$directletter       = DirectGetBIOSLetter ()
	MsgBox              ($mbontop, "Test Pre  Delete", $directletter & @CR & $directdisk & @CR & $directpart & @CR & $directretain)
	DirectRemoveLetter  ($directdisk, $directpart, $directletter, "yes")
	MsgBox              ($mbontop, "Test Post Delete", $directletter & @CR & $directdisk & @CR & $directpart & @CR & $directretain)
	BaseFuncCleanupTemp ("PreCheck")
EndIf

Func DirectPreCheck ($pcerrchk = "yes")
	If $systemmode <> "BIOS" Then Return
	_ArrayAdd ($templogarray, "")
	_ArrayAdd ($templogarray, "    BIOS Direct Precheck Starts")
	$pcletter  =  DirectGetBIOSLetter ()
	;$pcletter  =  ""
	If $pcletter <> "" Or $pcerrchk = "" Then Return
	DirectNotFound ("Setup")
	If $diagrun  = "" Then CommonFlashEnd ()
	BaseFuncCleanupTemp ("DirectPreCheck")
EndFunc

Func DirectGetBIOSLetter ()
	$directdisk       = ""
	$directpart       = ""
	$directletter     = ""
	$directretain     = ""
	Local $blstatus, $blwindisk, $blwinpart, $blwinletter, $blletter, $blcheckdetail
	;_ArrayDisplay ($partitionarray, $winbootdisk)
	For $blsub = 0 To Ubound ($partitionarray) - 1
		If $blsub > 8 Then ExitLoop
		$blretain       = "perm"
		$bldisk         = $partitionarray [$blsub] [$pDiskNumber]
		$blpart         = $partitionarray [$blsub] [$pPartNumber]
		$blletter       = $partitionarray [$blsub] [$pDriveLetter]
		$bltype         = $partitionarray [$blsub] [$pPartType]
		$blfilesystem   = $partitionarray [$blsub] [$pPartFileSystem]
		If $bldisk <> 0 Then ExitLoop
		If $blfilesystem <> "NTFS" Then ContinueLoop
		If $bltype      = $typewinboot Then
			$blwindisk   = $bldisk
			$blwinpart   = $blpart
			$blwinletter = $blletter
		EndIf
		If $blletter    = "" Then
			$blletter          = CommonDriveLetter ()
			$blretain          = "check"
			DirectDiskpartRun  ($bldisk, $blpart, "assign letter=" & $blletter)
			$blassigncheck     = BaseFuncSingleRead ($windowstempgrub & "\direct.diskpart.output.txt")
			Sleep              (250)
			If FileExists ($blassigncheck) Then
				$directletter      = $blletter
				$blcheckdetail    &= @CR & @CR & $blassigncheck & @CR
			Else
				$directletter      = ""
			EndIf
		EndIf
		$blstatus = DirectCheckBootman ($bldisk, $blpart, $blletter, $blretain)
		DirectRemoveLetter ($bldisk, $blpart, $blletter)
		If $blstatus = "found" Then ExitLoop
	Next
	If $blstatus <> "found" Then $blstatus     = DirectCheckBootman ($blwindisk, $blwinpart, $blwinletter, "perm")
	If $blstatus <> "found" Then $directletter = ""
	Return $directletter
EndFunc

Func DirectNotFound ($nftype)
	$nfmsg     =  $nftype & ' could not locate your Windows BIOS boot manager file'
	$nfmsgdesc =  @CR & @CR & @TAB & @TAB & '"/bootmgr"' & @CR & @CR
	$nfmsgdesc &= 'This file is usually found on your "System Reserved" partition' & @CR
	$nfmsgdesc &= 'or on your C: drive.'                                           & @CR & @CR
	If $nftype =  "Setup"  Then $nfmsgdesc &= 'Grub2Win setup is cancelled'
	DirectRemoveLetter  ($directdisk, $directpart, $directletter, "yes")
	_ArrayAdd ($templogarray, "    BIOS Direct Precheck Ends" & @CR & @CR & $nfmsg)
	MsgBox    ($mbwarnok, $nfmsg, $nfmsgdesc)
EndFunc

Func DirectDiskpartRun ($drdisk, $drpart, $drcommand)
	$drrc         = ""
	$drscriptfile = $windowstempgrub & "\direct.diskpart.script.txt"
	$droutputfile = $windowstempgrub & "\direct.diskpart.output.txt"
	Dim $drarray [0]
	_ArrayAdd ($drarray, "")
	_ArrayAdd ($drarray, "select disk "      & $drdisk)
	_ArrayAdd ($drarray, "select partition " & $drpart)
	_ArrayAdd ($drarray, $drcommand)
	_ArrayAdd ($drarray, "exit")
	BaseFuncArrayWrite ($drscriptfile,  $drarray)
	$drstring = "diskpart /s " & $drscriptfile
	$drlistarray = BaseFuncShellWait ($drstring, $droutputfile, $drrc, "DirectDiskpartRun")
	;_ArrayDisplay ($drlistarray, $drrc)
	If $drrc <> 0 Then Return ""
	For $drsub = 0 To Ubound ($drlistarray) - 1
		$drrec = $drlistarray [$drsub]
		If StringLeft ($drrec, 1) = "*" Then Return $drrec
	Next
EndFunc

Func DirectSecurity ($dsbiosdrive, $dsaction, $dsdisperr = "yes")
	Local $dsrcown, $dsrcgrant
	$dsoutputfile = $windowstempgrub & "\direct.security.output.txt"
	$dsbiosmanager = $dsbiosdrive & "\" & $bootmanstring
	If $dsaction = "off" Then
		BaseFuncShellWait ("takeown /A /F " & $dsbiosmanager,                                $dsoutputfile, $dsrcown,   "DirectSecurityTakeown")
		BaseFuncShellWait ("icacls     " &    $dsbiosmanager & " /grant *S-1-5-32-544:(F)",  $dsoutputfile, $dsrcgrant, "DirectSecurityGrant")  ; Administrators SID
		$dsrcattribl = FileSetAttrib         ($dsbiosmanager,                         "-RHS")
		$dsrcattribm = FileSetAttrib         ($dsbiosdrive   & "\" & $microsoftbios,  "-RHS")
		If $dsdisperr <> "" And ($dsrcown <> 0 Or $dsrcgrant <> 0 Or $dsrcattribl <> 1) Then
			$dserrcode  = "File  " & $dsbiosmanager & @Tab & "Retain"     & $directretain     & @CR & @CR
			$dserrcode &= "Disk "  & $directdisk    & @Tab & "Partition " & $directpart       & @CR & @CR
			$dserrcode &= "Own "   & $dsrcown       & @Tab & "Grant "     & $dsrcgrant        & @CR & @CR
			$dserrcode &= "Att-L " & $dsrcattribl   & @Tab & "Att-M "     & $dsrcattribm
		EndIf
	EndIf
	If $dsaction = "on" Then
		FileSetAttrib      ($dsbiosmanager,                       "+RS")
	    FileSetAttrib      ($dsbiosdrive & "\" & $microsoftbios,  "+RS")
	EndIf
	Return
EndFunc

Func DirectCheckBootman ($cbdisk, $cbpart, $cbletter, $cbretain = "check")
	$cbreturn      = ""
	DirectSecurity ($cbletter, "off", "")
	If FileExists  ($cbletter & "\" & $bootmanstring) Then
		$directdisk       = $cbdisk
		$directpart       = $cbpart
		$directletter     = $cbletter
		$directretain     = $cbretain
		If $cbretain      = "check" Then $directretain = "temp"
		$cbreturn         = "found"
	EndIf
	DirectSecurity ($cbletter, "on")
	Return $cbreturn
EndFunc

Func DirectSetupBIOS (ByRef $sberror)
	$sbmanager      = $directletter & "\" & $bootmanstring
	DirectSecurity  ($directletter, "off")
	$sbmicrosoftrc  = FileCopy ($bootmanpath & "\" & $microsoftbios,   $directletter & "\", 1)
	$sbgrub2winrc   = FileCopy ($bootmanpath & "\" & $bootmanagerbios, $sbmanager, 1)
	DirectSecurity   ($directletter, "on")
	;Msgbox ($mbontop, "Setup", $sbletter & @CR & $sbmanager & @CR & $bootmanpath & "\" & $microsoftbios)
	If $sbmicrosoftrc = 1 And $sbgrub2winrc = 1 Then
		$sbresdesc = '   "System Reserved"    '
		Select
			Case $directletter = $windowsdrive
				$sbdest = 'the Windows ' & $directletter  & ' drive.'
			Case $directretain = "yes"
				$sbdest = 'the ' & $sbresdesc & 'partition   Letter ' & $directletter
			Case Else
				$sbdest = $sbresdesc & 'Disk '   & $directdisk & '  Partition ' & $directpart & _
					"    Letter " & $directletter & "  " & BaseFuncCapIt ($directretain)
		EndSelect
		$sbmessage = "    Grub2Win Direct BIOS boot manager was installed" & @CR & "    to " & $sbdest & @CR
	Else
		$sbmessage = "*** Direct BIOS manager setup failed   RC = " & $sbmicrosoftrc & "-" & $sbgrub2winrc  & "-" & $directletter & " ***"
		$sberror   = "** Update Failed **"
	EndIf
	DirectRemoveLetter   ($directdisk, $directpart, $directletter, "yes")
	CommonWriteLog ("", 2)
	CommonWriteLog ($sbmessage, 2)
	Return $sbmessage
EndFunc

Func DirectUninstallBIOS ($ubletter)
	$ubmanager     = $ubletter & "\" & $bootmanstring
	DirectSecurity ($ubletter, "off")
	$ubmicrosoftrc = FileCopy   ($bootmanpath & "\" & $microsoftbios, $ubmanager, 1)
	$ubfiledelrc   = FileDelete ($ubletter    & "\" & $microsoftbios)
	If Not FileExists ($ubletter & "\" & $microsoftbios) Then $ubfiledelrc = 1
	DirectSecurity ($ubletter, "on")
	If $ubmicrosoftrc = 1 And $ubfiledelrc = 1 Then
		$ubmessage = "The Microsoft Windows BIOS boot manager was restored"
	Else
		$ubmessage = "*** Windows BIOS manager restore failed   RC = " & $ubmicrosoftrc & "-" & $ubfiledelrc & "-" & $ubletter & " ***"
	EndIf
	CommonWriteLog     ($ubmessage, 2)
	DirectRemoveLetter ($directdisk, $directpart, $directletter, "yes")
EndFunc

Func DirectCheckWindows ()
	;_ArrayDisplay ($selectionarray, "Before CW - " & $cwmanagerstatus)
	$cwwinfound = ""
	For $cwsub = 0 To Ubound ($selectionarray) -1
		If $selectionarray [$cwsub] [$sFamily] = $winstring Then $cwwinfound = "yes"
	Next
	If $cwwinfound = "" Then
		$defaultos                          = 0
		_ArrayInsert ($selectionarray, 0, "")
		$selectionarray [0] [$sOSType]      = $winstring
		$selectionarray [0] [$sClass]       = $winstring
		$selectionarray [0] [$sEntryTitle]  = "Windows BIOS Boot"
		$selectionarray [0] [$sFamily]      = $winstring
		$selectionarray [0] [$sLoadBy]      = $modewinauto
		$selectionarray [0] [$sReviewPause] = 2
		CommonArraySetDefaults (0)
		$selectionarray [0] [$sSortSeq]     = ""
	EndIf
	CommonDefaultSync  ()
	CommonSetupDefault ()
	;_ArrayDisplay ($selectionarray, "After CW - " & $cwmanagerstatus)
EndFunc

Func DirectRemoveLetter ($rldisk, $rlpart, $rlletter, $rlforce = "")
	If $rlletter     = "" Or $directretain = "perm" Then Return
	If $directretain = "temp" And $rlforce = "" Then Return
	DirectDiskpartRun ($rldisk, $rlpart, "remove letter=" & $rlletter)
EndFunc