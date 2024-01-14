#include-once
#include  <g2common.au3>

Func SelectionRunGUI ()
	;_ArrayDisplay ($selectionarray, "Before")
	SelectionRefresh ()
	;_ArrayDisplay ($selectionarray, "After")
	While 1
		$rgstatusarray = GUIGetMsg(1)
		If $rgstatusarray[1] <> $handleselectiongui And $rgstatusarray[1] <> $handleselectionscroll Then ContinueLoop
		$selectionstatus = $rgstatusarray[0]
		Select
			Case $selectionstatus = $GUI_EVENT_CLOSE Or $selectionstatus = $buttonselectioncancel Or $selectionstatus = $buttonselectionapply
				BaseFuncGUIDelete($handleselectiongui)
				If $selectionstatus <> $buttonselectionapply Then
					FileCopy ($usersectionorig, $usersectionfile, 1)
					GetPrevMiscArray       ()
					$selectionarray    = $selectionholdarray
					$defaultlastbooted = $selectionholdlastbooted
					$bcdwinorder       = $bcdwinmenuhold
					$editmenuerrors    = CommonSelectVerify ()
				EndIf
				CommonSetupDefault  ()
				$handleselectiongui = ""
				Return
			Case $selectionstatus = "" Or $selectionstatus = 0 Or $selectionstatus < 0
				ContinueLoop
			Case $selectionstatus = $selectionhelphandle
				CommonHelp ("Managing the Boot Menu")
				ContinueLoop
			Case $selectionstatus = $handlelastbooted
				SelectionLastBooted ()
			Case $selectionstatus = $buttonselectionadd
				SelectionAdd ()
			Case $selectionstatus = $buttonimportlinux Or $selectionstatus = $buttonimportchrome
				If $selectionstatus = $buttonimportlinux  Then $importtype = "Linux"
				If $selectionstatus = $buttonimportchrome Then $importtype = "Chrome"
				ImportRunGUI ()
				$scrollforcebottom = "yes"
			Case $selectionstatus = $handleusergroup
				CustomUserSectionEdit ("Update")
			Case $selectionstatus = $buttonselectionremove
				CustomUserSectionEdit ("Removal")
			Case Else
				For $rgentrysub = 0 To $selectionarraysize - 1
					;_ArrayDisplay ($selectiontransarray)
					If $rgentrysub > $selectionlimit Then ExitLoop
					Select
						Case $selectionstatus = $handleselectiondefault [$rgentrysub]
							$defaultos = $rgentrysub
							CommonDefaultSync ()
						Case $selectionstatus = $handleselectionup  [$rgentrysub]
							$selectionarray[$rgentrysub][$sSortSeq] -= 110
							$selectionarray[$rgentrysub][$sUpdateFlag]  = "updated"
							$selectionarray[$rgentrysub][$sMouseUpDown] = "up"    ; Mouse Up
						Case $selectionstatus = $handleselectiondown[$rgentrysub]
							$selectionarray[$rgentrysub][$sSortSeq] += 110
							$selectionarray[$rgentrysub][$sUpdateFlag]  = "updated"
							$selectionarray[$rgentrysub][$sMouseUpDown] = "down"  ; Mouse Down
						Case $selectionstatus = $handleselectiondel [$rgentrysub]
							SelectionDelete ($rgentrysub)
						Case $selectionstatus = $handleselectionbox [$rgentrysub]
                            $editholdarray = $selectionarray
							EditRunGUI ($rgentrysub)
						Case Else
							ContinueLoop
					EndSelect
					SelectionRefresh ()
				Next
				ContinueLoop
		EndSelect
		SelectionRefresh ()
	WEnd
EndFunc

Func SelectionSetupParent ()
	BaseFuncGUIDelete   ($handleselectiongui)
	$handleselectiongui   = CommonScaleCreate ("GUI", ""                ,                    -1, -1, 103.5, 100, -1, "", $handlemaingui)
	$selectionhelphandle  = CommonScaleCreate ("Button",   "Help",                           90, 2,   8,   3.5)
	$handlelastbooted     = CommonScaleCreate ("Checkbox", " Default = The Last Booted OS",   6, 2,  27,   3.5)
	$defaultlastbooted    = "no"
	If $defaultselect     = $lastbooted Then $defaultlastbooted = "yes"
	If $defaultlastbooted = "yes" Then GuiCtrlSetState ($handlelastbooted, $GUI_CHECKED)
	GUICtrlSetBkColor ($selectionhelphandle, $mymedblue)
	If  $selectionentrycount < 40 Then
		$buttonselectionadd  = CommonScaleCreate ("Button", "Add A New Entry",   42, 2, 13, 3.5)
		GUICtrlSetBkColor($buttonselectionadd, $myorange)
	EndIf
	                         CommonScaleCreate ("Group",  "  Import Configuration File  ", 62, 0, 24, 6.4,  $BS_CENTER)
	$buttonimportlinux     = CommonScaleCreate ("Button", "Linux",                         64, 2,  8, 3.8)
	$buttonimportchrome    = CommonScaleCreate ("Button", "Chrome",                        76, 2,  8, 3.8)
	GUICtrlSetBkColor ($buttonimportlinux,  $mymedblue)
	GUICtrlSetBkColor ($buttonimportchrome, $mymedblue)
	$buttonselectioncancel = CommonScaleCreate ("Button", "Cancel", 10, 95, 10, 3.8)
	$speditmessage         = CommonScaleCreate ("Label",  "To customize an entry - Click it", 39.5, 96, 20, 2.5, $SS_Center)
	GUICtrlSetBkColor     ($speditmessage, $mygreen)
	$buttonselectionapply  = CommonScaleCreate ("Button", "Apply",  80, 95, 10, 3.8)
	$scrolltoppos = 0
	GUISetBkColor($myblue,  $handleselectiongui)
	GUISetState  (@SW_SHOW, $handleselectiongui)
	GUISwitch              ($handleselectionscroll)
EndFunc

Func SelectionRefresh()
	;_ArrayDisplay ($selectionarray, "Refresh")
	_ArraySort ($selectionarray, 0, 0, 0, $sSortSeq)
	SelectionSequenceUpdate ()
	$selectionentrycount = UBound ($selectionarray)
	$selectionlimit      = $selectionentrycount - 1
	$edithotkeywork      = $hotkeystring
	$cloverfound         = ""
	Local $srmovehandle, $srmoveupdown
	If $handleselectiongui = "" Then SelectionSetupParent ()
	WinSetTitle ($handleselectiongui, "", "Grub2Win Menu Configuration     Total Entries = " &  $selectionentrycount - $selectionmisccount)
	$scrolltoppos = CommonScrollDelete ($handleselectionscroll)
	$handleselectionscroll = CommonScaleCreate ("GUI", "", 0, 6, 103.5, 88, $WS_CHILD, "", $handleselectiongui)
	CommonParmCalc (0, "Reset")
	$selectionarraysize = Ubound ($selectionarray)
	Dim $handleselectiondefault [$selectionarraysize]
	Dim $handleselectionup      [$selectionarraysize]
	Dim $handleselectiondown    [$selectionarraysize]
	Dim $srhandlelocup          [$selectionarraysize]
	Dim $srhandlelocdown        [$selectionarraysize]
	Dim $handleselectiondel     [$selectionarraysize]
	Dim $handleselectiongroup   [$selectionarraysize]
	Dim $handleselectionbox     [$selectionarraysize]
	$windowstypecount   = 0
	$srvert             = 0
	$sruserbump         = 0
	$sruserend          = 0
	$editmenuerrors     = CommonSelectVerify ()
	For $srlinecount  = 0 To $selectionarraysize
		;MsgBox ($mbontop, $srlinecount, $selectionarraysize)
		If $srlinecount > $selectionlimit Then ExitLoop
		$srvert = ($srlinecount * 15) + 5 + $sruserbump
		CommonArraySetDefaults ($srlinecount)
		;_ArrayDisplay ($selectionarray)
		If $selectionarray [$srlinecount] [$sAutoUser] = "user" Then
			If $sruserbump = 0 Then
				$srusercount = $selectionarraysize - $srlinecount
				$srusersize  = ($srusercount * 15)   + 10
				$sruserend   = $srvert + $srusersize + 9
				$handleusergroup       = CommonScaleCreate ("Label",  "", 8,   $srvert + 5,   87.6, $srusersize + 0.6)
					                     CommonScaleCreate ("Label",  "", 8.6, $srvert + 5.6, 86.4, $srusersize - 0.6)
										 CommonScaleCreate ("Label",  "This Is The User Section" & @CR & "Click here to Edit", 39, $srvert + 4.5, 18, 6, $SS_Center)
		        $buttonselectionremove = CommonScaleCreate ("Button", "Remove The User Section",  40, $sruserend,    19, 3.5)
				GUICtrlSetBkColor ($handleusergroup,       $myorange)
				GUICtrlSetBkColor ($buttonselectionremove, $mymedblue)
				$sruserbump  = 15
				$srvert     += 15
			EndIf
		EndIf
		$srtitle       = $selectionarray[$srlinecount][$sEntryTitle]
		$srentrystring = StringMid (" " & $srtitle & " ", 1, 100)
		$handleselectionbox   [$srlinecount] = CommonScaleCreate ("Label", "",             10, $srvert - 3.2, 83, 13)
		$handleselectiongroup [$srlinecount] = CommonScaleCreate ("Group", $srentrystring, 10, $srvert - 4, 83, 13.5)
		If $selectionarray[$srlinecount][$sUpdateFlag] = "updated" Then GUICtrlSetBkColor ($handleselectiongroup[$srlinecount], $myorange)
		If $selectionarray [$srlinecount] [$sOSType] = "nomenu" Then
			$srnomenustring  = ""
			For $srnomenusub = 0 To Ubound ($miscarray) - 1
				$srnomenustring &= $miscarray [$srnomenusub] & @CR
			Next
			CommonScaleCreate ("Label", $srnomenustring, 37, $srvert - 1.7 , 41, 10)
			ContinueLoop
		EndIf
		$sriconpath   = $iconpath & "\" & $selectionarray [$srlinecount] [$sIcon] & ".png"
		$handleselectiondefault [$srlinecount] = CommonScaleCreate ("Checkbox", "", 6, $srvert - 4.4, 2, 3)
		GuiCtrlSetState ($handleselectiondefault [$srlinecount], $GUI_UNCHECKED)
		If $defaultlastbooted = "yes" Or $selectionarray[$srlinecount] [$sReboot] <> "" Then
			GuiCtrlSetState ($handleselectiondefault [$srlinecount], $guihideit)
			$selectionarray[$srlinecount][$sDefaultOS] = ""
		EndIf
		If $selectionarray[$srlinecount][$sDefaultOS] = "DefaultOS"  Then
			$srdefstring = "       ** Grub Default **         "
			GUICtrlSetState   ($handleselectiondefault [$srlinecount], $GUI_CHECKED)
			GUICtrlSetData    ($handleselectiongroup   [$srlinecount], StringMid ($srdefstring & " " & $srtitle & " ", 1, 100))
			GUICtrlSetBkColor ($handleselectiongroup   [$srlinecount], $mygreen)
		EndIf
		CommonScaleCreate ("PicturePNG", $sriconpath, 12, $srvert + 0.1, 4,   5)
		If $selectionarray[$srlinecount][$sHotKey] <> "no" Then
			$srhklen = 7.4 + (StringLen ($selectionarray[$srlinecount][$sHotKey]) * 0.75)
			CommonScaleCreate("Label", "  Hotkey = " & $selectionarray[$srlinecount][$sHotKey], 78, $srvert - 4, $srhklen, 3)
			$edithotkeywork = StringReplace ($edithotkeywork, "|" & $selectionarray[$srlinecount][$sHotKey] & "|", "|")
		EndIf
		$srhandlenumber = CommonScaleCreate("Label", $srlinecount, 92.8 - (Stringlen ($srlinecount) * .4), $srvert + 1.6, Stringlen ($srlinecount), 2.8)
		GUICtrlSetColor ($srhandlenumber, $myred)
		CommonScaleCreate("Label", "Type = "   & $selectionarray[$srlinecount][$sOSType], 18, $srvert + 0.0, 15, 5)
		$srdiskr = "Root " & $modehardaddress & " =  " & $selectionarray[$srlinecount][$sRootDisk]
		$srdiskb = "Boot " & $modehardaddress & " =  " & $selectionarray[$srlinecount][$sBootDisk]
		If $selectionarray [$srlinecount] [$sFamily] <> "standfunc" Or $selectionarray [$srlinecount] [$sOSType] = "clover" Then _
			CommonScaleCreate ("Label", "Graph = " & $selectionarray[$srlinecount][$sGraphMode],  79, $srvert, 13, 3)
		$srpause = "Pause = " &  $selectionarray[$srlinecount][$sReviewPause]
		If $selectionarray[$srlinecount][$sReviewPause] = 0 Then $srpause = "Pause Is Off"
		CommonScaleCreate ("Label", $srpause, 79, $srvert + 4, 13, 3.3)
		If $selectionarray [$srlinecount] [$sAutoUser] = "auto" Then
			If $srlinecount > 0 Then $handleselectionup [$srlinecount] = CommonScaleCreate("Label", "↑", 97, $srvert - 3.0, 2, 5)
			GUICtrlSetFont    ($handleselectionup [$srlinecount], $fontsizelarge, 100)
			GUICtrlSetColor   ($handleselectionup [$srlinecount], $mymedgray)                ; Move Up
			$srhandlelocup [$srlinecount] = CommonScaleCreate("Label", "", 97.6, $srvert - 0.5, 0, 0)
			GUICtrlSetState ($srhandlelocup [$srlinecount], $guihideit)
			If $selectionlimit > 0 Then $handleselectiondel[$srlinecount] = CommonScaleCreate ("Button", "Delete", 2, $srvert + 0.8, 6, 3.3)
			GUICtrlSetBkColor($handleselectiondel[$srlinecount], $myblue)
			$srmovelimit = $srlinecount + 1
			If $srmovelimit > $selectionlimit Then $srmovelimit = $srlinecount
			If $selectionarray [$srmovelimit] [$sAutoUser] = "user" Then $srmovelimit = $srlinecount
			If $srlinecount < $srmovelimit Then $handleselectiondown[$srlinecount] = CommonScaleCreate("Label", "↓", 97, $srvert + 3.0, 2, 5)
			GUICtrlSetFont    ($handleselectiondown [$srlinecount], $fontsizelarge, 100)
			GUICtrlSetColor   ($handleselectiondown [$srlinecount], $mymedgray)              ; Move Down
			$srhandlelocdown [$srlinecount] = CommonScaleCreate ("Label", "", 97.6, $srvert + 5.5, 0, 0)
			GUICtrlSetState ($srhandlelocdown [$srlinecount], $guihideit)
		EndIf
		Local $srparmprompt = "", $srparmdisplay = ""
		If StringInStr ($selectionarray[$srlinecount][$sFamily], "linux") Then
			If  $selectionarray[$srlinecount][$sLoadBy] = $modepartlabel Then
				$srdiskr = "Root Partition Label = " & CommonGetSearch ($selectionarray[$srlinecount][$sRootDisk], "Label")
				$srdiskb = "Boot Partition Label = " & CommonGetSearch ($selectionarray[$srlinecount][$sBootDisk], "Label")
			ElseIf $selectionarray[$srlinecount][$sLoadBy] = $modepartuuid Then
				$srdiskr = "Root Partition UUID = "  & CommonGetSearch ($selectionarray[$srlinecount][$sRootDisk], "UUID")
				$srdiskb = "Boot Partition UUID = "  & CommonGetSearch ($selectionarray[$srlinecount][$sBootDisk], "UUID")
			ElseIf $selectionarray[$srlinecount][$sLoadBy] = $modeandroidfile Or $selectionarray[$srlinecount][$sLoadBy] = $modephoenixfile Then
				$srdiskr = "Kernel File = " & $selectionarray[$srlinecount][$sRootSearchArg]
			Else
				$srconvr = CommonConvDevAddr ($selectionarray [$srlinecount] [$sRootDisk])
				If $srconvr <> "" Then $srdiskr &= "    (" & $srconvr & ")"
				$srconvb = CommonConvDevAddr ($selectionarray [$srlinecount] [$sBootDisk])
				If $srconvb <> "" Then $srdiskb &= "    (" & $srconvb & ")"
			EndIf
			If $selectionarray [$srlinecount][$sLoadBy] <> $modechaindisk Then
				$srparm = CommonParmCalc ($srlinecount, "Previous")
				$srparmprompt  = "Parm = "
				$srparmdisplay = StringLeft ($srparm, 70)
				$srparmextra   = StringMid  ($srparm, 71, 70)
				If $srparmextra <> "" Then $srparmdisplay &= $srparmextra
				$srparmdisplay = '"' & $srparmdisplay & '"'
			EndIf
		EndIf
		If $srparmprompt <> "" Then
			CommonScaleCreate ("Label", $srparmprompt,  32, $srvert + 4,  5, 3.6)
			CommonScaleCreate ("Label", $srparmdisplay, 37, $srvert + 4, 41, 4.5)
		EndIf
		If $selectionarray[$srlinecount][$sLoadBy] = $modechaindisk Then  _
			$srdiskr = "          The Disk Address Is "  & $selectionarray [$srlinecount] [$sChainDrive]
		If $selectionarray[$srlinecount][$sLoadBy] = $modechainfile Then  _
			$srdiskr = "          The Chainload File Path Is " & $selectionarray [$srlinecount] [$sRootSearchArg]
		If $selectionarray [$srlinecount] [$sLoadBy] = $modeandroidfile Then _
			$srdiskr = $modeandroidfile & " = " & $selectionarray[$srlinecount][$sRootSearchArg]
		If $selectionarray [$srlinecount] [$sLoadBy] = $modephoenixfile Then _
			$srdiskr = $modephoenixfile & " = " & $selectionarray[$srlinecount][$sRootSearchArg]
		If $selectionarray[$srlinecount][$sOSType]   = "windows"  Then
			$windowstypecount += 1
			If $firmwaremode = "EFI" Then $selectionarray [$srlinecount] [$sLoadBy] = $modewinauto
		EndIf
		If $selectionarray[$srlinecount][$sLoadBy] = $modewinauto Then $srdiskr = "Partition Boot Address = Automatic"
		If $selectionarray[$srlinecount][$sFamily] = "standfunc"  Then $srdiskr = ""
		If $selectionarray[$srlinecount][$sLoadBy] = $modewinauto And $firmwaremode = "EFI" Then
			SelectionWinEFI ($srvert)
		ElseIf $selectionarray[$srlinecount][$sLoadBy] = $modecustom And $selectionarray[$srlinecount][$sAutoUser] = "auto" Then
			$srcust = CommonScaleCreate("Label", "**  Custom Configuration **", 32, $srvert, 25, 2.8, $SS_Center)
		    GUICtrlSetBkColor ($srcust, $mymedblue)
		ElseIf $selectionarray[$srlinecount][$sOSType] = "clover" Then
			$cloverfound      = "yes"
			CommonScaleCreate ("Label", "Level = " & SettingsGet ($setcloverdeployed), 32, $srvert, 25, 2.8)
		ElseIf $selectionarray[$srlinecount][$sAutoUser] = "user" Then
		Else
			If $selectionarray [$srlinecount][$sLayout] = $layoutboth Then $srvert -= 2
			If $selectionarray [$srlinecount][$sOSType] ="submenu" Then $srdiskr = ""
			;MsgBox ($mbontop, "UUID B", $srdiskr & @CR & "Root Partition UUID = "  & $selectionarray[$srlinecount][$sRootSearchArg])
			$srdisplayr = CommonScaleCreate("Label", $srdiskr, 32, $srvert, 45, 4.5)
			If StringLeft ($selectionarray [$srlinecount] [$sDiskError], 6) = "search" Then GUICtrlSetBkColor ($srdisplayr, $myred)
			$srvert += 3
			If $selectionarray[$srlinecount][$sLayout] = $layoutboth Then
				$srdisplayb = CommonScaleCreate("Label", $srdiskb, 32, $srvert, 45, 4.5)
				If StringRight ($selectionarray [$srlinecount] [$sDiskError], 4) = "boot" Then GUICtrlSetBkColor ($srdisplayb, $myred)
				$srvert += 3
			EndIf
		EndIf
		If $selectionarray [$srlinecount] [$sMouseUpDown] =  "up"   Then $srmovehandle = $srhandlelocup   [$srlinecount]
		If $selectionarray [$srlinecount] [$sMouseUpDown] =  "down" Then $srmovehandle = $srhandlelocdown [$srlinecount]
		If $selectionarray [$srlinecount] [$sMouseUpDown] <> ""     Then $srmoveupdown = $selectionarray  [$srlinecount] [$sMouseUpDown]
    	$selectionarray    [$srlinecount] [$sMouseUpDown] =  ""
	Next
	If $sruserend <> 0 Then
		$srvert = $sruserend
		If $scrollforcebottom = "yes" Then $scrolltoppos = 100
		$scrollforcebottom    = ""
	EndIf
	CommonControlGet  ($handleselectiongui, $srmovehandle, $dummyparm)
	$scrollmaxvsize = Int($scalepctvert * ($srvert + 10))
	CommonScrollGenerate ($handleselectionscroll, $scalehsize, $scrollmaxvsize)
	If $srmovehandle <> "" Then _
		CommonScrollMove ($handleselectiongui, $handleselectionscroll, $srmovehandle, $srmoveupdown, 7)
	GUICtrlSetState ($buttonselectionapply, $GUI_FOCUS)
	GUISetBkColor($myblue,  $handleselectionscroll)
	GUISetState  (@SW_SHOW, $handleselectionscroll)
	;_Arraydisplay ($selectionarray)
EndFunc

Func SelectionDelete($mdsub)
	If $selectionarray [$mdsub] [$sOSType] = "windows" Then
		If Not CommonQuestion ($mbwarnyesno, "*** Warning ***", "This will delete your Windows boot entry!", "Are you absolutely sure?") Then Return
	EndIf
	If Not CommonQuestion ($mbinfookcan, "", 'Deleting menu entry number   ' & $mdsub & '   "' &      _
		$selectionarray [$mdsub] [$sEntryTitle] & '"' , 'Click OK or Cancel') Then Return
	If $selectionarray [$mdsub] [$sDefaultOS] = "DefaultOS" Then $selectionarray[0][$sDefaultOS] = "DefaultOS"
	;If $selectionarray [$mdsub] [$sCustomName] <> "" Then FileDelete ($custconfigstemp & "\" & $selectionarray [$mdsub] [$sCustomName])
	_ArrayDelete($selectionarray, $mdsub)
	;SelectionRefresh ()
EndFunc

Func SelectionAdd()
	$editholdarray = $selectionarray
	$malimit = UBound($selectionarray)
	If $malimit = 0 Then Dim $selectionarray[1][$selectionfieldcount + 1]
	ReDim $selectionarray[$malimit + 1][$selectionfieldcount + 1]
	$selectionarray[$malimit][$sLoadBy] = ""
	CommonArraySetDefaults($malimit, "yes")
	$selectionarray [$malimit] [$sBootParm] = CommonParmCalc ($malimit, "Standard", "Reset")
	SelectionRefresh ()
	FileCopy      ($sourcepath & $templateempty, $customworkfile, 1)
	EditRunGUI    ($selectionautohigh)
	$sabump = Int ((Ubound ($selectionarray) / 2))
	If $editnewentry < 6 Then $sabump = 0
	$sanewpos = $sabump * ($editnewentry - 3)
	If $sanewpos < 9 Then $sanewpos = 0
	If _GUIScrollBars_GetScrollInfoPage ($handleselectionscroll, $SB_VERT) < 1 Then Return
	_GUIScrollBars_SetScrollInfoPos     ($handleselectionscroll, $SB_VERT, $sanewpos)
EndFunc

Func SelectionSequenceUpdate ()
	For $msusub = 0 To Ubound ($selectionarray) - 1
		If $selectionarray[$msusub][$sAutoUser] = "user" Then
			$selectionarray[$msusub][$sSortSeq] = 9000 + $msusub
		Else
			$selectionarray[$msusub][$sSortSeq] = ($msusub * 100) + 10
			$selectionautohigh  = $msusub
		EndIf
	Next
EndFunc

Func SelectionLastBooted ()
	If CommonCheckBox ($handlelastbooted) Then
		$defaultlastbooted = "yes"
	Else
		$defaultlastbooted = "no"
		CommonDefaultSync  ()
	EndIf
	;MsgBox ($mbontop, "Last Booted", $defaultlastbooted)
EndFunc

Func SelectionWinEFI ($mwvertstart)
	_ArraySort ($bcdwinorder, 0, 0, 0, $bSortSeq)
	$mwlimit = Ubound ($bcdwinorder) - 1
	$mwvert  = ($mwvertstart + 2) - ($mwlimit * 2)
	For $mwsub = 0 To $mwlimit
		$mwline  = "     Instance " & $mwsub + 1 & "     Drive - " & $bcdwinorder [$mwsub] [$bDrive]
		$mwline &= "       "           & $bcdwinorder [$mwsub] [$bItemTitle]
		CommonScaleCreate("Label", $mwline, 31, $mwvert + 1, 40, 3)
		$mwvert += 2.5
		If $mwvert - $mwvertstart > 6 Then ExitLoop
	Next
	;_ArrayDisplay ($bcdwinorder, "Win Order   Timeout = " & $bcdprevtime & "  " & $mwvert)
EndFunc