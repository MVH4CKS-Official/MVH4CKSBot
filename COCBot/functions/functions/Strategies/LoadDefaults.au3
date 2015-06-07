
Func _PluginDefaults()
	$arStrats = StringSplit($StratNames, "|")
	For $i = 1 To $arStrats[0]
		$searchfile = FileFindFirstFile($dirStrat & "*.ini")
		$found = False
		While True
			$newfile = FileFindNextFile($searchfile)
			If @error Then ExitLoop
			$strPlugInRead = IniRead($dirStrat & $newfile, "plugin", "name", "")
			If $strPlugInRead = $arStrats[$i] Then
				$found = True
				ExitLoop
			EndIf
		WEnd
		If Not $found Then
			SetLog(GetLangText("msgNoDataFound") & $arStrats[$i] & GetLangText("msgNoDefaults"))
			Call($arStrats[$i] & "_LoadGUI")
			Call($arStrats[$i] & "_SaveConfig", $dirStrat & $arStrats[$i] & " - default.ini")
			GUIDelete($frmAttackConfig)
		EndIf
		FileClose($searchfile)
	Next
EndFunc   ;==>_PluginDefaults
