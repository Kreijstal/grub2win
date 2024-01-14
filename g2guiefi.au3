#RequireAdmin
#include-once
#include  <g2common.au3>

Func EFIMain ($emruntype, $emguihandle, $emcaller, $emcontinuous = "")

	EFIPrepare        ($emguihandle, $emcaller)

	EFIAssignAll      ()

	If $efierrorsfound = "yes" Then
		EFICloseOut ($emruntype, $emguihandle, $emcaller)
		Return
	EndIf

	While 1
		If EFIDisplay     ($emruntype, $emcaller) Then ExitLoop
		If EFIUpdateParts ($emruntype)            Then ExitLoop
		If $emcontinuous  = ""                    Then ExitLoop
		CommonFlashStart   ("Your EFI Action Has Completed", "Waiting For Your Next Input", 2000)
		CommonFlashEnd     ("")
	Wend

	EFIReleaseDisk ()

	EFICloseOut       ($emruntype, $emguihandle, $emcaller)
EndFunc

Func EFIPrepare ($epcallhandle = "", $epcaller = "")
	If $handlemaingui <> "" Then GUISetState (@SW_MINIMIZE, $handlemaingui)
	CommonWriteLog   ()
	CommonWriteLog   ("    EFI Update Starts at " & @HOUR & ":" & @MIN & ":" & @SEC)
	$efimilsec         = TimeTickInit ()
	$utillogfilehandle = FileOpen  ($utillogfile, 2)
	UtilScanDisks ("EFI Update", $epcallhandle, $epcaller)
	If $partcountefi = 0 Then
	  $epmsg  = "No EFI System partitions were found!" & @CR & @CR
	  $epmsg &= "Would you like to see more information on EFI partitions?"
	  $eprc   = MsgBox ($mbwarnyesno, "** EFI Error **", $epmsg)
	  If $eprc = $IDYES Then CommonHelp ("EFI Partition Info and Tips")
	  UtilProcessError ("No EFI System partitions were found!", "Run Aborted")
	  $efierrorsfound   = "yes"
	  Return
	EndIf
	$efierrorsfound   = ""
	$eficancelled     = ""
	UtilDiskWriteLog ("")
	UtilDiskWriteLog ("Starting EFI Update on " & TimeLine ("", "", "yes"))
	UtilDiskWriteLog ()
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	;_ArrayDisplay ($partitionarray)
EndFunc

Func EFIAssignAll ()
	$eaapartcount = 0
	CommonEFIMountWin ()
	CommonDataBase        ()
	$efiutilmsg  = "*** Using Diskpart For Letter Assignment ***"
	For $eaasub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$eaasub] [$pEFIFlag] = "" Then ContinueLoop
		$eaadiskno     = $partitionarray [$eaasub] [$pDiskNumber]
		$eaapartno     = $partitionarray [$eaasub] [$pPartNumber]
		$eaaletter     = $partitionarray [$eaasub] [$pDriveLetter]
		$eaamediadesc  = $partitionarray [$eaasub] [$pDriveMediaDesc]
		$eaadrivestyle = $partitionarray [$eaasub] [$pDriveStyle]
		If $partitionarray [$eaasub] [$pEFIFlag] = $efiignoremedia Then
			EFIPartSkip ($eaasub, $eaadiskno, $eaapartno, "Letter = " & $eaaletter,             _
				"is on a flash drive",                                     _
				"Microsoft requires EFI partitions to be on fixed drives")
            ContinueLoop
		EndIf
		If $partitionarray [$eaasub] [$pEFIFlag] = $efiignorefs Then
			EFIPartSkip ($eaasub, $eaadiskno, $eaapartno, "Letter = " & $eaaletter,             _
				"is incorrectly formatted as  " & $partitionarray [$eaasub] [$pPartFileSystem], _
				"EFI partitions must be formated as FAT32, FAT16 or FAT12")
            ContinueLoop
		EndIf
		$eaapartcount += 1
        If $partitionarray [$eaasub] [$pEFIFlag] = $efiignorelimit Then
			EFIPartSkip ($eaasub, $eaadiskno, $eaapartno, "",                                   _
				"Too Many EFI Partitions. Found = " & $eaapartcount & "  Max Allowed = 5",      _
				"** Warning - Multiple EFI partitions may cause severe boot problems **")
			ContinueLoop
		EndIf
		If $eaaletter <> "" And $eaaletter <> $winefiletter And $eaadrivestyle <> "MBR" Then
			UtilDiskWriteLog ()
			UtilDiskWriteLog (_StringRepeat ("_", 105))
	   		UtilDiskWriteLog ("|    Releasing EFI Drive Letter " & $eaaletter & " From Disk " & $eaadiskno & "  Partition " & $eaapartno)
			EFISetPartLetter ($eaadiskno, $eaapartno, $eaaletter, "release", $eaasub)
		EndIf
		If ($eaaletter <> $winefiletter Or $winefiletter = "") And $eaadrivestyle <> "MBR" Then $eaaletter = CommonDriveLetter ($partitionarray)
		For $eaatrymount = 0 To 10
			If $eaadrivestyle <> "MBR" Then EFISetPartLetter ($eaadiskno, $eaapartno, $eaaletter, "assign", $eaasub)
			Sleep ($eaatrymount * 200)
			If DriveStatus ($eaaletter & "\") = "READY" Then ExitLoop
		Next
		UtilDiskWriteLog (_StringRepeat ("_", 105))
	    UtilDiskWriteLog ()
		If DriveStatus ($eaaletter & "\") <> "READY" Then
			EFIPartSkip ($eaasub, $eaadiskno, $eaapartno,                  _
				"", "Microsoft DiskPart Utility letter assignment failed")
			ContinueLoop
		EndIf
		If Not FileExists ($eaaletter & "\efi") Then
			DirCreate     ($eaaletter & "\EFI")
			CommonWriteLog   ("    ** Missing /EFI directory was created on drive " & $eaaletter & " **" & @CR)
		EndIf
		If Not FileExists ($eaaletter & "\clover") Then $partitionarray [$eaasub] [$pCloverLevel] = $unknown
		UtilDiskWriteLog ("Found An EFI Partition On " & $eaamediadesc & "  " & $eaadiskno & "  Partition " & _
			$eaapartno & "  -   Using Letter " & $eaaletter)
		If $eaaletter = $winefiletter Then UtilDiskWriteLog ("** This Is The Windows EFI Partition **")
		UtilDiskWriteLog ()
		EFIListStats  ($eaadiskno, $eaapartno, $eaaletter, $eaasub, $eaamediadesc)
	Next
	If $eaapartcount < 1 Then
		$eaamsg = "No Valid EFI Partitions Were Found"
		$efierrorsfound = "yes"
		MsgBox ($mbwarnok, "** EFI Error **", $eaamsg)
		CommonWriteLog    ($eaamsg)
		UtilDiskWriteLog ($eaamsg)
		CommonEndIt      ("Failed")
	EndIf
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
EndFunc

Func EFIPartSkip ($pssub, $psdiskno, $pspartno, $pspartletter, $psmessage1, $psmessage2 = "")
	$partitionarray [$pssub] [$pEFIFlag] = ""
	UtilDiskWriteLog  ()
	$psmessagedisk    = "Disk " & $psdiskno & "  Partition " & $pspartno & " " & $pspartletter & "   " & $psmessage1
	UtilDiskWriteLog  ("    **  " & $psmessagedisk)
	If $psmessage2    <> "" Then UtilDiskWriteLog  ("    **  " & $psmessage2)
	$psmessageskip    = "This EFI partition will be ignored"
	UtilDiskWriteLog  ("    **  " & $psmessageskip)
	UtilDiskWriteLog  ()
	If $runtype = $parmsetup Then Return
    MsgBox ($mbwarnok, "** EFI Partition Warning **", $psmessagedisk & @CR & @CR & $psmessage2 & @CR & @CR & $psmessageskip)
EndFunc

Func EFIDisplay ($edruntype, $edcaller)
	If $edruntype = $actionuninstall Or $edcaller = $parmsetup Or $edcaller = $firmwarestring Or $efidefaultfix = $IDYES Then Return
	If $efierrorsfound = "yes" Then Return
	$edheadervert     = 9.5
	$edvert           = 13
	$edbump           = 15
	$edpartcount      = $partcountefi
	If $partcountefi  + 5 Then $edpartcount = 5
	$efileveldeployed = ""
	BaseFuncGuiDelete ($eficonfguihandle)
	$eficonfguihandle = CommonScaleCreate ("GUI", "Grub2Win EFI Update Actions - New Level " & _
		$basefifromrelease, -1, -1, 80, 29 + $edpartcount * $edbump, -1, "", $utillogguihandle)
	$edstringall  = $actionrefresh & "|" & $actiondelete
	$edstringnew  = $actioninstall
	$edhelphandle = CommonScaleCreate ("Button", "Help",                      63, 2.4, 9.4, 4)
	GUICtrlSetBkColor ($edhelphandle, $mymedblue)
	CommonScaleCreate ("Label", "Disk",         14, $edheadervert,  7, 2.4)
	CommonScaleCreate ("Label", "Partition",    24, $edheadervert,  7, 2.4)
	CommonScaleCreate ("Label", "Drive Letter", 35, $edheadervert, 18, 2.4)
	CommonScaleCreate ("Label", "Action",       56, $edheadervert,  7, 2.4)
	For $edsub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$edsub] [$pEFIFlag] <> $efivalid Then ContinueLoop
		$edstring  = $edstringnew
		$eddefault = $actionno
		$edlevel   = $partitionarray [$edsub] [$pEFILevel]
		If $edlevel > $efileveldeployed And $edlevel <> $unknown Then $efileveldeployed = $edlevel
		EFIPartInfo ($edsub)
		If $partitionarray [$edsub] [$pGrubFound] = $foundstring Then
			$edstring  = $edstringall
		EndIf
		If $cloverfound = "yes" Then $edstring &= "|" & $actioncloverrefr
		$edstring &= "|" & $actionbackup & "|" & $actionrestore & "|" & $actionno
		$partitionarray [$edsub] [$pBrowseHandle] = CommonScaleCreate ("Button", "Browse", 4, $edvert - 0.6, 8, 3.5)
		GUICtrlSetBkColor ($partitionarray [$edsub] [$pBrowseHandle], $mymedblue)
		CommonScaleCreate ("Label", $partitionarray [$edsub] [$pDiskNumber],     15, $edvert,      3, 3)
		CommonScaleCreate ("Label", $partitionarray [$edsub] [$pPartNumber],     26, $edvert,      3, 3)
		CommonScaleCreate ("Label", $partitionarray [$edsub] [$pDriveLetter],    38, $edvert,      3, 3)
		CommonScaleCreate ("Label", $partitionarray [$edsub] [$pPartInfo],       10, $edvert + 4, 72, 3)
		If $partitionarray [$edsub] [$pDriveLetter] = $winefiletter Then _
		    CommonScaleCreate ("Label", "** This Is The Windows EFI Partition **", 25, $edvert + 6, 25, 3)
		CommonScaleCreate ("Label", _StringRepeat ("_", 120),                   0, $edvert + 8, 90, 3)
		$partitionarray [$edsub] [$pConfirmHandle] = CommonScaleCreate ("Combo", "", 47, $edvert - 0.4, 24, 3)
		If $partitionarray [$edsub] [$pAction] = $actionskip Then
			$edstring  = $actionskip
			$eddefault = $actionskip
		EndIf
		GuiCtrlSetData         ($partitionarray [$edsub] [$pConfirmHandle], $edstring, $eddefault)
		$partitionarray [$edsub] [$pAction] = $eddefault
		$edvert += $edbump
	Next
	If $efileveldeployed = "" Then $efileveldeployed = $unknown
	SettingsPut ($setefideployed, $efileveldeployed)
	$edtxtaction = 'Please click the "Browse" button or select an action above'
	$edtxtletter = 'Note: Drive letters are temporarily assigned and will be released when you close this window'
	$edaction = CommonScaleCreate ("Label",  $edtxtaction,      0,  $edvert +  1, 76,  3, $SS_CENTER)
	            CommonScaleCreate ("Label",  $edtxtletter,      0,  $edvert +  4, 76,  3, $SS_CENTER)
	$edcancel = CommonScaleCreate ("Button", "Close",           3,  $edvert + 10, 15,  4)
	$edaccept = CommonScaleCreate ("Button", "Apply Actions",  58,  $edvert + 10, 15,  4)
	GUICtrlSetState ($edaccept, $GUI_FOCUS)
	GUISetBkColor   ($mypurple,$eficonfguihandle)
	GUISetState     (@SW_SHOW, $eficonfguihandle)
	UtilDiskWriteLog (_StringRepeat ("_", 105))
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Ready For Update   -    Waiting For EFI Update Actions")
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	While 1
        $edmsg = GUIGetMsg()
		$edstatus = "no"
		$edchange = "no"
		For $edsub = 0 To Ubound ($partitionarray) - 1
			If $partitionarray [$edsub] [$pEFIFlag] <> $efivalid Then ContinueLoop
			If $edmsg = $partitionarray [$edsub] [$pBrowseHandle] Then EFIBrowse ($edsub)
			If $edmsg = $partitionarray [$edsub] [$pConfirmHandle] Then
				$partitionarray [$edsub] [$pAction] = StringStripWS (GUICtrlRead ($partitionarray [$edsub] [$pConfirmHandle]), 3)
				$edchange = "yes"
			EndIf
			If $partitionarray [$edsub] [$pAction] <> $actionno Then $edstatus = "yes"
		Next
		If $edstatus = "yes" Then
			If $edchange = "yes" Then
				GUICtrlSetState ($edaction, $guihideit)
				GUICtrlSetState ($edaccept, $guishowit)
				GUICtrlSetState ($edaccept, $GUI_FOCUS)
			EndIf
		Else
			GUICtrlSetState ($edaccept,	$guihideit)
		EndIf
		Select
			Case $edmsg = ""
			Case $edmsg = $GUI_EVENT_CLOSE Or $edmsg = $edcancel
				BaseFuncGuiDelete ($eficonfguihandle)
				Return "Closed"
			Case $edmsg = $edhelphandle
				CommonHelp ("EFI Update Actions")
			Case $edmsg = $edaccept
				ExitLoop
		EndSelect
    WEnd
EndFunc

Func EFIUpdateParts ($upruntype)
	GUISetState (@SW_RESTORE, $utillogguihandle)
	$upmsg1 = "Updating Your EFI Partition"
	If $partcountefi > 1 Then $upmsg1 &= "s"
	If $efierrorsfound = "yes" Then Return
	BaseFuncGuiDelete  ($eficonfguihandle)
	;_ArrayDisplay ($partitionarray)
	For $upsub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$upsub] [$pEFIFlag] <> $efivalid Then ContinueLoop
		$updiskno = $partitionarray [$upsub] [$pDiskNumber]
		$uppartno = $partitionarray [$upsub] [$pPartNumber]
		$upletter = $partitionarray [$upsub] [$pDriveLetter]
		$upaction = $partitionarray [$upsub] [$pAction]
		$updesc   = $partitionarray [$upsub] [$pDriveMediaDesc]
		If $upruntype = $actionuninstall Then $upaction = $actiondelete
		If $upaction  = ""               Then $upaction = $actioninstall
		If $eficancelled = "" And $upaction <> $actionno Then BackupMake ("")
        Select
			Case $eficancelled <> ""
			Case $upruntype   = $runpartops And ($upaction = $actionno Or $upaction = $actionskip)
			Case $upaction    = $actionbackup
				BackupEFI        ($updiskno, $uppartno, $upletter)
			Case $upaction    = $actionrestore
				RestoreEFI       ($updiskno, $uppartno, $upletter)
			Case $upaction    = $actioncloverrefr
				If EFICloverGet ($upaction) <> "OK" Then ContinueLoop
				EFIUpdateClover ($updiskno, $uppartno, $upletter, $upaction, $upsub)
			Case Else
				If EFIUpdateFiles ($updiskno, $uppartno, $upletter, $upaction, $upsub) Then
					$efierrorsfound = "yes"
					Return "Error"
				EndIf
				EFIForceCheck ($updiskno, $uppartno, $upletter, $upaction, $updesc)
		EndSelect
		Sleep (1000)
		UtilDiskWriteLog ()
	Next
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
EndFunc

Func EFIReleaseDisk ()
	For $rdsub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$rdsub] [$pEFIFlag] <> $efivalid Or $partitionarray [$rdsub] [$pDriveStyle] = "MBR" Then ContinueLoop
		$rddiskno = $partitionarray [$rdsub] [$pDiskNumber]
		$rdpartno = $partitionarray [$rdsub] [$pPartNumber]
		$rdletter = $partitionarray [$rdsub] [$pDriveLetter]
		$rddesc   = $partitionarray [$rdsub] [$pDriveMediaDesc]
		If $rdletter = $winefiletter Then ContinueLoop
		UtilDiskWriteLog ("Releasing Drive Letter " & $rdletter & " From " & _
				$rddesc & " " & $rddiskno & "  Partition " & $rdpartno)
		EFISetPartLetter ($rddiskno, $rdpartno, $rdletter, "release", $rdsub)
	Next
EndFunc

Func EFIUpdateFiles ($ufdiskno, $ufpartno, $ufletter, $ufaction, $ufsub)
	$uflvldesc = $partitionarray [$ufsub] [$pDriveMediaDesc]
	$ufdest    = $uflvldesc & " " & $ufdiskno & "    Partition " & $ufpartno & "    Letter " & $ufletter
	$uflvldel  = " Level " & $partitionarray [$ufsub] [$pEFILevel] & "  "
	$uflvladd  = " Level " & $basefifromrelease & "  "
	$uflvllog  = $uflvladd
	$ufinstmsg1 = "Installing The GNU Grub EFI" & $uflvladd & "Modules "
    $ufinstmsg2 = "To " & $ufdest
	If $ufaction = $actionrefresh Then
		$ufinstmsg1 = "Refreshing The GNU Grub EFI Modules On " & $ufdest & " "
		$ufinstmsg2 = "To" & $uflvladd
	EndIf
	If $ufaction = $actiondelete  Then
		$ufinstmsg1 = "Deleting   The GNU Grub EFI Modules From "
		$ufinstmsg2 = $ufdest
		$uflvllog   = $uflvldel
		$partitionarray [$ufsub] [$pGrubFound] = ""
		$efideleted = "yes"
		SettingsPut ($setefideployed,  "")
		SettingsPut ($setefiforceload, "")
		BCDCleanup  ()
	EndIf
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($ufinstmsg1 & $ufinstmsg2)
	CommonWriteLog    ("    " &      $ufinstmsg1)
	CommonWriteLog    ("        " &  $ufinstmsg2)
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	$uftargetpath = $ufletter & $efibootmanstring
	If EFIFreespace ($ufdiskno, $ufpartno, $ufletter, $bootmanpath, "grub2win", "GNU Grub EFI Modules") <> "" Then Return "NoSpace"
	If FileExists ($uftargetpath) Then
		If DirRemove ($uftargetpath, 1) <> 1 Then
			UtilProcessError ("Directory delete failed " & $uftargetpath & " - Run Cancelled")
			Return "DeleteFailed"
		EndIf
	EndIf
	$grubcfgefilevel = ""
	$partitionarray [$ufsub] [$pEFILevel] = $unknown
	SettingsPut   ($setefideployed, "")
	If $ufaction = $actiondelete Then
		DirRemove ($ufletter & $efitargetstring, 1)
		SettingsWriteFile ($settingspath)
		Return
	EndIf
	$grubcfgefilevel = $basefifromrelease
	GUICtrlSetBkColor ($buttonrunefi, $mymedblue)
	If Not FileExists ($uftargetpath) Then DirCreate ($uftargetpath)
	DirRemove ($ufletter & $efitargetstring, 1)
	If DirCopy ($bootmanpath, $uftargetpath, 1) <> 1 Then
		UtilProcessError ("Boot Manager directory copy failed " & $uftargetpath & " - Run Cancelled")
		Return "CopyFailed"
	EndIf
	SettingsPut       ($setefionpartition, $basefifromrelease)
	SettingsPut       ($setefideployed,    $basefifromrelease)
	SettingsSinglePut ($ufletter & $setefilvlstring, $setefionpartition, $basefifromrelease)
	SettingsWriteFile ($settingspath)
	If $firmwaremode <> "EFI" Then Return
	$bcefimessage = "Setting up Grub2Win to run with " & $osbits & " bit EFI firmware"
	UtilDiskWriteLog ()
	UtilDiskWriteLog (         $bcefimessage)
	CommonWriteLog    ("    " & $bcefimessage)
	BCDSetupEFI      ("grub2win")
	$partitionarray [$ufsub] [$pGrubFound] = $foundstring
	$partitionarray [$ufsub] [$pEFILevel]  = $basefifromrelease
EndFunc

Func EFIForceCheck ($fcdiskno, $fcpartno, $fcletter, $fcaction, $fcdesc)
	$fcstatus     = SettingsGet ($setefiforceload)
	$fcmasterfile = $fcletter & $efimasterstring
	$fcbootdir    = $fcletter & $efibootdir
	$fcbackupdir  = $fcletter & $efibootstring & "boot.backup"
	$fcmodule     = $fcletter & "\efi\grub2win\g2bootmgr\" & $bootmanefi
	Select
		Case $fcstatus = "no" Or $fcaction = $actiondelete
			If FileExists ($fcbackupdir) Then
				DirRemove ($fcbootdir, 1)
				DirMove   ($fcbackupdir, $fcbootdir, 1)
			EndIf
			$fcmsg1    = "Setting up EFI to use normal boot order"
			$fcmsg2    = " on " & $fcdesc & " " & $fcdiskno & "  Partition " & $fcpartno
		Case $fcstatus = "yes"
			If Not FileExists ($fcbackupdir) Then DirMove ($fcbootdir, $fcbackupdir, 1)
			DirRemove ($fcbootdir, 1)
			DirCreate ($fcbootdir)
			FileCopy  ($fcmodule, $fcmasterfile, 1)
			$fcmsg1    = "Setting up EFI to force Grub2Win load"
			$fcmsg2    = " on " & $fcdesc & " " & $fcdiskno & "  Partition " & $fcpartno
		Case Else
			Return
	EndSelect
	CommonWriteLog   ("    " & $fcmsg1)
	UtilDiskWriteLog (         $fcmsg1 & @CR & $fcmsg2)
EndFunc

Func EFICheckClover ()
	If $firmwaremode <> "EFI" Or $partcountefi < 1 Or $osbits = 32 Then Return
	$ccoldrel = SettingsGet ($setcloverdeployed)
	Select
		Case SettingsGet ($setwarnedclover)    <> $setno
			Return
		Case $cloverfound = "yes" And $ccoldrel = $unknown
			$ccaction = $actioncloverinst
			$ccreason = "You Added Clover To Your Boot Menu"
			$ccmsg    = "Clover Was Downloaded And Will Be Installed To Your EFI Partition"
			$ccask    = "Install"
		Case $cloverfound = "yes" And $ccoldrel <> $bascloverfromrelease
			$ccaction = $actioncloverrefr
			$ccreason = "Clover Was Updated From Level " & $ccoldrel & " To Level " & $bascloverfromrelease
			$ccmsg    = "The New Clover Level Was Downloaded"
			$ccask    = "Refresh"
		Case $cloverfound = ""    And $ccoldrel <> $unknown
			$ccaction =  $actioncloverdel
			$ccreason = "You Removed Clover From Your Boot menu"
			$ccmsg    = "Clover Will Be Uninstalled From Your EFI Partition"
			$ccask    = "Uninstall"
		Case Else
			Return
	EndSelect
	If Not CommonQuestion ($mbquestyesno, "", $ccreason, "Do You Want To " & $ccask & " The Clover EFI Modules?") Then
		SettingsPut ($setwarnedclover, TimeFormatDate ($todayjul, "", "", "juldatetime"))
		Return
	EndIf
	If EFICloverGet ($ccaction) <> "OK" Then
		If $ccaction = $actioncloverrefr Then $cloverload = "Warn"
		Return
	EndIf
	CommonFlashStart ($ccmsg, "", 3000)
	EFIPrepare      ($handlemaingui, "Main")
	CommonFlashEnd   ("")
	EFIAssignAll     ()
	For $ccsub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$ccsub] [$pEFIFlag] = "" Then ContinueLoop
		$ccdiskno = $partitionarray [$ccsub] [$pDiskNumber]
		$ccpartno = $partitionarray [$ccsub] [$pPartNumber]
		$ccletter = $partitionarray [$ccsub] [$pDriveLetter]
		$ccdesc   = $partitionarray [$ccsub] [$pDriveMediaDesc]
		UtilDiskWriteLog  ()
		UtilDiskWriteLog  ("Updating the Clover EFI files")
		UtilDiskWriteLog  ()
		UtilDiskWriteLog  ("EFI  " & $ccdesc & " " & $ccdiskno & "  Partition " & $ccpartno & "   Drive Letter " & $ccletter)
		EFIUpdateClover   ($ccdiskno, $ccpartno, $ccletter, $ccaction, $ccsub)
	Next
	UtilDiskWriteLog ()
	CommonWriteLog   ("    " & $ccmsg, Default, "yes")
	CommonWriteLog   ("    Clover EFI update is complete", Default, "yes")
	UtilDiskWriteLog ("Clover EFI update is complete")
	UtilDiskWriteLog ()
	EFIReleaseDisk   ()
	EFICloseOut      ("CloverUpdate", "", "")
EndFunc

Func EFIUpdateClover ($ucdiskno, $ucpartno, $ucletter, $ucaction, $ucsub)
	$uctargetpath = $ucletter & "\efi\CLOVER"
	$uccloverold  = SettingsSingleGet ($uctargetpath & $setcloverlvlstring, $setcloveronpartition)
	;$uccloverold  = SettingsGet ($setcloveronpartition, $uctargetpath & "\grub2win.clover.settings.txt")
	If $ucaction  = $actioncloverdel Then
		UtilDiskWriteLog ()
		UtilDiskWriteLog ("Deleting the Clover EFI release " & $uccloverold & " directory")
		DirRemove        ($uctargetpath, 1)
		$partitionarray  [$ucsub] [$pCloverLevel] = $unknown
		SettingsPut      ($setcloverdeployed, "")
		UtilDiskWriteLog ()
		UtilDiskWriteLog ("The Clover EFI directory has been deleted")
		Return
	EndIf
	$uccloverpath = $extracttempdir & "\CLOVER"
	$ucclovernew  = SettingsSingleGet ($uccloverpath & $setcloverlvlstring, $setcloveronpartition)
	;$ucclovernew  = SettingsGet ($setcloveronpartition, $uccloverpath & "\grub2win.clover.settings.txt")
	If EFIFreespace ($ucdiskno, $ucpartno, $ucletter, $uccloverpath, "CLOVER", "Clover EFI Modules") Then Return "NoSpace"
	$ucactionmsg = "Refreshing the Clover EFI directory from release  " &  $uccloverold & "  to release  "  & $ucclovernew
	If $ucaction  = $actioncloverinst Then $ucactionmsg = "Installing the Clover EFI release  "   & $ucclovernew & "  directory"
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($ucactionmsg)
	FileDelete       ($windowstempgrub & "\clover.temp.plist")
	FileCopy         ($uctargetpath & "\config.plist", $windowstempgrub & "\clover.temp.plist", 1)
	DirRemove        ($uctargetpath, 1)
	DirCopy          ($uccloverpath, $uctargetpath, 1)
	FileCopy         ($windowstempgrub & "\clover.temp.plist", $uctargetpath & "\config.plist", 1)
	$partitionarray  [$ucsub] [$pCloverLevel] = $ucclovernew
	SettingsPut      ($setcloverdeployed,    $ucclovernew)
	SettingsPut      ($setcloveronpartition, $ucclovernew)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("The Clover EFI directory " & StringLeft ($ucactionmsg, 7) & " was successful")
Endfunc

Func EFICloverGet ($cgaction)
	If $cgaction = $actioncloverdel Or FileExists ($windowstempgrub & "\clover") Then Return "OK"
	$cgresult    = NetFunctionGUI ("DownloadExtract", $windowstempgrub & "\Download\grubclover", $downsourcesubproj, "GrubClover", "Clover Software")
	If $cgresult <> "OK" Then
		$cloverload = "Failed"
		UtilDiskWriteLog ()
		UtilDiskWriteLog ("The Clover Software Download Or Extract Failed")
	EndIf
	Return $cgresult
EndFunc

Func EFIFreespace ($efdiskno, $efpartno, $eftargetletter, $efcodepath, $eftargetdir, $efdesc)
	If $setupinprogress Then $efcodepath = $setupmasterpath & "\g2bootmgr"
	$efcodesize     = DirGetSize ($efcodepath)
	$eftargetpath   = $eftargetletter & "\efi\" & $eftargetdir
	$eftargetsize   = DirGetSize ($eftargetpath)
	$efnetsize      = $efcodesize - $eftargetsize
	If $efnetsize   < $mega Then Return
	$efsizeformat   = StringFormat ("%4.1f", $efnetsize / $mega)
	$effreespace    = Int (DriveSpaceFree ($eftargetletter & "\")) * ($mega)
	$effreeformat   = StringFormat ("%4.1f", $effreespace / $mega)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("The " & $efdesc & " Require " & $efsizeformat & " MB Of Space In The EFI Partition")
	If $efnetsize > $effreespace Then
		$efspacemessage =   "Freespace available  -  " & $effreeformat & " MB"
		MsgBox ($mberrorok, "** Your EFI Partition Is Full **", $efspacemessage, 120)
		UtilProcessError   ("** There is not enough free space in your EFI partition", _
			"Disk " & $efdiskno & " Partition " & $efpartno & " Drive " & $eftargetletter & " - Run Cancelled")
		Return "Error"
	EndIf
EndFunc

Func EFICloseOut ($coruntype, $cocallhandle, $cocaller)
	If $coruntype = $actionuninstall Then Return
	$ecflag = "  -  No Errors Found"
	Select
		Case $efierrorsfound = "yes"
			$cocolor = $myred
			$ecmessage = "   **  Grub2Win EFI Update Failed!!  **"
			$ecflag    = "      **  A Severe Error Occurred  **"
		Case $eficancelled   = "yes" Or $cloverload = "Failed"
			$cocolor = $myyellow
			$ecmessage = "** Grub2Win EFI Update Was Cancelled By User **"
			$ecflag    = "      **  Cancelled By User  **"
		Case Else
			$efideleted = ""
			$ecmessage  = "   **  Grub2Win EFI Update Successfully Completed  **"
			$cocolor    = $mygreen
	EndSelect
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($ecmessage)
	CommonWriteLog    ("    Ending EFI Update" & $ecflag)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Ending EFI Update on " & TimeLine ("", "", "yes") & "    Duration " & CommonCalcDuration ($efimilsec))
	FileClose ($utillogfilehandle)
	FileCopy  ($utillogfile, $efilogfile, 1)
	If CommonParms ($parmautoinstall) Then Return
	GUISetBkColor     ($cocolor, $utillogguihandle)
	GUICtrlSetBKColor ($utillogtxthandle,   $cocolor)
	If $cocaller = $callermain Or $efierrorsfound = "yes" Then GUICtrlSetState ($utillogclosehandle, $guishowit + $GUI_FOCUS)
	If Not $efierrorsfound                                Then GUICtrlSetState ($utillogreturnhandle, $guishowit)
	GUISetState       (@SW_SHOW, $utillogguihandle)
	UtilDiskGUIWait   ($cocallhandle, $cocaller)
	$esctype = "Main"
	If $efierrorsfound = "yes" Then CommonEndIt ("Failed")
	If $efiexit        = "yes" Then CommonEndIt ("Cancelled")
EndFunc

Func EFISetPartLetter ($plmdiskno, $plmpartno, ByRef $plmletter, $plmtype, $plmsub)
	If $plmletter = $winefiletter Then Return
	If $efiutilmsg <> "" Then UtilDiskWriteLog ($efiutilmsg)
	$efiutilmsg = ""
	If $efierrorsfound = "yes" Then Return
	If $plmtype = "assign"  And DriveStatus ($plmletter & "\") =  "READY" Then Return
	If $plmtype = "release" And DriveStatus ($plmletter & "\") <> "READY" Then Return
	$plmhandle = FileOpen ($diskpartprefix & "efipartletter." & $plmtype & $filesuffixin, 2)
	FileWriteLine ($plmhandle, "Select Disk "      & $plmdiskno)
	FileWriteLine ($plmhandle, "Select Partition " & $plmpartno)
	If $plmtype = "release" Then
		FileWriteLine ($plmhandle, "Remove Letter " & $plmletter)
		$partitionarray [$plmsub] [$pDriveLetter] = ""
		$plmletter                                = ""
	EndIf
	If $plmtype = "assign"  Then
		FileWriteLine ($plmhandle, "Assign Letter " & $plmletter)
		$partitionarray [$plmsub] [$pDriveLetter]  = $plmletter
	EndIf
	UtilRunDiskPart ("efipartletter." & $plmtype)
	Sleep (250) ; Allow diskpart assign & release time to stabilize
EndFunc

Func EFIListStats ($elsdiskno, $elspartno, $elsletter, $elspartsub, $elsmediadesc)
	$elshandle = FileFindFirstFile ($elsletter & "\EFI\*.*")
	If $elshandle = -1 Then Return
	UtilDiskWriteLog ("The Following Directories Were Found In   " & $elsletter & "\EFI   On  " & _
		$elsmediadesc & "  " & $elsdiskno & "   Partition " & $elspartno & ":")
	$elsefilevel = $unknown
	Dim $elsdirarray [0]
	While 1
		$elsfile = FileFindNextFile ($elshandle)
		If @error Then ExitLoop
		If Not @extended Then ContinueLoop
		If $elsfile = "grub2win" Then
			$elsefilevel = SettingsSingleGet ($elsletter & $setefilvlstring, $setefionpartition)
			If $elsefilevel <> $unknown Then $partitionarray [$elspartsub] [$pEFILevel] = $elsefilevel
			$partitionarray [$elspartsub] [$pGrubFound] = $foundstring
		EndIf
		If $elsfile = "clover" Then
			$elscloverlevel = SettingsSingleGet ($elsletter & $setcloverlvlstring, $setcloveronpartition)
			;$elscloverlevel = SettingsGet ($setcloveronpartition, $elsletter & "\EFI\clover\grub2win.clover.settings.txt")
			If $elscloverlevel <> $unknown Then $partitionarray [$elspartsub] [$pCloverLevel] = $elscloverlevel
			$elsfile &= "   release  " & $elscloverlevel
		EndIf
		_ArrayAdd ($elsdirarray, $elsfile)
	WEnd
	_ArraySort ($elsdirarray)
	For $elsdirsub = 0 To Ubound ($elsdirarray) -1
		UtilDiskWriteLog ("     " & $elsdirarray [$elsdirsub])
	Next
	FileClose ($elshandle)
	UtilDiskWriteLog ()
	$partitionarray [$elspartsub] [$pEFILevel] = $elsefilevel
	EFIPartInfo ($elspartsub)
	UtilDiskWriteLog ($partitionarray [$elspartsub] [$pPartInfo])
	CommonCheckpointLog ($utillogfile, $utillogfilehandle)
	;Sleep (2000)
	;_ArrayDisplay ($partitionarray)
EndFunc

Func EFIPartInfo ($pisub)
	$pidriveletter = $partitionarray [$pisub] [$pDriveLetter]
	$piefilevel    = $partitionarray [$pisub] [$pEFILevel]
	$pisize  = Int (DriveSpaceTotal ($pidriveletter))
	$pifree  = Int (DriveSpaceFree  ($pidriveletter))
	$pilabel = CommonGetLabel ($pidriveletter)
	$partitionarray [$pisub] [$pPartLabel] = $pilabel
	$piused  = $pisize - $pifree
	$pipct   = StringFormat ("%4.1f", 100 * ($piused / $pisize)) & "%"
	$piinfo  = $partitionarray [$pisub] [$pDriveLetter] & " EFI Partition "
	$piinfo  &= CommonFormatSize ($pisize * $mega) & "        Used  " & CommonFormatSize ($piused * $mega)
	$piinfo  &= "    " & $pipct & "  Full         EFI Module Level = "  & $piefilevel & "       Label = " & $pilabel
	$partitionarray [$pisub] [$pPartInfo] = $piinfo
EndFunc

Func EFIBrowse ($ebsub)
	$ebletter = $partitionarray [$ebsub] [$pDriveLetter]
	$eblabel  = $partitionarray [$ebsub] [$pPartLabel]
	$ebinfo   = "This EFI Partition Is On    Disk " & $partitionarray [$ebsub] [$pDiskNumber]
	$ebinfo  &= "   Partition " &          $partitionarray [$ebsub] [$pPartNumber] & "   Drive Letter " & $ebletter
	If $eblabel <> "" Then $ebinfo &= "       Partition Label = " & $eblabel
	$ebbrowsestart = $ebletter & "\efi"
	$ebfind        = $ebbrowsestart
	While 1
		$ebfilepath = FileOpenDialog ($ebinfo, $ebfind, "All(*.*)", $FD_MULTISELECT)
		If @error Then ExitLoop
		$ebfind     = $ebfilepath
		If StringLeft ($ebfind, 2) <> $ebletter Then
			$ebfind = $ebbrowsestart
			ContinueLoop
		EndIf
		$ebpid = ShellExecute ($notepadexec, $ebfilepath)
		ProcessWait ("notepad.exe", 10)
		While ProcessExists ($ebpid)
			Sleep (200)
		Wend
	Wend
EndFunc