#include-once
#include  <g2common.au3>

Func BackupMake ($bmspacer = "yes")
	If $backupcomplete = "yes" Or $backuptrigger = "" Or CommonParms ($parmuninstall) Then Return
	If $bmspacer <> "" Then CommonWriteLog ()
	CommonWriteLog ("    Creating backups in " & $backuppath)
	$bmname      = "grub2win." & $backupmode & "backup"
	$bmext       = "g2b"
	$bmarray     = BaseFuncArrayRead ($configfile, "BackupMake")
	$bmstamp     = FileGetTime     ($configfile, 0, 1)
	$bmbackfile  = $backupmain & "\" & $bmname & "."        & $bmext
	$bmlevel     = 0
	If $firmwaremode = "EFI" Then $bmlevel = SettingsGet ($setefideployed)
	_ArrayInsert  ($bmarray, 0, $backupdelim & "FileStamp=" & $bmstamp & $backupdelim & "EFILevel="  & $bmlevel & $backupdelim)
	CommonBackStep (5, $bmname, $bmext, $backupmain, $backupmain)
	_FileWriteFromArray ($bmbackfile, $bmarray)
	If $bootos = $xpstring Then
		$bmname        = "xpboot.backup"
		$bmext         = "ini"
		CommonBackStep      (5, $bmname, $bmext, $backupmain, $backupmain)
		FileCopy      ($xpinifile, $backupmain & "\" & $bmname & "." & $bmext, 1)
	Else
		$bmname        = "winbcd." & $backupmode & "backup"
		$bmext         = "bcd"
		CommonBackStep (5, $bmname, $bmext, $backupbcds, $backupbcds)
		$bmwinbcdfile  = $backupbcds & "\" & $bmname & "." & $bmext
		CommonBCDRun  ("/export " & $bmwinbcdfile, "export", "")
		If @error Then
			MsgBox         ($mbontop, "Error","*** BCD Export Error (BackupMake) ***", 30)
			CommonWriteLog               ("    *** BCD Export Error (BackupMake) ***")
		EndIf
		FileDelete    ($backupbcds & "\*.bcd.log*")
	EndIf
	If DirGetSize ($custconfigs) > 0 Then
		CommonDirStep (5, "customconfigs", $backupcustom)
		DirCopy  ($custconfigs, $backupcustom & "\customconfigs", 1)
	EndIf
	$backupcomplete = "yes"
EndFunc

Func BackupChoose ()
	$bcmessage  = "                       ** Select a Grub2Win backup file to be restored **"
	$bcsearch   = "Grub2Win Backups (*." & $backupmode & "*.g2b)"
	$bcfile     = $backupmain & "\grub2win." & $backupmode & "backup.g2b"
	$bcfilepath = FileOpenDialog ($bcmessage, $backupmain & "\", $bcsearch,  $FD_FILEMUSTEXIST, $bcfile, $handlemaingui)
	If @error Then
		$bcstatus = "cancelled"
	Else
		$bcversion = StringTrimRight ($bcfilepath, 4)
		$bcloc     = StringInStr     ($bcversion, "previous-")
		$bcversion = "." & StringTrimLeft  ($bcversion, $bcloc - 1)
		If $bcloc  = 0 Then $bcversion = ""
		$bcstatus = BackupRestore ($bcfilepath, $bcversion)
	EndIf
	If  $bcstatus Then
		MsgBox ($mbinfook, "Restore Cancelled", "The Grub2Win restore was cancelled by the user")
		return 0
	EndIf
EndFunc

Func BackupRestore ($brpath, $brversion)
	$brdisplay = StringReplace   ($brpath, $backupmain & "\", "          ")
	$brbcd     = StringReplace   ($brdisplay, "grub2win", "winbcd")
	$brbcd     = StringReplace   ($brbcd,     "g2b",      "bcd")
	$brini     = StringReplace   ($brdisplay, "grub2win", "xpboot")
	$brini     = StringReplace   ($brini,     "g2b",      "ini")
	$brini     = StringReplace   ($brini,     ".bios.",   ".")
	$brini     = StringReplace   ($brini,     ".xp.",     ".")
	$brmsg     = "The Grub2Win settings will be restored from this backup:"  & @CR  & @CR & $brdisplay & @CR & @CR & @CR
	If $bootos = $xpstring Then
		$brmsg    &= "The Windows boot.ini file will also be restored from:" & @CR  & @CR & $brini & @CR & @CR & @CR
	Else
		$brmsg    &= "The Windows BCD will also be restored from:"           & @CR  & @CR & $brbcd     & @CR & @CR & @CR
	EndIf
	$brmsg    &= 'Please click "Yes" to confirm'                             & @CR  & @CR
	$brrc = MsgBox ($mbquestyesno, "Restore", $brmsg)
	If $brrc <> $IDYES Then Return "cancelled"
	$brarray  = BaseFuncArrayRead ($brpath, "BackupRestore")
	$brsplit  = StringSplit    ($brarray [0], $backupdelim, 1)
	$brstamp  = StringTrimLeft ($brsplit [2], 10)
	$brlevel  = StringTrimLeft ($brsplit [3],  9)
	_ArrayDelete        ($brarray, 0)
	_FileWriteFromArray ($configfile, $brarray)
	FileSetTime         ($configfile, $brstamp)
	DirRemove  ($custconfigs, 1)
	DirCreate  ($custconfigs)
	DirCopy    ($backupcustom & "\customconfigs" & $brversion, $custconfigs, 1)
	FileDelete ($usersectionfile)
	If $bootos = $xpstring Then
		$brinifile  = $backupmain & "\" & StringStripWS ($brini, 8)
		FileCopy ($brinifile, $xpinifile, 1)
	Else
		CommonFlashStart ("Restoring Grub2Win settings and Windows BCD")
		$brbcdfile  = $backupbcds & "\" & StringStripWS ($brbcd, 8)
		CommonBCDRun  ("/import " & $brbcdfile & " /clean", "import")
		If $firmwaremode = "EFI" Then
			SettingsPut ($setefideployed, $brlevel)
			BCDCleanup  ()
			BCDSetupEFI ("grub2win" & $osbits)
		EndIf
		CommonFlashEnd  ()
	EndIf
	CommonWriteLog ()
	CommonWriteLog ("The Grub2Win settings were restored from backup: " & $brpath, Default, "")
	MsgBox ($mbinfook, "Restore", "The restore was successful" & @CR & @CR & 'Grub2Win will restart when you click "OK"')
	CommonEndIt  ("Restart")
EndFunc

Func BackupEFI  ($bediskno, $bepartno, $beletter)
	$betarget = "EFIBackup-Disk-" & $bediskno & "-Partition-" & $bepartno
	$bename   =  $backupefipart & "\"  & $betarget
	CommonFlashStart ("Creating an EFI Partition File Backup of Disk " & $bediskno & "  Partition " & $bepartno,  _
		"The backup name is   " & $bename, 2000)
    UtilDiskWriteLog ()
	UtilDiskWriteLog ("Creating an EFI Partition File Backup of Disk " & $bediskno & "  Partition " & $bepartno)
	UtilDiskWriteLog ("The backup name is   " & $bename)
	DirRemove        ($bename, 1)
	BackupCopyPath   ($beletter,                                  $bename,  "EFI")
	BackupCopyPath   ($beletter & "\EFI",                         $bename & "\EFI", "Microsoft")
	If FileExists    ($beletter & "\EFI\Microsoft\Boot") Then
		BackupCopyPath   ($beletter & "\EFI\Microsoft\Boot",      $bename & "\EFI\Microsoft\Boot", "", "BCD")
		DirCopy          ($beletter & "\EFI\Microsoft\Recovery" , $bename & "\EFI\Microsoft\Recovery", 1)
	EndIf
	$bebcdtarget     = $bename & "\grub2win.efibackup.bcd"
	CommonBCDRun     ("/export " & $bebcdtarget, "efibackup", "")
	If @error Then
		MsgBox         ($mbontop, "Error","*** BCD Export Error (BackupEFI) ***", 30)
		CommonWriteLog               ("    *** BCD Export Error (BackupEFI) ***")
	EndIf
	;CommonFlashEnd   ()
	FileDelete       ($bebcdtarget & ".log*")
EndFunc

Func RestoreEFI ($rediskno, $repartno, $reletter)
	While 1
		$refolder = FileSelectFolder ("** Select an EFI Backup to restore to disk " & $rediskno & " partition " & $repartno & " **", $backupefipart)
		If @error Then
			MsgBox ($mbwarnok, "EFI File Restore", "The EFI Partition File Restore Was Cancelled", 60)
			Return
		EndIf
		$repatharray = StringSplit ($refolder, "\")
		If @error Then ContinueLoop
		$recheck = $repatharray [Ubound ($repatharray) - 1]
		If StringLeft ($recheck, 10) = "EFIBackup-" Then ExitLoop
		MsgBox ($mbontop, "** Selection Error ** ", 'The EFI backup name you select must begin with "EFIBackup"' _
			& @CR & @CR & "Please Try Again")
	Wend
	CommonFlashStart ("Restoring Your EFI Backup Files To Disk " & $rediskno & "  Partition " & $repartno, _
		"The backup name was   " & $refolder, 2000)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Restoring Your EFI Backup Files To Disk " & $rediskno & "  Partition " & $repartno)
	UtilDiskWriteLog ("The backup name was   " & $refolder)
	DirRemove  ($reletter & "\*.*", 1)
	FileDelete ($reletter & "\*.*")
	$rehandle    = FileFindFirstFile ($reletter & "\EFI\*.*")
	If $rehandle = -1 Then MsgBox ($mberrorok, "Error", "Error Reading The " & $reletter & "\EFI Directory")
	While 1
		$rename = FileFindNextFile ($rehandle)
		If @error Then ExitLoop
		DirRemove  ($reletter & "\EFI\" & $rename, 1)
		FileDelete ($reletter & "\EFI\" & $rename)
		;MsgBox ($mbontop, "Del", $rename)
	Wend
    FileClose ($rehandle)
	BackupCopyPath     ($refolder,                             $reletter & "\",                    "EFI")
	BackupCopyPath     ($refolder & "\EFI",                    $reletter & "\EFI",                 "Microsoft")
	If FileExists      ($refolder & "\EFI\Microsoft\Boot") Then
		BackupCopyPath ($refolder & "\EFI\Microsoft\Boot",     $reletter & "\EFI\Microsoft\Boot" , "", "BCD")
		DirCopy        ($refolder & "\EFI\Microsoft\Recovery", $reletter & "\EFI\Microsoft\Recovery" ,1)
	EndIf
	$rebcdtarget       = $reletter & "\grub2win.efibackup.bcd"
	CommonBCDRun       ("/import " & $rebcdtarget & " /clean", "efirestore")
	FileDelete         ($rebcdtarget & ".*")
	CommonFlashEnd     ()
EndFunc

Func BackupCopyPath ($cpfrompath, $cptopath, $cpskipdir = "", $cpskipfilestring = "")
	If Not FileExists ($cptopath) Then DirCreate ($cptopath)
	;MsgBox ($mbontop, "Copy", $cpfrompath & @CR & $cptopath & @CR & $cpskipdir & @CR & $cpskipfilestring)
	$cphandle    = FileFindFirstFile ($cpfrompath & "\*.*")
	If $cphandle = -1 Then MsgBox ($mberrorok, "Error", "Error Reading The " & $cpfrompath & " Directory")
	While 1
		$cpname = FileFindNextFile ($cphandle)
		If @error Then ExitLoop
		If StringInStr (FileGetAttrib ($cpfrompath & "\" & $cpname), "D") Then
			If $cpskipdir <> "" And $cpname = $cpskipdir Then ContinueLoop
			If $cpname = "System Volume Information" Or $cpname = "$RECYCLE.BIN" Then ContinueLoop
			DirCopy ($cpfrompath & "\" & $cpname, $cptopath & "\" & $cpname, 1)
			ContinueLoop
		EndIf
		If $cpskipfilestring <> "" And StringInStr ($cpname, $cpskipfilestring) Then ContinueLoop
		FileCopy ($cpfrompath & "\" & $cpname, $cptopath & "\" & $cpname, 1)
	Wend
    FileClose ($cphandle)
EndFunc