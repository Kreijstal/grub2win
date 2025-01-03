#include-once
#include <g2basefunc.au3>

Const  $langendarray        = Ubound        ($langarray) - 1
Const  $langsyssubculture   = StringReplace (@OSLang,  "0000", "")
Const  $langxpdesc          = _WinAPI_GetLocaleInfo ($LOCALE_SYSTEM_DEFAULT, $LOCALE_SLANGUAGE)
Const  $langsysentry        = LangGetEntry  ($langsyssubculture)
Const  $langsysdesc         = LangGetDesc   ($langsysentry,  $LOCALE_CUSTOM_DEFAULT)
Const  $langengsysdesc      = $langarray    [$langsysentry] [$sLangName]
Const  $langusersubculture  = StringReplace (@MUILang, "0000", "")
Const  $languserentry       = LangGetEntry  ($langusersubculture)
Const  $languserdesc        = LangGetDesc   ($languserentry, $LOCALE_SYSTEM_DEFAULT, "yes")
Const  $langenguserdesc     = $langarray    [$languserentry] [$sLangName]
Const  $langcode            = $langarray    [$languserentry] [$sLangCode]
Global $langdiagsubculture  = $langusersubculture

; MsgBox ($mbontop, "Lang", @OSLang & @CR & @MUILang & @CR & $langsysentry & @CR & $languserentry & @CR _
;	& $langsyssubculture & @CR & $langsysdesc & @CR & $langusersubculture & @CR & $languserdesc  & @CR & $langcode)

If StringInStr (@ScriptName, "g2language") Then LangDiagnostic ()

Func LangSetup ()
	$lsuserdesc = LangStrip ($languserdesc)
	$lssysdesc  = LangStrip ($langsysdesc)
	If $langfound = "yes" Then
		If $langdiagsubculture = "" Then $langdiagsubculture =        $langarray [$languserentry] [$sLangSubculture]
		If $langdiagsubculture = "" Then $langdiagsubculture = "**" & $langarray [$languserentry] [$sLangCulture]
		If $langusersubculture = "" Then $langdiagsubculture = ""
	EndIf
	$langheader  = $languserdesc & "   " & $langdiagsubculture
	If $lsuserdesc <> $lssysdesc  Then
		$langheader  = $lsuserdesc & "   " &                 $langdiagsubculture
		$langheader &=" -- Win Lang=" & $lssysdesc & "   " & $langsyssubculture
	EndIf
	$langline1        =       "The Windows system language is " &  $langsysdesc  & "   " & $langsyssubculture
	If $langengsysdesc  <> $lssysdesc  And $langengsysdesc <> ""   Then _
		$langline2    =       "The system  language description is " & $langengsysdesc
	If $lsuserdesc <> $lssysdesc Then _
		$langline3    =       "The current user   language is "  &  $languserdesc & "   " & $langdiagsubculture
	$langline3        =       StringStripWS ($langline3, 3)
	If $langenguserdesc <> $lsuserdesc And $langfound = "yes" Then _
		$langline4    =       "The user    language description is " & $langenguserdesc
	LangComboInit     ()
	$langfullselector = LangGetFullSelector ($langcode)
EndFunc

Func LangWarn ()
	$lsmessage  = @CR & @CR & @CR
	$lsmessage &= 'Your currently selected language is not supported by GNU Grub.'  & @CR & @CR & @CR
	$lsmessage &= 'Grub2Win will start with the default language - English.'        & @CR & @CR & @CR
	$lsmessage &= 'You can then continue to use English, or change to one'          & @CR
	$lsmessage &= 'of the 32 supported languages.'                                  & @CR & @CR & @CR
	$lsmessage &= 'Simply click OK to open the Grub2Win main configuration'         & @CR
	$lsmessage &= 'screen. Then choose your favorite language.'                     & @CR & @CR & @CR
	MsgBox ($mbinfook, "Selected Language = " & $langheader, $lsmessage)
EndFunc

Func LangDiagnostic ()
	LangSetup  ()
	$ldmsg  = "L="          & $langheader &                                @CR & @CR
	$ldmsg &= "System = "   & $langsyssubculture  & "  " & $langsysdesc  & @CR & @CR
	$ldmsg &= "User     = " & $langdiagsubculture & "  " & $languserdesc & @CR & @CR
	$ldmsg &= $langline1 & @CR & $langline2 & @CR & $langline3 & @CR & $langline4
	If $langfound     = "no" Then $ldmsg &= "  ** Unsupported **"
	Msgbox ($mbinfook, "Language" & " Code = " & $langcode & "    " & _
		$langarray [$languserentry] [$sLangNative], $ldmsg)
EndFunc

Func LangGetFullSelector ($gfscode)
	$gfsfullselector = $langenglish
	$gfssearch       = _ArraySearch ($langarray, $gfscode, 0, 0, 0, 0, 0, $sLangCode)
	If @error Then Return
	$gfsfullselector = $langarray  [$gfssearch] [$sLangName] & $langspacer & $langarray [$gfssearch] [$sLangNative]
	If $gfscode = $langdefcode Then $gfsfullselector = $langenglish
	Return $gfsfullselector
EndFunc

Func LangStrip ($lsdesc)
	$lsbetween = _StringBetween ($lsdesc, "(", ")")
	If Not @error Then $lsdesc = StringReplace ($lsdesc, "(" & $lsbetween [0] & ")", "")
	$lsdesc = StringStripWS ($lsdesc, 7)
    Return $lsdesc
EndFunc

Func LangComboInit ()
	Dim $langcomboarray [$langendarray] [5]
	For $lcsub = 0 To $langendarray - 1
		$langcomboarray [$lcsub] [0] = $langarray [$lcsub] [$sLangName] & $langspacer & _
			 $langarray [$lcsub] [$sLangNative]
		If $langarray [$lcsub] [$sLangName] = $langenglish Then $langcomboarray [$lcsub] [0] = $langenglish
		$langcomboarray [$lcsub] [1] = $langarray [$lcsub] [$sLangCode]
		$langcombo &= $langcomboarray[$lcsub][0] & "|"
	Next
	$langcombo = StringTrimRight ($langcombo, 1)
	If $langfound = "no" Then Return
	$langautostring = $autostring     & "   " & $langcomboarray [$languserentry] [0]
	$langcombo      = $langautostring & "|"   & $langcombo
EndFunc

Func LangGetEntry ($gesearch)
	$geloc     = -1
	If $gesearch = "" Then
		$geloc     = _ArraySearch ($langarray, $langxpdesc, 0, 0, 0, 0, 0, $sLangName)
	Else
		$geculture = StringRight ($gesearch, 2)
		$geloc     =            _ArraySearch ($langarray, $gesearch,  0, 0, 0, 0, 0, $sLangSubculture)
		If @error Then $geloc = _ArraySearch ($langarray, $geculture, 0, 0, 0, 0, 0, $sLangCulture)
	EndIf
	$langfound = "yes"
    If $geloc >= 0 Then Return $geloc
	$geloc     = $langendarray
	$langfound = "no"
	Return $geloc
EndFunc

Func LangGetDesc   ($gdentry, $gdtype, $gduser = "")
	$gdtext       = _WinAPI_GetLocaleInfo ($gdtype, $LOCALE_SLANGUAGE)
	$gdnative     = $langarray [$gdentry] [$sLangNative]
	If $gduser    = "yes" And $languserentry = $langsysentry Then $gdtext = $langsysdesc
	If $bootos    = $xpstring Then $gdtext = $langxpdesc
	$gdstripped   = LangStrip ($gdnative)
	If $langfound = "yes" And $gdtext <> $gdstripped Then $gdtext = $gdnative
	Return $gdtext
EndFunc