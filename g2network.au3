#RequireAdmin
#include-once
#include <g2common.au3>

If StringInStr (@ScriptName, "g2network") Then
	$zippath =  @ScriptDir & "\" & $zipmodule
	;$netrc = NetFunctionGUI  ("Download",  $windowstempgrub & "\Download\grubinst", "GrubInst", "Grub2Win Software", "")
	;$netrc = NetFunctionGUI  ("DownloadExtract",  $windowstempgrub & "\Download\grubinst", "GrubInst", "Grub2Win Software")
	$netrc = NetFunctionGUI  ("DownloadExtractRun", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, "GrubInst", "Grub2Win Software")
	MsgBox ($mbontop, "Return Code", $netrc)
	BaseFuncCleanupTemp  ("Network", "")
EndIf

Func NetCheckSpace ($csaction, $cslocalfile)
	$csworkdrive = StringLeft ($cslocalfile, 3)
	$csrequired  = 50
	$csresult    = "OK"
	If $csaction = "DownloadOnly" Then $csrequired = 1
	If $netfreespace = "" Then $netfreespace = Int (DriveSpaceFree ($csworkdrive))
	If $csrequired > $netfreespace Then
		$cserrmsg  = "There Is Not Enough Free Space On Your " & $csworkdrive & " Drive" & @CR & @CR
		$cserrmsg &= $csrequired & " MB Is Requred For Grub2Win" & @CR & "Download, Extract And Setup Work Space."
		MsgBox ($mbwarnok, "**** Space Check Failed ***        " & $netfreespace & " MB Available", $cserrmsg)
		$csresult = "NoSpace"
	EndIf
	Return $csresult
EndFunc

Func NetFunctionGUI ($fgaction, $fglocalfile, $fgremotedir, $fgremotefile, $fgdesc, $fginitgui = "yes", _
		$fgrunparms = $parmsetup & " " & $parmfromupdate)
	$fgresult = "OK"
	SecureCheck          ()
	BaseFuncGUIDelete      ($upmessguihandle)  ; Remove after testing
	DirCreate            ($windowstempgrub &  "\Download")
	$nethandlegui        = CommonScaleCreate ("GUI",    $netlogdesc,  -1, -1, 70,  50, $WS_EX_STATICEDGE)
	$fghandlemsg         = CommonScaleCreate ("Label",  "",          3.3,  2, 63,  25, $SS_CENTER)
	$nethandlebar        = CommonScaleCreate ("Progress", "",         15, 31, 40,   3)
	$nethandleprogtext   = CommonScaleCreate ("Label",    "",          1, 35, 69,   3, $SS_CENTER)
	$nethandlecancel     = CommonScaleCreate ("Button",   "",         27, 40, 15,   3)
	$fghandleclose       = CommonScaleCreate ("Button", "Close",      57, 40,  7, 3.2)
	GUICtrlSetBkColor    ($fghandlemsg, $myyellow)
	GUISetBkColor        ($myblue,  $nethandlegui)
	If $fginitgui <> "" Then GUISetState (@SW_SHOW, $nethandlegui)
	NetProgressVisible   ($guihideit)
    WinSetOnTop          ($nethandlegui, "", 1)
	$fgresult = NetCheckSpace ($fgaction, $fglocalfile)
	If $fgresult = "OK" And StringInStr ($fgaction, "Download") Then
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
	$direturn    = "OK"
	NetProgressUpdate ("Start", "", "")
	Do
		$diinfoarray = InetGetInfo  ($dihandle, -1)
		;_ArrayDisplay ($diinfoarray)
		$diread      = $diinfoarray [$INET_DOWNLOADREAD]
		$disize      = $diinfoarray [$INET_DOWNLOADSIZE]
		$dicomplete  = $diinfoarray [$INET_DOWNLOADSUCCESS]
		$dierrorcode = $diinfoarray [$INET_DOWNLOADERROR]
		If $dierrorcode  = 0 Then
			If $netshortlimit <> "" And $diread > $netshortlimit Then $direturn = "Short"
			$dipercent     = CommonCalcPercent  ($diread, $disize)
			$diprogress    = NetProgressUpdate ("update", $dipercent, $dipercent & "%", $ditimeout)
			If $diprogress <> "OK"      Then $direturn = "The Download Of The " & $didesc & " Was Cancelled After " & $netsecsave & " Seconds."
			If $diprogress =  "TimeOut" Then $direturn = "The Download Of The " & $didesc & " Timed Out After "     & $netsecsave & " Seconds."
		Else
			$direturn = "The Download Of The " & $didesc & " Failed  -  Code " & $dierrorcode & "   "
		EndIf
		;ProgressSet ($dipercent, Int ($dipercent) & "% Complete" & "            " & $diseconds & " Seconds")
		;MsgBox ($mbontop, "Read", $disize & @CR & $diread & @CR & $dipercent)
	Until $dicomplete = "true" Or $direturn <> "OK"
	If $direturn   = "OK" And FileGetSize ($dilocalfile) < $kilo Then $direturn = "Download Of The " & $didesc & " Failed (Size)."
	If $direturn   = "Short" Then $direturn = "OK"
	$netshortlimit = ""
	InetClose ($dihandle)
	Return     $direturn
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
	$nelog          =  ""
	$neresult       =  "OK"
	If $nehndmsg    <> "" Then CommonLabelJustify ($nehndmsg, "Now Extracting The " & $nedesc, 1)
	If $nehndclose  <> "" Then GUICtrlSetState   ($nehndclose, $guihideit)
	$neparms        = ' x "' & $nezipfile & '" -aoa -o"' & $extracttempdir & '"'
	NetProgressUpdate ("Start", "", "", $netimeout, "Extract")
	$nepidextract   = Run ($zippath & $neparms, "", @SW_HIDE, $STDERR_MERGED)
	$neprocrc       = ProcessWait ($zipmodule, 5)
	;MsgBox ($mbontop, "Extract " & @error, $nepidextract & @CR & @CR & $neparms & @CR & @CR & $zippath)
	If $nepidextract = 0 Or $neprocrc = 0 Then
		$neresult = "7-Zip Did Not Initialize Properly   " & $nepidextract & "    " & $neprocrc
	Else
		While 1
			$nelog     &= StdOutRead ($nepidextract)
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
	ProcessClose        ($nepidextract)
	$neinsize    =  BaseFuncAddThousands (FileGetSize ($nezipfile))
	$neoutcheck  =                       (DirGetSize  ($extracttempdir))
	$neoutsize   =  BaseFuncAddThousands ($neoutcheck)
	BaseFuncSingleWrite ($workdir & $extractlogstring, @CR & TimeLine () & @CR & $nelog)
	If $neresult =  "OK" And $neoutcheck < $kilo Then _
		$neresult = "7-Zip Did Not Complete Normally"
	If $neresult <> "OK" Then
		FileDelete ($nezipfile)
		DirRemove  ($extracttempdir, 1)
		MsgBox ($mbontop, "** Extract Error **", "Input File Size = " & $neinsize & @CR & @CR & _
			"Output Dir Size = " & $neoutsize & @CR & @CR & @CR & "7-Zip Log Text = " & $nelog)
		$neresult  = "The Zip Extract Failed" & @CR & @CR
		$neresult &= "** Extract Failures Are Often Caused By Your Antivirus Software **" & @CR
		$neresult &= "**     Or Not Having Enough Disk Space For The Output Files     **" & @CR & @CR
		$neresult &= "Parms = " & StringReplace ($neparms, " ", @CR)
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