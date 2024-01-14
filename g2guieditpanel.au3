#include-once
#include  <g2common.au3>

Func EditPanelRefresh ($prsub, $prcreate = "")
	;_ArrayDisplay ($selectionarray, EditPanelGetMode ($prsub, ""))
	;MsgBox ($mbontop, "Panel Refresh", $selectionarray [$prsub] [$sOSType] & @CR & $selectionarray [$prsub] [$sLoadBy], 1)
	EditPanelLoadBy      ($prsub, $prcreate)
	EditPanelDiskAddress ($prsub, $prcreate)
	If $selectionarray [$prsub] [$sOSType] <> "windows" Then EditPanelSearch      ($prsub, $prcreate)
	EditPanelCustom      ($prsub, $prcreate)
	EditPanelWindowsEFI  ($prsub, $prcreate)
	EditPanelIcon        ($prsub, $prcreate)
	;_ArrayDisplay ($selectionarray)
EndFunc

Func EditPanelLoadBy ($plsub, $plcreate = "")
	$plstatus     = $guihideit
	If EditPanelGetMode ($plsub, "") <> "" Then	$plstatus = $guishowit
	$plmodestring = EditPanelGetMode ($plsub)
	If $plcreate  <> "" Then
		$editpromptloadby  = CommonScaleCreate ("Label", "Load The Kernel By", 26,  10,  13, 3, $SS_Right)
		$edithandleloadlab = CommonScaleCreate ("Label", "",                   40,  10,  18, 3)
		$edithandleloadby  = CommonScaleCreate ("Combo", "",                   40,  9.8, 25, 20.5, -1)
	EndIf
	$plcombostatus  = $plstatus
	$pllabelstatus  = $plstatus
	$pllayoutstatus = $plstatus
	If $editlinpartcount < 2 Then
		$pllayoutstatus = $guihideit
		If $selectionarray [$plsub] [$sLayout] = $layoutboth Then $selectionarray [$plsub] [$sLayout] = $layoutrootonly
	EndIf
	If  CommonStringCount ($plmodestring, "|") = 1 Then
		GUICtrlSetData  ($edithandleloadlab, $selectionarray [$plsub] [$sLoadBy])
		$plcombostatus = $guihideit
	Else
		GUICtrlSetData ($edithandleloadby, $plmodestring, $selectionarray [$plsub] [$sLoadBy])
		$pllabelstatus = $guihideit
	EndIf
	$pslayout = $selectionarray [$plsub] [$sLayout]
	If $pslayout = "" Then $pslayout = $layoutrootonly
	GUICtrlSetData  ($edithandlelayout,  $layoutstring,  $pslayout)
	GUICtrlSetState ($editpromptloadby,  $plstatus)
	GUICtrlSetState ($edithandleloadlab, $pllabelstatus)
	GUICtrlSetState ($edithandleloadby,  $plcombostatus)
	If Not StringInStr ($selectionarray  [$plsub] [$sLoadBy], "Partition") Then $plstatus = $guihideit
	GUICtrlSetState ($editpromptlayout,  $pllayoutstatus)
	GUICtrlSetState ($edithandlelayout,  $pllayoutstatus)
EndFunc

Func EditPanelDiskAddress ($dasub, $dacreate)
	Local $dacombodata, $dacombodefaultr, $dacombodefaultb
	;_ArrayDisplay ($selectionarray)
	If $dacreate <> "" Then
		$editpromptlayout    = CommonScaleCreate ("Label", "Partition Layout",        65, 10,   12, 3, $SS_Right)
		$edithandlelayout    = CommonScaleCreate ("Combo", "",                        78, 9.8,  20, 20.5, -1)
		$editpromptdiskr     = CommonScaleCreate ("Label", "Root Partition",          35, 20.5, 10, 3, $SS_Right)
		$edithandlediskr     = CommonScaleCreate ("Combo", "",                        46, 20,   40, 3)
		$editpromptchaindrv  = CommonScaleCreate ("Label", "Disk Drive To Chainload", 30, 25.3, 20, 3, $SS_Right)
		$edithandlechaindrv  = CommonScaleCreate ("Input", "",                        51, 25,    5, 3)
	    $editupdownchaindrv  = GUICtrlCreateUpdown($edithandlechaindrv)
		$editpromptdiskb     = CommonScaleCreate ("Label", "Boot Partition",          35, 32.5, 10, 3, $SS_Right)
		$edithandlediskb     = CommonScaleCreate ("Combo", "",                        46, 32,   40, 3)
	EndIf
	$dastatusr      = $guihideit
	$dastatusb      = $guihideit
	$dastatusc      = $guihideit
	$dastatlay      = $guihideit
	$daloadby       = $selectionarray [$dasub] [$sLoadBy]
	Select
		Case $daloadby = $modechaindisk
			$dastatusc    = $guishowit
			GUICtrlSetData  ($edithandlechaindrv, $selectionarray [$dasub] [$sChainDrive])
		Case $daloadby = $modehardaddress Or $daloadby = $modepartlabel Or $daloadby = $modepartuuid
			$dastatusr    = $guishowit
			If $editlinpartcount > 1 Then $dastatlay = $guishowit
			If GUICtrlRead ($edithandlelayout) = $layoutboth Then $dastatusb = $guishowit
			$dadefaultkey = $selectionarray [$dasub] [$sRootDisk]
			EditPanelGetCombo ($daloadby, $dadefaultkey, $dacombodata, $dacombodefaultr)
			GUICtrlSetData  ($edithandlediskr, $dacombodata, $dacombodefaultr)
			$selectionarray [$dasub] [$sRootDisk] = CommonGetDisk ($dacombodefaultr, "Disk")
			If GUICtrlRead ($edithandlelayout) = $layoutboth Then
				$dadefaultkey = $selectionarray [$dasub] [$sBootDisk]
				EditPanelGetCombo ($daloadby, $dadefaultkey, $dacombodata, $dacombodefaultb, $dacombodefaultr)
				GUICtrlSetData  ($edithandlediskb, $dacombodata, $dacombodefaultb)
				$selectionarray [$dasub] [$sBootDisk] = CommonGetDisk ($dacombodefaultb, "Disk")
			EndIf
	EndSelect
	GUICtrlSetState ($editpromptchaindrv, $dastatusc)
	GUICtrlSetState ($edithandlechaindrv, $dastatusc)
	GUICtrlSetState ($editupdownchaindrv, $dastatusc)
	GUICtrlSetState ($editpromptlayout,   $dastatlay)
	GUICtrlSetState ($edithandlelayout,   $dastatlay)
	GUICtrlSetState ($editpromptdiskr,    $dastatusr)
	GUICtrlSetState ($edithandlediskr,    $dastatusr)
	GUICtrlSetState ($editpromptdiskb,    $dastatusb)
	GUICtrlSetState ($edithandlediskb,    $dastatusb)
	;MsgBox ($mbontop, "After", "")
EndFunc

Func EditPanelSearch ($pssub, $pscreate)
	;MsgBox ($mbontop, "Setup Label " & $pssub, $selectionarray[$pssub][$sRootSearchArg])
	;_ArrayDisplay ($selectionarray)
	If $pscreate <> "" Then
		$editpromptsrchr   = CommonScaleCreate ("Label",  "", 30, 20.5, 20,  3, $SS_Right)
		$edithandlesrchr   = CommonScaleCreate ("Input",  "", 51, 20,   30,  3)
		$editpromptsrchl   = CommonScaleCreate ("Label",  "", 37, 27,   30,  3, $SS_CENTER)
		$edithandlesrchl   = CommonScaleCreate ("Input",  "", 37, 30,   30,  3)
		$edithandlefilea   = CommonScaleCreate ("Label",  "", 37, 35,   30,  6, $SS_CENTER)
		$edithandleselfile = CommonScaleCreate ("Button", "", 68, 28,    8, 12, $BS_MULTILINE)
	EndIf
	$psloadby  = $selectionarray[$pssub][$sLoadBy]
	$pspromptr = ""
	$pspromptl = ""
	$pssearchr = $selectionarray[$pssub][$sRootSearchArg]
	$psstatusr = $guihideit
	$psstatusl = $guihideit
	$psbutton  = $guihideit
	$psfilemsg = ""
	If $psloadby = $modeandroidfile Or $psloadby = $modephoenixfile Or $psloadby = $modechainfile Then
		CommonEFIMountWin ()
		$psostype  = BaseFuncCapIt ($selectionarray [$pssub] [$sOSType])
		$pspathmsg = $psostype & " Kernel"
		If $psostype = $typechainfile Then $pspathmsg = "Chainload"
		$pspromptl  = "The Current " & $pspathmsg & " Path Is "
		GUICtrlSetData  ($edithandlesrchl, $pssearchr)
		$psbootfile = CommonGetBootFile   ($pssearchr)
		If $selectionarray [$pssub] [$sFileLoadCheck] = $fileloaddisable Then $psfilemsg = "** File Checking Is Disbled **"
		If StringMid ($psbootfile, 2, 1) = ":" Then $psfilemsg = "The Current " & $pspathmsg & " File Is " & @CR & $psbootfile
		GUICtrlSetData ($edithandleselfile, $selnewfile & $pspathmsg & @CR & "File")
		GUICtrlSetData ($edithandlefilea,   $psfilemsg)
		$psstatusl = $guishowit
		$psbutton  = $guishowit
	EndIf
	GUICtrlSetData  ($editpromptsrchr,   $pspromptr)
	GUICtrlSetData  ($editpromptsrchl,   $pspromptl)
	GUICtrlSetData  ($edithandlesrchr,   $pssearchr)
	GUICtrlSetState ($editpromptsrchr,   $psstatusr)
	GUICtrlSetState ($editpromptsrchl,   $psstatusl)
	GUICtrlSetState ($edithandlesrchl,   $psstatusl)
	GUICtrlSetState ($edithandlesrchr,   $psstatusr)
	GUICtrlSetState ($edithandlefilea,   $psbutton)
	GUICtrlSetState ($edithandleselfile, $psbutton)
EndFunc

Func EditPanelWindowsEFI ($wisub, $wicreate = "")
	$eswinvert    = 12
	$wistatus     = EditPanelGetStatus ($selectionarray [$wisub] [$sLoadBy], $modewinefi)
	For $eswinsub = 0 To Ubound ($bcdwinorder) - 1
		If $eswinsub > 5 Then ExitLoop
		If $wicreate <> "" Then
			$edithandlewinset   [$eswinsub] = CommonScaleCreate ("Button", "Move To Top",       34, $eswinvert + 10,   12, 3.5)
			$edithandlewininst  [$eswinsub] = CommonScaleCreate ("Label",  "",                  47, $eswinvert + 10.6,  8, 3.5, $SS_Right)
			$edithandlewintitle [$eswinsub] = CommonScaleCreate ("Input",  "",                  56, $eswinvert + 10.1, 30, 3.5)
			$eswinvert += 8
		EndIf
		GUICtrlSetState ($edithandlewinset   [$eswinsub], $wistatus)
		GUICtrlSetState ($edithandlewininst  [$eswinsub], $wistatus)
		GUICtrlSetState ($edithandlewintitle [$eswinsub], $wistatus)
	Next
EndFunc

Func EditPanelCustom ($pcsub, $pccreate)
	If $pccreate <> "" Then
		$editpromptcust    = CommonScaleCreate ("Button",  "Edit Custom Code",  27, 17, 14, 3.5)
		GUICtrlSetBKColor  ($editpromptcust, $mygreen)
		$edithandleseliso  = CommonScaleCreate ("Button",  "Select ISO File ",  53, 17, 16, 3.5)
		GUICtrlSetBKColor  ($edithandleseliso, $mygreen)
		$editpromptsample  = CommonScaleCreate ("Button",  "Load Sample Code",  82, 17, 14, 3.5)
		GUICtrlSetBKColor  ($editpromptsample, $mygreen)
		$editlistcustedit  = CommonScaleCreate ("List", "",                     27, 21, 69, 40, $WS_HSCROLL + $WS_VSCROLL)
		GUICtrlSetBkColor  ($editlistcustedit, $mylightgray)
		EndIf
	$pcstatus = EditPanelGetStatus ($pcsub, $modecustom)
	$pcdata   = CustomGetData      ($pcsub)
	GUICtrlSetState ($editpromptcust,   $pcstatus)
	GUICtrlSetState ($edithandleseliso, $pcstatus)
	If $selectionarray [$pcsub][$sOSType] <> "isoboot" Or Not StringInStr ($pcdata, "isopath=") Then _
		GUICtrlSetState ($edithandleseliso, $guihideit)
	GUICtrlSetState ($editpromptsample, $pcstatus)
	If $selectionarray [$pcsub] [$sLoadBy] = $modecustom And $pcdata <> "" And $editerrorok = "yes" Then
		CustomWriteList ()
		GUICtrlSetState ($editlistcustedit, $guishowit)
	Else
		GUICtrlSetState ($editlistcustedit, $guihideit)
	EndIf
EndFunc

Func EditPanelIcon ($eisub, $eicreate)
	$eipath = $iconpath & "\" & $selectionarray [$eisub] [$sIcon] & ".png"
	If $eicreate <> "" Then
		$editpictureicon = CommonScaleCreate ("PicturePNG",      $eipath,  3,   15,  8, 10)
		$editprompticon  = CommonScaleCreate ("Label", "Click The Icon",  13.4, 19, 12,  3)
	EndIf
	$eiarray = ControlGetPos ($edithandlegui, "", $editpictureicon)
	If @error Then MsgBox ($mbontop, "Icon Error " & $eisub, $eipath)
	SpecFuncGUICtrlSetImage ($editpictureicon, $eipath, $eiarray [2], $eiarray [3])
	GUICtrlSetState   ($editpictureicon, $guishowit)
	GUICtrlSetState   ($editprompticon,  $guishowit)
	If $editerrorok <> "yes" Then
		GUICtrlSetState   ($editpictureicon, $guishowdis)
		GUICtrlSetState   ($editprompticon,  $guihideit)
	EndIf
EndFunc

Func EditPanelGetStatus ($gssub, $gsmode)
	;MsgBox ($mbontop, "Status", $gsloadby & @CR & $gsmode)
	If $selectionarray [$gssub] [$sLoadBy] = $gsmode Then Return $guishowit
	Return $guihideit
EndFunc

Func EditPanelGetMode ($gmsub, $gminitsep = "|")
	$gmstring = ""
	$gmtype   = $selectionarray [$gmsub] [$sOSType]
	$gmfamily = $selectionarray [$gmsub] [$sFamily]
	Select
		Case $gmtype = "chainfile"
			$gmstring = $modechainfile
		Case $gmtype = "chaindisk"
			$gmstring = $modechaindisk
		Case $gmtype = "isoboot"
			$gmstring = $modecustom
		Case $gmtype = "android"
			$gmstring = $modeandroidfile
		Case $gmtype = "phoenix"
			$gmstring = $modephoenixfile
		Case StringInStr ($gmfamily, "linux")
			If $editlinpartcount = 0 Then EditPanelWarnPart ()
			$gmstring = ""
			If $editlinuuidcount  > 0 Then $gmstring &= $modepartuuid  & "|"
			If $editlinlabelcount > 0 Then $gmstring &= $modepartlabel & "|"
			$gmstring &= $modecustom & "|" & $modehardaddress
		Case $gmtype = "windows" And $firmwaremode = "EFI"
			$gmstring = $modewinefi
	EndSelect
	;MsgBox ($mbontop, "Getmode", $gmtype & @CR & $gmstring)
	Return $gminitsep & $gmstring
EndFunc

Func EditPanelGetCombo ($gcloadby, $gcdefaultkey, ByRef $gccombodata, ByRef $gccombodefault, $gccombodefaultr = "")
	$gccombodefault = $partnotselected
	$gccombodata    = "|" & $partnotselected & "|"
	For $gcsub = 0 To Ubound ($linuxpartarray) - 1
		$gcfullentry = $linuxpartarray [$gcsub] [3]
		If $gcloadby = $modepartlabel And Not StringInStr ($gcfullentry, "Label=") Then ContinueLoop
		If $gccombodefaultr <> "" And StringInStr ($gcfullentry, $gccombodefaultr) Then ContinueLoop
		$gccombodata &= $gcfullentry & "|"
		If  $linuxpartarray [$gcsub] [0] = $gcdefaultkey Or $linuxpartarray [$gcsub] [1] = $gcdefaultkey Or    _
			$linuxpartarray [$gcsub] [2] = $gcdefaultkey Or $gcfullentry = $gcdefaultkey Then  _
			$gccombodefault = $gcfullentry
	Next
	If $gcdefaultkey = "" Then $gccombodefault = $partnotselected
	If StringInStr ($gccombodata, "Disk") Then Return
	$gccombodefault = $partnotavail
	$gccombodata    = "|" & $partnotavail & "|"
EndFunc

Func EditPanelStackArray ()
	If IsArray ($linuxpartarray) Then Return
	Dim $linuxpartarray [0] [5]
	For $sasub = 0 To Ubound ($partitionarray) - 1
		If $partitionarray [$sasub] [$pPartFamily] <> "Linux" Then ContinueLoop
		$editlinpartcount += 1
		If $partitionarray [$sasub] [$pPartUUID]  <> "" Then $editlinuuidcount  += 1
		If $partitionarray [$sasub] [$pPartLabel] <> "" Then $editlinlabelcount += 1
		$sainfloc = _ArrayAdd ($linuxpartarray, "")
		$linuxpartarray [$sainfloc] [0] = CommonConvDisk ($partitionarray [$sasub] [$pDiskNumber], $partitionarray [$sasub] [$pPartNumber])
		$linuxpartarray [$sainfloc] [1] = $partitionarray [$sasub] [$pPartUUID]
		$linuxpartarray [$sainfloc] [2] = $partitionarray [$sasub] [$pPartLabel]
		$saentry =  $linuxpartarray [$sainfloc] [0]
		$saentry &= "   Size=" & CommonFormatSize ($partitionarray [$sasub] [$pPartSize])
		If $partitionarray [$sasub] [$pPartLabel] <> "" And Not StringInStr ($partitionarray [$sasub] [$pPartLabel], " ") And _
			Not BaseFuncCheckCharSpec ($partitionarray [$sasub] [$pPartLabel]) Then                                               _
			$saentry &= "   Label="  & $partitionarray [$sasub] [$pPartLabel]
		$linuxpartarray [$sainfloc] [3] = $saentry
		$linuxpartarray [$sainfloc] [4] = $partitionarray [$sasub] [$pPartFileSystem]
	Next
EndFunc

Func EditPanelWarnPart ()
	If $editlinwarned  = "" Then
		$editlinwarned = "yes"
		$samsg  = @TAB & @TAB & "**  Warning  **" & @CR & @CR & @TAB & "     No Linux Partitions Were Found" & @CR & @CR
		$samsg &= "Please Make Linux Partitions Available And Re-Start Grub2Win"
		MsgBox ($mbontop, "", $samsg)
	EndIf
	;_ArrayDisplay ($linuxpartarray, $editlinpartcount & " - " & $editlinuuidcount & " - " & $editlinlabelcount)
EndFunc