
Func checkTownhall()
	_CaptureRegion()
	$sendHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
	$res = DllCall(@ScriptDir & "\images\misc\MVH4CKS.dll", "str", "BrokenBotMatchBuilding", "ptr", $sendHBitmap, "int", 1, "int", 3, "int", 1, "int", 1)
	_WinAPI_DeleteObject($sendHBitmap)
	If IsArray($res) Then
		If $res[0] = -1 Then
			; failed to find TH
			If $DebugMode = 1 Then _GDIPlus_ImageSaveToFile($hBitmap, $dirDebug & "NegTH-" & @HOUR & @MIN & @SEC & ".png")
			$THx = 0
			$THy = 0
			Return "-" ; return 0
		Else
			$res = StringSplit($res[0], "|", 2)
			$THx = $res[1]
			$THy = $res[2]
			If $DebugMode = 1 Then
				$hClone = _GDIPlus_BitmapCloneArea($hBitmap, $THx - 30, $THy - 30, 60, 60, _GDIPlus_ImageGetPixelFormat($hBitmap))
				$j = 1
				Do
					If Not FileExists($dirDebug & "PosTH-x" & $THx & "y" & $THy & " (" & $j & ").jpg") Then ExitLoop
					$j = $j + 1
				Until $j = 1000
				_GDIPlus_ImageSaveToFile($hClone, $dirDebug & "PosTH-x" & $THx & "y" & $THy & " (" & $j & ").jpg")
				_GDIPlus_ImageDispose($hClone)
			EndIf
			If $res[4] < 7 Then
				Return $THText[0]
			Else
				Return $THText[$res[4]-6]
			EndIf
		EndIf
	Else
		SetLog(GetLangText("msgDLLFailure"), $COLOR_RED)
		$DEx = 0
		$DEy = 0
		Return "-" ; return 0
	EndIf
EndFunc   ;==>checkTownhall
