#include-once
#include  <g2common.au3>

Func EditRunGUI($emsub)
  	Local $emlastentry, $emlastpause, $emlastdrvc
	CustomClearWorkFile ($emsub)
	EditSetup($emsub)
	$emwinorderhold = $bcdwinorder
	EditRefresh ($emsub, "Setup")
	While 1
		$emstatusarray = GUIGetMsg (1)
		$emhandle      = $emstatusarray [1]
		$emstatus      = $emstatusarray [0]
		If $emhandle <> $edithandlegui Then	ContinueLoop
		If $emstatus = $GUI_EVENT_CLOSE Or $emstatus = $editbuttoncancel Then
			EditCloseout ($emsub, $emwinorderhold)
			ExitLoop
		EndIf
		Select
			Case $emstatus < 1
				Select
					Case $emstatus <> $GUI_EVENT_PRIMARYUP
						ContinueLoop
					 Case CommonCheckUpDown ($edithandlechaindrv, $emlastdrvc, 0, 9)
						$emchainnumber = GUICtrlRead ($edithandlechaindrv)
						If $emchainnumber > $partdisknumber Then $emchainnumber = $partdisknumber
						$selectionarray [$emsub] [$sChainDrive] = $emchainnumber
						EditRefresh ($emsub, "UPDown drvc")
					Case CommonCheckUpDown ($edithandleentry, $emlastentry, 0, $selectionautohigh)
						$editnewentry = $emlastentry
					Case CommonCheckUpDown ($edithandlepause, $emlastpause)
						EditPause ($emsub)
				EndSelect
			Case Else
				Select
					Case $emstatus = $editprompticon Or $emstatus = $editpictureicon
						If $editerrorok = "yes" Then
							IconRunGUI    ($emsub)
							EditRefresh   ($emsub, "Icon Edit")
						EndIf
						EditRefresh ($emsub, "Icon")
					Case $emstatus = $edithandleloadby Or $emstatus = $edithandlelayout Or _
						 $emstatus = $edithandlediskr   Or $emstatus = $edithandlediskb
						EditDiskAddress ($emsub)
						EditRefresh ($emsub, "Diskaddr")
					Case $emstatus = $edithandlesrchr
						$selectionarray [$emsub] [$sRootSearchArg] = GUICtrlRead ($edithandlesrchr)
						EditRefresh ($emsub, "srchr")
					Case $emstatus = $edithandlesrchl
						$selectionarray [$emsub] [$sRootSearchArg] = GUICtrlRead ($edithandlesrchl)
						EditRefresh ($emsub, "srchl")
					Case $emstatus = $edithandleselfile
						EditKernelSelect ($emsub)
						EditRefresh  ($emsub, "SelFile")
					Case $emstatus = $editpromptcust Or $emstatus = $editlistcustedit
						CustomEditData ($emsub)
						EditRefresh ($emsub, "Cust")
					Case $emstatus = $edithandleseliso
						EditISOSelect ($emsub)
					Case $emstatus = $editpromptsample
						EditLoadSample ($emsub)
						EditRefresh ($emsub, "Sample")
				EndSelect
				If $selectionarray [$emsub] [$sOSType] = "windows" And $firmwaremode = "EFI" Then EditCheckWinOrder ($emstatus, $emsub)
				$emloadby  = $selectionarray[$emsub][$sLoadBy]
				Select
					Case $emstatus = $edithelphandle
						If $emloadby = $modecustom Then
							CommonHelp ("Entering Custom Code")
						Else
							CommonHelp ("Editing OS Details")
						EndIf
						ContinueLoop
					Case $emstatus = $editbuttonok Or $emstatus = $editbuttonapply
						If $editnewentry <> $editholdentry Then $selectionarray [$editholdentry][$sSortSeq] = ($editnewentry * 100) + 10
						$selectionarray[$emsub][$sUpdateFlag] = "updated"
						If $emstatus = $editbuttonok And FileExists ($customworkfile) Then
							FileCopy ($customworkfile, $custconfigstemp & "\" & CommonCustomName ($selectionarray [$emsub] [$sEntryTitle]), 1)
							$selectionarray [$emsub] [$sCustomName] =           CommonCustomName ($selectionarray [$emsub] [$sEntryTitle])
						EndIf
						EditRefresh($emsub, "OK")
						;If $emstatus = $editbuttonapply Then _ArrayDisplay ($selectionarray, "Apply")
						If $emstatus = $editbuttonok And $editerrorok = "yes" Then ExitLoop
					Case $emstatus = $edithandletitle
						EditTitle ($emsub)
					Case $emstatus = $edithandlefix
						$emfix = GUICtrlRead ($edithandletitle)
						If $edittitleok = "invalchar" Then $emfix = BaseFuncRemoveCharSpec ($emfix)
						If StringLen ($emfix) > 80    Then $emfix = StringLeft (StringStripWS ($emfix, 7), 80)
						GUICtrlSetData  ($edithandletitle, $emfix)
						EditTitle       ($emsub)
						EditCheckErrors ($emsub, "")
					Case $emstatus = $edithandletype
						$emtype = GUICtrlRead ($edithandletype)
						If $emtype = $typeotherlin Then
							$emothermsg  = 'You must import the Grub configuration file for ' & @CR
							$emothermsg &= 'Linux Distributions not supported by Grub2Win.'   & @CR & @CR
							$emothermsg &= 'Click "OK" for detailed import instructions.'
							$emrc = MsgBox ($mbinfookcan, "** Other Linux **", $emothermsg)
							If $emrc = $IDOK Then
								CommonHelp  ("Importing Linux Config Files")
								CommonEndIt ("Success", "", "", "")
							EndIf
							GUICtrlSetData ($edithandletype, "|" & $typestringcust, "")
							ContinueLoop
						EndIf
						If $emtype = $typeuser OR $emtype = $typeimport Then
							If $emtype = $typeuser   Then CustomUserSectionEdit ("Creation")
							If $emtype = $typeimport Then ImportRunGUI ()
							_ArrayDelete ($selectionarray, $emsub)
							ExitLoop
						EndIf
						If $emtype = "posrog" Then
							BaseFuncGUIDelete ($edithandlegui)
							BaseFuncGUIDelete ($handleselectiongui)
							EditCloseout    ($emsub, $emwinorderhold)
							$emposrc = POSInstall      ()
							MsgBox      ($mbwarnok, "** POSROG Install Failed", $emposrc)
							ExitLoop
						EndIf
						EditRefresh($emsub, "Type")
					Case $emstatus = $edithandlechknv
						EditKernelParm ($emsub)
					Case $emstatus = $edithandleparm
						EditParm($emsub)
					Case $emstatus = $editbuttonstand
						$emdefault = CommonParmCalc ($emsub, "Standard")
						GuiCtrlSetData ($edithandleparm, $emdefault)
						EditParm($emsub)
						If $selectionarray [$emsub] [$sFamily] = "linux-android" Then
							CommonKernelArray ($emsub, $emdefault)
							EditKernelGUI ($emsub)
						EndIf
						GUICtrlSetState ($editbuttonstand, $guihideit)
						GUICtrlSetState ($editmessageparm, $guishowit)
					Case $emstatus = $edithandlegraph
						EditGraph ($emsub)
					Case $emstatus = $edithandlehotkey
						EditHotkey ($emsub)
					Case Else
				EndSelect
		EndSelect
		;If $emloadby = $modehardaddress Or $emloadby = $modechaindisk Then
	WEnd
	CustomClearWorkFile ($emsub)
	BaseFuncGUIDelete     ($edithandlegui)
	GUICtrlSetState     ($buttonselectionadd,  $guishowit)
	GUICtrlSetState     ($selectionhelphandle, $guishowit)
EndFunc

Func EditSetup ($essub)
	;_ArrayDisplay ($selectionarray)
	GUICtrlSetState ($buttonselectionadd,  $guihideit)
	GUICtrlSetState ($selectionhelphandle, $guihideit)
	$editholdentry    = $essub
	$editnewentry     = $essub
	$editerrorok      = ""
	$edittitleok      = ""
	$editparmok       = ""
	$editsearchfilled = ""
	$editsearchok     = ""
	Dim $edithandlewinset   [6]
	Dim $edithandlewininst  [6]
	Dim $edithandlewintitle [6]
	$editlimit = UBound($selectionarray) - 1
	BaseFuncGUIDelete ($edithandlegui)
	$edithandlegui  = CommonScaleCreate ("GUI", "Editing Menu Slot " & $essub, -1, -1, 100, 70, -1, "", $handleselectiongui)
	GUISwitch ($edithandlegui)
	$edithelphandle = CommonScaleCreate("Button", "Help", 90, 1, 8, 3.5)
	GUICtrlSetBkColor ($edithelphandle, $mymedblue)
	CommonScaleCreate("Label", "Title", 30, 4, 4, 2)
	$edithandletitle = CommonScaleCreate("Input", $selectionarray[$essub][$sEntryTitle], 37, 4, 50, 3)
	$edithandlefix   = CommonScaleCreate("Button", " Fix", 28.5, 6, 5, 3)
	GUICtrlSetBkColor ($edithandlefix,   $myyellow)
	CommonScaleCreate ("Label", "Type",  3, 4, 10, 3)
	$edithandletype  = CommonScaleCreate("Combo", "", 13, 3.8, 13, 3, -1)
	$typestringcust  = StringReplace ($typestring, $typeotherlin & "|", $typeotherlin & "||")
	If $firmwaremode = "EFI" And $windowstypecount > 0 And $selectionarray [$essub] [$sOSType] <> "windows" _
		Then $typestringcust = StringReplace ($typestringcust, "windows|", "")
	If $osbits = 32 Or $cloverfound = "yes" Then $typestringcust = StringReplace ($typestringcust, "clover|",  "")
	If FileGetSize ($usersectionfile) <> 0  Then $typestringcust = StringReplace ($typestringcust, $typeuser & "|", "")
	GUICtrlSetData ($edithandletype, $typestringcust, $selectionarray[$essub][$sOSType])
	                    CommonScaleCreate("Label", "Menu Slot", 3, 10, 8, 3)
	$edithandleentry =  CommonScaleCreate("Input", $essub, 13, 10, 5, 3)
					    GUICtrlCreateUpdown($edithandleentry)
	If $selectionarray [$essub] [$sFamily] <> "standfunc" Or $selectionarray [$essub] [$sOSType] = "clover" Then
		$editpromptgraph =  CommonScaleCreate("Label", "Graphics Payload", 3,   27.2, 10, 6)
		$edithandlegraph =  CommonScaleCreate("Combo", "", 13, 27, 12, 3, -1)
		GUICtrlSetData($edithandlegraph, $graphnotset & "|any|keep|" & $graphstring, $selectionarray[$essub][$sGraphMode])
	EndIf
	                    CommonScaleCreate("Label", "Pause" & @CR & "Seconds", 3, 33, 8, 6)
	$edithandlepause =  CommonScaleCreate("Input", $selectionarray[$essub][$sReviewPause], 13, 34, 5, 3)
	                    GUICtrlCreateUpdown($edithandlepause)
	                    CommonScaleCreate("Label", "Hotkey", 3, 40, 8, 3)
	$edithandlehotkey = CommonScaleCreate("Combo", "", 13, 39.5, 10, 3, -1)
	                    CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
	                    CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
						CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
	                    CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
						CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
	                    CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
						CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
	                    CommonScaleCreate("Label", "", 1, 1, 1, 1)    ;dummy entries for Aotoit Bug
	$eshotkey     = $selectionarray[$essub][$sHotKey]
	$eshotkeywork = $edithotkeywork
	If Not StringInStr ($edithotkeywork, "|" & $eshotkey & "|") Then $eshotkeywork &= $eshotkey & "|"
	GUICtrlSetData   ($edithandlehotkey, $eshotkeywork, $eshotkey)
	EditHotKey       ($essub)
	$edithandlewarn   = CommonScaleCreate("Label", "", 19, 54.5, 60, 9, $SS_CENTER)
	$editpromptparm   = CommonScaleCreate("Label", "Linux Boot Parms",    43, 43, 12, 3)
	$edithandlechknv  = CommonScaleCreate ("Checkbox", "Nvidia Support", 80, 43, 17, 3)
	If $selectionarray [$essub] [$sFamily] = "linux-android" Then EditKernelGUI ($essub)
	$editbuttonstand  = CommonScaleCreate("Button",   "Restore Standard Parms", 79, 54.5, 19, 3.5)
	GUICtrlSetBkColor ($editbuttonstand, $mygreen)
	$edithandledevice = CommonScaleCreate("Label", "", 3, 54.5, 60, 7)
	$edithandleparm   = CommonScaleCreate("Edit", CommonParmCalc ($essub, "Previous", "Store"), 3, 46, 95, 8, "", "")
	$editmessageparm  = CommonScaleCreate("Label", "Standard Parms Are In Use", 79, 54.5, 20, 3)
	GUICtrlSetColor   ($editmessageparm, $mymedblue)
	$focushandle = $edithandletitle
	$editbuttoncancel = CommonScaleCreate("Button", "Cancel", 10, 64, 10, 3.8)
	$editbuttonapply  = CommonScaleCreate("Button", "Apply",  45, 64, 10, 3.8)
	$editbuttonok     = CommonScaleCreate("Button", "OK",     80, 64, 10, 3.8)
	EditPanelRefresh   ($essub, "yes")
EndFunc

Func EditRefresh ($ersub, $ercaller, $erhandle = "")
	$ermsg = "Caller is " & $ercaller
	If $erhandle <> "" Then $ermsg &= "         Handle is " & $erhandle
	;MsgBox ($mbontop, "Edit Refresh Caller", $ermsg, 1)
	EditType ($ersub)
	$erloadby = $selectionarray [$ersub][$sLoadBy]
	If StringInStr ($selectionarray [$ersub] [$sFamily], "linux")                        Or _
	    $erloadby = $modeandroidfile Or $selectionarray [$ersub] [$sClass] = "clover"    Or _
		$erloadby = $modephoenixfile Or $selectionarray [$ersub] [$sClass] = "chainfile" Then EditSearchPart ($ersub)
	EditDiskErrors  ($ersub)
	EditGraph       ($ersub)
	EditPause       ($ersub)
	EditCheckDuplicates ($ersub)
	EditCheckErrors ($ersub, $ercaller)
	If $focushandle > 0 And $focushandle <> $focushandlelast Then
		ControlFocus ($edithandlegui, "", $focushandle)
		$focushandlelast = $focushandle
	EndIf
	EditPanelRefresh ($ersub)
	If $selectionarray [$ersub] [$sOSType] = "windows" And $firmwaremode = "EFI" Then EditSetupWinOrder ($guishowit)
	GUISetBkColor    ($myorange, $edithandlegui)
	GUISetState      (@SW_SHOW,  $edithandlegui)
	;_ArrayDisplay ($selectionarray)
EndFunc

Func EditCloseout ($ecsub, $ecwinorderhold)
	CustomClearWorkFile ($ecsub)
	$selectionarray = $editholdarray
	$bcdwinorder    = $ecwinorderhold
	$editnewentry   = 0
EndFunc

Func EditSetupWinOrder ($eswstate = $guihideit)
	;_ArrayDisplay ($bcdwinorder, "Edit Setup")
	If $eswstate = $guihideit Then GUICtrlSetState ($edithandletitle, $guishowit)
	For $eswwinsub = 0 To Ubound ($bcdwinorder) - 1
		If $eswwinsub > 5 Then ExitLoop
		$bcdwinorder [$eswwinsub] [$bSortSeq] = $eswwinsub * 100
		GUICtrlSetState ($edithandlewinset   [$eswwinsub], $eswstate)
		GUICtrlSetState ($edithandlewininst  [$eswwinsub], $eswstate)
		GUICtrlSetState ($edithandlewintitle [$eswwinsub], $eswstate)
		If $eswwinsub = 0 Then GUICtrlSetState ($edithandlewinset [$eswwinsub], $guihideit)
		If $eswstate  = $guihideit Then ContinueLoop
		GUICtrlSetData ($edithandlewininst  [$eswwinsub], "Instance " & $eswwinsub + 1)
		GUICtrlSetData ($edithandlewintitle [$eswwinsub], $bcdwinorder [$eswwinsub] [$bItemTitle])
	Next
EndFunc

Func EditCheckWinOrder ($ecwstatus, $ecwsub)
	For $ecwwinsub = 0 To Ubound ($bcdwinorder) - 1
		If $ecwwinsub > 5 Then ExitLoop
		If $ecwstatus = $edithandlewinset [$ecwwinsub] Then
			$bcdwinorder [$ecwwinsub] [$bSortSeq] = 0
			_ArraySort ($bcdwinorder, 0, 0, 0, $bSortSeq)
			GUICtrlSetBkColor ($edithandlewintitle [0], $mygreen)
			$bcdwinorderflag = "set"
			EditRefresh ($ecwsub, "WinSet")
		Endif
		If $ecwstatus = $edithandlewintitle [$ecwwinsub] Then
			$ecwtitle = GUICtrlRead ($edithandlewintitle [$ecwwinsub])
			If StringLen (StringStripWS ($ecwtitle, 8)) > 1 Then
				$bcdwinorder [$ecwwinsub] [$bItemTitle] = $ecwtitle
				GUICtrlSetBkColor ($edithandlewintitle [$ecwwinsub], $mygreen)
			EndIf
			$bcdwinorderflag = "title"
		EndIf
	Next
EndFunc

Func EditTitle ($etitlesub)
	$edittitleok     = ""
	$etstring = EditContentStringCheck ($edithandletitle, $edittitleok, 80)
	$selectionarray [$etitlesub][$sEntryTitle] = $etstring
	EditHotkey ($etitlesub)
EndFunc

Func EditHotkey ($ehsub)
	If StringLen ($selectionarray [$ehsub][$sEntryTitle]) > 46 Then
		$selectionarray [$ehsub][$sHotKey] = ""
		GUICtrlSetData  ($edithandlehotkey, $edithotkeywork, "no")
		GUICtrlSetState ($edithandlehotkey, $guishowdis)
	Else
		$ehhotkey = GUICtrlRead ($edithandlehotkey)
	    $selectionarray [$ehsub] [$sHotKey] = $ehhotkey
		GUICtrlSetState ($edithandlehotkey, $guishowit)
	EndIf
EndFunc

Func EditCheckDuplicates ($cdsub)
	$editdupmessage = ""
	$cdchanged      = ""
	If $selectionarray [$cdsub] [$sLoadBy] <> $modecustom Then Return
	$cdoriginal     = $selectionarray [$cdsub] [$sEntryTitle]
	For $cdattempt = 2 To 99
		Dim $cdarray [0]
		For $cdsel = 0 To Ubound ($selectionarray) - 1
			$cdrec = CommonCustomName ($selectionarray [$cdsel] [$sEntryTitle])
			If $cdrec = "" Or $cdsel = $cdsub Then ContinueLoop
			_ArrayAdd ($cdarray, $cdrec)
		Next
		_ArraySearch ($cdarray, CommonCustomName ($selectionarray [$cdsub] [$sEntryTitle]))
	    If @error Then
			ExitLoop
		Else
			$cdchanged  = "yes"
			$cdnewtitle = StringLeft (StringStripWS ($cdoriginal, 2), 77) & "-" & StringFormat ("%.2d",$cdattempt)
			$selectionarray [$cdsub] [$sEntryTitle] = $cdnewtitle
			GUICtrlSetData ($edithandletitle, $cdnewtitle)
		Endif
	Next
	$editerrorok = "no"
		If $cdchanged <> "" Then $editdupmessage = "Custom Code Titles Must Be Unique" & @CR & _
			"The Title For Menu Entry " & $cdsub & " Has Been Changed To " & @CR & _
			'"' & $cdnewtitle & '"      Please Click Apply'
EndFunc

Func EditLoadSample ($elssub)
	$elssamptype = $selectionarray [$elssub] [$sOSType]
	CommonFlashStart ("Loading Sample Code", "For " & BaseFuncCapIt ($elssamptype) & " Systems", 1000)
	Dim $elsstandarray [1]
	If $selectionarray [$elssub] [$sReviewPause] < 1 And $elssamptype <> "submenu" Then
		GUICtrlSetData ($edithandlepause, 2)
		$selectionarray [$elssub] [$sReviewPause] = 2
	EndIf
	GenGetOsFields   ($elssub, $elsstandarray, "sample")
	BaseFuncArrayWrite ($customworkfile, $elsstandarray)
	If $elssamptype = $modecustom   Then FileCopy ($samplecustcode, $customworkfile, 1)
	If $elssamptype = "isoboot"     Then FileCopy ($sampleisocode,  $customworkfile, 1)
	If $elssamptype = "submenu"     Then FileCopy ($samplesubcode,  $customworkfile, 1)
	;_ArrayDisplay ($elsstandarray, $elssamptype)
	$selectionarray   [$elssub] [$sCustomName] = $custworkstring
	$custparsearray  = BaseFuncArrayRead ($customworkfile, "EditLoadSample")
	CustomGetData ($elssub)
	CustomWriteList   ()
	GUICtrlSetBkColor ($editpromptcust,   $mygreen)
	GUICtrlSetBkColor ($editpromptsample, $mygreen)
	CommonFlashEnd    ("")
EndFunc

Func EditType($etsub)
	If $selectionarray[$etsub][$sOSType] = "clover" Then _
		GUICtrlSetData ($edithandletype, "|" & $typestringcust & "clover", "clover")
	$edittype = GUICtrlRead ($edithandletype)
	If $firmwaremode <> "EFI" And $edittype = "windows" Then
		$edittype = ""
		GUICtrlSetData ($edithandletype, "|" & $typestringcust, "")
		$etmsg    = 'Windows Can Not Be Added To Grub2Win BIOS Menus' & @CR & @CR & 'Click "OK" For More Information'
		$etrc     = MsgBox ($mbwarnokcan, '** This Is A BIOS System **', $etmsg)
		If $etrc  = $IDOK Then CommonHelp ("BIOS System Boot")
	EndIf
	If $edittype = "" Then $edittype = "unknown"
	$etstatus = "Previous"
	If $edittype <> $selectionarray[$etsub][$sOSType] Then $etstatus = "New"
	$selectionarray[$etsub][$sOSType] = $edittype
	$etparmloc  = CommonGetOSParms ($etsub)
	$etclass    = $osparmarray [$etparmloc] [$pClass]
	$etfamily   = $osparmarray [$etparmloc] [$pFamily]
	$ettitle    = $osparmarray [$etparmloc] [$pTitle]
	$selectionarray [$etsub] [$sFamily] = $etfamily
	$selectionarray [$etsub] [$sClass ] = $etclass
	If $etstatus = "New" Then
		$selectionarray [$etsub] [$sEntryTitle] = $ettitle
		$etparmcalctype = "Held"
		CommonSetDefault ($selectionarray [$etsub][$sBootParm], "Standard")
		$selectionarray [$etsub][$sBootParm] = CommonParmCalc ($etsub, $etparmcalctype)
		If $selectionarray [$etsub][$sOSType] = "isoboot" Then GuiCtrlSetData ($edithandlegraph, "1024x768")
		If  $selectionarray[$etsub][$sOSType] = "android" Then
			$selectionarray[$etsub][$sLoadBy] = $modeandroidfile
			GuiCtrlSetData ($edithandlesrchl,  $androidbootpath)
			GuiCtrlSetData ($edithandlegraph,  "1024x768")
		ElseIf $selectionarray[$etsub][$sOSType] = "phoenix" Then
			$selectionarray[$etsub][$sLoadBy] = $modephoenixfile
			GuiCtrlSetData ($edithandlesrchl,  $phoenixbootpath)
			GuiCtrlSetData ($edithandlegraph,  "1024x768")
		ElseIf StringInStr ($etfamily, "linux") Then
			$selectionarray[$etsub][$sLoadBy] = $modepartuuid
			GuiCtrlSetData ($edithandlegraph,  "1024x768")
		ElseIf $etfamily = "chainfile" Then
			$etbootfile = $chainbootpath
			$selectionarray[$etsub] [$sLoadBy]    = $modechainfile
			If $selectionarray[$etsub][$sOSType]  = "clover" Then $etbootfile = $cloverbootfile
			$selectionarray[$etsub] [$sRootSearchArg] = $etbootfile
			GuiCtrlSetData ($edithandlesrchl, $etbootfile)
		ElseIf $etfamily = "chaindisk" Then
			$selectionarray[$etsub] [$sLoadBy]    = $modechaindisk
		Else
			$selectionarray[$etsub][$sLoadBy] = ""
			$selectionarray[$etsub][$sRootSearchArg] = ""
			GuiCtrlSetData ($edithandlesrchr, "")
		EndIf
		CommonArraySetDefaults ($etsub, "yes")
        $ethotkey = StringLower (StringLeft ($edittype, 1))
		If StringInStr ($edithotkeywork, $ethotkey) Then
			GUICtrlSetData ($edithandlehotkey, $edithotkeywork, $ethotkey)
			EditHotKey ($etsub)
		EndIf
		If $selectionarray [$etsub] [$sFamily] = "linux-android" Then
			$selectionarray [$etsub] [$sEntryTitle] &= " 64 Bit"
			EditKernelGUI  ($etsub)
		EndIf
		If $selectionarray [$etsub] [$sLoadBy] = $modecustom Then _
			FileCopy ($sourcepath & $templateempty, $customworkfile, 1)
		$selectionarray[$etsub][$sReviewPause] = 2
		GuiCtrlSetData ($edithandlepause, 2)
	EndIf
	$etloadby =  $selectionarray [$etsub] [$sLoadBy]
	If $etloadby = $modecustom And $selectionarray [$etsub] [$sOSType] <> "isoboot" And _
		$selectionarray [$etsub] [$sOSType] <> "submenu" Then
			$selectionarray [$etsub] [$sClass]      = "custom"
			$selectionarray [$etsub] [$sCustomName] = $custworkstring
	Else
			$selectionarray [$etsub] [$sSampleLoadBy] = $etloadby
	EndIf
	GUICtrlSetData ($edithandleloadby, EditPanelGetMode ($etsub), $etloadby)
	EditSetAttribs ($etsub, $etloadby)
	$etnewparm = CommonParmCalc ($etsub, "Previous", "Store")
	GuiCtrlSetData ($edithandletitle, $selectionarray[$etsub][$sEntryTitle])
	GuiCtrlSetData ($edithandleparm, $etnewparm)
	;_ArrayDisplay ($selectionarray)
EndFunc

Func EditSetAttribs ($esasub, $esabootby = $modehardaddress)
	$esaparm        = $guihideit
	$esaparmandroid = $guihideit
	$esaiso         = $guihideit
	$esafamily      = $selectionarray [$esasub][$sFamily]
	If StringInStr ($esafamily, "linux") Then $esaparm = $guishowit
	If $firmwaremode = "EFI" Then EditSetupWinOrder ($guihideit)
	Select
		Case $selectionarray [$esasub] [$sLoadBy] = $modecustom
			$esaparm = $guihideit
		Case $selectionarray [$esasub] [$sOSType] = "windows" And $firmwaremode = "EFI"
			EditSetupWinOrder ($guishowit)
		Case $esabootby = $modechaindisk
			$esaparm     = $guihideit
	EndSelect
	If $esafamily = "linux-android" Then $esaparmandroid = $guishowit
	If $esaparm   = $guihideit Then $esaparmandroid = $guihideit
	If $selectionarray [$esasub] [$sOSType] = "isoboot"	Then $esaiso = $guishowit
	GUICtrlSetState ($edithandlechknv,    $esaparmandroid)
	GUICtrlSetState ($editpromptparm,     $esaparm)
	GUICtrlSetState ($edithandleparm,     $esaparm)
	GUICtrlSetState ($editbuttonstand,    $esaparm)
	GUICtrlSetState ($editmessageparm,   $guihideit)
	GUICtrlSetState ($edithandledevice,  $guihideit)
	If StringInStr ($esafamily, "linux") And $esafamily <> "linux-android" Then EditDisplayDev ($esasub)
	If $esaparm = $guihideit Then Return
	If $selectionarray [$esasub] [$sBootParm] = CommonParmCalc ($esasub, "Standard") Then
		GUICtrlSetState ($editbuttonstand, $guihideit)
		GUICtrlSetState ($editmessageparm, $guishowit)
	EndIf
EndFunc

Func EditKernelGUI ($kgsub)
	CommonKernelArray ($kgsub)
	GUICtrlSetState ($edithandlechknv, $GUI_UNCHECKED)
	If $selectionarray[$kgsub][$sNvidia] = "yes" Then GUICtrlSetState ($edithandlechknv, $GUI_CHECKED)
EndFunc

Func EditKernelParm ($epsub)
	$epparm = StringStripWS ($selectionarray [$epsub] [$sBootParm], 2)
	$selectionarray [$epsub] [$sNvidia] = "no"
	$epparm = StringReplace ($epparm, $parmnvidia, " ")
	If CommonCheckBox ($edithandlechknv) Then
		$epparm &= " " & $parmnvidia
		$selectionarray [$epsub] [$sNvidia] = "yes"
	EndIf
	$selectionarray [$epsub] [$sbootparm] = $epparm
	GuiCtrlSetData ($edithandleparm, $epparm)
	CommonKernelArray ($epsub)
EndFunc

Func EditKernelSelect ($essub)
	$estype = $selectionarray [$essub] [$sOSType]
	$esfile = CommonGetBootFile ($selectionarray [$essub] [$sRootSearchArg])
	If $estype  = "android" Or $estype = "phoenix" Or $estype = $typechainfile Then
		$esfile = FileOpenDialog ("Select the " & $estype & " kernel file", "C:\", "All(*.*)", 3, $esfile)
		If @error Then Return
	EndIf
	$espath = CommonGetBootPath ($esfile)
	If StringLen ($espath) < 4 Then Return
	GuiCtrlSetData  ($edithandlesrchl, $espath)
	$selectionarray [$essub] [$sRootSearchArg] = $espath
EndFunc

Func EditISOSelect ($eisub)
	$eisearch = FileOpenDialog ($selisofile, "", "(*.iso)", $FD_FILEMUSTEXIST)
	If @error Or StringLen ($eisearch) < 4 Then Return
	$eisearch = StringReplace (StringTrimLeft ($eisearch, 2), "\", "/")
	StringReplace ($eisearch, " ", "")
	If @extended > 0 Then
		MsgBox ($mbontop, "", "*** Error - The ISO file path must not contain embedded spaces ***" & @CR & @CR & $eisearch)
		Return
	EndIf
	$eisearch = "'" & $eisearch & "'"
	If CustomGetData ($eisub) = "" Then
		EditLoadSample ($eisub)
		EditRefresh    ($eisub, "ISOSel")
	EndIf
	$eisearch = "set isopath=" & $eisearch
	For $eirecordno = 0 To Ubound ($custparsearray) - 1
		$eirecord = $custparsearray [$eirecordno]
		If StringLeft  (StringStripWS ($eirecord, 1), 1) = "#" Then ContinueLoop
		If StringInStr ($eirecord, "isopath=") Then
			$custparsearray [$eirecordno] = $eisearch
			ExitLoop
		EndIf
	Next
	CustomWriteList  ()
	_ArrayInsert ($custparsearray, 0, "")
	CommonFlashStart ("Updating the isopath variable", $eisearch, 1000)
	CommonFlashEnd   ("")
	BaseFuncArrayWrite ($customworkfile, $custparsearray)
EndFunc

Func EditDiskAddress ($dasub)
	$selectionarray [$dasub] [$sLoadBy]    = GUICtrlRead ($edithandleloadby)
	If $editlinpartcount < 2 Then GUICtrlSetData ($edithandlelayout, $layoutrootonly)
	$selectionarray [$dasub] [$sLayout]    = GUICtrlRead ($edithandlelayout)
	$selectionarray [$dasub] [$sRootDisk]  = CommonGetDisk (GUICtrlRead ($edithandlediskr), "Disk")
	$selectionarray [$dasub] [$sBootDisk]  = CommonGetDisk (GUICtrlRead ($edithandlediskb), "Disk")
EndFunc

Func EditDiskErrors ($desub)
	$editpartselected = ""
	If $selectionarray [$desub] [$sLoadBy] = $modecustom Then Return
	$defamily = $selectionarray [$desub] [$sFamily]
	If Not StringInStr ($defamily, "linux") Or StringInStr ($defamily, "android") Then Return
	If Not StringInStr ($selectionarray [$desub] [$sRootDisk], "Disk") Then $editpartselected = "Root"
	If $selectionarray [$desub] [$sLayout] = $layoutboth And Not StringInStr ($selectionarray [$desub] [$sBootDisk], "Disk") Then $editpartselected = "Boot"
EndFunc

Func EditSearchPart ($espsub)
	;_ArrayDisplay ($selectionarray)$selectionarray [$desub] [$sFamily]
	$espsearch        = ""
	$editsearchok     = ""
	$editsearchfilled = ""
	$esploadby        = $selectionarray [$espsub] [$sLoadBy]
	Select
		Case $esploadby = $modepartuuid Or $esploadby = $modepartlabel Or $esploadby = $modehardaddress
			;MsgBox ($mbontop, "Search", $selectionarray [$espsub] [$sRootDisk] & @CR & @CR & GUICtrlRead ($edithandlediskr) & @CR & @CR &$selectionarray [$espsub] [$sLayout], 1)
		Case $esploadby = $modepartuuid Or $esploadby = $modepartlabel
		Case $esploadby = $modeandroidfile Or $esploadby = $modephoenixfile Or $esploadby = $modechainfile
			If $selectionarray [$espsub][$sRootSearchArg] = "" Then
				If $selectionarray [$espsub][$sOSType] = "android"   Then GUICtrlSetData ($edithandlesrchl, $androidbootpath)
				If $selectionarray [$espsub][$sOSType] = "phoenix"   Then GUICtrlSetData ($edithandlesrchl, $phoenixbootpath)
				If $selectionarray [$espsub][$sOSType] = "chainfile" Then GUICtrlSetData ($edithandlesrchl, $chainbootpath)
			EndIf
			$espsearch = EditContentStringCheck ($edithandlesrchl, $editsearchok, 60, "yes")
			If $editsearchok <> "" Then Return
			If $espsearch <> "" Then $selectionarray [$espsub] [$sRootSearchArg] = $espsearch
			If StringMid (CommonGetBootFile ($espsearch), 2, 1) <> ":"  Then $editsearchok = "kernelmissing"
			If $editsearchok = "" Then $selectionarray [$espsub] [$sFileLoadCheck] = ""
			If $selectionarray [$espsub] [$sFileLoadCheck] = $fileloaddisable Then $editsearchok = ""
		Case $selectionarray [$espsub][$sOSType] = "clover"
			$selectionarray [$espsub][$sRootSearchArg] = $cloverbootfile
			GuiCtrlSetData ($edithandlesrchr, $espsearch)
		EndSelect
	;_ArrayDisplay ($selectionarray, "EditSearchPart  End " & " R " & GuiCtrlRead ($edithandlesrchr) & "   M " & GuiCtrlRead ($edithandlesrchr) )
EndFunc

Func EditContentStringCheck ($csshandle, ByRef $cssok, $cssmaxlength, $cssallowslash = "no")
	$cssok    = ""
	$cssfield = GUICtrlRead   ($csshandle)
	$cssfield = StringStripWS ($cssfield, 3)
	GUICtrlSetData ($csshandle, $cssfield)
	$csscheck = $cssfield
	If $cssallowslash = "yes" Then $csscheck = StringReplace ($csscheck, "/", "")
	If StringMid ($csscheck, 2, 1) = ":" Then $csscheck = StringTrimLeft ($csscheck, 2)
	If StringLen ($cssfield) < 1 Or StringLen ($cssfield) > $cssmaxlength Then $cssok = "length"
	If StringLen ($cssfield) = 0 Then $editsearchfilled = "no"
	If BaseFuncCheckCharSpec ($csscheck) Then $cssok = "invalchar"
	Return $cssfield
EndFunc

Func EditParm($epsub)
	$epparm = GUICtrlRead($edithandleparm)
	$editparmok     = "yes"
	$editparmlength = StringLen($epparm)
	If $editparmlength > 120 Then $editparmok = "no"
	If $editparmlength = 0 Then
		$epparm = $nullparm
		GUICtrlSetData($edithandleparm, "")
	EndIf
	$selectionarray[$epsub][$sBootParm] = $epparm
	CommonParmCalc ($epsub, "Held", "Store")
EndFunc

Func EditGraph($egsub)
	$eggraph = GUICtrlRead($edithandlegraph)
	$selectionarray[$egsub][$sGraphMode] = $eggraph
EndFunc

Func EditPause($epentrysub)
	Local $eppause
	CommonCheckUpDown ($edithandlepause, $eppause, 0, 120)
	$selectionarray[$epentrysub][$sReviewPause] = $eppause
EndFunc

Func EditDisplayDev ($dddsub)
	$ddloadby     = $selectionarray [$dddsub] [$sLoadBy]
	$ddtype       = "Device"
	If $ddloadby  = $modepartuuid  Then $ddtype = "UUID"
	If $ddloadby  = $modepartlabel Then $ddtype = "Label"
	$ddrootstring = CommonConvDevAddr ($selectionarray [$dddsub] [$sRootDisk], $ddtype, "FSys")
	$dddaddress   = "Linux Root " & $ddtype & "  =  " & $ddrootstring
	If $selectionarray[$dddsub][$sLayout] = $layoutboth Then
	    $ddbootstring = CommonConvDevAddr ($selectionarray [$dddsub] [$sBootDisk], $ddtype, "FSys")
		$dddaddress &= @CR & "Linux Boot " & $ddtype & "  =  " & $ddbootstring
	EndIf
	GUICtrlSetData  ($edithandledevice, $dddaddress)
	GUICtrlSetState ($edithandledevice, $guishowit)
EndFunc

Func EditCheckErrors ($ecesub, $ececaller)
	$editerrorok     = "no"
	$ecewarnmessage  = ""
	$ececolor        = $myred
	$ecetitle        = $selectionarray [$ecesub][$sEntryTitle]
	$eceredmessage   = @CR & @CR & 'Please correct the error,  then click the "Apply" button below.'
	GUICtrlSetState  ($edithandlefix, $guihideit)
	$eceprompt       = StringReplace (GUICtrlRead ($editpromptsrchr), "Root", "")
	$ecebootby       = $selectionarray [$ecesub] [$sLoadBy]
	Select
		Case $selectionarray [$ecesub] [$sOSType] = "" Or $selectionarray [$ecesub] [$sOSType] = "unknown"
			$ecewarnmessage  = 'Please select an OS Type.'
			$ececolor        = $mypurple
		Case $edittitleok = "length"
			$ecewarnmessage  = 'The menu title must be 1 to 80 characters in length.' & @CR
			$ecewarnmessage &= 'There are ' & StringLen ($ecetitle) & ' characters currently.' & @CR
			$eceredmessage   = @CR & 'Click the yellow "Fix" button to remove the excess characters.'
			GUICtrlSetState  ($edithandlefix, $guishowit)
		Case $edittitleok = "invalchar"
			$ecewarnmessage  = "Menu titles cannot contain the following characters" & @CR & $invalchardisp & @CR
			$eceredmessage   = @CR & 'Click the yellow "Fix" button to remove the invalid characters.'
			GUICtrlSetState  ($edithandlefix, $guishowit)
		Case $editdupmessage <> ""
			$ecewarnmessage  = $editdupmessage
			$ececolor        = $myyellow
		Case $selectionarray [$ecesub] [$sOSType] = "clover"
			$ecewarnmessage  = 'Clover level = ' & SettingsGet ($setcloverdeployed)
			$editerrorok     = "yes"
		Case $selectionarray [$ecesub] [$sLoadBy] = $modecustom And CustomGetData ($ecesub) = ""
		   	$ecewarnmessage  = 'Custom code has not yet been entered'
			$ececolor        = $myyellow
			GUICtrlSetState   ($editlistcustedit, $guihideit)
			GUICtrlSetState   ($editpromptcust,   $guishowit)
			GUICtrlSetBkColor ($editpromptcust,   $myyellow)
			GUICtrlSetBkColor ($editpromptsample, $myyellow)
		Case $editpartselected <> ""
			$ecewarnmessage  = @CR & 'Please select the  ' & $editpartselected & "   partition"
			$ececolor        = $myyellow
		Case $selectionarray [$ecesub] [$sLoadBy] = $modecustom
			$editerrorok = "yes"
		Case $editparmok = "no" And ($ecebootby = $modepartlabel Or $ecebootby = $modehardaddress Or $ecebootby = $modepartuuid)
			$ecewarnmessage  = 'The Linux Boot Parm contains ' & $editparmlength & ' characters.   It should have 120 characters or less.'
		Case $ecebootby <> $modepartlabel And $ecebootby <> $modepartuuid And $ecebootby <> $modeandroidfile And $ecebootby <> $modephoenixfile _
			And $selectionarray [$ecesub] [$sOSType] <> $typechainfile And $selectionarray [$ecesub] [$sOSType] <> "clover"
			$editerrorok = "yes"
		Case $editsearchok = "kernelmissing"
			$ecewarnmessage = EditBootFileMessage ($ecesub, $ececaller, $ececolor)
		Case $editsearchok = "embedded"
			$ecewarnmessage   = 'The ' & $editbootroot & ' ' & $eceprompt & ' field must not contain embedded spaces.'
		Case $editsearchok = "no" And $ecebootby = $modepartlabel
			$ecewarnmessage   = 'The ' & $editbootroot & ' ' & $ecebootby & '   must be 1 to 16 characters and alphanumeric.' & @CR
			$ecewarnmessage  &= 'Periods "."  and  hyphens "-"  are allowed.'
		Case $editsearchok = "no" And ($ecebootby = $modeandroidfile Or $ecebootby = $modephoenixfile)
			$ecewarnmessage   = 'The   ' & $ecebootby & '   name must be 1 to 60 characters and alphanumeric.' & @CR
			$ecewarnmessage  &= 'Periods "."  and  hyphens "-"  and  "/"  are allowed.'
		Case Else
			$editerrorok = "yes"
	EndSelect
	If $editerrorok = "yes" Then
		GUICtrlSetBkColor ($edithandlewarn, $myorange)
		GUICtrlSetState   ($editbuttonok,   $guishowit)
	Else
		If $ececolor = $myred Then $ecewarnmessage &= $eceredmessage
		GUICtrlSetBkColor ($edithandlewarn,   $ececolor)
		GUICtrlSetState   ($edithandlewarn,   $guishowit)
		GUICtrlSetState   ($edithandledevice, $guihideit)
		GUICtrlSetState   ($editbuttonok,     $guishowdis)
		$focushandle      = $edithandlesrchr
	EndIf
	GUICtrlSetData        ($edithandlewarn, $ecewarnmessage)
EndFunc

Func EditBootFileMessage ($bfmsub, $bfmtype, ByRef $bfmcolor)
	$bfmfilename = BaseFuncCapIt ($selectionarray [$bfmsub] [$sOSType])
	$bfmwarnmessage = 'The specified ' & $bfmfilename & ' boot file was not found on any Windows partition.'        & @CR
	If $bfmtype <> "Type" And $bfmtype <> "Setup" Then
		$bfmextmsg  = @CR & @CR &'This can be normal if the ' & $bfmfilename & ' boot file is on a Linux ext partition.' & @CR & @CR
		$bfmrc = MsgBox ($mbwarnyesno, "", $bfmwarnmessage & $bfmextmsg & "Do you want disable Windows boot file checking for this menu entry?")
		If $bfmrc = $IDYES Then
			$selectionarray [$bfmsub] [$sFileLoadCheck] = $fileloaddisable
			$editerrorok     = "yes"
			Return ""
		EndIf
	EndIf
	$bfmcolor        = $myyellow
	$bfmwarnmessage &=                                                          @CR
	$bfmwarnmessage &= 'Please select a new ' & $bfmfilename & ' boot file.' & @CR
	$bfmwarnmessage &= 'Then click the Apply button below.'
	Return $bfmwarnmessage
EndFunc