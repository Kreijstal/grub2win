#include-once
#include  <g2common.au3>

Func FirmOrderRunGUI ($rgheader, ByRef $rgdisplay)
	If $handlemaingui <> "" Then GUISetState (@SW_MINIMIZE, $handlemaingui)
	$rgholdarray = $bcdorderarray
    $firmcancel  = ""
	FirmOrderRefresh ($rgheader, $rgdisplay)
	If Ubound ($bcdorderarray) = 0 Then
		BaseFuncGUIDelete   ($handleordergui)
		Return
	EndIf
	$ordercurrentstring = $rgdisplay
	$ordercurrbootpath  = $bcdorderarray [0] [$bPath]
	While 1
		$rgstatusarray = GUIGetMsg (1)
		$rghandle      = $rgstatusarray[1]
		If $rghandle   <> $handleordergui And $rghandle <> $handleorderscroll And $rghandle <> $handleorderbottom Then ContinueLoop
		$rgstatus      = $rgstatusarray [0]
		Select
			Case $rgstatus = $buttonorderreturn
				BaseFuncGUIDelete   ($handleordergui)
				Return
			Case $rgstatus = $orderefiforce
				FirmForceSet ($rgholdarray, $rgheader, $rgdisplay)
			Case $rgstatus = $buttonordercancel Or $firmcancel = "yes"
				$firmcancel         = ""
				$bcdorderarray      = $rgholdarray
				$rgdisplay          = BCDOrderSort ($bcdorderarray)
				$ordercurrentstring = $rgdisplay
				$efiforceload       = SettingsGet ($setefiforceload)
			Case $rgstatus = $buttonorderapply
				If Not FirmDefaultMsg ($bcdorderarray [0] [$bItemTitle], $rgholdarray) Then	ContinueLoop
				GUICtrlSetState ($buttonordercancel, $guihideit)
				$rgholdarray        = BCDSetFirmOrder ()
				$rgdisplay          = BCDOrderSort ($bcdorderarray)
				$ordercurrentstring = $rgdisplay
				FirmOrderRefresh ($rgheader, $rgdisplay)
				$ordercurrbootpath  = $bcdorderarray [0] [$bPath]
			Case $rgstatus = $orderdefaultgrub Or $rgstatus = $orderdefaultwin
				$rgtype = "grub2win"
				If $rgstatus = $orderdefaultwin Then $rgtype = "windows"
				If Not FirmDefaultMsg ($rgtype, $rgholdarray, "force") Then ContinueLoop
				BCDSetDefault ($rgtype)
				;_ArrayDisplay ($bcdorderarray, "Set FirmOrder")
				$ordercurrbootpath  = $bcdorderarray [0] [$bPath]
			Case $rgstatus = "" Or $rgstatus < 1
				ContinueLoop
			Case $rgstatus = $orderhelphandle
				CommonHelp ("EFI Firmware Order")
				ContinueLoop
			Case Else
				For $rglinecount = 0 To Ubound ($bcdorderarray) - 1
					Select
						Case $rgstatus = $handleorderup   [$rglinecount]
							;MsgBox ($mbontop, "Bump", $orderlinebump)
							$bcdorderarray[$rglinecount][$bSortSeq]     -= 110
							$bcdorderarray[$rglinecount][$bUpdateFlag]   = "moved"
							$bcdorderarray[$rglinecount][$bMouseUpDown]  = "up"     ; Mouse Up
						Case $rgstatus = $handleorderdown [$rglinecount]
							$bcdorderarray[$rglinecount][$bSortSeq]     += 110
							$bcdorderarray[$rglinecount][$bUpdateFlag]   = "moved"
							$bcdorderarray[$rglinecount][$bMouseUpDown]  = "down"   ; Mouse Down
						Case Else
							ContinueLoop
					EndSelect
				Next
		EndSelect
		FirmOrderRefresh ($rgheader, $rgdisplay)
	WEnd
EndFunc

Func FirmSetupParent ($spheader)
	BaseFuncGUIDelete ($handleordergui)
	$spheader &= "                           Slots = " & Ubound ($bcdorderarray)
	$handleordergui    = CommonScaleCreate ("GUI", $spheader , -1, -1, 104, 104, $WS_EX_STATICEDGE, -1, $handlemaingui)
	$orderdefaultgrub  = CommonScaleCreate ("Button",   "Set Grub2Win As Default",                2,    2, 20, 3.5)
	$orderefiforce     = CommonScaleCreate ("CheckBox", " Force Unconditional Load Of Grub2Win", 32,    2, 30, 3.5)
	$orderdefaultwin   = CommonScaleCreate ("Button",   "Set Windows As Default",                67,    2, 20, 3.5)
	$orderhelphandle   = CommonScaleCreate ("Button",   "Help",                                  90,    2,  8, 3.5)
	GUICtrlSetBkColor ($orderdefaultgrub, $mygreen)
	GUICtrlSetBkColor ($orderdefaultwin,  $mymedblue)
	GUICtrlSetBkColor ($orderhelphandle,  $mymedblue)
	;Msgbox ($mbontop, "Compare", "Original - " & $ordercurrentstring & @CR & "New - " & $spdisplay)
	FirmSetupBottom ()
	If $efileveldeployed = $setno Then
		SettingsPut     ($setefiforceload, "")
		GUICtrlSetState ($orderefiforce, $guihideit)
	EndIf
	$efiforceload = SettingsGet ($setefiforceload)
	GUISetState   (@SW_SHOW,   $handleordergui)
	GUISwitch     ($handleorderscroll)
EndFunc

Func FirmSetupBottom ()
	BaseFuncGUIDelete ($handleorderbottom)
	$handleorderbottom = CommonScaleCreate ("GUI", "", 0, 93, 104, 12, $WS_CHILD, "", _
		$handleordergui)
	$buttonordercancel = CommonScaleCreate ("Button",   "Cancel Pending Updates",                7, 0, 22, 3.5)
	$buttonorderreturn = CommonScaleCreate ("Button",   "Return To The Main Menu",              38, 0, 22, 3.5)
	$buttonorderapply  = CommonScaleCreate ("Button",   "Apply Updates",                        70, 0, 22, 3.5)
	GUISetState     (@SW_SHOW,   $handleorderbottom)
EndFunc

Func FirmOrderRefresh ($orheader, ByRef $ordisplay)
	;_ArrayDisplay ($bcdorderarray, "omarray " & $orderbootman)
	;MsgBox ($mbontop, "Refresh", "")
	BCDCheckDups ($bcdorderarray)
	$ordisplay          = BCDOrderSort ($bcdorderarray)
	$ormovehandle       = ""
	$ormoveupdown       = ""
	$orvert             = 0
	$orderlinebump      = 0
	$ordispgrub         = $guishowit
	$ordispwin          = $guishowit
	If $handleordergui  = "" Then FirmSetupParent ($orheader)
	If $orderbootman = 0 Then
		If $bcdorderarray [$orderbootman] [$bPath] = $efipathgrub    Then $ordispgrub = $guihideit
		If $bcdorderarray [$orderbootman] [$bPath] = $efipathwindows Then $ordispwin  = $guihideit
	Else
		$ordispgrub = $guishowit
		$ordispwin  = $guishowit
	EndIf
	If $efiforceload = "yes" Then
		$ordispgrub  = $guihideit
		$ordispwin   = $guihideit
	EndIf
	If $efileveldeployed = $setno Then $ordispgrub = $guihideit
	GUICtrlSetState ($orderdefaultgrub, $ordispgrub)
	GUICtrlSetState ($orderdefaultwin,  $ordispwin)
	;MsgBox ($mbontop, "Display ", $efiforceload & @CR & SettingsGet ($setefiforceload) & @CR & _
		;"Curr " & $ordercurrentstring & @CR & @CR & "Disp " & $ordisplay)
	If ($efileveldeployed <> $setno  And ($ordercurrentstring <> "" And $ordercurrentstring <> $ordisplay)) Or _
		$efiforceload <> SettingsGet ($setefiforceload) Or $bcdorderarray [0] [$bUpdateFlag] <> "" Then
		GUICtrlSetState ($buttonordercancel,  $guishowit)
		GUICtrlSetState ($buttonorderapply,   $guishowit)
		GUICtrlSetState ($buttonorderreturn,  $guihideit)
		GUICtrlSetState ($buttonorderapply,   $GUI_FOCUS)
	Else
		GUICtrlSetState ($buttonordercancel,  $guihideit)
		GUICtrlSetState ($buttonorderapply,   $guihideit)
		GUICtrlSetState ($buttonorderreturn,  $guishowit)
		GUICtrlSetState ($buttonorderreturn,  $GUI_FOCUS)
	EndIf
	$scrolltoppos      = CommonScrollDelete ($handleorderscroll)
	$handleorderscroll = CommonScaleCreate ("GUI", "", 0, 8, 104, 80, $WS_CHILD, "", _
		$handleordergui)
	$orlimit = Ubound ($bcdorderarray)
	Dim $orhandlelocup      [$orlimit + 1]
	Dim $orhandlelocdown    [$orlimit + 1]
	Dim $handleorderup      [$orlimit + 1]
	Dim $handleorderdown    [$orlimit + 1]
	Dim $handleorderdesc    [$orlimit + 1]
	Dim $handleorderpath    [$orlimit + 1]
	Dim $handleordergroup   [$orlimit + 1]
	$orlimit -= 1
	For $orlinecount = 0 To $orlimit
		If $orlinecount > $orlimit Then ExitLoop
		If $bcdorderarray [$orlinecount] [$bOrderType] <> $firmmanstring Then Continueloop
		$orgrouphighlight = ""
		$orvert   = (($orlinecount + $orderlinebump) * 10) + 5
		$orgroup  = "EFI firmware slot "
		$orgroup &= $orlinecount + 1
		$ordesc   = $bcdorderarray[$orlinecount][$bItemTitle] & @TAB
		$orpath   = "Path = " & StringLeft ($bcdorderarray[$orlinecount][$bPath], 49)
		If $bcdorderarray [$orlinecount] [$bPath] = "" Then $orpath = "Boot = Disk device"
		$handleorderpath [$orlinecount] = CommonScaleCreate ("Label", $orpath,         49, $orvert - 1.0 , 41, 6)
		$handleorderdesc [$orlinecount] = CommonScaleCreate ("Label", $ordesc, 18, $orvert - 1.0 , 27, 4.5)
		If $orlinecount = 0 Then
			$orgroup &= "          " & BaseFuncCapIt ($bcdorderarray[$orlinecount] [$bItemTitle]) & " Is The Default Firmware Boot Manager   "
			If StringInStr ($bcdorderarray [0] [$bPath], $efipathgrub) Then
				$orgrouphighlight = $mygreen
			ElseIf StringInStr ($bcdorderarray [0] [$bPath], $efipathwindows) Then
				$orgrouphighlight = $mylightgray
			Else
				$orgrouphighlight = $myorange
			EndIf
		EndIf
		;If $bcdorderarray [$orlinecount] [$bItemType] = $firmgrub Then $orderfirmboot = $bcdorderarray [$orlinecount] [$bGUID]
		If $bcdorderarray [$orlinecount] [$bUpdateFlag] = "moved"   Then  GUICtrlSetBkColor($handleorderdesc [$orlinecount], $mypurple)
		If $bcdorderarray [$orlinecount] [$bUpdateFlag] = "default" Then  GUICtrlSetBkColor($handleorderdesc [$orlinecount], $mygreen)
		$bcdorderarray    [$orlinecount] [$bUpdateHold] = $bcdorderarray [$orlinecount] [$bUpdateFlag]
		                 $handleorderup   [$orlinecount] = CommonScaleCreate("Label", "↑", 92, $orvert - 3.9, 2, 3.9)
		GUICtrlSetFont  ($handleorderup   [$orlinecount], $fontsizelarge, 100)
		GUICtrlSetColor ($handleorderup   [$orlinecount], $mylightgray) ; Move Up
		$orhandlelocup  [$orlinecount] = CommonScaleCreate("Label", "", 92.6, $orvert - 1.7, 0, 0)
		;GUICtrlSetGraphic ($orhandlelocup  [$orlinecount], $GUI_GR_Pixel, 1,1)
		;GUICtrlSetBkColor ($orhandlelocup  [$orlinecount], $myred) ; Move Up Pixel
		GUICtrlSetState ($orhandlelocup [$orlinecount], $guihideit)
		                 $handleorderdown  [$orlinecount] = CommonScaleCreate("Label", "↓", 92, $orvert + 0.2, 2, 3.9)
		GUICtrlSetFont  ($handleorderdown  [$orlinecount], $fontsizelarge, 100)
		GUICtrlSetColor ($handleorderdown  [$orlinecount], $mylightgray) ; Move Down
		$orhandlelocdown  [$orlinecount] = CommonScaleCreate("Label", "", 92.6, $orvert +2.3, 0, 0)
		;GUICtrlSetGraphic ($orhandlelocdown  [$orlinecount], $GUI_GR_Pixel, 1,1)
		;GUICtrlSetBkColor ($orhandlelocdown  [$orlinecount], $myred) ; Move Down Pixel
		GUICtrlSetState   ($orhandlelocdown  [$orlinecount], $guihideit)
		If $orlinecount < 1 Or $efiforceload = "yes" Or ($orlinecount = 1 And $bcdorderarray[$orlinecount][$bPath] = "") Then _
			GUICtrlSetState ($handleorderup [$orlinecount], $guihideit)
		If $orlinecount = 0 Or $orlinecount >= $orlimit Or $efiforceload = "yes" Then GUICtrlSetState ($handleorderdown [$orlinecount], $guihideit)
		If $bcdorderarray [$orlinecount] [$bMouseUpDown] =  "up"   Then $ormovehandle = $orhandlelocup          [$orlinecount]
		If $bcdorderarray [$orlinecount] [$bMouseUpDown] =  "down" Then $ormovehandle = $orhandlelocdown        [$orlinecount]
		If $bcdorderarray [$orlinecount] [$bMouseUpDown] <> ""     Then $ormoveupdown = $bcdorderarray [$orlinecount] [$bMouseUpDown]
		   $bcdorderarray [$orlinecount] [$bMouseUpDown] =  ""
		$handleordergroup [$orlinecount] = CommonScaleCreate ("Group", $orgroup,  1, $orvert - 4, 88, 8)
		If $orgrouphighlight <> "" Then GUICtrlSetBkColor ($handleordergroup [$orlinecount], $orgrouphighlight)
		$bcdorderarray [$orlinecount][$bSortSeq] = ($orlinecount + 1) * 100
	Next
	;_ArrayDisplay ($bcdorderarray, $ormovehandle & "  " & $orhandlelocdown  [1])
	CommonControlGet ($handleordergui, $ormovehandle, $dummyparm)
	$scrollmaxvsize = Int ($scalepctvert * ($orvert) + 25)
	CommonScrollGenerate ($handleorderscroll, $scalehsize, $scrollmaxvsize)
	If $ormovehandle <> "" Then _
		CommonScrollMove ($handleordergui, $handleorderscroll, $ormovehandle, $ormoveupdown, 4)
	If $efiforceload = "yes" Then
		GUICtrlSetState ($orderefiforce, $GUI_CHECKED)
		GUISetBkColor ($mymedgray, $handleordergui)
		GUISetBkColor ($mymedgray, $handleorderscroll)
		GUISetBkColor ($mymedgray, $handleorderbottom)
	Else
		GUICtrlSetState ($orderefiforce, $GUI_UNCHECKED)
		GUISetBkColor ($mymedblue, $handleordergui)
		GUISetBkColor ($mymedblue, $handleorderscroll)
		GUISetBkColor ($mymedblue, $handleorderbottom)
	EndIf
	GUISetState     (@SW_SHOW, $handleorderscroll)
EndFunc

Func FirmForceSet (ByRef $fsholdarray, $fsheader, $fsdisplay)
	$fsforcesave  = $efiforceload
	$efiforceload = $setno
	$fsmsg        = "use normal EFI boot order" & @CR & @CR
	If CommonCheckBox ($orderefiforce) Then
		$efiforceload = "yes"
		$fsmsg        = "force the unconditional load of Grub2Win" & @CR & @CR & @TAB
	EndIf
	$fsmsg = 'Click "OK" to ' & $fsmsg
	If Not CommonQuestion ($mbinfookcan, "** Confirm Change To EFI Firmware Priority **",  _
		$fsmsg & @TAB & 'Or click "Cancel"') Then
			$efiforceload = $fsforcesave
			Return
	EndIf
	If $efiforceload = "yes" Then
		$bcdorderarray      = $fsholdarray
		$fsdisplay          = BCDOrderSort ($bcdorderarray)
		$ordercurrentstring = $fsdisplay
		BCDSetDefault ("grub2win")
	Else
		$fsholdarray = BCDSetFirmOrder ()
	EndIf
	SettingsPut ($setefiforceload,   $efiforceload)
	EFIMain     ($actionrefresh,     $handleordergui, $firmwarestring)
	FirmOrderRefresh  ($fsheader, $fsdisplay)
EndFunc

Func FirmDefaultMsg ($dmdesc, ByRef $dmholdarray, $dmforcemsg = "")
	If $dmforcemsg = "" And $ordercurrbootpath = $bcdorderarray [0] [$bPath] Then Return 1
	$dmdesc    = BaseFuncCapit ($dmdesc)
	$dmdefmsg  = 'When you click "OK" your firmware default will be' & @CR
	$dmdefmsg &= 'set to run ' & $dmdesc & ' every time you boot your PC' & @CR & @CR
	If CommonQuestion ($mbinfookcan, "Set " & $dmdesc & " As Default", $dmdefmsg) Then
		CommonWriteLog   ()
		CommonWriteLog   ("    Now Setting " & $dmdesc)
		CommonWriteLog   ("    As The Default EFI Boot Manager")
		$bcdfirstrun    = ""
		Return 1
	EndIf
	MsgBox ($mbinfook, "", "Set " & $dmdesc & " as default has been cancelled", 5)
	$firmcancel    = "yes"
	$bcdorderarray = $dmholdarray
EndFunc