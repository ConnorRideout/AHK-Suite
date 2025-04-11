#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

excluded_titles := "Messages"
excluded_classes := "WorkerW|Progman|Shell_TrayWnd|Shell_SecondaryTrayWnd|#\d+" ; regex
activate_before_min := true

GetHwnds() { ; get all the hwnds of the current process, then return a filtered list
    proc_name := WinGetProcessName("A")
    hwnds := Array()
    for hwnd in WinGetList("ahk_exe " proc_name, , excluded_titles)
        if (WinGetMinMax(hwnd) != -1) ; don't try to minimize already minimized windows
            hwnds.Push(hwnd)
    return hwnds
}

DoMinimize(hwnd) { ; minimize windows, ignoring the exlusions listed above
    cls := WinGetClass("ahk_id " hwnd)
    if !(RegExMatch(cls, excluded_classes)) { ; skip windows that are in the excluded_classes (regex)
        if (activate_before_min) {
            WinActivate hwnd
            Sleep 200
        }
        WinMinimize hwnd
    }
}

; ctrl+shift+m => minimize all windows of the current app
^+m::
{
    for hwnd in GetHwnds()
        DoMinimize(hwnd)
}

; ctrl+m => minimize all windows of the current app EXCEPT the currently active window
^m::
{
    cur_hwnd := WinGetID("A")
    for hwnd in GetHwnds()
        if not (hwnd = cur_hwnd)
            DoMinimize(hwnd)
}
