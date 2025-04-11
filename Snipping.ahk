#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
SetWorkingDir, %A_Desktop%
DetectHiddenWindows, On

~!PrintScreen::
    Sleep, 100
    WinGetActiveTitle, winTitle
    winTitle := "screenshot_" . winTitle . ".jpg"
    FileSelect(winTitle)
    Return

~#+s::
    Clipboard = Getting Image
    oldclip := Clipboard
    WinWait, ahk_exe ScreenClippingHost.exe
    WinWaitClose
    i = 0
    while ((oldclip := Clipboard) and A_Index <= 10) {
        Sleep, 200
        i := A_Index
    }
    if (i < 10) {
        FormatTime, TimeString,, 'screensnip_'yyyy-MM-dd-hhmmss'.jpg'
        FileSelect(TimeString)
    } else {
        MsgBox,,, % "Could not get image from clipboard"
        Return
    }

MakeActive:
IfWinNotExist, Save screensnip as, , Return
SetTimer, MakeActive, off
WinMaximize
WinRestore
WinActivate
Return

FileSelect(fileName)
{
    SetTimer, MakeActive, 10
    FileSelectFile, saveas, S, %fileName%, Save screensnip as, JPEG Image (*.jpg)
    if saveas
    {
        savename := RegExReplace(saveas, "i)\.jpg$")
        savename .= ".jpg"
        if (FileExist(savename))
        {
            SplitPath, savename, fname
            MsgBox, 67,, % fname " already exists.`nOverwrite this file?"
            IfMsgBox No
            {
                newFileName := SubStr(savename, 1, -4) " (1).jpg"
                FileSelect(newFileName)
            }
            else IfMsgBox Cancel
            {
                Return
            }
        }
        Run, % "magick clipboard: """ savename """",, Hide
    }
}
