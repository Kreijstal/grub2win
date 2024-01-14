#include-once
#include  <g2common.au3>

Func IconRunGUI($imsub)
	IconSetup      ($imsub)
	IconRefresh    ($imsub)
	While 1
		$imstatusarray = GUIGetMsg(1)
		If $imstatusarray[1] <> $iconhandlescroll and $imstatusarray[1] <> $iconhandlegui Then ContinueLoop
		$iconstatus = $imstatusarray[0]
		Select
			Case $iconstatus = "" Or $iconstatus = 0
			Case $iconstatus = $GUI_EVENT_CLOSE Or $iconstatus = $iconbuttoncancel
				$selectionarray [$imsub] [$sIcon] = $iconhold
				ExitLoop
			Case $iconstatus = $iconhelphandle
				CommonHelp ("Changing The Icon")
				ContinueLoop
			Case $iconstatus = $iconbuttonapply
				ExitLoop
			Case Else
				For $imiconsub = 0 To Ubound ($iconarray) - 1
					If $iconstatus = $iconarray [$imiconsub] [0] Or $iconstatus = $iconarray [$imiconsub] [1] Then
						$selectionarray [$imsub] [$sIcon] = $iconarray [$imiconsub] [2]
						IconRefresh($imsub)
					EndIf
				Next
		EndSelect
	WEnd
	BaseFuncGUIDelete($iconhandlegui)
EndFunc

Func IconSetup($issub)
	CommonCopyUserFiles ("yes")
	$iconhold         = $selectionarray [$issub] [$sIcon]
	$iconhandlegui    = CommonScaleCreate ("GUI",    "Change Icon Menu Slot " & $issub, -1, -1, 104, 97,         -1,  "", $edithandlegui)
	$iconhelphandle   = CommonScaleCreate ("Button", "Help",                            45,  2,   8,  4)
	$iconbuttoncancel = CommonScaleCreate ("Button", "Cancel",                          10, 90,  10,  4)
	$iconbuttonapply  = CommonScaleCreate ("Button", "Apply",                           82, 90,  10,  4)
	$iconhandlescroll = CommonScaleCreate ("GUI", "",                                    0,  6, 104, 80.5, $WS_CHILD, "", $iconhandlegui)
	GUISwitch ($iconhandlescroll)
	GUICtrlSetBkColor ($iconhelphandle, $mymedblue)
	$isvert     = 5
	$ishor      = 7
	Dim $iconarray [1] [3]
	$isiconsub = -1
	$ishandledesc = ""
	FileChangeDir ($iconpath)
	$issearch = FileFindFirstFile ("*.png")
	While 1
		$isfile = FileFindNextFile ($issearch)
		If @error Then ExitLoop
		$isfile = StringLower ($isfile)
		$isdesc = $isfile
		If StringLeft ($isdesc, 10) <> "user-icon-" Then $isdesc = StringReplace ($isdesc, "icon-", "")
		If StringLeft ($isdesc, 10) =  "user-icon-" Then $isdesc = StringReplace ($isdesc, "user-icon-", "user-icon" & @CR)
		$ishandlebutton = CommonBorderCreate _
			($iconpath & "\" & $isfile, $ishor - 1, $isvert - 1.5, 9, 11.5, $ishandledesc, StringTrimRight ($isdesc, 4), 1)
		$isiconsub += 1
		ReDim $iconarray [$isiconsub + 1] [3]
		$iconarray [$isiconsub] [0] = $ishandlebutton
		$iconarray [$isiconsub] [1] = $ishandledesc
		$iconarray [$isiconsub] [2] = StringTrimRight ($isfile, 4)
		$ishor += 20
		If $ishor > 90 Then
			$isvert += 20
			$ishor   = 7
		EndIf
	Wend
	FileClose ($issearch)
	$iconscrollpos = CommonControlGet ($iconhandlegui, $iconhandlescroll, $dummyparm)
	$icondescpos   = CommonControlGet ($iconhandlegui, $ishandledesc, $dummyparm)
	CommonScrollGenerate ($iconhandlescroll, $scalehsize, $icondescpos - $iconscrollpos + 30)
EndFunc

Func IconRefresh($irsub)
	Local $irhandlemove
	For $iriconsub = 0 To Ubound ($iconarray) - 1
		$irhandlebutton = $iconarray [$iriconsub] [0]
		$irhandledesc   = $iconarray [$iriconsub] [1]
		$irdesc         = $iconarray [$iriconsub] [2]
		GUICtrlSetBkColor ($irhandlebutton, $mygreen)
		If $selectionarray [$irsub] [$sIcon] = $irdesc Then
			GUICtrlSetBKColor ($irhandlebutton, $myred)
			$irhandlemove = $irhandledesc
		EndIf
	Next
    CommonScrollCenter ($iconhandlegui, $iconhandlescroll, $irhandlemove, $iconarray)
	GUICtrlSetState($iconbuttonapply, $GUI_FOCUS)
	GUISetBkColor($mygreen, $iconhandlescroll)
	GUISetBkColor($mygreen, $iconhandlegui)
	GUISetState(@SW_SHOW, $iconhandlescroll)
	GUISetState(@SW_SHOW, $iconhandlegui)
EndFunc