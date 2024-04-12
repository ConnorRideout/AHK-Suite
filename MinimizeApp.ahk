#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

exclude_title := "Messages"
excluded_classes := "WorkerW|Progman|Shell_TrayWnd|Shell_SecondaryTrayWnd|#\d+"

^+m::
{
    proc_name := WinGetProcessName("A")
    for hwnd in WinGetList("ahk_exe " proc_name,, exclude_title) {
        cls := WinGetClass("ahk_id " hwnd)
        if !(RegExMatch(cls, excluded_classes))
            WinMinimize hwnd
    }
}

^m::
{
    cur_hwnd := WinGetID("A")
    proc_name := WinGetProcessName("A")
    for hwnd in WinGetList("ahk_exe " proc_name,, exclude_title) {
        if not (hwnd = cur_hwnd) {
            cls := WinGetClass("ahk_id " hwnd)
            if !(RegExMatch(cls, excluded_classes))
                WinMinimize hwnd
        }
    }
}
