Func _ExtractZip($sZipFile, $sDestinationFolder, $sFolderStructure = "")

    Local $i
    Do
        $i += 1
        $sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & StringRegExpReplace($sZipFile, ".*\\", "")
    Until Not FileExists($sTempZipFolder) ; this folder will be created during extraction

    Local $oShell = ObjCreate("Shell.Application")

    If Not IsObj($oShell) Then
        Return SetError(1, 0, 0) ; highly unlikely but could happen
    EndIf

    Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
    If Not IsObj($oDestinationFolder) Then
        DirCreate($sDestinationFolder)
;~         Return SetError(2, 0, 0) ; unavailable destionation location
    EndIf

    Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure) ; FolderStructure is overstatement because of the available depth
    If Not IsObj($oOriginFolder) Then
        Return SetError(3, 0, 0) ; unavailable location
    EndIf

    Local $oOriginFile = $oOriginFolder.Items();get all items
    If Not IsObj($oOriginFile) Then
        Return SetError(4, 0, 0) ; no such file in ZIP file
    EndIf

    ; copy content of origin to destination
    $oDestinationFolder.CopyHere($oOriginFile, 20) ; 20 means 4 and 16, replaces files if asked

    DirRemove($sTempZipFolder, 1) ; clean temp dir

    Return 1 ; All OK!

EndFunc

Func checkupdate()
	If IsChecked($chkUpdate) Then
		Local $sFilePath = @TempDir & "\update.dat"

		Local $hMasterVersion = InetGet("https://github.com/MVH4CKS-Official/MVH4CKSBot/blob/master/MVH4CKSBot.au3", $sFilePath, 3)

		If $hMasterVersion = 0 Then
			SetLog(GetLangText("msgFailedVersion"), $COLOR_RED)
		Else
			$hReadFile = FileOpen($sFilePath)
			While True
				$strReadLine = FileReadLine($hReadFile)
				If @error Then ExitLoop
				If StringInStr($strReadLine, "$sBotVersion") Then
					$split = StringSplit($strReadLine, "&quot;", 1)
					SetLog(GetLangText("msgVersionOnline") & $split[2], $COLOR_BLUE)
					If $sBotVersion < $split[2] Then
						SetLog(GetLangText("msgUpdateNeeded"), $COLOR_RED)
						InetGet("https://raw.githubusercontent.com/MVH4CKS-Official/MVH4CKSBot/master/MVCangelog.md", @TempDir & "\MVBotCangelog.md", 3)
						$strReleaseNotes = ""
						$fileopen = FileOpen(@TempDir & "\MVBotCangelog.md")
						If @error Then SetLog(GetLangText("msgFailedVersion"), $COLOR_RED)
						FileReadLine($fileopen)
						FileReadLine($fileopen)
						While True
							$line = FileReadLine($fileopen)
							If @error Then ExitLoop
							If StringLeft($line, 3) = "###" Then
								If StringReplace($line, "### v", "") <= $sBotVersion Then
									ExitLoop
								EndIf
							EndIf
							If StringStripWS($line, 3) <> "" Then SetLog($line)
							$strReleaseNotes = $strReleaseNotes & StringReplace($line, "### ", "") & @CRLF
						WEnd
						FileClose($fileopen)
						FileDelete(@TempDir & "\MVBotCangelog.md")
						If MsgBox($MB_OKCANCEL, GetLangText("boxUpdate"), GetLangText("boxUpdate2") & @CRLF & @CRLF & GetLangText("boxUpdate3") &  @CRLF & @CRLF & GetLangText("boxUpdate5") & @CRLF & @CRLF & GetLangText("boxUpdate6") & @CRLF & @CRLF & $strReleaseNotes, 0, $frmBot) = $IDOK Then
							SetLog(GetLangText("msgDownloading"), $COLOR_GREEN)
							InetGet("https://github.com/MVH4CKS-Official/MVH4CKSBot/blob/master/MVH4CKSBot.zip?raw=true", @TempDir & "\MVH4CKSBot.zip", 3)
							If Not FileExists(@TempDir & "\MVH4CKSBot.zip") Then
								MsgBox(0, "", GetLangText("boxUpdateError"))
							Else
								SetLog(GetLangText("msgUnzipping"), $COLOR_PURPLE)
								If not FileExists(@TempDir & "\TempUpdateFolder") Then
									DirCreate(@TempDir & "\TempUpdateFolder")
								EndIf
								If _ExtractZip(@TempDir & "\MVH4CKSBot.zip", @TempDir & "\TempUpdateFolder") <> 1 Then
									MsgBox(0, "", GetLangText("boxUpdateExtract"))
								Else
									SetLog(GetLangText("msgInstallandRestart"), $COLOR_BLUE)
									_GDIPlus_Shutdown()
									$fileopen = FileOpen(@TempDir & "\MVH4CKS.bat", 2)
									FileWriteLine($fileopen, 'xcopy "' & @TempDir & '\TempUpdateFolder\MVH4CKSBot\*.*" "' & @ScriptDir & '\" /S /E /Y')
									FileWriteLine($fileopen, 'del "' & @TempDir & '\TempUpdateFolder\*.*" /S /Q')
									FileWriteLine($fileopen, 'del "' & @TempDir & '\MVH4CKSBot.zip" /S /Q')
									FileWriteLine($fileopen, 'rd "' & @TempDir & '\TempUpdateFolder" /S /Q')
									FileWriteLine($fileopen, 'start "" /D "' & @ScriptDir & '\" MVH4CKSBot.exe')
									FileClose($fileopen)
									_GUICtrlRichEdit_Destroy($txtLog)
									Run(@ComSpec & ' /c "' & @TempDir & '\MVH4CKS.bat"', @SystemDir, @SW_SHOW)
									Exit
								EndIf
							EndIf
						EndIf
					ElseIf $sBotVersion > $split[2] Then
						SetLog(GetLangText("msgAheadMaster"), $COLOR_PURPLE)
					Else
						SetLog(GetLangText("msgNoUpdateNeeded"), $COLOR_GREEN)
					EndIf
					FileClose($hReadFile)
					FileDelete($sFilePath)
					Return
				EndIf
			WEnd
			SetLog(GetLangText("msgFailedVersion"), $COLOR_RED)
			FileClose($hReadFile)
			FileDelete($sFilePath)
		EndIf
	EndIf
EndFunc   ;==>checkupdate

