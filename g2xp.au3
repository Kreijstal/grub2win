#include-once
#include <g2common.au3>

Func XPCreateManager ()
	FileSetAttrib ($xpmanager,                             "-RS")
	FileSetAttrib ($windowsdrive & "\" & $microsoftxpbios, "-RS")
	$xcmicrosoftrc = FileCopy ($bootmanpath & "\" & $microsoftxpbios, $windowsdrive & "\", 1)
	$xcgrub2winrc  = FileCopy ($bootmanpath & "\" & $bootmanagerbios, $xpmanager, 1)
	FileSetAttrib ($xpmanager,                             "+RS")
	FileSetAttrib ($windowsdrive & "\" & $microsoftxpbios, "+RS")
	If $xcmicrosoftrc = 1 And $xcgrub2winrc = 1 Then
		CommonWriteLog('  The Grub2Win XP Boot manager ' & $xpmanager & ' was set up', 2)
	Else
		CommonWriteLog("  *** XP manager setup failed   RC = " & $xcmicrosoftrc & "-" & $xcgrub2winrc & " ***", 2)
		Return 1
	EndIf
	Return 0
EndFunc

Func XPUninstall ()
	FileSetAttrib ($xpmanager, "-RS")
	FileCopy      ($bootmanpath & "\"  & $microsoftxpbios, $xpmanager, 1)
	FileSetAttrib ($xpmanager, "+RS")
	FileSetAttrib ($windowsdrive & "\" & $microsoftxpbios, "-RS")
	FileDelete    ($windowsdrive & "\" & $microsoftxpbios)
EndFunc

Func XPCleanupBoot ()
	$cbiniupdate    = ""
	Dim $cbarraynew [0]
	$cbarrayold = BaseFuncArrayRead ($xpinifile, "XPCleanupBoot", "", "no")
	If @error Then
		CommonWriteLog    ("                *** Error reading " & $xpinifile)
		BaseFuncShowError ("The " & $xpinifile & " file is missing", "XPCleanupBoot")
	EndIf
	For $cbsub = 0 To Ubound ($cbarrayold) - 1
		$cbrec = StringStripWS ($cbarrayold [$cbsub], 3)
		If StringInStr ($cbrec, "g2wxpstub") Then
			$cbiniupdate = "yes"
			ContinueLoop
		EndIf
		_ArrayAdd ($cbarraynew, $cbrec)
	Next
	;_ArrayDisplay ($cbarraynew, $cbtimeoutnew)
	If FileExists ($xpstubfile) Or FileExists ($xploadfile) Or $cbiniupdate <> "" Then
		FileSetAttrib  ($xpstubfile, "-RS")
		FileSetAttrib  ($xploadfile, "-RS")
		FileSetAttrib  ($xpinifile,  "-RS")
		FileDelete     ($xpstubfile)
		FileDelete     ($xploadfile)
		BaseFuncArrayWrite ($xpinifile, $cbarraynew, $FO_OVERWRITE, "", 0)
		FileSetAttrib  ($xpinifile,  "+RS")
		CommonWriteLog ("           Obsolete Grub2Win boot entries have been removed")
		CommonWriteLog ()
	EndIf
EndFunc