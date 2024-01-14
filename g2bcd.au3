#include-once
#include <g2common.au3>

Dim  $bcdcleanuparray [1]

If StringInStr (@ScriptName, "g2bcd") Then
	BCDGetBootArray ()
	;_ArrayDisplay ($bcdarray, "BCD Before")
	;_ArrayDisplay ($bcdorderarray, "Order Before")
	_ArrayDisplay ($bcdorderarray, "Order After")
	_ArrayDisplay ($bcdarray,      "BCD After")
	_ArrayDisplay ($bcdwinorder,   "Winorder After")
	Exit
EndIf

Func BCDTest ()
	;CommonFlashEnd ("")
	Local $btdrive, $btfolder, $btfile, $btext
	$btsel = FileOpenDialog ("Select BCD Diagnostic File", "C:\", "BCD Diagnostic Files (Diagnostic.BCDArray.*;Diagnostic.BCDRaw.*)")
	_PathSplit ($btsel, $btdrive, $btfolder, $btfile, $btext)
	$btpath = $btdrive & $btfolder
	$btfile = $btfile  & $btext
	If $btfile = "Diagnostic.BCDRaw.verbose.txt" Then
		$bcdallarray   = BaseFuncArrayRead ($btsel, "BCDTest A")
		;_ArrayDisplay  ($bcdallarray, "BCDAllArray")
		Return "rawarray"
	ElseIf $btfile = "Diagnostic.BCDArray.txt" Then
		$bcdarray      = BaseFuncArrayRead ($btpath & "Diagnostic.BCDArray.txt",      "BCDTest B","", "", $bcdfieldcount + 1)
		$bcdorderarray = BaseFuncArrayRead ($btpath & "Diagnostic.BCDOrderArray.txt", "BCDTest C", "", "", $bcdfieldcount + 1)
		BCDPopulate ()
		;_ArrayDisplay ($bcdarray,      "BCDArray")
		;_ArrayDisplay ($bcdorderarray, "BCDOrderArray")
		Return "bcdarray"
	Else
		Return "error"
	EndIf
EndFunc

Func BCDGetBootArray ()
	If $bootos = $xpstring Then Return
	;_ArrayDisplay ($bmworkarray, "Work")
	$gbatimehandle = TimeTickInit ()
	Local $gbacurrid, $gbacurrpath, $gbacurrtype, $gbacurrdesc, $gbacurrletter
	Local $gbaskip, $gbaorderfound, $gbaworkorder, $gbadefault, $gbatranidfound
	Dim $gbaworkorder   [0] [$bcdfieldcount + 1]
	Dim $bcdarray       [0] [$bcdfieldcount + 1]
	Dim $bcdorderarray  [0] [$bcdfieldcount + 1]
	Local $gbaordertype
	$bcdtestguid    = ""
	$gbaprevline    = ""
	If $bcdfirstrun = "" Then $bcdallarray = CommonBCDRun  ("/v /enum all", "detail")
	$bcdfirstrun    = "no"
	If $bcdteststatus Then
		$bcdstatus = BCDTest ()
		MsgBox  ($mbontop, "BCD Test Status", $bcdstatus)
		;If $bcdstatus = "bcdarray" Then Return
	EndIf
	$bcdbound    = UBound ($bcdallarray) - 1
	For $bcdsub  = 1 To $bcdbound
		$gbaline = $bcdallarray [$bcdsub]
		If StringLeft  ($gbaline, 1) <> " " Then $gbaorderfound = "no"
		Select
			Case StringLeft   ($gbaprevline, 5) = $bcddashline And StringInStr ($gbaline, "{") And StringInStr ($gbaline, "}")
				$gbatranidfound = "yes"
				BCDBreak ($gbaordertype, $gbacurrtype, $gbacurrdesc, $gbacurrid, $gbacurrletter, $gbacurrpath)
				$gbacurrtype   = ""
				$gbacurrletter = ""
				$gbaordertype  = ""
				$gbacurrid     = BCDParseID ($gbaline)
				If $gbacurrid = $firmmanid Then
					$gbacurrtype  = $firmmanstring
					$gbaordertype = $firmmanstring
				EndIf
				If $gbacurrid = $bootmanid Then
					$gbacurrtype  = $bootmanstring
					$gbaordertype = $bootmanstring
				EndIf
				$gbacurrpath = ""
				$gbacurrdesc = ""
				;Msgbox ($mbontop, "ID", $gbaline & @CR & $gbacurrtype & @CR & $gbaskip)
			Case StringLeft ($gbaline, 11) = "description"
				$gbacurrdesc = BCDParseLine ($gbaline, "description")
			Case $gbaskip = "yes"
			Case StringLeft  ($gbaline, 12) = "displayorder"
				$gbaorderfound = "yes"
			Case StringLeft  ($gbaline,  6) = "device"
				$gbaline = BCDParseLine ($gbaline, "device")
				$gbaline = BCDParseLine ($gbaline, "partition=")
				If StringLen ($gbaline) = 2 Then $gbacurrletter = $gbaline
			Case StringLeft ($gbaline, 4)  = "path"
			   $gbacurrpath = BCDParseLine ($gbaline, "path")
			   If StringInStr ($gbacurrpath, $winloaderefi)   Then $gbacurrtype = "win-instance"
			   If StringInStr ($gbacurrpath, $bootloaderbios) And $gbacurrletter = $masterdrive Then $biosprevfound = "yes"
			Case StringLeft ($gbaline,  7)  = "default"
				$gbadefault  = BCDParseID ($gbaline)
			Case StringLeft ($gbaline, 12)  = "bootsequence" And $gbacurrtype = $firmmanstring
				$bcdtestguid = BCDParseID ($gbaline)
			Case StringLeft  ($gbaline,  7) = "timeout"
				$bcdprevtime  = BCDParseLine ($gbaline, "timeout")
				$timeoutwin  = $bcdprevtime
		 EndSelect
		;MsgBox ($mbontop, "Ord", $gbaline & @cr & $gbaorderfound)
		If $gbaorderfound = "yes" Then
			$gbaordid    = BCDParseID ($gbaline)
			_ArraySearch ($bcdorderarray, $gbaordid, 0, 0, 0, 0, 0, $bGUID)
			If @error Then
				$gbaordersub = _ArrayAdd ($bcdorderarray, "")
				If $bcdorderarray [$gbaordersub] [$bOrderType] <> $firmmanstring Then _
				   $bcdorderarray [$gbaordersub] [$bOrderType] =  $gbaordertype
				$bcdorderarray [$gbaordersub] [$bGUID]      = $gbaordid
				$bcdorderarray [$gbaordersub] [$bSortSeq]   = Ubound ($bcdorderarray) * 100
				If $gbaordid = $bootmanid Then $bcdorderarray [$gbaordersub] [$bSortSeq] = 100
			EndIf
		EndIf
		$gbaprevline = $gbaline
	Next
	If $bcdteststatus Then _ArrayDisplay ($bcdorderarray, "BCD Test OrderArray After")
	BCDBreak    ($gbaordertype, $gbacurrtype, $gbacurrdesc, $gbacurrid, $gbacurrletter, $gbacurrpath)
	If $gbatranidfound = "" Then CommonBCDError ("BCD Ident not found " & $langheader)
	BCDPopulate ()
	If $bcdteststatus Then _ArrayDisplay ($bcdarray, "BCD Test BCDArray After")
	If $runtype <> $parmsetup Or $bcdtimecount < 2 Then
		$bcdtimecount += 1
		$bcdtimetotal += TimeTickDiff ($gbatimehandle)
	EndIf
	$bcdtimestatus = "  BCD Time " & TimeFormatSeconds ("", $bcdtimetotal) & "  "
	If $bcdtimecount > 1 Then _
		$bcdtimestatus = "  BCD Count " & $bcdtimecount & "  Average Time " & TimeFormatSeconds ("", ($bcdtimetotal / $bcdtimecount)) & "  "
EndFunc

Func BCDPopulate ()
	$bpsub = 0
	While Ubound ($bcdorderarray) > 0 And $bpsub <= Ubound ($bcdorderarray) - 1
	    $bpdel     = "yes"
		$bpordguid = $bcdorderarray [$bpsub] [$bGUID]
		$bpmainloc = _ArraySearch ($bcdarray, $bpordguid, 0, 0, 0, 0, 0, $bGUID)
		Select
			Case $bpmainloc < 0
				$bpsub += 1
				ContinueLoop
			Case $firmwaremode = "EFI" And $bcdorderarray [$bpsub] [$bOrderType] <> $firmmanstring
			Case StringInStr ($bcdarray [$bpmainloc] [$bPath], $winbootmgr) And $bcdarray [$bpmainloc] [$bGUID] <> $bootmanid       ; Extraneous Windows Boot Managers
			Case Else
				$bpdel = ""
		EndSelect
		$bcdarray [$bpmainloc] [$bSortSeq]     = $bcdorderarray [$bpsub] [$bSortSeq]
		If $bpdel = "yes" Then
			_ArrayDelete ($bcdorderarray, $bpsub)
			ContinueLoop
		EndIf
		$bcdorderarray [$bpsub] [$bItemType]      = $bcdarray [$bpmainloc] [$bItemType]
		If $bcdorderarray [$bpsub] [$bOrderType]  = $firmmanstring Then $bcdorderarray [$bpsub] [$bItemType] = "firm-os"
		If $bcdorderarray [$bpsub] [$bGUID]       = $bootmanid Then $bcdorderarray [$bpsub] [$bItemType] = $bootmanstring
		$bcdorderarray [$bpsub] [$bItemTitle]     = $bcdarray [$bpmainloc] [$bItemTitle]
		$bcdorderarray [$bpsub] [$bItemTitlePrev] = $bcdarray [$bpmainloc] [$bItemTitle]
		$bcdorderarray [$bpsub] [$bDrive]         = $bcdarray [$bpmainloc] [$bDrive]
		$bcdorderarray [$bpsub] [$bPath]          = $bcdarray [$bpmainloc] [$bPath]
		$bcdarray [$bpmainloc] [$bOrderType]      = $bcdorderarray [$bpsub] [$bOrderType]
		$bcdarray [$bpmainloc] [$bItemType]       = $bcdorderarray [$bpsub] [$bItemType]
		$bcdarray [$bpmainloc] [$bSortSeq]        = $bcdorderarray [$bpsub] [$bSortSeq]
		$bpsub += 1
	Wend
	If Ubound ($bcdorderarray) = 0 Then Dim $bcdorderarray  [1] [$bcdfieldcount + 1]
	If $firmwaremode = "EFI" Then
		BCDWinOnly   ()
	EndIf
EndFunc

Func BCDBreak ($bbordertype, $bbtype, $bbdesc, $bbid, $bbletter, $bbpath)
	;If $bbtype   = "" Then Return
	$bbsub = _ArrayAdd ($bcdarray, "")
	If $bbtype = $bootmanstring and $bbid <> $bootmanid Then $bbtype = ""
	;MsgBox ($mbontop, "Dup " & $bcdarray [$bbsub] [$bNoShowFirm], $bcdduppath & @CR & @CR & $bbpath & @CR & @CR & $bcddupguid & @CR & @CR & $bbid)
	If $bcdarray [$bbsub] [$bOrderType] <> $firmmanstring Then $bcdarray [$bbsub] [$bOrderType] = $bbordertype
	$bcdarray [$bbsub] [$bOrderType] = $bbordertype
	$bcdarray [$bbsub] [$bItemType]  = $bbtype
	$bcdarray [$bbsub] [$bItemTitle] = $bbdesc
	$bcdarray [$bbsub] [$bGUID]      = $bbid
	$bcdarray [$bbsub] [$bDrive]     = $bbletter
	$bcdarray [$bbsub] [$bPath]      = $bbpath
EndFunc

Func BCDCheckDups (ByRef $cdarray)
	$cdduppath = ""
	;_ArrayDisplay ($cdarray, "Dups Before " & $cdduppath)
	$cdsub     = 0
	While 1
		$cdlimit = Ubound ($cdarray) - 1
		If $cdsub < 0 Or $cdsub > $cdlimit Then ExitLoop
		$cdpath  = $cdarray [$cdsub] [$bPath]
		If ($cdsub > 0 And ($cdpath = $efipathwindows Or $cdpath = $efipathgrub)) Or _
			StringInStr ($cdduppath, $cdpath) Then
			    If $cdpath = $cdarray [0] [$bPath] Then $cdarray [0] [$bGUID] = $cdarray [$cdsub] [$bGUID]
			    _ArrayDelete ($cdarray, $cdsub)
				$cdsub -= 1
				$cdduppath = ""
				ContinueLoop
		EndIf
		$cdduppath &= "-" & $cdpath
		$cdsub += 1
	Wend
	;_ArrayDisplay ($cdarray, "Dups After " & $cdduppath)
EndFunc

Func BCDOrderSort (ByRef $bosarray, $bostype = "")
	$bosdisplay = ""
	;_ArrayDisplay ($bosarray, "BCDOrderSort Before")
	_ArraySort ($bosarray, 0, 0, 0, $bSortSeq)
	If $bostype = "" Then BCDCheckDups ($bosarray)
	;_ArrayDisplay ($bosarray, "BCDOrderSort After B")
	For $boslinecount = 0 To Ubound ($bosarray) - 1
		If $bosarray [$boslinecount] [$bItemType] = "" Then ExitLoop
		If $bosarray [$boslinecount] [$bGUID]     = $bootmanid Then ContinueLoop
		If StringInStr ($bosdisplay, $bosarray [$boslinecount] [$bGUID]) Then ContinueLoop
		;If $boslinecount = 0 Then $bosarray [$boslinecount] [$bGUID] = $bootmanid
		$bosdisplay &= " " & $bosarray [$boslinecount] [$bGUID]
	Next
	;MsgBox ($mbontop, "BOS", $bosdisplay)
	;_ArrayDisplay ($bosarray, "BOS " & $bosdisplay)
	Return $bosdisplay
EndFunc

Func BCDGetUpdateMessage (ByRef $gumarray, $gumgetgrub = "")
	;_ArrayDisplay ($gumarray)
	Local $gumgrubslot = "no", $gumupdateslot, $gummessage
	For $gumsub = 0 To Ubound ($gumarray) - 1
		If $gumgetgrub <> "" And $gumarray [$gumsub] [$bPath] = $efipathgrub Then $gumgrubslot = $gumsub
		If $gumarray [$gumsub] [$bUpdateHold] <> "" Then $gumupdateslot = $gumsub
	Next
	If $gumgrubslot <> "no" Then Return "Grub2Win Will Boot From EFI Firmware Slot " & $gumgrubslot + 1
	If $gumarray [$gumupdateslot] [$bUpdateHold] = "moved" Then _
	    $gummessage = "    Slot " & $gumupdateslot + 1 & ' Is Now "' & $gumarray [$gumupdateslot] [$bItemTitle] & '"'
	If $gumarray [$gumupdateslot] [$bUpdateFlag] = "default" Then _
	    $gummessage = "     ** " & $gumarray [$gumupdateslot] [$bItemTitle] & " In Now The Default **"
	Return $gummessage
EndFunc

Func BCDSetupEFI ($setype = "windows", $sepath = "", $sedesc = "")
	If $backupcomplete <> "" Then  Return
	If $sepath = "" Then $sepath  = $bcdorderarray [0] [$bPath]
	If $sedesc = "" Then $sedesc  = $bcdorderarray [0] [$bItemTitle]
	;MsgBox ($mbontop, "EFISet A", $setype & @CR & $sepath & @CR & $sedesc)
	Select
		Case $setype = "windows"
			$sedesc = $efidescwindows
			$sepath = $efipathwindows
		Case $setype = "grub2win"
			$sedesc = $efidescgrub
			$sepath = $efipathgrub
		Case $sepath = $efipathwindows Or $sepath = $efipathgrub
		Case Else
			SettingsPut ($setefioldpath, $sepath)
			SettingsPut ($setefiolddesc, $sedesc)
	EndSelect
	;MsgBox ($mbontop, "EFISet B", $setype & @CR & $sepath & @CR & $sedesc)
	;_ArrayDisplay ($bcdorderarray, "Setup EFI " & $bootmanid & $orderfirmdisplay)
	CommonBCDRun ('/set {bootmgr}   path '         & $sepath,          "setupefi-path")
	CommonBCDRun ('/set {bootmgr}   description "' & $sedesc & '"',    "setupefi-description")
	CommonBCDRun ('/set {fwbootmgr} displayorder {bootmgr} /addfirst', "setupefi-createaddfirst")
	BCDGetBootArray ()
EndFunc

Func BCDSetFirmOrder ()
	CommonFlashStart    ("Updating The EFI Firmware Order")
	BackupMake ()
	GUICtrlSetState    ($buttonorderapply, $guihideit)
	;_ArrayDisplay ($bcdorderarray, "SetFirm " & $bootmanid & $orderfirmdisplay)
	BCDSetupEFI    ("")
	$bsfmessage = BCDGetUpdateMessage ($bcdorderarray)
	CommonBCDRun        ('/set {fwbootmgr} displayorder ' & $bootmanid & $orderfirmdisplay, "setorder")
	;$bsfsplit = _StringBetween ($orderfirmdisplay, "{", "}")
	;If IsArray ($bsfsplit) Then CommonBCDRun ('/set {fwbootmgr} bootsequence {' & $bsfsplit [0] & '}')
	$bcdfirstrun    = ""
	BCDGetBootArray ()
	CommonFlashEnd  ("EFI Firmware Order Has Been Set")
	CommonWriteLog  ()
	CommonWriteLog  ("    The EFI Firmware Boot Order Slots Have Changed")
   	If $bsfmessage  <> "" Then CommonWriteLog ($bsfmessage)
	;_ArrayDisplay ($bcdfirmorder, "After Firmware set displayorder")
	Return $bcdorderarray
EndFunc

Func BCDSetWinOrderEFI ()
	If $bcdwinorderflag = "" Then Return
	$bswdisplay = BCDOrderSort ($bcdwinorder, "win")
	$bswdefault = $bcdwinorder [0] [$bGUID]
	BCDSetWinDescEFI ()
	If $bswdisplay = $bcdwindisplayorig Then Return
	;MsgBox ($mbontop, "WINORD", "Default " & $bswdefault & @CR & @CR & "Display Order " & $bswdisplay)
	CommonBCDRun   ('/set {bootmgr} displayorder ' & $bswdisplay, "setorder")
	CommonBCDRun   ('/set {bootmgr} default      ' & $bswdefault, "setdefault")
	CommonWriteLog ()
	CommonWriteLog ("          The Windows Boot Order Has Been Updated")
EndFunc

Func BCDSetWinDescEFI ()
	;_ArrayDisplay ($bcdwinorder, "Desc")
	For $bswsub = 0 To Ubound ($bcdwinorder) - 1
		If $bcdwinorder [$bswsub] [$bItemTitle] = $bcdwinorder [$bswsub] [$bItemTitlePrev] Then ContinueLoop
		CommonBCDRun   ('/set ' & $bcdwinorder [$bswsub] [$bGUID] & ' description "' & _
		    $bcdwinorder [$bswsub] [$bItemTitle] & '"', "setwindesc")
		CommonWriteLog ()
		CommonWriteLog ('          The Windows Boot Description  "' & $bcdwinorder [$bswsub] [$bItemTitlePrev] & '"  Has Been Updated')
		CommonWriteLog ('          The New Description Is        "' & $bcdwinorder [$bswsub] [$bItemTitle] & '"')
	Next
EndFunc

Func BCDWinOnly ()
	If IsArray ($bcdwinorder) Then Return
	$bcdwinorder = $bcdarray
	$bwosub = 0
	While 1
		$bwolimit = Ubound ($bcdwinorder) - 1
		If $bwosub > $bwolimit Then ExitLoop
		If $bcdwinorder [$bwosub] [$bItemType] <> "win-instance" Or $bcdwinorder [$bwosub] [$bDrive] = "" Then
			_ArrayDelete ($bcdwinorder, $bwosub)
			ContinueLoop
		EndIf
		$bcdwinorder [$bwosub] [$bItemTitlePrev] = $bcdwinorder [$bwosub] [$bItemTitle]
		$bwosub += 1
	Wend
	_ArraySort ($bcdwinorder, 0, 0, 0, $bSortSeq)
EndFunc

Func BCDSetWinTimeout ($swtimeout)
	$swmsg = $swtimeout & " seconds"
	If $timewinenabled <> "yes" Then
		$swtimeout = $winbootoff
		$swmsg     = "disabled"
	EndIf
	If $swtimeout <> $bcdprevtime Then
		CommonBCDRun ("/timeout " & $swtimeout, "settimeout")
		$swmsg       = "now "     & $swmsg
	EndIf
	CommonWriteLog ()
	CommonWriteLog ("          The Windows boot timeout is " & $swmsg)
EndFunc

Func BCDSetDefault ($sdtype, $sdflash = "yes")
	$sddisplay  = BaseFuncCapIt ($sdtype)
	If $sdflash = "yes" Then CommonFlashStart ("Setting " & $sddisplay & " As Default")
	$bcdfirstrun    = ""
	BCDSetupEFI     ($sdtype)
	CommonWriteLog   ()
	CommonWriteLog   ("    " & $sddisplay & " Has Been Set As")
	CommonWriteLog   ("    The Default EFI Boot Manager")
	CommonFlashEnd   ($sddisplay & " Has Been Set As Default")
	$ordercurrentstring = BCDOrderSort ($bcdorderarray)
	$efidefaulttype     = $unknown
EndFunc

Func BCDSetupBIOS ($sbtimeout = $timeoutwin, $sbsetup = "yes")
	BCDSetWinTimeout ($sbtimeout)
	If $biosprevfound = "yes" And $sbtimeout = $bcdprevtime Then
		If $sbsetup = "yes" Then CommonWriteLog ("          The Grub2Win BCD entry already exists. No BCD changes are required.", 2)
		Return 0
	EndIf
	If $biosprevfound = "yes" Then
		If $sbsetup = "yes" Then CommonWriteLog ("               The Grub2Win BCD entry already exists. No new entry is required.")
		Return 0
	EndIf
	BCDCleanup    ()
	CommonWriteLog("                Adding the new Grub2Win entry to the BCD for " & $masterdrive & "\" & $biosbootstring)
	CommonWriteLog('                  The title is -  "' & $biosdesc & '"')
	$sbarray = CommonBCDRun(' /create /d "' & $biosdesc & '" /application bootsector', "biosentry")
	If @error Then Return 1
	$newcheck = $sbarray [4]
	$bcdnewid = BCDParseId($newcheck)
	If $bcdnewid <> "" Then
		CommonWriteLog ("                   BCD ID " & $bcdnewid & " was successfully created", 2)
		CommonBCDRun   ("/set " & $bcdnewid & " device partition=" & $masterdrive, "biospart")
		CommonBCDRun   ("/set " & $bcdnewid & " path \" & $biosbootstring, "biospath")
		CommonBCDRun   ("/displayorder " & $bcdnewid & " /addlast", "biosadd")
		CommonBCDRun   ("/set {default} bootmenupolicy legacy", "legacy", "")
		Return 0
	Else
		CommonWriteLog("                *** The creation of BCD ID " & $bcdnewid & " failed ***", 2)
		Return 1
	EndIf
EndFunc

Func BCDCleanup ($bcoldrelease = "")
	If $bootos = $xpstring Then Return
	;MsgBox ($mbontop, "Cleanup", "")
	If $firmwaremode = "EFI" Then
        $bcoldpath = SettingsGet ($setefioldpath)
   		$bcolddesc = SettingsGet ($setefiolddesc)
		$bcmsg     = @CR
		If $bcoldpath = $unknown Then
			$bcmsg &= "Setting EFI Default Boot To Windows"                   & @CR & @CR
			CommonWriteLog ($bcmsg)
			BCDSetupEFI    ("windows")
		Else
			If FileExists ($winefiletter & $bcoldpath) Then
				$bcmsg &= "**** Setting EFI Default Boot To The Former Value" & @CR & @CR
				$bcmsg &= "****    Description   " & $bcolddesc               & @CR & @CR
				$bcmsg &= "****    Path          " & $bcoldpath               & @CR & @CR
				CommonWriteLog ($bcmsg)
				BCDSetupEFI    ("", $bcoldpath, $bcolddesc)
			Else
				$bcmsg &= "**** The EFI File For " & $bcolddesc               & @CR
				$bcmsg &= "**** Was Not Found"                                & @CR & @CR
				$bcmsg &= "**** Path         " & $bcoldpath                   & @CR & @CR
				$bcmsg &= "**** Setting EFI Default Boot To Windows"          & @CR & @CR
				CommonWriteLog ($bcmsg)
				BCDSetupEFI    ("windows")
				If CommonParms ($parmuninstall) And Not CommonParms ($parmquiet) _
				Then MsgBox ($mbinfook, "** Uninstall Set EFI Default **", $bcmsg)
			EndIf
		EndIf
	EndIf
	If Ubound ($bcdcleanuparray) = 1 Then _
		_ArrayAdd ($bcdcleanuparray, "Start BCD Cleanup Run " & TimeLine ("", "", "yes"))
	For $bcsub = 0 To Ubound ($bcdarray) - 1
		$bcdelete = ""
		$bcpath   = $bcdarray [$bcsub] [$bPath]
		If (StringInStr ($bcpath, $bootmanefi32) Or StringInStr ($bcpath, $bootmanefi64) _
			Or StringInStr ($bcpath, $bootloaderbios)) And $bcoldrelease = "" Then $bcdelete = "yes"
		If $bcdelete = "" Then ContinueLoop
		_ArrayAdd ($bcdcleanuparray, "")
		_ArrayAdd ($bcdcleanuparray, 'Deleting BCD Entry  "' & $bcdarray [$bcsub] [$bItemTitle] & '"   Path = ' & $bcpath)
		_ArrayAdd ($bcdcleanuparray, "ID =              "    & $bcdarray [$bcsub] [$bGUID] & @CR)
		$bcrc = BCDDelete ($bcdarray [$bcsub] [$bGUID])
		If $bcrc <> 0 Then MsgBox ($mbwarnok, "Delete Failed", $bcdarray [$bcsub] [$bItemTitle])
	Next
	If $bcoldrelease = "yes" Then
		_ArrayAdd ($bcdcleanuparray, "End BCD Cleanup Run")
		If Ubound ($bcdcleanuparray) > 3 Then BaseFuncArrayWrite ($bcdcleanuplog, $bcdcleanuparray)
		Return
	EndIf
	BCDGetBootArray ()
EndFunc

Func BCDDelete ($bootid)
	If $bootid = $bootmanid Then Return
	CommonBCDRun("/delete " & $bootid & " /cleanup", "delete")
	If @error Then Return 1
EndFunc

Func BCDParseLine ($bplline, $bplparm)
	$bplresult = StringReplace ($bplline, $bplparm, "", 1)
	$bplresult = StringStripWS ($bplresult, 3)
	Return $bplresult
EndFunc

Func BCDParseID ($bpiline)
	$bpistart = StringInStr($bpiline, "{")
	If $bpistart = 0 Then Return
	$bpiend = StringInStr($bpiline, "}")
	$bpiresult = StringMid($bpiline, $bpistart, $bpiend - $bpistart + 1)
	Return $bpiresult
EndFunc