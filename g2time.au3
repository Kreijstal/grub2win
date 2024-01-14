#include-once
#include <g2basefunc.au3>
#include <xxSpecialSecure.au3>

Const  $todaydate        = TimeFormatDate     ("", @YEAR & @MON & @MDAY)
Const  $todayjul         = StringLeft         ($todaydate, 7)
Const  $nyzuluoffset     = TimeNYZuluOffset   ()   ; Adjust if needed in 2024
Const  $upticks          = TimeGetUpTicks     ()
Const  $bootstamp        = TimeGetBootStamp   ()
Const  $zulupacket       = SpecFuncZuluPacket ()

Func TimeGetCurrent ($gczulunet = "")
	$gcholdsec   = @SEC
	$gczulutime  = ""
	$gczulutag   = _Date_Time_GetSystemTime ()
	$gczuluos    = _Date_Time_SystemTimeToDateTimeStr ($gczulutag, 1)
	If $gczulunet <> "" Then $gczulutime = TimeGetZulu ()
	If $gczulutime = "" Then $gczulutime = $gczuluos
	;MsgBox ($mbontop, "Zulu", $gczulutime)
	$gczulutime  = StringReplace ($gczulutime, "/", "")
	TimeBuild ($gczulutime, "yes", $gcholdsec)
	TimeBuild ($gczulutime, "",    $gcholdsec)
EndFunc

Func TimeFormatSeconds ($fstimeinit = "", $fsdiff = "")
	If $fsdiff = "" Then $fsdiff = TimeTickDiff ($fstimeinit)
	$fsline = StringFormat ("%.1f", $fsdiff / 1000)
	If $fsdiff < 100 Then $fsline = StringFormat ("%.2f", $fsdiff / 1000)
	$fssec  = "Seconds"
	If $fsdiff < 2000 Then $fssec = "Second"
	$fsreturn = $fsline & " " & $fssec
	Return $fsreturn
EndFunc

Func TimeFormatTicks ($ftmilsecs)
	If $ftmilsecs < 1000 Then Return TimeFormatSeconds ("", $ftmilsecs)
	Local $fthours, $ftmins, $ftsecs, $ftout
	_TicksToTime ($ftmilsecs, $fthours, $ftmins, $ftsecs)
	$ftdays  = Int ($fthours / 24)
	$fthours = Mod ($fthours,  24)
	If $ftdays  > 0 Then $ftout &= $ftdays  & " Days "
	If $fthours > 0 Then $ftout &= $fthours & " Hours "
	If $ftmins  > 0 Then $ftout &= $ftmins  & " Minutes "
	If $ftsecs  > 0 Then $ftout &= $ftsecs  & " Seconds"
	If $ftdays  = 1 Then $ftout = StringReplace($ftout, "Days",    "Day")
	If $fthours = 1 Then $ftout = StringReplace($ftout, "Hours",   "Hour")
	If $ftmins  = 1 Then $ftout = StringReplace($ftout, "Minutes", "Minute")
	If $ftsecs  = 1 Then $ftout = StringReplace($ftout, "Seconds", "Second")
	Return $ftout
EndFunc

Func TimeFormatDays ($fdindays, $fdshowday = "yes", $fdago = " Ago")
	If $fdindays = 0 And $fdshowday <> "" Then Return "** Today **"
	If $fdindays = 1 And $fdshowday <> "" Then Return "** Yesterday **"
	$fdout    =  ""
	$fdyears  =  Int ($fdindays / 365.25)
	$fdindays -= Int ($fdyears  * 365.25)
	$fdmonths =  Int ($fdindays / 30.5)
	$fdindays -= Int ($fdmonths * 30.5)
	If $fdyears  > 0 Then $fdout &= $fdyears  & " Years "
	If $fdmonths > 0 Then $fdout &= $fdMonths & " Months "
	If $fdindays > 0 Then $fdout &= $fdindays & " Days"
	If $fdyears  = 1 Then $fdout = StringReplace($fdout, "Years",  "Year")
	If $fdmonths = 1 Then $fdout = StringReplace($fdout, "Months", "Month")
	If $fdindays = 1 Then $fdout = StringReplace($fdout, "Days",   "Day")
	Return $fdout & $fdago
EndFunc

Func TimeLine ($tljuldate = "", $tltime = "", $tllanglocal = "no", $tlshowdayname = "yes", $tlshowtime = "yes")
	If $tljuldate = "" Then $tljuldate = Int (_DateToDayValue (@YEAR, @MON, @MDAY)) + 1
	If $tltime    = "" Then $tltime    = @HOUR & ":" & @MIN & ":" & @SEC
	Local $tlyear, $tlmonth, $tlday
	_DayValueToDate (Int ($tljuldate), $tlyear, $tlmonth, $tlday)
	$tllocaleday       = Mod (_DateToDayOfWeek ($tlyear, $tlmonth, $tlday) + 5, 7)
	$tlday             = StringFormat ("%.1d", $tlday)
	If $tllanglocal = "yes" Then
		$tldayname     = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, Dec (Hex ($LOCALE_SDAYNAME1))   + $tllocaleday) & "  "
		$tlmonthname   = _WinAPI_GetLocaleInfo ($LOCALE_USER_DEFAULT, Dec (Hex ($LOCALE_SMONTHNAME1)) - 1 + $tlmonth)
	Else
		$tldayname     = _DateDayOfWeek (Mod ($tllocaleday + 1, 7) + 1, 0) & "  "
		$tlmonthname   = _DateToMonth   ($tlmonth, 0)
		$tltime        = TimeAMPM  ($tltime)
	EndIf
	$tltime            = "  at  " & $tltime
	$tlstring          = $tlday & " " & BaseFuncCapIt ($tlmonthname) & " " & $tlyear
	If $dateformat     = "M/d/yyyy" Or $dateformat = "" Or $tllanglocal <> "yes" Then _
		$tlstring      = BaseFuncCapit ($tlmonthname) & " " & $tlday & ", " & $tlyear
	If $tlshowdayname  = "" Then $tldayname = ""
	If $tlshowtime     = "" Then $tltime    = ""
	Return BaseFuncCapit ($tldayname) & $tlstring & $tltime
EndFunc

Func TimeFormatDate ($fdjul = "", $fddate = "", $fdtime = "", $fdtype = "", $fdlanglocal = "no")
	If $fdtime = "" Then $fdtime = @HOUR & @MIN & @SEC
	$fddate  = StringReplace ($fddate, "/", "")
	$fdtime  = StringReplace ($fdtime, ":", "")
	$fdyear  = StringLeft ($fddate, 4)
	$fdmonth = StringMid  ($fddate, 5, 2)
	$fdday   = StringMid  ($fddate, 7, 2)
	$fdhour  = StringLeft ($fdtime, 2)
	$fdmin   = Stringmid  ($fdtime, 3, 2)
	$fdsec   = Stringmid  ($fdtime, 5, 2)
	If $fdjul  = "" Then $fdjul = Int (_DateToDayValue ($fdyear, $fdmonth, $fdday)) + 1
	If $fdjul  < $julearly Then $fdjul = $julearly
	If $fddate = "" Then _DayValueToDate (Number (StringLeft ($fdjul, 7)), $fdyear, $fdmonth, $fdday)
	$fdtime = $fdhour & ":" & $fdmin   & ":" & $fdsec
	$fdreturn = TimeLine ($fdjul, $fdtime, $fdlanglocal)
	Select
		Case $fdtype = ""
			$fdreturn = Int ($fdjul) & "-" & $fdhour & $fdmin & $fdsec & " - " & $fdreturn
		Case $fdtype = "daydate"
			$fdloc    = StringInStr ($fdreturn, " at ")
			$fdreturn = StringLeft  ($fdreturn, $fdloc)
		Case $fdtype = "stamp"
			$fdreturn = $fdyear & " - " & $fdmonth & $fdday & " - " & $fdhour & $fdmin & $fdsec
		Case $fdtype = "juldatetime"
			$fdreturn = $fdjul & "-" & $fdhour & $fdmin & $fdsec & " - " & StringStripWS ($fdreturn, 7)
	EndSelect
	Return $fdreturn
EndFunc

Func TimeAMPM ($taptime)
	$taptime = StringReplace ($taptime, ":", "")
	$taphour = StringLeft    ($taptime, 2)
	$tapampm = "AM"
	If $taphour > 11 Then
		$tapampm = "PM"
		$taphour -= 12
	EndIf
	If $taphour = 0 Then $taphour = 12
	$taphour    = StringFormat ("%.1d", $taphour)
	$tapstring  = $taphour & ":" & StringMid ($taptime, 3, 2) & ":" & StringRight ($taptime, 2)
	Return $tapstring & " " & $tapampm
EndFunc

Func TimeNY ($tnutcstamp)
	$tnyear = StringLeft ($tnutcstamp,  4)
	$tnmon  = StringMid  ($tnutcstamp,  5, 2)
	$tnday  = StringMid  ($tnutcstamp,  7, 2)
	$tnhour = StringMid  ($tnutcstamp,  9, 2)
	$tnmin  = StringMid  ($tnutcstamp, 11, 2)
	$tnsec  = StringMid  ($tnutcstamp, 13, 2)
	$tnhour -= $nyzuluoffset
	TimeFix ($tnyear, $tnmon, $tnday, $tnhour, $tnmin)
	Return $tnyear & $tnmon & $tnday & $tnhour & $tnmin & $tnsec
EndFunc

Func TimeFix (ByRef $tfyear, ByRef $tfmon, ByRef $tfday, ByRef $tfhour, ByRef $tfmin)
	$tfjul  = Int (_DateToDayValue ($tfyear, $tfmon, $tfday)) + 1
	If $tfmin > 59 Then
		$tfhour +=  1
		$tfmin  -= 60
	EndIf
	If $tfmin < 0 Then
		$tfhour -=  1
		$tfmin  += 60
	EndIf
	If $tfhour > 23 Then
		$tfjul  +=  1
		$tfhour -= 24
	EndIf
	If $tfhour < 0 Then
		$tfjul  -=  1
		$tfhour += 24
	EndIf
	$tfmin  = StringFormat ("%02i", $tfmin)
	$tfhour = StringFormat ("%02i", $tfhour)
	_DayValueToDate ($tfjul, $tfyear, $tfmon, $tfday)
	;MsgBox ($mbontop, "Fix Local " & @HOUR, $tfjul & @CR & $tfhour & " " & $tfmin & @CR & $timeoffhours & @CR & $loctimeline)
	Return $tfjul
EndFunc

Func TimeBuild ($btstring, $btnyline, $btholdsec)
	$btstring    = StringReplace ($btstring, "-", "")
	$btstring    = StringReplace ($btstring, ":", "")
	$btstring    = StringStripWS ($btstring, $STR_STRIPALL)
	$btdate      = StringLeft    ($btstring, 8)
	$bttime      = StringMid     ($btstring, 9, 4) & $btholdsec
	$btyear      = Stringleft    ($btdate,   4)
	$btmon       = StringMid     ($btdate,   5, 2)
	$btday       = StringRight   ($btdate,   2)
	$bthour      = StringLeft    ($bttime,   2)
	$btmin       = StringMid     ($bttime,   3, 2)
	$localsec    = StringRight   ($bttime,   2)
	If $btnyline <> "" Then
		$nyhour        = StringFormat ("%02i", $bthour - $nyzuluoffset)
		$nyjulian      = TimeFix  ($btyear, $btmon, $btday, $nyhour, $btmin)
		$zulutimeline  = TimeFormatDate ("", $btdate, $bttime, "datetime",  "yes")
		$zulutimeus    = TimeFormatDate ("", $btdate, $bttime, "datetime")
		$nytimeus      = TimeLine ($nyjulian, $nyhour & ":" & $btmin & ":" & $localsec)
		$nytimestamp   = TimeFormatDate ($nyjulian, "", $nyhour & $btmin & $localsec, "stamp")
		$nytimefulljul = TimeFormatDate ($nyjulian, "", $nyhour & $btmin & $localsec, "juldatetime")
		TimeGetGenDate ($nyjulian, "yes")
	Else
		TimeOffset ()
		$localhour   = $bthour + $timeoffhours
		$localmin    = $btmin  + $timeoffmins
		$localjul    = TimeFix  ($btyear, $btmon, $btday, $localhour, $localmin)
		$loctimeline = TimeFormatDate ($localjul, "", $localhour & $localmin & $localsec, "datetime")
		;MsgBox ($mbontop, "Local", Int (_DateToDayValue ($btyear, $btmon, $btday)) & @CR & $bthour & @CR & $loctimeline)
	EndIf
EndFunc

Func TimeGetGenDate ($gdnyjul = $nyjulian, $gdforce = "")
	If $genstampdisp <> "" And $gdforce = "" Then Return
	$gendatefull  = TimeFormatDate ("", StringLeft ($basgenstamp, 8), StringMid ($basgenstamp, 9, 6))
	$gendatejul   = StringLeft      ($gendatefull, 7)
	$gendateage   = StringLeft      ($gdnyjul, 7) - $gendatejul
	$gendatedisp  = StringTrimLeft  (StringTrimRight ($gendatefull, 13), 17)
	$gendatetime  = StringRight     ($gendatefull, 13)
	$genstampdisp = StringLeft      ($basgenstamp, 4) & " - "        & StringMid ($basgenstamp, 5, 4) & " - " & _
     				StringMid       ($basgenstamp, 9, 6) &	"      " & "Build " & $basrelbuild & "   " & TimeFormatDays ($gendateage, "yes")
EndFunc

Func TimeOffset ()
	If $geotimeoffset = $unknown Then
		$timeoffhours = $altoffsethours
		$timeoffmins  = $altoffsetmins
	Else
		$timeoffhours = StringFormat ("%+d", Int ($geotimeoffset / 3600))
		$timeoffmins  = Int (Mod ($geotimeoffset, 3600) / 60)
	EndIf
	Return        "( " & $timeoffhours & ":" & StringFormat ("%02i", Abs ($timeoffmins)) & " )"
EndFunc

Func TimeNYZuluOffset ()
	Return 5              ; Adjust in 2024 if needed
	$nzoffset = 5
	Select
		Case @YEAR = 2024 And  @YDAY > 69 And @yday < 308
			$nzoffset = 4
	EndSelect
	Return $nzoffset
EndFunc

Func TimeGetUpTicks ()
	$gudata = DllCall ('kernel32.dll', 'uint64', 'GetTickCount64')
	If IsArray ($gudata) Then
		$guticks = $gudata [0]
	Else
		$guticks = _Date_Time_GetTickCount ()
	EndIf
	Return $guticks
EndFunc

Func TimeGetBootStamp ()
	$bssec   = Int ($upticks / 1000) * -1
	$bsboot  = _DateAdd('s', $bssec, _NowCalc())
	$bsstamp = TimeFormatDate ("", StringLeft ($bsboot, 10), StringRight ($bsboot, 8), "juldatetime", "")
	;MsgBox ($mbontop, "Boot " & $bssec, $bsboot & @CR & $bsstamp)
	Return $bsstamp
EndFunc

Func TimeJulStamp ($jsin)
	$jsout = StringLeft ($jsin, 7) & StringMid ($jsin, 9, 6)
	Return $jsout
EndFunc

Func TimeTickInit ()
	Return _TimeToTicks (@HOUR, @MIN, @SEC) + @MSEC
EndFunc

Func TimeTickDiff ($tdinit)
	$tdcurrent = TimeTickInit ()
	Return Abs ($tdcurrent - $tdinit)
EndFunc

Func TimeGetInfo (ByRef $giarray)
	If $giarray [$iStamp] = "" Then
		$gistamp             = FileGetTime    ($giarray [$iPath], $FT_MODIFIED, $FT_STRING + $FT_UTC)
		If @error Then Return
		$giarray [$iStamp]   = TimeNY ($gistamp)
	EndIf
	$giarray [$iJul]     = Int (_DateToDayValue _
		(StringLeft ($giarray [$iStamp], 4), StringMid ($giarray [$iStamp], 5, 2), StringMid ($giarray [$iStamp], 7, 2))) + 1
	$giarray [$idate]    = TimeLine ($giarray [$iJul], "", "no", "", "")
	$giarray [$iTime]    = TimeAMPM (StringRight ($giarray [$iStamp], 6))
EndFunc

Func TimeGetZulu ()
	SecureCheck ()
	If $statremote = "" Then
		$statuszulu = "Zulu Load Failed - Source"
		Return ""
	EndIf
	$gzinit     = TimeTickInit ()
   	TCPStartup ()
	UDPStartup ()
	$gztry      = ""
	$gzdata     = ""
	$gzipaddr   = $zuluiparray [0]
	For $gzaddrsub = 0 To 3
		If $zuluiparray [$gzaddrsub] = "" Then
			$gzipaddr = TCPNameToIP ($gzaddrsub & "." & $urlntpsite)
			If @error Then $gzipaddr = ""
		EndIf
		If $gzipaddr = "" Then ContinueLoop
		$gzdata = TimeGetZuluData ($gzipaddr)
		$gztry  = @extended
		If $gzdata <> "" Then ExitLoop
	Next
	TCPShutdown ()
	;_ArrayDisplay ($zuluiparray, $gzaddrsub)
	$gzseconds = TimeFormatSeconds ($gzinit)
	If $gzdata = "" Or StringInStr ($gzdata, "<") Then
		$statuszulu = "Zulu Load Failed " & $gzseconds
		Return ""
	EndIf
	$gzvalue = SpecFuncTimeHexToDecimal (StringMid ($gzdata, 83, 8))
	$gzutc   = _DateAdd ("s", $gzvalue, "1900/01/01 00:00:00")
	If $statuszulu = "" Then $statuszulu = "Zulu Load " & $gzseconds
	;MsgBox ($mbontop, "Zulu", $gzutc & @CR & "Tries " & $gztry & @CR & "Addresses " & $gzaddrsub + 1 & @CR & $zuluiparray [0])
	Return $gzutc
EndFunc

Func TimeGetZuluData ($zdipaddr)
	$zdsocket = UDPOpen ($zdipaddr, 123)
	UDPSend ($zdsocket, $zulupacket)
	For $zdtry = 1 To 4
		$zddata = UDPRecv ($zdsocket, 100)
		; If $zdipaddr = $zuluiparray [0] Then $sdata = "" ; For Testing
		If $zddata <> "" Then
			$zdloc = _ArraySearch ($zuluiparray, $zdipaddr)
			If @error Then
				_ArrayPush ($zuluiparray, $zdipaddr, 1)
			ElseIf $zdloc > 0 Then
				$zuluiparray [$zdloc] = $zuluiparray [0] = $zuluiparray [$zdloc]
				$zuluiparray [$zdloc] = $zdipaddr
			EndIf
			ExitLoop
		EndIf
		Sleep (250)
	Next
	UDPCloseSocket ($zdsocket)
	SetExtended    ($zdtry)
	Return          $zddata
EndFunc