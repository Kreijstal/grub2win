#RequireAdmin
#include-once
#include  <g2common.au3>

; UninstallGUI ()
; BaseFuncSingleWrite ("C:\temp\download\test.txt", $uninstinfo)
; MsgBox ($mbontop,"UI", $uninstinfo)

Func UninstallIt ()
	CommonFlashEnd ("", 0)
	UninstallGUI  ()
	$uibatfile     = @TempDir & "\Grub2win.Delete.bat"
	$uiarray       = BaseFuncArrayRead ($sourcepath & "\xxgrubdelete.txt", "UninstallIt")
	_ArrayInsert   ($uiarray, 2,  "set basepath=" & $masterpath)
	BaseFuncArrayWrite ($uibatfile, $uiarray, $FO_OVERWRITE, "", 0)
	CommonFlashEnd ("", 0)
	$loadtime = CommonGetInitTime ($starttimetick)
	If $firmwaremode = "EFI" And $efileveldeployed <> $unknown Then
		$uidummy  = CommonScaleCreate ("GUI", "", 0, 0)
		EFIMain ($actionuninstall, $uidummy, $callermain)
		BaseFuncGUIDelete ($utillogguihandle)
	EndIf
	If IsArray ($licmsgarray) Then CommonLicWarn ()
	If Not CommonParms ($parmquiet) Then CommonFlashStart ("Now completely uninstalling Grub2Win")
	CommonStatsBuild  ($parmuninstall)
	CommonStatsPut    ()
	If $bootos       = $xpstring Then
		XPUninstall     ()
	ElseIf $firmwaremode = "BIOS" Then
		BCDCleanup          ()
		$uiletter           = DirectGetBIOSLetter ()
		If $uiletter = "" Then
			DirectNotFound      ("Uninstall")
		Else
			DirectUninstallBIOS ($uiletter)
		EndIf
	EndIf
	FileClose         ($temploghandle)
	If FileExists     ($shortcutfile) Then FileDelete ($shortcutfile)
	If FileExists     ($winshortcut)  Then FileDelete ($winshortcut)
	RegDelete         ($reguninstall)
	CommonFlashEnd ("")
	If CommonParms    ($parmquiet) Then
		CommonRunBat  ($uibatfile, "Grub2win.Delete.bat", "set quiet=y", @SW_HIDE, "")
	Else
		CommonRunBat  ($uibatfile, "Grub2win.Delete.bat", "", @SW_SHOW, "")
	EndIf
	BaseFuncCleanupTemp ("UninstallIt")
EndFunc

Func UninstallGUI ()
	If CommonParms ($parmquiet) Then Return
	Local $ugreasondata, $ugcommentdata, $ugemaildata
	$uninstinfo       = ""
	$ugdefault        = "** No Reason Given **"
	$ugsevere         = "** I Had A Severe Error At Boot Time !! **"
	$ugwinboot        = "Always Boots Straight To Windows (The Grub2Win Menu Never Appears)"
	$ugsecureboot     = "I Want To Use EFI Secure Boot (This Is Not Possible With The Grub2Win Kernel)"
	$ugerrmsg         = "I Got An Error Message  (Provide An Error Description In The Comments Below)"
	$ugothermsg       = "Other Reasons   (Please Provide Comments Below)"
	$ugstring         = $ugdefault & "|" & $ugsevere & "|I No Longer Need Grub2Win|"   & $ugothermsg   & "|"
	$ugstring        &= $ugwinboot & "|" & $ugerrmsg & "|Grub2Win Did Not Work For Me|" & $ugsecureboot & "|"
	$ugstring        &= "It Was Too Complicated|The Program Was Hard To Use||"
	$ugmsg            = "We are very sorry to see you go" & @CR & "Please tell us why you are leaving so we can make Grub2Win better"
	$ugguihandle      = CommonScaleCreate ("GUI",    "",         -1, -1, 100, 80, "", $WS_EX_STATICEDGE)
	                    CommonScaleCreate ("Label",  $ugmsg,      5,  5,  85,  6, $SS_CENTER)
	$ugreason         = CommonScaleCreate ("Combo",  "",         20, 15,  60,  6)
	$ugcomprompt      = CommonScaleCreate ("Label",  "Please provide your comments  -  They are always welcome", _
						                                         25, 26,  50,  3, $SS_CENTER)
	$ugcomment        = CommonScaleCreate ("Input",  "",         25, 29,  50, 20, $ES_MULTILINE + $ES_WANTRETURN)
	$ugsuppmsg        = 'If you would like help with a Grub2Win problem' & @CR
	$ugsuppmsg       &= 'please click the green "Support" button below'
	                    CommonScaleCreate ("Label",  $ugsuppmsg, 25, 53, 50,  6, $SS_CENTER)
	$ugsupport        = CommonScaleCreate ("Button", "Support",  44, 60, 10,  4)
	$ugcancel         = CommonScaleCreate ("Button", "Cancel",    3, 70, 19,  4)
	$ugcontinue       = CommonScaleCreate ("Button", "Continue The Uninstall", 77, 70,  19, 4)
	GUICtrlSetState   ($ugcomment,     $GUI_FOCUS)
	GUICtrlSetBkColor ($ugcomment,     $mylightgray)
	GUICtrlSetBkColor ($ugsupport,     $mygreen)
	GUICtrlSetData    ($ugreason,      $ugstring, $ugdefault)
					   GUISetBkColor  ($myblue,   $ugguihandle)
	GUISetState       (@SW_SHOW, $ugguihandle)
	While 1
		$ugstatus   = GUIGetmsg ()
		Select
			Case $ugstatus = $ugcontinue Or $ugstatus = $ugreason
			    GUICtrlSetState ($ugcomment, $GUI_FOCUS)
				$ugcommentdata = GUICtrlRead ($ugcomment)
				If CommonCheckDescription ($ugcommentdata) <> "" Then $ugcommentdata = ""
				If $ugstatus = $ugreason Then
					$ugreasondata    = GUICtrlRead ($ugreason)
					If $ugreasondata = $ugwinboot Then UninstallWinBoot ()
					If $ugreasondata = $ugsevere  Then UninstallSevere  ()
				EndIf
				$ugcomplete = "yes"
				If $ugreasondata <> $ugerrmsg And $ugreasondata <> $ugothermsg Then
					GUICtrlSetBkColor ($ugcomprompt, $myblue)
				Else
					If $ugcommentdata = "" Then $ugcomplete = "no"
					GUICtrlSetBkColor ($ugcomprompt, $myyellow)
				EndIf
				If $ugstatus = $ugcontinue And $ugcomplete = "yes" Then ExitLoop
			Case $ugstatus = $ugsupport
				GUISetState     (@SW_MINIMIZE, $ugguihandle)
				If DiagnoseGUI  ("Support", GUICtrlRead ($ugcomment)) Then CommonEndIt ("Diagnostics")
				GUISetState     (@SW_RESTORE, $ugguihandle)
				GUICtrlSetState ($ugcomment,  $GUI_FOCUS)
				ContinueLoop
			Case $ugstatus = $ugcancel
				BaseFuncGUIDelete ($ugguihandle)
				CommonEndIt       ("Cancelled")
		EndSelect
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

Func UninstallSevere ()
	$wbmsg  = "I Understand You Encountered A Severe Error!!" & @CR & @CR
	$wbmsg &= "Please Click The Green Support Button Below So I Can Fix It."
	$wbrc   = MsgBox ($mbwarnok, "", $wbmsg)
EndFunc

Func UninstallWinBoot ()
	$wbmsg  = "Would You Like To View A Help Topic" & @CR & "Concerning This Windows Boot Issue?" & @CR & @CR
	$wbmsg &= "You May Be Able To Fix The Boot Problem."
	$wbrc   = MsgBox ($mbinfoyesno, "", $wbmsg)
	If $wbrc = $IDYES Then
		CommonHelp          ("EFIFirmwareIssues")
		BaseFuncCleanupTemp ("UninstWinBoot")
	EndIf
EndFunc