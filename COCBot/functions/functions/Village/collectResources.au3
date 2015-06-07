
Func collectResources()
   Local $i, $j = 0
   Local $foundResource = false
   If $ichkCollect = 1 Then
	  SetLog(GetLangText("msgCollecting"), $COLOR_BLUE)
	  Do
		  _CaptureRegion()
		  $sendHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
		  $res = DllCall(@ScriptDir & "\images\misc\MVH4CKS.dll", "str", "BrokenBotMatchBuilding", "ptr", $sendHBitmap, "int", 27, "int", 3, "int", 17, "int", 1)
		  _WinAPI_DeleteObject($sendHBitmap)
		 If IsArray($res) Then
		   If $res[0] = -1 and NOT $foundResource Then
			   ; failed to find Resources
			   SetLog(GetLangText("msgNoResources"), $COLOR_RED)
			   $ResX = 0
			   $ResY = 0
			   ExitLoop
			Else
			   $expRet = StringSplit($res[0], "|")
			   $numBldg = $expRet[0]
			   For $j = 2 To UBound($expRet)  - 1 step 6
				  $ResX = $expRet[$j]
				  $ResY = $expRet[$j+1]
				  Click($ResX, $ResY)
				  Click(1, 1)
				  Sleep(300)
			   Next
			   $foundResource = true
			EndIf
		 Else
			SetLog(GetLangText("msgDLLFailure"), $COLOR_RED)
			$ResX = 0
			$ResY = 0
			Return False ; return 0
		 EndIf
		 $i += 1
	  Until $i = 2
   EndIf
   Return
EndFunc   ;==>checkDarkElix
