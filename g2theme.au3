#include-once
#include <g2common.au3>

Const  $sBackBorder = 0, $sBackSelect = 1, $sBackName = 2, $sBackRemove = 3, $sBackImage = 4

If StringInStr (@ScriptName, "g2theme") Then
	CommonHotKeys       ()
	BaseFuncGuiDelete     ($upmessguihandle)
	CommonCopyUserFiles ()
	GetPrevConfig       ()
	ThemeEdit           ()
	ThemeUpdateFiles    ()
	BaseFuncCleanupTemp    ("Theme")
EndIf

Func ThemeEdit          ()
	If StringLeft ($graphset, 7) = "800x600" Then Return
	CommonCopyUserFiles ()
	ThemeCreateHold     ()
	ThemeSetupGUI       ()
	$terc = ThemeRunGUI ()
	Return $terc
EndFunc

Func ThemeSetupGUI ()
	BaseFuncGuiDelete ($handlethemegui)
	$handlethemegui    = CommonScaleCreate ("GUI", "Customize Theme",                -1,  -1, 108,  107,  -1, -1, $handlemaingui)
	                     CommonScaleCreate ("Label",    "Click the image to select your background", 5, 6.8, 33, 2.2)
	$buttonthemehelp   = CommonScaleCreate ("Button",   "Help",                       1,   1,    8, 3.5)
	GUICtrlSetBkColor  ($buttonthemehelp, $mymedblue)
	$handlethemecenter = CommonScaleCreate ("Checkbox", " Center Menus",             40,   3,   13, 3.5)
	$buttonthemecolgrp = CommonScaleCreate ("Group",    "Set Colors",                55,   0,   47, 8, $BS_CENTER)
	$buttonthemecoltit = CommonScaleCreate ("Button",   "Titles",                    58,   3,    7, 3.5)
	$buttonthemecolsel = CommonScaleCreate ("Button",   "Selected Item",             68,   3,   10, 3.5)
	$buttonthemecoltxt = CommonScaleCreate ("Button",   "Text",                      81.5, 3,    7, 3.5)
	$buttonthemecolclk = CommonScaleCreate ("Button",   "Clock",                     92,   3,    7, 3.5)
	$handlethemeshot   = CommonScaleCreate ("Label",    "",                           4,   9,  101, 78)
	$handlethemepic    = CommonScaleCreate ("Picture",  $screenshotfile,              4,   9,  101, 78)
	$handlethemetime   = CommonScaleCreate ("Checkbox", " Enable Grub Timeout",       6,  90,   16, 3.5)
	$handlethemesecs   = CommonScaleCreate ("Input",    $timeoutgrub,                 23,  90.3,  4.5, 3, $ES_RIGHT)
	$handlethemeseclab = CommonScaleCreate ("Label",    "seconds",                   28,  90.6,  8,   3)
	$handlethemesecud  = GUICtrlCreateUpdown ($handlethemesecs, $UDS_ALIGNLEFT)
    $handlethemelabs   = CommonScaleCreate ("Label",    "Style",                     18.5, 95.8,  8, 3.5)
	$handlethemestyle  = CommonScaleCreate ("Combo",    "",                          22,   95.3, 14, 10,  -1)
	$handlethemelab1   = CommonScaleCreate ("Label",    "Face",                      18.5, 99.3,  8, 3.5)
	$handlethemeface   = CommonScaleCreate ("Combo",    "",                          22,   99,  15, 3.5, -1)
	$handlethemedesc   = CommonScaleCreate ("Label",    "",                           4,   87, 101, 3.0, $SS_CENTER)
	$handlethemedark   = CommonScaleCreate ("Checkbox", " Dark Background",          45,   92,  20, 3.5)
	$handlethemehilite = CommonScaleCreate ("Checkbox", " Highlight Selected Item",  45,   97,  20, 3.5)
	$handlethemescroll = CommonScaleCreate ("Checkbox", " Show Scroll Bar (if needed)", 45,  102,  21, 3.5)
	$handlethememode   = CommonScaleCreate ("Checkbox", " Show Boot Mode",           68,   97,  25, 3.5)
	$handlethemevers   = CommonScaleCreate ("Checkbox", " Show Grub2Win Version",    68,   92,  20, 3.5)
	$handlethemelines  = CommonScaleCreate ("Checkbox", " Show Prompt Lines",        68,  102,  20, 3.5)
	$buttonthemereset  = CommonScaleCreate ("Button",   "Set Standard View",         93,   90,  13, 3.8)
	$buttonthemecancel = CommonScaleCreate ("Button",   "Cancel",                     4,  100,  10, 3.8)
	$buttonthemeok     = CommonScaleCreate ("Button",   "OK",                        94,  100,  10, 3.8)
	GUICtrlSetData     ($handlethemeface,  ThemeGetFaces (), CommonThemeGetOption ("face"))
	GUICtrlSetData     ($handlethemestyle, "Clock|Progress Bar")
	GUISetBkColor      ($mylightgray, $handlethemegui)
	ThemeRefreshHandles  ()
	GUISetState        (@SW_MINIMIZE, $handlemaingui)
	GUISetState        (@SW_SHOW,     $handlethemegui)
EndFunc

Func ThemeRunGUI ()
	Local $rgprevname, $rgprevstyle, $rgprevface
	$rgname        = CommonThemeGetOption ("name",  "lower")
	ThemeGetLocal ($rgname)
	$rgstyle       = CommonThemeGetOption ("style", "lower")
	$rgface        = CommonThemeGetOption ("face",  "lower")
	$rgtime        = $GUI_UNCHECKED
	$rgholdenabled = $timegrubenabled
	If $timegrubenabled = "yes" Then $rgtime = $GUI_CHECKED
	GUICtrlSetState ($handlethemetime, $rgtime)
	ThemeRefreshGUI ()
	While 1
		$rgreturn = GUIGetMSG (1)
		$rgstatus = $rgreturn [0]
		$rghandle = $rgreturn [1]
		If $rgstatus < 1 And $rgstatus <> $GUI_EVENT_CLOSE And $rgstatus <> $GUI_EVENT_PRIMARYUP And _
		    $rgstatus <> $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
		Select
			Case $rgstatus = $GUI_EVENT_CLOSE Or $rgstatus = $buttonthemecancel
				If $rghandle <> $handlethemegui Then ContinueLoop
				$timegrubenabled = $rgholdenabled
				ThemeRestoreHold ()
				ExitLoop
			Case $rgstatus = $GUI_EVENT_PRIMARYUP
				If CommonCheckUpDown ($handlethemesecs, $timeoutgrub, 0, 999) Then ThemeRefreshGUI ()
			Case $rgstatus = $buttonthemehelp
				CommonHelp ("Customizing The Theme")
				ContinueLoop
			Case $rgstatus = $handlethemeshot Or $rgstatus = $handlethemedesc
				$rgname    = ThemeSelectRunGUI ($rgname)
				If StringLeft ($rgname, 7) = "autores" Then
					$rgname = ThemeAutoRes ($themetempoptarray)
					CommonWriteLog ("    Automatic Resolution Set The Theme Background To " & $rgname)
				EndIf
				If $rgname = $rgprevname Then ContinueLoop
				ThemeGetLocal ($rgname)
				CommonThemePutOption ("name", $rgname, $themetempoptarray)
				ThemeResetColor ()
				ThemeRefreshGUI ($rgname)
				$rgprevname = $rgname
			Case $rgstatus = $handlethemetime
				$timegrubenabled = "no"
				If CommonCheckBox ($handlethemetime) Then $timegrubenabled = "yes"
				ThemeRefreshGUI ($rgname)
			Case $rgstatus = $handlethemedark
				ThemeCheckBox   ($handlethemedark,   "dark")
			Case $rgstatus = $handlethemescroll
				ThemeCheckBox   ($handlethemescroll, "scrollbar")
			Case $rgstatus = $handlethemehilite
				ThemeCheckBox   ($handlethemehilite, "highlight")
			Case $rgstatus = $handlethemelines
				ThemeCheckBox   ($handlethemelines,  "lines")
			Case $rgstatus = $handlethemevers
				ThemeCheckBox   ($handlethemevers,   "version")
			Case $rgstatus = $handlethememode
				ThemeCheckBox   ($handlethememode,   "bootmode")
			Case $rgstatus = $handlethemecenter
				ThemeCheckBox   ($handlethemecenter, "center")
			Case $rgstatus = $handlethemeface
				$rgface = StringLower (GUICtrlRead ($handlethemeface))
				CommonThemePutOption ("face", $rgface, $themetempoptarray)
				If $rgface <> $rgprevface Then ThemeRefreshGUI ()
				$rgprevface = $rgface
			Case $rgstatus = $handlethemestyle
				$rgstyle = StringLower (GUICtrlRead ($handlethemestyle))
				CommonThemePutOption ("style", $rgstyle, $themetempoptarray)
				If $rgstyle <> $rgprevstyle Then ThemeRefreshGUI ()
				$rgprevstyle = $rgstyle
			Case $rgstatus = $buttonthemecoltit
				$rgcolortit   = CommonThemeGetOption ("coltitle")
				ThemeGetColors ($rgname, "coltitle",  $rgcolortit)
			Case $rgstatus = $buttonthemecolsel
				$rgcolorsel   = CommonThemeGetOption ("colselect")
				ThemeGetColors ($rgname, "colselect", $rgcolorsel)
			Case $rgstatus = $buttonthemecoltxt
				$rgcolortext  = CommonThemeGetOption ("coltext")
				ThemeGetColors ($rgname, "coltext", $rgcolortext, "yes")
			Case $rgstatus = $buttonthemecolclk
				$rgcolorclock = CommonThemeGetOption ("colclock")
				ThemeGetColors ($rgname, "colclock", $rgcolorclock, "yes")
			Case $rgstatus = $buttonthemereset
				$themetempoptarray = ThemeLoadOptions ($themestandpath & "\" & $rgname & ".txt")
				$timegrubenabled = "yes"
				ThemeResetColor ()
				ThemeSetupGUI   ()
				GUICtrlSetState ($handlethemetime, $GUI_CHECKED)
				ThemeRefreshGUI ($rgname)
			Case $rgstatus = $buttonthemeok
				GuiCtrlSetData ($updowngt, $timeoutgrub)
				$rgvariable = StringLower (StringReplace ($rgname, "-", "_"))
				Assign ("themeoptarrayhold_" & $rgvariable, $themetempoptarray, 2)
				ExitLoop
			Case Else
		EndSelect
	WEnd
	BaseFuncGuiDelete ($handlethemegui)
	BaseFuncGuiDelete ($themeselecthandlegui)
	If $rgstatus = $buttonthemeok Then
		Return "OK"
	Else
		Return "Cancelled"
	EndIf
EndFunc

Func ThemeCheckBox ($tcbhandle, $tcbkey)
	$tcbvalue = "no"
	If CommonCheckBox    ($tcbhandle) Then $tcbvalue = "yes"
	CommonThemePutOption ($tcbkey, $tcbvalue, $themetempoptarray)
	ThemeRefreshGUI ()
EndFunc

Func ThemeRefreshGUI ($rgname = "")
	GUICtrlSetState ($handlethemelab1,   $guihideit)
	GUICtrlSetState ($handlethemelabs,   $guihideit)
	GUICtrlSetState ($handlethemestyle,  $guihideit)
	GUICtrlSetState ($handlethemeface,   $guihideit)
	If $rgname = "" Then $rgname = CommonThemeGetOption ("name")
	ThemeBuildScreenShot ($rgname)
	If $rgname = $notheme Then
		$rgnamedesc = $nothemedesc
		GUICtrlSetState ($handlethemedark,   $guihideit)
		GUICtrlSetState ($handlethemescroll, $guihideit)
		GUICtrlSetState ($handlethemehilite, $guihideit)
		GUICtrlSetState ($handlethemelines,  $guihideit)
		GUICtrlSetState ($handlethemevers,   $guihideit)
		GUICtrlSetState ($buttonthemereset,  $guihideit)
		GUICtrlSetState ($handlethememode,   $guihideit)
		GUICtrlSetState ($handlethemecenter, $guihideit)
		GUICtrlSetState ($buttonthemecolgrp, $guihideit)
		GUICtrlSetState ($buttonthemecoltit, $guihideit)
		GUICtrlSetState ($buttonthemecolsel, $guihideit)
		GUICtrlSetState ($buttonthemecoltxt, $guihideit)
		GUICtrlSetState ($buttonthemecolclk, $guihideit)
	Else
		$rgnamedesc = BaseFuncCapIt ($rgname)
		GUICtrlSetState ($handlethemedark,   $guishowit)
		GUICtrlSetState ($handlethemescroll, $guishowit)
		GUICtrlSetState ($handlethemehilite, $guishowit)
		GUICtrlSetState ($handlethemelines,  $guishowit)
		GUICtrlSetState ($handlethemevers,   $guishowit)
		GUICtrlSetState ($handlethememode,   $guishowit)
		GUICtrlSetState ($handlethemecenter, $guishowit)
		GUICtrlSetState ($buttonthemereset,  $guishowit)
		GUICtrlSetState ($buttonthemecolgrp, $guishowit)
		GUICtrlSetState ($buttonthemecoltit, $guishowit)
		GUICtrlSetState ($buttonthemecolsel, $guishowit)
		GUICtrlSetState ($buttonthemecoltxt, $guishowit)
		GUICtrlSetState ($buttonthemecolclk, $guishowit)
		GUICtrlSetState ($handlethemelabs,   $guishowit)
		GUICtrlSetState ($handlethemestyle,  $guishowit)
		GUICtrlSetState ($handlethemeface,   $guishowit)
		GUICtrlSetState ($handlethemelab1,   $guishowit)
	EndIf
	If $timegrubenabled = "yes" Then
		If CommonThemeGetOption ("style") = "clock" Then
			GUICtrlSetPos   ($buttonthemecolgrp, Default, Default, $scalepcthorz * 47)
		Else
			GUICtrlSetState ($handlethemeface,   $guihideit)
			GUICtrlSetState ($handlethemelab1,   $guihideit)
			GUICtrlSetState ($buttonthemecolclk, $guihideit)
			GUICtrlSetPos   ($buttonthemecolgrp, Default, Default, $scalepcthorz * 36.5)
		EndIf
		GUICtrlSetState ($handlethemesecs,   $guishowit)
		GUICtrlSetState ($handlethemeseclab, $guishowit)
		GUICtrlSetState ($handlethemesecud,  $guishowit)
	Else
		GUICtrlSetState ($handlethemelabs,   $guihideit)
		GUICtrlSetState ($handlethemestyle,  $guihideit)
		GUICtrlSetState ($handlethemeface,   $guihideit)
		GUICtrlSetState ($handlethemelab1,   $guihideit)
		GUICtrlSetState ($handlethemesecs,   $guihideit)
		GUICtrlSetState ($handlethemeseclab, $guihideit)
		GUICtrlSetState ($handlethemesecud,  $guihideit)
	EndIf
	If Not FileExists ($themestandpath & "\" & $rgname & ".txt") Then _
		GUICtrlSetState ($buttonthemereset, $guihideit)
	GUICtrlSetData  ($handlethemedesc, $rgnamedesc)
	GUICtrlSetImage ($handlethemepic,  $screenshotfile)
EndFunc

Func ThemeBuildScreenShot ($wsname = "")
	If $wsname = "" Then $wsname = CommonThemeGetOption ("name")
	If $wsname = $notheme Then
		ThemeGDISetup     ($themestatic & "\image.notheme.jpg", "Arial", 16)
		ThemeBuildNotheme ()
		ThemeGDICloseout  ($screenshotfile)
	Else
		$wsnamelow = StringLower ($wsname)
		ThemeGDISetup    ($themetempback & "\" & $wsnamelow & ".jpg", "Arial", 16)
		ThemeBuildImage  ()
		ThemeGDICloseout ($screenshotfile)
	EndIf
EndFunc

Func ThemeBuildBackground ($tbbfile)
	ThemeGDISetup    ($tbbfile, "Arial", 16)
	ThemeGDICloseout ($themecustback)
EndFunc

Func ThemeBuildImage ()
	$tbibound     = Ubound ($selectionarray) - $selectionmisccount - 1
	$tbilimit     = 12
	$tbiscroll    = 735
	If CommonThemeGetOption ("style") = "progress bar" Then
		$tbilimit  -= 1
		$tbiscroll  = 685
	EndIf
	$themecenterstart = ($tbilimit / 2) - ($tbibound / 2) - 1
	If $themecenterstart <   0 Then $themecenterstart =   0
	If $themecenterstart > 3.5 Then $themecenterstart = 3.5
	$themecentersize = $tbibound + 1
	If CommonThemeGetOption ("center") = "no" Then
		$themecenterstart = 0
		$themecentersize  = $tbilimit
	EndIf
	If $themecentersize > $tbilimit Then $themecentersize = $tbilimit
	;MsgBox ($mbontop, "Start", $tbilimit & @TAB & ($tbilimit / 2) & @CR & $tbibound & @TAB & ($tbibound / 2 ) & @CR & $themecenterstart)
	$tbivert = ($themecenterstart * 60) + 30
	$tbidark = CommonThemeGetOption ("dark")
	If CommonThemeGetOption ("scrollbar") = "yes" And $tbibound >= $tbilimit Then _
	    ThemeLayerImage ($themestatic & "\image.scrollbar.png", 855, 20,        19, $tbiscroll)
	For $tbisub = 0 To $tbibound
		If $tbisub = $tbilimit Then Exitloop
		$tbibrush  = $brushtitle
		$tbiicon   = $selectionarray [$tbisub] [$sIcon]
		$tbitext   = $selectionarray [$tbisub] [$sEntryTitle]
		If $tbidark = "yes" Then ThemeLayerImage ($themestatic & "\menubox.dark_c.png", 120, $tbivert, 725, 63)
		If $selectionarray [$tbisub] [$sDefaultOS] <> "" Then
			$tbibrush = $brushselect
			If CommonThemeGetOption ("highlight") = "yes" Then ThemeLayerImage ($themestatic & "\select_c.png", 120, $tbivert + 3, 725, 56)
		EndIf
		ThemeLayerImage ($themepath & "\icons\" & $tbiicon & ".png",             130, $tbivert +  8,  45, 45)
		ThemeLayerText  ($tbitext,                                               195, $tbivert + 17, $tbibrush)
		$tbivert += 60
	Next
	If CommonThemeGetOption ("version")  = "yes" Then
		ThemeLayerImage ($themecolorcustom & "\grub.title.png",            900, 330, 90, 24)
		ThemeLayerImage ($themecolorcustom & "\digita.png",                907, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            922, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitb.png",                927, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            942, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitc.png",                947, 370, 15, 20)
		ThemeLayerImage ($themecolorcustom & "\digitpoint.png",            962, 370,  5, 20)
		ThemeLayerImage ($themecolorcustom & "\digitd.png",                967, 370, 15, 20)
	EndIf
	If CommonThemeGetOption ("bootmode") = "yes" Then
		$tbioffset = 885
		If $firmwaremode = "EFI" Then $tbioffset = 905
		ThemeLayerImage ($themecolorcustom & "\image.type" & $firmwaremode & $procbits & ".png", $tbioffset, 425, 110, 30)
	EndIf
	If CommonThemeGetOption ("lines") = "yes" Then _
		ThemeLayerImage ($themecolorcustom & "\image.promptlines.png",     870,  40, 150, 300)
	If $timegrubenabled = "no" Then Return
	If CommonThemeGetOption ("style") = "clock" Then
		ThemeLayerText  ($timeoutgrub & "s",          938, 685, $brushclock)
		$tbiface = CommonThemeGetOption ("face")
		If $tbiface <> $noface Then
			$tbifacefile = $themefaces  & "\" & $tbiface & ".png"
			If $tbiface = $ticksonly Then $tbifacefile = $themeempty
			ThemeLayerImage ($themecolorcustom & "\image.clock.png", 901, 544, 108, 108)
			ThemeLayerImage ($tbifacefile,                      921, 559,  70,  70)
		EndIf
	EndIf
	If CommonThemeGetOption ("style")  = "progress bar" Then
		ThemeLayerImage ($themestatic & "\image.progress.bar.png",        130, 710, 790, 40)
		$tbiprogmessage = "The hilighted entry will be executed automatically in " & $timeoutgrub & "s"
		ThemeLayerText  ($tbiprogmessage,                                 220, 718, $brushtext)
	EndIf
EndFunc

Func ThemeBuildNotheme ()
	$tbngray  = _GDIPlus_BrushCreateSolid (Execute  ("0x99FFFFFF"))
	$tbntext0 = "GNU GRUB   version " & SettingsGet ($setgnugrubversion)
	ThemeLayerText  ($tbntext0,                365,  35, $tbngray)
	$tbnvert  = 110
	For $tbnsub = 0 To Ubound ($selectionarray) - $selectionmisccount - 1
		If $tbnsub > 12 Then Exitloop
		$tbntext = $selectionarray [$tbnsub] [$sEntryTitle]
		If $selectionarray [$tbnsub] [$sDefaultOS] <> "" Then _
			ThemeLayerImage ($themestatic & "\select.notheme.png", 23, $tbnvert + 12, 975, 30)
		ThemeLayerText  ($tbntext,              40, $tbnvert + 17, $tbngray)
		$tbnvert += 30
	Next
	$tbntext1 = "Use the     and     keys to select which entry is highlighted."
	$tbntext2 = "Press enter to boot the selected OS,  'e'  to edit the commands"
	$tbntext3 = "before booting or  'c'  for a command-line."
	$tbntext4 = "The hilighted entry will be executed automatically in " & $timeoutgrub & "s"
	ThemeLayerText  ($tbntext1,                               165, 625, $tbngray)
	ThemeLayerText  ($tbntext2,                               165, 650, $tbngray)
	ThemeLayerText  ($tbntext3,                               165, 675, $tbngray)
	ThemeLayerImage ($themestatic & "\image.arrow.up.png",    250, 628, 15, 15)
	ThemeLayerImage ($themestatic & "\image.arrow.down.png",  318, 632, 14, 14)
	If $timegrubenabled = "yes" Then ThemeLayerText  ($tbntext4, 165, 700, $tbngray)
	_GDIPlus_BrushDispose ($tbngray)
EndFunc

Func ThemeLayerImage ($listack, $lileft, $litop, $liwidth, $liheight)
	$lihandlestack    = _GDIPlus_ImageLoadFromFile ($listack)
	If $lihandlestack = 0 Then Return ; MsgBox ($mbontop, "GDI Get File Error", "Stack = " & $listack)
	$licontextstack   = _GDIPlus_ImageGetGraphicsContext ($lihandlestack)
	SpecFunc_GDIPlus_GraphicsDrawImageTrans ($gdicontextin, $lihandlestack, $liwidth, $liheight, $lileft, $litop)
	_GDIPlus_GraphicsDispose ($licontextstack)
	_GDIPlus_ImageDispose    ($lihandlestack)
EndFunc

Func ThemeLayerText ($lttext, $ltleft, $lttop, $ltbrush)
	$gdilayout  = _GDIPlus_RectFCreate           ($ltleft, $lttop, 0, 0)
	$gdimeasure = _GDIPlus_GraphicsMeasureString ($gdicontextin, $lttext, $gdifont, $gdilayout, $gdiformat)
	_GDIPlus_GraphicsDrawStringEx ($gdicontextin, $lttext, $gdifont, $gdimeasure [0], $gdiformat, $ltbrush)
EndFunc

Func ThemeGDISetup ($gsinfile, $gsfontname, $gsfontsize)
	_GDIPlus_Startup ()
	$gdihandlein    = _GDIPlus_ImageLoadFromFile       ($gsinfile)
	If $gdihandlein = 0 Then CommonEndIt ("Failed", "", "GDI Get File Error Input File = " & $gsinfile)
	$gdihandlein    = _GDIPlus_ImageResize             ($gdihandlein, 1024, 768)
	$gdicontextin   = _GDIPlus_ImageGetGraphicsContext ($gdihandlein)
	$gdiformat      = _GDIPlus_StringFormatCreate      ()
	$gdifontfam     = _GDIPlus_FontFamilyCreate        ($gsfontname)
	$gdifont        = _GDIPlus_FontCreate              ($gdifontfam, $gsfontsize, 0)
	ThemeSetupColors ()
EndFunc

Func ThemeGDICloseout ($gcoutfile)
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

Func ThemeGetCurrent ($tgcfile = $themecustopt)
	$tgcarray = ThemeLoadOptions ($tgcfile)
	$tgcarray = ThemeHealOptions ($tgcarray)
	Return $tgcarray
EndFunc

Func ThemeGetLocal ($glname)
	$glvariable = StringLower (StringReplace ($glname, "-", "_"))
	If IsDeclared ("themeoptarrayhold_" & $glvariable) = $DECLARED_GLOBAL Then
		$themetempoptarray = Eval ("themeoptarrayhold_" & $glvariable)
		ThemeRefreshHandles ()
		Return
	EndIf
	$glstandfile  = $themestandpath & "\" & $glname & ".txt"
	$gllocalfile  = $themelocalpath & "\" & $glname & ".txt"
	FileCopy ($glstandfile, $themecustopt, 1)
	If Not FileExists ($glstandfile) Then ThemeUserLocal ($glname, $gllocalfile)
	If Not FileExists ($gllocalfile) Then FileCopy ($glstandfile, $themecustopt, 1)
										  FileCopy ($gllocalfile, $themecustopt, 1)
	$themetempoptarray = ThemeLoadOptions ($themecustopt)
	$themetempoptarray = ThemeHealOptions ($themetempoptarray)
	CommonThemePutOption ("name", $glname, $themetempoptarray)
	ThemeRefreshHandles ()
EndFunc

Func ThemeUserLocal ($ulname, $ulfile)
	If FileExists ($ulfile) Then Return
	$ularray = ThemeLoadOptions ($themedeffile)
	CommonThemePutOption ("name", $ulname, $ularray)
	ThemeWriteOptionsFile ($ulfile, $ularray)
EndFunc

Func ThemeHealOptions (ByRef $hoinarray)
	If Not IsArray ($themedefarray) Then $themedefarray = ThemeLoadOptions ($themedeffile)
	$hohealedarray = $themedefarray
	For $hosub = 0 To Ubound ($hohealedarray) - 1
		$hofield = $hohealedarray [$hosub] [2]
		$hovalue = CommonThemeGetOption ($hofield, "", $hoinarray)
		If $hofield <> "level" And $hovalue <> "" Then $hohealedarray [$hosub] [3] = $hovalue
	Next
	Return $hohealedarray
EndFunc

Func ThemeLoadOptions ($tlofile, $tlocheck = "yes")
	Dim $tloarray  [0] [5]
	$tlohandleopts = FileOpen ($tlofile)
	While 1
		$tlorecord = FileReadLine ($tlohandleopts)
		If @error Then ExitLoop
		$tlotype     = StringStripWs (StringLeft ($tlorecord, 11),     3)
		If $tlotype  = "" Then ContinueLoop
		$tlohandname = StringStripWs (StringMid      ($tlorecord, 12, 23), 3)
		$tlokey      = StringStripWs (StringMid      ($tlorecord, 35, 10), 3)
		$tlovalue    = StringStripWs (StringTrimLeft ($tlorecord, 46)    , 3)
		_ArrayAdd ($tloarray, $tlotype & "|" & $tlohandname & "|" & $tlokey & "|" & $tlovalue & "|")
	WEnd
	FileClose ($tlohandleopts)
	$tloname = CommonThemeGetOption ("name", "", $tloarray)
	$tlobackground  = $themetempback & "\" & $tloname & ".jpg"
	If $tlocheck <> "" And $tloname <> "basic" And Not FileExists ($tlobackground) And Not CommonParms ("AutoResDir") Then
		FileDelete ($themepath &       "\custom.*")
		FileDelete ($setupolddir     & "\themes\options.local\" & $tloname & ".txt")
		FileCopy   ($thememasterpath & "\options.txt", $themepath & "\custom.options.txt",    1)
		MsgBox ($mbwarnok, "File " & $tlofile, "Theme background file " & $tlobackground & " is missing."  _
		     & @CR & @CR & 'The theme was changed to "Common"' & @CR & @CR & 'Please click "OK" to continue')
	EndIf
	;_ArrayDisplay ($tloarray)
	Return $tloarray
EndFunc

Func ThemeGetFaces ()
	$tgfstring = $noface
	$tgfhandle = FileFindFirstFile ($themefaces & "\*.png")
	While 1
		$tgfname = FileFindNextFile ($tgfhandle)
		If @error Then ExitLoop
		$tgfname = StringLower ($tgfname)
		$tgfstring &= "|" & BaseFuncCapIt (StringTrimRight ($tgfname, 4))
	WEnd
	FileClose ($tgfhandle)
	Return $tgfstring & "|" & $ticksonly
EndFunc

Func ThemeGetColors ($gcname, $gcfield, $gccurrent, $gccopy = "")
	$gccolortext = _ChooseColor (2, Execute ("0x" & $gccurrent), 2, $handlethemegui)
	If $gccolortext = -1 Then Return
	$gccolortext = StringTrimLeft ($gccolortext, 2)
	CommonThemePutOption ($gcfield, $gccolortext, $themetempoptarray)
	If $gccopy <> "" Then ThemeCopyColor ($gcfield, $gccolortext)
	; MsgBox ($mbontop, "GetColors " & $gccolortext, $gcfield)
	ThemeRefreshGUI      ($gcname)
EndFunc

Func ThemeSetupColors ()
	$tpctitle  = CommonThemeGetOption ("coltitle")
	$tpcselect = CommonThemeGetOption ("colselect")
	$tpctext   = CommonThemeGetOption ("coltext")
	$tpcclock  = CommonThemeGetOption ("colclock")
	GUICtrlSetBkColor ($buttonthemecoltit,    Execute ("0x" &   $tpctitle))
	GUICtrlSetColor   ($buttonthemecoltit,    ThemeGetContrast ($tpctitle))
	GUICtrlSetBkColor ($buttonthemecolsel,    Execute ("0x" &   $tpcselect))
	GUICtrlSetColor   ($buttonthemecolsel,    ThemeGetContrast ($tpcselect))
	GUICtrlSetBkColor ($buttonthemecoltxt,    Execute ("0x" &   $tpctext))
	GUICtrlSetColor   ($buttonthemecoltxt,    ThemeGetContrast ($tpctext))
	GUICtrlSetBkColor ($buttonthemecolclk,    Execute ("0x" &   $tpcclock))
	GUICtrlSetColor   ($buttonthemecolclk,    ThemeGetContrast ($tpcclock))
	$brushtitle  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctitle))
	$brushselect = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcselect))
	$brushtext   = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpctext))
	$brushclock  = _GDIPlus_BrushCreateSolid (Execute ("0xFF" & $tpcclock))
EndFunc

Func ThemeCopyColor ($cctype, $cccolor = "", $ccfromdir = $themecolorsource, $cctodir = $themecolorcustom)
	If $cctype = "coltext"  Then
		ThemeChangeColor ("grub.title.png",        $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("digita.png",            $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("digitb.png",            $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("digitc.png",            $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("digitd.png",            $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("digitpoint.png",        $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.typeefi32.png",   $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.typeefi64.png",   $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.typebios32.png",  $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.typebios64.png",  $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.promptlines.png", $cccolor, $ccfromdir, $cctodir)
	Else
		ThemeChangeColor ("tick.png",             $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("image.clock.png",      $cccolor, $ccfromdir, $cctodir)
		ThemeChangeColor ("radian.png",           $cccolor, $ccfromdir, $themefaces)
		ThemeChangeColor ("snowflake.png",        $cccolor, $ccfromdir, $themefaces)
	EndIf
EndFunc

Func ThemeChangeColor ($ccfile, $ccoutcolor, $ccfromdir = $themecolorsource, $cctodir = $themecolorcustom)
	$ccbgr = StringMid ($ccoutcolor, 5, 2) & StringMid ($ccoutcolor, 3, 2) & StringLeft ($ccoutcolor, 2) & "FF"
	;MsgBox ($mbontop, "Colors", "BGR=" & $ccbgr & @CR &  "RGB=" & $ccoutcolor)
	_GDIPlus_Startup  ()
    $ccimage = _GDIPlus_ImageLoadFromFile ($ccfromdir & "\" & $ccfile)
	$ccimage = SpecFunc_ImageColorRegExpReplace   ($ccimage, "(0000FFFF)",   $ccbgr)
	_GDIPlus_ImageSaveToFile ($ccimage,    $cctodir   & "\" & $ccfile)
	_GDIPlus_ImageDispose ($ccimage)
	_GDIPlus_Shutdown     ()
EndFunc

Func ThemeGetContrast ($tgccolor)
	$tgcred        = Dec (StringLeft  ($tgccolor, 2))
	$tgcgreen      = Dec (StringMid   ($tgccolor, 3,2))
	$tgcblue       = Dec (StringRight ($tgccolor, 2))
	$tgcbrightness = Int (.299 * $tgcred + .587 * $tgcgreen + .114 * $tgcblue)
	If $tgcbrightness < 128 Then Return $mywhite
	;MsgBox ($mbontop, "RGB " & $tgcbrightness & " " & $tgccontrast, $tgccolor & @CR & $tgcred & @CR & $tgcgreen & @CR & $tgcblue)
	Return $myblack
EndFunc

Func ThemeResetColor ()
	ThemeCopyColor  ("coltext",  CommonThemeGetOption ("coltext"))
	ThemeCopyColor  ("colclock", CommonThemeGetOption ("colclock"))
EndFunc

Func ThemeRefreshHandles ()
	For $tshsub = 0 To Ubound ($themetempoptarray) - 1
		$tshvalue  = StringLower ($themetempoptarray [$tshsub] [1])
   	    $tshhandle = Eval ($tshvalue)
		If @error Then ContinueLoop
		;MsgBox ($mbontop, "Eval", $tshvalue & @CR & $tshhandle)
		$themetempoptarray [$tshsub] [4] = $tshhandle
		$thschecked = $GUI_UNCHECKED
		If $themetempoptarray [$tshsub] [3] = "yes" Then $thschecked = $GUI_CHECKED
        GUICtrlSetState ($tshhandle, $thschecked)
	    ;MsgBox ($mbontop, $tshvalue, $tshhandle)
	Next
	$trhstyle = CommonThemeGetOption ("style")
	GUICtrlSetData ($handlethemestyle, $trhstyle)
	GUICtrlSetData ($handlethemeface,  CommonThemeGetOption ("face"))
EndFunc

Func ThemeUpdateFiles ($tufoutfile = $themecustopt)
	;_ArrayDisplay ($themetempoptarray, Ubound ($themetempoptarray) - 1)
	ThemeWriteOptionsFile ($tufoutfile, $themetempoptarray, TimeLine ())
	$tufname = CommonThemeGetOption ("name")
	$tuflocal =  $themelocalpath & "\" & $tufname & ".txt"
	FileCopy ($themecustopt, $tuflocal, 1)
	ThemeBuildBackground ($themetempback & "\" & $tufname & ".jpg")
	If $tufname <> $notheme Then ThemeGenConfig ()
EndFunc

Func ThemeWriteOptionsFile ($wofoutfile, ByRef $wofarray, $wofstamp = "")
	$wofhandleopts = FileOpen ($wofoutfile, $FO_OVERWRITE)
	FileWriteLine ($wofhandleopts, _StringRepeat (" ", 34) & "Timestamp = " & $wofstamp & @CR & @CR)
	For $wofsub = 0 To Ubound ($wofarray) - 1
		$wofrecord  = BaseFuncPadRight ($wofarray [$wofsub] [0], 11)
		$wofrecord &= BaseFuncPadRight ($wofarray [$wofsub] [1], 23)
		$wofrecord &= BaseFuncPadRight ($wofarray [$wofsub] [2],  9) & " = "
		$wofrecord &=                $wofarray [$wofsub] [3]
		If $wofsub < Ubound ($wofarray) - 1 Then $wofrecord &= @CR
		FileWrite ($wofhandleopts, $wofrecord)
	Next
	FileClose ($wofhandleopts)
EndFunc

Func ThemeStarterSetup ()
	FileCopy ($thememasterpath  & "\background.png", $themepath & "\custom.background.png", 1)
	FileCopy ($thememasterpath  & "\options.txt",    $themepath & "\custom.options.txt",    1)
	If FileExists ($setupolddir & "\themes\custom.background.png") Then	FileCopy ($setupolddir & "\themes\custom.*", $themepath & "\", 1)
	$themetempoptarray = ThemeGetCurrent            ($themepath & "\custom.options.txt")
	If CommonParms ("AutoResDir") And FileExists ($setupvalueautoresdir & "\autores.default.jpg") Then
		FileCopy ($setupvalueautoresdir & "\*.*",  $themebackgrounds & "\", 1)
		FileCopy ($setupvalueautoresdir & "\*.*",  $userbackgrounds  & "\", 1)
		$ssresfile = ThemeAutoRes ($themetempoptarray)
		CommonWriteLog ("Automatic Resolution Set The Theme Background To " & $ssresfile)
	EndIf
	ThemeGenConfig ()
EndFunc

Func ThemeAutoRes (ByRef $ararray)
	$arresfile = "autores." & $graphsize
	If Not FileExists ($themetempback & "\" & $arresfile & ".jpg") Then $arresfile = "autores.default"
	CommonThemePutOption  ("name", $arresfile, $ararray)
	ThemeWriteOptionsFile ($themecustopt, $ararray)
	Return $arresfile
EndFunc

Func ThemeAddImages ()
	$aicount = ""
	$aimsg   = ""
	$aiarray = CommonFileDialog ("Select image files for the theme background", $dialogpathhold, "Image Files (*.jpg)", 5, "",  $handlethemegui)
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
			$aifiletowork = $themetempback   & "\" & $ainamefixed
			If FileExists ($themebackgrounds & "\" & $ainamefixed) Then ContinueLoop
			FileCopy ($aifilefrom, $aifiletouser, 1)
			FileCopy ($aifilefrom, $aifiletowork, 1)
			$aicount += 1
		Next
	EndIf
	If $aicount <> 0 Then
		MsgBox ($mbontop, "", BaseFuncCapIt (BaseFuncSing ($aicount, $aimsg) & @CR & @CR & _
			BaseFuncSing ($aicount, $aicount & " image files were added to the " & $userbackgrounds & " directory")))
		BaseFuncGuiDelete    ($themeselecthandlegui)
	EndIf
	ThemeSelectRunGUI (CommonThemeGetOption ("name"))
EndFunc

Func ThemeDelImage ($disub)
	;_ArrayDisplay ($themeselectarray, $disub)
	$diname = $themeselectarray [$disub] [$sBackName]
	$dirc = MsgBox ($mbquestyesno, "", "Are you sure you want to" & @CR & "delete this background image?" & @CR & @CR & $diname)
	If $dirc <> $IDYES Then Return "NoDelete"
	FileDelete ($userbackgrounds  & "\" & $diname & ".jpg")
	FileDelete ($themetempback    & "\" & $diname & ".jpg")
	FileDelete ($themelocalpath   & "\" & $diname & ".txt")
	BaseFuncGuiCtrlDelete ($themeselectarray [$disub] [$sBackRemove])
	BaseFuncGuiCtrlDelete ($themeselectarray [$disub] [$sBackImage])
	GUICtrlSetData     ($themeselectarray [$disub] [$sBackSelect], "*** Removed Image ***" & @CR & $diname)
	GUICtrlSetState    ($themeselectarray [$disub] [$sBackSelect], $guishowdis)
	GUICtrlSetState    ($themeselectarray [$disub] [$sBackBorder], $guishowdis)
EndFunc

Func ThemeGenConfig ()
	Dim $tgc64biosarray [1]
	Dim $tgc64efiarray  [1]
	Dim $tgc32biosarray [1]
	Dim $tgc32efiarray  [1]
	$tgcmenutop    = Int ($themecenterstart * 8) + 5
	$tgcmenuheight = Int ($themecentersize  * 6.9)
	If CommonThemeGetOption ("style") = "progress bar" and $tgcmenutop + $tgcmenuheight > 90 Then $tgcmenuheight = 90 - $tgcmenutop
	If $tgcmenutop + $tgcmenuheight > 100 Then $tgcmenuheight = 100 - $tgcmenutop
	$tgchandle     = FileOpen ($themetemplate)
	While 1
		$tgcrecord = FileReadLine ($tgchandle)
		If @error Then ExitLoop
		If StringInStr ($tgcrecord, "*menusizestring*") Then
		    If $tgcmenuheight = 0 Then $tgcmenuheight = 82
			$tgcrecord = "   top  = " & $tgcmenutop & "%   height = " & $tgcmenuheight & "%"
		EndIf
		$tgcincloc = StringInStr ($tgcrecord, "##g2w-include")
		If $tgcincloc <> 0 Then
			$tgcparse = StringStripWs (StringTrimLeft ($tgcrecord, $tgcincloc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			$tgcrecvalue = StringLeft ($tgcsplit [2], 4)
			If @error Then ContinueLoop
			$tgcoptvalue = StringLeft (CommonThemeGetOption ($tgcsplit [1], "lower"), 4)
			If $tgcrecvalue <> $tgcoptvalue Then ContinueLoop
			;_ArrayDisplay ($tgcsplit, $tgcparse & " " & $tgccompare)
		EndIf
		$tgcreploc = StringInStr ($tgcrecord, "##g2w-replace")
		If $tgcreploc <> 0 Then
			$tgcparse = StringStripWs (StringTrimLeft ($tgcrecord, $tgcreploc + 12), 7)
			$tgcsplit = StringSplit ($tgcparse, " ")
			If @error Then ContinueLoop
			$tgcrep = CommonThemeGetOption ($tgcsplit [1], "lower")
			$tgcrecord = StringReplace ($tgcrecord, $tgcsplit [2], $tgcrep)
			;_ArrayDisplay ($tgcsplit, $tgcparse)
		EndIf
		$tgcparmloc = StringInStr ($tgcrecord, "##g2w")
		If $tgcparmloc <> 0 Then $tgcrecord  = StringLeft  ($tgcrecord, $tgcparmloc - 1)
		If StringInStr ($tgcrecord, "*clockfacestring*") Then
			$tgcface = CommonThemeGetOption ("face")
			If $tgcface = $noface Then ContinueLoop
			$tgcfacestring = '"common/clockfaces/' & $tgcface & '.png"'
			If Not FileExists ($themefaces & "\" & $tgcface & ".png") Or $tgcface = $ticksonly _
				Then $tgcfacestring = '"common/static/image.empty.png"'
			$tgcfacestring &= '   tick_bitmap = "common/colorcustom/tick.png"'
			$tgcrecord      = '   center_bitmap   = ' & $tgcfacestring
		EndIf
		$tgcoutefi  = StringStripWS ($tgcrecord, 2)
		$tgcoutbios = $tgcoutefi
		If StringInStr ($tgcrecord, "*bootmodestring*") Then
			_ArrayAdd ($tgc64efiarray,  '      left   = 87% + image { file = "common/colorcustom/image.typeefi64.png"  }')
			_ArrayAdd ($tgc64biosarray, '      left   = 85% + image { file = "common/colorcustom/image.typebios64.png" }')
			_ArrayAdd ($tgc32efiarray,  '      left   = 87% + image { file = "common/colorcustom/image.typeefi32.png"  }')
			_ArrayAdd ($tgc32biosarray, '      left   = 85% + image { file = "common/colorcustom/image.typebios32.png" }')
			ContinueLoop
		EndIf
		_ArrayAdd ($tgc64efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc64biosarray, $tgcoutbios)
		_ArrayAdd ($tgc32efiarray,  $tgcoutefi)
		_ArrayAdd ($tgc32biosarray, $tgcoutbios)
	Wend
	;_ArrayDisplay ($tgcefiarray)
	FileDelete       ($themeconfig & "*")
	BaseFuncArrayWrite ($themeconfig & ".64.bios.txt", $tgc64biosarray)
	BaseFuncArrayWrite ($themeconfig & ".64.efi.txt",  $tgc64efiarray)
	BaseFuncArrayWrite ($themeconfig & ".32.bios.txt", $tgc32biosarray)
	BaseFuncArrayWrite ($themeconfig & ".32.efi.txt",  $tgc32efiarray)
EndFunc

Func ThemeMainScreenShot ()
	ThemeBuildScreenShot      ()
	BaseFuncGuiCtrlDelete ($screenpicturehandle)
	BaseFuncGuiCtrlDelete ($screenshothandle)
	BaseFuncGuiCtrlDelete ($screenpreviewhandle)
    $sstheme = BaseFuncCapIt (CommonThemeGetOption ("name"))
	$sstext = 'Preview of theme  "' & $sstheme & '"  -  Click to customize'
	If $sstheme = $notheme Then $sstext = $nothemedesc
	$screenshothandle    = CommonScaleCreate ("Label",   "",              44,  1, 55, 52)
	$screenpicturehandle = CommonScaleCreate ("Picture", $screenshotfile, 44,  1, 55, 52)
	$screenpreviewhandle = CommonScaleCreate ("Label",   $sstext,         44, 53, 55,  9, $SS_CENTER)
	GUICtrlSetState ($screenshothandle, $guishowit)
EndFunc

Func ThemeSelectRunGUI ($rgname)
	ThemeSelectSetup   ($rgname)
	ThemeSelectRefresh ($themeselectcurrsub)
	GUISetState (@SW_HIDE, $handlethemegui)
	GUISetState (@SW_SHOW, $themeselecthandlescroll)
	GUISetState (@SW_SHOW, $themeselecthandlegui)
	While 1
		$rgstatusarray = GUIGetMsg(1)
		If $rgstatusarray[1] <> $themeselecthandlescroll and $rgstatusarray [1] <> $themeselecthandlegui Then ContinueLoop
		$rgstatus = $rgstatusarray [0]
		Select
			Case $rgstatus = "" Or $rgstatus = 0
			Case $rgstatus = $themeselecthandleadd
				ThemeAddImages ()
				ExitLoop
			Case $rgstatus = $themeselecthandledone
				ExitLoop
			Case Else
				For $rgselectsub = 0 To Ubound ($themeselectarray) - 1
					If $rgstatus = $themeselectarray [$rgselectsub] [$sBackRemove] Then
						If ThemeDelImage   ($rgselectsub) Then ContinueLoop
						;ThemeSelectRefresh ($themeselectcurrsub)
						ContinueLoop
					EndIf
					If $rgstatus = $themeselectarray [$rgselectsub] [$sBackBorder] Or $rgstatus = $themeselectarray [$rgselectsub] [$sBackSelect] Then
						ThemeSelectRefresh ($rgselectsub)
						ContinueLoop
					EndIf
				Next
		EndSelect
	WEnd
	GUISetState (@SW_HIDE, $themeselecthandlescroll)
	GUISetState (@SW_HIDE, $themeselecthandlegui)
	GUISetState (@SW_SHOW, $handlethemegui)
	Return $themeselectarray [$themeselectcurrsub] [$sBackName]
EndFunc

Func ThemeSelectSetup ($sscurrname)
	CommonCopyUserFiles ("yes")
	If $themeselecthandlegui <> "" Then Return
	$themeselecthandlegui    = CommonScaleCreate ("GUI",    "Click on the background you want to use",  -1, -1, 110.5, 101.5, $WS_EX_STATICEDGE, "", $handlethemegui)
	$themeselecthandleadd    = CommonScaleCreate ("Button", "Add Images",                               23, 92,  12,     3)
	$themeselecthandledone   = CommonScaleCreate ("Button", "OK Done",                                  78, 92,  13,     3)
	$themeselecthandlescroll = CommonScaleCreate ("GUI",    "",                                          0,  3, 110,    86,   $WS_CHILD, "", $themeselecthandlegui)
	GUICtrlSetBkColor ($themeselecthandleadd,  $mygreen)
	GUICtrlSetBkColor ($themeselecthandledone, $mygreen)
	$ssvert      = 3
	$sshor       = 9
	$ssautofound = ""
	Dim $themeselectarray [0] [5]
	$sshandledesc = ""
	_ArrayAdd ($themeselectarray, "||notheme")
	_ArrayAdd ($themeselectarray, "||basic")
	$sshandle = FileFindFirstFile ($themetempback & "\*.jpg")
	While 1
		$ssname = FileFindNextFile ($sshandle)
		If @error Then ExitLoop
		$ssname = StringLower ($ssname)
		If $ssname = "Notheme.jpg" Or $ssname = "Common.jpg" Then ContinueLoop
		Select
			Case StringLeft  ($ssname, 7) <> "autores"
			Case StringInStr ($ssname,       "default")
				If $ssautofound = "yes" Then ContinueLoop
			Case Not StringInStr ($ssname, $graphsize)
				ContinueLoop
			Case Else
				$ssautofound = "yes"
		EndSelect
		_ArrayAdd ($themeselectarray, "||" & StringTrimRight ($ssname, 4))
	WEnd
	FileClose ($sshandle)
	If Ubound ($themeselectarray) > 12 Then CommonFlashStart ("Loading The Background Images", "This May Take A Few Seconds", 0)
	GUISwitch ($themeselecthandlescroll)
	For $sssub  = 0 To Ubound ($themeselectarray) -1
		$ssfile = $themeselectarray [$sssub] [$sBackName]
		If $ssfile = $sscurrname Then $themeselectcurrsub = $sssub
		$sshandlebutton = CommonBorderCreate _
			($themetempback & "\" & $ssfile & ".jpg", $sshor - 1, $ssvert - 1.5, 41, 28, $sshandledesc, $ssfile, 1)
		$themeselectarray [$sssub] [$sBackImage] = $borderpichandle
		If Not FileExists ($themebackgrounds & "\" & $ssfile & ".jpg") Then
			$sshandledel = CommonScaleCreate ("Button", "Remove", $sshor - 7, $ssvert + 12, 6, 3)
			GUICtrlSetFont    ($sshandledel, $fontsizesmall)
			$themeselectarray [$sssub] [$sBackRemove] = $sshandledel
		EndIf
		$themeselectarray [$sssub] [$sBackBorder] = $sshandlebutton
		$themeselectarray [$sssub] [$sBackSelect] = $sshandledesc
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
	CommonScrollGenerate ($themeselecthandlescroll, $scalehsize, ($ssvert) * $scalepctvert)
	CommonFlashEnd ("")
EndFunc

Func ThemeSelectRefresh ($irselection)
	; _ArrayDisplay ($themeselectarray, $themeselectcurrsub)
	Local $irhandlemove
	$themeselectcurrsub = $irselection
	For $irsub = 0 To Ubound ($themeselectarray) - 1
		$irhandlebutton = $themeselectarray [$irsub] [$sBackBorder]
		$irhandledesc   = $themeselectarray [$irsub] [$sBackSelect]
		$irdesc         = $themeselectarray [$irsub] [$sBackName]
		$irhandledelete = $themeselectarray [$irsub] [$sBackRemove]
		If $irsub = $irselection Then
			GUICtrlSetBKColor ($irhandlebutton, $myred)
			If $irhandledelete <> "" Then GUICtrlSetState ($irhandledelete, $guihideit)
			$irhandlemove = $irhandledesc
		Else
			If $irhandledelete <> "" Then GUICtrlSetState ($irhandledelete, $guishowit)
			GUICtrlSetBKColor ($irhandlebutton, $mylightgray)
		EndIf
	Next
    CommonScrollCenter ($themeselecthandlegui, $themeselecthandlescroll, $irhandlemove, $themeselectarray)
EndFunc

Func ThemeCreateHold ()
	$themeoptarray     = ThemeGetCurrent ()
	$themetempoptarray = $themeoptarray
	DirRemove ($themetemp, 1)
	DirCreate ($themetemp)
	DirCreate ($themetempfiles)
	FileCopy  ($themepath & "\custom.*", $themetempfiles, 1)
	DirCopy   ($themecolorcustom,        $themetempcust, 1)
	DirCopy   ($themelocalpath,          $themetemplocal, 1)
EndFunc

Func ThemeRestoreHold ()
	FileCopy  ($themetempfiles & "\custom.*", $themepath, 1)
	DirCopy   ($themetempcust,                $themecolorcustom, 1)
	DirCopy   ($themetemplocal,               $themelocalpath , 1)
	DirRemove ($themetemp, 1)
	$themetempoptarray = $themeoptarray
EndFunc