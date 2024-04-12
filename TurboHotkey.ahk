; Reference: https://www.overclock.net/forum/375-mice/1453680-razer-naga-real-side-buttons-trick-f13-f24-bound-side-buttons.html
#NoTrayIcon
#Persistent
#SingleInstance Force
#InstallKeybdHook
#InstallMouseHook
SendMode Input
SetKeyDelay, 10

allKeys := ["LButton", "RButton", "MButton", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m", "BS", "Tab", "Enter", "Del", "PgUp", "PgDn", "Shift", "Ctrl", "Space", "Left", "Up", "Down", "Right"]
CoordMode, ToolTip, Screen

#If GetKeyState("F14", "P") || GetKeyState("F15", "P")
for i, key in allKeys {
    Hotkey, %key%, turbo, on
}
return


turbo:
    If GetKeyState("F14") {
        delay := 0
        spd := "Turbo "
    }
    If GetKeyState("F15") {
        delay := 100
        spd := "Slow Turbo "
    }
    while GetKeyState(A_ThisHotkey, "P") {
        ToolTip, % spd A_ThisHotkey "`n" A_Index, 0, 0
        Send, { %A_ThisHotKey% }
        If A_Index > 2000
            break
        Sleep, %delay%
    }
    ToolTip
    Return