#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
SetWorkingDir, %A_Desktop%
DetectHiddenWindows, On

~#+s::
    oldclip := Clipboard
    WinWait, ahk_class Windows.UI.Core.CoreWindow
    WinWaitNotActive
    while (!(oldclip := Clipboard) and A_Index <= 10) {
        Sleep, 500
        i := A_Index
    }
    if (i < 10) {
        FormatTime, TimeString,, 'screensnip_'yyyy-MM-dd-hhmmss'.jpg'
        FileSelect:
        FileSelectFile, saveas, S, %TimeString%, Save screensnip as, JPEG Image (*.jpg)
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
                    TimeString := SubStr(savename, 1, -4) " (1).jpg"
                    GoTo FileSelect
                }
                else IfMsgBox Cancel
                {
                    Return
                }
            }
            Run, % "magick clipboard: """ savename """",, Hide
        }
    } else {
        MsgBox,,, % "Could not get image from clipboard"
    }
