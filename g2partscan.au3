#RequireAdmin
#include-once
#include <g2common.au3>

If StringInStr (@ScriptName, "g2partscan") Then
	PartBuildDatabase   ("yes")
	BaseFuncGuiDelete   ($upmessguihandle)
	_ArrayDisplay       ($partitionarray)
	BaseFuncCleanupTemp ("PartScan")
EndIf

Func PartBuildDatabase ($bdcheckcd = "")
	Global $partcountwin  = 0, $partcountlinux = 0, $partcountapple = 0, $partcountother = 0, $partcountbsd = 0
	Global $partcountdisk = 0, $partcountmbr   = 0, $partcountgpt   = 0, $partcountpart  = 0, $partcountefi = 0
	Global $partcountswap = 0, $partcountflash = 0
	$bdscaninit = TimeTickInit ()
	Global $partdrivearray      = PartGetDriveLetters   ()
    Global $partdiskletterarray = PartMatchDiskToLetter ()
	Dim    $partitionarray [0] [$partfieldcount + 1]
	Local  $bdoDiskDrive, $bdoCDRomDrive    ; Dummies for RefCheck
	Local  $bdcolDiskDrives, $bddisksub
	If $partdumppath <> "" Then FileDelete ($partdumppath & "\*.*")
	$partscanbuffer     = DllStructCreate ("byte[4096]")
	$bdcolDiskDrives    = $wmisvc.ExecQuery ("SELECT * FROM Win32_DiskDrive")
	For $bdoDiskDrive In $bdcolDiskDrives
		$bddisknumber   = StringTrimLeft ($bdoDiskDrive.DeviceId, 17)
		$bddrivelabel   = $bdoDiskDrive.Caption
		$bdmediatype    = $bdoDiskDrive.MediaType
		$bddrivesize    = Number ($bdoDiskDrive.Size)
		$bdsectorsize   = Number ($bdoDiskDrive.BytesPerSector)
		$bdmediadesc    = "Disk"
		If $bdmediatype = "Removable Media" Then
			$bdmediadesc     = "Flash"
			$partcountflash += 1
		EndIf
		; MsgBox ($mbontop,"Part", $bddisknumber & @CR & $bdmediatype)
		$bdsub          = _ArrayAdd ($partitionarray, $bddisknumber & "|" & 0)
		$partitionarray [$bdsub] [$pDriveLabel]     = $bddrivelabel
		$partitionarray [$bdsub] [$pDriveSize]      = $bddrivesize
		$partitionarray [$bdsub] [$pDriveMediaDesc] = $bdmediadesc
		$partitionarray [$bdsub] [$pDriveSecSize]   = $bdsectorsize
		$partitionarray [$bdsub] [$pSortPartID]     = StringFormat ("%03i", $bddisknumber) & "-" & BaseFuncPadLeft (0,  4, 0)
		$partitionarray [$bdsub] [$pSortPhysical]   = StringFormat ("%03i", $bddisknumber) & "-" & BaseFuncPadLeft (0, 20, 0)
	Next
	If $bdcheckcd <> "" Then
		$drivecountcd = 0
		$bdcolCDRomDrives   = $wmisvc.ExecQuery ("SELECT * FROM Win32_CDROMDrive")
		For $bdoCDRomDrive In $bdcolCDRomDrives
			$bdcdlabel      = $bdoCDRomDrive.Caption
			$bdcdmediatype  = $bdoCDRomDrive.MediaType
			If $bdcdmediatype = "Unknown" Then $bdcdmediatype = "Optical Drive"
			$bdcdletter     = $bdoCDRomDrive.Drive
			If StringLen    ($bdcdletter) > 2 Then $bdcdletter = ""
			$bdcdvolname    = StringStripWS ($bdoCDRomDrive.VolumeName, 7)
			$bdcdloaded     = $bdoCDRomDrive.MediaLoaded
			$bdcdsize       = Number ($bdoCDRomDrive.Size)
			$bdsub          = _ArrayAdd ($partitionarray, $bdcdletter & "|" & 0)
			$partitionarray [$bdsub] [$pSortPhysical]   = "90" & $drivecountcd
			$partitionarray [$bdsub] [$pDriveLabel]     = $bdcdlabel
			$partitionarray [$bdsub] [$pDriveSize]      = $bdcdsize
			$partitionarray [$bdsub] [$pDriveLetter]    = $bdcdletter
			$partitionarray [$bdsub] [$pPartLabel]      = $bdcdvolname
			$partitionarray [$bdsub] [$pDriveMediaDesc] = $bdcdmediatype
			$partitionarray [$bdsub] [$pDriveLoaded]    = "No Media Inserted"
			If $bdcdloaded = True Then $partitionarray [$bdsub] [$pDriveLoaded] =  "Media Loaded"
			If $bdcdvolname <> "" Then $partitionarray [$bdsub] [$pDriveLoaded] &= " Is " & $bdcdvolname
		Next
	EndIf
    ; _ArrayDisplay ($partitionarray, "PreSort")
	_ArraySort ($partitionarray)
	; _ArrayDisplay ($partitionarray, "AfterSort")
	$partcountdisk = Ubound ($partitionarray)
	For $bddiskno = 0 To $partcountdisk - 1
		$bddisksub          = $bddiskno
		$bdpartfound        = PartDiskProcess ($bddisksub)
		$partcountpart     += $bdpartfound
		$partitionarray [$bddisksub] [$pDrivePartCount] = $bdpartfound
	Next
	_ArraySort ($partitionarray, 0, 0, 0, $pSortPartID)
	$bdpartcount = 0
	For $bdsub = 0 To Ubound ($partitionarray) - 1
		$bdpartcount += 1
		If $partitionarray [$bdsub] [$pPartNumber] = 0 Then $bdpartcount = 0
		$partitionarray [$bdsub] [$pPartNumber] = $bdpartcount
		If $winefiletter <> "" And $partitionarray [$bdsub] [$pDriveLetter] = $winefiletter Then _
			$winefiuuid = $partitionarray [$bdsub] [$pPartUUID]
	Next
	$partscanbuffer = 0
	$scantime = "Disk Scan " & TimeFormatSeconds ($bdscaninit)
	;_Arraydisplay ($partitionarray, $partscantime)
EndFunc

Func PartDiskProcess ($dpdisksub)
	If $partitionarray [$dpdisksub] [$pDriveLoaded] <> "" Then Return
	If StringInStr ($partitionarray  [$dpdisksub] [$pDriveLabel], "Storage Space Device") Then
		PartUnsupported ($dpdisksub, "STR", "Storage Space")
		Return
	EndIf
	$partdisknumber    = $partitionarray  [$dpdisksub] [$pDisknumber]
	$partdiskhandle    = PartDiskOpen ("read")
	If $partdiskhandle = 0 Then Return
	$partsectorsize    = $partitionarray  [$dpdisksub] [$pDriveSecSize]
	$dpsector0         = PartReadRaw (0)                     ; Read first 512 bytes on the drive
	If StringLen ($dpsector0) = 0 Then $partitionarray [$dpdisksub] [$pDriveLetter] = "Ignore"
	PartHexDisplay     ($dpsector0, "disk-" & $partdisknumber & " sector-0")
	$dppartnumber      = 0
	$dpextstartlba     = ""
	For $dpparttable   = 1 To 4
		$dppartentry   = PartGetHexFields ($dpsector0, Dec ("01BE") + (($dpparttable - 1) * 16), 16, "raw")
		If $dppartentry = "error" Or PartCheckZero ($dppartentry) Then ExitLoop    ; No more entries in sector 0
		$dpdescriptor  = StringMid ($dppartentry, 9, 2)
		$dpstartlba    = PartGetHexFields ($dppartentry, Dec ("08"), 4, "littleendian")
        $dpcountlba    = PartGetHexFields ($dppartentry, Dec ("0C"), 4, "littleendian")
		$dpendlba      = $dpstartlba + $dpcountlba
		If ($dpdescriptor = "EE" And $dpstartlba = 1) Then                         ; A typical "GPT protective MBR"
			$dppartnumber = PartGPTProcess ($dpdisksub)
		ElseIf $dpdescriptor = "05" Or $dpdescriptor = "0F" Then                   ; Extended MBR partition
			$partitionarray [$dpdisksub] [$pDriveStyle] = "MBR"
			$dpextstartlba  = $dpstartlba
		Else
			$dppartnumber += 1
			$partitionarray [$dpdisksub] [$pDriveStyle] = "MBR"
			$dpinfloc = PartAddEntry ($dpdisksub, $dppartnumber, $dpstartlba, $dpendlba)   ; Normal MBR Partition
			PartGetFamily ($tCode, $dpdescriptor, $dpinfloc)
			PartGetMisc   ($dpinfloc, $dpdisksub)
		EndIf
	Next
	If $dpextstartlba <> "" Then PartExtendedProcess ($dpextstartlba, $dpdisksub, $dppartnumber)
	_WinAPI_CloseHandle  ($partdiskhandle)
	If $partitionarray [$dpdisksub] [$pDriveStyle] = "MBR" Then	$partcountmbr += 1
	Return $dppartnumber
EndFunc

Func PartExtendedProcess ($epstartlba, $epdisksub, ByRef $eppartnumber)
	$epnextentry   = 0
	$eppartnumber += 1
	For $dummy = 1 To 40
		$epsector = PartReadRaw (($epstartlba + $epnextentry) * $partsectorsize, "", 0, 512, $partsectorsize, "")
		If $epsector    = "" Then Return ""
		$epparttable    = PartGetHexFields ($epsector,    Dec   ("01BE"), 64, "raw")
		$epfsdescriptor = PartGetHexFields ($epparttable, Dec   ("04"),    1, "raw")
		$epstartsector  = $epstartlba + $epnextentry + PartGetHexFields ($epparttable, Dec ("08"), 4, "littleendian")
		$epcountsector  = PartGetHexFields ($epparttable,                              Dec ("0C"), 4, "littleendian")
		$ependsector    = $epstartsector + $epcountsector
		$epinfloc       = PartAddEntry ($epdisksub, $eppartnumber, $epstartsector, $ependsector)
		$partitionarray   [$epinfloc] [$pPartExtended] = "yes"
		PartGetFamily   ($tCode, $epfsdescriptor, $epinfloc, "Extended:")
		PartGetMisc     ($epinfloc, $epdisksub)
	   	If PartCheckZero (PartGetHexFields ($epparttable, Dec ("10"), 16, "raw")) Then exitLoop   ; No more entries
		$eppartnumber  += 1
		PartHexDisplay  ($epparttable, "Extended-" & $partdisknumber & "-" & $eppartnumber)
		$epnextentry    = PartGetHexFields ($epparttable, Dec ("18"),  4,  "littleendian")
	Next
EndFunc

Func PartGPTProcess ($gpdisksub)
	$gpsector1  = PartReadRaw  (512)      ; Read the second 512 bybtes on the drive, which contains the GPT partition header
	If _HexToString (StringMid ($gpsector1, 1, 16)) <> "EFI PART" Then
		MsgBox ($mbontop, "** Error **", "Could not find the GPT signature on disk " & $partdisknumber & @CR & @CR & $gpsector1)
		Return
	EndIf
	$partcountgpt += 1
	PartHexDisplay ($gpsector1, "disk-" & $partdisknumber & " sector-1")
    $gpnullcount  = 0
	$gppartnumber = 0
	$partitionarray [$gpdisksub] [$pDriveStyle] = "GPT"
	For $gplba    = 2 To 33
		$gpsectorpart   = PartReadRaw ("", $gplba)
		For $gplbaslot = 1 To 4
			$gpentry    = PartGetHexFields ($gpsectorpart, ($gplbaslot - 1) * 128, 128, "raw")
			$gptypeguid = PartGetHexFields ($gpentry,                           0,  16, "raw")
			If PartCheckZero ($gptypeguid) Then
				$gpnullcount += 1
				If $gpnullcount > 5 Then ExitLoop 2
				ContinueLoop
			EndIf
			$gpnullcount  =  0
			$gppartnumber += 1
			$gptypeguid   = PartMixedEndianGUID ($gptypeguid)
			$gpstartlba   = PartGetHexFields    ($gpentry, Dec ("20"), 8, "littleendian")
			$gpendlba     = PartGetHexFields    ($gpentry, Dec ("28"), 8, "littleendian")
			$gpinfloc     = PartAddEntry ($gpdisksub, $gppartnumber, $gpstartlba, $gpendlba)
			PartGetFamily ($tGUID, $gptypeguid, $gpinfloc)
			PartGetMisc   ($gpinfloc, $gpdisksub, $gptypeguid)
		Next
	Next
	Return $gppartnumber
EndFunc

Func PartAddEntry ($aedisksub, $aepartnumber, $aestartlba, $aeendlba)
	$aeloc = _ArrayAdd ($partitionarray, "")
	$partitionarray [$aeloc] [$pDiskNumber] = $partdisknumber
	$partitionarray [$aeloc] [$pPartNumber] = $aepartnumber
	$partitionarray [$aeloc] [$pStartLBA]   = $aestartlba
	$partitionarray [$aeloc] [$pPartOffset] = $aestartlba * $partsectorsize
	$partitionarray [$aeloc] [$pEndLBA]     = $aeendlba
	$partitionarray [$aeloc] [$pPartSize]   = ($aeendlba - $aestartlba + 1) * $partsectorsize
	$partitionarray [$aedisksub] [$pDriveused] += $partitionarray [$aeloc] [$pPartSize]
	$partitionarray [$aeloc] [$pSortPartID]   = StringFormat ("%03i", $partdisknumber) & "-" & _
		BaseFuncPadLeft ($aepartnumber, 4, 0)
	$partitionarray [$aeloc] [$pSortPhysical] = StringFormat ("%03i", $partdisknumber) & "-" & _
		BaseFuncPadLeft ($partitionarray [$aeloc] [$pPartOffset], 20, 0)
	Return $aeloc
EndFunc

Func PartGetMisc ($gmloc, $gmdisksub, $gmtypeguid = "")
	$gmfamily     = $partitionarray [$gmloc] [$pPartFamily]
	$gmpartnumber = $partitionarray [$gmloc] [$pPartNumber]
	$gmlbanumber  = $partitionarray [$gmloc] [$pStartLBA]
	$partitionarray [$gmloc] [$pDriveMediaDesc] = $partitionarray [$gmdisksub] [$pDriveMediaDesc]
	Select
		Case $gmfamily = "Linux"
			PartProcessLinux   ($gmloc, $gmpartnumber, $gmlbanumber)
		Case $gmfamily = "EFI" Or $gmfamily = "Windows" Or $gmfamily = "System"
			PartProcessWindows ($gmloc, $gmpartnumber, $gmlbanumber)
		Case StringInStr ($gmtypeguid,"-11aa-aa11-")
			 $partitionarray [$gmloc] [$pPartFamily] = "Apple"
		Case $gmtypeguid = $dynmetaguid
			 PartUnsupported ($partitionarray [$gmloc] [$pDisknumber], "DYN", "Dynamic")
		EndSelect
	For $gmsub = 0 To Ubound ($partdiskletterarray) - 1
		If $partdiskletterarray [$gmsub] [1] <> $partdisknumber Then ContinueLoop
		If $partdiskletterarray [$gmsub] [2] <> $gmpartnumber   Then ContinueLoop
		$gmdriveletter = $partdiskletterarray [$gmsub] [0]
		$gmdrivepath   = $gmdriveletter & "\"
		$partitionarray [$gmloc] [$pDriveLetter] = $gmdriveletter
		$gmlabel = DriveGetLabel ($gmdrivepath)
		If Not @error Then $partitionarray [$gmloc] [$pPartLabel] = $gmlabel
		If $partitionarray [$gmloc] [$pPartFileSystem] = "" Then $partitionarray [$gmloc] [$pPartFileSystem] = DriveGetFileSystem ($gmdrivepath)
		$partitionarray [$gmloc] [$pPartFreeSpace] = DriveSpaceFree ($gmdrivepath) * $mega
	Next
	If StringLeft ($partitionarray [$gmloc] [$pPartLabel], 7) = "NO NAME" Then $partitionarray [$gmloc] [$pPartLabel] = ""
	If Not StringIsASCII ($partitionarray [$gmloc] [$pPartLabel])         Then $partitionarray [$gmloc] [$pPartLabel] = ""
	$partitionarray [$gmloc] [$pPartLabel] = StringStripWS ($partitionarray [$gmloc] [$pPartLabel], 7)
	If $partitionarray [$gmloc] [$pEFIFlag] = $efivalid And Not StringInStr ($partitionarray [$gmloc] [$pPartFileSystem], "FAT") Then _
		$partitionarray [$gmloc] [$pEFIFlag] = $efiignorefs
	If $partitionarray [$gmloc] [$pDriveMediaDesc] = "Flash" Then _
		$partitionarray [$gmloc] [$pEFIFlag]       = PartEFIFlash ($gmloc)
	If $partcountefi > 5 And $gmfamily = "EFI" Then $partitionarray [$gmloc] [$pEFIFlag] = $efiignorelimit
EndFunc

Func PartUnsupported ($pudisksub, $pustyle,$pumsg)
	$partitionarray [$pudisksub] [$pDriveStyle] = "*" & $pustyle & "*"
	$puerrormsg1   = "****  Disk Drive " & $partitionarray [$pudisksub] [$pDiskNumber] & " is a " & $pumsg & " Disk" & @CR
	$puerrormsg2   = "****  " & $pumsg & " Disks are not supported by Grub2Win"                                      & @CR
	CommonWriteLog  ($puerrormsg1 & $puerrormsg2)
EndFunc

Func PartEFIFlash ($efsub)
	$efletter = $partitionarray [$efsub] [$pDriveLetter]
	If Not FileExists ($efletter & "\efi") Then Return ""
	If CommonParms ("Advanced") Then Return $efivalid
	Return $efiignoremedia
EndFunc

Func PartProcessWindows ($pwloc, $pwpartnumber, $pwlbanumber)
	$pwsector     = PartReadRaw ("", $pwlbanumber)
	If PartGetHexFields ($pwsector, 3, 4, "char") = "NTFS" Then
		$partitionarray [$pwloc] [$pPartFileSystem] = "NTFS"
	Else
		$pwfat32 = PartGetHexFields ($pwsector, Dec ("52"), 5, "char")
		$pwfatxx = PartGetHexFields ($pwsector, Dec ("36"), 5, "char")
		Select
			Case $pwfat32 = "FAT32"
				$partitionarray [$pwloc] [$pPartFileSystem] = "FAT32"
				$pwsernoraw                            = PartGetHexFields    ($pwsector, Dec ("43"), 4,  "raw")
				$partitionarray [$pwloc] [$pPartUUID ] = PartMixedEndianGUID ($pwsernoraw)
				$partitionarray [$pwloc] [$pPartLabel] = PartGetHexFields    ($pwsector, Dec ("47"), 11, "char")
			Case StringLeft ($pwfatxx, 3) = "FAT"
				$partitionarray [$pwloc] [$pPartFileSystem] = $pwfatxx
				$pwsernoraw                            = PartGetHexFields    ($pwsector, Dec ("27"), 4,  "raw")
				$partitionarray [$pwloc] [$pPartUUID ] = PartMixedEndianGUID ($pwsernoraw)
				$partitionarray [$pwloc] [$pPartLabel] = PartGetHexFields    ($pwsector, Dec ("2B"), 11, "char")
			Case Else
				PartProcessLinux ($pwloc, $pwpartnumber, $pwlbanumber)
				$partitionarray [$pwloc] [$pPartType]          = "Linux Filesystem"
				$partitionarray [$pwloc] [$pPartFamily]        = "Linux"
			    If $partitionarray [$pwloc] [$pPartFileSystem] = "OTHER" Then
				   $partitionarray [$pwloc] [$pPartType]       = $partnotformatted
				   $partitionarray [$pwloc] [$pPartFamily]     = "Misc"
				EndIf
			    Return
		EndSelect
	EndIf
	If $partdisknumber = $winbootdisk And $pwpartnumber = $winbootpart Then _
		$partitionarray [$pwloc] [$pPartType] = "** Windows Boot **"
	PartHexDisplay ($pwsector, "disk-" & $partdisknumber & " part-" & $pwpartnumber & "  windata")
EndFunc

Func PartProcessLinux ($plloc, $plpartnumber, $pllbanumber)
	$plsector    = PartReadRaw ("", $pllbanumber, $kilo)	                               ; extx superblock is offset 1 KB
	$plextid     = PartGetHexFields ($plsector, Dec ("38"), 2, "raw")
	If $plextid  = "53EF" Then
		$pltotblocks    =    PartGetHexFields ($plsector, Dec ("04"),  4, "littleendian")
		$plfreeblocks   =    PartGetHexFields ($plsector, Dec ("0C"),  4, "littleendian")
		$plfeature         = PartGetHexFields ($plsector, Dec ("5C"),  4, "littleendian")  ; extx features block
		$plfeaturereadonly = PartGetHexFields ($plsector, Dec ("60"),  4, "littleendian")  ; extx read only comp. block
		Select
			Case BitAnd ($plfeaturereadonly, 0x40)                     ; Test if the extx filesystem supports extents
				$partitionarray [$plloc] [$pPartFileSystem] = "EXT4"
			Case BitAnd ($plfeature,         0x04)                     ; Test if the extx filesystem supports journaling
				$partitionarray [$plloc] [$pPartFileSystem] = "EXT3"
			Case Else
				$partitionarray [$plloc] [$pPartFileSystem] = "EXT2"
		EndSelect
		$partitionarray [$plloc] [$pPartUUID]       = PartFormatGUID (PartGetHexFields ($plsector, Dec ("68"), 16, "raw"))
		$partitionarray [$plloc] [$pPartLabel]      = StringStripWS  (PartGetHexFields ($plsector, Dec ("78"), 16, "char"), 7)
		$partitionarray [$plloc] [$pPartFreeSpace]  = Int (($plfreeblocks / $pltotblocks) * $partitionarray [$plloc] [$pPartSize])
		PartHexDisplay ($plsector, "disk-" & $partdisknumber & " part-" & $plpartnumber & "  extxdata")
	Else
		$plsectorbtrfs = PartReadRaw  ("", $pllbanumber,   64 * $kilo)              ; btrfs superblock is offset 64 KB
		$plbtrfsid     = PartGetHexFields ($plsectorbtrfs, Dec ("40"), 7, "char")   ; Check for btrfs
		If $plbtrfsid  = "_BHRfS_" Then
			$partitionarray [$plloc] [$pPartUUID]       = PartFormatGUID (PartGetHexFields ($plsectorbtrfs, Dec ("20"),   16, "raw"))
			$partitionarray [$plloc] [$pPartLabel]      = StringStripWS  (PartGetHexFields ($plsectorbtrfs, Dec ("012b"), 16, "char"), 7)
			$partitionarray [$plloc] [$pPartFileSystem] = "BTRFS"
			$partbytestot   = (PartGetHexFields ($plsectorbtrfs, Dec ("70"), 8, "littleendian"))
			$partbytesused  = (PartGetHexFields ($plsectorbtrfs, Dec ("78"), 8, "littleendian"))
			$partitionarray [$plloc] [$pPartFreeSpace] = $partbytestot - $partbytesused
			PartHexDisplay ($plsectorbtrfs, "disk-" & $partdisknumber & " part-" & $plpartnumber & "  btrfsdata")
		Else
			If $partitionarray [$plloc] [$pPartFileSystem] = "" Then $partitionarray [$plloc] [$pPartFileSystem] = "OTHER"
			PartHexDisplay ($plsector,  "disk-" & $partdisknumber & " part-" & $plpartnumber & "  other")
		EndIf
	EndIf
EndFunc

Func PartReadRaw ($rrbytenumber = "", $rrsectornumber = 0, $rrbyteoffset = 0, $rrbytestoread = 4096, $rrsectorsize = $partsectorsize, $rrshowerror = "yes")
	$rrerrormsg   = ""
	$rrdebuginfo  = ""
	$rremptymsg   = "****  This May Be Caused By An Empty SD Card Reader"                                   & @CR
	$rremptymsg  &= "****  Disk Drive " & $partdisknumber & " Will Be Ignored"                              & @CR & @CR
	$rrbyteloc    = $rrbytenumber
	$rrbytesread  = 0
	If $rrbytenumber = "" Then $rrbyteloc = $rrsectornumber * $rrsectorsize
	$rrbyteloc   += $rrbyteoffset
	If $rrbyteloc <> 0 Then
		$rrpointrc = _WinAPI_SetFilePointerEx ($partdiskhandle, $rrbyteloc, $FILE_BEGIN)
		If $rrpointrc = 0 Then $rrerrormsg = "****  Location Pointer Error On Disk " & $partdisknumber & @CR & @CR
	EndIf
	If $rrerrormsg = "" Then
		$rrread    = _WinAPI_ReadFile ($partdiskhandle, DllStructGetPtr ($partscanbuffer), $rrbytestoread, $rrbytesread)
		If $rrread    = 0 Then $rrerrormsg = "****  Disk Read Error  ****"                                   & @CR & @CR
	EndIf
	If $rrerrormsg = "" Then Return StringTrimLeft (DllStructGetData ($partscanbuffer, 1), 2)
	If $rrshowerror <> "" Then
		$rrlasterror  = _WinAPI_GetLastError () & "    " & _WinAPI_GetLastErrorMessage ()
		$rrerrormsg  &= "****  This Disk Drive Will Be Ignored"                                               & @CR
		$rrerrormsg  &= "****  May Be Caused By An Empty SD Card Reader"                                      & @CR
		If StringInStr ($rrlasterror, "not ready") Then
			$rrerrormsg  = "****  Disk Drive " & $partdisknumber & " Is Not Ready"                            & @CR
			$rrerrormsg &= $rremptymsg
		Else
			$rrerrormsg   = $rremptymsg
			$rrdebuginfo  = "****  Code   = "      & $rrlasterror                                             & @CR & @CR
			$rrdebuginfo &= "****  DiskHandle  = " & $partdiskhandle & "   ByteLoc    = " & $rrbyteloc        & @CR
			$rrdebuginfo &= "****  SectorNumb  = " & $rrsectornumber & "   ByteOffset = " & $rrbyteoffset     & @CR
			$rrdebuginfo &= "****  SectorSize  = " & $rrsectorsize   & "   ByteNumb   = " & $rrbytenumber     & @CR
			$rrdebuginfo &= "****  BytesToRead = " & $rrbytestoread  & "   BytesRead  = " & $rrbytesread
		EndIf
		CommonWriteLog     (@CR & $rrerrormsg & $rrdebuginfo)
		If Not CommonParms ($parmquiet) And $rrdebuginfo <> "" Then _
			MsgBox ($mbwarnok, "** Disk Error **", $rrerrormsg & @CR & $rrdebuginfo)
	EndIf
	Return ""
EndFunc

Func PartDiskOpen ($dotype = "read")
	$domode       = 2
	If $dotype    = "write" Then $domode = 4
	$dodiskobject = "\\.\PhysicalDrive" & $partdisknumber
	Return        _WinAPI_CreateFile ($dodiskobject, 2, $domode, 7)
EndFunc

Func PartMixedEndianGUID ($meginput)  ; Mixed endian format
	$megoutput =  PartSwapEndian (StringMid ($meginput,  1,  8))
	If StringLen ($meginput) = 8 Then Return PartFormatVolser ($megoutput)
	$megoutput &= PartSwapEndian (StringMid ($meginput,  9,  4))
	$megoutput &= PartSwapEndian (StringMid ($meginput, 13,  4))
	$megoutput &=                 StringMid ($meginput, 17,  4)
	$megoutput &=                 StringMid ($meginput, 21, 12)
	Return PartFormatGUID ($megoutput)
EndFunc

Func PartFormatGUID ($fginput)
	$fgoutput  = StringMid ($fginput,  1,  8) & "-"
	$fgoutput &= StringMid ($fginput,  9,  4) & "-"
	$fgoutput &= StringMid ($fginput, 13,  4) & "-"
	$fgoutput &= StringMid ($fginput, 17,  4) & "-"
	$fgoutput &= StringMid ($fginput, 21, 12)
	Return StringUpper ($fgoutput)
EndFunc

Func PartFormatVolSer ($fvinput)
	$fvoutput  = StringLeft  ($fvinput, 4) & "-"
	$fvoutput &= StringRight ($fvinput, 4)
	Return StringUpper ($fvoutput)
EndFunc

Func PartSwapEndian ($sehex)
	Return StringMid (Binary (Dec ($sehex, 2)), 3, StringLen ($sehex))
EndFunc

Func PartGetFamily ($gfsearchcol, $gfcodein, $gfpartloc, $gfextended = "")
	$gfcode = $gfcodein
	If $gfcode = "0C" Or $gfcode = "0B" Or $gfcode = "0E" Or $gfcode = "04" Or $gfcode = "06" Then $gfcode = "07"
	$gfloc = _ArraySearch ($parttypearray, $gfcode, 0, 0, 0, 0, 0, $gfsearchcol)
	If @error Then
		$gfloc = 0
		$partitionarray [$gfpartloc] [$pPartUUID]   = "**  Unknown Partition Type - Code " & $gfcodein & " **"
		If StringInStr ($gfcodein, "-11aa-aa11-") Then $gfloc = 1      ; Apple Misc
   EndIf
	$partitionarray [$gfpartloc] [$pPartType]       = $gfextended & $parttypearray [$gfloc] [$tDesc]
	$partitionarray [$gfpartloc] [$pPartFamily]     = $parttypearray               [$gfloc] [$tFamily]
	$gffamily                                       = $parttypearray               [$gfloc] [$tFamily]
	$partitionarray [$gfpartloc] [$pPartFileSystem] = $parttypearray               [$gfloc] [$tFileSystem]
	$partitionarray [$gfpartloc] [$pPartTypeCode]   = $gfcode
	Select
		Case $gffamily = "Linux"
			$partcountlinux += 1
		Case $gffamily = "Windows" Or $gffamily = "System" Or $gffamily = "Reserved"
			$partcountwin   += 1
		Case $gffamily = "Apple"
			$partcountapple += 1
		Case $gffamily = "EFI"
			$partitionarray [$gfpartloc] [$pEFIFlag] = $efivalid
			$partcountefi   += 1
		Case $gffamily = "BSD"
			$partcountbsd   += 1
		Case $gffamily = "Swap"
			$partcountswap  += 1
		Case Else
			$partcountother += 1
	EndSelect
EndFunc

Func PartGetHexFields (ByRef $ghfblock, $ghfdecoffset, $ghfdeclength, $ghftype)
	If $ghfdecoffset + $ghfdeclength > StringLen ($ghfblock) Then Return "Error"
	$ghfdata = StringMid ($ghfblock, ($ghfdecoffset * 2) + 1, $ghfdeclength * 2)
	If $ghftype = "raw"          Then Return                      $ghfdata
	If $ghftype = "char"         Then Return _HexToString        ($ghfdata)
	If $ghftype = "littleendian" Then Return Dec (PartSwapEndian ($ghfdata), 2)
EndFunc

Func PartCheckZero ($czinput)
	If StringReplace ($czinput, "0", "") = "" Then Return 1
EndFunc

Func PartGetDriveLetters ()
	For $gdltry = 1 To 11
		$gdldrivearray = DriveGetDrive ("ALL")
		If Not @error Then ExitLoop
		If $gdltry > 10 Then Dim $gdldrivearray [0]
		Sleep (500)
	Next
	Return $gdldrivearray
EndFunc

Func PartMatchDiskToLetter ()
	Dim $mdldiskarray [0] [3]
	For $mdlsub = 1 To Ubound ($partdrivearray) - 1
		$mdlnumbers = _WinAPI_GetDriveNumber ($partdrivearray [$mdlsub])
		If @error Or $mdlnumbers [0] <> "7" Then ContinueLoop
		$mdldriveletter = BaseFuncCapIt ($partdrivearray [$mdlsub])
		$mdlloc = _ArrayAdd($mdldiskarray, $mdldriveletter & "|" & $mdlnumbers [1] & "|" & $mdlnumbers [2])
		If $mdldriveletter = $windowsdrive Then
			$winbootdisk = $mdldiskarray [$mdlloc] [1]
			$winbootpart = $mdldiskarray [$mdlloc] [2]
		EndIf
	Next
	Return $mdldiskarray
EndFunc

Func PartHexDisplay ($hdinput, $hdfile)      ;Diagnostic routine to print a sector
	$hdcount  = 0
	Dim $hdarray [1]
	_ArrayAdd ($hdarray, $parthexheader & @CR)
	$hdinput  = StringLeft ($hdinput, 1024)
	While $hdcount  < StringLen ($hdinput)
		$hdhexfield = StringMid ($hdinput, $hdcount + 1, 32)
		$hdcharout = ""
		$hdhexout  = ""
		For $hdloc = 0 To 15
			$hdhexchar = StringMid ($hdhexfield, ($hdloc * 2) + 1, 2)
			$hdchar    = _HexToString ($hdhexchar)
			If $hdhexchar < "20" Or $hdhexchar > "7F" Then $hdchar = "."
			$hdcharout &= $hdchar
			$hdhexout  &= $hdhexchar & " "
		Next
		$hdline = "   " & BaseFuncPadLeft  ($hdcount / 2, 3) & "     " & BaseFuncPadRight (Hex (Int ($hdcount / 2)), 14) & _
			      BaseFuncPadright ($hdhexout, 54) & $hdcharout
		$hdcount += 32
		_ArrayAdd ($hdarray, $hdline, 0, @CR)
	Wend
	_ArrayAdd ($hdarray, @CR & $parthexheader)
	If FileExists ($partdumppath) Then BaseFuncArrayWrite ($partdumppath & "\" & $hdfile & ".txt", $hdarray)
EndFunc
