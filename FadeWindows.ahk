#Requires AutoHotkey v2.0
#SingleInstance Force
; #NoTrayIcon
Persistent()
InstallMouseHook()
SetTitleMatchMode(2)
OnExit(Cleanup)
CoordMode "ToolTip", "Window"
CoordMode "Mouse", "Screen"

/* ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___
  | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
  | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
  |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/
fadeWait := 25    ; default=25 milliseconds. How long the mouse must be stationary before windows fade in
fadeSpeed := 15   ; default=15 milliseconds. Approximate. Fading occurs over about this many milliseconds
fadePercent := 15 ; default=15 percent. Approximate. Percent opacity after fading, where 0 means invisible, 100 means no fading at all
mouseCheck := 10  ; default=10 milliseconds. How often to check mouse position
desktopClass := "WorkerW" ; name of the desktop window class, usually 'WorkerW' or 'Progman'

/* ___ ___  ___   ___ ___    _   __  __
  | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
  |  _/   / (_) | (_ \   / / _ \| |\/| |
  |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/
; -----Initialize vars-----
; Using objects in the array to store both handle and state
windowArray := []
fadeTo := Round(255 * (fadePercent / 100))
fadeMax := Max(fadeTo, 1)
fadeStep := Round((255 - fadeTo) / fadeSpeed)

; Global state for fading - only two states: "active" or "stopped"
fadingActive := true

; Find and store desktop window
desktop := WinExist("ahk_class " desktopClass)
if !desktop {
    MsgBox("Could not find desktop window. Check desktopClass variable.")
    ExitApp()
}

; Add desktop to window array with special state
windowArray.Push({ handle: desktop, state: "showing", isDesktop: true })

OnMessage(0x5555, listener)
SetTimer(CheckWindows, mouseCheck)

; Function to check if a window is already in our array
IsWindowInArray(windowHandle) {
    for index, windowObj in windowArray {
        if (windowObj.handle = windowHandle)
            return index
    }
    return 0
}

GetDesktopWindowObj() {
    for index, windowObj in windowArray {
        if (windowObj.isDesktop)
            return windowObj
    }
}

; Function to show tooltip at the top-left corner of the window
ShowWindowTooltip(message, windowHandle, adding := true) {
    try {
        ToolTip(message, 10, 10)
        SetTimer(() => ToolTip(), -2000)
    } catch {
        ToolTip(message)
        SetTimer(() => ToolTip(), -2000)
    }
    if (adding) {
        SoundPlay "*32"
    } else {
        SoundPlay "*64"
    }
}

; Main function to check all windows and update their state
CheckWindows() {
    global windowArray, fadingActive

    ; don't fade if inactive, if the mouse hasn't moved for over 1 second, or if the mouse is still moving (per fadeWait)
    if (!fadingActive || A_TimeIdle > 1000 || A_TimeIdle < fadeWait)
        return

    ; Get current mouse position and window under mouse
    MouseGetPos(&mx, &my, &mouseWin)

    ; Get active window
    try {
        activeWin := WinGetID("A")
    } catch {
        activeWin := 0
    }

    ; For desktop handling, determine if desktop is directly under mouse
    isMouseOverDesktop := false
    try {
        mouseWinClass := WinGetClass("ahk_id " mouseWin)
        if (mouseWinClass = "WorkerW" || mouseWinClass = "Progman")
            isMouseOverDesktop := true
    } catch {
        ; Ignore errors
    }

    ; Process each window in our array
    i := 1
    while (i <= windowArray.Length) {
        try {
            windowObj := windowArray[i]

            ; Skip if window doesn't exist anymore (except desktop)
            if (!WinExist("ahk_id " windowObj.handle)) {
                if (!windowObj.isDesktop)
                    windowArray.RemoveAt(i)
                else
                    i++
                continue
            }

            ; Determine if this window should be visible
            shouldBeVisible := false

            ; Case 1: Window is active
            if (windowObj.handle = activeWin)
                shouldBeVisible := true

            ; Case 2: Mouse is over this window
            else {
                ; For desktop
                if (windowObj.isDesktop) {
                    ; Desktop is visible if mouse is over it or no window is active
                    try {
                        activeClass := WinGetClass("A")
                        if (isMouseOverDesktop || activeClass = "" || activeClass = "WorkerW") {
                            shouldBeVisible := true
                        }
                    } catch {
                        ; Default to visible if error, which it WILL error if the user clicks on an icon on the desktop while the desktop hasn't been active
                        shouldBeVisible := true
                    }
                }
                ; For regular windows
                else if (windowObj.handle = mouseWin) {
                    ; Need to check if mouse position is stable for faded windows
                    if (windowObj.state = "faded") {
                        MouseGetPos(&mx2, &my2, &mouseWin2)
                        if (mx = mx2 && my = my2 && mouseWin = mouseWin2)
                            shouldBeVisible := true
                    } else {
                        shouldBeVisible := true
                    }
                }
            }

            ; Update window transparency based on shouldBeVisible
            if (shouldBeVisible && windowObj.state = "faded")
                FadeWindowIn(windowObj)
            else if (!shouldBeVisible && windowObj.state = "showing")
                FadeWindowOut(windowObj)

            i++
        } catch as err {
            ; MsgBox("Error in CheckWindows: " err.Message)
            i++
        }
    }
}

; Fade a window in (increase opacity to 100%)
FadeWindowIn(windowObj) {
    global fadeTo, fadeStep, fadingActive

    if (!fadingActive)
        return

    try {
        transVal := fadeTo
        while (transVal < 255 && fadingActive) {
            WinSetTransparent(transVal, "ahk_id " windowObj.handle)
            transVal += fadeStep
            Sleep(1)
        }
        WinSetTransparent('', "ahk_id " windowObj.handle)
        windowObj.state := "showing"
    } catch {
        ; Ignore errors during fading
    }
}

; Fade a window out (decrease opacity to fadeTo value)
FadeWindowOut(windowObj) {
    global fadeTo, fadeStep, fadeMax, fadingActive

    if (!fadingActive)
        return

    try {
        transVal := 255
        while (transVal > fadeTo && fadingActive) {
            WinSetTransparent(transVal, "ahk_id " windowObj.handle)
            transVal -= fadeStep
            Sleep(1)
        }
        WinSetTransparent(fadeMax, "ahk_id " windowObj.handle)
        windowObj.state := "faded"
    } catch {
        ; Ignore errors during fading
    }
}

/* ______  ___  _____________________  _  ______
  / __/ / / / |/ / ___/_  __/  _/ __ \/ |/ / __/
 / _// /_/ /    / /__  / / _/ // /_/ /    /\ \
/_/  \____/_/|_/\___/ /_/ /___/\____/_/|_/___/
*/

; F16 hotkey to toggle the current window in/out of the array
F16:: ToggleCurrentWindow()

ToggleCurrentWindow() {
    global desktopClass

    try {
        currentWindow := WinGetID("A")

        ; Check if window is the desktop - don't allow toggle
        ; windowArray.Push({ handle: desktop, state: "showing", isDesktop: true })
        currentClass := WinGetClass("ahk_id " currentWindow)
        if (currentClass = desktopClass) {
            ; check if desktopClass is broken
            desktopObj := GetDesktopWindowObj()
            if (!WinExist("ahk_id " desktopObj.handle)) {
                desktopHandle := WinExist("ahk_class " desktopClass)
                desktopObj.handle := desktopHandle
                ShowWindowTooltip("Desktop handle was corrupted, re-adding...", currentWindow)
            } else {
                ShowWindowTooltip("Desktop transparency is managed automatically", currentWindow)
            }
            return
        }

        ; Check if window is already in array
        existingIndex := IsWindowInArray(currentWindow)

        if (existingIndex) {
            ; Remove window from array
            windowArray.RemoveAt(existingIndex)

            ; Reset transparency to 100% when removing from tracking
            WinSetTransparent('', "ahk_id " currentWindow)

            ShowWindowTooltip("Window removed from transparency management", currentWindow, false)
        } else {
            ; Add window to array with initial state "showing" (since it's active)
            windowArray.Push({ handle: currentWindow, state: "showing", isDesktop: false })

            ShowWindowTooltip("Window added to transparency management", currentWindow)
        }
    } catch as err {
        ToolTip("Error: " err.Message)
        SetTimer(() => ToolTip(), -3000)
    }
}

listener(wParam, lParam, msg, hwnd) {
    global fadingActive, fadeSpeed, mouseCheck

    if wParam {
        ; Pause transparency management
        SetTimer(CheckWindows, 0)
        fadingActive := false
        Sleep(fadeSpeed)

        ; Restore all windows to full opacity
        for index, windowObj in windowArray {
            try {
                WinSetTransparent('', "ahk_id " windowObj.handle)
                windowObj.state := "showing"
            } catch {
                ; Ignore errors during restoration
            }
        }
    } else {
        ; Resume transparency management
        fadingActive := true
        SetTimer(CheckWindows, mouseCheck)
    }
    return true
}

Cleanup(*) {
    Critical()

    ; Stop timers
    SetTimer(CheckWindows, 0)
    fadingActive := false

    ; Restore all windows to full opacity
    for index, windowObj in windowArray {
        try {
            WinSetTransparent('', "ahk_id " windowObj.handle)
        } catch {
            ; Ignore errors during cleanup
        }
    }

    ExitApp()
}
