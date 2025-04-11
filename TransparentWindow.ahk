#Requires AutoHotkey v2.0
#SingleInstance Force
; #NoTrayIcon
OnExit(Cleanup)
CoordMode "ToolTip", "Window"

/* ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___
  | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
  | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
  |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/

fadePercent := 15 ; default=20 percent. Approximate. Percent opacity after fading, where 0 means invisible, 100 means no fading at all
fadeSpeed := 15 ; default=15 milliseconds. Approximate. Fading occurs over about this many milliseconds

/* ___ ___  ___   ___ ___    _   __  __
  | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
  |  _/   / (_) | (_ \   / / _ \| |\/| |
  |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/
; Using objects in the array to store both handle and state
windowArray := []
fadeTo := Round(255 * (fadePercent / 100))
fadeMax := Max(fadeTo, 1)
fadeStep := Round((255 - fadeTo) / fadeSpeed)

; Function to check if a window is already in our array
IsWindowInArray(windowHandle) {
    for index, windowObj in windowArray {
        if (windowObj.handle = windowHandle)
            return index
    }
    return 0
}

; Function to show tooltip at the top-left corner of the window
ShowWindowTooltip(message, windowHandle) {
    try {
        ; Get window position
        ; WinGetPos(&x, &y, , , "ahk_id " windowHandle)

        ; Show tooltip at window's top-left corner (with small offset)
        ToolTip(message, 10, 10)

        ; Hide tooltip after 2 seconds
        SetTimer(() => ToolTip(), -2000)
    } catch {
        ; Fallback to default tooltip if window position can't be determined
        ToolTip(message)
        SetTimer(() => ToolTip(), -2000)
    }
    SoundPlay "*32"
}

; Function to update transparency for all windows in the array
UpdateTransparency() {
    try {
        activeWindow := WinGetID("A")
    } catch {
        activeWindow := 0
    }

    i := 1
    while (i <= windowArray.Length) {
        try {
            windowObj := windowArray[i]

            if (windowObj.handle = activeWindow) {
                ; Window is active - should be fully visible
                if (windowObj.state = "faded") {
                    ; Need to fade in
                    transVal := fadeTo
                    while (transVal < 255) {
                        WinSetTransparent(transVal, "ahk_id " windowObj.handle)
                        transVal += fadeStep
                        Sleep(1)
                    }
                    WinSetTransparent('', "ahk_id " windowObj.handle)
                    windowObj.state := "showing"
                }
                ; Otherwise already showing, do nothing
            } else {
                ; Window is inactive - should be faded
                if (windowObj.state = "showing") {
                    ; Need to fade out
                    transVal := 255
                    while (transVal > fadeTo) {
                        WinSetTransparent(transVal, "ahk_id " windowObj.handle)
                        transVal -= fadeStep
                        Sleep(1)
                    }
                    WinSetTransparent(fadeMax, "ahk_id " windowObj.handle)
                    windowObj.state := "faded"
                }
                ; Otherwise already faded, do nothing
            }
            i++
        } catch {
            ; Window doesn't exist anymore, remove it from our array
            windowArray.RemoveAt(i)
            ; Don't increment i since we've removed an element
        }
    }
}

; Set up a timer to check active window and update transparency regularly
SetTimer(UpdateTransparency, 100)

; F16 hotkey to toggle the current window in/out of the array
F16:: ToggleCurrentWindow()

ToggleCurrentWindow() {
    try {
        currentWindow := WinGetID("A")

        ; Check if window is already in array
        existingIndex := IsWindowInArray(currentWindow)

        if (existingIndex) {
            ; Remove window from array
            windowArray.RemoveAt(existingIndex)

            ; Reset transparency to 100% when removing from tracking
            WinSetTransparent('', "ahk_id " currentWindow)

            ShowWindowTooltip("Window removed from transparency management", currentWindow)
        } else {
            ; Add window to array with initial state "showing" (since it's active)
            windowArray.Push({ handle: currentWindow, state: "showing" })

            ShowWindowTooltip("Window added to transparency management", currentWindow)
        }

        ; Immediately update transparencies
        UpdateTransparency()
    } catch as err {
        ToolTip("Error: " err.Message)
        SetTimer(() => ToolTip(), -3000)
    }
}

Cleanup(ExitReason, ExitCode) {
    Critical()
    SetTimer(UpdateTransparency, 0)
    for index, windowObj in windowArray {
        try {
            WinSetTransparent('', "ahk_id " windowObj.handle)
        } catch {
            ; Ignore errors during cleanup
        }
    }
}
