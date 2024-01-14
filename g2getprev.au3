#include-once
#include  <g2common.au3>

Func GetPrevConfig ()
	ThemeCreateHold ()
	Dim $selectionarray [1] [$selectionfieldcount + 1]
	Dim $userarray      [1]
	Dim $autoarray      [1]
	Dim $configarray    [1]
	EditPanelStackArray ()
	If Not FileExists   ($configfile) Then FileCopy ($sourcepath & "\basic.cfg", $configfile, 1)
	$gfxmode            = UtilEnvGet ($envgfxmode)
	GetPrevConfigUpdate     ($configfile)
	If $graphset        = "" Then $graphset   = $autostring
	If $timeoutgrub      = "" Then $timeoutgrub = 30
	While 1
		If UBound ($userarray) = 1 Then
			$userarray = BaseFuncArrayRead ($sourcepath & $templateuser, "GetPrevConfig")
			ExitLoop
		EndIf
		$gpcmenu = StringStripWS($userarray[0], 8)
		If StringLen($gpcmenu) <> 0 Then ExitLoop
		_ArrayDelete($userarray, 0)
	WEnd
	If  $selectionarray [0] [$sOSType] = "" Then
		CommonArraySetDefaults (0)
		$selectionarray [0] [$sOSType]     = "windows"
		$selectionarray [0] [$sClass]      = "windows"
		$selectionarray [0] [$sFamily]     = "windows"
		$selectionarray [0] [$sLoadBy]     = $modewinauto
		$selectionarray [0] [$sDefaultOS]  = "DefaultOS"
		$selectionarray [0] [$sLoadBy]     = ""
		$selectionarray [0] [$sIcon]       = "icon-windows"
		$selectionarray [0] [$sHotKey]     = "w"
		$gpcparmloc = CommonGetOSParms (0)
		$selectionarray [0] [$sEntryTitle] = $osparmarray [$gpcparmloc] [$pTitle]
	EndIf
	CommonSelArraySync ()
	If $firmwaremode <> "EFI" Then GetPrevWinBIOS ()
	If Ubound ($selectionarray) < 1 Then Dim $selectionarray [1] [$selectionfieldcount + 1]
	$editmenuerrors = CommonSelectVerify ()
	If Not CommonParms ("Setup") And FileExists ($usersectionexp) Then
		$pcrc = MsgBox ($mbquestyesno, "** Expanded User File Section Found **", "Do You Want To Use The Expanded User Section File?")
		If $pcrc = $IDYES Then	$usersectionfile = $usersectionexp
	EndIf
	If StringStripWS (FileRead ($usersectionfile), 8) <> "" Then
		Dim $userarray  [1]
		GetPrevConfigUpdate ($usersectionfile, $autohighsub + 1, "on")
	Else
		CustomUserSectionArray ()
		BaseFuncArrayWrite ($usersectionfile, $userarray, 2, "", 0)
	EndIf
	;_ArrayDisplay ($userarray)
	FileCopy ($usersectionfile, $usersectionorig, 1)
	;_ArrayDisplay ($selectionarray, "Prev")
EndFunc

Func GetPrevCleanRecord (ByRef $crrecord, $crremovehash = "")
	$crrecord        = StringReplace ($crrecord, Chr (9), "        ")
	$crrecord        = StringStripWS ($crrecord, 2)
	If $crremovehash = "" Then Return StringStripWS ($crrecord, 7)
	$crhashpos       = StringInStr ($crrecord, "#")
	If $crhashpos > 0 Then $crrecord = StringTrimRight ($crrecord, StringLen ($crrecord) - $crhashpos + 1)
	Return StringStripWS ($crrecord, 7)
EndFunc

Func GetPrevConfigUpdate ($cufile, $cuseldim = 0, $cuuserstatus = "off")
	$cumenusub        = 0
	$cuautostatus     = "off"
	$cuinputarray     = GetPrevInputArray ($cufile)
	For $curecsub = 0 To Ubound ($cuinputarray) - 1
		$curecord = $cuinputarray [$curecsub]
		$curecstripped = GetPrevCleanRecord ($curecord)
		If StringInStr($curecord, "end-grub2win-auto-menu-section") Then
			$cuautostatus = "off"
		EndIf
		If StringInStr($curecord, "start") And StringInStr($curecord, "user-section") Then
			$curecord = $usersectionstart
			$cuautostatus     = "off"
			$cuuserstatus     = "on"
		EndIf
		If StringInStr($curecord, "end") And StringInStr($curecord, "user-section") Then
			$curecord = $usersectionend
			$cuuserstatus = "off"
			_ArrayAdd($userarray, $curecord)
		EndIf
		Select
			Case StringLeft ($curecstripped, 1) = "#"   ; Skip Comments
			Case GetPrevCheckMenu ($curecord) <> ""
				If $cuuserstatus  = "off" Then $cuautostatus = "on"
				ReDim $selectionarray [$cuseldim + 1] [$selectionfieldcount + 1]
				$cumenusub = Ubound  ($selectionarray) - 1
				$cuseldim += 1
				If $cuautostatus = "on" Then
					$selectionarray [$cumenusub] [$sLoadBy]   = ""
					$selectionarray [$cumenusub] [$sAutoUser] = "auto"
					$selectionarray [$cumenusub] [$sBootParm] = $nullparm
				Else
					$selectionarray [$cumenusub] [$sAutoUser] = "user"
				EndIf
				If CommonPrevParse ($curecord, "submenu", 1) Then $selectionarray [$cumenusub] [$sOSType] = "submenu"
				$cuhotloc = StringInStr ($parseresult1, "Hotkey=")
				If $cuhotloc <> 0 Then $parseresult1 = StringLeft ($parseresult1, $cuhotloc - 1)
				$selectionarray [$cumenusub] [$sEntryTitle] = StringStripWS ($parseresult1, 3)
				If $cumenusub = $defaultos Then $selectionarray [$cumenusub] [$sDefaultOS] = "DefaultOS"
				If StringInStr ($curecord, "--")  Then GetPrevParseParms  ($curecord, $cumenusub)
				CommonArraySetDefaults ($cumenusub)
			Case StringLeft ($curecstripped, 17) = $customfilestring
				$selectionarray [$cumenusub] [$sCustomName] = StringTrimLeft ($curecstripped, 17)
				ContinueLoop
			Case CommonPrevParse ($curecord, "set", 1)
				Select
					Case CommonParseStrip ($parseresult1, "timeout=") And $cuautostatus = "off" And $cuuserstatus = "off"
						$timeoutgrub   = $parmstripped
						$timegrubenabled = "yes"
					Case CommonParseStrip ($parseresult1, "default=")
						$defaultos = $parmstripped
					Case CommonParseStrip ($parseresult1, "grub2win_efilevel=")
						$grubcfgefilevel = $parmstripped
					Case CommonParseStrip ($parseresult1, "grub2win_lastbooted=")
						$defaultlastbooted = $parmstripped
					Case CommonParseStrip ($parseresult1, "gfxmode=")
						If $gfxmode <> "" Then $parmstripped = $gfxmode
						$graphset = StringReplace ($parmstripped, ",auto", "")
						If Not StringInStr ($graphstring,  $graphset)          Then $graphstring &= "|" & $graphset
						If     StringInStr ($parmstripped, $graphconfigauto)   Then $graphset     = $autostring
						If Not StringInStr ($graphstring,  $graphset)          Then $graphset     = $autostring
					Case CommonParseStrip ($parseresult1, "grub2win_langauto=")
						If $langfound = "yes" Then $langauto = $parmstripped
					Case CommonParseStrip ($parseresult1, "lang=")
						$langselectedcode = $parmstripped
						$langfullselector = LangGetFullSelector ($langselectedcode)
					Case $cuautostatus = "off" And $cuuserstatus = "off"
					Case $cumenusub < 0
					Case CommonParseStrip ($parseresult1, "gfxpayload=")
						$selectionarray [$cumenusub] [$sGraphMode] = $parmstripped
					Case CommonParseStrip ($parseresult1, "reviewpause=")
						$selectionarray [$cumenusub] [$sReviewPause] = $parmstripped
					Case $selectionarray [$cumenusub] [$sOSType] = "submenu"
					Case CommonParseStrip ($parseresult1, "kerneldir=")
						If $selectionarray [$cumenusub] [$sOSType] = "android" Then $selectionarray [$cumenusub] [$sLoadBy] = $modeandroidfile
						If $selectionarray [$cumenusub] [$sOSType] = "phoenix" Then $selectionarray [$cumenusub] [$sLoadBy] = $modephoenixfile
						$selectionarray [$cumenusub] [$sRootSearchArg] = $parmstripped & "/kernel"
					Case CommonParseStrip ($parseresult1, "kernelfile=")
						$cukernel     = StringTrimLeft ($parmstripped, 11)
						$cuandpath    = StringReplace  ($selectionarray [$cumenusub] [$sRootSearchArg], "/kernel", "/" & $cukernel)
						$selectionarray [$cumenusub]   [$sRootSearchArg] = $cuandpath
						If StringInStr ($curecord, $fileloaddisable) Then $selectionarray [$cumenusub] [$sFileLoadCheck] = $fileloaddisable
					Case CommonParseStrip ($parseresult1, "root=")
						$parmstripped = StringReplace ($parmstripped, "(hd", "")
						$parmstripped = StringReplace ($parmstripped, ")", "")
						$parmstripped = StringReplace ($parmstripped, "gpt", "")
						$parmstripped = StringReplace ($parmstripped, "msdos", "")
						$cudrivepart = StringSplit($parmstripped, ",")
						If @error Then
							If StringIsDigit ($parmstripped) Then _
								$selectionarray [$cumenusub] [$sChainDrive] = $parmstripped
						Else
							$selectionarray [$cumenusub] [$sLoadBy]   = $modehardaddress
							$selectionarray [$cumenusub] [$sRootDisk] = CommonGetDisk (CommonConvDisk ($cudrivepart [1], $cudrivepart [2]), "Disk")
						EndIf
					Case CommonParseStrip ($parseresult1, "boot=")
						$parmstripped = StringReplace ($parmstripped, "(hd", "")
						$parmstripped = StringReplace ($parmstripped, ")", "")
						$parmstripped = StringReplace ($parmstripped, "gpt", "")
						$parmstripped = StringReplace ($parmstripped, "msdos", "")
						$cudrivepart = StringSplit($parmstripped, ",")
						If @error Then
							If StringIsDigit ($parmstripped) Then _
								$selectionarray [$cumenusub] [$sBootDisk] = CommonConvDisk ($parmstripped)
						Else
							$selectionarray [$cumenusub] [$sLoadBy]   = $modehardaddress
							$selectionarray [$cumenusub] [$sBootDisk] = CommonGetDisk (CommonConvDisk ($cudrivepart [1], $cudrivepart [2]), "Disk")
						EndIf
						If $editlinpartcount > 1 Then $selectionarray [$cumenusub] [$sLayout] = $layoutboth
					Case CommonParseStrip ($parseresult1, "chainbootmgr=")
						$selectionarray [$cumenusub] [$sRootSearchArg] = $parmstripped
						If StringInStr ($curecord, $fileloaddisable) Then $selectionarray [$cumenusub] [$sFileLoadCheck] = $fileloaddisable
					Case CommonParseStrip ($parseresult1, "rootlabel=")
						$selectionarray [$cumenusub] [$sRootDisk] = CommonGetDisk ($parmstripped, "Label")
					Case CommonParseStrip ($parseresult1, "rootuuid=")
						$selectionarray [$cumenusub] [$sRootDisk] = CommonGetDisk ($parmstripped, "UUID")
					Case CommonParseStrip ($parseresult1, "bootlabel=")
						$selectionarray [$cumenusub] [$sBootDisk] = CommonGetDisk ($parmstripped, "Label")
					Case CommonParseStrip ($parseresult1, "bootuuid=")
						$selectionarray [$cumenusub] [$sBootDisk] = CommonGetDisk ($parmstripped, "UUID")
					Case CommonParseStrip ($parseresult1, "partlabel=")
						$selectionarray [$cumenusub] [$sLoadBy] = $modepartlabel
						$selectionarray [$cumenusub] [$sRootDisk] = CommonGetDisk ($parmstripped, "Label")
					Case CommonParseStrip ($parseresult1, "partuuid=")
						$selectionarray [$cumenusub] [$sLoadBy] = $modepartuuid
						$selectionarray [$cumenusub] [$sRootDisk] = CommonGetDisk ($parmstripped, "UUID")
				EndSelect
			Case $cuautostatus = "off" And $cuuserstatus = "off"
			Case CommonPrevParse ($curecord, "getpartition", 1)
				If $parseresult1 = "label"        Then $selectionarray [$cumenusub] [$sLoadBy] = $modepartlabel
				If $parseresult1 = "uuid"         Then $selectionarray [$cumenusub] [$sLoadBy] = $modepartuuid
				If $selectionarray [$cumenusub] [$sOSType] = "android"   Then $selectionarray [$cumenusub] [$sLoadBy] = $modeandroidfile
				If $selectionarray [$cumenusub] [$sOSType] = "phoenix"   Then $selectionarray [$cumenusub] [$sLoadBy] = $modephoenixfile
				If $selectionarray [$cumenusub] [$sClass]  = "chainfile" Then $selectionarray [$cumenusub] [$sLoadBy] = $modechainfile
				If $selectionarray [$cumenusub] [$sFamily] = "standfunc" Then
					$selectionarray [$cumenusub] [$sLoadBy]        = "No"
					$selectionarray [$cumenusub] [$sLayout]        = ""
					$selectionarray [$cumenusub] [$sRootSearchArg] = ""
				EndIf
				If $parseresult3 = "boot" And $editlinpartcount > 1 Then $selectionarray [$cumenusub] [$sLayout] = $layoutboth
			Case StringInStr ($curecord, "set efibootmgr")
				$selectionarray [$cumenusub] [$sLoadBy] = $modewinauto
			Case StringInStr ($curecord, "/bootmgr") Or StringInStr ($curecord, "/ntldr")
				$selectionarray [$cumenusub] [$sLoadBy] = $modewinauto
				$selectionarray [$cumenusub] [$sRootDisk] = ""
			Case CommonPrevParse ($curecord, "chainloader", 1) And Not StringInStr ($curecord, $bootmanstring)
				$selectionarray [$cumenusub] [$sLoadBy] = $modechaindisk
				$gdcchainparse = StringSplit ($selectionarray [$cumenusub] [$sRootDisk], " ")
				$selectionarray [$cumenusub] [$sRootDisk] = ""
				If Not @error And $gdcchainparse [1] <> "Disk" Then $selectionarray [$cumenusub] [$sChainDrive] = $gdcchainparse [2]
			Case CommonPrevParse ($curecord, "linux", 1)
				$cuparm = GetPrevBootParm ()
				$selectionarray [$cumenusub] [$sBootParm]   = $cuparm
				$selectionarray [$cumenusub] [$sKernelName] = $parseresult1
				If $selectionarray [$cumenusub] [$sFamily] = "linux-andremix" Then CommonKernelArray ($cumenusub, $cuparm)
		EndSelect
		If $cuuserstatus = "on" Then _ArrayAdd ($userarray, $curecord)
	Next
	If $cuuserstatus = "on" Then GetPrevMiscArray  ()
	;_ArrayDisplay ($selectionarray, "Update")
EndFunc

Func GetPrevBootParm ()
	$bpparm = ""
	For $bplinsub = 3 To UBound($parsearray) - 1
		$bpinstance = $parsearray [$bplinsub]
		If StringLeft ($bpinstance, 5) = "root=" And Not StringInStr ($bpinstance, "ram0") Then ContinueLoop
		$bpparm &= $bpinstance & " "
	Next
	$bpparm = StringReplace ($bpparm, "$subvolparm", "")
	Return StringStripWS ($bpparm, 2)
EndFunc

Func GetPrevParseParms ($pprecord, $ppmenusub)
	$pprecord = CommonStripSpecial ($pprecord)
	$pparray  = StringSplit ($pprecord, "--", 1)
	If @error Then Return
	$ppostype = $typecustom
	$ppicon     = ""
	$ppcust     = ""
	$ppparmloc  = ""
	For $ppsub = 1 To Ubound ($pparray) - 1
		$ppentry = StringStripWS ($pparray [$ppsub], 8)
		If StringLeft ($ppentry, 6) = "hotkey" Then
			$pphotkey = StringTrimLeft ($ppentry, 7)
			If StringInStr ($edithotkeywork, "*" & $pphotkey & "*") Then $pphotkey = "no"
			If $pphotkey <> "no" Then $edithotkeywork &= "*" & $pphotkey & "*"
			$selectionarray [$ppmenusub] [$sHotKey] = $pphotkey
			ContinueLoop
		EndIf
		If StringLeft ($ppentry, 5) <> "class" Then ContinueLoop
		$ppentry = StringTrimLeft ($ppentry, 5)
		If StringInStr ($ppentry, "icon-")     Then
			$ppicon = $ppentry
			ContinueLoop
		EndIf
		If StringInStr ($ppentry, "custom_") Then
			$ppcust = $ppentry
			ContinueLoop
		EndIf
		$ppparmloc = _ArraySearch ($osparmarray, $ppentry, 0, 0, 0, 0 ,0, $pClass)
	    If @error Then $ppparmloc = 0
		$ppostype = $osparmarray [$ppparmloc] [$pType]
	Next
	$selectionarray [$ppmenusub] [$sOSType] = $ppostype
	$selectionarray [$ppmenusub] [$sIcon]   = $ppicon
	$ppclass = $osparmarray [$ppparmloc] [$pClass]
	$selectionarray [$ppmenusub] [$sClass]  = $ppclass
	$selectionarray [$ppmenusub] [$sFamily] = $osparmarray [$ppparmloc] [$pFamily]
	If $ppcust <> "" And $selectionarray[$ppmenusub] [$sLoadBy] <> $modeuser Then $selectionarray[$ppmenusub] [$sLoadBy] = $modecustom
	;_ArrayDisplay ($Selectionarray, $ppcust)
EndFunc

Func GetPrevInputArray ($iafile)
	BaseFuncGUIDelete ($upmessguihandle)
	Dim $iaarray [0]
	$ialastclass = ""
	$iahandle = FileOpen ($iafile, 0)
	If $iahandle = -1 Then
		CommonWriteLog ("                *** Error reading " & $iafile & " " & @error)
		CommonEndit    ("Failed")
	EndIf
	While 1
		$iarecord = FileReadLine ($iahandle)
		If @error      = -1 Then ExitLoop
		If StringInStr ($iarecord, "--class") Then $ialastclass = $iarecord
		If StringInStr ($iarecord, $customsourcerec) Then
			Dim $iaarrayinner [0]
			Dim $iaarrayouter [0]
			$iacustfile  = CommonPathToWin ($iarecord)
			$iacustarray = BaseFuncArrayRead ($iacustfile, "GetPrevInputArray", "", "no")
			If @error Then MsgBox ($mbwarnok, "** Missing Custom Code File **", $iacustfile & _
				@CR & @CR & $ialastclass & @CR & @CR & "This Menu Entry Was Skipped")
			$iacustfilename = GetPrevStripCustomFile ($iacustarray, $iacustfile, $iaarrayinner, $iaarrayouter)
			;_ArrayDisplay ($iaarrayinner, "Get Inner ")
			;_ArrayDisplay ($iaarrayouter, "Get Outer ")
			_ArrayInsert  ($iacustarray, 0, $customfilestring & $iacustfilename)
           	If StringInStr ($ialastclass, "--class submenu") Then
				;MsgBox ($mbontop, "Class B", $iarecord & @CR & @CR & $ialastclass)
				$iacustarray = $iaarrayouter
				;ContinueLoop
			EndIf


			_ArrayConcatenate ($iaarray, $iacustarray)
			ContinueLoop
		EndIf
		_Arrayadd ($iaarray, $iarecord)
	Wend
	;_ArrayDisplay ($iaarray)
	Return $iaarray
EndFunc

Func GetPrevStripCustomFile ($cfarray, $cffilename, ByRef $cfarrayinner, ByRef $cfarrayouter)
	GetPrevStripCustomCode ($cfarray, $cfarrayinner, $cfarrayouter)
	$cffilesplit = StringSplit ($cffilename, "\")
    If @error Then Return
	$cffilename = $cffilesplit [Ubound ($cffilesplit) - 1]
	$cfoutpath  = $custconfigstemp & "\" & $cffilename
	BaseFuncArrayWrite ($cfoutpath, $cfarrayinner, $FO_OVERWRITE, "", 0)
	Return $cffilename
EndFunc

Func GetPrevStripCustomCode ($ccarrayin, ByRef $ccarrayinner, ByRef $ccarrayouter)
	Dim $ccarrayinner [0]
	Dim $ccarrayouter [0]
	Local $ccstartloc, $ccendloc = $mega
	For $ccsub = 0 To Ubound ($ccarrayin) - 1
		If StringInStr ($ccarrayin [$ccsub], $customcodestart) Then $ccstartloc = $ccsub
		If StringInStr ($ccarrayin [$ccsub], $customcodeend)   Then $ccendloc   = $ccsub
	Next
	For $ccsub = 0 To Ubound ($ccarrayin) - 1
		Select
			Case ($ccsub > $ccstartloc Or $ccstartloc = "") And $ccsub < $ccendloc
				_ArrayAdd ($ccarrayinner, $ccarrayin [$ccsub], 0, "", "", $ARRAYFILL_FORCE_SINGLEITEM)
			Case $ccsub <  $ccstartloc Or  $ccsub > $ccendloc
				_ArrayAdd ($ccarrayouter, $ccarrayin [$ccsub], 0, "", "", $ARRAYFILL_FORCE_SINGLEITEM)
		EndSelect
	Next
	;_ArrayDisplay ($ccarrayinner, "Inner")
	;_ArrayDisplay ($ccarrayouter, "Outer")
EndFunc

Func GetPrevMiscArray ()
	Dim $miscarray [0]
	If StringStripWS (FileRead ($usersectionfile), 8) = "" Then Return
	$matemparray = BaseFuncArrayRead ($usersectionfile, "GetMiscArray")
	;_ArrayDisplay ($matemparray, "Temp")
	$mamenuon = ""
	$mabound  = Ubound ($matemparray)
	For $masub = 0 To $mabound - 1
		$marecord = StringStripWS ($matemparray [$masub], 3)
		If StringLeft ($marecord, 1) =  "#" Or $marecord = "" Then ContinueLoop
		If GetPrevCheckMenu ($marecord) Then $mamenuon = "yes"
		If StringLeft ($marecord, 1) = "}" Then
			$mamenuon = ""
			ContinueLoop
		EndIf
		If $mamenuon = "yes" Then ContinueLoop
		_ArrayAdd ($miscarray, $marecord)
	Next
	;_ArrayDisplay ($miscarray, "Misc")
	$selectionmisccount = 0
	If Ubound ($miscarray) = 0 Then Return
	$selectionmisccount = 1
	_ArrayAdd ($selectionarray, "")
	$mapointer = Ubound ($selectionarray) - 1
	CommonArraySetDefaults ($mapointer)
	$selectionarray [$mapointer] [$sEntryTitle] = "** User Section Commands Without Menus **"
	$selectionarray [$mapointer] [$sOSType]     = "nomenu"
	$selectionarray [$mapointer] [$sAutoUser]   = "user"
	;_ArrayDisplay ($selectionarray, Ubound ($selectionarray) - 1)
EndFunc

Func GetPrevCheckMenu ($cmrecord)
	$cmrecord = StringStripWS ($cmrecord, 1)
	If StringLeft ($cmrecord, 10) <> "menuentry " And StringLeft ($cmrecord, 8) <> "submenu " Then Return 0
	$cmarray = _StringBetween ($cmrecord, "'", "'")
	If @error Then Return 0
	;_ArrayDisplay ($cmarray, "GetPrevCheckMenu")
	$parseresult1 = $cmarray [0]
	Return 1
EndFunc

Func GetPrevWinBIOS ()
	; Remove Windows menuentries from BIOS machines.
	$gpcsub = 0
	While 1
		$gpclimit = Ubound ($selectionarray) - 1
		If $gpcsub > $gpclimit Then ExitLoop
		$gpctype = $selectionarray [$gpcsub] [$sOSType]
		If ($gpctype = "windows" Or $gpctype = "bootfirmware") And $selectionarray [$gpcsub] [$sLoadBy] <> $modeuser Then
			_ArrayDelete ($selectionarray, $gpcsub)
		Else
			$gpcsub += 1
		EndIf
	Wend
EndFunc