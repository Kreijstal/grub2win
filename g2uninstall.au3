#RequireAdmin
#include-once
#include  <g2common.au3>

;UninstallGUI ()
;BaseFuncSingleWrite ("C:\temp\download\test.txt", $uninstinfo)
;MsgBox ($mbontop,"UI", $uninstinfo)

Func UninstallIt ()
	UninstallGUI ()
	$uibatfile     = @TempDir &   "\Grub2win.Delete.bat"
	$uirc          = FileInstall ("xxgrubdelete.txt", $uninstfile, 1)
	If $uirc       = 0 Then BaseFuncShowError ("** FileInstall Failed **", "UninstallIt")
	FileCopy       ($uninstfile, $uibatfile, 1)
	FileDelete     ($uninstfile)
	CommonFlashEnd ("", 0)
	$loadtime = CommonGetInitTime ($starttimetick)
	$uidummy  = CommonScaleCreate ("GUI", "", 0, 0)
	If $firmwaremode = "EFI" And $efileveldeployed <> $unknown Then
		EFIMain ($actionuninstall, $uidummy, $callermain)
		BaseFuncGUIDelete ($utillogguihandle)
	EndIf
	If IsArray ($licmsgarray) Then CommonLicWarn ()
	If Not CommonParms ($parmquiet) Then MsgBox ($mbinfook, "", "Now completely uninstalling Grub2Win", 2)
	CommonStatsBuild  ($parmuninstall)
	CommonStatsPut    ()
	If $firmwaremode = "BIOS" Then BCDCleanup ()
	If $bootos       = $xpstring Then
		XPIniCleanup    ("uninstall")
		BaseFuncArrayWrite ($xpinifile, $xpiniarray)
		FileDelete      ($xpstubfile)
		FileDelete      ($xploadfile)
	EndIf
	FileClose         ($temploghandle)
	If FileExists     ($shortcutfile) Then FileDelete ($shortcutfile)
	If FileExists     ($winshortcut)  Then FileDelete ($winshortcut)
	RegDelete         ($reguninstall)
	BaseFuncCleanupTemp ("UninstallIt", "")
	If CommonParms    ($parmquiet) Then
		CommonRunBat  ($uibatfile, "Grub2win.Delete.bat", "set quiet=y", @SW_HIDE)
	Else
		CommonRunBat  ($uibatfile, "Grub2win.Delete.bat")
	EndIf
EndFunc

Func UninstallGUI ()
	If CommonParms ($parmquiet) Then Return
	Local $ugreasondata, $ugcommentdata, $ugemaildata
	$uninstinfo       = ""
	$ugcomment        = ""
	$ugcomstatus      = ""
	$ugdefault        = "** No Reason Given **"
	$ugwinboot        = "Always Boots Straight To Windows (The Grub2Win Menu Never Appears)"
	$ugerrmsg         = "I Got An Error Message  (Provide An Error Description In The Comments Below)"
	$ugothermsg       = "Other Reasons   (Please Provide Comments Below)"
	$ugstring         = $ugdefault & "|" & $ugwinboot & "|I No Longer Need Grub2Win|"
	$ugstring        &= $ugerrmsg & "|Grub2Win Did Not Work For Me|" & $ugothermsg & "|"
	$ugstring        &= "It Was Too Complicated|The Program Was Hard To Use||"
	$ugmsg            = "We are very sorry to see you go" & @CR & "Please tell us why you are leaving so we can make Grub2Win better"
	$ugguihandle      = CommonScaleCreate ("GUI",    "",         -1, -1, 100, 80, "", $WS_EX_STATICEDGE)
	                    CommonScaleCreate ("Label",  $ugmsg,      5,  5,  85,  6, $SS_CENTER)
	$ugreason         = CommonScaleCreate ("Combo",  "",         20, 15,  60,  6)
	$ugcomprompt      = CommonScaleCreate ("Label",  "Please provide your comments  -  They are always welcome", _
						                                         25, 25, 50,  2, $SS_CENTER)
	$ugcomment        = CommonScaleCreate ("Input",  "",         25, 28, 50, 20, $ES_MULTILINE + $ES_WANTRETURN)
	                    CommonScaleCreate ("Label",  "If you would like a response - Please provide your email address", _
						                                         25, 52, 50,  2, $SS_CENTER)
	$ugemail          = CommonScaleCreate ("Input",  "",         29, 55, 42,  4)
	$ugcancel         = CommonScaleCreate ("Button", "Cancel The Uninstall", 5, 70, 17, 4)
	$ugcontinue       = CommonScaleCreate ("Button", "Continue", 78, 70,  17, 4)
	GUICtrlSetBkColor ($ugcomment,     $mylightgray)
	GUICtrlSetBkColor ($ugemail,       $mylightgray)
	GUICtrlSetData    ($ugreason,      $ugstring, $ugdefault)
					   GUISetBkColor  ($myblue,   $ugguihandle)
	GUISetState       (@SW_SHOW, $ugguihandle)
	While 1
		$ugstatus = GUIGetmsg ()
		$ugcomplete   = ""
		If ($ugreasondata = $ugerrmsg Or $ugreasondata = $ugothermsg) And $ugcommentdata = "" Then
			$ugcomplete = "no"
			If $ugcomstatus = "" Then GUICtrlSetBkColor ($ugcomprompt, $myyellow)
			$ugcomstatus    = "set"
		Else
			If $ugcomstatus <> "" Then GUICtrlSetBkColor ($ugcomprompt, $myblue)
			$ugcomstatus    = ""
		EndIf
		If $ugstatus = $ugcancel Then
			BaseFuncGUIDelete ($ugguihandle)
			CommonEndIt       ("Cancelled")
		EndIf
		If $ugstatus  = $ugreason Then
			$ugreasondata    = GUICtrlRead ($ugreason)
			If $ugreasondata = $ugwinboot Then UninstWinBoot ()
			ContinueLoop
		EndIf
		If $ugstatus  = $ugcomment  Then
			$ugcommentdata = GUICtrlRead ($ugcomment)
			If CommonCheckDescription ($ugcommentdata) <> "" Then $ugcommentdata = ""
		EndIf
		If $ugstatus  = $ugemail Then $ugemaildata = GUICtrlRead ($ugemail)
		If $ugemaildata <> "" And Not CommonCheckEmail ($ugemaildata) Then
			MsgBox ($mbwarnok, "", "Invalid Email Address" & @CR & @CR & "    " & $ugemaildata & @CR & @CR & "Please Try Again")
			$ugemaildata   = ""
			GUICtrlSetData ($ugemail, "")
			ControlFocus   ($ugguihandle, "", $ugemail)
			ContinueLoop
		EndIf
		If $ugstatus = $ugcontinue And $ugcomplete <> "no" Then ExitLoop
	Wend

	BaseFuncGUIDelete ($ugguihandle)
	$ugreasondata    = StringStripWS ($ugreasondata, 7)
	If $ugreasondata = "" Then $ugreasondata = $ugdefault
	$ugcommentdata   = CommonFormatComment ($ugcommentdata)
	If $ugreasondata <> $ugdefault Or $ugcommentdata <> "" Or $ugemaildata <> "" Then
		$uninstinfo = "UninstallInfo"
		If $ugcommentdata = "" Then $ugcommentdata = "** None **"
		$uninstinfo &= @CR & @CR & "    Reason  = " & $ugreasondata
		$uninstinfo &= @CR & @CR & "    Comment = " & $ugcommentdata
		If $ugemaildata <> "" Then $uninstinfo &= @CR & @CR & "    ReplyMail = " & $ugemaildata
	EndIf
	Return
EndFunc

Func UninstWinBoot ()
	$wbmsg  = "Would You Like To View A Help Topic" & @CR & "Concerning This Windows Boot Issue?" & @CR & @CR
	$wbmsg &= "You May Be Able To Fix The Boot Problem."
	$wbrc   = MsgBox ($mbinfoyesno, "", $wbmsg)
	If $wbrc = $IDYES Then
		CommonHelp          ("EFIFirmwareIssues")
		BaseFuncCleanupTemp ("UninstWinBoot")
	EndIf
EndFunc