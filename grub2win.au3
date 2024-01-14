#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\winsource\xxgrub2win.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs  Author: Dave Pickens
   Available from the Grub2Win project at sourceforge.net

   Supports Windows 11, 10, 8, 7, Vista and XP

   Creates and updates the C:\grub2\grub.cfg file

   Creates and maintains the \EFI\grub2win directory in your EFI partition

   Grub2Win is written in AutoIt.
   If you wish to modify and recompile grub2win.exe,
   you will need to download and install the AutoIt software package.
   AutoIt is available free at http://www.autoitscript.com/


         Grub2Win   Copyright (C) 2010 - 2023, Dave Pickens

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see http://www.gnu.org/licenses/gpl.txt.

   Grub2Win uses parts of the 7-Zip program.
   7-Zip is licensed under the GNU LGPL license.
   The 7-Zip source code can be found here: www.7-zip.org.

#ce

#RequireAdmin
#include-once

#include     <g2common.au3>

CommonPrepareAll ()

If $runtype = $parmsetup Or CommonParms ($parmautoinstall) Then SetupMain ()
SettingsLoad    ($settingspath)

; ************  Start of main routine ************

If Not FileExists ($masterexe) Then
	$missingmsg  = 'The base program "' & $masterexe & '"  is missing!!' & @CR & @CR
	$missingmsg &= 'Grub2Win is cancelled'
	BaseFuncShowError ("Missing BaseFunc Program" & @CR & @CR & $missingmsg, "Grub2Win Main")
EndIf

If $bootos = $xpstring Then
	InitializeXP ()
Else
	InitializeBCD ()
EndIf

ProcessCommon ()

If $bootos = $xpstring Then
	UpdateXP ()
Else
	UpdateBCD ()
EndIf

CommonEndIt ("Success")

; ************  End of main routine ************

Func InitializeXP()
	XPSetup ()
	CommonInitialize ()
	XPGetPrevious    ()
EndFunc

Func InitializeBCD()
	CommonInitialize ()
	$ibrc = BCDGetBootArray ()
	If $ibrc <> 0 Then CommonEndit ("Failed")
	If $firmwaremode = "EFI" Then
		$bcdwindisplayorig = BCDOrderSort  ($bcdwinorder, "win")
		$typestring        = StringReplace ($typestring,  "invaders|", "")
	EndIf
EndFunc

Func ProcessCommon      ()
	UpdateCheckDays     ()
	CommonCopyUserFiles ()
	GetPrevConfig       ()
	CheckEnvironment    ()
	If CommonParms ($rebootstring)  Then GenRebootBuild ($parmvalue)
	If CommonParms ($parmuninstall) Then UninstallIt ()
	$pcrc = MainRunGUI ()
	SettingsPut   ($setstattype, "Daily")
	If $pcrc =  3 Then CommonEndit ("Diagnostics")
	If $pcrc <> 0 Then CommonEndit ("Cancelled")
	;BackupMake         ()
	$pcrc = GenConfig  ()
	If $pcrc <> 0 Then CommonEndit ("Failed")
	ThemeUpdateFiles   ()
EndFunc

Func UpdateXP ()
	$uxrc = XPUpdate ($timeoutwin, "no")
	If $uxrc <> 0 Then CommonEndIt ("Failed")
EndFunc

Func UpdateBCD ()
	If $firmwaremode = "EFI" Then
		BCDSetWinOrderEFI   ()
		$ubgrubmessage = BCDGetUpdateMessage ($bcdorderarray, "yes")
		If $ubgrubmessage <> "" Then CommonWriteLog ("          " & $ubgrubmessage)
		BCDSetWinTimeout ($timeoutwin)
	Else
		BCDSetupBIOS ($timeoutwin, "no")
	EndIf
EndFunc

Func CheckEnvironment ()
	$efidefaulttype = SettingsGet ($setefidefaulttype)
	$celevel        = SettingsGet ($setefideployed)
	CommonSetupSysLines    ($celevel)
	CommonWriteLog ("    " & $syslineos)
	If $prevgrubinfo  <> "" Then CommonWriteLog ("    Running " & $prevgrubinfo)
	If $syslinesecure <> "" Then CommonWriteLog ("    "         & $syslinesecure)
	CommonWriteLog ("    " & $syslinepath, Default, "")
	CommonWriteLog ("    " & $langline1, Default, "")
	If $langline2 <> "" Then CommonWriteLog ("    " & $langline2, Default, "")
	If $langline3 <> "" Then CommonWriteLog ("    " & $langline3, Default, "")
	If $langline4 <> "" Then CommonWriteLog ("    " & $langline4, Default, "")
	If StringInStr (FileGetAttrib ($masterpath), "C") Then UnCompressIt ()
	If @Compiled And $statremote = "" Then CommonEndit ("Failed", "", "Insecure")
EndFunc

Func UnCompressIt ()
	CommonWriteLog ("    The Grub2Win base directory  " & $masterpath & "  is compressed.")
	$ucmsg  = "The Grub2Win base directory  " & $masterpath & "  is compressed."    & @CR & @CR
	$ucmsg &= "               Compression is not recommended !"                   & @CR & @CR & @CR & @CR
	$ucmsg &= 'Click "Yes" to uncompress  ' & $masterpath & '  or "No" to continue'
	If CommonQuestion ($mbwarnyesno, "*** Compression Warning ***", $ucmsg) Then _
		CommonRunBat  ($sourcepath & "\xxuncompress.txt", "Grub2Win.UnCompress.bat")
EndFunc