#RequireAdmin
#include-once
#include <g2common.au3>

Func UpdateCheckDays ()
	$cddaystogo = $todayjul - UpdateGetParms ()
	CommonWriteLog ("    Update was last checked on " & StringTrimLeft ($updatearray [$sUpLastCheck], 23), Default, "")
	;_ArrayDisplay ($updatearray, $cddaystogo & "-" & $updatetoday & "-" & UpdateGetParms ())
	If $gendateage < 30 Or $updatearray [$sUpRemindFreq] = $updatenever Or $cddaystogo < 0 Then Return
	FileDelete     ($updatechangelog)
	CommonWriteLog ("    Update is auto loading the ChangeLog")
	$upautohandle = InetGet ($downloadurlquery, $updatechangelog, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	If @error Then $upautohandle = ""
EndFunc

Func UpdateRunGUI ($rgnewraw = "", $rgmessage = "", $rgcolor = $mylightgray)
	TimeGetGenDate ($todaydate)
	$updatearray    [$sUpNextRemind] = $todaydate
	$updatehandlevisit  = ""
	$updatehandleview   = ""
	$updatehandledown   = ""
	$updatehandlecheck  = ""
	$updatehandleremind = ""
	$updatehandlefreq   = ""
	$updatehandleclose  = ""
	$updatehandlenext   = ""
	$updatehandlehelp   = ""
	$updatehandleok     = ""
	$rgholdfreq         = $updatearray [$sUpRemindFreq]
	$rgsetdefault       = $rgholdfreq
	$rgpidview          = ""
	GUISetState         (@SW_MINIMIZE, $handlemaingui)
	$sgversion          = "Grub2Win Version " & $basrelcurr & "     Build " & $basrelbuild & "      Released " & $basreldate
	BaseFuncGUIDelete ($updatehandlegui)
	$updatehandlegui    = CommonScaleCreate ("GUI",      $sgversion,             -1,   -1,   50, 85, $WS_EX_STATICEDGE, -1, $handlemaingui)
	$updatehandlehelp   = CommonScaleCreate ("Button",   "Help",                 45,    1,    4,  3.5)
	GUICtrlSetBkColor ($updatehandlehelp, $mymedblue)
	$updatehandlenext   = CommonScaleCreate ("Label",    "",                      1,    5,   47, 12, $SS_CENTER)
	$updatehandlemsg    = CommonScaleCreate ("Label",    "",                      2,   17,   45, 12, $SS_CENTER)
	$updatehandlecheck  = CommonScaleCreate ("Button",   "Check For Updates Now", 9,   29,   33,  8)
	GUICtrlSetBkColor ($updatehandlecheck, $mygreen)
	$updatehandleremind = CommonScaleCreate ("CheckBox", "",                      7,   40.8, 27, 3.5)
	$updatehandlefreq   = CommonScaleCreate ("Combo",    "",                     35,   41,   10, 3.5, -1)
	$updatehandlevisit  = CommonScaleCreate ("Button", _
		@CR & "Visit The Official Grub2Win Site",                               13,   65,   24,   4)
	GUICtrlSetBkColor ($updatehandlevisit, $mymedblue)
	$updatebuttoncancel = CommonScaleCreate ("Button",   "Cancel",                2,   75,   10, 3.8)
	$updatehandleclose  = CommonScaleCreate ("Button",   "Close",                20,   75,   10, 3.8)
	$updatehandleok     = CommonScaleCreate ("Button",   "OK",                   38,   75,   10, 3.8)
	GUICtrlSetState ($updatehandleclose,  $guihideit)
	GUISetBkColor   ($myblue,  $updatehandlegui)
	UpdateDateBox   ()
	If $rgcolor     = $myred Then UpdateSetMessage ($myred, $rgmessage, $rgnewraw)
	GUISetState     (@SW_SHOW, $updatehandlegui)
	$rgsetbox       = $GUI_CHECKED
	If $updatearray [$sUpRemindFreq] = $updatenever Then $rgsetbox = $GUI_UNCHECKED
	GUICtrlSetState ($updatehandleremind, $rgsetbox)
	If $rgsetdefault = $updatenever Then $rgsetdefault = $updatedefault
	GUICtrlSetData  ($updatehandlefreq, $updatedefault & "|60 Days|90 Days", $rgsetdefault)
	UpdateCheckBox  ()
	;_ArrayDisplay ($updatearray)
	While 1
		$rgreturn = GUIGetMSG (1)
		$rgstatus = $rgreturn [0]
		$rghandle = $rgreturn [1]
		Select
			Case $rgstatus  = "" Or $rgstatus = 0
			Case $rgstatus  = $updatebuttoncancel Or $rgstatus = $updatehandleclose
				If $rghandle <> $updatehandlegui Then ContinueLoop
				If $rgstatus = $updatebuttoncancel Then
					$updatearray [$sUpRemindFreq] = $rgholdfreq
					$updatearray [$sUpNextRemind] = $updatearray [$sUpOldRemind]
				EndIf
				ExitLoop
			Case $rgstatus = $updatehandlehelp
				CommonHelp ("Checking For Updates")
				ContinueLoop
			Case $rgstatus = $updatehandledown Or $rgstatus = $updatehandlerefresh
				BaseFuncSingleWrite ($downloadjulian, $todayjul)
				BaseFuncGUIDelete     ($updatehandlegui)
				Sleep (250)
				$rgresult = NetFunctionGUI   ("DownloadExtract", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, _
					"GrubInst", "Grub2Win Software")
				If $rgresult <> "OK" Then
					$setuperror = $rgresult
					ExitLoop
				EndIf
		        SecureAuth      ("Set", $todayjul)
				NetFunctionGUI  ("Run", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, _
					"GrubInst", "Grub2Win Software")
			Case $rgstatus  = $updatehandleview
				If ProcessExists ($rgpidview) Then ContinueLoop
				$rgpidview     = CommonNotepad ($updatechangelog)
			Case $rgstatus  = $updatehandlevisit
				WinClose        ("Grub2Win download", "")
				ShellExecute    ($downloadurlvisit)
				CommonWriteLog  ("*** Visiting the Grub2Win site ***")
			Case $rgstatus  = $updatehandleremind
				$updatearray [$sUpRemindFreq] = UpdateCheckBox ()
				UpdateDateBox ()
			Case $rgstatus = $updatehandlefreq
				$updatearray [$sUpRemindFreq] = GUICtrlRead ($updatehandlefreq)
				UpdateDateBox ()
			Case $rgstatus  = $updatehandlecheck Or $rgstatus = $updatehandleok Or $upautohandle <> ""
				;MsgBox ($mbontop, "Check", $rgstatus & @CR & $updatehandlecheck)
				GUICtrlSetState ($updatehandlecheck,  $guihideit)
				GUICtrlSetState ($updatehandleok,     $guihideit)
				GUICtrlSetState ($updatehandlefreq,   $guihideit)
				GUICtrlSetState ($updatehandleremind, $guihideit)
				GUICtrlSetState ($updatebuttoncancel, $guihideit)
				GUICtrlSetState ($updatehandleclose,  $guishowit)
				If $rgstatus  = $updatehandlecheck Then
					CommonWriteLog ("    Checking for Grub2Win updates", Default, "")
					$updatehandlecheck = CommonScaleCreate ("Label", "", 9,  20,   33,  8, $SS_CENTER)
					GUICtrlSetData     ($updatehandlecheck, "Checking For Grub2Win Updates")
					GUICtrlSetState    ($updatehandleclose,  $guihideit)
					GUICtrlSetState    ($updatehandlevisit,  $guihideit)
					$rgresult = NetFunctionGUI ("Download", $updatechangelog, $downsourcesubproj, "GrubQuery", "Change Log", "")
					GUICtrlSetState    ($updatehandleclose,  $guishowit)
					GUICtrlSetState    ($updatehandlevisit,  $guishowit)
					If $rgresult <> "OK" Then
						$setuperror = $rgresult
						ExitLoop
					EndIf
					$rgnewraw = UpdateGetVersion ($rgcolor,  $rgmessage)
					UpdateSetMessage ($rgcolor, $rgmessage,  $rgnewraw)
					;MsgBox ($mbontop, "Message", $rgcolor & @CR & $rgmessage & @CR & $rgnewraw)
				EndIf
				If $rgstatus = $updatehandleok Then
					If $rgholdfreq = $updatearray [$sUpRemindFreq] Then
						$updatearray [$sUpNextRemind] = $updatearray [$sUpOldRemind]
						UpdateDateBox ()
						ExitLoop
					EndIf
					MsgBox ($mbinfook, "", "The Grub2Win reminder frequency has been updated", 2)
				Else
					UpdateSetMessage ($rgcolor, $rgmessage, $rgnewraw)
				EndIf
				UpdateDateBox ()
		EndSelect
	Wend
	If $rgcolor <> $myred Then UpdatePutParms ($updatearray [$sUpNextRemind])
	BaseFuncGUIDelete ($updatehandlegui)
	GUISetState    (@SW_RESTORE, $handlemaingui)
EndFunc

Func UpdateGetVersion (ByRef $gvcolor, ByRef $gvmessage)
	$gvrecord = BaseFuncSingleRead ($updatechangelog, "yes")
	$gvrecord = StringReplace   ($gvrecord, $currentstring, "")
	$gvrecord = StringReplace   ($gvrecord, @TAB, " ")
	$gvrecord = StringStripWS   ($gvrecord, 7)
	$gvsplit  = StringSplit     ($gvrecord, " ")
	If @error Then Return ""
	$gvnewraw = $gvsplit [2]
	$gvnewver = Number (StringReplace ($gvnewraw,   ".", ""))
	$gvoldver = Number (StringReplace ($basrelcurr, ".", ""))
	If Ubound ($gvsplit) > 7 Then $updatenewbuild = $gvsplit [7]
	;_ArrayDisplay ($gvsplit, $gvnewver & " " & $gvoldver)
	If  $gvoldver  = $gvnewver Then
		$gvmessage = "This is the latest version available"
		$gvcolor   = $mygreen
	Else
		$gvmessage = "The latest version is " & $gvnewraw & @CR & "Please upgrade to the latest version of Grub2Win"
		$gvcolor   = $myorange
	EndIf
	$updatearray   [$sUpLastCheck] = TimeFormatDate ($todaydate)
	UpdatePutParms ()
	Return $gvnewraw
EndFunc

Func UpdateSetMessage ($smcolor, $smmessage2, $smnewraw)
	$upautohandle         = ""
	$updatehandleview     = CommonScaleCreate ("Button", "View The Change Log", 13, 46, 24, 4)
	$smbuildmsg           = "Build " & $updatenewbuild
	If $basrelbuild <> $updatenewbuild Then _
		$smbuildmsg = "From Build " & $basrelbuild & " To " & $smbuildmsg
	$updatehandlerefresh  = CommonScaleCreate ("Button", _
		@CR & "Refresh Grub2Win Version " & $smnewraw & @CR & $smbuildmsg,     13, 53, 24, 9, $BS_MULTILINE)
	GUICtrlSetBkColor  ($updatehandleview,    $mymedblue)
	GUICtrlSetBkColor  ($updatehandlerefresh, $mymedblue)
	GUICtrlSetState    ($updatehandlerefresh, $guihideit)
	GUICtrlSetBkColor  ($updatehandlemsg,     $smcolor)
	CommonLabelJustify  ($updatehandlemsg,  $updateversion & @CR & $smmessage2, 4)
	If FileExists ($updatechangelog) Then
		$smupcolor = $mygreen
		If $smnewraw = $basrelcurr  Then GUICtrlSetState ($updatehandlerefresh, $guishowit)
		$updatehandledown = CommonScaleCreate ("Button", @CR & "Upgrade To Grub2Win Version " & $smnewraw, _
			1, 30, 47, 9, $BS_MULTILINE)
		GUICtrlSetBkColor ($updatehandledown, $smupcolor)
		If $smcolor <> $myorange Then
			GUICtrlSetState ($updatehandledown,    $guihideit)
			GUICtrlSetState ($updatehandlerefresh, $guishowit)
		EndIf
	Else
		GuiCtrlSetState    ($updatehandleview,  $guishowdis)
		GuiCtrlSetState    ($updatehandlevisit, $guishowdis)
		GUICtrlSetBkColor  ($updatehandlemsg,   $myred)
		CommonLabelJustify  ($updatehandlemsg,   "The Grub2Win Update Check Failed." & $updateconnmsg, 4)
	EndIf
	BaseFuncGuiCtrlDelete  ($updatehandlecheck)
	BaseFuncGuiCtrlDelete  ($updatehandleremind)
	BaseFuncGuiCtrlDelete  ($updatehandlefreq)
	GUISetState         (@SW_SHOW, $updatehandlegui)
EndFunc

Func UpdateGetParms ()
	Dim $updatearray [6]
	$updatearray [$sUpNextRemind]    = SettingsGet  ($setupnextremind)
	$updatearray [$sUpRemindFreq]    = SettingsGet  ($setupremindfreq)
	$updatearray [$sUpLastCheck]     = SettingsGet  ($setuplastcheck)
	$updatearray [$sUpOldRemind]     = $updatearray [$sUpNextRemind]
	If $updatearray [$sUpRemindFreq] = $unknown Then $updatearray [$sUpRemindFreq] = $updatedefault
	$gporiginaljul = StringLeft ($updatearray [$sUpNextRemind], 7)
	UpdateCalcDates ()
	Return $gporiginaljul
EndFunc

Func UpdatePutParms ($ppremind = $todaydate, $ppnewfreq = $updatearray [$sUpRemindFreq])
	SettingsPut ($setupnextremind, $ppremind)
	SettingsPut ($setupremindfreq, $ppnewfreq)
	SettingsPut ($setuplastcheck,  $updatearray [$sUpLastCheck])
EndFunc

Func UpdateDateBox ()
	UpdateCalcDates ()
	$dbnextdate = StringTrimLeft  ($updatearray [$sUpNextRemind], 15)
	$dbnextdate = StringTrimRight ($dbnextdate,                   15)
    $dbmsg1 = "The last Grub2Win update check was" & @CR
	$dbmsg2 = $updatearray [$sUpLastCheckDays] & "  days ago  "
	If $updatearray [$sUpLastCheckDays] = 0 Then $dbmsg2 = "Today  "
	If $updatearray [$sUpLastCheckDays] = 1 Then $dbmsg2 = "Yesterday  "
	$dbcheckdate  = StringTrimLeft ($updatearray [$sUpLastCheck], 15)
	$dbfuture     = "in " & $updatearray [$sUpToGoDays] &  " days on "
	If $updatearray [$sUpToGoDays] = 1 Then $dbfuture =  "tomorrow"
	$dbmsg3 = "The next reminder will be " & $dbfuture & $dbnextdate
    If $updatearray [$sUpToGoDays] < 1 Then $dbfuture =  "today" & StringTrimLeft ($todaydate, 15)
	If $updatearray [$sUpRemindFreq] = $updatenever Then $dbmsg3 =  "** Reminders are disabled **"
	$dbmsg = $dbmsg1 & $dbmsg2 & $dbcheckdate & @CR & @CR & $dbmsg3
	GUICtrlSetData ($updatehandlenext, $dbmsg)
EndFunc

Func UpdateCalcDates ()
	$cdlastcheck = StringLeft ($updatearray [$sUpLastCheck], 7)
	If $gendatejul > $cdlastcheck Then $cdlastcheck = $gendatejul
	If $todayjul - $cdlastcheck > 365 Then $updatearray [$sUpLastCheck] = TimeFormatDate ($todayjul - 365)
	$updatearray [$sUpLastCheckDays] = $todayjul - $cdlastcheck
	If $updatearray [$sUpRemindFreq] = $updatenever Then Return
	$cdremindjul = StringLeft (TimeFormatDate ($updatearray [$sUpNextRemind]), 7)
	$cdfreq      = Number (StringLeft ($updatearray [$sUpRemindFreq], 2))
	If $cdremindjul < $todayjul - $cdfreq Then $cdremindjul = $todayjul
	If $cdremindjul + $cdfreq > $todayjul + $cdfreq Then $cdremindjul = $todayjul
    $updatearray [$sUpNextRemind] = TimeFormatDate ($cdremindjul + $cdfreq)
	$updatearray [$sUpToGoDays]   = StringLeft ($updatearray [$sUpNextRemind], 7) - $todayjul
	If $updatearray [$sUpToGoDays] < 0 Then
	   $updatearray [$sUpToGoDays] = 0
	   $updatearray [$sUpNextRemind] = $todaydate
	EndIf
	;_ArrayDisplay ($updatearray, $cdlastcheck)
EndFunc

Func UpdateCheckBox ()
	If CommonCheckBox ($updatehandleremind) Then
		GUICtrlSetState ($updatehandlefreq,   $guishowit)
		GUICtrlSetData  ($updatehandleremind, "Enable Reminders  -  Remind Me Every")
		$cbfreq = GUICtrlRead ($updatehandlefreq)
	Else
		GUICtrlSetState ($updatehandlefreq,   $guihideit)
		GUICtrlSetData  ($updatehandleremind, "Enable Reminders")
		$cbfreq = $updatenever
	EndIf
	;MsgBox ($mbontop, "Check", $cbfreq)
	Return $cbfreq
EndFunc