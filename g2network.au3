#RequireAdmin
#include-once
#include <g2common.au3>

Global $ftptimerstart, $ftptimeout, $ftpseconds
Global $nethandlegui, $nethandlecancel, $nethandlebar, $nethandleprogtext
Global $netsecsave, $nettimer, $netlogdesc = "Grub2Win Network Log"
Global $netdownsite, $netlogmode = $FO_OVERWRITE

If StringInStr (@ScriptName, "g2network") Then
	$zippath =  @ScriptDir & "\" & $zipmodule
	;$netrc = NetFunctionGUI  ("Download",  $windowstempgrub & "\Download\grubinst", "GrubInst", "Grub2Win Software", "")
	;$netrc = NetFunctionGUI  ("DownloadExtract",  $windowstempgrub & "\Download\grubinst", "GrubInst", "Grub2Win Software")
	$netrc = NetFunctionGUI  ("DownloadExtractRun", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, "GrubInst", "Grub2Win Software")
	MsgBox ($mbontop, "Return Code", $netrc)
	BaseFuncCleanupTemp  ("Network", "")
EndIf

Func NetFunctionGUI ($fgaction, $fglocalfile, $fgremotedir, $fgremotefile, $fgdesc, $fginitgui = "yes", _
		$fgrunparms = $parmsetup & " " & $parmfromupdate)
	$fgresult = "OK"
	SecureCheck          ()
	BaseFuncGUIDelete      ($upmessguihandle)  ; Remove after testing
	DirCreate            ($windowstempgrub &  "\Download")
	$nethandlegui        = CommonScaleCreate ("GUI",    $netlogdesc,  -1, -1, 60,  50, $WS_EX_STATICEDGE)
	$fghandlemsg         = CommonScaleCreate ("Label",  "",          3.3,  3, 52,  25, $SS_CENTER)
	$fghandleclose       = CommonScaleCreate ("Button", "Close",      48, 41,  7, 3.2)
	$nethandlebar        = CommonScaleCreate ("Progress", "",         10, 31, 40,   3)
	$nethandleprogtext   = CommonScaleCreate ("Label",    "",          1, 35, 59,   3, $SS_CENTER)
	$nethandlecancel     = CommonScaleCreate ("Button",   "",         22, 41, 15,   3)
	GUICtrlSetBkColor    ($fghandlemsg, $myyellow)
	GUISetBkColor        ($myblue,  $nethandlegui)
	If $fginitgui <> "" Then GUISetState (@SW_SHOW, $nethandlegui)
	NetProgressVisible   ($guihideit)
    WinSetOnTop          ($nethandlegui, "", 1)
	If StringInStr ($fgaction, "Download") Then
		$fgtimer  = TimeTickInit ()
		$fgresult = NetDownLoad ($fglocalfile, $fgremotedir, $fgremotefile, $fgdesc, "", $fghandlemsg, $fghandleclose)
		NetLog           ("End Download     " & $fgresult, $fgdesc, $fgtimer)
	EndIf
	If $fgresult = "OK" And StringInStr ($fgaction, "Extract") Then
		$fgtimer  = TimeTickInit ()
		$fgresult = NetExtract ($fglocalfile, $fgdesc, $fghandlemsg, $fghandleclose)
		NetLog           ("End Extract      " & $fgresult, $fgdesc, $fgtimer)
	EndIf
	NetProgressVisible   ($guihideit)
	If $fgresult = "OK" Then
		If StringInStr ($fgaction, "Run") Then
			$fgtimer           = TimeTickInit ()
			CommonLabelJustify  ($fghandlemsg, "** Preparing Grub2Win Setup **", 3)
			BaseFuncUnmountWinEFI ()
			Sleep              (250)
			Run                ($extracttempdir & "\install\winsource\" & $exestring & " " & $fgrunparms)
			BaseFuncGUIDelete    ($handlemaingui)
			BaseFuncGUIDelete    ($nethandlegui)
			NetLog             ("Start Setup      " & $fgresult, $fgdesc, $fgtimer)
			;MsgBox ($mbontop, "Starting", $fgaction & @CR & $fgrunparms)
			Exit
		EndIf
	Else
		GUICtrlSetState   ($fghandleclose, $guishowit)
		GUICtrlSetData    ($fghandlemsg,   @CR & $fgresult)
		GUICtrlSetBkColor ($fghandlemsg,   $myred)
		GUISetState       (@SW_SHOW, $nethandlegui)
		CommonGUIPause     ($fghandleclose)
	EndIf
	BaseFuncGUIDelete        ($nethandlegui)
	Return $fgresult
EndFunc

Func NetProgressUpdate ($puaction, $pupercent = "", $puprogtext = "", $putimeout = 30, $putype = "Download")
	$puresult = "OK"
	Select
		Case $puaction = "Start"
			$nettimer   = TimeTickInit ()
			$netsecsave = 0
			GUICtrlSetData     ($nethandlecancel, "Cancel " & $putype)
			NetProgressVisible ($guihideit)
		Case $puaction = "Update"
			$puticks   = TimeTickDiff ($nettimer)
			$puseconds = Int ($puticks / 1000)
			If $puseconds > 1 And $puseconds <> $netsecsave Then
				$netsecsave = $puseconds
				$puline = $putype & " Is " & $puprogtext & " Complete       Running For " & TimeFormatTicks ($puticks)
				GUICtrlSetData     ($nethandlebar,      $pupercent)
				GUICtrlSetData     ($nethandleprogtext, $puline)
				NetProgressVisible ($guishowit)
				GUISetState        (@SW_SHOW, $nethandlegui)
			EndIf
			$pustatus = GUIGetMsg ()
			Select
				Case $pustatus = "" Or $pustatus = 0
				Case $pustatus = $nethandlecancel
					$puresult = "Cancelled"
				Case $puseconds > $putimeout
					$puresult = "TimeOut"
			EndSelect
	EndSelect
	Return $puresult
EndFunc

Func NetProgressVisible ($pvstate = $guishowit)
	GUICtrlSetState ($nethandlebar,      $pvstate)
	GUICtrlSetState ($nethandleprogtext, $pvstate)
	GUICtrlSetState ($nethandlecancel,   $pvstate)
EndFunc

Func NetDownload ($ndlocalfile, $ndremotedir, $ndremotefile, $nddesc, $nddownhandle = "", $ndmsghandle = "", $ndclosehandle = "", $ndtimeout = 30)
	FileDelete ($ndlocalfile)
	If $ndclosehandle <> "" Then GUICtrlSetState   ($ndclosehandle, $guihideit)
	If $ndmsghandle   <> "" Then CommonLabelJustify ($ndmsghandle, "Now Downloading The " & $nddesc, 0)
	If $bootos = $xpstring  Then $netdownsite = "Alternate Site"
	If $netdownsite = "" Then
		$ndresult = NetDownINet ($ndlocalfile, $ndremotedir, $ndremotefile, $nddesc, $ndtimeout) ;$ndtimeout)
		If $ndresult <> "OK" Then
			NetLog         ($ndresult & " Trying Alternate FTP Site.", $nddesc)
			CommonWriteLog ()
			CommonWriteLog ("**** SourceForge   " & $ndresult)
			If Not StringInStr ($ndresult, "Cancelled") Then $netdownsite = "Alternate Site"
			$netsecsave = 0
		EndIf
	EndIf
	If $netdownsite <> "" Then
		;MsgBox ($mbontop, "FTP Start", $ndresult)
		WinSetTitle ($nethandlegui, "", $netlogdesc & "   ** " & $netdownsite & " **")
		$ndresult = NetDownFTP  ($ndlocalfile, $ndremotefile, $nddesc, $ndtimeout)
		If $ndresult <> "OK" And Not StringInStr ($ndresult, "Cancelled") Then
			TimeGetCurrent  ()
			CommonWriteLog ("**** " & $netdownsite & "   " & $ndresult)
			$nderrmsg  = $netdownsite & "   " & $ndresult & @CR & @CR
			$nderrmsg &= "Please Check Your Internet Connection And Firewall Software"      & @CR & @CR & @CR
			$nderrmsg &= "Local Time" & @TAB & TimeLine ("", "", "yes") & @CR
			If $zulutimeline <> "" Then $nderrmsg &= "ZULU Time"     & @TAB & $zulutimeline & @CR
			If $nytimeus     <> "" Then $nderrmsg &= "New York Time" & @TAB & $nytimeus     & @CR
			$nderrmsg &= "Country   " & @TAB & SettingsGet ($setstatcountry)
			MsgBox ($mbwarnok, "**** Download Failed ***", $nderrmsg)
		EndIf
	EndIf
	If $ndresult <> "OK" Then
		FileDelete         ($ndlocalfile)
		If $ndmsghandle   <> "" Then CommonLabelJustify  ($ndmsghandle,   $ndresult, 2)
		If $ndmsghandle   <> "" Then GUICtrlSetBkColor  ($ndmsghandle,   $myred)
		If $nddownhandle  <> "" Then GUICtrlSetState    ($nddownhandle,  $guihideit)
		If $ndclosehandle <> "" Then GUICtrlSetState    ($ndclosehandle, $guishowit)
		GUISetState (@SW_SHOW, $nethandlegui)
	EndIf
	Return $ndresult
EndFunc

Func NetDownINet ($dilocalfile, $diremotedir, $diremotefile, $didesc, $ditimeout = 30)
	$diremoteurl = $diremotedir & "/" & $diremotefile & "/download"
	$dihandle    = InetGet ($diremoteurl, $dilocalfile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	NetProgressUpdate ("Start", "", "")
	Do
		$diinfoarray = InetGetInfo  ($dihandle, -1)
		;_ArrayDisplay ($diinfoarray)
		$diread      = $diinfoarray [$INET_DOWNLOADREAD]
		$disize      = $diinfoarray [$INET_DOWNLOADSIZE]
		$dicomplete  = $diinfoarray [$INET_DOWNLOADSUCCESS]
		$dierrorcode = $diinfoarray [$INET_DOWNLOADERROR]
		If $dierrorcode <> 0 Then Return "The Download Of The " & $didesc & " Failed  -  Code " & $dierrorcode & "   "
		$dipercent   = CommonCalcPercent  ($diread, $disize)
		$diprogress  = NetProgressUpdate ("update", $dipercent, $dipercent & "%", $ditimeout)
		If $diprogress =  "TimeOut" Then Return "The Download Of The " & $didesc & " Timed Out After "     & $netsecsave & " Seconds."
		If $diprogress <> "OK"      Then Return "The Download Of The " & $didesc & " Was Cancelled After " & $netsecsave & " Seconds."
		;ProgressSet ($dipercent, Int ($dipercent) & "% Complete" & "            " & $diseconds & " Seconds")
		;MsgBox ($mbontop, "Read", $disize & @CR & $diread & @CR & $dipercent)
	Until $dicomplete = "true"
	If FileGetSize ($dilocalfile) < $kilo Then Return "Download Of The " & $didesc & " Failed (Size)."
	Return "OK"
EndFunc

Func NetDownFTP ($dflocalfile, $dfremotefile, $dfdesc, $dftimeout = 30)
	$dfresult       = ""
	$ftptimerstart  = TimeTickInit ()
	$ftptimeout     = $dftimeout
	$ftpseconds     = 0
	FileDelete ($dflocalfile)
	;ProgressOn ("Alternate Download", "Downloading The " & $dfdesc)
	NetProgressUpdate ("Start", "", "", $dftimeout)
	$dfsession = _FTP_Open    ('MyFTP Control')
	$dfhandle  = _FTP_Connect ($dfsession, $ftpserver, $downusername, $downpassword, 1, 21, _
		$INTERNET_SERVICE_FTP, $INTERNET_FLAG_PASSIVE + $INTERNET_FLAG_TRANSFER_ASCII)
	If @error Then $dfresult = "Connect Error When Downloading " & $dfdesc
	If $dfresult = "" Then
		_FTP_ProgressDownload ($dfhandle, $dflocalfile, $downremotedir & "/" & $dfremotefile, NetFTPProgress)
		If @error = 0 Then
			$dfresult = "OK"
			Sleep (500)
		ElseIf @error = -6 Then
			$dfresult = "The Download Of The " & $dfdesc & @CR & " Was Cancelled After " & $netsecsave & " Seconds"
		ElseIf $ftpseconds > $ftptimeout Then
			$dfresult = "The Download Of The " & $dfdesc & @CR & " Timed Out After " & $netsecsave & " Seconds"
		Else
			$dfresult = "The Download Of The " & $dfdesc & @CR & " Failed. RC = " & @error
		EndIf
	EndIf
	_FTP_Close  ($dfsession)
	Return $dfresult
EndFunc

Func NetFTPProgress ($fppercent)
	$fpprogress    = NetProgressUpdate ("update", $fppercent, Int ($fppercent) & "% ", $kilo)
	If $fpprogress = "OK" Then Return 1  ; Continue Download
	Return -2                            ; Cancel Download
EndFunc

Func NetExtract ($nezipfile, $nedesc, $nehndmsg = "", $nehndclose = "", $netimeout = 30)
	DirCreate       ($extracttempdir)
	$neresult       = "OK"
	If $nehndmsg    <> "" Then CommonLabelJustify ($nehndmsg, "Now Extracting The " & $nedesc, 1)
	If $nehndclose  <> "" Then GUICtrlSetState   ($nehndclose, $guihideit)
	$neparms        = ' x "' & $nezipfile & '" -aoa -o"' & $extracttempdir & '"'
	NetProgressUpdate ("Start", "", "", $netimeout, "Extract")
	$nepidextract   = Run ($zippath & $neparms, "", @SW_HIDE)
	$neprocrc       = ProcessWait ($zipmodule, 5)
	;MsgBox ($mbontop, "Extract " & @error, $nepidextract & @CR & @CR & $neparms & @CR & @CR & $zippath)
	If $nepidextract = 0 Or $neprocrc = 0 Then
		$neresult = "7-Zip Did Not Initialize Properly   " & $nepidextract & "    " & $neprocrc
	Else
		While 1
			If $neresult <> "OK" Or Not ProcessExists ($nepidextract) Then ExitLoop
			$nepercent  = CommonCalcPercent  (DirGetSize ($extracttempdir), (19 * $mega))
			$neprogress = NetProgressUpdate ("Update", $nepercent, $nepercent & "%", $netimeout, "Extract")
			Select
				Case $neprogress = "TimeOut"
					$neresult = "The Extract Timed Out"
					ExitLoop
				Case $neprogress = "OK"
				Case $neprogress = "Cancelled"
					$neresult = "The Extract Was Cancelled By User After " & $netsecsave & " Seconds"
					ExitLoop
				Case Else
					ExitLoop
			EndSelect
		Wend
	EndIf
	ProcessClose   ($nepidextract)
	If $neresult =  "OK" And DirGetSize ($extracttempdir) < $kilo Then _
		$neresult = "7-Zip Did Not Complete Normally"
	If $neresult <> "OK" Then
		FileDelete ($nezipfile)
		DirRemove  ($extracttempdir, 1)
		$neresult  = "The Zip Extract Failed" & @CR & @CR
		$neresult &= "** Extract Failures Are Often Caused By Your Antivirus Software **" & @CR & @CR
		$neresult &= "Parms = " & $neparms
		CommonLabelJustify  ($nehndmsg, $neresult, 3)
		If $nehndclose <> "" Then GUICtrlSetState ($nehndclose, $guishowit)
	EndIf
	Return $neresult
EndFunc

Func NetLog ($nltext, $nlsofttype, $nltimer = "", $nlmode = $netlogmode)
	$nlduration    = ""
	TimeGetCurrent ()
	If StringInStr ($nltext, "Cancelled") Then $nlduration = ""
	If $nltimer   <> "" Then $nlduration = @TAB & @TAB & TimeFormatTicks (TimeTickDiff ($nltimer))
	$nlrec        = "Stamp " & $nytimestamp                 & "|"
	$nlrec       &= _StringRepeat ("*", 100)                & "||"
	$nlrec       &= @TAB & $nytimeus & "    " & $nlsofttype & "||"
	$nlrec       &= @TAB & $nltext & $nlduration            & "||"
	$nlrec       &= _StringRepeat ("*", 100)
    $nlhandle     = FileOpen ($statslog, $nlmode)
	FileWriteline ($nlhandle, $nlrec)
	FileClose     ($nlhandle)
	$netlogmode   = $FO_APPEND
EndFunc