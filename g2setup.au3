#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <g2common.au3>

If $runtype = $parmsetup Then SetupMain ()

;MsgBox ($mbontop, "Path", $setupmasterpath)

Func SetupMain ()
	If Not StringInStr (@ScriptDir, "install") Then
		MsgBox ($mbontop, "", 'Setup Must Run From The "Install" directory')
		Exit
	EndIf
	CommonPrepareAll     ()
	CommonCheckRestrict  ()
	SetupParms           ()
	SetupCheckBuild      ()
	SecureAuth           ("", $todayjul)
	If  CommonParms      ($parmautoinstall) Then
		SetupAuto  ()
	Else
		SetupByGUI ()
	EndIf
EndFunc

Func SetupParms ()
	If CommonParms ($parmdrive)       Then $setupvaluedrive      = $parmvalue
	If CommonParms ($parmshortcut)    Then $setupvalueshort      = $parmvalue
	If CommonParms ($parmautoresdir)  Then $setupvalueautoresdir = $parmvalue
	If CommonParms ($parmcleanupdir)  Then
		$setupvaluecleanupdir = $parmvalue
		If Not CommonParms ($parmquiet) Then SetupCheckExe ()
	EndIf
EndFunc

Func SetupCheckBuild ()
	If @OSBuild <= $maxosbuild Then Return
	$cbmsg  = $bootos & "   Build = " & @OSBuild        & @CR & @CR & @CR
	$cbmsg &= "Grub2Win Has Not Yet Been Tested"        & @CR
	$cbmsg &= "Against This Preview Build Of Windows."  & @CR & @CR
	$cbmsg &= "You May Encounter Problems."             & @CR & @CR & @CR
	$cbmsg &= "Do You  Want To Continue The Setup?"
	$cbrc = MsgBox ($mbwarnyesno, "** Windows Build Warning **", $cbmsg)
	If $cbrc = $IDYES Then Return
    BaseFuncCleanupTemp ("SetupCheckBuild")
EndFunc

Func SetupAuto ()
	If $setupvaluedrive = "" Then $setupvaluedrive = $windowsdrive
	SetupPrepare      ($setupvaluedrive)
	SetupCopyPrep     ()
	SetupCopyFiles    ($setupvalueshort)
	CommonInitialize  ()
	CommonFlashEnd    ("")
	If $firmwaremode = "EFI" Then
		EFIPrepare      ("", "")
		UtilScanDisks   ()
		EFIAssignAll    ()
		EFIUpdateParts  ("Install")
		EFIReleaseDisk  ()
		EFICloseOut     ("Install", "", "")
	Else
		SetupBootBIOS   ()
	EndIf
	CommonWriteLog       ()
	CommonSetupCloseOut  ()
	If Not CommonParms   ($parmquiet) Then MsgBox ($mbontop, "", "Grub2Win Setup Is Complete", 10)
	BaseFuncCleanupTemp    ("SetupAuto")
EndFunc

Func SetupByGUI ()
	CommonHotKeys      ()
	SetupCreateGUI     ()
	SetupRefreshGUI    ()
	$sgloaddiff        = TimeTickDiff ($starttimetick)
	If $refreshdiff    >  0 Then $sgloaddiff -= $refreshdiff
	CommonWriteLog     ("    " & CommonGetInitTime ("", $sgloaddiff))
	While 1
		$sgstatus = GUIGetMsg ()
		Select
			Case $sgstatus = "" Or $sgstatus = 0
			Case $sgstatus = $setupbuttoncancel Or $sgstatus = $setupbuttonclose Or $sgstatus = $GUI_EVENT_CLOSE
				If $setupstatus <> "complete" Then
					FileDelete    ($downloadjulian)
					CommonWriteLog ("** Setup was cancelled by the user **")
					If $setuperror <> "" Then $setuperror = "* Setup Cancelled" & $setuperror
				EndIf
				If $sgstatus = $setupbuttoncancel Or $sgstatus = $GUI_EVENT_CLOSE Then
					BaseFuncGuiDelete   ($setuphandlegui)
					CommonStatsBuild  ("SetupCancel", "")
					CommonStatsPut    ()
					BaseFuncCleanupTemp ("SetupCancel")
				EndIf
				ExitLoop
			Case $sgstatus = $setuphandledrive
				$basictargetdrive = GUICtrlRead ($setuphandledrive)
				SetupRefreshGUI ()
			Case $sgstatus = $setuphandleshort
			Case $sgstatus = $setupbuttonhelp
				CommonHelp ($setuphelploc)
				ContinueLoop
			Case $sgstatus = $setupbuttonconfirm
				SetupRefreshGUI    ("Confirmed")
				Sleep              (750)
				BaseFuncGuiCtrlDelete ($setuphandlewarn)
				SetupPerformGUI    ()
				ContinueLoop
			Case $sgstatus = $setupbuttoninstall
				SetupPerformGUI ()
				ContinueLoop
			Case Else
		EndSelect
	WEnd
	If $firmwaremode = "EFI" and $securebootstatus = "Enabled" Then
		$sgmsg  = '                          *** Note ***'            & @CR & @CR
		$sgmsg &= '"Secure Boot" is enabled in your EFI Firmware.'    & @CR & @CR
        $sgmsg &= 'It must be disabled for Grub2Win to run properly.' & @CR & @CR
		$sgmsg &= 'Consult your motherboard or PC documentation for further information.'
		MsgBox ($mbwarnok, "", $sgmsg)
	EndIf
	$sgbasepid  = ""
	$sgdelsetup     = CommonCheckBox ($setuphandledel)
	$sgrungrub      = CommonCheckBox ($setuphandlerun)
	BaseFuncGuiDelete      ($setuphandlegui)
	CommonFlashStart     ("**  Setup Is Cleaning Up  **", "", 1000, "")
	CommonSetupCloseOut  ()
	$sgtype     = "Setup"
	If $setuperror <> "" Then $setuperror = "* Setup Continued" & $setuperror
	If CommonParms       ($parmfromupdate) Then $sgtype = "Update"
	If $setupvaluecleanupdir <> "" And $sgdelsetup Then _
		BaseFuncCleanupTemp ("SetupByGUIA", "", "setupfiles", $setupvaluecleanupdir)
	CommonFlashEnd       ("")
	If $sgrungrub And $setupstatus = "complete" Then
		CommonHotKeys    ("off")
		$sgbasepid = Run ($masterexe)
		CommonEnqueue    ("", "Grub2Win Will Start In A Moment", 1000, "")
	Else
		CommonStatsPut ()
		FileDelete     ($workdir & "\grub2win.*")
	EndIf
	BaseFuncCleanupTemp ("SetupByGUIB")
EndFunc

Func SetupCreateGUI ()
	$loadtime          = CommonGetInitTime ($starttimetick)
	$basictargetdrive  = $windowsdrive
	If CommonParms     ($parmdrive) Then $basictargetdrive = $parmvalue
	SetupPrepare       ($basictargetdrive)
	$setuphandlegui     = CommonScaleCreate ("GUI", "",                -1, -1, 65, 86, -1, $WS_EX_TOPMOST)
	GUISetBkColor       ($mymedblue, $setuphandlegui)
	SetupGetDrives      ($setupvaluedrive)
	$setupbuttonhelp    = CommonScaleCreate ("Button", "Help",          2,    2,    6,  4)
	GUICtrlSetBkColor  ($setupbuttonhelp, $mymedblue)
	$ssshortmsg         = "Grub2Win desktop shortcut"
	$setuphandleshort   = CommonScaleCreate ("Checkbox", $ssshortmsg,  17.5, 13.5,   25,  2.5, $BS_LEFT)
	GUICtrlSetState     ($setuphandleshort, $GUI_CHECKED)
	If $setupvalueshort = "no" Then GUICtrlSetState ($setuphandleshort, $GUI_UNCHECKED)
	$ssrunmsg           = "Run Grub2Win after setup finishes"
	$setuphandlerun     = CommonScaleCreate ("Checkbox", $ssrunmsg,    17.5, 20, 28, 2.5, $BS_LEFT)
	GUICtrlSetState    ($setuphandlerun, $GUI_CHECKED)
	$setuphandlewarn    = CommonScaleCreate ("Label",  "",             14,   35, 40, 30, $SS_Center)
	$setupbuttonconfirm = CommonScaleCreate ("Button", "Confirm and Continue Install", 24, 68, 20, 5, $SS_Center)
	$setuphandleefimsg  = CommonScaleCreate ("Label",  "",              1,   75, 65,  4, $SS_Center)
	$setupbuttoncancel  = CommonScaleCreate ("Button", "Cancel",                   4, 80,  8, 4)
	$setupbuttonclose   = CommonScaleCreate ("Button", "Close The Setup Program", 24, 80, 20, 4)
	GUICtrlSetState ($setupbuttonclose, $guihideit)
	$setupbuttoninstall = CommonScaleCreate ("Button", "Setup",                   52, 80,  8, 4)
	$cgstamp = $basgenstamp
	$cgstamp = StringLeft  ($cgstamp, 4) &   " - " & StringMid ($cgstamp, 5, 4) & " - " & StringMid ($cgstamp, 9, 6)
	$cghandlestamp      = CommonScaleCreate ("Label", $cgstamp, 14, 84, 40, 2, $SS_Center)
	GUICtrlSetColor     ($cghandlestamp, $mymedgray)
	If $firmwaremode <> "EFI" Then Return
EndFunc

Func SetupRefreshGUI ($srstatus = "")
	SetupCheckDrive  ($basictargetdrive)
    If $firmwaremode = "EFI" Then SetupCheckEFI ()
	SetupTargetMsg ()
	;MsgBox ($mbontop, "EFI " & $setuptargetdir & "\windata\storage", $efilevelfromrelease & @CR & $efileveldeployed)
	SetUpCheckErrors ($srstatus)
	CommonFlashEnd    ("", 0)
	GUISetState      (@SW_SHOWNORMAL, $setuphandlegui)
	GUISetState      (@SW_RESTORE,    $setuphandlegui)
EndFunc

Func SetupCheckEFI ()
	GUICtrlSetState    ($setuphandleefimsg, $guihideit)
	$setuprefreshefi = ""
	$ssefilvlmsg     = "Your current EFI module level is " & $efileveldeployed
	If $efileveldeployed <> $basefifromrelease Then
		$setuprefreshefi = "yes"
		$ssefilvlmsg     = "Your GNU Grub EFI modules will be updated from level  " & $efileveldeployed & "  to level  " & $basefifromrelease
	EndIf
	If $efileveldeployed = $unknown Then $ssefilvlmsg = "The GNU Grub level " & $basefifromrelease & " modules will be installed to your EFI partition"
	GUICtrlSetData     ($setuphandleefimsg, $ssefilvlmsg)
	GUICtrlSetState    ($setuphandleefimsg, $guishowit)
EndFunc

Func SetupPerformGUI ()
	$spmakeshortcut    = ""
	If CommonCheckBox  ($setuphandleshort)   Then $spmakeshortcut  = "yes"
	$setupdisableprm   = "yes"
	GUICtrlSetColor    ($setuphandleprompt,  $mymedgray)
	GUICtrlSetColor    ($setuphandlelabel,   $mymedgray)
	GUICtrlSetState    ($setuphandleshort,   $guishowdis)
	GUICtrlSetState    ($setuphandledrive,   $guishowdis)
	GUICtrlSetState    ($setuphandlelist,    $guihideit)
	GUICtrlSetState    ($setupbuttoncancel , $guihideit)
	GUICtrlSetState    ($setupbuttonconfirm, $guihideit)
	GUICtrlSetState    ($setupbuttoninstall, $guihideit)
	GUICtrlSetState    ($setuphandleefimsg,  $guihideit)
	$setuphandlelist   = CommonScaleCreate ("List", "", 12, 35, 45, 38, $WS_HSCROLL + $WS_VSCROLL)
    SetupCopyPrep ()
	If CommonParms ($parmcodeonly) Then
		SetupCodeOnly  ()
	Else
		SetupCopyFiles ($spmakeshortcut)
	EndIf
	GUICtrlSetState    ($setupbuttonclose, $guishowit + $GUI_FOCUS)
EndFunc

Func SetupBootEFI ()
	CommonSetHeaders  ()
	EFIMain           ("Install", $setuphandlegui, $parmsetup)
EndFunc

Func SetupBootBIOS ()
	CommonWriteLog ()
	CommonWriteLog ("Starting the " & $systemmode & " boot code installation.")
	$sbbrc = ""
	If $bootos = $xpstring Then
		XPSetup       ()
		XPGetPrevious ()
		$sbbrc = XPUpdate     (30)
	Else
		;BCDGetPreviousBIOS ()
		$sbbrc = BCDSetupBIOS (30)
	EndIf
	If $sbbrc <> 0 Then SetupError ("** The BIOS boot code installation failed **", $sbbrc)
    CommonWriteLog ("The " & $systemmode & " boot code installation is complete.")
EndFunc

Func SetupCheckErrors ($scconfstatus)
	$scmsg             = ""
	$forcecleaninstall = ""
	$scwarncolor       = $myyellow
	$setupolddir       = $basictargetdrive & "\grub2.old"
	$scfullrel         = $basrelcurr & " build " & $basrelbuild
	$sctitle           = "Setup Grub2Win version " & $scfullrel
	$setuphelploc      = "The Grub2Win Setup Screen"
	GUICtrlSetState ($setupbuttonconfirm, $guihideit)
	Select
		Case $encryptionstatus Or CommonParms ($parmadvanced)
			If $encryptionstatus Then
				$scmsg  = @CR & @CR & 'Drive ' & $basictargetdrive & ' is encrypted with BitLocker.' & @CR & @CR
				$scmsg &= 'Grub2Win cannot be installed to an encrypted partition.'                  & @CR & @CR
				$scmsg &= 'Please click the blue  Help  button above and refer to the'               & @CR
			    $scmsg &= '"Encrypted Disk Workaround"  topic for more information.'
			    $setuphelploc = "Encrypted Disk Workaround"
			EndIf
		Case $setupmbrequired > DriveSpaceFree ($basictargetdrive)
			$scmsg  = @CR & @CR & "There is not enough free space" & @CR & @CR
			$scmsg &= "on drive " & $basictargetdrive & @CR & @CR & $setupmbrequired & " MB is required."
		Case StringLeft (@ScriptDir, 9) = $setuptargetdir & "\"
			$scmsg  = @CR & @CR & "The setup program cannot be run" & @CR
			$scmsg &= "from the target directory." & @CR & @CR & $setuptargetdir
		Case CommonParms ($parmcodeonly) And Not FileExists ($setuptargetdir)
			$scmsg  = @CR & @CR & "*** CodeOnly Error ***"                     & @CR & @CR & @CR
			$scmsg &= 'When the "CodeOnly" parameter is used'                  & @CR
            $scmsg &= 'there must be a \grub2 directory present on the drive.' & @CR & @CR & @CR
            $scmsg &= $setuptargetdir & '  was not found.'
		Case FileExists ($setuptargetdir)
			$progexistinfo = BaseFuncGetVersion ($setuptargetdir & "\" & $exestring, $progexistversion)
			                 TimeGetInfo        ($progexistinfo)
			$scexistbuild  = $progexistinfo [$iBuild]
			$sctitle = "Upgrade Grub2Win version " & $progexistversion & " to " & $scfullrel
			If $progexistversion = $basrelcurr Then
				$sctitle = "Refresh Grub2Win version " & $progexistversion & " to build " & $basrelbuild
				If $basrelbuild = $scexistbuild Then $sctitle = StringReplace ($sctitle, "to ", "")
			EndIf
			If StringReplace ($progexistversion, ".", "") < $oldreleasecutoff And $progexistversion <> "0.0.0.0" Then
				$forcecleaninstall = "yes"
				$scwarncolor       = $myorange
				$setupolddir       = $basictargetdrive & "\grub2.archive"
				$sctitle = "** Clean install of Grub2Win " & $scfullrel & " **"
				$scmsgbody  = @CR & 'Your currently installed Grub2Win version'                       & @CR
				$scmsgbody &=  $progexistversion & '  is too old for upgrade.'                         & @CR & @CR
				$scmsgbody &= '** A clean install of Grub2Win must be performed. **'                  & @CR & @CR
				$scmsgbody &= 'Your  '& $setuptargetdir & '  will be renamed to  ' & $setupolddir     & @CR & @CR
				$scmsgbody &= 'A clean  ' & $setuptargetdir & '  directory will then be installed.'   & @CR & @CR & @CR
			ElseIf CommonParms ($parmcodeonly) Then
				$scmsgbody =  @CR & '***   CodeOnly Note   ***'                           & @CR & @CR
				$scmsgbody &= 'The GNU Grub libraries in directory ' & $setuptargetdir    & @CR
				$scmsgbody &= 'will be refreshed with the current code.'                  & @CR & @CR
				$scmsgbody &= 'The grub2win.exe application will be upgraded'             & @CR & @CR
				$scmsgbody &= 'Your current configurations, settings and themes'          & @CR
				$scmsgbody &= 'will remain unchanged.'                                    & @CR & @CR
			Else
				$scmsgbody =  @CR & '***   Note   ***' & @CR & @CR
				$scmsgbody &= 'There is already a ' & $setuptargetdir & ' directory'  & @CR
				$scmsgbody &= 'on the drive you selected.'                            & @CR & @CR
				$scmsgbody &= 'Your current directory will be saved as ' & $setupolddir & @CR
				$scmsgbody &= 'Your settings and backup files will be migrated'       & @CR
				$scmsgbody &= 'to the new ' & $setuptargetdir & ' directory.'         & @CR & @CR & @CR
			EndIf
			If $scconfstatus = "Confirmed" Then
				$scmsg =  @CR & '***   Confirmed   ***' & @CR & @CR & $scmsgbody
				$scmsg &= 'The install of Grub2Win will now continue.'            & @CR
				GUICtrlSetState ($setupbuttoninstall, $guihideit)
			Else
				$scmsg  = $scmsgbody
				$scmsg &= 'Click the "Confirm" button below'                      & @CR
				$scmsg &= 'to continue the install.'
				GUICtrlSetState ($setupbuttonconfirm, $guishowit + $GUI_FOCUS)
			EndIf
	EndSelect
	If $parmsdisplay <> "" Then $sctitle &= "   P=" & $parmsdisplay
	If $scmsg = "" Then
		GUICtrlSetState ($setuphandlewarn,    $guihideit)
		GUICtrlSetState ($setupbuttonconfirm, $guihideit)
		GUICtrlSetState ($setupbuttoninstall, $guishowit)
		GUICtrlSetState ($setupbuttoninstall, $GUI_FOCUS)
	Else
		GUICtrlSetData    ($setuphandlewarn,    $scmsg)
		GUICtrlSetBKColor ($setuphandlewarn,    $scwarncolor)
		GUICtrlSetState   ($setuphandlewarn,    $guishowit)
		If Not CommonParms ($parmadvanced) Then GUICtrlSetState   ($setupbuttoninstall, $guihideit)
	EndIf
	WinSetTitle ($setuphandlegui, "", $sctitle)
EndFunc

Func SetupPrepare ($spdrive)
	$setupdownload = "no"
	If StringInStr (@ScriptDir, "Local\Temp") Then $setupdownload = "yes"
	$setuplogfile  = $setupmasterpath & $setuplogstring
	If $setupdownload = "yes" Then $setuplogfile = @ScriptDir & $setuplogstring
	FileDelete ($setuplogfile)
	CommonWriteLog        ("Start Setup - " & TimeLine ("", "", "yes"))
	If $parmlog <> "" Then CommonWriteLog ('** Command Line Parms are "' & $parmlog & '" **')
	SetupCheckDrive        ($spdrive)
	$efiforceload           = SettingsGet ($setefiforceload)
	CommonSetupSysLines ($basefifromrelease, "The setup ")
	$setupmbrequired  = Int ((DirGetSize ($setupmasterpath) / $mega) * 1.1)
EndFunc

Func SetupCheckDrive ($cddrive)
	If DriveStatus    ($cddrive & "\") <> "Ready" Then SetupError ("The Target Drive Is Not Ready " & $cddrive)
	$setuptargetdir   = $cddrive & "\grub2"
	If FileExists     ($shortcutfile) Or Not FileExists ($setuptargetdir) Or $setupvalueshort = "yes" Then GUICtrlSetState ($setuphandleshort, $GUI_CHECKED)
	If $setuptargetdir & "\" = $runpath Then
		MsgBox ($mbwarnok, "** Setup must not overwrite itself.  Run Cancelled **",  _
			@CR & @CR & "Source = " & @scriptdir & @CR & @CR & "Target  = " & $setuptargetdir)
		BaseFuncCleanupTemp ("SetupCheckDrive")
	EndIf
	UtilCheckEncryption  ($cddrive)
	$setuptempdir        = $cddrive & "\grub2.temp.rename.old"
	If $forcecleaninstall <> "" Then $setupolddir = $cddrive & "\grub2.archive"
	$setuptargetstore    = $setuptargetdir & "\windata\storage\settings.txt"
	SettingsLoad          ($setuptargetstore)
	$efileveldeployed    = SettingsGet  ($setefideployed)
	;_ArrayDisplay ($settingsarray, $cdtargetstor)
	If $basictargetdrive = $setuptargetdriveold Then Return
	$setuptargetdriveold = $basictargetdrive
EndFunc

Func SetupGetDrives ($gddefault = "")
	$gdstring         = ""
	CommonSearchDrives ($masterstring, $gddefault, $gdstring, "")
	$basictargetdrive = $masterdrive
	If $basictargetdrive = "" Then $basictargetdrive = $windowsdrive
	$gdmsgmulti        = "Select the target drive"
	If CommonStringCount ($gdstring, "|") = 1 Then
		$setuphandlelabel  = CommonScaleCreate ("Label", "",          17,   5, 38, 6, $SS_Center)
	Else
		$setuphandleprompt = CommonScaleCreate ("Label", $gdmsgmulti, 17, 3.0, 22, 6, $SS_RIGHT)
		$setuphandledrive  = CommonScaleCreate ("Combo", "",          40, 2.4,  6, 6)
		$setuphandlelabel  = CommonScaleCreate ("Label", "",          17, 7.5, 38, 6, $SS_Center)
		GUICtrlSetData ($setuphandledrive,  $gdstring, $masterdrive)
		GUICtrlSetFont ($setuphandledrive,  $fontsizemedium)
	EndIf
	SetupTargetMsg ()
	GUICtrlSetFont ($setuphandleprompt, $fontsizemedium)
EndFunc

Func SetupTargetMsg ()
	$tmmsg  = "Grub2Win will be installed to directory " & StringLeft ($basictargetdrive, 2) & "\grub2"
	$tmmsg &= @CR & "Partition Label = " & CommonGetLabel ($basictargetdrive)
	GUICtrlSetData ($setuphandlelabel, $tmmsg)
EndFunc

Func SetupCopyPrep ()
	TimeGetGenDate      ($todaydate)
	BCDGetBootArray     ()
	If CommonParms      ($parmautoinstall) Then CommonFlashStart ("Grub2Win AutoInstall", "Now Copying Files")
	CommonPathSet       ($setuptargetdir)
	CommonGetAllInfo    ($masterexe)
	$setupinprogress = "yes"
	If CommonParms ($parmautoinstall) Then CommonWriteLog ("** This is an Automatic install to " & $setuptargetdir & " **")
	CommonWriteLog ()
	CommonWriteLog ($langline1 & ".")
	If $langline2 <> "" Then CommonWriteLog ($langline2 & ".")
	If $langline3 <> "" Then CommonWriteLog ($langline3 & ".")
	If $langline4 <> "" Then CommonWriteLog ($langline4 & ".")
	CommonWriteLog ($syslineos & ".")
	If $syslinesecure   <> "" Then CommonWriteLog ($syslinesecure & ".")
	CommonWriteLog ($syslinepath, 1, "")
EndFunc

Func SetupCopyFiles ($scmakeshortcut = "")
	$cfbootmanexists = "no"
	SetupProcessCleanup ()
	If FileExists    ($bootmanpath)    Then $cfbootmanexists = "yes"
	If FileExists    ($setuptargetdir) Then SetupRenameCurr ()
	CommonWriteLog ()
	DirCreate ($setuptargetdir)
	CommonWriteLog  ("OK - The New Main Directory Was Created At " & $setuptargetdir & ".")
	If SetupCheckCompress ($setuptargetdir) Then CommonWriteLog ("OK - Compression turned off for setup")
	DirCreate ($fontpath)
	DirCreate ($backuppath)
	DirCreate ($storagepath)
	DirCreate ($updatedatapath)
	DirCreate ($partdumppath)
	DirCreate ($userbackgrounds)
	DirCreate ($userclockfaces)
	DirCreate ($usermiscfiles)
	DirCreate ($usericons)
	DirCreate ($userfonts)
	CommonSubdirCopy ("winhelp",    $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("winsource",  $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("themes",     $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("fonts",      $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("i386-pc",    $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("i386-efi",   $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("x86_64-efi", $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ("locale",     $setupmasterpath, $setuptargetdir)
	CommonSubdirCopy ($bootmandir,  $setupmasterpath, $setuptargetdir)
	$cfcfgarray = BaseFuncArrayRead ($setuptargetdir & "\winsource\template.basic." & $firmwaremode & ".cfg", "SetupCopyFiles")
	If $winefiuuid <> "" Then _ArrayInsert ($cfcfgarray, 26, "set grub2win_efiuuid=" & $winefiuuid)
	BaseFuncArrayWrite ($setuptargetdir & "\grub.cfg", $cfcfgarray, $FO_OVERWRITE, "", 0)
	FileCopy ($setuptargetdir & "\winsource\grubenv", $envfile, 1)
	If FileExists ($setupolddir & "\userfiles") Then DirCopy   ($setupolddir & "\userfiles", $userfiles, 1)
	CommonCopyUserFiles ()
	If FileExists ($setupolddir & "\userfiles") Then CommonWriteLog  ("OK - Previous User Files Were Migrated.")
	If Not FileExists ($setupolddir) Then $themecenterstart = 3.5
	ThemeStarterSetup   ()
	FileMove        ($setuptargetdir  & "\winsource\" & $exestring, $masterexe, 1)
	If FileExists   ($setuptargetdir  & "\setup.bat") Then FileDelete ($setuptargetdir & "\setup.bat")
	If FileExists   ($setupolddir) Then SetupCopyPrevConfig ()
	SettingsLoad    ($setuptargetstore)
	SettingsLoad    ($setupmasterpath & "\winsource\basic.settings.txt", "setup")
	$scdonatestatus  = SettingsGet  ($setdonatestatus)
	$scdonatedate    = SettingsGet  ($setdonatedate)
	$scdonatenew     = $scdonatedate
	If $scdonatenew = "no" Or (StringLeft ($scdonatenew, 7) <= $todayjul) Then _
		$scdonatenew = TimeFormatDate ($todayjul + 7, "", "", "juldatetime")
	If $scdonatestatus = "dontask" or $scdonatestatus = "paypal" Then $scdonatenew = $scdonatedate
	SettingsPut   ($setlatestsetup,       TimeFormatDate ($todayjul, "", "", "juldatetime"))
	SettingsPut   ($setwarnedfirmearly,   "")
	SettingsPut   ($setefidefaulttype,    "")
	SettingsPut   ($setwarnedclover,      "")
	SettingsPut   ($setstatusgeo,         "")
	SettingsPut   ($setdonatedate,        $scdonatenew)
	SettingsPut   ($setgnugrubversion,    $basgnugrubversion)
	If $firmwaremode = "EFI" Then
		$scpath  = $bcdorderarray [0] [$bPath]
		$scdesc  = $bcdorderarray [0] [$bItemTitle]
		If $scpath <> $efipathwindows And $scpath <> $efipathgrub Then
			SettingsPut ($setefioldpath, $scpath)
			SettingsPut ($setefiolddesc, $scdesc)
		EndIf
		SettingsPut ($setgnugrubprevinfo, "")
		SettingsPut ($setefideployed,     $efileveldeployed)
		BCDSetupEFI ("grub2win")
	EndIf
	SettingsWriteFile ($setuptargetstore)
	If CommonParms ($parmrefreshefi) Then $setuprefreshefi = "yes"
	If $bootos <> $xpstring Then UtilCreateSysInfo ()
	UpdateGetParms  ()
	If StringLeft ($gendatefull, 31) > StringLeft ($updatearray [$sUpLastCheck], 31) Then _
		$updatearray [$sUpLastCheck] = $gendatefull
	UpdateCalcDates ()
	$spnextremind     = TimeFormatDate ($todayjul + 5)
	$spearliestremind = $spnextremind
	If $updatearray [$sUpLastCheck] = "no" Then $updatearray [$sUpLastCheck] = TimeFormatDate ($todayjul)
	If $updatearray [$sUpLastCheckDays] < 26 Then _
		$spnextremind = TimeFormatDate ($gendatejul + $updatearray [$sUpToGoDays])
	If StringLeft ($spnextremind, 7) < StringLeft ($spearliestremind, 7) Then _
		$spnextremind = $spearliestremind
	UpdatePutParms ($spnextremind)
	$spshortmsg = CommonShortcut ($scmakeshortcut)
	CommonShortLink  ($winshortcut)
	CommonWriteLog   ()
	CommonWriteLog   ("OK - " & $spshortmsg)
	If Not CommonParms ($parmautoinstall) Then
		If $firmwaremode  =  "EFI" And $setuprefreshefi  =  "yes" Then SetupBootEFI  ()
		If $firmwaremode <>  "EFI"                                Then SetupBootBIOS ()
	EndIf
	If Not FileExists ($partlistfile) Then UtilPartitionReport ()
	SetupComplete       ()
EndFunc

Func SetupCodeOnly ()
	If FileExists ($setuptargetdir & ".old") Then
		$costamp = $setuptargetdir & ".old.archive." & StringRight (@YEAR, 2) & @MON & @MDAY & "." & @HOUR & @MIN
		CommonWriteLog ()
		CommonWriteLog ("Saving archive directory " & $costamp)
		DirMove ($setuptargetdir & ".old", $costamp, 1)
	EndIf
	;DirRemove ($setuptargetdir & ".old", 1)
	CommonWriteLog ()
	CommonWriteLog ("Creating backup directory " & $setuptargetdir & ".old")
	DirCopy   ($setuptargetdir, $setuptargetdir & ".old", 1)
	CommonWriteLog    ()
	CommonWriteLog    ("OK - Directory " & $setuptargetdir & " Was copied to " & $setuptargetdir & ".old.")
	CommonWriteLog    ()
	CommonSubdirCopy ("g2bootmgr",  $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("i386-efi",   $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("i386-pc",    $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("x86_64-efi", $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("locale",     $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("winhelp",    $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("winsource",  $setupmasterpath, $setuptargetdir, "yes")
	CommonSubdirCopy ("themes\common\colorsource",  $setupmasterpath, $setuptargetdir, "yes")
	SetupCustColor   ()
	CommonWriteLog    ()
	If $firmwaremode  =  "EFI" Then SetupBootEFI  ()
	If $firmwaremode <>  "EFI" Then SetupBootBIOS ()
	SetupComplete ()
EndFunc

Func SetupComplete ()
	FileMove            ($setuptargetdir & "\winsource\" & $exestring, $masterexe, 1)
	If FileExists       ($setuptargetdir & "\setup.bat") Then FileDelete ($setuptargetdir & "\setup.bat")
	SetupRegistry       ($setuptargetdir)
	BaseFuncUnmountWinEFI ()
	CommonStatsBuild    ("Setup", "", "")
	GUISetBkColor       ($mygreen, $setuphandlegui)
	CommonWriteLog ()
	CommonWriteLog ()
	CommonWriteLog ("The Grub2Win setup completed successfully!")
	CommonWriteLog ()
	If $setupvaluecleanupdir <> "" Then
		$cfdelmsg         = "Delete the setup files - No longer needed"
		GUICtrlSetPos     ($setuphandlerun, Int ($scalepcthorz * 5))
		$setuphandledel   = CommonScaleCreate ("Checkbox", $cfdelmsg, 34, 20, 29, 2.5, $BS_LEFT)
		GUICtrlSetState   ($setuphandledel, $GUI_CHECKED)
		GUICtrlSetBkColor ($setuphandledel, $myorange)
	EndIf
	_GUICtrlListBox_SetTopIndex ($setuphandlelist, _GUICtrlListBox_GetCount ($setuphandlelist) - 15)
	$setupstatus  = "complete"
	;MsgBox ($mbontop, "Setup Complete", $spmsg)
EndFunc

Func SetupRenameCurr ()
	DirRemove     ($setuptempdir, 1)
	If FileExists ($setupolddir) Then SetupMoveCheck ($setupolddir, $setuptempdir, "delete")
	SetupMoveCheck ($setuptargetdir, $setupolddir, "rename")
	DirRemove ($setuptempdir, 1)
	If $firmwaremode = "EFI" And $efileveldeployed <> $basefifromrelease Then
		$srcmsg = " is currently at EFI level " & $efileveldeployed
		If $efileveldeployed = $unknown Then $srcmsg = " - The Grub2Win EFI modules have not yet been installed."
		CommonWriteLog ("Drive " & $basictargetdrive & $srcmsg)
	EndIf
	CommonWriteLog ()
	CommonWriteLog ('OK - ' & $setuptargetdir & ' Was Renamed to ' & $setupolddir & '.')
	If $forcecleaninstall <> "" Then $setupolddir = ""
EndFunc

Func SetupMoveCheck ($mcolddir, $mcnewdir, $mcmsgtype)
	$mcprompt = $mbwarnretrycan
	For $mcretry = 1 To 3
		$mcrc = DirMove ($mcolddir, $mcnewdir)
		If $mcrc = 1 Then Return
		$mcmsg  = "The " & $mcmsgtype & " of " & $mcolddir & " failed." &                      @CR & @CR & @CR
		$mcmsg &= "Grub2Win must not be running during setup."                               & @CR & @CR
		$mcmsg &= "Make sure no files are open in " & $mcolddir & " or it's subdirectories." & @CR & @CR
		$mcmsg &= "Also check for open command line widows."
		If $mcretry = 3 Then
			$mcprompt = $mbwarnok
			$mcmsg = "The final attempt to " & $mcmsgtype & " " & $mcolddir & " failed."
        EndIf
		If Not CommonQuestion ($mcprompt, "Rename attempt " & $mcretry & " of 3 failed", $mcmsg) Then ExitLoop
	Next
	If $mcmsgtype = "rename" Then DirMove ($setuptempdir, $setupolddir)
	SetupError ('The ' & $mcmsgtype & ' of "' & $mcolddir & '" failed - Setup is cancelled')
EndFunc

Func SetupCopyPrevConfig ()
	$stmsg = "Upgrading version " & $progexistversion & " to version "
	If $progexistversion = $basrelcurr Then $stmsg = "Refreshing version "
	CommonWriteLog  ()
	CommonWriteLog  ("** " & $stmsg & $basrelcurr & " **")
	SetupReorgFiles ()
	DirCopy   ($setupolddir     & "\windata\storage",        $storagepath,           1)
	DirCopy   ($setupolddir     & "\windata\customconfigs",  $custconfigs,           1)
	DirCopy   ($setupolddir     & "\windata\updatedata",     $updatedatapath,        1)
	FileCopy  ($setupolddir     & "\grubenv",                $envfile,               1)
	FileCopy  ($setupolddir     & "\windata\partlist.txt",   $partlistfile,          1)
	DirCopy   ($setupolddir     & "\themes\options.local",   $themepath & "\options.local", 1)
	If FileExists ($setupolddir & "\themes\common\colorcustom") Then SetupCustColor ()
	FileCopy  ($setupolddir     & "\grub.cfg", $setuptargetdir & "\grub.cfg", 1)
	CommonWriteLog  ("OK - Previous Settings And Backups Were Migrated.")
EndFunc

Func SetupReorgFiles ()
	DirCopy   ($setupolddir     & "\windata\backups",        $backuppath,            1)
	DirCreate ($backupmain)
	DirCreate ($backupcustom)
	DirCreate ($backupbcds)
	DirCreate ($backuplogs)
EndFunc

Func SetupCustColor ()
	Local $cctext, $ccclock
	$cchandle = FileOpen ($setuptargetdir & "\themes\custom.options.txt")
	$ccdata   = FileRead ($cchandle)
	FileClose ($cchandle)
	$cctextloc  = StringInStr ($ccdata, "coltext   =")
	$ccclockloc = StringInStr ($ccdata, "colclock  =")
	If $cctextloc  > 0 Then $cctext  = StringMid ($ccdata, $cctextloc  + 12, 6)
	If $ccclockloc > 0 Then $ccclock = StringMid ($ccdata, $ccclockloc + 12, 6)
	If $cctext <> "" Then _
		ThemeCopyColor ("coltext",  $cctext,  $themepath & "\common\colorsource", $themepath & "\common\colorcustom")
	If $ccclock <> "" Then _
		ThemeCopyColor ("colclock", $ccclock, $themepath & "\common\colorsource", $themepath & "\common\colorcustom")
EndFunc

Func SetupCheckCompress ($ccdir)
	If Not StringInStr (FileGetAttrib ($ccdir), "C") Then Return 0
	$ccstring   = "compact /u /q /s:" & $ccdir
	$ccoutpath  = $commandtemppath & "\compressoff.output.txt"
	$ccrc       = ""
	BaseFuncShellWait ($ccstring, $ccoutpath, $ccrc, "SetupCheckCompress")
	Return 1
EndFunc

Func SetupRegistry ($srtargetdir = $masterpath)
	$srmajversion = StringLeft      ($basrelcurr, 1)
    $srminversion = StringReplace   (StringTrimLeft ($basrelcurr, 2), ".", "")
    $srestsize    = DirGetSize      ($setupmasterpath)
	$srestsize    = Int             ($srestsize / $kilo) + $kilo
	$srcurrsize   = DirGetSize      ($srtargetdir)
	$srcurrsize   = Int             ($srcurrsize / $kilo) + $kilo
	$srlickey     = RegRead         ($reguninstall, "LicenseKey")
	If @error Then $srlickey = ""
	RegDelete ($reguninstall)
	RegWrite  ($reguninstall)
    RegWrite  ($reguninstall, "DisplayName",     "REG_SZ",    "Grub2Win")
    RegWrite  ($reguninstall, "UninstallString", "REG_SZ",    $srtargetdir & "\grub2win.exe UnInstall")
    RegWrite  ($reguninstall, "Publisher",       "REG_SZ",    "Dave Pickens")
    RegWrite  ($reguninstall, "InstallLocation", "REG_SZ",    $srtargetdir)
    RegWrite  ($reguninstall, "VersionMajor",    "REG_DWORD", $srmajversion)
    RegWrite  ($reguninstall, "VersionMinor",    "REG_DWORD", $srminversion)
    RegWrite  ($reguninstall, "DisplayVersion",  "REG_SZ",    $basrelcurr)
    RegWrite  ($reguninstall, "DisplayIcon",     "REG_SZ",    $srtargetdir & "\grub2win.exe")
	RegWrite  ($reguninstall, "LicenseKey",      "REG_SZ",    $srlickey)
	RegWrite  ($reguninstall, "Auth",            "REG_SZ",    $todayjul)
    RegWrite  ($reguninstall, "EstimatedSize",   "REG_DWORD", $srestsize)
	RegWrite  ($reguninstall, "Size",            "REG_DWORD", $srcurrsize)
    RegWrite  ($reguninstall, "InstallDate",     "REG_SZ",    @YEAR & @MON & @MDAY)
EndFunc

Func SetupCheckExe ()
	$loadtime      = CommonGetInitTime ($starttimetick)
	$ceprefix      = 'The "setup.exe" module you are running from directory' & @CR & @CR
	$ceprefix     &= "    " & $setupvaluecleanupdir & @CR & @CR
	$cemessage     = ""
	$cedate        = ""
	If FileExists ($downloadjulian) Then
		$cedownjul = BaseFuncSingleRead ($downloadjulian)
		If $nyjulian - $cedownjul > $downloadexpdays Then
			$cedate    = TimeLine ($cedownjul, "", "", "", "")
			$cemessage = 'too old.        '    & $cedate
			$bypassmsg = "BypassOld          "
		EndIf
	Else
		$cemessage     = 'no longer valid.'
		$bypassmsg     = "BypassInvalid      "
	EndIf
	; $cemessage = 'Testing Testing.' & @CR                           ; Use for testing with bat setup & parms
	If $cemessage      = "" Then Return
	CommonFlashEnd    ("")
	$cemessage2        = 'You should delete it from your system.'
	SetupListModules  ($cedate)
	$ceprompt   = @CR & @CR & 'Click "OK" to load and continue with the newest setup module.' & @CR & @CR & @CR & _
							  'Or click "Cancel".'                                            & @CR & @CR       & _
							  'You will then be directed to the official'                     & @CR &             _
							  'official SourceForge Grub2Win download site.'                  & @CR & @CR
	$ceinfo     = StringReplace ($setupexeinfo, @TAB, " ")
	If StringStripWS  ($ceinfo, 8) <> "" Then $ceinfo = @CR & @CR & '      setup.exe' & $ceinfo
	$cerc = MsgBox ($mbwarnokcan, "** Invalid setup.exe **", $ceprefix & "is " & $cemessage & @CR & $cemessage2 & $ceinfo & @CR & $ceprompt)
	ProcessClose      ("setup.exe")
	ProcessWaitClose  ("setup.exe", 1)
	If FileExists     ($setupvaluecleanupdir & "\grub2win.zip")   Then FileDelete ($setupvaluecleanupdir & "\grub2win.zip")
	If FileExists     ($setupvaluecleanupdir & "\G2WInstall.exe") Then FileDelete ($setupvaluecleanupdir & "\G2WInstall.exe")
	If $cerc = $IDOK Then
		NetLog        ($bypassmsg & $cedate, "", $starttimetick, $FO_APPEND)
		Return
	EndIf
	$bypassmsg  =     ""
	ShellExecute      ($downloadurlvisit)
	$setuperror =     "* Setup Too Old"
	NetLog            ("Cancelled " & $cemessage, "", $starttimetick, $FO_APPEND)
	CommonStatsBuild  ("SetupTooOld", "")
	CommonStatsPut    ()
	BaseFuncCleanupTemp ("SetupCheckExe")
EndFunc

Func SetupListModules ($lmgendate)
	$lmspacer = @TAB & @TAB & @TAB & @TAB & @TAB
	$lmarray = _FileListToArray ($setupvaluecleanupdir, "*", 1)
	If @error Then $setupmodlist = $lmspacer & "* Empty *"
	$lmfullcount = Ubound ($lmarray)
	If $lmfullcount      > 20 Then $lmarray = _FileListToArray ($setupvaluecleanupdir, "*.exe", 1)
	If @error Then $setupmodlist = $lmspacer & "* Empty *"
	If Ubound ($lmarray) > 20 Then $lmarray = _FileListToArray ($setupvaluecleanupdir, "setup.exe", 1)
	If @error Then $setupmodlist = $lmspacer & "* Empty *"
	For $lmsub = 1 To Ubound ($lmarray) - 1
		$lmversion     = ""
		$lmbuild       = ""
		$lmgenwork     = ""
		$lmname        = $lmarray [$lmsub]
		$lmverarray    = BaseFuncGetVersion ($setupvaluecleanupdir & "\" & $lmname, $lmversion)
						 TimeGetInfo        ($lmverarray)
		$lmdate        = $lmverarray [$iDate]
		If StringLeft  ($lmverarray [$iStamp], 8) >= @YEAR & @MON & @MDAY Then $lmdate = "* Today *"
		If $lmname = "setup.exe" Then
			$lmdatework = "File Date  " & $lmdate
			If $lmgendate <> "" And $lmgendate <> $lmdate Then $lmgenwork  = "Gen  Date  " & $lmgendate
		Else
			$lmdatework = "Date       " & $lmdate
		EndIf
		$lmdate         = @CR & $lmspacer & @TAB & $lmdatework
		If $lmgenwork <> "" Then $lmdate &= @CR & $lmspacer & @TAB & $lmgenwork
		If $lmversion <> "" Then            $lmversion = "Version    " & $lmversion
		If $lmverarray [$iBuild] <> "" Then $lmbuild   = "  Build " & $lmverarray [$iBuild]
	    $lmattrib      = @CR & $lmspacer & @TAB &        "Attrib     " & FileGetAttrib  ($setupvaluecleanupdir & "\" & $lmname)
		If @error Or StringStripWS ($lmattrib, 8) = "AttribA" Then $lmattrib = ""
		$lmstring      = @CR & $lmspacer & $lmname & $lmattrib & $lmversion & $lmbuild & $lmdate & @CR
		If StringRight ($lmname, 4) = ".exe" Then
			$setupexeinfo = @CR & $lmspacer & @TAB & $lmversion & $lmbuild & $lmdate
			$setupmodlist = @CR & $lmspacer & $lmname & $lmattrib & @CR & @TAB & $lmspacer & _
				$lmversion & $lmbuild & $lmdate & @CR & $setupmodlist
			ContinueLoop
		EndIf
		$setupmodlist &= $lmstring
	Next
	$setupmodlist &= @CR & $lmspacer & @TAB & "** Full Module Count = " & $lmfullcount - 1 & " **"
EndFunc

Func SetupProcessCleanup ()
	$pcarray = ProcessList ("grub2win.exe")
	If @error Then Return
	$pclimit = Ubound ($pcarray) - 1
	If $pclimit = 0 Then Return
	For $pcsub = 1 To $pclimit
		If $pcarray [$pcsub] [1] = @AutoItPID Then ContinueLoop
		ProcessClose     ($pcarray [$pcsub] [0])
		ProcessWaitClose ($pcarray [$pcsub] [0], 5)
	Next
EndFunc

Func SetupError ($semsg, $serc = "")
	$semsg = $semsg & @CR & @CR & "An error has occurred.    "
	If $serc <> "" Then $semsg &= "The return code is " & $serc & @CR & @CR
	$semsg &= "Grub2Win setup is cancelled"
	CommonWriteLog ($semsg)
	MsgBox ($mberrorok, "*** Grub2Win Setup Error ***", $semsg, 120)
	CommonSetupCloseOut ()
	BaseFuncCleanupTemp    ("SetupError")
EndFunc