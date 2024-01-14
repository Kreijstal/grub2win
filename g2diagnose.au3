#RequireAdmin
#include-once
#include  <g2common.au3>

Func DiagnoseGUI ($dglocalfile = "")
	$dgpathguide = "C:\"
	Global $diagnosename = $useridalpha
	Global $diagnosemail = RegEnumKey ($regkeyemail, 1)
	Global $diagnoselang
	Global $diagnosedesc
	Global $diagnoseguihandle  = CommonScaleCreate ("GUI", "** Diagnostics **", - 1, - 1,  60, 70,   $WS_EX_STATICEDGE, -1, $handlemaingui)
	Global $diagnosenamehandle = CommonScaleCreate ("Input",  $diagnosename,      2,   3,  20,  3)
	CommonScaleCreate ("Label", "Enter a name to identify your diagnostic file", 23.2, 3,  55,  3)
	Global $diagnosemailhandle = CommonScaleCreate ("Input",  $diagnosemail,      2,  10,  35,  3)
	CommonScaleCreate ("Label", "Enter your E-Mail address" & @CR & "for a response", 38.2, 9, 21, 6)
	Global $diagnoselanghandle = CommonScaleCreate ("Combo",  "",                 2,  15,  35,  3)
	CommonScaleCreate ("Label", "Set your preferred language",                 38.2, 15.4, 21, 6)
    $dglanglist = BaseFuncSingleRead ($sourcepath & "\xxdiaglang.txt")
    $dglanglist = StringReplace ($dglanglist, "|" & $languserdesc, "")
	GUICtrlSetData    ($diagnoselanghandle, "|" & $languserdesc & $dglanglist, $languserdesc)
	CommonScaleCreate ("Label", "Please describe the problem",                    2,  22,  55,  3,   $SS_CENTER)
	Global $diagnosedeschandle = CommonScaleCreate ("Input",  $diagnosedesc,      2,  25,  56, 12,   $ES_MULTILINE + $ES_WANTRETURN)
	ControlFocus ($diagnoseguihandle, "", $diagnosedeschandle)
	Global $diagnosemischandle = CommonScaleCreate ("Button", "",                 2,  40,  12, 11,   $BS_MULTILINE)
	Global $diagnoselisthandle = CommonScaleCreate ("List",   "",                16, 42.1, 42, 11.6, $WS_VSCROLL, 0)
	Global $diagnosecanchandle = CommonScaleCreate ("Button", "Cancel",           4,  58,   8,  3)
	Global $diagnosetexthandle = CommonScaleCreate ("Label",  "",                13,  58,  34,  6,   $SS_CENTER)
	Global $diagnoseokhandle   = CommonScaleCreate ("Button", "OK",              48,  58,   8,  3)
	Dim    $diagnosemiscarray  [0]
	DiagnoseRefresh ("")
	While 1
		$dgstatus = GUIGetMsg ()
		Select
			Case $dgstatus = $diagnoseokhandle
				$dgcolor = DiagnoseRefresh ()
				If $dgcolor <> $myred Then ExitLoop
			Case $dgstatus = $diagnosecanchandle
				BaseFuncGUIDelete ($diagnoseguihandle)
				Return
			Case $dgstatus = $diagnosemischandle
				$dgmiscpath = FileOpenDialog ("Select a file to attach", $dgpathguide, "All(*.*)", $FD_FILEMUSTEXIST, "", $diagnoseguihandle)
				$dgpathguide = '"' & $dgmiscpath & '"'
				If Not @error Then
					_ArrayAdd       ($diagnosemiscarray, $dgmiscpath)
					GUICtrlSetData  ($diagnoselisthandle, "|")
				EndIf
				DiagnoseRefresh ()
			Case $dgstatus = $diagnosemailhandle Or $dgstatus = $diagnoselanghandle Or $dgstatus = $diagnosetexthandle
				DiagnoseRefresh ()
				ContinueLoop
		EndSelect
	Wend
	BaseFuncGUIDelete ($handlemaingui)
	BaseFuncGUIDelete ($diagnoseguihandle)
	CommonFlashStart  ("Creating Diagnostics Data", "This May Take Up To 60 Seconds", 750, "Diagnostics")
	UtilCreateSysInfo ()
   	CommonDatabase    ()
	PartBuildDatabase ("yes")
	UtilScanDisks     ()
	$diagnosedesc     = CommonFormatComment ($diagnosedesc, @TAB & @TAB & @TAB & @TAB)
	DiagnoseRun       ("OnRequest", BaseFuncRemoveCharSpec ($diagnosename), $diagnosemail, @TAB & $diagnosedesc, $dglocalfile)
	Return 1
EndFunc

Func DiagnoseRefresh ($drcheckerror = "yes")
	$drdiagcolor     = $mylightgray
	$drfocus         = $diagnoseokhandle
	$drmailok        = ""
	$drdescok        = ""
	$drlangok        = ""
	$droktext        = "Click OK when you are done"
	$drmiscbutton    = @CR & "Attach" & @CR & "Files"
	$drmisclist      = "|| Attach files and screenshots that show any errors.| You can take screenshot photos with your phone."
	If Ubound ($diagnosemiscarray) > 0 Then
		$drmiscbutton  = @CR & "Attach More" & @CR & "Files"
		GUICtrlSetData ($diagnoselisthandle, "|")
		$drmisclist = "****** Attached Files ******|"
		For $drsub = 0 To Ubound ($diagnosemiscarray) - 1
			$drmisclist &= $drsub + 1 & ".  " & $diagnosemiscarray [$drsub] & "|"
		Next
	EndIf
	$diagnosemail    = StringStripWS (GUICtrlRead ($diagnosemailhandle), 7)
	$diagnoselang    = StringStripWS (GUICtrlRead ($diagnoselanghandle), 7)
	$diagnosename    = StringStripWS (GUICtrlRead ($diagnosenamehandle), 7)
	$diagnosedesc    = StringStripWS (GUICtrlRead ($diagnosedeschandle), 7)
	If $diagnosename = "" Then $diagnosename = $useridalpha
	If $drcheckerror  <> "" Then
		$drdescmsg       = CommonCheckDescription ($diagnosedesc)
		If $drdescmsg    =  ""              Then $drdescok = "yes"
		If $diagnoselang <> ""              Then $drlangok = "yes"
		If CommonCheckEmail ($diagnosemail) Then $drmailok = "yes"
		$drdiagcolor     = $myred
		Select
			Case $drmailok = ""
				$droktext = "Please enter a valid E-Mail address"
				$drfocus  = $diagnosemailhandle
			Case $diagnoselang = ""
				$droktext = "Please set your preferred language"
				$drfocus  = $diagnoselanghandle
			Case $drdescmsg <> ""
				$droktext = $drdescmsg
				$drfocus  = $diagnosedeschandle
			Case Else
				$drdiagcolor = $mylightgray
		EndSelect
	EndIf
	ControlFocus      ($diagnoseguihandle, "", $drfocus)
	GUICtrlSetData    ($diagnosemischandle, $drmiscbutton)
	GUICtrlSetData    ($diagnosetexthandle, $droktext)
	GUICtrlSetBkColor ($diagnosetexthandle, $drdiagcolor)
	GUICtrlSetBkColor ($diagnosemischandle, $myyellow)
	GUICtrlSetBkColor ($diagnoselisthandle, $mylightgray)
	GUICtrlSetData    ($diagnoselisthandle, $drmisclist)
	GUISetState       (@SW_SHOW, $diagnoseguihandle)
	Return $drdiagcolor
EndFunc

Func DiagnoseRun ($drerrorcode, $drname = $useridformat, $dremail = "None", $drerrdesc = "", $drlocalfile = "")
	$drsmisccount = Ubound ($diagnosemiscarray)
	If Ubound ($diagnosemiscarray) = 0 Then $drsmisccount = "No"
	$drhandle = FileOpen ($datapath & "\diag.desc.txt", 2)
	FileWriteLine ($drhandle, "New York Time      = " & $nytimeus     & @CR & @CR)
	FileWriteLine ($drhandle, "User Name          = " & $drname       & @CR & @CR)
	FileWriteLine ($drhandle, "User E-Mail        = " & $dremail      & @CR & @CR)
	FileWriteLine ($drhandle, "Run Type           = " & $runtype &  "    Version " & $basrelcurr & @CR & @CR)
	FileWriteLine ($drhandle, "OS Info            = " & $bootos  &  "  " & $firmwaremode &  " " & $osbits & " Bit" & @CR & @CR)
	FileWriteLine ($drhandle, "BIOS Date          = " & $regbiosdate  & @CR & @CR)
	FileWriteLine ($drhandle, "Stamp              = " & $genstampdisp & @CR & @CR)
	FileWriteLine ($drhandle, "Location           = " & $geocity & ", " & $georegion & ", " & $geocountry   & @CR & @CR)
	FileWriteLine ($drhandle, "System Language    = " & $langsysdesc  & @CR & @CR)
	If $languserdesc <> $langsysdesc Then FileWriteLine ($drhandle, "User Language      = " & $languserdesc & @CR & @CR)
	FileWriteLine ($drhandle, "Preferred Language = " & $diagnoselang & @CR & @CR)
	FileWriteLine ($drhandle, "Misc Files         = " & $drsmisccount & @CR & @CR)
	FileWriteLine ($drhandle, "Error Code         = " & $drerrorcode  & @CR & @CR & @CR)
	FileWrite     ($drhandle, "Error Description Follows:    "   & $drerrdesc)
	FileClose     ($drhandle)
	If $diagcomplete = "yes" Then
		CommonFlashEnd ("")
		Return
	EndIf
	_ArrayInsert ($templogarray, 0, "New York Time = " & $nytimeus)
	BaseFuncArrayWrite ($datapath & "\diag.log.main.txt", $templogarray)
	FileCopy        ($windowstempgrub & "\utilityscan.log.txt", $datapath & "\diag.log.util.txt",1)
	If Ubound ($efiassignlogarray) > 0 Then _
		BaseFuncArrayWrite ($datapath & "\diag.log.efiassign.txt", $efiassignlogarray, $FO_OVERWRITE, "", 0)
	DirRemove ($diagpath, 1)
	If Ubound ($diagnosemiscarray) > 0 Then
		For $drsub = 0 To Ubound ($diagnosemiscarray) - 1
			$drfrompath   = $diagnosemiscarray [$drsub]
			$drsplitarray = StringSplit ($drfrompath, "\")
			If @error Then ContinueLoop
			$drtofile     = $drsplitarray [Ubound ($drsplitarray) - 1]
			FileCopy ($drfrompath, $masterpath & "\miscfiles\" & $drtofile, 9)
		Next
	EndIf
	EnvSet  ("diagauto",  "yes")
	EnvSet  ("basedir",   $masterpath)
	EnvSet  ("errorcode", $drerrorcode)
	If $firmwaremode = "EFI" Then
		DirCreate ($storagepath & "\tempfiles")
		_FileWriteFromArray ($storagepath & "\tempfiles\Diagnostic.BCDArray.txt",      $bcdarray)
		_FileWriteFromArray ($storagepath & "\tempfiles\Diagnostic.BCDOrderArray.txt", $bcdorderarray)
	EndIf
	CommonWriteLog  ("Diagnostics are now being run")
	CommonWriteLog  ("This may take up to 60 seconds")
	CommonWriteLog  ()
	CommonSaveListings ()
	RunWait ($sourcepath & "\xxdiag.bat", "", @SW_HIDE)
	CommonFlashEnd    ("Diagnostics Data Creation Is Complete")
	If $drlocalfile = "" Then $drlocalfile =  $masterpath & "\diagnose.7z"
	DiagnoseCompress ($drlocalfile, $diagpath)
	DirRemove        ($diagpath, 1)
	If FileExists    ($drlocalfile) Then
		CommonWriteLog ("Diagnostics are complete, the data has been stored in file " & $drlocalfile)
		$drrc = DiagnoseUpload ($drname, $drlocalfile, $drerrdesc)
		If $drrc <> "OK" Then
			CommonFlashEnd  ("")
			CommonWriteLog ("The diagnostic upload failed - " & @CR & $drrc)
			MsgBox         ($mbwarnok, "** Diagnostic Upload Error",  $drrc)
			$drrc = MsgBox ($mbquestyesno, "** The Upload Failed **", _
				"Would you like to email the diagnosics file" & @CR & "instead of uploading?")
			If $drrc = $IDYES Then CommonMailIt ("file", $drlocalfile, $drerrdesc)
		EndIf
	Else
		CommonWriteLog ("The diagnostic routine failed")
	EndIf
	$diagcomplete = "yes"
EndFunc

Func DiagnoseUpload ($duname, $dulocalfile, $duerrdesc)
	$dumessage  = 'The diagnostic file can now be uploaded'        & @CR
	$dumessage &= 'to the Grub2Win support server.'                & @CR & @CR & @CR
	$dumessage &= 'Click "Yes" to upload the file.'                & @CR
	$dumessage &= 'Click "No" if you prefer to email the file.'    & @CR
	$durc = MsgBox ($mbquestyesno, "** Upload Ready **", $dumessage)
	If $durc <> $IDYES Then
		CommonMailIt ("file", $dulocalfile, $duerrdesc)
		Return "OK"
	EndIf
	CommonFlashStart ("Uploading Your Diagnostic File")
	$duopen = _FTP_Open    ('MyFTP Control')
    $duconn = _FTP_Connect ($duopen, $ftpserver, $diaguser, $diagpass, 1, 21, _
		$INTERNET_SERVICE_FTP, $INTERNET_FLAG_PASSIVE + $INTERNET_FLAG_TRANSFER_BINARY)
	If @error Then Return "Connect Error"
	_FTP_DirSetCurrent ($duconn, $diagremote)
	If @error Then Return "DirSet Error"
	TimeGetCurrent   ()
	$duremotefile  = StringMid ($nytimestamp,  3, 2)
	$duremotefile &= StringMid ($nytimestamp,  8, 4) & "-"
	$duremotefile &= StringMid ($nytimestamp, 15, 2) & "." & StringMid ($nytimestamp, 17, 2)
	$duremotefile &= "-" & StringStripWS ($duname, 8) & ".diagnose.7z"
	_FTP_FilePut ($duconn, $dulocalfile, $duremotefile, 2)
	If @error Then Return "FTP Put Error - Please Check Your Firewall Settings"
	_FTP_Close($duconn)
    _FTP_Close($duopen)
	Sleep (1000)
	CommonFlashStart  ("Diagnostic File Upload Is Complete")
	CommonWriteLog    ("The diagnostic file was uploaded successfully")
	Sleep (1000)
    CommonFlashEnd    ("")
	Return "OK"
EndFunc

Func DiagnoseCompress ($dczipoutput, $dczipinput)
	CommonFlashStart ("Now Compressing The Diagnostic Data")
	FileDelete       ($dczipoutput)
	$dcparms         = ' a "' & $dczipoutput & '"  "' & $dczipinput & '\*"'
	RunWait          ($zippath & $dcparms, "", @SW_HIDE)
	CommonFlashEnd   ("Diagnostic Data Compression Is Complete")
EndFunc