#RequireAdmin
#include-once
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Assign   ("downloadmode", "Grub2Win Download", 2)  ; Must appear before any includes
#include <g2network.au3>

Const  $zipdir      = $windowstempgrub & "\Zip"
Global $zippath     = $zipdir          & "\" & $zipmodule

FileDelete            ($statsdatageneric & "*.*")
FileDelete            ($statslog)
LangSetup             ()
TimeGetCurrent        ()
CommonCheckRestrict   ()
DownloadRunGUI        ()
DownloadEndIt         ()

Func DownloadRunGUI ()
	BaseFuncGUIDelete ($upmessguihandle)
	If Not CommonCheckResolution () And Not CommonParms ($parmautoinstall) Then DownloadEndIt ()
	CommonHotKeys  ()
	If Not CommonParms ($parmautoinstall) Then
		$rgmessage  = 'The installer will now download the current GNU Grub'                              & @CR
		$rgmessage &= @TAB & 'and Grub2Win modules for:'                                                  & @CR & @CR & @CR
		$rgmessage &= '       ' & $bootos & "     " & $osbits & " bit     " & $firmwaremode & " firmware" & @CR & @CR & @CR
		$rgmessage &= '       Click "OK" to continue or click "Cancel"'
		$rgheader   = 'G2WInstall                                                                Ver '
		$rgheader  &= $basrelcurr
		$rgrc = MsgBox ($mbinfookcan, $rgheader, $rgmessage)
		If $rgrc <> $IDOK Then DownloadEndIt (2)
	EndIf
	DirCreate ($zipdir)
	$rgrc     = FileInstall ("zip7za.runtime", $zippath)
	If $rgrc  = 0 Then BaseFuncShowError ("** FileInstall Failed **", "DownloadRunGUI")
	$rgparms  = $parmsetup & ' "' & $parmcleanupdir & '=' & @ScriptDir & '"'
	$rgrc = NetFunctionGUI   ("DownloadExtract", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, _
		"GrubInst", "Grub2Win Software", "yes")
	If $rgrc <> "OK" Then DownloadEndIt ()
	BaseFuncSingleWrite ($downloadjulian, $basreljul)
	CommonStatsBuild    ("Download")
	SecureAuth          ("Set", $todayjul)
	NetFunctionGUI      ("Run", $windowstempgrub & "\Download\grubinst", $downsourcesubproj, _
		"GrubInst", "Grub2Win Software", "yes", $rgparms)
EndFunc

Func DownloadEndIt ($eicode = 0)
	BaseFuncCleanupTemp ("DownLoadEndIt", $eicode)
EndFunc