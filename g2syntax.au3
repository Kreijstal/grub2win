#include-once
#include <g2common.au3>

Const $sOpenChar  = 0, $sOpenDesc   = 1
Const $sCloseChar = 2, $sCloseDesc  = 3
Const $sEvalType  = 4

Const $sOpenCount = 0, $sCloseCount = 1
Const $sErrorMsg  = 2, $sErrorStart = 3
Const $sErrorEnd  = 4, $sLastFound  = 5

Const $sScanTypes     = 6
Const $sSyntaxFields  = 5
Const $sWorkFields    = 6

Const $synlimit       = 10000

Const $sSrcCaller     = 0, $sSrcLine = 1, $sSrcCode = 2, $sSrcLimit = 3

Const $synquotes     = "'",                    $synquoted    = '"'
Const $synlitquotes  = '"' & $synquotes & '"', $synlitquoted = "'" & $synquoted & "'"
Const $synreportfile = $storagepath & "\syntax.report.txt"

Global $syninputarray, $synerrorcount, $synerrorarray, $synnotepadpid, $synguihandle, $synsourcemissing
Global $synmaxlevel, $syncharactercount, $syncurrfilename, $syncurrfileline, $syncurrfileedit
Global $synopenfile = $configfile

Dim $synvaluearray [$sScanTypes] [$sSyntaxFields]
Dim $synworkarray  [$sScanTypes] [$sWorkFields]

$synvaluearray [0] [$sOpenChar]  = $synquotes
$synvaluearray [0] [$sOpenDesc]  = "Unmatched Single Quote"
$synvaluearray [0] [$sEvalType]  = "Line"
$synvaluearray [1] [$sOpenChar]  = $synquoted
$synvaluearray [1] [$sOpenDesc]  = 'Unmatched Double Quotes'
$synvaluearray [1] [$sEvalType]  = "Line"
$synvaluearray [2] [$sOpenChar]  = "["
$synvaluearray [2] [$sOpenDesc]  = "Unmatched Left Brace - ["
$synvaluearray [2] [$sCloseChar] = "]"
$synvaluearray [2] [$sCloseDesc] = "Unmatched Right Brace - ]"
$synvaluearray [2] [$sEvalType]  = "Line"
$synvaluearray [3] [$sOpenChar]  = "("
$synvaluearray [3] [$sOpenDesc]  = "Unmatched Left Parenthesis - ("
$synvaluearray [3] [$sCloseChar] = ")"
$synvaluearray [3] [$sCloseDesc] = "Unmatched Right Parenthesis - )"
$synvaluearray [3] [$sEvalType]  = "Line"
$synvaluearray [4] [$sOpenChar]  = "{"
$synvaluearray [4] [$sOpenDesc]  = "Unmatched Left Curly Bracket - {"
$synvaluearray [4] [$sCloseChar] = "}"
$synvaluearray [4] [$sCloseDesc] = "Unmatched Right Curly Bracket - }"
$synvaluearray [4] [$sEvalType]  = "Block"
$synvaluearray [5] [$sOpenChar]  = " if "
$synvaluearray [5] [$sOpenDesc]  = 'Extra Opening  "if"  Clause'
$synvaluearray [5] [$sCloseChar] = " fi "
$synvaluearray [5] [$sCloseDesc] = 'Extra Closing  "fi"  Clause'
$synvaluearray [5] [$sEvalType]  = "Block"

Func SynMain ($smfilein, $smmenuitem = "")
	$smtarget  = "File " & $smfilein
	If $smmenuitem <> "" Then $smtarget = "The Custom Code For Menu Item " & $smmenuitem
	While 1
		$smreturn = SynCheck ($smfilein, $smtarget, $smmenuitem)
		BaseFuncGuiDelete ($synguihandle)
		If $smreturn = "NoErrors" Or $smreturn = "Empty" Or $smreturn = "Cancelled" Or $smreturn = "Accepted" Then ExitLoop
	Wend
	If $smreturn = "Cancelled" Then
		If $smmenuitem <> "" Or                                                _
				(FileGetTime ($smfilein,       $FT_MODIFIED, $FT_STRING) >     _
			 	 FileGetTime ($syntaxorigfile, $FT_MODIFIED, $FT_STRING)) Then
			MsgBox   ($mbinfook, "The changes have been cancelled","", 3)
			FileCopy ($syntaxorigfile, $smfilein, 1)
		EndIf
	EndIf
	If $smreturn = "NoErrors" Then
		$smgood  = @CR & @CR & @TAB & "No Syntax Errors Were Found In"
		$smgood &= @CR & @TAB & $smtarget
		$smgood &= @CR & @CR & @TAB & SynFormatLines ()
	    $smgood &= @CR & @CR & @TAB & "The Maximum Nesting Level Was " & $synmaxlevel
		$smgood &= @CR & @CR & @TAB & "The Time Is " & TimeLine ("", "", "yes")
		$smgood &= @CR & @CR & @CR & @CR & @TAB & $synsourcemissing
		_ArrayAdd ($synerrorarray, $smgood)
		MsgBox ($mbinfook, "Syntax Check Succeeded", $smgood, 200)
	EndIf
	_ArrayAdd ($synerrorarray, @CR & @TAB & "Status is - " & $smreturn)
	BaseFuncArrayWrite ($synreportfile, $synerrorarray)
	Return $smreturn
EndFunc

Func SynCheck ($scfilein, $sstarget, $scmenuitem)
	$synerrorcount     = 0
	$syncharactercount = 0
	$synmaxlevel       = 0
	Dim $synerrorarray [1]
	$syninputarray = SynBuildInput ($scfilein)
	For $scsub = 1 To Ubound ($syninputarray) - 1
		$screcord = SynMerge ($scsub)
		If StringLeft  ($screcord, 16) = "## SyntaxSource " Then
			$syncurrfileline    = $scsub
			$syncurrfilename    = StringTrimLeft ($screcord, 16)
		EndIf
	    If StringLeft  ($screcord, 13) = "# Menu Entry " Or StringLeft ($screcord, 9) = "function " Or _
			(StringInStr ($screcord, "end-") And StringInStr ($screcord, "-section")) Then SynEndBlock ($scsub - 1)
		$screcord = SynStrip ($screcord)
		If $screcord  = "" Then ContinueLoop
		If StringInStr ($screcord, "menuentry") Then
			If StringInStr ($screcord, '"') Then          _
				MsgBox ($mbwarnok, "** Grub2Win Syntax Warning **", $screcord & @CR & @CR & @CR &  _
				'Do not use double quotes  "   within menuentry statements.'  & @CR &              _
				"Use single quotes                 '   instead."              & @CR & @CR & @CR &  _
				"File " & $scfilein & "        Line " & $scsub)
			If $selectionarray [$scmenuitem] [$sOsType] = $modecustom Then
				FileDelete ($scfilein)
				$scmenumsg =  "Custom code must not contain Menuentry statements." & @CR & @CR
				$scmenumsg &= "You may want to put this code in the User Section." & @CR & @CR & @CR & @CR
				$scmenumsg &= "     The error is in code line " & $scsub           & @CR & @CR & $screcord
				Msgbox ($mbwarnok, "** Warning **", $scmenumsg)
				Return "Cancelled"
			EndIf
		EndIf
		$syncharactercount += StringLen ($screcord)
		SynCheckLine   ($screcord, $scsub)
		If $selectionarray [$scmenuitem] [$sOSType] = "isoboot" Then SynCheckISO ($screcord)
	Next
	Return SynShowErrors ($sstarget)
EndFunc

Func SynBuildInput ($bicurrfile)
	$bimainarray = BaseFuncArrayRead ($bicurrfile, "SysBuildInput A", "", "", "", "yes")
	_ArrayInsert ($bimainarray, 0, "")
	$bisubend         = Ubound ($bimainarray)
	ReDim $bimainarray [$bisubend]
	;_ArrayDisplay ($bimainarray, "Main Before " & $bicurrfile)
	$bisub            = 0
	$syncurrfileline  = 0
	$bitracksub       = 0
	$biloopcount      = 0
	Dim $bitrackarray [1] [4]
    $bitrackarray     [0] [$sSrcCaller] = $bicurrfile
   	$bitrackarray     [0] [$sSrcLimit]  = Ubound ($bimainarray) - 1
	$synsourcemissing = ""
	$syncurrfilename  = $bicurrfile
	$syncurrfileedit  = ""
	While 1
		;If $bisub + 1   > Ubound ($bimainarray - 1)  Then ExitLoop
		$birec          = $bimainarray [$bisub]
		$bisub         += 1
		$bitracklimit   = $bitrackarray [$bitracksub] [$sSrcLimit]
		$bitrackline    = $bitrackarray [$bitracksub] [$sSrcLine]
		If $bitracksub > 0 And $bitrackline > 0 And $bitrackline = $bitracklimit Then
			_ArrayDelete ($bitrackarray, $bitracksub)
			$bitracksub = Ubound ($bitrackarray) - 1
			;MsgBox ($mbontop, "Sub", $bitracksub & @CR & $bitrackline & @CR & $bitracklimit)
		EndIf
		If CommonPrevParse ($birec, "source") And Not StringInStr ($birec, "gnugrub.functions.cfg") Then
			$bipath        = CommonPathToWin   ($parseresult1)
			$bipath        = StringReplace     ($bipath, "($root)\grub2\", $masterpath & "\")
			$bisourcearray = BaseFuncArrayRead ($bipath, "SysBuildInput B", "no", "yes", "yes")
			$bicodesub     = Ubound ($bitrackarray ) - 1
			$bitrackarray  [$bicodesub] [$sSrcCode] = $birec
			$biloc = _ArraySearch ($bitrackarray, $bipath)
			If $biloc > - 1 Then $biloopcount += 1
			If $bisubend > $synlimit Or $biloopcount > 3 Then
				$bierrmsg1 = "Loop Detected **"
				If $bisubend > $synlimit Then $bierrmsg1 = " Scan Limit Of " & $synlimit & " Lines Exceeded - Check For Loops **"
				$bierrmsg2 = ""
				If $bicodesub > 0 Then $bierrmsg2 = @CR & @CR & "File = " & $bitrackarray [$bicodesub] [$sSrcCaller] & @CR & @CR &  _
					"Line = " & $bitrackarray [$bicodesub] [$sSrcLine] & @CR & @CR & "Code = " & $bitrackarray [$bicodesub] [$sSrcCode]
				MsgBox ($mbontop, "** Syntax Scan Count = " & $bisubend & " **", "** Error - " & $bierrmsg1 & @CR & $bierrmsg2)
				CommonWriteLog (@CR & "** Syntax Scan Error - " & $bierrmsg1 & $bierrmsg2)
				_ArrayDisplay ($bitrackarray, "Source Loop Trace")
				Dim $bimainarray [0]
				Return
			EndIf
			If IsArray ($bisourcearray) Then
				_ArrayInsert ($bisourcearray, 0, "## SyntaxSource " & $bipath)
				;_ArrayDisplay ($bitrackarray, $bipath)
				;If _ArraySearch ($bitrackarray, $bipath) > 0 Then MsgBox ($mbontop, "Loop", $bipath)
				;_ArrayDisplay ($bisourcearray, "Target " & $bipath)
				$bisubend   = SynInsertSource ($bisub, $bimainarray, $bisourcearray)
				_ArrayAdd    ($bitrackarray, $bipath & "|0||" & Ubound ($bisourcearray) - 1)
				$bitracksub = Ubound ($bitrackarray) - 1
			Else
				$bicaller      = $bitrackarray [$bitracksub] [$sSrcCaller]
				$bicallingline = $bitrackarray [$bitracksub] [$sSrcLine]
                $synsourcemissing &= @CR & @CR & _StringRepeat ("*", 64) & @CR & @CR
				$synsourcemissing &=             "*** Warning - Missing Target File Was Not Checked For Syntax" & @CR
				$synsourcemissing &=       @CR & "*** Calling File" & @CR & $bicaller  & "       Line " & $bicallingline & @CR & @CR
				$synsourcemissing &=             "*** Target File " & @CR & $bipath
				$synsourcemissing &= @CR & @CR & _StringRepeat ("*", 64) & @CR & @CR
				;_ArrayDisplay ($bitrackarray, "Error " & $bitracksub)
				$bitrackarray [$bitracksub] [$sSrcLine] += 1
			EndIf
			;_ArrayDisplay ($bitrackarray, "After")
		Else
			$bitrackarray [$bitracksub] [$sSrcLine] += 1
		EndIf
		;If $bisub > Ubound ($bimainarray) - 1 Then MsgBox ($mbontop, "Sub", $bisub & @CR & Ubound ($bimainarray) - 1)
		If $bisub + 1 > Ubound ($bimainarray - 1) Then ExitLoop
		$bimainarray [$bisub] = StringReplace (StringStripWS ($bimainarray [$bisub], 1), " \" & @CR, " ")
	Wend
    ReDim $bimainarray [$bisubend]
	;_ArrayDisplay ($bimainarray, "After")
	Return $bimainarray
EndFunc

Func SynInsertSource ($ismainsub, ByRef $ismainarray, ByRef $issourcearray)
	$istemparray = $ismainarray
	$istempsub   = $ismainsub
	$issourcelimit = Ubound ($issourcearray) - 1
	$istemplimit   = Ubound ($istemparray) - $istempsub
	ReDim $ismainarray [$ismainsub + $issourcelimit + $istemplimit + 1]
	For $issourcesub = 0 To $issourcelimit
		$ismainarray [$ismainsub] = $issourcearray [$issourcesub]
		$ismainsub += 1
	Next
	For $isworksub = $istempsub To Ubound ($istemparray) - 1
		$ismainarray [$ismainsub] = $istemparray [$isworksub]
		$ismainsub += 1
		;_ArrayAdd ($ismainarray, $istemparray [$ismainsub])
	Next
	$isendsub = Ubound ($ismainarray)
	;_ArrayDisplay ($ismainarray,   "Main " & $ismainsub & " " & $isendsub)
	Return $isendsub
EndFunc

Func SynMerge ($smstartsub)
	$smcheck    = $syninputarray [$smstartsub]
	$smbuild    = SynFindBackslash ($smcheck)
	$smextended = @extended
	If $smextended = 0 Or $smextended = 999 Then Return $smcheck
	For $smsub = $smstartsub + 1 To Ubound ($syninputarray) - 1
		$smrecord   = SynFindBackslash ($syninputarray [$smsub])
	    $smextended = @extended
	    If $smextended = 0   Then ContinueLoop
		$smbuild &= " " & $smrecord
		$syninputarray [$smstartsub] = $smbuild
		If $smsub <> $smstartsub Then $syninputarray [$smsub] = ""
		If $smextended = 999 Then ExitLoop
	Next
	;_ArrayDisplay ($syninputarray, $smsub)
	Return $smbuild
EndFunc

Func SynFindBackslash ($fbrecord)
	$fbstripped    = StringStripWS ($fbrecord, 7)
	If $fbstripped = "" Or StringLeft ($fbstripped, 1) = "#" Then Return $fbstripped
	$fbreplaced = StringReplace ($fbstripped, " \", "")
	$fbextended = @extended
	If $fbextended = 0 Then $fbextended = 999
	SetExtended ($fbextended)
	Return $fbreplaced
EndFunc

Func SynCheckLine ($sclrecord, $sclnumber)
	$sclrecord = StringReplace ($sclrecord, ";", " ")
	$sclrecord = BaseFuncPadRight ("Line " & $sclnumber, 10) & $sclrecord
	For $sclsub = 0 To Ubound ($synvaluearray) - 1
		$sclopenchar = $synvaluearray [$sclsub] [$sOpenChar]
		If $sclopenchar = "" Then ContinueLoop
		StringReplace ($sclrecord, $sclopenchar, "")
		$sclopencount  = @extended
		StringReplace ($sclrecord, $synvaluearray [$sclsub] [$sCloseChar], "")
		$sclclosecount = @extended
		If $sclopencount > 0 Or $sclclosecount > 0 Then _
			SynCheckState ($sclsub, $sclnumber, $sclrecord, $sclopencount, $sclclosecount)
	Next
EndFunc

Func SynCheckState ($scssub, $scsnumber, $scsline, $scsopencount = 0, $scsclosecount = 0, $scscloseout = "")
	   	$synworkarray [$scssub] [$sOpenCount]  += $scsopencount
		$synworkarray [$scssub] [$sCloseCount] += $scsclosecount
		If $scsopencount  > 0 Or $scsclosecount > 0 Then $synworkarray [$scssub] [$sLastFound ] = $scsnumber
		If $synvaluearray [$scssub] [$sEvalType] <> "Line" Then
			$scslevel = Abs ($synworkarray [$scssub] [$sOpenCount] - $synworkarray [$scssub] [$sCloseCount])
			If $scslevel > $synmaxlevel Then $synmaxlevel = $scslevel
		EndIf
		Select
			Case $synvaluearray [$scssub] [$sEvalType] = "Line"
				$scslineok = ""
				If $synvaluearray [$scssub] [$sCloseChar] =  "" And Mod ($scsopencount + $scsclosecount, 2) <> 0 Then $scslineok = "no"
				If $synvaluearray [$scssub] [$sCloseChar] <> "" And      $scsopencount <> $scsclosecount         Then $scslineok = "no"
				If $scslineok = "no" Then
					If Not StringInStr ($scsline, $synlitquotes) And Not StringInStr ($scsline, $synlitquoted) Then
						If $scsopencount  > $scsclosecount Then $synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sOpenDesc]
						If $scsclosecount > $scsopencount  Then $synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sCloseDesc]
						$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
					EndIf
				EndIf
			Case $scscloseout = "yes"
				If $synworkarray [$scssub] [$sOpenCount] > $synworkarray  [$scssub] [$sCloseCount] Then
					$synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sOpenDesc]
					$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
				EndIf
			Case $synworkarray [$scssub] [$sCloseCount] > $synworkarray [$scssub] [$sOpenCount]
				$synworkarray [$scssub] [$sErrorMsg] = $synvaluearray [$scssub] [$sCloseDesc]
				$synworkarray [$scssub] [$sErrorEnd] = $scsnumber
			Case $scsopencount <> $scsclosecount And $synworkarray [$scssub] [$sErrorStart] = ""
				$synworkarray [$scssub] [$sErrorStart] = $scsnumber
			Case $synworkarray [$scssub] [$sOpenCount] = $synworkarray [$scssub] [$sCloseCount]
				If $synworkarray [$scssub] [$sOpenCount]  > 0 Then $synworkarray [$scssub] [$sOpenCount]  -= 1
				If $synworkarray [$scssub] [$sCloseCount] > 0 Then $synworkarray [$scssub] [$sCloseCount] -= 1
		EndSelect
		If $synworkarray [$scssub] [$sErrorEnd] <> "" Then SynStoreError ($syncurrfilename, $syncurrfileline)
EndFunc

Func SynStoreError ($sefilename, $sefileline)
	If $syncurrfileedit = "" Then $syncurrfileedit = $sefilename
	For $ssesub = 0 To $sScanTypes - 1
		If $synworkarray [$ssesub] [$sErrorMsg] = "" Then ContinueLoop
		$ssestart = $synworkarray [$ssesub] [$sErrorStart]
		$sseend   = $synworkarray [$ssesub] [$sErrorEnd]
		$sselast  = $synworkarray [$ssesub] [$sLastFound]
		If $sselast <> "" And $sselast < $sseend Then $sseend = $sselast
		If $ssestart = "" Or $ssestart = $sseend Then
			$ssestart = $sseend
			$ssemsghdr1 = "*** Line  " & $sseend - $sefileline
		Else
			$ssemsghdr1 = "*** Lines " & $ssestart  - $sefileline & "  To  " & $sseend  - $sefileline
		EndIf
		$ssemsghdr1  = @TAB & "File " & BaseFuncPadRight ($sefilename, 60) & @TAB & $ssemsghdr1
		$ssemsghdr2  = "Error Type        " & $synworkarray [$ssesub] [$sErrorMsg] & " ***" & @CRLF
		$ssesortinc  = 2
		$ssesortcode = StringFormat ("%05i", $ssestart) & "-" & $ssesub & "-"
		_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", 1)& @CRLF & _
		    $ssemsghdr1 & @TAB & $ssemsghdr2)
		For $sselinesub = $ssestart To $sseend
			_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", $ssesortinc) & _
				"     " & $sselinesub - $sefileline & "     " & $syninputarray [$sselinesub])
			$ssesortinc += 1
		Next
		_ArrayAdd ($synerrorarray, $ssesortcode & StringFormat ("%05i", $ssesortinc) & @CRLF)
		$synerrorcount += 1
		If $synworkarray [$ssesub] [$sErrorEnd] <> "" Then
			For $sseworkfields = 0 To $sWorkFields - 1
				$synworkarray [$ssesub] [$sseworkfields] = ""
			Next
		EndIf
	Next
	;_ArrayDisplay ($synerrorarray)
EndFunc

Func SynEndBlock ($sebline)
	For $sebsub = 0 To $sScanTypes - 1
		SynCheckState ($sebsub, $sebline, "", 0, 0, "yes")
	Next
	Dim $synworkarray [$sScanTypes] [$sWorkFields]
EndFunc

Func SynShowErrors ($ssetarget)
	Local $ssebuttonedit, $ssebuttonrescan, $sseedithandle, $ssenotepadpid, $sserunningedit
	$ssepad = _StringRepeat (" ", 13)
	SynEndBlock (Ubound ($syninputarray) - 1)
	If $syncharactercount = 0 Then Return "Empty"
	If $synerrorcount     = 0 Then Return "NoErrors"
	_ArraySort    ($synerrorarray)
	$ssemessage = ""
	$sseheader  = "** Probable Syntax Errors In " & $ssetarget & "  **"
	$ssetrailer = $synerrorcount & "  Errors Were Found"
	If $synerrorcount = 1 Then $ssetrailer = "1 Error Was Found"
	_ArrayInsert ($synerrorarray, 1, $ssepad & @CRLF & @TAB & _
	     "** " & $ssetrailer & " on " & TimeLine ("", "", "yes") & " **" & @CRLF)
	_ArrayInsert ($synerrorarray, 1, $ssepad & @CRLF & @TAB & $sseheader)
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & _
	     "***   The Syntax Check Is Complete    ***  "   & @TAB & $ssetrailer)
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & SynFormatLines ())
	_ArrayAdd    ($synerrorarray,    $ssepad & @CRLF & @TAB & "The Maximum Nesting Level Was " & $synmaxlevel)
	For $ssesub = 0 To Ubound ($synerrorarray) - 1
		$synerrorarray [$ssesub] = StringTrimLeft ($synerrorarray [$ssesub], 13)
		$ssemessage &= $synerrorarray [$ssesub] & @CRLF
	Next
	$synguihandle = CommonScaleCreate ("GUI", "  Syntax Scan Of " & $ssetarget, -1, -1, 100, 100, -1)
	GUISetBKColor ($mymedgray, $synguihandle)
	If Not ProcessExists ($ssenotepadpid) Then ProcessClose ($ssenotepadpid)
	$sseedithandle   = CommonScaleCreate ("Edit", $ssemessage,  0, 0, 100, 85, BitOr ($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
	$ssebuttonedit   = CommonScaleCreate ("Button", "Edit File",     8, 93, 12, 5)
	$ssebuttonrescan = CommonScaleCreate ("Button", "Rescan",       45, 93, 12, 5)
	$ssebuttonaccept = CommonScaleCreate ("Button", "Accept As Is", 45, 87, 12, 5)
	$ssebuttoncancel = CommonScaleCreate ("Button", "Cancel",       80, 93, 12, 5)
	GUICtrlSetBKColor ($ssebuttonaccept, $myyellow)
	GUICtrlSetBKColor ($ssebuttonedit,   $mylightgray)
	GUICtrlSetBKColor ($ssebuttonrescan, $mylightgray)
	GUICtrlSetBKColor ($ssebuttoncancel, $mylightgray)
	GUICtrlSetBKColor ($sseedithandle,   $myyellow)
	;GUICtrlSetBKColor ($ssebuttonclose,  $sseclosecolor)
	GUISetState (@SW_SHOW, $synguihandle)
	While 1
		While $sserunningedit = "yes"
			Sleep (10)
			If ProcessExists ($synnotepadpid) Then ContinueLoop
			Return "Rescan"
		Wend
		$sseguistatusarray = GUIGetMsg (1)
		If $sseguistatusarray [1] <> $synguihandle Then ContinueLoop
		$sseguistatus = $sseguistatusarray [0]
		Switch $sseguistatus
			Case $ssebuttoncancel, $GUI_EVENT_CLOSE
				Return "Cancelled"
			Case $ssebuttonaccept
				$sseaccmsg  = "Are you sure you want to accept this file with probable syntax errors?"
				If CommonQuestion ($mbwarnyesno, "Accept?", $sseaccmsg) Then
					MsgBox ($mbinfook, "Accepted", $ssetarget & " has been accepted", 3)
					Return "Accepted"
				EndIf
			Case $ssebuttonrescan
				Return "Rescan"
			Case $ssebuttonedit
				$sserunningedit = "yes"
				GUICtrlSetState ($ssebuttonedit,   $guihideit)
				GUICtrlSetState ($ssebuttonrescan, $guihideit)
				GUICtrlSetState ($ssebuttoncancel, $guihideit)
				If Not ProcessExists ($synnotepadpid) Then _
					$synnotepadpid = CommonNotepad ($syncurrfileedit, "Edit file " & $syncurrfileedit, $synguihandle)
		EndSwitch
	WEnd
EndFunc

Func SynCheckISO ($cirecord)
	$cicheck  = $synquotes
	$cirecord = StringStripWS ($cirecord, 7)
	If StringLeft ($cirecord, 12) = "set isopath="    Then $cicheck = StringTrimLeft ($cirecord, 12)
	If StringLeft ($cirecord, 15) = "set kernelpath=" Then $cicheck = StringTrimLeft ($cirecord, 15)
	If StringLeft ($cirecord, 15) = "set initrdpath=" Then $cicheck = StringTrimLeft ($cirecord, 15)
	If StringLeft ($cirecord, 14) = "set bootparms="  Then $cicheck = StringTrimLeft ($cirecord, 14)
	If StringLeft ($cicheck,  1)  = $synquotes Or StringLeft ($cicheck,  1)  = $synquoted Then Return
	$cimsg = "The fields in this variable should be enclosed in quotes." & @CR & @CR & $cicheck
	MsgBox ($mbontop, "** ISOBoot Warning **", $cirecord & @CR & @CR & $cimsg)
EndFunc

Func SynChoose ()
	While 1
		$scmessage  = "             ** Select a Grub configuration file to be scanned for syntax **"
		$scsearch   = "Grub Configuration Files (*.cfg)"
		$scfilepath = FileOpenDialog ($scmessage, $masterpath & "\", $scsearch, 0, $synopenfile, $handlemaingui)
		If @error Then
			Return "Cancelled"
		Else
			FileCopy  ($scfilepath, $syntaxorigfile, 1)
			$synopenfile = $scfilepath
			$scstatus = SynMain ($scfilepath)
		EndIf
		If $scstatus = "Empty" Then
			$scempty = " ** No Code Was Found In This File **" & @CR & @CR & $scfilepath
			MsgBox ($mbwarnok, "             ** Syntax Check Error **", $scempty, 30)
		EndIf
		If  $scstatus  = "Cancelled" Then
			MsgBox ($mbinfook, "", "The Syntax Scan was cancelled by the user")
			Return $scstatus
		EndIf
	Wend
EndFunc

Func SynFormatLines ()
	$flcount =  Ubound ($syninputarray) - 1
	If $flcount = 1 Then Return $flcount & " Line Was Scanned"
	Return $flcount & " Lines Were Scanned"
EndFunc

Func SynStrip ($ssrecord)
	$sscommentloc = StringInStr ($ssrecord, "#")
	If $sscommentloc <> 0 Then $ssrecord = StringMid ($ssrecord, 1, $sscommentloc - 1)
	$ssrecord = StringReplace ($ssrecord, ";", " ")
	$ssrecord = StringStripWS ($ssrecord, 3)
	If $ssrecord = "" Then Return ""
	$ssrecord = " " & $ssrecord & " "
	Return $ssrecord
EndFunc