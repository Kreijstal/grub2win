#include-once
#include <g2common.au3>

Func CustomGenCode ($gcmenusub)
	If $selectionarray [$gcmenusub] [$sAutoUser] = "user" Then Return
	$gcname = CommonCustomName ($selectionarray [$gcmenusub] [$sEntryTitle])
	If $gcname = $custworkstring Then Return
	$gcconfigtempfile = $custconfigstemp & "\" & $gcname
	;MsgBox ($mbontop, "Gen " & $gcmenusub, $gcname & @CR & $gcconfigtempfile)
	If Not FileExists ($gcconfigtempfile) Then
		;_ArrayDisplay ($selectionarray, "Gen " & $gcmenusub)
		;_ArrayDisplay ($custparsearray, "Gen " & $gcmenusub & " " & $selectionarray [$gcmenusub] [$sCustomFunc])
		$gcwarn1 = "** Warning. Custom Code is missing for Menu Entry " & $gcmenusub & "  -  " & $selectionarray [$gcmenusub] [$sEntryTitle]
		$gcwarn2 = "** Sample Code will be substituted for the missing Custom Code"
		CommonWriteLog ("     " & $gcwarn1)
		CommonWriteLog ("     " & $gcwarn2)
		MsgBox ($mbwarnok, "** Error **", $gcwarn1 & @CR & @CR & $gcwarn2)
		$selectionarray [$gcmenusub] [$sCustomName] = ""
		FileCopy ($samplecustcode, $gcconfigtempfile, 1)
	EndIf
	$gctemparray = BaseFuncArrayRead     ($gcconfigtempfile, "CustomGenCode")
	Dim   $gcbuildarray [0]
	Local $gctempinnerarray, $gctempouterarray
	GetPrevStripCustomCode ($gctemparray,  $gctempinnerarray, $gctempouterarray)
	;_ArrayDisplay ($gctempinnerarray, "Build")
	GenMenuHeader      ($gcmenusub,    $gcbuildarray)
	_ArrayAdd          ($gcbuildarray, $customcodestart)
	_ArrayConcatenate  ($gcbuildarray, $gctempinnerarray)
	_ArrayAdd          ($gcbuildarray, $customcodeend)
	If $selectionarray [$gcmenusub][$sReviewPause] > 0 And $selectionarray[$gcmenusub][$sOSType] <> "isoboot" Then _
		_ArrayAdd ($gcbuildarray, "     g2wsleep $reviewpause")
	GenMenuFooter ($gcmenusub, $gcbuildarray)
	;_ArrayDisplay ($gcbuildarray, "Final")
	BaseFuncArraywrite ($custconfigs & "\" & $gcname, $gcbuildarray)
	If  $selectionarray [$gcmenusub] [$sOSType]    =  "submenu" And _
		$selectionarray [$gcmenusub] [$sGraphMode] <> $graphnotset Then _ArrayAdd ($autoarray, "     export gfxpayload")
	_ArrayAdd ($autoarray, "#")
	_ArrayAdd ($autoarray, "     " & $customsourcerec & $gcname)
	_ArrayAdd ($autoarray, "#" )
EndFunc

Func CustomClearWorkFile ($cfsub)
	FileDelete ($customworkfile)
	If $cfsub > Ubound ($selectionarray) - 1 Then Return
	$selectionarray [$cfsub] [$sCustomName] = CommonCustomName ($selectionarray [$cfsub] [$sEntryTitle])
EndFunc

Func CustomGetData ($gdsub)
	If $selectionarray [$gdsub] [$sLoadby] <> $modecustom Then Return ""
	$gdcustname = $selectionarray [$gdsub] [$sCustomName]
	$gdcustfile = $custconfigstemp & "\" & $gdcustname
	;MsgBox ($mbontop, "Work " & $gdsub, $gdcustname & @CR & $gdcustfile)
	Select
		Case FileExists ($customworkfile)
		Case $gdcustfile = $customworkfile
			FileCopy ($sourcepath & $templateempty, $customworkfile, 1)
		Case Else
			FileCopy ($gdcustfile, $customworkfile, 1)
	EndSelect
	$custparsearray  = BaseFuncArrayRead ($customworkfile, "CustomGetData")
	Return CustomConvertData ($custparsearray)
EndFunc

Func CustomConvertData ($cdarray)
	$cdoutput       = ""
	For $cdrecordno = 0 To Ubound ($cdarray) - 1
		$cdrecord = $cdarray [$cdrecordno]
		$cdoutput &= $cdrecord & @CR
	Next
	$cdcheck = StringStripCR ($cdoutput)
	$cdcheck = StringStripWS ($cdcheck, 8)
	If $cdcheck = "" Then $cdoutput = ""
	Return $cdoutput
EndFunc

Func CustomEditData ($edselsub)
	CustomGetData   ($edselsub)
	FileCopy  ($customworkfile, $syntaxorigfile, 1)
	$edstampold  = FileGetTime ($customworkfile, $FT_MODIFIED, $FT_STRING)
	$edtitle     = "Edit Grub2Win Custom Code For Menu Entry " & $edselsub
	$edtitle    &= "          The Title Is " & $selectionarray [$edselsub] [$sEntryTitle]
	CommonNotepad  ($customworkfile, $edtitle, $edithandlegui, $editpromptcust, $editlistcustedit)
	CustomGetData  ($edselsub)
	GUISetBkColor  ($myorange, $edithandlegui)
	$edstampnew  = FileGetTime ($customworkfile, $FT_MODIFIED, $FT_STRING)
	If $edstampnew <> $edstampold Then
		$edsynrc = SynMain ($customworkfile, $edselsub)
		If $edsynrc = "Accepted" Then CommonWriteLog _
			("     ** Warning - Syntax check in menu entry " & $edselsub & " custom code.")
	EndIf
	CustomWriteList   ()
	GUICtrlSetBkColor ($editpromptcust,   $mygreen)
	GUICtrlSetBkColor ($editpromptsample, $mygreen)
	;_ArrayDisplay ($custparsearray, "After 2")
EndFunc

 Func CustomWriteList ()
	$wlcustdata = CustomConvertData ($custparsearray)
	$wlcustdata = StringReplace ($wlcustdata, @CR, @LF)
	;MsgBox ($mbontop, "List", StringLeft ($wlcustdata, 100))
	GuiCtrlSetData ($editlistcustedit, "")
	;MsgBox ($mbontop, "WriteList", $wlcustdata)
	AutoItSetOption ("GUIDataSeparatorChar", @LF)
	GuiCtrlSetData ($editlistcustedit, $wlcustdata)
	AutoItSetOption ("GUIDataSeparatorChar", "|")
	_GUICtrlListBox_UpdateHScroll ($editlistcustedit)
 EndFunc

 Func CustomUserSectionArray ()
	If $userarray [0] = $usersectionstart Then
		_ArrayDelete  ($userarray, 0)
		If StringStripWS ($userarray [0], 7) = "#" Then _ArrayDelete ($userarray, 0)
	EndIf
	$sabound = Ubound ($userarray) - 1
	If $userarray [$sabound] = $usersectionend Then
		_ArrayDelete  ($userarray, $sabound)
		$sabound = Ubound ($userarray) - 1
		If StringStripWS ($userarray [$sabound], 7) = "#" Then _ArrayDelete ($userarray, $sabound)
	EndIf
EndFunc

Func CustomUserSectionEdit ($seaction)
	$sestampold  = FileGetTime ($usersectionfile, $FT_MODIFIED, $FT_STRING)
	If $seaction = "Removal" Then
		FileCopy ($sourcepath & $templateempty, $usersectionfile, 1)
		MsgBox ($mbwarnok, "", "User Section Code Was Removed")
	Else
		While 1
			If $seaction = "Creation" Then
				CommonNotepad  ($usersectionfile, "Creating The User Section Code", $edithandlegui)
				GUISetBkColor  ($myorange, $edithandlegui)
			Else
				CommonNotepad  ($usersectionfile, "Editing The User Section Code", $handleselectiongui, "", $buttonselectionadd)
				GUISetBkColor  ($myblue,  $handleselectiongui)
			EndIf
			If StringStripWS (FileRead ($usersectionfile), 8) <> "" Then ExitLoop
			If CommonQuestion ($mbwarnretrycan, "** No User Section Code Was Entered **", 'Click "Retry" To Enter Code') Then ContinueLoop
			MsgBox ($mbwarnok, "", "User Section Code " & $seaction & " Was Cancelled")
			FileCopy ($usersectionorig, $usersectionfile, 1)
			If $seaction = "Creation" Then FileCopy ($templateempty, $usersectionfile, 1)
			ExitLoop
		Wend
	EndIf
	$sestampnew  = FileGetTime ($usersectionfile, $FT_MODIFIED, $FT_STRING)
	If $sestampnew <> $sestampold Then
		$sesynrc = SynMain ($usersectionfile)
		If $sesynrc = "Accepted" Then CommonWriteLog _
			("     ** Warning - Syntax check in user section code.")
		If $sesynrc = "Cancelled" Then FileCopy ($usersectionorig, $usersectionfile, 1)
		CommonSelArraySync ()
		ReDim $selectionarray [$autohighsub + 1] [$selectionfieldcount + 1]
		If StringStripWS (FileRead ($usersectionfile), 8) = "" Then FileCopy ($sourcepath & $templateempty, $usersectionfile, 1)
		GetPrevConfigUpdate  ($usersectionfile, $autohighsub + 1, "on")
	EndIf
	$scrollforcebottom = "yes"
EndFunc