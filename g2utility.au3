#RequireAdmin
#include-once
#include  <g2common.au3>

If StringInStr (@ScriptName, "g2utility") Then
	CommonEFIMountWin ()
	CommonFlashStart ($runtype & " Is Scanning Your Disks And Partitions")
	PartBuildDatabase    ("yes")
	CommonFlashEnd       ()
	_ArrayDisplay        ($partitionarray)
	UtilPartitionReport  ()
	ShellExecute         ($notepadexec, $partlistfile, "", "", @SW_MAXIMIZE)
	BaseFuncCleanupTemp  ("Utility")
EndIf

Func UtilScanDisks ($sdtitle = "", $sdcallhandle = "", $sdcaller = "")
	;If Ubound ($partitionarray) <> 0 Then Return
	If Not CommonParms ($parmquiet) And $sdcallhandle <> "" Then UtilDiskGUISetup ($sdtitle, $sdcallhandle, $sdcaller)
	UtilCheckDisks    ()
	UtilDiskSummary   ()
	UtilPartitionReport ()
	$sdmsg = BaseFuncSing ($partcountefi,  $partcountefi  & "  EFI system partitions were found")
	UtilDiskWriteLog  ()
	UtilDiskWriteLog  ($sdmsg)
	$sdmsg = BaseFuncSing ($partcountpart, $partcountpart & "  Partitions were found")
	UtilDiskWriteLog  ()
	UtilDiskWriteLog  ($sdmsg)
EndFunc

Func UtilCheckDisks ()
	UtilDiskWriteLog ("Spinning Up And Scanning Disks", "startline")
	UtilDiskWriteLog ("  -  The Partition Scan May Take Up To 60 seconds", "endline")
	UtilDiskWriteLog ()
	Sleep            (250)
	If $partcountdisk = 0 Then
		MsgBox ($mbwarnok,  "No disk drives were detected!", "Grub2Win Run Aborted")
		Exit
	EndIf
	$cdadiskmsg = BaseFuncSing ($partcountdisk, $partcountdisk & " disk drives were detected")
	UtilDiskWriteLog ($cdadiskmsg)
	UtilDiskWriteLog ()
EndFunc

Func UtilDiskSummary ()
	Local $dspartcount, $dseficount, $dslastdisk, $dsdesc
	For $dssub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$dssub] [$pPartNumber] = 0 Then
			If $dslastdisk <> "" Then UtilDiskTotals ($dslastdisk, $dspartcount, $dseficount, $dsdesc)
			$dscurrdisk  = $partitionarray [$dssub] [$pDiskNumber]
			$dsdesc      = $partitionarray [$dssub] [$pDriveMediaDesc]
			$dspartcount = 0
			$dseficount  = 0
			$dslastdisk  = $dscurrdisk
			UtilDiskWriteLog ("Examining " & $dsdesc & " " & $dscurrdisk & "     ", "startline")
			ContinueLoop
		EndIf
		$dspartcount += 1
		If $partitionarray [$dssub] [$pEFIFlag] = $efivalid Then $dseficount += 1
	Next
	If $dslastdisk <> "" Then UtilDiskTotals ($dslastdisk, $dspartcount, $dseficount, $dsdesc)
	UtilDiskWriteLog ()
EndFunc

Func UtilDiskTotals ($dtlastdisk, $dtpartcount, $dteficount, $dtdesc)
	$dtmsg = "Found " & StringFormat ("%2s", $dtpartcount) & "  Partitions"
	If $dtpartcount  = 0 Then $dtmsg = "No partitions were found on " & $dtdesc & "  " & $dtlastdisk
	If $dtpartcount  = 1 Then $dtmsg = StringTrimRight ($dtmsg, 1) & " "
	If $dteficount   > 0 Then $dtmsg &= "      ** " & $dtdesc & "  " & $dtlastdisk & "  contains an EFI partition **"
	UtilDiskWriteLog ($dtmsg, "endline")
EndFunc

Func UtilDiskGUISetup ($dgsguititle = "", $dgscallhandle = "", $dgscaller = "")
	$utillogct           = 0
	$utilloglines        = ""
	If $dgsguititle      = "" Then $dgsguititle = "Grub2Win Disk Scan"
	$dgsguititle        &= " Log"
	If $parmsdisplay <> "" Then $dgsguititle &= "          P=" & $parmsdisplay
	If $dgscallhandle <> "" Then GUISetState (@SW_MINIMIZE, $dgscallhandle)
	BaseFuncGUIDelete ($utillogguihandle)
	$utillogguihandle    = CommonScaleCreate ("GUI", $dgsguititle,       1,  0, 75,   77, "", $WS_EX_STATICEDGE, $dgscallhandle)
	$utillogtxthandle    = CommonScaleCreate ("List", "",                0,  0, 74.7, 66, 0x00200000)
	GUISetBkColor       ($mymedblue, $utillogguihandle)
	GUICtrlSetBKColor   ($utillogtxthandle, $mymedblue)
	$utillogclosehandle  = CommonScaleCreate ("Button", "Exit Grub2Win", 2, 67, 22,    4)
	GUICtrlSetState     ($utillogclosehandle, $guihideit)
	$utillogreturnhandle = CommonScaleCreate ("Button", "Return To The " & $dgscaller & " Menu", 45, 67, 26, 4)
	GUICtrlSetState     ($utillogreturnhandle, $guihideit)
	GUISetState         (@SW_SHOW,  $utillogguihandle)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ()
	UtilDiskWriteLog ("Starting the " & $dgsguititle & " on " & TimeLine ("", "", "yes"))
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($progvermessage)
	UtilDiskWriteLog ("           Generation Stamp   " & $genstampdisp)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ()
EndFunc

Func UtilDiskGUIWait ($gwcallhandle, $gwcaller)
	While $gwcallhandle <> ""
		$gwmsg = GUIGetMsg ()
		Select
			Case CommonParms ($parmquiet)
				ExitLoop
			Case $gwmsg    = ""
			Case $gwcaller = "Closeout"
				GUICtrlSetState ($utillogreturnhandle, $guihideit)
				Sleep (1500)
				Exitloop
			Case $gwmsg  = $utillogclosehandle
				$efiexit = "yes"
				ExitLoop
			Case $gwmsg  = $utillogreturnhandle Or ($gwcaller = $parmsetup And Not $efierrorsfound)
				UtilDiskWriteLog ()
				UtilDiskWriteLog ("Returning To The Grub2Win " & $gwcaller & " Menu")
				Sleep (700)
				GUISetState (@SW_RESTORE, $gwcallhandle)
				ExitLoop
		EndSelect
	Wend
	BaseFuncGUIDelete ($utillogguihandle)
EndFunc

Func UtilPartitionReport ()
	_ArraySort ($partitionarray, 0, 0, 0, $pSortPhysical)
	;_ArrayDisplay ($partitionarray)
	Local $proffset, $prprevdrivesize, $prprevoffset, $prprevsize, $prprevextended
	$utilreporthandle = FileOpen ($partlistfile, 2)
	$uptitle  = @TAB & "Disk and Partition List as of " & TimeLine () & @TAB & @TAB & @TAB & $scantime
	If $parmsdisplay <> "" Then $uptitle &= "       Parms = " & $parmsdisplay
	FileWriteLine ($utilreporthandle, @CRLF & $uptitle & @CRLF & @CRLF)
	For $prsub = 0 To Ubound ($partitionarray) - 1
		$prline      = ""
		$prtempmount = ""
		If $partitionarray [$prsub] [$pPartNumber] = 0 Then
			UtilCheckUnalloc ($prprevoffset, $prprevsize, $prprevdrivesize, 0, $utilreporthandle, $prprevextended)
			UtilDiskHeader   ($prsub, $partitionarray, $utilreporthandle)
			$proffset        = 0
			$prprevoffset    = 0
			If $partitionarray [$prsub] [$pDriveLoaded] <> "" Then $prprevoffset = $highnumber
			$prprevsize      = 0
			$prprevdrivesize = $partitionarray [$prsub] [$pDriveSize]
			ContinueLoop
		EndIf
		UtilCheckUnalloc ($prprevoffset, $prprevsize, $partitionarray [$prsub] [$pPartOffset], _
			$partitionarray [$prsub] [$pPartSize], $utilreporthandle, $prprevextended)
		UtilFormatField  ($prline, "Partition", $partitionarray [$prsub] [$pPartNumber],     14)
		$prtype = $partitionarray [$prsub] [$pPartType]
		If $partitionarray [$prsub] [$pEFIFlag] <> "" Then
			$prtype = $partitionarray [$prsub] [$pEFIFlag]
			If $prtype = $efivalid Then $prtype = "** Other EFI **"
			If $partitionarray [$prsub] [$pDriveLetter] = $winefiletter Then
				$prtype = "** Windows EFI  **"
				If $winefistatus = "mounted" Then $prtempmount = "*"
			EndIf
		Else
			If StringInStr ($partitionarray [$prsub] [$pPartFileSystem], "FAT") And  _
				FileExists ($partitionarray [$prsub] [$pDriveLetter] &  "\EFI")  Then _
				$prtype = "** Invalid EFI **"
		EndIf
		UtilFormatField  ($prline, "",          $prtype,                              28)
		UtilFormatField  ($prline, "Letter",    $partitionarray [$prsub] [$pDriveLetter] & $prtempmount, 14)
		UtilFormatField  ($prline, "FS",        $partitionarray [$prsub] [$pPartFileSystem],             14)
		$prsizeline = CommonFormatSize ($partitionarray [$prsub][$pPartSize], "yes")
		If $partitionarray [$prsub] [$pPartFreeSpace] <> "" Then
			$prusedpercent =  100 - Int (100 * ($partitionarray [$prsub] [$pPartFreeSpace] / $partitionarray [$prsub] [$pPartSize]))
			$prsizeline &= "   " & StringFormat ("%3.0f", $prusedpercent) & "% Full"
		EndIf
		UtilFormatField  ($prline, "Size", $prsizeline, 30)
		$prlabel = $partitionarray [$prsub] [$pPartLabel]
		$pruuid  = $partitionarray [$prsub] [$pPartUUID]
		$prmisc  = ""
		If $prlabel <> "" Then
			$prmisc = "Label = " & $prlabel
			$prline &= $prmisc & "    "
		EndIf
		If $partitionarray [$prsub] [$pPartUuID] <> "" Then $prline &= @CRLF & "UUID = " & $pruuid
		FileWriteLine ($utilreporthandle, $prline & @CRLF & @CRLF)
		$prprevextended = $partitionarray [$prsub] [$pPartExtended]
	Next
	UtilCheckUnalloc ($prprevoffset, $prprevsize, $prprevdrivesize, 0, $utilreporthandle, $prprevextended)
	FileWriteLine ($utilreporthandle, _StringRepeat ("*", 124))
	UtilWriteTotal ("Drive Types",        "no", 2, 2, 52)
	UtilWriteTotal ("MBR",     $partcountmbr)
	UtilWriteTotal ("GPT",     $partcountgpt)
	If $partcountflash > 0 Or $drivecountcd > 0 Then
		UtilWriteTotal ("Fixed Drives",  $partcountdisk - $partcountflash, 2)
		UtilWriteTotal ("Flash Drives",  $partcountflash)
		UtilWriteTotal ("CD/DVD Drives", $drivecountcd)
	EndIf
	UtilWriteTotal ("Total Drives", $partcountdisk + $drivecountcd, 1, 2)
	UtilWriteTotal ("Partition Types",    "no", 1, 2, 52)
	UtilWriteTotal ("Windows", $partcountwin)
	UtilWriteTotal ("Linux",   $partcountlinux)
	UtilWriteTotal ("Swap",    $partcountswap)
	UtilWriteTotal ("Apple",   $partcountapple)
	UtilWriteTotal ("BSD",     $partcountbsd)
	UtilWriteTotal ("EFI",     $partcountefi)
	UtilWriteTotal ("Other",   $partcountother)
	UtilWriteTotal ("Total Partitions", $partcountpart, 1, 2)
	FileClose ($utilreporthandle)
	$utilreporthandle = FileOpen ($partlistfile)
	$prlfdata = FileRead ($utilreporthandle)
	FileClose ($utilreporthandle)
	$prlfdata   = StringReplace ($prlfdata, @CRLF & @CRLF, @CRLF)
	$prlfhandle = FileOpen ($partlistlffile, 2)
	FileWrite ($prlfhandle, $prlfdata)
	FileClose ($prlfhandle)
EndFunc

Func UtilWriteTotal ($wtline, $wtcount, $wtskipbef = 0, $wtskipaft = 1, $wtspace = 48)
	$wtcountout = StringFormat ("%3i", $wtcount)
	If $wtcount = "no" Then $wtcountout = ""
	If $wtcount = ""   Then Return
	$wtskipbef = _StringRepeat (@CRLF, $wtskipbef)
	$wtskipaft = _StringRepeat (@CRLF, $wtskipaft)
	FileWriteLine ($utilreporthandle,  $wtskipbef & _StringRepeat (" ", $wtspace) & _
		BaseFuncPadRight ($wtline, 18) & $wtcountout & $wtskipaft)
EndFunc

Func UtilCheckUnalloc (ByRef $cuprevoffset, ByRef $cuprevsize, $cucurroffset, $cucurrsize, $cuhandle, $cuextended)
	If $cuextended = "yes" Then $cuextended = "               Extended: "
	$cusize = $cucurroffset - $cuprevoffset - $cuprevsize
	$cuprevoffset = $cucurroffset
	$cuprevsize   = $cucurrsize
	If $cusize <= 2 * $mega Then Return
	$culine = BaseFuncPadRight ($cuextended & "** Unallocated Space ** ", 70) & "Size " & CommonFormatSize ($cusize, "yes")
	FileWriteLine ($cuhandle, $culine & @CRLF & @CRLF)
EndFunc

Func UtilDiskHeader ($dhsub, $dharray, $dhhandle)
	FileWriteLine ($dhhandle, _StringRepeat ("*", 124))
	$dhline = ""
	If $dharray [$dhsub] [$pDriveLoaded] = "" Then
		UtilFormatField ($dhline, $dharray [$dhsub] [$pDriveMediaDesc], $dharray [$dhsub] [$pDiskNumber], 12)
		UtilFormatField ($dhline, "Style",  $dharray [$dhsub] [$pDriveStyle], 12)
	Else
		UtilFormatField ($dhline, $dharray [$dhsub] [$pDriveMediaDesc], $drivecountcd & " ", 24)
		$dharray [$dhsub] [$pDriveUsed] = $dharray [$dhsub] [$pDriveSize]
		$drivecountcd += 1
	EndIf
	UtilFormatField ($dhline, "Sector", $dharray [$dhsub] [$pDriveSecSize], 18)
	$dhdriveadj = $dharray [$dhsub] [$pDriveSize]
	If $dharray [$dhsub] [$pDriveUsed] > $dhdriveadj Then $dhdriveadj = $dharray [$dhsub] [$pDriveUsed]
	UtilFormatField ($dhline, "Size",  CommonFormatSize  ($dhdriveadj), 18)
	$dhusednumber = CommonFormatSize  ($dharray [$dhsub] [$pDriveUsed])
	$dhusedpct    = ($dharray [$dhsub] [$pDriveUsed] / $dhdriveadj)
	$dhusedpct    = ($dhusedpct * 100)
	$dhpctformat  = StringFormat ("%3.0f", $dhusedpct)
	If $dhusedpct < 99.999 Then $dhpctformat = StringFormat ("%3.2f", $dhusedpct)
	If $dhusedpct < 99     Then $dhpctformat = StringFormat ("%3.1f", $dhusedpct)
	If $dharray [$dhsub] [$pDriveUsed] < 1 Then $dhpctformat = 0
	UtilFormatField ($dhline, "Used", $dhusednumber & "  " & $dhpctformat & "%", 25)
	$dhfree    =  $dhdriveadj - $dharray [$dhsub] [$pDriveUsed]
	If $dhfree > 1 * $mega Then
		UtilFormatField ($dhline, "Free", CommonFormatSize  ($dhfree), 14)
	Else
		UtilFormatField ($dhline, "",     "",                          14)
	EndIf
	UtilFormatField ($dhline, "", $dharray [$dhsub] [$pDriveLabel],    40)
	If $dharray [$dhsub] [$pDriveMediaDesc] = "Flash" Then $dhline &= @CRLF & _StringRepeat (" ", 100) & "** This Is A Flash Drive **"
	FileWriteLine   ($dhhandle, @CRLF & $dhline & @CRLF & @CRLF & @CRLF)
	If $dharray [$dhsub] [$pDriveLetter]    = "Ignore" Then
		FileWrite ($dhhandle,                                                                                              _
		@TAB  & @TAB &        "**      Disk " & $dharray [$dhsub] [$pDiskNumber] & " Was Ignored Due To Read Errors      **" & _
		@CRLF & @TAB & @TAB & "**  This May Be Caused By An Empty SD Card Reader  **" & @CRLF & @CRLF)
	Else
		$dhnopart = "**           No Partitions Were Found              **"
		If $dharray [$dhsub] [$pDriveLoaded] <> "" Then
			$dhnopart  =  "No Drive Letter Assigned   "
		    If $dharray [$dhsub] [$pDriveLetter] <> "" Then $dhnopart = "Drive Letter " & $dharray [$dhsub] [$pDriveLetter]
			$dhnopart = @TAB & @TAB & $dhnopart & "    Drive Status - " & $dharray [$dhsub] [$pDriveLoaded]
		EndIf
		If $dharray [$dhsub] [$pDrivePartCount] = 0 Then FileWrite ($dhhandle, @TAB & @TAB & $dhnopart & @CRLF & @CRLF)
	EndIf
EndFunc

Func UtilFormatField (ByRef $ffline, $ffname, $ffdata, $ffpad = 10, $ffsep = " ")
	If $ffdata = "" Then $ffname = ""
	$ffline &= BaseFuncPadRight ($ffname & $ffsep & $ffdata, $ffpad)
EndFunc

Func UtilRunDiskPart ($dpfilestring, $dpdisperror = "yes")                      ; Run DiskPart Utility
	$dpinfile   = $diskpartprefix & $dpfilestring & $filesuffixin
	$dpoutfile  = $diskpartprefix & $dpfilestring & $filesuffixout
	$dpinhandle = FileOpen ($dpinfile, 1)
	FileWriteLine ($dpinhandle, "Exit")
	FileClose     ($dpinhandle)
	$dpstring   =   $efiutilexec & " /s " & $dpinfile
	$dprc       = ""
	Sleep       (100)   ;100 ms delay to allow any previous DiskPart commands to complete
	$dparrayout = BaseFuncShellWait ($dpstring, $dpoutfile, $dprc, "UtilRunDiskpart B")
	If $dprc <> 0 And $dpdisperror = "yes" Then
		$dparrayin = BaseFuncArrayRead  ($dpinfile,  "UtilRunDiskPart A")
		_ArrayAdd ($efiassignlogarray, _StringRepeat ("_", 80))
		_ArrayAdd ($efiassignlogarray, "")
		_ArrayAdd ($efiassignlogarray, "New York Time = " & $nytimeus)
		_ArrayConcatenate ($efiassignlogarray, $dparrayin)
		_ArrayConcatenate ($efiassignlogarray, $dparrayout)
		UtilProcessError ("DiskPart Run Error - Return Code " & _
			$dprc, "Error " & @error);
	EndIf
EndFunc

Func UtilCheckEncryption ($cedrive)
	If $bootos = $xpstring Then Return
	$encryptionstatus = 0
	$ceoutput  = $windowstempgrub & $encryptstring
	$cestring  = $encryptexec & " -status " & $cedrive
	$cerc      = ""
	$cearray   = BaseFuncShellWait ($cestring, $ceoutput, $cerc, "UtilCheckEncryption")
	;_ArrayDisplay ($cearray, $cerc)
	For $cesub = 0 To Ubound ($cearray) - 1
		$cerec = $cearray [$cesub]
		If Not StringInStr ($cerec, "AES")  Then ContinueLoop
		If StringInStr     ($cerec, "-AES") Or StringInStr ($cerec, "AES-") Then $encryptionstatus = 1
	Next
EndFunc

Func UtilProcessError ($peline1, $peline2 = "", $pelogfile = $utillogfile, $pelogfilehandle = $utillogfilehandle)
	UtilDiskWriteLog ()
	UtilDiskWriteLog ($peline1)
	If $peline2 <> "" Then UtilDiskWriteLog ($peline2)
	UtilDiskWriteLog ()
	$diagerrorcode  = $peline1
	If $pelogfile <> "" Then CommonCheckpointLog ($pelogfile, $pelogfilehandle)
EndFunc

Func UtilDiskWriteLog ($wlline = "", $wltype = "", $wltxthandle = $utillogtxthandle, $wlfilehandle = $utillogfilehandle)
	Local $wldisplaynl, $wlfilenl
	If $wltype      = "" Or $wltype = "endline" Then
		$utillogct   += 1
		$wldisplaynl = "|"
		$wlfilenl    = @CR
	EndIf
	$wlformatline = $wlline
	If $wltype  <> "endline" Then $wlformatline = "    " & $wlline
	If $utillogct > 28 Then
		 GUICtrlSetData ($wltxthandle, $wlformatline & "|")
		_GUICtrlListBox_SetTopIndex ($wltxthandle, $utillogct - 28)
	Else
		$utilloglines &= $wlformatline & $wldisplaynl
		GUICtrlSetData ($wltxthandle, "")
		GUICtrlSetData ($wltxthandle, $utilloglines)
	EndIf
	FileWrite ($wlfilehandle, $wlline & $wlfilenl)
EndFunc

Func UtilCreateSysInfo ()
	Local $csimessage
	If Not FileExists ($windowstempgrub) Then Return
	$statuszulu = ""
	SettingsPut  ($setstatusgeo, "")
	CommonGetGeo (1)
	$sibuild   = @OSBuild
	$csiheader = "The OS Is " & @TAB & $bootos & "      Build " & $sibuild                   & @CRLF & @CRLF
	If $winbootdisk <> "" Then $csiheader &= "Windows Boot" & @TAB  & "Drive " & _
			$windowsdrive & @TAB & "Disk  " & $winbootdisk & "  Partition  " & $winbootpart  & @CRLF & @CRLF
	;If StringLen ($csimessage) < 30 Then Return
	If $bootos <> $xpstring Then $csimessage &= UtilGetMachineInfo ()
	TimeGetCurrent ("ZuluNet")
	$csimessage &= @CRLF & "Current As Of"  & @TAB & TimeFormatDate ($localjul, "", $localhour & $localmin & $localsec, "datetime", "yes")  & @CRLF
	$csimessage &= @CRLF & "ZULU          " & @TAB & $zulutimeline       & @CRLF
	$csimessage &= @CRLF & "New York Time " & @TAB & $nytimeus           & @CRLF
	$csimessage &= @CRLF & "Time Zone     " & @TAB & $timezonedisplay    & @CRLF
	$csimessage &= @CRLF & "Gen Stamp     " & @TAB & $genstampdisp       & @CRLF
	$csimessage &= @CRLF & "Install Date  " & @TAB & BaseFuncPadRight (StringTrimLeft (SettingsGet ($setinstalldate), 17), 42) _
		& @TAB & "Updated " & StringTrimLeft ($latestsetup, 17) & @CRLF
	$csimessage &= @CRLF & "Boot Time     " & @TAB & BaseFuncPadRight (StringTrimLeft ($bootstamp, 17), 42)                    _
		& @TAB & "Uptime is " & TimeFormatTicks ($upticks) & @CRLF
	$csimessage &= @CRLF & $langline1 & @TAB & @TAB & "User name is " & $useridformat
	If $langline2 <> "" Then $csimessage &= @CRLF & @CRLF & $langline2
	If $langline3 <> "" Then $csimessage &= @CRLF & @CRLF & $langline3
	If $langline4 <> "" Then $csimessage &= @CRLF & @CRLF & $langline4
	$csimessage &= @CRLF & @CRLF & "IP Address" & @TAB                & SettingsGet ($setstatipaddress)  & "    "
	$csimessage &= @TAB  & @TAB  & @TAB & @TAB  & "GNU Grub Version " & SettingsGet ($setgnugrubversion)
	$csimessage &= @CRLF & @CRLF & CommonLoadFormat ()
	$sysinfotitle   = "** Grub2Win Version " & $basrelcurr & "   System Hardware Information"
	$sysinfomessage = $csiheader & $csimessage
	$csimessage  = StringReplace ($csimessage, "dword:", "")
	$csiheader   = $sysinfotitle & @CRLF & @CRLF & $csiheader
	$csihandle   = FileOpen ($systemdatafile, 2)
	FileWrite   ($csihandle, $csiheader & $csimessage)
	FileClose   ($csihandle)
	_FileWriteFromArray ($systempartfile, $partitionarray)
EndFunc

Func UtilGetMachineInfo ()
	For $gmithreads = 1 To 100
		RegEnumKey ($regkeycpu & "\CentralProcessor", $gmithreads)
		If @error Then ExitLoop
	Next
	$gmifirm         = $systemmode
	If $firmwaremode = "EFI" Then $gmifirm &= "-" & $osbits
	$gmistring      = 'Regedit.exe /E "' & $sysinfotempfile & '" ' & $regkeysysinfo
	$gmirc          = ""
	BaseFuncShellWait ($gmistring, "", $gmirc, "UtilGetMachineInfo A")
	If FileExists    ($sysinfotempfile) Then
		$gmiarray    = BaseFuncArrayRead    ($sysinfotempfile, "UtilGetMachineInfo B")
		$gmimessage  = "Processor" & @TAB & $procbits    & " Bit" & @TAB & $gmithreads - 1 & " Thread " & $regcpuname & @CRLF & @CRLF
		$gmimessage &= "Memory   " & @TAB & $sysmemorygb & @TAB
		$gmimessage &= _WinAPI_GetNumberFormat (0, $sysmemorybytes, _WinAPI_CreateNumberFormatInfo (0, 1, 3, '', ',', 1)) & " Bytes"
		$gmimessage &= @CRLF & @CRLF & "Firmware Mode Is " & BaseFuncPadRight ($gmifirm, 12) & @TAB
		If $firmwaremode = "EFI" Then $gmimessage &= "Secure Boot Is " & $securebootstatus & _
			"       EFI Level Is " & SettingsGet ($setefideployed)
		If $firmmoderc <> ""  Then $gmimessage &= @CRLF & @CRLF & "Firmware RC" & @TAB & @TAB & $firmmoderc
		$gmimessage &= BaseFuncCheckVirtual ()
		For $gmisub = 3 To Ubound ($gmiarray) - 2
			$gmirecord     = StringReplace  ($gmiarray   [$gmisub], '"',  '')
			$gmirecord     = StringReplace  ($gmirecord, 'dword:000000',  '')
			If StringInStr ($gmirecord, "Default string") Then ContinueLoop
			$gmilocsplit   = StringInStr    ($gmirecord, "=")
			$gmirecleft    = StringLeft     ($gmirecord, $gmilocsplit - 1)
			$gmirecright   = StringTrimLeft ($gmirecord, $gmilocsplit)
			If $gmilocsplit < 16 Then $gmirecleft &= @TAB
			$gmirecord     = $gmirecleft & _StringRepeat  (" ", 25 - $gmilocsplit) & @TAB & $gmirecright
			$gmimessage   &= @CRLF & @CRLF & StringReplace ($gmirecord, '"', '')
		Next
		Return $gmimessage
	EndIf
EndFunc

Func UtilEnvGet ($egkey)
	If Not IsArray ($envarray) Then
		Dim $envarray [0] [2]
		If FileGetSize ($envfile) <> 1024 Then FileCopy ($masterpath & "\winsource\grubenv", $masterpath & "\", 1)
		$eghandle = FileOpen ($envfile)
		While 1
			$egrecord = FileReadLine ($eghandle)
			If @error Then ExitLoop
			_ArrayAdd ($envarray, $egrecord, 0, "=")
		Wend
		FileClose ($eghandle)
		_ArrayDelete  ($envarray, Ubound ($envarray) - 1)
	EndIf
	$egloc = _ArraySearch ($envarray, $egkey)
	If @error Then Return ""
	Return $envarray [$egloc] [1]
EndFunc

Func UtilEnvPut ($epkey, $epvalue, $epwrite = "")
	$eploc = _ArraySearch ($envarray, $epkey)
	If @error Then
		_ArrayAdd ($envarray, $epkey & "|" & $epvalue)
		$envchanged = "yes"
	Else
		If $envarray [$eploc] [1] <> $epvalue Then
		   $envarray [$eploc] [1] =  $epvalue
		   $envchanged = "yes"
		EndIf
		If $epvalue = "" Then _ArrayDelete ($envarray, $eploc)
	EndIf
	If $epwrite <> "" Then UtilEnvWrite ()
EndFunc

Func UtilEnvDelete ($edkey)
	$edloc = _ArraySearch ($envarray, $edkey)
	If @error Then Return
	_ArrayDelete ($envarray, $edloc)
	UtilEnvWrite ("yes")
EndFunc

Func UtilEnvWrite ($evchanged = $envchanged)
	If $evchanged = "" Then Return
	$ewdata = $envarray [0] [0] & @LF
	For $ewsub = 1 To Ubound ($envarray) - 1
		$ewdata &= $envarray [$ewsub] [0] & "=" & $envarray [$ewsub] [1] & @LF
	Next
	$ewdata = BaseFuncPadRight ($ewdata, 1024, "#")
	$ewhandle = FileOpen ($envfile, 2)
	FileWrite ($ewhandle, $ewdata)
	FileClose ($ewhandle)
EndFunc

Func UtilReboot ()
	$udtext   = "Do You Want To Reboot Your Machine" & @CR & "To The EFI Firmware Setup Screen?"
	$udver    =  MsgBox ($mbwarnyesno, "** Confirm Reboot **", $udtext)
	If $udver <> $IDYES Then Return
	CommonWriteLog ()
	CommonWriteLog ("** Shutdown Started ** Reboot To Firmware")
	CommonEndIt    ("Reboot",  "no", "", "")
	$udstring      = "shutdown /fw /r /t 0"
	$udrc          = ""
	BaseFuncShellWait ($udstring, "", $udrc, "UtilReboot")
	If $udrc <> 0 Then
		MsgBox ($mberrorok, "** EFI Firmware Error **        RC = " & $udrc,  _
			'Your Machine Does Not Support The Reboot To Firmware Command' &  _
			 @CR & @CR & "The Command Was     " & $udstring & @CR & @CR    &  _
			'When You Click "OK" Grub2Win Will Restart')
		Run ($masterexe)
	EndIf
	Exit
EndFunc