#include-once
#include <MsgBoxConstants.au3>
Global  $regkeycpu, $regcountry, $regkeyrestrict
Global  $regcpuname, $regfirm, $regrestrictdata, $regmachguid
Global  $diaguser, $diagpass, $diagremote, $statuser, $statpass, $statremote
Global  $downloadurlquery, $downloadurlvisit, $donateurl, $locationurl, $urlntpsite
Global  $downusername, $downpassword, $ftpserver, $downremotedir, $downsourcesubproj

Func  SecureRestrict      ($srdummy = "")
EndFunc

Func  SecureDiagnostics   ($srdummy = "")
EndFunc

Func  SecureCheckLicensed ($srdummy = "")
EndFunc

Func  SecurePutFTP        ($srdummy = "", $srdummy2 = "")
EndFunc

If StringInStr (@ScriptName, "xxSpecialSecure") Then MsgBox (1, "", "            ** Dummy **", 2)

Func  SecureCheck ()
	If @Compiled Then Return
	$scrc = MsgBox ($IDOK + $IDABORT + $MB_TOPMOST, "SecureCheck", "Status Is Dummy" & @CR & @CR & "Do You Want To Cancel?", 5)
	If $scrc = 6 Or $scrc = -1 Then Exit
EndFunc