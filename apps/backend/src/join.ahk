#SingleInstance force
#MaxMem 1024
myDir := a_scriptdir
FileEncoding, UTF-8

outputFile := % myDir . "\finalfinal.txt"
result := ""


Loop, files, %myDir%\*.ts, R

{

FileRead, aFileContents, %A_LoopFileFullPath% 
result .= aFileContents
ToolTip, % A_Index

}

FileAppend, %result%, %outputFile% 
Msgbox TheEnd
