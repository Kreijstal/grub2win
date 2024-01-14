#include-once
#include  <g2common.au3>

Func MainRunGUI()
	CommonCheckRestrict ()
	MainCheckBootMenu  ()
	If $langfound = "no" And $langselectedcode = "" Then LangWarn ()
	MainGUISetup   ()
	NetLog         ("Grub2Win Total Init", "", $starttimetick, $FO_APPEND)
	$loadtime      = CommonGetInitTime ($starttimetick)
	CommonWriteLog ("    " & $loadtime)
	MainGUIRefresh ("")
	$mrcolorhold = ""
	CommonFlashEnd    ("", 0)
	GUICtrlSetState   ($buttonok, $GUI_FOCUS)
	GUISetState       (@SW_SHOW, $handlemaingui)
	WinSetState       ($handlemaingui, "", @SW_RESTORE)
	While 1
		$mrgreturn = GUIGetMSG  (1)
		$mrgstatus = $mrgreturn [0]
		$mrghandle = $mrgreturn [1]
		If $osfound = "" And $cloverfound = "" Then $mrcolorhold = CommonFlashButton ($buttonselection, $mrcolorhold)
		If $mrgstatus < 1 And $mrgstatus <> $GUI_EVENT_CLOSE And $mrgstatus <> $GUI_EVENT_PRIMARYUP And _
		    $mrgstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $upautohandle <> "" And InetGetInfo ($upautohandle, $INET_DOWNLOADCOMPLETE)
				InetClose ($upautohandle)
				Local $mrgcolor, $mrgmessage
				$mrgnewraw = UpdateGetVersion ($mrgcolor, $mrgmessage)
				If $mrgcolor <> $mygreen Then UpdateRunGUI ($mrgnewraw, $mrgmessage, $mrgcolor)
				$upautohandle = ""
				ContinueLoop
			Case $mrghandle <> $handlemaingui
			Case $mrgstatus = $GUI_EVENT_CLOSE Or $mrgstatus = $buttoncancel
				FileCopy ($usersectionorig, $usersectionfile, 1)
				ThemeRestoreHold ()
				Return 1
			Case $mrgstatus = $GUI_EVENT_PRIMARYUP
				If CommonCheckUpDown ($updowngt, $timeoutgrub, 0, 999) Then MainGUIRefresh ()
				If CommonCheckUpDown ($updownbt, $timeoutwin,  0,  99) Then MainGUIRefresh ()
			Case $mrgstatus = $buttonok
				GUICtrlSetState ($buttonok, $guihideit)
				BackupMake ()
				Return 0
			Case $mrgstatus = $mainhelphandle
				CommonHelp ("The Main Configuration Screen")
				ContinueLoop
			Case $mrgstatus = $buttonpartlist
				MainPartList ()
				ContinueLoop
			Case $mrgstatus = $buttonsysinfo
				MainSysInfo  ()
				ContinueLoop
			Case $mrgstatus = $buttondiag
				If DiagnoseGUI () Then Return 3
				ContinueLoop
			Case $mrgstatus = $mainresthandle
				BackupChoose ()
				ContinueLoop
			Case $mrgstatus = $mainsynhandle
				SynChoose ()
				ContinueLoop
			Case $mrgstatus = $mainupdhandle
				UpdateRunGUI ()
				ContinueLoop
			Case $mrgstatus = $buttonrunefi
				CommonDatabase ()
				EFIMain ($runpartops, $handlemaingui, $callermain, "yes")
				MainGUIRefresh ()
			Case $mrgstatus = $buttondefault
				BCDSetDefault  ("grub2win")
				MainGUIRefresh ()
			Case $mrgstatus = $buttonsetorder
				FirmOrderRunGUI ("Set EFI Firmware order", $orderfirmdisplay)
				MainGUIRefresh  ()
			Case $mrgstatus = $buttonreboot
				UtilReboot      ()
			Case $mrgstatus = $buttonselection
				$selectionholdarray      = $selectionarray
				$selectionholdlastbooted = $defaultlastbooted
				$bcdwinmenuhold = $bcdwinorder
				SelectionRunGUI()
				MainGUIRefresh()
			Case $mrgstatus = $handlegrubtimeout Or $mrgstatus = $handlewintimeout
				MainRefreshTimeout ()
				MainGUIRefresh     ()
			Case $mrgstatus = $checkshortcut
				MainRefreshShortcut ()
				MainGUIRefresh      ()
			Case $mrgstatus = $screenpreviewhandle Or $mrgstatus = $screenshothandle
				ThemeEdit ()
				MainGUIRefresh()
			Case $mrgstatus = $langhandle
				MainGUIRefresh()
			Case $mrgstatus = $graphhandle
				MainGUIRefresh()
			Case $mrgstatus = $defaulthandle
				MainRefreshDefault ()
				MainGUIRefresh  ()
			Case Else
		EndSelect
	WEnd
EndFunc

Func MainGUISetup()
	$handlemaingui = CommonScaleCreate ("GUI", $headermessage & "      L=" & $langheader, -1, -1, 100, 100,-1)
	GUISetBkColor  ($mylightgray, $handlemaingui)
	$origgraphset   = $graphset
	$origlangset    = $langfullselector
	If $timeoutwin  < $shortbootoff Then $timewinenabled = "yes"
	If $langauto    = "yes" Then $origlangset = $langautostring
	$origdefault    = $defaultset
	$mgbootstyle    = "BCD"
	If $bootos      = $xpstring Then $mgbootstyle = $xptargetini
	$mainhelphandle = CommonScaleCreate ("Button", "Help",                1,   1.5,  8, 3.5)
	GUICtrlSetBkColor ($mainhelphandle, $mymedblue)
	$mainresthandle = CommonScaleCreate ("Button", "Restore",            12.0, 1.5,  8, 3.5)
	GUICtrlSetBkColor ($mainresthandle, $mymedblue)
	$mainsynhandle  = CommonScaleCreate ("Button", "Syntax",             23.0, 1.5,  8, 3.5)
	GUICtrlSetBkColor ($mainsynhandle, $mymedblue)
	$mainupdhandle  = CommonScaleCreate ("Button", "Updates",            33.7, 1.5,  7, 3.5)
	GUICtrlSetBkColor ($mainupdhandle, $mymedblue)
	$mgbiosbump     = 14
	If $firmwaremode = "EFI" Or CommonParms ($parmefiaccess) Then
		$buttonrunefi   = CommonScaleCreate ("Button",  $runpartops,        9, 36.5, 22, 4)
		If $firmwaremode = "EFI" Then
			$buttonsetorder = CommonScaleCreate ("Button", "Set EFI Firmware Boot Order", 9, 44.5, 22, 4)
			$buttondefault  = CommonScaleCreate ("Button", ""                       ,     7, 49.5, 26, 4)
			$buttonreboot   = CommonScaleCreate ("Button", "Click To Reboot Your Machine " & @CR & "For EFI Firmware Setup", 9, 68, 22, 7, $BS_MULTILINE)
		EndIf
		$mgbiosbump = 0
	EndIf

	$mainloghandle   = CommonScaleCreate  ("List", "",                      2,    7 + $mgbiosbump, 41,  29, 0x00200000, "")
                       GUICtrlSetBKColor ($mainloghandle, $mylightgray)
	$promptd = CommonScaleCreate("Label", "Boot default OS", 44, 62.7, 20, 3)
	CommonSetupDefault ()
	$promptg = CommonScaleCreate("Label", "Boot graphics mode", 44, 70.3, 20, 3)
	$graphhandle = CommonScaleCreate("Combo", "", 58, 70, 39, 15, -1)
	GUICtrlSetData ($graphhandle, $autostring & "|" & $graphstring, $graphset)
	$promptl = CommonScaleCreate("Label", "Boot locale language", 44, 76.7, 20, 3)
	$langhandle = CommonScaleCreate ("Combo", "", 58, 76.3, 39, 15, -1)
	GUICtrlSetData ($langhandle, $langcombo, $origlangset)
	$checkshortcut     = CommonScaleCreate ("Checkbox", "Desktop Shortcut",      4, 77.2, 15,   3)
	If FileExists ($shortcutfile) Then GUICtrlSetState ($checkshortcut, $GUI_CHECKED)
	$handlegrubtimeout = CommonScaleCreate ("Checkbox", "Grub default timeout",          4, 85.5, 15,   3)
	$updowngt = CommonScaleCreate("Input", $timeoutgrub,                          7, 88.5,  4.5, 3, $ES_RIGHT)
	$labelgt1 = CommonScaleCreate("Label", "seconds",                           12, 88.5,  8,   3)
	$buttonpartlist = CommonScaleCreate("Button",   "Partition List",         29.5, 86,   10,  3.5)
	GUICtrlSetBkColor ($buttonpartlist, $mymedblue)
	$buttonsysinfo  = CommonScaleCreate("Button",   "System Info",              47, 86,   10,  3.5)
	GUICtrlSetBkColor ($buttonsysinfo, $mymedblue)
	$buttondiag     = CommonScaleCreate("Button",   "Diagnostics",              64, 86,   10,  3.5)
	GUICtrlSetBkColor ($buttondiag,    $mymedblue)
	$mgtimeoutwin = $timeoutwin
	If $mgtimeoutwin >= $shortbootoff Then $mgtimeoutwin = 10
	$handlewintimeout = CommonScaleCreate("Checkbox", "Windows boot timeout", 80, 85.5,  18,  3)
	$updownbt = CommonScaleCreate("Input", $mgtimeoutwin,               84, 88.5,  4.5, 3, $ES_RIGHT)
	$labelbt2 = CommonScaleCreate("Label", "seconds",                 89, 88.5,  30,  3)
	$buttoncancel    = CommonScaleCreate("Button", "Cancel", 11, 95, 10, 3.5)
	$buttonselection = CommonScaleCreate("Button", "Manage Boot Menu", 43, 95, 18, 3.5)
	GUICtrlSetBkColor($buttonselection, $myyellow)
	$buttonok = CommonScaleCreate("Button", "OK", 77, 95, 10, 3.5)
EndFunc

Func MainGUIRefresh ($grtrigger = "yes")
	GUISetState         (@SW_RESTORE, $handlemaingui)
	If $grtrigger       <> "" Then $backuptrigger = "yes"
	ThemeMainScreenShot ()
	CommonDisplayLog    ()
	CommonCheckUpDown   ($updowngt, $timeoutgrub, 0, 999)
	CommonCheckUpDown   ($updownbt, $timeoutwin,  0,  99)
	$timeoutok    = ""
	$grlanghold   = ""
	If $timeoutwin   = 0 Then                              $timeoutok = "Windows boot"
	If $timeoutgrub  < 2 And $timegrubenabled = "yes" Then $timeoutok = "Grub"
	MainRefreshLanguage()
	MainRefreshDefault ()
	$graphset = GUICtrlRead ($graphhandle)
	MainCheckErrors ()
	$grdispwin  = $guishowit
	$grdispgrub = $guishowit
	GUICtrlSetState($promptd, $grdispgrub)
	GUICtrlSetState($defaulthandle, $grdispgrub)
	GUICtrlSetState($promptbt, $grdispgrub)
	GUICtrlSetState($promptg, $grdispgrub)
	GUICtrlSetState($graphhandle, $grdispgrub)
	GUICtrlSetState($promptl, $grdispgrub)
	$grlanghold = $grdispgrub
	If $timegrubenabled = "yes" Then
		GUICtrlSetState ($handlegrubtimeout, $GUI_CHECKED)
	Else
		GUICtrlSetState ($handlegrubtimeout, $GUI_UNCHECKED)
	EndIf
	If $timewinenabled = "yes" Then
		GUICtrlSetData  ($updownbt, $timeoutwin)
		GUICtrlSetState ($handlewintimeout, $GUI_CHECKED)
	Else
		GUICtrlSetState ($handlewintimeout, $GUI_UNCHECKED)
	EndIf
	MainRefreshTimeout ()
	GUICtrlSetState   ($promptt,  $grdispwin)
	GUICtrlSetState   ($handlewintimeout, $grdispwin)
	GUICtrlSetBkColor ($buttonselection, $myyellow)
	If StringLeft ($graphset, 7) = "800x600" Then
		CommonThemePutOption ("name", $notheme, $themetempoptarray)
        ThemeBuildScreenShot ($notheme)
		ThemeMainScreenShot  ()
	ElseIf CommonThemeGetOption ("name") = $notheme Then
		GUICtrlSetState($promptg,     $GUI_HIDE + $GUI_ENABLE)
		GUICtrlSetState($graphhandle, $GUI_HIDE + $GUI_ENABLE)
		$graphset = "No"
	 EndIf
	GUISetState (@SW_SHOW, $handlemaingui)
EndFunc

Func MainRefreshLanguage ()
	$rllang = GUICtrlRead ($langhandle)
	$langauto  = ""
	If $rllang = $langautostring Then
		$langauto         = "yes"
        $langselectedcode = $langcode
		$langfullselector = $langautostring
		Return
	EndIf
	$rlsub = _ArraySearch ($langcomboarray, $rllang)
	If $rlsub < 0 Then
		$langselectedcode = $langdefcode
	Else
		$langselectedcode = $langcomboarray [$rlsub] [1]
	EndIf
	$langfullselector  = LangGetFullSelector ($langselectedcode)
EndFunc

Func MainRefreshTimeout ()
	If CommonCheckBox ($handlegrubtimeout) Then
		GUICtrlSetState ($updowngt, $guishowit)
		BaseFuncGUICtrlDelete ($arrowgt)
		$arrowgt = GUICtrlCreateUpdown ($updowngt, $UDS_ALIGNLEFT)
		GUICtrlSetState ($arrowgt,  $guishowit)
		GUICtrlSetState ($labelgt1, $guishowit)
		$timegrubenabled = "yes"
	Else
		GUICtrlSetState ($updowngt, $guihideit)
		GUICtrlSetState ($arrowgt,  $guihideit)
		GUICtrlSetState ($labelgt1, $guihideit)
		$timegrubenabled = "no"
	EndIf
	If CommonCheckBox ($handlewintimeout) Then
		GUICtrlSetState ($updownbt, $guishowit)
		BaseFuncGUICtrlDelete ($arrowbt)
		$arrowbt = GUICtrlCreateUpdown ($updownbt, $UDS_ALIGNLEFT)
		GUICtrlSetState ($arrowbt,  $guishowit)
		GUICtrlSetState ($labelbt2, $guishowit)
		$timewinenabled = "yes"
	Else
		GUICtrlSetState ($updownbt, $guihideit)
		GUICtrlSetState ($arrowbt,  $guihideit)
		GUICtrlSetState ($labelbt2, $guihideit)
		$timewinenabled = "no"
	EndIf
	;MsgBox ($mbontop, "Time", $timewinenabled)
EndFunc

Func MainRefreshDefault ()
	$defaultselect = GUICtrlRead ($defaulthandle)
	$defaultos = StringSplit ($defaultselect, " ")
	$defaultos = $defaultos [1]
	If $defaultos = "" Then $defaultos = 0
	$defaultlastbooted = "no"
	If $defaultselect  = $lastbooted Then $defaultlastbooted = "yes"
	CommonDefaultSync ()
EndFunc

Func MainRefreshShortcut ()
	$rsmakeshortcut = ""
	If CommonCheckBox ($checkshortcut) Then $rsmakeshortcut = "yes"
	$rsmsg          = CommonShortcut  ($rsmakeshortcut)
	CommonWriteLog  ("    " & $rsmsg)
EndFunc

Func MainCheckErrors()
	BaseFuncGUICtrlDelete ($warnhandle)
	GUICtrlSetState    ($buttonok,        $guishowit)
	GUICtrlSetBkColor  ($buttonrunefi,    $mymedblue)
	GUICtrlSetBkColor  ($buttonsetorder,  $mymedblue)
	GUICtrlSetData     ($buttondefault,   "")
	GUICtrlSetState    ($buttondefault,   $guihideit)
	$cecolor           = ""
	$cewarn            = ""
	If $firmwaremode = "EFI" Then
		$cecolor           = $mygreen
		$efileveldeployed  = SettingsGet ($setefideployed)
		;MsgBox ($mbontop, "EFI DEF", $efidefaulttype & @CR & @CR & CommonGetEFIDefaultType (), 2)
		Select
			Case $cewarn <> ""
			Case $winefiletter <> "" And Not FileExists ($winefiletter & "\efi\grub2win")
				$cewarn =  '* Warning *   The GNU Grub EFI modules are not  ' & @CR
				$cewarn &= 'installed to your primary Windows EFI partition ' & @CR & @CR
				$cewarn &= 'Click "EFI Partition Operations" to install them'
				$cecolor = $myorange
			Case Ubound ($bcdorderarray) = 0
				;_ArrayAdd   ($bcdfirmorder, $firmwinbootmgr & "|" & $modewinefi & "|{bootmgr}||\EFI\MICROSOFT\BOOT\BOOTMGFW.EFI||100||" & $modewinefi)
				CommonBCDRun     ('/set {fwbootmgr}  default {bootmgr}', "bootdefault")
				BCDGetBootArray  ()
				$cewarn =  '    Errors Found Parseing Your Windows BCD' & @CR
				$cewarn &= '    The EFI default has been set to'        & @CR
				$cewarn &= '    the Windows EFI Boot manager'
			Case $securebootstatus = "Enabled"
				$cewarn =  'Error - "Secure Boot" is enabled' & @CR
				$cewarn &= 'in your EFI firmware settings' & @CR
				$cewarn &= 'Grub2Win will not boot properly'
				$cecolor = $myred
				If $securebootwarned = "" Then CommonHelp  ("EFI Secure Boot")
				$securebootwarned    = "yes"
			Case $efileveldeployed <> $basefifromrelease Or $efileveldeployed = $unknown
				$cewarn =  'The GNU Grub EFI modules are not current' & @CR
				If $efileveldeployed = $setno Then $cewarn =  'The GNU Grub EFI modules are not installed' & @CR
				$cewarn &= 'Please click "' & $runpartops & '" above' & @CR
				$cewarn &= 'New level = ' & $basefifromrelease & "   Installed level = " & $efileveldeployed
				GUICtrlSetBkColor ($buttonrunefi, $myyellow)
				$cecolor = $myred
			Case $efierrorsfound = "yes"
				$cewarn =  'There were EFI partition errors' & @CR
				$cewarn &= 'Grub2Win cannot continue'
				$cecolor = $myred
			Case $efidefaulttype <> $unknown And $efidefaulttype <> CommonGetEFIDefaultType ()
				$ceresetmsg  = '    Your EFI default boot module was changed'                        & @CR
				$ceresetmsg &= '    from   ' & $efidefaulttype & '   to  '  & CommonGetEFIDefaultType ()
				$ceresetmsg &= '    by an external program.'                                         & @CR & @CR
				$ceresetmsg &= '    This probably happened when Microsoft'                           & @CR
				$ceresetmsg &= '    Windows or Linux software updates were run.'                     & @CR & @CR
				$ceresetmsg &= '    The current module is ' & $bcdorderarray [0] [$bPath]            & @CR & @CR
				$ceresetmsg &= '    No worries. No harm done.'                                       & @CR & @CR
				$ceresetmsg &= '    Simply click "Yes" to set Grub2Win as the'                       & @CR
				$ceresetmsg &= '    proper default EFI boot module.'                                 & @CR & @CR
				$ceresetmsg &= '    Click "No" to leave the default as is.'
				CommonWriteLog (@CR & $ceresetmsg)
				$efidefaultfix = MsgBox ($mbinfoyesno, "** For Your Information **", $ceresetmsg)
				If $efidefaultfix = $IDYES Then
					BCDSetupEFI     ("grub2win")
					If SettingsGet  ($setefiforceload) = $efiforceload Then EFIMain ($actionrefresh, $handlemaingui, "Main")
					$efidefaultfix = ""
					$cecolor = $mygreen
				EndIf
		EndSelect
		$efidefaulttype = $unknown
		If $cecolor = $mygreen Then
			$cewarn  = 'Grub2Win is correctly set as the' & @CR
			$cewarn &= 'default EFI boot manager'
			If SettingsGet ($setefiforceload) = "yes" Then
				$cewarn  = 'Your EFI firmware is set to' & @CR
				$cewarn &= 'unconditionally load Grub2Win at boot time'
			EndIf
			If Not StringInStr ($bcdorderarray [0] [$bPath], $efibootmanstring) Then
				$cecolor = $myorange
				$cewarn  =  'Caution - Grub2Win is not set'     & @CR
				$cewarn &= 'as your default EFI bootmanager'   & @CR
				GUICtrlSetData    ($buttondefault, 'Set Grub2Win As The Default')
				GUICtrlSetBkColor ($buttondefault, $myyellow)
			EndIf
		EndIf
	EndIf
	Select
		Case $cewarn <> "" And $cecolor <> $mygreen
		Case $editmenuerrors <> ""
			$cewarn =  'Warning - Errors were detected'           & @CR
			$cewarn &= 'Please click "Manage Boot Menu" below'    & @CR
			$cewarn &= 'and correct the errors shown in red for'  & @CR
			$cewarn &= $editmenuerrors & "."
			$cecolor = $myyellow
		Case $timeoutok <> ""
			$cewarn =  'Caution - Setting the ' & $timeoutok & ' timeout too low' & @CR
			$cewarn &= 'may prevent menus from displaying'
			$cecolor = $myyellow
		Case $osfound = "" And $cloverfound = ""
			$cewarn =  'To complete Grub2Win configuration'          & @CR
			$cewarn &= 'you must now add or import your OS entries.' & @CR & @CR
			$cewarn &= 'Click the yellow "Manage Boot Menu" button below.'
			$cecolor  = $myred
			If $oswarned <> "" Then $cecolor = $myorange
			$oswarned = "yes"
		Case $cecolor = ""
			Return
	EndSelect
	$cewarncount  = CommonStringCount  ($cewarn, @CR)
	$warnhandle   = CommonScaleCreate ("Label", @CR & $cewarn, 3, 54, 36, ($cewarncount * 2.1) + 7, $SS_CENTER)
	GUICtrlSetBkColor($warnhandle, $cecolor)
	If GUICtrlRead ($buttondefault) <> ""   Then GUICtrlSetState ($buttondefault, $guishowit)
	If $cecolor  = $myred Then GUICtrlSetState($buttonok, $guishowdis)
EndFunc

Func MainCheckBootMenu ()
	$latestsetup = SettingsGet ($setlatestsetup)
	If $firmwaremode <> "EFI" Or CommonParms ($parmquiet) Then Return
	If SettingsGet ($setwarnedbootmenu) <> $setno Then Return
	$cbdiff = TimeJulStamp ($bootstamp) - TimeJulStamp ($latestsetup)
	If $cbdiff < 0 Or ($upticks / 3600000) > 24 Then Return
	If Not FileExists ($screenshotfile) Then ThemeBuildScreenShot ()
	$cbhandle = CommonScaleCreate ("GUI", "Boot Menu Check", -1, -1, 60, 80, -1)
	GUISetBkColor  ($myyellow, $cbhandle)
	$cbmsg  = "We noticed that your machine was recently booted on " & @CR & StringTrimLeft ($bootstamp, 17) & "."
	$cbmsg &= @CR & @CR & "Did the Grub2Win menu shown below appear when you booted your machine?"
	CommonScaleCreate ("Label",   $cbmsg,          2.8,  3, 55, 10, $SS_CENTER)
	CommonScaleCreate ("Picture", $screenshotfile, 2.8, 15, 55, 52)
	GUISetState      (@SW_SHOW, $cbhandle)
	$gbdontask = CommonScaleCreate ("Button", "Don't Ask Me Again",            5, 69, 10, 8, $BS_MULTILINE)
	$gbnogood  = CommonScaleCreate ("Button", "No!" & @CR & "Please Help Me", 26, 69, 10, 8, $BS_MULTILINE)
	$gbmenuok  = CommonScaleCreate ("Button", "Yes" & @CR & "The Menu Is OK", 46, 69, 10, 8, $BS_MULTILINE)
	While 1
		$gbstatus = GUIGetMsg ()
		Select
			Case $gbstatus = $GUI_EVENT_CLOSE
				ExitLoop
			Case $gbstatus = $gbdontask Or $gbstatus = $gbmenuok
				SettingsPut    ($setwarnedbootmenu, TimeFormatDate ($todayjul, "", "", "juldatetime"))
				ExitLoop
			Case $gbstatus = $gbnogood
				BaseFuncGUIDelete ($cbhandle)
				CommonHelp      ("EFI Firmware Issues")
				CommonEndit     ("Success", "no", "", "")
		EndSelect
	Wend
	BaseFuncGUIDelete ($cbhandle)
EndFunc

Func MainSysInfo ()
	CommonFlashStart  ($runtype & " Is Gathering Your System Information", "", 0)
	UtilCreateSysInfo ()
	CommonFlashEnd    ("", 0)
	MsgBox ($mbontop, $sysinfotitle, $sysinfomessage)
EndFunc

Func MainPartList ()
	If $firmwaremode = "EFI" Then CommonEFIMountWin ()
	CommonFlashStart    ($runtype & " Is Scanning Your Disks And Partitions", "", 0)
	PartBuildDatabase   ("yes")
	CommonFlashEnd      ("", 0)
	UtilPartitionReport ()
	ShellExecute        ($notepadexec, $partlistfile, "", "", @SW_MAXIMIZE)
EndFunc