#include-once
#include <g2common.au3>

If StringInStr (@ScriptName, "g2wallpaper") Then
	CommonHotKeys       ()
	BaseFuncGUIDelete   ($upmessguihandle)
	CommonCopyUserFiles ()
	GetPrevConfig       ()
	WallpaperEdit           ()
	WallpaperUpdateFiles    ()
	BaseFuncCleanupTemp ("Wallpaper")
EndIf

Func WallpaperEdit          ()
	CommonCopyUserFiles ()
	WallpaperCreateHold     ()
	WallpaperSetupGUI       ()
	$terc = WallpaperRunGUI ()
	Return $terc
EndFunc

Func WallpaperSetupGUI ()
	BaseFuncGuiDelete ($handlewallpapergui)
	$handlewallpapergui    = CommonScaleCreate ("GUI",      "Customize Wallpaper",       -1,  -1, 108,  107,  -1, -1, $handlemaingui)
	                         CommonScaleCreate ("Label",    "Click the image to select or add your own wallpaper", 5, 9.8, 38, 2.2)
	$buttonwallpaperhelp   = CommonScaleCreate ("Button",   "Help",                       1,   1,    8, 3.5)
	GUICtrlSetBkColor  ($buttonwallpaperhelp, $mymedblue)
	$handlefontprompt      = CommonScaleCreate ("Label",    "Menu Font Size",            16.5, 1.5, 10, 2)
	$handlewallpaperauto   = CommonScaleCreate ("Checkbox", "Auto",                      30,   1.1,  8, 3.0)
	$handlewallpaperfont   = CommonScaleCreate ("Combo",    "",                          16,   4,   19, 3.5)
	$handlewallpapercenter = CommonScaleCreate ("Checkbox", " Center Menus",             40,   4,   13, 3.5)
	$buttonwallpapercolgrp = CommonScaleCreate ("Group",    "Set Colors",                55,   0,   47, 8, $BS_CENTER)
	$buttonwallpapercoltit = CommonScaleCreate ("Button",   "Titles",                    58,   3,    7, 3.5)
	$buttonwallpapercolsel = CommonScaleCreate ("Button",   "Selected Item",             68,   3,   10, 3.5)
	$buttonwallpapercoltxt = CommonScaleCreate ("Button",   "Text",                      81.5, 3,    7, 3.5)
	$buttonwallpapercolclk = CommonScaleCreate ("Button",   "Clock",                     92,   3,    7, 3.5)
	$handlewallpapershot   = CommonScaleCreate ("Label",    "",                           4,  12,   98, 78)
	$handlewallpaperpic    = CommonScaleCreate ("Picture",  $screenshotfile,              4,  12,   98, 78)
	$handlewallpapertime   = CommonScaleCreate ("Checkbox", " Enable Grub Timeout",       6,  90,   16, 3.5)
	$handlewallpapersecs   = CommonScaleCreate ("Input",    $timeoutgrub,                23,  90.3,  4.5, 3, $ES_RIGHT)
	$handlewallpaperseclab = CommonScaleCreate ("Label",    "seconds",                   28,  90.6,  8,   3)
	$handlewallpapersecud  = GUICtrlCreateUpdown ($handlewallpapersecs, $UDS_ALIGNLEFT)
    $handlewallpaperlabs   = CommonScaleCreate ("Label",    "Style",                     18.5, 95.8,  8, 3.5)
	$handlewallpaperstyle  = CommonScaleCreate ("Combo",    "",                          22,   95.3, 14, 10,  -1)
	$handlewallpaperlab1   = CommonScaleCreate ("Label",    "Face",                      18.5, 99.3,  8, 3.5)
	$handlewallpaperface   = CommonScaleCreate ("Combo",    "",                          22,   99,  15, 3.5, -1)
	$handlewallpaperdesc   = CommonScaleCreate ("Label",    "",                           4,   87, 101, 3.0, $SS_CENTER)
	$handlewallpaperdark   = CommonScaleCreate ("Checkbox", " Dark Background",          45,   92,  20, 3.5)
	$handlewallpaperhilite = CommonScaleCreate ("Checkbox", " Highlight Selected Item",  45,   97,  20, 3.5)
	$handlewallpaperscroll = CommonScaleCreate ("Checkbox", " Show Scroll Bar (if needed)", 45,  102,  21, 3.5)
	$handlewallpapermode   = CommonScaleCreate ("Checkbox", " Show Boot Mode",           68,   97,  25, 3.5)
	$handlewallpapervers   = CommonScaleCreate ("Checkbox", " Show Grub2Win Version",    68,   92,  20, 3.5)
	$handlewallpaperlines  = CommonScaleCreate ("Checkbox", " Show Prompt Lines",        68,  102,  20, 3.5)
	$buttonwallpaperreset  = CommonScaleCreate ("Button",   "Set Standard View",         93,   90,  13, 3.8)
	$buttonwallpapercancel = CommonScaleCreate ("Button",   "Cancel",                     4,  100,  10, 3.8)
	$buttonwallpaperok     = CommonScaleCreate ("Button",   "OK",                        94,  100,  10, 3.8)
	$wallpaperfontstring   = WallpaperFontSetup    ()
	If $wallpaperfont      = "" Then $wallpaperfont     = SettingsGet ($setwallpaperfont)
	If $wallpaperfontauto  = "" Then $wallpaperfontauto = SettingsGet ($setwallpaperfontauto)
	If $wallpaperfontauto  = "yes" Then GUICtrlSetState ($handlewallpaperauto, $GUI_CHECKED)
	$wallpaperfont         = WallpaperFontSelect ()
	GUICtrlSetData     ($handlewallpaperface,  WallpaperGetFaces  (), CommonWallpaperGetOption ("face"))
	GUICtrlSetData     ($handlewallpaperstyle, "Clock|Progress Bar")
	GUISetBkColor      ($mylightgray, $handlewallpapergui)
	WallpaperRefreshHandles  ()
	GUISetState        (@SW_MINIMIZE, $handlemaingui)
	GUISetState        (@SW_SHOW,     $handlewallpapergui)
EndFunc

Func WallpaperRunGUI ()
	Local $rgprevname, $rgprevstyle, $rgprevface
	$rgname        = CommonWallpaperGetOption ("name",  "lower")
	If $wallpapergraphname <> "" Then $rgname = $wallpapergraphname
	WallpaperGetLocal ($rgname)
	$rgstyle       = CommonWallpaperGetOption ("style", "lower")
	$rgface        = CommonWallpaperGetOption ("face",  "lower")
	$rgtime        = $GUI_UNCHECKED
	$rgholdenabled = $timegrubenabled
	If $timegrubenabled = "yes" Then $rgtime = $GUI_CHECKED
	GUICtrlSetState ($handlewallpapertime, $rgtime)
	WallpaperRefreshGUI ()
	While 1
		$rgreturn = GUIGetMSG (1)
		$rgstatus = $rgreturn [0]
		$rghandle = $rgreturn [1]
		If $rgstatus < 1 And $rgstatus <> $GUI_EVENT_CLOSE And $rgstatus <> $GUI_EVENT_PRIMARYUP And _
		    $rgstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $rgstatus = $GUI_EVENT_CLOSE Or $rgstatus = $buttonwallpapercancel
				If $rghandle <> $handlewallpapergui Then ContinueLoop
				$timegrubenabled = $rgholdenabled
				WallpaperRestoreHold ()
				ExitLoop
			Case $rgstatus = $GUI_EVENT_PRIMARYUP
				If CommonCheckUpDown ($handlewallpapersecs, $timeoutgrub, 0, 999) Then WallpaperRefreshGUI ()
			Case $rgstatus = $buttonwallpaperhelp
				CommonHelp ("Customizing The Wallpaper")
				ContinueLoop
			Case $rgstatus = $handlewallpapershot Or $rgstatus = $handlewallpaperdesc
				$rgname    = WallpaperSelectRunGUI ($rgname)
				If StringLeft ($rgname, 7) = "autores" Then
					$rgname = WallpaperAutoRes ($wallpapertempoptarray)
					CommonWriteLog ("    Automatic Resolution Set The Wallpaper Wallpaper To " & $rgname)
				EndIf
				If $rgname = $rgprevname Then ContinueLoop
				WallpaperGetLocal ($rgname)
				CommonWallpaperPutOption ("name", $rgname, $wallpapertempoptarray)
				WallpaperResetColor ()
				WallpaperRefreshGUI ($rgname)
				$rgprevname = $rgname
			Case $rgstatus = $handlewallpaperauto
				$wallpaperfont = WallpaperFontSelect ()
			Case $rgstatus = $handlewallpaperfont
				$wallpaperfont       = StringStripWS (GUICtrlRead ($handlewallpaperfont), 7)
				WallpaperFontFields ($wallpaperfont)
			Case $rgstatus = $handlewallpapertime
				$timegrubenabled = "no"
				If CommonCheckBox ($handlewallpapertime) Then $timegrubenabled = "yes"
				WallpaperRefreshGUI ($rgname)
			Case $rgstatus = $handlewallpaperdark
				WallpaperCheckBox   ($handlewallpaperdark,   "dark")
			Case $rgstatus = $handlewallpaperscroll
				WallpaperCheckBox   ($handlewallpaperscroll, "scrollbar")
			Case $rgstatus = $handlewallpaperhilite
				WallpaperCheckBox   ($handlewallpaperhilite, "highlight")
			Case $rgstatus = $handlewallpaperlines
				WallpaperCheckBox   ($handlewallpaperlines,  "lines")
			Case $rgstatus = $handlewallpapervers
				WallpaperCheckBox   ($handlewallpapervers,   "version")
			Case $rgstatus = $handlewallpapermode
				WallpaperCheckBox   ($handlewallpapermode,   "bootmode")
			Case $rgstatus = $handlewallpapercenter
				WallpaperCheckBox   ($handlewallpapercenter, "center")
			Case $rgstatus = $handlewallpaperface
				$rgface = StringLower (GUICtrlRead ($handlewallpaperface))
				CommonWallpaperPutOption ("face", $rgface, $wallpapertempoptarray)
				If $rgface <> $rgprevface Then WallpaperRefreshGUI ()
				$rgprevface = $rgface
			Case $rgstatus = $handlewallpaperstyle
				$rgstyle = StringLower (GUICtrlRead ($handlewallpaperstyle))
				CommonWallpaperPutOption ("style", $rgstyle, $wallpapertempoptarray)
				If $rgstyle <> $rgprevstyle Then WallpaperRefreshGUI ()
				$rgprevstyle = $rgstyle
			Case $rgstatus = $buttonwallpapercoltit
				$rgcolortit   = CommonWallpaperGetOption ("coltitle")
				WallpaperGetColors ($rgname, "coltitle",  $rgcolortit)
			Case $rgstatus = $buttonwallpapercolsel
				$rgcolorsel   = CommonWallpaperGetOption ("colselect")
				WallpaperGetColors ($rgname, "colselect", $rgcolorsel)
			Case $rgstatus = $buttonwallpapercoltxt
				$rgcolortext  = CommonWallpaperGetOption ("coltext")
				WallpaperGetColors ($rgname, "coltext", $rgcolortext, "yes")
			Case $rgstatus = $buttonwallpapercolclk
				$rgcolorclock = CommonWallpaperGetOption ("colclock")
				WallpaperGetColors ($rgname, "colclock", $rgcolorclock, "yes")
			Case $rgstatus = $buttonwallpaperreset
				$wallpapertempoptarray = WallpaperLoadOptions ($wallpaperstandpath & "\" & $rgname & ".txt")
				$timegrubenabled = "yes"
				WallpaperResetColor ()
				WallpaperSetupGUI   ()
				GUICtrlSetState ($handlewallpapertime, $GUI_CHECKED)
				WallpaperRefreshGUI ($rgname)
			Case $rgstatus = $buttonwallpaperok
				GuiCtrlSetData ($updowngt, $timeoutgrub)
				$rgvariable = StringLower (StringReplace ($rgname, "-", "_"))
				Assign ("wallpaperoptarrayhold_" & $rgvariable, $wallpapertempoptarray, 2)
				ExitLoop
			Case Else
		EndSelect
	WEnd
	BaseFuncGuiDelete ($handlewallpapergui)
	BaseFuncGuiDelete ($wallpaperselecthandlegui)
	If $rgstatus = $buttonwallpaperok Then
		Return "OK"
	Else
		Return "Cancelled"
	EndIf
EndFunc

Func WallpaperCheckBox ($tcbhandle, $tcbkey)
	$tcbvalue = "no"
	If CommonCheckBox    ($tcbhandle) Then $tcbvalue = "yes"
	CommonWallpaperPutOption ($tcbkey, $tcbvalue, $wallpapertempoptarray)
	WallpaperRefreshGUI ()
EndFunc

Func WallpaperRefreshGUI ($rgname = "")
	GUICtrlSetState ($handlewallpaperlab1,   $guihideit)
	GUICtrlSetState ($handlewallpaperlabs,   $guihideit)
	GUICtrlSetState ($handlewallpaperstyle,  $guihideit)
	GUICtrlSetState ($handlewallpaperface,   $guihideit)
	If $rgname = "" Then $rgname = CommonWallpaperGetOption ("name")
	WallpaperBuildScreenShot ($rgname)
	If $rgname = $nowallpaper Then
		$rgnamedesc = $nowallpaperdesc
		GUICtrlSetState ($handlewallpaperdark,   $guihideit)
		GUICtrlSetState ($handlewallpaperscroll, $guihideit)
		GUICtrlSetState ($handlewallpaperhilite, $guihideit)
		GUICtrlSetState ($handlewallpaperlines,  $guihideit)
		GUICtrlSetState ($handlewallpapervers,   $guihideit)
		GUICtrlSetState ($buttonwallpaperreset,  $guihideit)
		GUICtrlSetState ($handlewallpapermode,   $guihideit)
		GUICtrlSetState ($handlewallpapercenter, $guihideit)
		GUICtrlSetState ($buttonwallpapercolgrp, $guihideit)
		GUICtrlSetState ($buttonwallpapercoltit, $guihideit)
		GUICtrlSetState ($buttonwallpapercolsel, $guihideit)
		GUICtrlSetState ($buttonwallpapercoltxt, $guihideit)
		GUICtrlSetState ($buttonwallpapercolclk, $guihideit)
		GUICtrlSetState ($handlewallpaperfont,   $guihideit)
		GUICtrlSetState ($handlefontprompt,  $guihideit)
		GUICtrlSetState ($handlewallpaperauto,   $guihideit)
	Else
		$rgnamedesc = BaseFuncCapIt ($rgname)
		GUICtrlSetState ($handlewallpaperdark,   $guishowit)
		GUICtrlSetState ($handlewallpaperscroll, $guishowit)
		GUICtrlSetState ($handlewallpaperhilite, $guishowit)
		GUICtrlSetState ($handlewallpaperlines,  $guishowit)
		GUICtrlSetState ($handlewallpapervers,   $guishowit)
		GUICtrlSetState ($handlewallpapermode,   $guishowit)
		GUICtrlSetState ($handlewallpapercenter, $guishowit)
		GUICtrlSetState ($buttonwallpaperreset,  $guishowit)
		GUICtrlSetState ($buttonwallpapercolgrp, $guishowit)
		GUICtrlSetState ($buttonwallpapercoltit, $guishowit)
		GUICtrlSetState ($buttonwallpapercolsel, $guishowit)
		GUICtrlSetState ($buttonwallpapercoltxt, $guishowit)
		GUICtrlSetState ($buttonwallpapercolclk, $guishowit)
		GUICtrlSetState ($handlewallpaperlabs,   $guishowit)
		GUICtrlSetState ($handlewallpaperstyle,  $guishowit)
		GUICtrlSetState ($handlewallpaperface,   $guishowit)
		GUICtrlSetState ($handlewallpaperlab1,   $guishowit)
		GUICtrlSetState ($handlewallpaperfont,   $guishowit)
		GUICtrlSetState ($handlefontprompt,  $guishowit)
		GUICtrlSetState ($handlewallpaperauto,   $guishowit)
	EndIf
	If $timegrubenabled = "yes" Then
		If CommonWallpaperGetOption ("style") = "clock" Then
			GUICtrlSetPos   ($buttonwallpapercolgrp, Default, Default, $scalepcthorz * 47)
		Else
			GUICtrlSetState ($handlewallpaperface,   $guihideit)
			GUICtrlSetState ($handlewallpaperlab1,   $guihideit)
			GUICtrlSetState ($buttonwallpapercolclk, $guihideit)
			GUICtrlSetPos   ($buttonwallpapercolgrp, Default, Default, $scalepcthorz * 36.5)
		EndIf
		GUICtrlSetState ($handlewallpapersecs,   $guishowit)
		GUICtrlSetState ($handlewallpaperseclab, $guishowit)
		GUICtrlSetState ($handlewallpapersecud,  $guishowit)
	Else
		GUICtrlSetState ($handlewallpaperlabs,   $guihideit)
		GUICtrlSetState ($handlewallpaperstyle,  $guihideit)
		GUICtrlSetState ($handlewallpaperface,   $guihideit)
		GUICtrlSetState ($handlewallpaperlab1,   $guihideit)
		GUICtrlSetState ($handlewallpapersecs,   $guihideit)
		GUICtrlSetState ($handlewallpaperseclab, $guihideit)
		GUICtrlSetState ($handlewallpapersecud,  $guihideit)
	EndIf
	If Not FileExists ($wallpaperstandpath & "\" & $rgname & ".txt") Then _
		GUICtrlSetState ($buttonwallpaperreset, $guihideit)
	GUICtrlSetData  ($handlewallpaperdesc, $rgnamedesc)
	GUICtrlSetImage ($handlewallpaperpic,  $screenshotfile)
EndFunc

Func WallpaperBuildScreenShot ($wsname = "")
	If $wsname = "" Then $wsname = CommonWallpaperGetOption ("name")
	If $wsname = $nowallpaper Then
		WallpaperGDISetup         ($wallpaperstatic & "\image.nowallpaper.jpg", "Arial", 16)
		WallpaperBuildNoImage ()
		WallpaperGDICloseout      ($screenshotfile)
	Else
		$wsnamelow = StringLower ($wsname)
		WallpaperGDISetup         ($wallpapertempback & "\" & $wsnamelow & ".jpg", "Arial", 18)
		WallpaperBuildImage       ()
		WallpaperGDICloseout      ($screenshotfile)
	EndIf
EndFunc

Func WallpaperBuildBackground ($tbbfile)
	WallpaperGDISetup    ($tbbfile, "Arial", 18)
	WallpaperGDICloseout ($wallpapercustback)
EndFunc

Func WallpaperBuildImage ()
	$tbibound     = Ubound ($selectionarray) - $selectionmisccount - 1
	$tbilimit     = 12
	$tbiscroll    = 735
	If CommonWallpaperGetOption ("style") = "progress bar" Then
		$tbilimit  -= 1
		$tbiscroll  = 685
	EndIf
	$wallpapercenterstart = ($tbilimit / 2) - ($tbibound / 2) - 1
	If $wallpapercenterstart <   0 Then $wallpapercenterstart =   0
	If $wallpapercenterstart > 3.5 Then $wallpapercenterstart = 3.5
	$wallpapercentersize = $tbibound + 1
	If CommonWallpaperGetOption ("center") = "no" Then
		$wallpapercenterstart = 0
		$wallpapercentersize  = $tbilimit
	EndIf
	If $wallpapercentersize > $tbilimit Then $wallpapercentersize = $tbilimit
	;MsgBox ($mbontop, "Start", $tbilimit & @TAB & ($tbilimit / 2) & @CR & $tbibound & @TAB & ($tbibound / 2 ) & @CR & $wallpapercenterstart)
	$tbivert = ($wallpapercenterstart * 60) + 30
	$tbidark = CommonWallpaperGetOption ("dark")
	If CommonWallpaperGetOption ("scrollbar") = "yes" And $tbibound >= $tbilimit Then _
	    WallpaperLayerImage ($wallpaperstatic & "\image.scrollbar.png", 845, 20,        19, $tbiscroll)
	For $tbisub = 0 To $tbibound
		If $tbisub = $tbilimit Then Exitloop
		$tbibrush  = $brushtitle
		$tbiicon   = $selectionarray [$tbisub] [$sIcon]
		$tbitext   = $selectionarray [$tbisub] [$sEntryTitle]
		If $tbidark = "yes" Then WallpaperLayerImage ($wallpaperstatic & "\menubox.dark_c.png", 120, $tbivert, 725, 63)
		If $selectionarray [$tbisub] [$sDefaultOS] <> "" Then
			$tbibrush = $brushselect
			If CommonWallpaperGetOption ("highlight") = "yes" Then WallpaperLayerImage ($wallpaperstatic & "\select_c.png", 120, $tbivert + 3, 720, 56)
		EndIf
		WallpaperLayerImage ($wallpaperpath & "\icons\" & $tbiicon & ".png",             130, $tbivert +  8,  45, 45)
		WallpaperLayerText  ($tbitext,                                               195, $tbivert + 17, $tbibrush, 665, 34)
		$tbivert += 60
	Next
	If CommonWallpaperGetOption ("version")  = "yes" Then
		WallpaperLayerText  ("Grub2Win",                                       875, 330, $brushtext)
		WallpaperLayerText  ($basrelcurr,                                      897, 365, $brushtext)
	EndIf
	If CommonWallpaperGetOption ("bootmode") = "yes" Then
		$tbioffset = 855
		If $firmwaremode = "EFI" Then $tbioffset = 870
		WallpaperLayerText  ($firmwaremode & "   " & $procbits & " Bit",   $tbioffset, 405, $brushtext)
	EndIf
	If CommonWallpaperGetOption ("lines") = "yes" Then _
		WallpaperLayerImage ($wallpapercolorcustom & "\image.promptlines.png",     870,  40, 150, 300)
	If $timegrubenabled = "no" Then Return
	If CommonWallpaperGetOption ("style") = "clock" Then
		WallpaperLayerText  ($timeoutgrub & "s",          915, 685, $brushclock)
		$tbiface = CommonWallpaperGetOption ("face")
		If $tbiface <> $noface Then
			$tbifacefile = $wallpaperfaces  & "\" & $tbiface & ".png"
			If $tbiface = $ticksonly Then $tbifacefile = $wallpaperempty
			WallpaperLayerImage ($wallpapercolorcustom & "\image.clock.png", 880, 544, 108, 108)
			WallpaperLayerImage ($tbifacefile,                      900, 559,  70,  70)
		EndIf
	EndIf
	If CommonWallpaperGetOption ("style")  = "progress bar" Then
		WallpaperLayerImage ($wallpaperstatic & "\image.progress.bar.png",        130, 710, 790, 40)
		$tbiprogmessage = "The hilighted entry will be executed automatically in " & $timeoutgrub & "s"
		WallpaperLayerText  ($tbiprogmessage,                                 220, 716, $brushtext)
	EndIf
	$tbifontflag      = StringRight ($wallpaperfont, 2)
	If StringLeft     ($wallpaperfont, 7) = "Unifont" Then $tbifontflag &= "  Unifont"
	; If $wallpaperfontauto = "yes"                     Then $tbifontflag &= "  Auto  "
	WallpaperLayerText    ($tbifontflag,  0, 768, $brushtext)
EndFunc

Func WallpaperBuildNoImage ()
	$tbngray  = _GDIPlus_BrushCreateSolid (Execute  ("0x99FFFFFF"))
	$tbntext0 = "GNU GRUB   version " & SettingsGet ($setgnugrubversion)
	WallpaperLayerText  ($tbntext0,                365,  35, $tbngray)
	$tbnvert  = 110
	For $tbnsub = 0 To Ubound ($selectionarray) - $selectionmisccount - 1
		If $tbnsub > 12 Then Exitloop
		$tbntext = $selectionarray [$tbnsub] [$sEntryTitle]
		If $selectionarray [$tbnsub] [$sDefaultOS] <> "" Then _
			WallpaperLayerImage ($wallpaperstatic & "\select.nowallpaper.png", 23, $tbnvert + 12, 975, 30)
		WallpaperLayerText  ($tbntext,              40, $tbnvert + 17, $tbngray)
		$tbnvert += 30
	Next
	$tbntext1 = "Use the     and     keys to select which entry is highlighted."
	$tbntext2 = "Press enter to boot the selected OS,  'e'  to edit the commands"
	$tbntext3 = "before booting or  'c'  for a command-line."
	$tbntext4 = "The hilighted entry will be executed automatically in " & $timeoutgrub & "s"
	WallpaperLayerText  ($tbntext1,                               165, 625, $tbngray)
	WallpaperLayerText  ($tbntext2,                               165, 650, $tbngray)
	WallpaperLayerText  ($tbntext3,                               165, 675, $tbngray)
	WallpaperLayerImage ($wallpaperstatic & "\image.arrow.up.png",    250, 628, 15, 15)
	WallpaperLayerImage ($wallpaperstatic & "\image.arrow.down.png",  318, 632, 14, 14)
	If $timegrubenabled = "yes" Then WallpaperLayerText  ($tbntext4, 165, 700, $tbngray)
	_GDIPlus_BrushDispose ($tbngray)
EndFunc

Func WallpaperLayerImage ($listack, $lileft, $litop, $liwidth, $liheight)
	$lihandlestack    = _GDIPlus_ImageLoadFromFile ($listack)
	If $lihandlestack = 0 Then Return ; MsgBox ($mbontop, "GDI Get File Error", "Stack = " & $listack)
	$licontextstack   = _GDIPlus_ImageGetGraphicsContext ($lihandlestack)
	SpecFunc_GDIPlus_GraphicsDrawImageTrans ($gdicontextin, $lihandlestack, $liwidth, $liheight, $lileft, $litop)
	_GDIPlus_GraphicsDispose ($licontextstack)
	_GDIPlus_ImageDispose    ($lihandlestack)
EndFunc

Func WallpaperLayerText ($lttext, $ltleft, $lttop, $ltbrush, $ltwidth = 0, $ltheight = 0)
	$gdilayout  = _GDIPlus_RectFCreate           ($ltleft, $lttop, $ltwidth, $ltheight)
	$gdimeasure = _GDIPlus_GraphicsMeasureString ($gdicontextin, $lttext, $gdifont, $gdilayout, $gdiformat)
	_GDIPlus_GraphicsDrawStringEx ($gdicontextin, $lttext, $gdifont, $gdimeasure [0], $gdiformat, $ltbrush)
EndFunc

Func WallpaperGDISetup ($gsinfile, $gsfontname, $gsfontsize)
	_GDIPlus_Startup ()
	$gdihandlein    = _GDIPlus_ImageLoadFromFile       ($gsinfile)
	If $gdihandlein = 0 Then CommonEndIt ("Failed", "", "GDI Get File Error Input File = " & $gsinfile)
	$gdihandlein    = _GDIPlus_ImageResize             ($gdihandlein, 1024, 800)
	$gdicontextin   = _GDIPlus_ImageGetGraphicsContext ($gdihandlein)
	$gdiformat      = _GDIPlus_StringFormatCreate      ()
	$gdifontfam     = _GDIPlus_FontFamilyCreate        ($gsfontname)
	$gdifont        = _GDIPlus_FontCreate              ($gdifontfam, $gsfontsize, 0)
	WallpaperSetupColors ()
EndFunc

Func WallpaperGDICloseout ($gcoutfile)
	FileDelete ($gcoutfile)
	_GDIPlus_ImageSaveToFile     ($gdihandlein, $gcoutfile)
	_GDIPlus_FontDispose         ($gdifont)
	_GDIPlus_FontFamilyDispose   ($gdifontfam)
	_GDIPlus_StringFormatDispose ($gdiformat)
	_GDIPlus_GraphicsDispose     ($gdicontextin)
	_GDIPlus_ImageDispose        ($gdihandlein)
	_GDIPlus_BrushDispose        ($brushtitle)
	_GDIPlus_BrushDispose        ($brushselect)
	_GDIPlus_BrushDispose        ($brushtext)
	_GDIPlus_Shutdown            ()
EndFunc

Func WallpaperGetCurrent ($tgcfile = $wallpapercustopt)
	$tgcarray = WallpaperLoadOptions ($tgcfile)
	$tgcarray = WallpaperHealOptions ($tgcarray)
	Return $tgcarray
EndFunc

Func WallpaperGetLocal ($glname)
	$glvariable = StringLower (StringReplace ($glname, "-", "_"))
	If IsDeclared ("themeoptarrayhold_" & $glvariable) = $DECLARED_GLOBAL Then
		$wallpapertempoptarray = Eval ("themeoptarrayhold_" & $glvariable)
		WallpaperRefreshHandles ()
		Return
	EndIf
	$glstandfile  = $wallpaperstandpath & "\" & $glname & ".txt"
	$gllocalfile  = $wallpaperlocalpath & "\" & $glname & ".txt"
	FileCopy ($glstandfile, $wallpapercustopt, 1)
	If Not FileExists ($glstandfile) Then WallpaperUserLocal ($glname, $gllocalfile)
	If Not FileExists ($gllocalfile) Then FileCopy ($glstandfile, $wallpapercustopt, 1)
										  FileCopy ($gllocalfile, $wallpapercustopt, 1)
	$wallpapertempoptarray = WallpaperLoadOptions ($wallpapercustopt)
	$wallpapertempoptarray = WallpaperHealOptions ($wallpapertempoptarray)
	CommonWallpaperPutOption ("name", $glname, $wallpapertempoptarray)
	WallpaperRefreshHandles ()
EndFunc

Func WallpaperUserLocal ($ulname, $ulfile)
	If FileExists ($ulfile) Then Return
	$ularray = WallpaperLoadOptions ($wallpaperdeffile)
	CommonWallpaperPutOption ("name", $ulname, $ularray)
	WallpaperWriteOptionsFile ($ulfile, $ularray)
EndFunc

Func WallpaperHealOptions (ByRef $hoinarray)
	If Not IsArray ($wallpaperdefarray) Then $wallpaperdefarray = WallpaperLoadOptions ($wallpaperdeffile)
	$hohealedarray = $wallpaperdefarray
	For $hosub = 0 To Ubound ($hohealedarray) - 1
		$hofield = $hohealedarray [$hosub] [2]
		$hovalue = CommonWallpaperGetOption ($hofield, "", $hoinarray)
		If $hofield <> "level" And $hovalue <> "" Then $hohealedarray [$hosub] [3] = $hovalue
	Next
	Return $hohealedarray
EndFunc

Func WallpaperLoadOptions ($lofile, $locheck = "yes")
	Dim $loarray  [0] [5]
	$lohandleopts = FileOpen ($lofile)
	While 1
		$lorecord = FileReadLine ($lohandleopts)
		If @error Then ExitLoop
		$lorecord = StringStripWS  ($lorecord, 7)
		If StringInStr ($lorecord, "Timestamp") Or $lorecord = "" Then ContinueLoop
		$loequal     = StringInStr ($lorecord, "=")
		$losplit     = StringSplit ($lorecord, " ", 2)
		$loparmcount = Ubound      ($losplit)
		If $loparmcount = 4 Then _ArrayInsert ($losplit, 1, "")
		$lotype      = $losplit [0]
		$lohandname  = $losplit [1]
		$lohandname  = StringReplace ($lohandname, "theme", "wallpaper")                          ; Compat 12/31/24
		$lokey       = $losplit [2]
		$lovalue     = StringStripWS (StringTrimLeft ($lorecord, $loequal), 7)
		_ArrayAdd ($loarray, $lotype & "|" & $lohandname & "|" & $lokey & "|" & $lovalue & "|")
	WEnd
	FileClose ($lohandleopts)
	$loname = CommonWallpaperGetOption ("name", "", $loarray)
	$lobackground  = $wallpapertempback & "\" & $loname & ".jpg"
	;MsgBox ($mbontop, "WallPath", $loname & @CR & @CR & $wallpapertempback)
	If $locheck <> "" And $loname <> "basic" And Not FileExists ($lobackground) And Not CommonParms ("AutoResDir") Then
		FileDelete ($wallpaperpath       & "\custom.*")
		FileDelete ($setupolddir         & "\themes\options.local\" & $loname & ".txt")
		FileCopy   ($wallpapermasterpath & "\options.txt", $wallpaperpath & "\custom.options.txt",    1)
		MsgBox ($mbwarnok, "File " & $lofile, "Wallpaper image file " & $lobackground & " is missing."  _
		     & @CR & @CR & 'The wallpaper was changed to "Common"' & @CR & @CR & 'Please click "OK" to continue')
	EndIf
	;_ArrayDisplay ($loarray, $lofile)
	Return $loarray
EndFunc

Func WallpaperGetFaces ()
	$tgfstring = $noface
	$tgfhandle = FileFindFirstFile ($wallpaperfaces & "\*.png")
	While 1
		$tgfname = FileFindNextFile ($tgfhandle)
		If @error Then ExitLoop
		$tgfname = StringLower ($tgfname)
		$tgfstring &= "|" & BaseFuncCapIt (StringTrimRight ($tgfname, 4))
	WEnd
	FileClose ($tgfhandle)
	Return $tgfstring & "|" & $ticksonly
EndFunc

Func WallpaperGetColors ($gcname, $gcfield, $gccurrent, $gccopy = "")
	$gccolortext = _ChooseColor (2, Execute ("0x" & $gccurrent), 2, $handlewallpapergui)
	If $gccolortext = -1 Then Return
	$gccolortext = StringTrimLeft ($gccolortext, 2)
	CommonWallpaperPutOption ($gcfield, $gccolortext, $wallpapertempoptarray)
	If $gccopy <> "" Then WallpaperCopyColor ($gcfield, $gccolortext)
	; MsgBox ($mbontop, "GetColors " & $gccolortext, $gcfield)
	WallpaperRefreshGUI      ($gcname)
EndFunc

Func WallpaperSetupColors ()
	$tpctitle  = CommonWallpaperGetOption ("coltitle")
	$tpcselect = CommonWallpaperGetOption ("colselect")
	$tpctext   = CommonWallpaperGetOption ("coltext")
	$tpcclock  = CommonWallpaperGetOption ("colclock")
	GUICtrlSetBkColor ($buttonwallpapercoltit,    Execute ("0x" &   $tpctitle))
	GUICtrlSetColor   ($buttonwallpapercoltit,    WallpaperGetContrast ($tpctitle))
	GUICtrlSetBkColor ($buttonwallpapercolsel,    Execute ("0x" &   $tpcselect))
	GUICtrlSetColor   ($buttonwallpapercolsel,    WallpaperGetContrast ($tpcselect))
	GUICtrlSetBkColor ($buttonwallpapercoltxt,    Execute ("0x" &   $tpctext))
	GUICtrlSetColor   ($buttonwallpapercoltxt,    WallpaperGetContrast ($tpctext))
	GUICtrlSetBkColor ($buttonwallpapercolclk,    Execute ("0x" &   $tpcclock))
	GUICtrlSetColor   ($buttonwallpapercolclk,    WallpaperGetContrast ($tpcclock))
	$brushtitle  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctitle))
	$brushselect = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcselect))
	$brushtext   = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctext))
	$brushclock  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcclock))
EndFunc

Func WallpaperCopyColor ($cctype, $cccolor = "", $ccfromdir = $wallpapercolorsource, $cctodir = $wallpapercolorcustom)
	If $cctype = "coltext"  Then
		WallpaperChangeColor ("image.promptlines.png", $cccolor, $ccfromdir, $cctodir)
	Else
		WallpaperChangeColor ("tick.png",             $cccolor, $ccfromdir, $cctodir)
		WallpaperChangeColor ("image.clock.png",      $cccolor, $ccfromdir, $cctodir)
		WallpaperChangeColor ("radian.png",           $cccolor, $ccfromdir, $wallpaperfaces)
		WallpaperChangeColor ("snowflake.png",        $cccolor, $ccfromdir, $wallpaperfaces)
	EndIf
EndFunc

Func WallpaperChangeColor ($ccfile, $ccoutcolor, $ccfromdir = $wallpapercolorsource, $cctodir = $wallpapercolorcustom)
	$ccbgr = StringMid ($ccoutcolor, 5, 2) & StringMid ($ccoutcolor, 3, 2) & StringLeft ($ccoutcolor, 2) & "FF"
	;MsgBox ($mbontop, "Colors", "BGR=" & $ccbgr & @CR &  "RGB=" & $ccoutcolor)
	_GDIPlus_Startup  ()
    $ccimage = _GDIPlus_ImageLoadFromFile ($ccfromdir & "\" & $ccfile)
	$ccimage = SpecFunc_ImageColorRegExpReplace   ($ccimage, "(0000FFFF)",   $ccbgr)
	_GDIPlus_ImageSaveToFile ($ccimage,    $cctodir   & "\" & $ccfile)
	_GDIPlus_ImageDispose ($ccimage)
	_GDIPlus_Shutdown     ()
EndFunc

Func WallpaperGetContrast ($tgccolor)
	$tgcred        = Dec (StringLeft  ($tgccolor, 2))
	$tgcgreen      = Dec (StringMid   ($tgccolor, 3,2))
	$tgcblue       = Dec (StringRight ($tgccolor, 2))
	$tgcbrightness = Int (.299 * $tgcred + .587 * $tgcgreen + .114 * $tgcblue)
	If $tgcbrightness < 128 Then Return $mywhite
	;MsgBox ($mbontop, "RGB " & $tgcbrightness & " " & $tgccontrast, $tgccolor & @CR & $tgcred & @CR & $tgcgreen & @CR & $tgcblue)
	Return $myblack
EndFunc

Func WallpaperResetColor ()
	WallpaperCopyColor   ("coltext",  CommonWallpaperGetOption ("coltext"))
	WallpaperCopyColor   ("colclock", CommonWallpaperGetOption ("colclock"))
EndFunc

Func WallpaperRefreshHandles ()
	For $tshsub = 0 To Ubound ($wallpapertempoptarray) - 1
		$tshvalue  = StringLower ($wallpapertempoptarray [$tshsub] [1])
   	    $tshhandle = Eval ($tshvalue)
		If @error Then ContinueLoop
		;MsgBox ($mbontop, "Eval", $tshvalue & @CR & $tshhandle)
		$wallpapertempoptarray [$tshsub] [4] = $tshhandle
		$thschecked = $GUI_UNCHECKED
		If $wallpapertempoptarray [$tshsub] [3] = "yes" Then $thschecked = $GUI_CHECKED
        GUICtrlSetState ($tshhandle, $thschecked)
	    ;MsgBox ($mbontop, $tshvalue, $tshhandle)
	Next
	$trhstyle = CommonWallpaperGetOption ("style")
	GUICtrlSetData ($handlewallpaperstyle, $trhstyle)
	GUICtrlSetData ($handlewallpaperface,  CommonWallpaperGetOption ("face"))
EndFunc

Func WallpaperUpdateFiles ()
	;_ArrayDisplay ($wallpapertempoptarray, Ubound ($wallpapertempoptarray) - 1)
	If $wallpaperfontauto = "yes" Then WallpaperGraphGetAuto ($wallpaperfont)
	$wallpaperfont            = StringStripWS    ($wallpaperfont, 7)
	SettingsPut           ($setwallpaperfont,     $wallpaperfont)
	SettingsPut           ($setwallpaperfontauto, $wallpaperfontauto)
	WallpaperWriteOptionsFile ($wallpapercustopt,   $wallpapertempoptarray, TimeLine ())
	$tufname              = CommonWallpaperGetOption ("name")
	$tuflocal             = $wallpaperlocalpath & "\" & $tufname & ".txt"
	FileCopy              ($wallpapercustopt, $tuflocal, 1)
	WallpaperBuildBackground  ($wallpapertempback & "\" & $tufname & ".jpg")
	If $tufname           <> $nowallpaper Then WallpaperGenConfig ()
	Return $tufname
EndFunc

Func WallpaperWriteOptionsFile ($wofoutfile, ByRef $wofarray, $wofstamp = "")
	$wofhandleopts = FileOpen ($wofoutfile, $FO_OVERWRITE)
	FileWriteLine ($wofhandleopts, _StringRepeat (" ", 34) & "Timestamp = " & $wofstamp & @CR & @CR)
	For $wofsub = 0 To Ubound ($wofarray) - 1
		$wofrecord  = BaseFuncPadRight ($wofarray [$wofsub] [0], 11)
		$wofrecord &= BaseFuncPadRight ($wofarray [$wofsub] [1], 27)
		$wofrecord &= BaseFuncPadRight ($wofarray [$wofsub] [2],  9) & " = "
		$wofrecord &=                   $wofarray [$wofsub] [3]
		If $wofsub < Ubound ($wofarray) - 1 Then $wofrecord &= @CR
		FileWrite ($wofhandleopts, $wofrecord)
	Next
	FileClose ($wofhandleopts)
EndFunc

Func WallpaperStarterSetup ()
	FileCopy ($wallpapermasterpath  & "\background.png", $wallpaperpath & "\custom.background.png", 1)
	FileCopy ($wallpapermasterpath  & "\options.txt",    $wallpaperpath & "\custom.options.txt",    1)
	If FileExists ($setupolddir & "\themes\custom.background.png") Then	FileCopy ($setupolddir & "\themes\custom.*", $wallpaperpath & "\", 1)
	$wallpapertempoptarray = WallpaperGetCurrent            ($wallpaperpath & "\custom.options.txt")
	If CommonParms ("AutoResDir") And FileExists ($setupvalueautoresdir & "\autores.default.jpg") Then
		FileCopy ($setupvalueautoresdir & "\*.*",  $wallpaperbackgrounds & "\", 1)
		FileCopy ($setupvalueautoresdir & "\*.*",  $userbackgrounds  & "\", 1)
		$ssresfile = WallpaperAutoRes ($wallpapertempoptarray)
		CommonWriteLog ("Automatic Resolution Set The Wallpaper Wallpaper To " & $ssresfile)
	EndIf
	WallpaperGenConfig ()
EndFunc

Func WallpaperAutoRes (ByRef $ararray)
	$arresfile = "autores." & $graphsize
	If Not FileExists ($wallpapertempback & "\" & $arresfile & ".jpg") Then $arresfile = "autores.default"
	CommonWallpaperPutOption  ("name", $arresfile, $ararray)
	WallpaperWriteOptionsFile ($wallpapercustopt, $ararray)
	Return $arresfile
EndFunc

Func WallpaperAddImages ()
	$aicount = ""
	$aimsg   = ""
	$aiarray = CommonFileDialog ("Select image files for the theme wallpaper", $dialogpathhold, "Image Files (*.jpg)", 5, "",  $handlewallpapergui)
	If Ubound ($aiarray) <> 0 Then
		$aimsg = "These image files were selected from the " & $aiarray [0] & " directory" & @CR & @CR & @CR
		For $aisub = 1 To Ubound ($aiarray) - 1
			$aifilename = $aiarray [$aisub]
			$aifilefrom = $aiarray [0] & "\" & $aifilename
			If FileGetSize ($aifilefrom) > 4 * $mega Then
				MsgBox ($mbontop, "", "File " & $aifilefrom & @CR & @CR & "Was Skipped Because It Is Too Large" & @CR & @CR & "Size Limit Is 4 MB")
				ContinueLoop
			EndIf
			$ainamefixed= StringReplace ($aifilename, " ", "-")
			$aimsg &= $aifilename & @CR & @CR
			$aifiletouser = $userbackgrounds & "\" & $ainamefixed
			$aifiletowork = $wallpapertempback   & "\" & $ainamefixed
			If FileExists ($wallpaperbackgrounds & "\" & $ainamefixed) Then ContinueLoop
			FileCopy ($aifilefrom, $aifiletouser, 1)
			FileCopy ($aifilefrom, $aifiletowork, 1)
			$aicount += 1
		Next
	EndIf
	If $aicount <> 0 Then
		MsgBox ($mbontop, "", BaseFuncCapIt (BaseFuncSing ($aicount, $aimsg) & @CR & @CR & _
			BaseFuncSing ($aicount, $aicount & " image files were added to the " & $userbackgrounds & " directory")))
		BaseFuncGuiDelete    ($wallpaperselecthandlegui)
	EndIf
	WallpaperSelectRunGUI (CommonWallpaperGetOption ("name"))
EndFunc

Func WallpaperDelImage ($disub)
	;_ArrayDisplay ($wallpaperselectarray, $disub)
	$diname = $wallpaperselectarray [$disub] [$sBackName]
	$dirc = MsgBox ($mbquestyesno, "", "Are you sure you want to" & @CR & "delete this wallpaper image?" & @CR & @CR & $diname)
	If $dirc <> $IDYES Then Return "NoDelete"
	FileRecycle ($userbackgrounds  & "\" & $diname & ".jpg")
	FileDelete  ($wallpapertempback    & "\" & $diname & ".jpg")
	FileDelete  ($wallpaperlocalpath   & "\" & $diname & ".txt")
	BaseFuncGuiCtrlDelete ($wallpaperselectarray [$disub] [$sBackDelete])
	BaseFuncGuiCtrlDelete ($wallpaperselectarray [$disub] [$sBackImage])
	GUICtrlSetData     ($wallpaperselectarray [$disub] [$sBackSelect], "*** Deleted Image ***" & @CR & $diname)
	GUICtrlSetState    ($wallpaperselectarray [$disub] [$sBackSelect], $guishowdis)
	GUICtrlSetState    ($wallpaperselectarray [$disub] [$sBackBorder], $guishowdis)
EndFunc

Func WallpaperGenConfig ()
	Dim $tgc64biosarray [1]
	Dim $tgc64efiarray  [1]
	Dim $tgc32biosarray [1]
	Dim $tgc32efiarray  [1]
	$tgcmenutop    = Int ($wallpapercenterstart * 8) + 5
	$tgcmenuheight = Int ($wallpapercentersize  * 6.9)
	$tgcthemefont  = SettingsGet     ($setwallpaperfont)
	$tgcfontsub    = WallpaperFontFields ($tgcthemefont)
	If CommonWallpaperGetOption ("style") = "progress bar" and $tgcmenutop + $tgcmenuheight > 90 Then $tgcmenuheight = 90 - $tgcmenutop
	If $tgcmenutop + $tgcmenuheight > 100 Then $tgcmenuheight = 100 - $tgcmenutop
	$tgchandle     = FileOpen ($wallpapertemplate)
	While 1
		$tgcrecord = FileReadLine ($tgchandle)
		If @error Then ExitLoop
		If StringInStr ($tgcrecord, "*menusizestring*") Then
		    If $tgcmenuheight = 0 Then $tgcmenuheight = 82
			$tgcrecord = "   top  = " & $tgcmenutop & "%    height = " & $tgcmenuheight & "%"
		EndIf
		$tgcincloc = StringInStr ($tgcrecord, "##g2w-include")
		If $tgcincloc <> 0 Then
			$tgcparse = StringStripWS (StringTrimLeft ($tgcrecord, $tgcincloc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			$tgcrecvalue = StringLeft ($tgcsplit [2], 4)
			If @error Then ContinueLoop
			$tgcoptvalue = StringLeft (CommonWallpaperGetOption ($tgcsplit [1], "lower"), 4)
			If $tgcrecvalue <> $tgcoptvalue Then ContinueLoop
			;_ArrayDisplay ($tgcsplit, $tgcparse & " " & $tgccompare)
		EndIf
		$tgcreploc = StringInStr ($tgcrecord, "##g2w-replace")
		If $tgcreploc <> 0 Then
			$tgcparse = StringStripWS (StringTrimLeft ($tgcrecord, $tgcreploc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			If @error Then ContinueLoop
			$tgcrep   = CommonWallpaperGetOption ($tgcsplit [1])
			Select
				Case StringInStr ($tgcrecord, "*fontbold*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sFontBold]
				Case StringInStr ($tgcrecord, "*fontnormal*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sFontNormal]
				Case StringInStr ($tgcrecord, "*fontsmall*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sFontSmall]
				Case StringInStr ($tgcrecord, "*fontname*")
				       $tgcrep = StringRight ($fontarray [$tgcfontsub] [$sFontName], 2)
					   ;If $wallpaperfontauto = "yes" Then $tgcrep &= " Auto"
				Case StringInStr ($tgcrecord, "*fontsmallest*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sFontSmallest]
				Case StringInStr ($tgcrecord, "*canvasleft*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sBannerLeft]
				Case StringInStr ($tgcrecord, "*clockleft*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sClockLeft]
				Case StringInStr ($tgcrecord, "*secondsleft*")
					   $tgcrep = $fontarray [$tgcfontsub] [$sSecondsLeft]
				Case StringInStr ($tgcrecord, "*barleft*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sBarLeft]
				Case StringInStr ($tgcrecord, "*barwidth*")
				       $tgcrep = $fontarray [$tgcfontsub] [$sBarWidth]
				Case StringInStr ($tgcrecord, "*grubversion*")
				      $tgcrep = $basrelcurr
				Case Else
				      $tgcrep = StringLower ($tgcrep)
			EndSelect
			$tgcrecord = StringReplace ($tgcrecord, $tgcsplit [2], $tgcrep)
			;_ArrayDisplay ($tgcsplit, $tgcparse)
		EndIf
		$tgcparmloc = StringInStr ($tgcrecord, "##g2w")
		If $tgcparmloc <> 0 Then $tgcrecord  = StringLeft  ($tgcrecord, $tgcparmloc - 1)
		If StringInStr ($tgcrecord, "*clockfacestring*") Then
			$tgcface = CommonWallpaperGetOption ("face")
			If $tgcface = $noface Then ContinueLoop
			$tgcfacestring = '"common/clockfaces/' & $tgcface & '.png"'
			If Not FileExists ($wallpaperfaces & "\" & $tgcface & ".png") Or $tgcface = $ticksonly _
				Then $tgcfacestring = '"common/static/image.empty.png"'
			$tgcfacestring &= '   tick_bitmap = "common/colorcustom/tick.png"'
			$tgcrecord      = '   center_bitmap   = ' & $tgcfacestring
		EndIf
		$tgcoutefi  = StringStripWS ($tgcrecord, 2)
		$tgcoutbios = $tgcoutefi
		If StringInStr ($tgcrecord, "*bootmodestring*") Then
			_ArrayAdd ($tgc64efiarray,  '                  text   = "EFI  64 Bit"}')
			_ArrayAdd ($tgc64biosarray, '                  text   = "BIOS 64 Bit"}')
			_ArrayAdd ($tgc32efiarray,  '                  text   = "EFI  32 Bit"}')
			_ArrayAdd ($tgc32biosarray, '                  text   = "BIOS 32 Bit"}')
			ContinueLoop
		EndIf
		_ArrayAdd ($tgc64efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc64biosarray, $tgcoutbios)
		_ArrayAdd ($tgc32efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc32biosarray, $tgcoutbios)
	Wend
	;_ArrayDisplay ($tgcefiarray)
	FileDelete       ($wallpaperconfig & "*")
	BaseFuncArrayWrite ($wallpaperconfig & ".64.bios.txt", $tgc64biosarray)
	BaseFuncArrayWrite ($wallpaperconfig & ".64.efi.txt",  $tgc64efiarray)
	BaseFuncArrayWrite ($wallpaperconfig & ".32.bios.txt", $tgc32biosarray)
	BaseFuncArrayWrite ($wallpaperconfig & ".32.efi.txt",  $tgc32efiarray)
	If FileExists ($userthemes & "\*.config.*") Then _
		FileCopy  ($userthemes & "\custom.config." & $osbits & "." & $firmwaremode & ".txt", $wallpaperpath & "\", 1)
EndFunc

Func WallpaperMainScreenShot ()
	WallpaperBuildScreenShot ()
	BaseFuncGuiCtrlDelete ($screenpicturehandle)
	BaseFuncGuiCtrlDelete ($screenshothandle)
	BaseFuncGuiCtrlDelete ($screenpreviewhandle)
    $ssname  = CommonWallpaperGetOption ("name")
	$sstheme = BaseFuncCapIt ($ssname)
	If $ssname <> $nowallpaper Then $wallpapergraphname = $ssname
	$sstext = 'Preview of wallpaper  "' & $sstheme & '"'
	If $graphset <> $textstring  Then $sstext &= '  -  Click to customize'
	If $sstheme  =  $nowallpaper Then $sstext = $nowallpaperdesc
	$screenshothandle    = CommonScaleCreate ("Label",   "",              44,  1, 55, 52)
	$screenpicturehandle = CommonScaleCreate ("Picture", $screenshotfile, 44,  1, 55, 52)
	$screenpreviewhandle = CommonScaleCreate ("Label",   $sstext,         44, 53, 55,  9, $SS_CENTER)
	GUICtrlSetState ($screenshothandle, $guishowit)
EndFunc

Func WallpaperSelectRunGUI ($rgname)
	WallpaperSelectSetup   ($rgname)
	WallpaperSelectRefresh ($wallpaperselectcurrsub)
	GUISetState (@SW_HIDE, $handlewallpapergui)
	GUISetState (@SW_SHOW, $wallpaperselecthandlescroll)
	GUISetState (@SW_SHOW, $wallpaperselecthandlegui)
	While 1
		$rgstatusarray = GUIGetMsg(1)
		If $rgstatusarray[1] <> $wallpaperselecthandlescroll and $rgstatusarray [1] <> $wallpaperselecthandlegui Then ContinueLoop
		$rgstatus = $rgstatusarray [0]
		Select
			Case $rgstatus = "" Or $rgstatus = 0
			Case $rgstatus = $wallpaperselecthandleadd
				WallpaperAddImages ()
				ExitLoop
			Case $rgstatus = $wallpaperselecthandledone Or $rgstatus = $GUI_EVENT_CLOSE
				ExitLoop
			Case Else
				For $rgselectsub = 0 To Ubound ($wallpaperselectarray) - 1
					If $rgstatus = $wallpaperselectarray [$rgselectsub] [$sBackDelete] Then
						If WallpaperDelImage   ($rgselectsub) Then ContinueLoop
						;WallpaperSelectRefresh ($wallpaperselectcurrsub)
						ContinueLoop
					EndIf
					If $rgstatus = $wallpaperselectarray [$rgselectsub] [$sBackBorder] Or $rgstatus = $wallpaperselectarray [$rgselectsub] [$sBackSelect] Then
						WallpaperSelectRefresh ($rgselectsub)
						ContinueLoop
					EndIf
				Next
		EndSelect
	WEnd
	GUISetState (@SW_HIDE, $wallpaperselecthandlescroll)
	GUISetState (@SW_HIDE, $wallpaperselecthandlegui)
	GUISetState (@SW_SHOW, $handlewallpapergui)
	Return $wallpaperselectarray [$wallpaperselectcurrsub] [$sBackName]
EndFunc

Func WallpaperSelectSetup ($sscurrname)
	CommonCopyUserFiles ("yes")
	If $wallpaperselecthandlegui <> "" Then Return
	$wallpaperselecthandlegui    = CommonScaleCreate ("GUI",    "Click on the wallpaper you want to use",    -1, -1, 110.5, 101.5)
	$wallpaperselecthandleadd    = CommonScaleCreate ("Button", "Add Your Own JPG Images",                   16, 92,  25,     6)
	$wallpaperselecthandledone   = CommonScaleCreate ("Button", "OK Done",                                   76, 92,  18,     6)
	$wallpaperselecthandlescroll = CommonScaleCreate ("GUI",    "",                                           0,  3, 110,    86,   $WS_CHILD, "", $wallpaperselecthandlegui)
	GUICtrlSetBkColor ($wallpaperselecthandleadd,  $mygreen)
	GUICtrlSetBkColor ($wallpaperselecthandledone, $mygreen)
	$ssvert      = 3
	$sshor       = 9
	$ssautofound = ""
	Dim $wallpaperselectarray [0] [5]
	$sshandledesc = ""
	_ArrayAdd ($wallpaperselectarray, "||basic")
	$sshandle = FileFindFirstFile ($wallpapertempback & "\*.jpg")
	While 1
		$ssname = FileFindNextFile ($sshandle)
		If @error Then ExitLoop
		$ssname = StringLower ($ssname)
		If $ssname = "nowallpaper.jpg" Or $ssname = "common.jpg" Or $ssname = "basic.jpg" Then ContinueLoop
		Select
			Case StringLeft  ($ssname, 7) <> "autores"
			Case StringInStr ($ssname,       "default")
				If $ssautofound = "yes" Then ContinueLoop
			Case Not StringInStr ($ssname, $graphsize)
				ContinueLoop
			Case Else
				$ssautofound = "yes"
		EndSelect
		_ArrayAdd ($wallpaperselectarray, "||" & StringTrimRight ($ssname, 4))
	WEnd
	FileClose ($sshandle)
	If Ubound ($wallpaperselectarray) > 12 Then CommonFlashStart ("Loading The Wallpaper Images", "This May Take A Few Seconds", 0)
	GUISwitch ($wallpaperselecthandlescroll)
	For $sssub  = 0 To Ubound ($wallpaperselectarray) -1
		$ssfile = $wallpaperselectarray [$sssub] [$sBackName]
		If $ssfile = $sscurrname Then $wallpaperselectcurrsub = $sssub
		$sshandlebutton = CommonBorderCreate _
			($wallpapertempback & "\" & $ssfile & ".jpg", $sshor - 1, $ssvert - 1.5, 41, 28, $sshandledesc, $ssfile, 1)
		$wallpaperselectarray [$sssub] [$sBackImage] = $borderpichandle
		If Not FileExists ($wallpaperbackgrounds & "\" & $ssfile & ".jpg") Then
			$sshandledel = CommonScaleCreate ("Button", "Delete", $sshor - 7, $ssvert + 12, 6, 3)
			GUICtrlSetFont    ($sshandledel, $fontsizesmall)
			$wallpaperselectarray [$sssub] [$sBackDelete] = $sshandledel
		EndIf
		$wallpaperselectarray [$sssub] [$sBackBorder] = $sshandlebutton
		$wallpaperselectarray [$sssub] [$sBackSelect] = $sshandledesc
		$sshor += 55
		If $sshor > 90 Then
			$ssvert += 35
			$sshor   = 9
		EndIf
	Next
	If $sssub > 10 Then
		$ssvert += Int ($sssub / 1.7)
		If Mod ($sssub, 2) = 1 Then $ssvert += 30
	EndIf
	CommonScrollGenerate ($wallpaperselecthandlescroll, $scalehsize, ($ssvert) * $scalepctvert)
	CommonFlashEnd ("")
EndFunc

Func WallpaperSelectRefresh ($irselection)
	; _ArrayDisplay ($wallpaperselectarray, $wallpaperselectcurrsub)
	Local $irhandlemove
	$wallpaperselectcurrsub = $irselection
	For $irsub = 0 To Ubound ($wallpaperselectarray) - 1
		$irhandlebutton = $wallpaperselectarray [$irsub] [$sBackBorder]
		$irhandledesc   = $wallpaperselectarray [$irsub] [$sBackSelect]
		$irdesc         = $wallpaperselectarray [$irsub] [$sBackName]
		$irhandledelete = $wallpaperselectarray [$irsub] [$sBackDelete]
		If $irsub = $irselection Then
			GUICtrlSetBKColor ($irhandlebutton, $myred)
			If $irhandledelete <> "" Then GUICtrlSetState ($irhandledelete, $guihideit)
			$irhandlemove = $irhandledesc
		Else
			If $irhandledelete <> "" Then GUICtrlSetState ($irhandledelete, $guishowit)
			GUICtrlSetBKColor ($irhandlebutton, $mylightgray)
		EndIf
	Next
    CommonScrollCenter ($wallpaperselecthandlegui, $wallpaperselecthandlescroll, $irhandlemove, $wallpaperselectarray)
EndFunc

Func WallpaperFontSetup ()
	$fsreturn  = ""
	$fsgap     = _StringRepeat (" ", 24)
	For $fssub = 0 To Ubound ($fontarray) - 1
		$fsrec     = $fontarray [$fssub] [$sFontName]
		$fontarray [$fssub] [$sFontExpand] = StringTrimRight ($fsrec, 2) & $fsgap & StringRight ($fsrec, 2)
		$fsgap     = "  "
		If StringRight ($fsrec, 2) < 16 Then ContinueLoop
		$fsreturn &= $fontarray [$fssub] [$sFontExpand] & "|"
	Next
	Return StringTrimRight ($fsreturn, 1)
EndFunc

Func WallpaperFontFields ($ffname)
	$ffsub   = _ArraySearch ($fontarray, $ffname)
	$ffpoint = StringRight     ($ffname, 2)
	$ffstrip = StringTrimRight ($ffname, 2)
	$fontarray [$ffsub] [$sFontBold]     = $ffstrip & "Bold "    & $ffpoint
	$fontarray [$ffsub] [$sFontNormal]   = $ffstrip & "Regular " & $ffpoint
	If $ffpoint > 15 And Not StringInStr ($ffname, "Unifont") Then $ffpoint   -= 4
	$fontarray [$ffsub] [$sFontSmall]    = $ffstrip & "Regular " & $ffpoint
	If $ffpoint > 15 And Not StringInStr ($ffname, "Unifont") Then $ffpoint   -= 4
	$fontarray [$ffsub] [$sFontSmallest] = $ffstrip & "Regular " & $ffpoint
	If StringInStr ($ffname, "Unifont") Then $fontarray [$ffsub] [$sFontBold] = $fontarray [$ffsub] [$sFontSmall]
	$wallpaperfontlimit = $fontarray [$ffsub] [$sHotKeyLimit]
	;MsgBox ($mbontop, "Fields " & $ffname, $ffstrip & @CR & @CR & $ffsub & @CR & @CR & $fontarray [$ffsub] [$sFontBold] & @CR & @CR & $fontarray [$ffsub] [$sFontSmall])
	Return $ffsub
EndFunc

Func WallpaperFontSelect ()
	BaseFuncGUICtrlDelete ($handlewallpaperfont)
	$fafontsub           = WallpaperFontFields   ($wallpaperfont)
	If CommonCheckBox     ($handlewallpaperauto) Then
		$wallpaperfontauto   = "yes"
		$fafontsub       = WallpaperGraphGetAuto ($wallpaperfont)
		$handlewallpaperfont = CommonScaleCreate ("Label", $fontarray [$fafontsub] [$sFontName], 14,   4,   19, 3.5, $SS_CENTER)
	Else
		$wallpaperfontauto   = "no"
		$handlewallpaperfont = CommonScaleCreate ("Combo", "",                                   16,   4,   19, 3.5)
		GUICtrlSetData   ($handlewallpaperfont,  $wallpaperfontstring, $fontarray [$fafontsub] [$sFontExpand])
	EndIf
	Return $fontarray [$fafontsub] [$sFontName]
EndFunc

Func WallpaperGraphGetAuto (ByRef $wallpaperfont)
	If $wallpaperfontauto <> "yes" Then Return
	$gghoriz = ""
	$ggsplit  = StringSplit ($graphset, "x")
	If @error Then $gghoriz = 1024
	$gghoriz = $ggsplit [1]
	If $gghoriz = $autostring Then $gghoriz = 1600
    For $gasub = 0 To Ubound ($fontarray) - 1
		If $gghoriz <= $fontarray [$gasub] [$sHorizRes] Then ExitLoop
	Next
	$wallpaperfont = $fontarray [$gasub] [$sFontName]
	Return $gasub
	;_ArrayDisplay ($ggsplit, $gghoriz & "   " & $gasub)
EndFunc

Func WallpaperCreateHold ()
	$wallpaperoptarray     = WallpaperGetCurrent ()
	$wallpapertempoptarray = $wallpaperoptarray
	DirRemove ($wallpapertemp, 1)
	DirCreate ($wallpapertemp)
	DirCreate ($wallpapertempfiles)
	FileCopy  ($wallpaperpath & "\custom.*", $wallpapertempfiles, 1)
	DirCopy   ($wallpapercolorcustom,        $wallpapertempcust, 1)
	DirCopy   ($wallpaperlocalpath,          $wallpapertemplocal, 1)
EndFunc

Func WallpaperRestoreHold ()
	FileCopy  ($wallpapertempfiles & "\custom.*", $wallpaperpath, 1)
	DirCopy   ($wallpapertempcust,                $wallpapercolorcustom, 1)
	DirCopy   ($wallpapertemplocal,               $wallpaperlocalpath , 1)
	DirRemove ($wallpapertemp, 1)
	$wallpapertempoptarray = $wallpaperoptarray
	$wallpaperfont     = $wallpaperfontsave
	$wallpaperfontauto = $wallpaperautosave
EndFunc