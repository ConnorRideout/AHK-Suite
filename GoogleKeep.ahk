#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
SetTitleMatchMode, 2
OnExit("Cleanup")

/*___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___ 
 | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
 | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
 |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/

        hwAccelOff := True  ; bool. Turning off hardware acceleration in Chrome allows the app text to be clearer when faded (Chrome > Settings > Advanced > System > Use hardware acceleration when available > OFF)
        proxyPath = C:\Program Files (x86)\Google\Chrome\Application\chrome_proxy.exe   ; str. The full path to 'chrome_proxy.exe' (should be in the same directory as 'chrome.exe')
    
    ;  ===================
    ;==== CUSTOMIZATION ====
    ;  ===================
      ;     Variable     |  Value  | Type  |Limits| Description                                        | Notes
      ;==================|=========|=======|======|====================================================|========================================================================================
        askToStart      :=  False  ; bool  | T/F  | If Chrome isn't open, ask before starting          | If Chrome is closed, the previous Chrome session is lost when the app starts
        updateInterval  :=  10     ; int   | 1+   | Update polling interval, in milliseconds           |
        textShadow      :=  0      ; int   | 0+   | Size of the text's shadow                          | 0 = default
      ;=MAKE PRETTY======|=========|=======|======|====================================================|========================================================================================
        winBorder       :=  8      ; int   | 0+   | The window's border (cropped off all sides)        |
        topMargin       :=  27     ; int   | 0+   | Titlebar height (cropped off the top)              |
      ;=APP GEOMETRY=====|=========|=======|======|====================================================|========================================================================================
        appX            :=  1935   ; int   | 0+   | Horizontal position to place the app               |
        appY            :=  300    ; int   | 0+   | Vertical position to place the app                 |
        appW            :=  625    ; int   | 0+   | Width when faded in                                |
        appH            :=  850    ; int   | 0+   | Height when faded in                               |
        rebtn            =x270 y55 ; str   | xn yn| Window coordinates of the refresh button           |
        rounded         :=  True   ; bool  | T/F  | Whether to round the app's corners                 |
      ;=FADING OPTIONS===|=========|=======|======|====================================================|========================================================================================
        opacityShow     :=  9      ; float | 0-10 | Opacity when faded in                              | 0 = invisible | 10 = opaque
        opacityHide     :=  4      ; float | 0-10 | Opacity when faded out                             | 0 = invisible | 10 = opaque
        fSpeed          :=  5      ; int   | 1+   | How fast to fade in Milliseconds                   | 1 = instant
        fStopKey         =  Shift  ; str   | Key  | The key that will prevent fading when held         |
        fBlurFix        :=  True   ; bool  | T/F  | Whether to force deselect everything when faded    | If 'False', if the window is clicked off of while a note is open, visual bugs can occur
        doCrop          :=  True   ; bool  | T/F  | Whether to crop the app when it's faded            |
      ;=CROPPING OPTIONS (Used only when 'doCrop' is True)=============================================|========================================================================================
        fCrop:={"left"   :  90     ; int   | 0+   | Amount to crop the left by when faded out          |
               ,"top"    :  175    ; int   | 0+   | Amount to crop the top by when faded out           |
               ,"right"  :  0      ; int   | 0+   | Amount to crop the right by when faded out         |
               ,"bottom" :  0      ; int   | 0+   | Amount to crop the bottom by when faded out        |
               ,"cHorz"  :  2      ; int   | 0-2  | How to change the app's width when cropped         | 0 = maintain | 1 = center | 2 = shrink
               ,"cVert"  :  0   }  ; int   | 0-2  | How to change the app's height when cropped        | 0 = maintain | 1 = center | 2 = shrink
      ;=DEBUG============|=========|=======|======|====================================================|========================================================================================
        SetWinDelay      ,  -1     ; int   | -1+  | Delay between windowing commands, in milliseconds  | -1 = none | 0 = smallest possible
        SetKeyDelay      ,  50     ; int   | -1+  | Delay between inputs, in milliseconds              | -1 = none | 0 = smallest possible
        blockWhileLoad  :=  True   ; bool  | T/F  | Whether to block user input while starting up      | Only set to 'False' if absolutely necessary. Errors often occur if it's off
      ;=DEVELOPER========|=========|=======|======|====================================================|========================================================================================
       ;---Don't change these unless you know what you're doing!---
        cmdLineArgs     :=  "--profile-directory=Default --app-id=eilembjdkfgodjkcjnpgpaenohkicgjd"
        devWinTitle     :=  "DevTools - keep.google.com"
        txtCmd          :=  "document.body.style.textShadow = ``0px 0px " textShadow "px ${window.getComputedStyle(document.body, null).getPropertyValue(""color"").replace(/\d+/g, n => 255-n)}``"
        bgCmd           :=  "window.getComputedStyle(document.body, null).getPropertyValue(""background-color"")"
        blurCmd         :=  "window.addEventListener('blur', () => {let allEls = document.querySelectorAll('*'); setTimeout(() => allEls.forEach(el => el.blur()), 1000);})"
        winBG           :=  "202124"







/*___ ___  ___   ___ ___    _   __  __ 
 | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
 |  _/   / (_) | (_ \   / / _ \| |\/| |
 |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/

    /* _____________   ___  ________  _____ 
      / __/_  __/ _ | / _ \/_  __/ / / / _ \
     _\ \  / / / __ |/ , _/ / / / /_/ / ___/
    /___/ /_/ /_/ |_/_/|_| /_/  \____/_/    
    */

        ; Verify vars
            for i, var in StrSplit("hwAccelOff,askToStart,updateInterval,textShadow,winBorder,topMargin,appX,appY,appW,appH,rounded,opacityShow,opacityHide,fSpeed,fBlurFix,doCrop,blockWhileLoad", ",") {
                if (var ~= "hwAccelOff|askToStart|rounded|fBlurFix|doCrop|blockWhileLoad") {
                    if not (%var% ~= "^[01]$")
                        errMsg .= Format("`n{} | True or False | {}", var, %var%)
                } else if (var ~= "textShadow|winBorder|topMargin|appX|appY|appW|appH") {
                    if not (%var% ~= "^[\d]+$") or (%var% < 0)
                        errMsg .= Format("`n{} | a non-negative integer | {}", var, %var%)
                } else if (var ~= "updateInterval|fSpeed") {
                    if not (%var% ~= "^[\d]+$") or (%var% < 1)
                        errMsg .= Format("`n{} | a positive integer | {}", var, %var%)
                } else if (var ~= "opacityShow|opacityHide") {
                    if not (%var% ~= "^[\d\.]+$") or (%var% < 0) or (%var% > 10)
                        errMsg .= Format("`n{} | a number between 0 and 10 | {}", var, %var%)
                    if (var = "opacityHide") and (opacityHide > opacityShow)
                        errMsg .= Format("`nopacity | -Show is greater-than/equal-to -Hide | {} & {}", opacityShow, opacityHide)
                }
            }
            if doCrop {
                for k,v in fCrop {
                    if (k ~= "cHorz|cVert") {
                        if not (v ~= "^[012]+$")
                            errMsg .= Format("`nfCrop>{} | an integer between 0 and 2 | {}", k, v)
                        Continue
                    } else if (v < 0) {
                        errMsg .= Format("`nfCrop>{} | a non-negative integer | {}", k, v)
                    } else if v {
                        canCrop := True
                    }
                }
            }
            if (errMsg := SubStr(errMsg, 2)) {
                Gui, Font, s12, Calibri
                Gui, Add, ListView, W450 Grid NoSortHdr NoSort, % "Variable to Fix|Accepted Values|Current"
                Loop, Parse, errMsg, `n
                {
                    err := StrSplit(A_LoopField, " | ")
                    LV_Add("", err*)
                }
                LV_ModifyCol(1, "AutoHdr")
                LV_ModifyCol(2, "AutoHdr")
                LV_ModifyCol(3, "AutoHdr Center")
                Gui, Show, AutoSize Center, % "GoogleKeep.ahk - Variable Error"
                Return
            }
        ; Initialize vars  =====================================================================================
            SetControlDelay -1
            fadedIn := (254 // (10 // opacityShow) + 1)
            fadedOut := (254 // (10 // opacityHide) + 1)
            if canCrop {
                fCrop.x := fCrop.left
                fCrop.y := fCrop.top
                fCrop.w := -(fCrop.left + fCrop.right)
                fCrop.h := -(fCrop.top + fCrop.bottom)
                if (fCrop.cHorz ~= "^[01]$") or (fCrop.cVert ~= "^[01]$")
                    fMove := {"x": (fCrop.cHorz=2 ? 0 : (fCrop.cHorz=1 ? fCrop.w / 2 : -fCrop.x))
                            , "y": (fCrop.cVert=2 ? 0 : (fCrop.cVert=1 ? fCrop.h / 2 : -fCrop.y))
                            , "w": (fCrop.cHorz=0 ? -fCrop.w : 0)
                            , "h": (fCrop.cVert=0 ? -fCrop.h : 0)}
            }
            fStep := (fadedIn - fadedOut) // fSpeed
            viewRgn := { "x": winBorder
                        ,"y": winBorder + topMargin
                        ,"w": appW
                        ,"h": appH}
            winGeo :=  { "x": appX - winBorder
                        ,"y": appY - winBorder - topMargin
                        ,"w": appW + winBorder * 2
                        ,"h": appH + winBorder * 2 + topMargin}
            if textShadow or fBlurFix or (hwAccelOff and not winBG)
                oldClip := Clipboard
            WinGet, prevActWin, ID, A
            OnMessage(0x5555, "listener")
        askStart: ;===============================================================================================
            if askToStart and not WinExist("ahk_exe Chrome.exe") {
                MsgBox, 2, % "Warning", % "It looks like Chrome is not running.`nWould you like to open Google Keep anyway?`n(If you had any tabs saved or pinned from a previous session, they will be lost!)"
                IfMsgBox, Abort, ExitApp
                IfMsgBox, Retry, WinWait, % "ahk_exe Chrome.exe",, 10
                if ErrorLevel
                    Goto askStart
            }
        ; Hide any chrome wins titled 'Google Keep'  ==============================================================
            WinGet, oldWins, list, % "Google Keep ahk_exe Chrome.exe"
            Loop % oldWins
                WinClose, % "ahk_id " oldWins%A_Index%
        startGKeep: ;=============================================================================================
            Run, % """" proxyPath """ " cmdLineArgs
            WinWait, % "Google Keep ahk_exe Chrome.exe",, 10
            if ErrorLevel {
                MsgBox, 4, % "Error", % "Couldn't hook Google Keep.`nTry again?"
                IfMsgBox, Yes, Goto startGKeep
                Return
            }
            WinGet, gkeepHwnd, ID, % "Google Keep ahk_exe Chrome.exe"
            appHwnds := [gkeepHwnd]
        ; Format GKeep window  ====================================================================================
            WinRestore, % "Google Keep ahk_exe Chrome.exe"
            WinSet, Style, -0x840000, % "Google Keep ahk_exe Chrome.exe" ; remove window shadow and borders
            WinSet, ExStyle, +0x80, % "Google Keep ahk_exe Chrome.exe" ; make it a toolwindow
            WinMove,% "Google Keep ahk_exe Chrome.exe",, % winGeo.x, % winGeo.y, % winGeo.w, % winGeo.h
            WinSet, Region, % viewRgn.x "-" viewRgn.y " w" viewRgn.w " h" viewRgn.h (rounded ? " R" : ""), % "Google Keep ahk_exe Chrome.exe"
        openDevConsole: ;=========================================================================================
            Sleep 1000
            if textShadow or fBlurFix or (hwAccelOff and not winBG) {
                BlockIn(1)
                WinActivate, ahk_id %gkeepHwnd%
                Send, ^+j
                WinWait, %devWinTitle%,, 10
                if ErrorLevel
                {
                    BlockIn(0)
                    MsgBox, 4, % "Error", % "Couldn't open Dev Console.`nTry again?"
                    IfMsgBox, Yes, Goto openDevConsole
                    ExitApp
                }
                WinGet, devHwnd, ID, %devWinTitle%
                WinSet, Transparent, 0, ahk_id %devHwnd%
            } else {
                Sleep 1000
            }
        if textShadow { ;=========================================================================================
            Clipboard := txtCmd
            Sleep % A_KeyDelay
            WinActivate, ahk_id %devHwnd%
            Send, ^``^v{Enter}
        }
        Sleep 100
        if fBlurFix { ;===========================================================================================
            Clipboard := blurCmd
            Sleep % A_KeyDelay
            WinActivate, ahk_id %devHwnd%
            Send, ^``^v{Enter}
        }
        Sleep 100
        if hwAccelOff { ;=========================================================================================
            ; -----Get GKeep bg color-----
                if not winBG {
                    Clipboard := bgCmd
                    Sleep % A_KeyDelay
                    while not col
                    {
                        WinActivate, ahk_id %devHwnd%
                        Send, ^``^l^v{Enter}
                        Sleep % A_KeyDelay
                        Send, ^``+{Tab}^a^c
                        Sleep % A_KeyDelay
                        RegExMatch(Clipboard, "(\d+), (\d+), (\d+).{0,5}$", col)
                        if A_Index > 5
                        {
                            BlockIn(0)
                            WinClose, ahk_id %devHwnd%
                            MsgBox, 2, % "Error", % "Couldn't get Google Keep background color"
                            IfMsgBox, Abort, ExitApp
                            IfMsgBox, Retry, Goto openDevConsole
                            ignoreBg := True
                        }
                    }
                    winBG := format("{:x}{:x}{:x}", col1, col2, col3)
                    bg := winBG """`n"
                    file := FileOpen(A_ScriptFullPath, "rw")
                    While not (InStr(file.ReadLine(), "winBG")) {
                        Continue
                    }
                    file.Seek(-3, 1)
                    file.WriteLine(bg)
                    file.Close()
                }
            ; -----Create GUI for background-----
                Gui, +HwndguiHwnd +LastFound +ToolWindow -Caption
                if not ignoreBg
                    Gui, Color, % winBG
                Gui, Show, % "x" winGeo.x " y" winGeo.y " w" winGeo.w " h" winGeo.h " NA"
                WinSet, Region, % viewRgn.x "-" viewRgn.y " w" viewRgn.w " h" viewRgn.h (rounded ? " R" : "")
                DllCall("SetWindowLongPtr", "ptr", gkeepHwnd, "int", -8, "ptr", guiHwnd)
                appHwnds.Push(guiHwnd)
            }
        ; Reset changes  ==========================================================================================
            if devHwnd
                WinClose, ahk_id %devHwnd%
            for i,wID in appHwnds
                WinSet, Bottom,, ahk_id %wID%
            if WinExist("ahk_id " prevActWin)
                WinActivate, ahk_id %prevActWin%
            else
                Send, !{Tab}
            BlockIn(0)
            if textShadow or fBlurFix or (hwAccelOff and not winBG)
                Clipboard := oldClip
            fadeWin := (hwAccelOff ? guiHwnd : gkeepHwnd)


    /* ___  __  ___  __
      / _ \/ / / / |/ /
     / , _/ /_/ /    / 
    /_/|_|\____/_/|_/  
    */

        fadeOut:
            while WinActive("ahk_id " gkeepHwnd)
            {
                sleep % updateInterval
                if stop
                    Goto fadeIn
            }
            doFade := !GetKeyState(fStopKey)
            if hwAccelOff
            {
                if doFade
                {
                    ControlClick, %rebtn%, ahk_id %gkeepHwnd%,,,, NA
                    WinSet, Transparent, Off, ahk_id %gkeepHwnd%
                    WinSet, TransColor, %winBG%, ahk_id %gkeepHwnd%
                }
                WinSet, ExStyle, +0x20, ahk_id %gkeepHwnd%
            }
            Loop % fSpeed
            {
                i := A_Index
                if doFade
                    WinSet, Transparent, % (i=fSpeed ? (fadedOut=255 ? "Off" : fadedOut) : fadedIn - i * fStep), ahk_id %fadeWin%
                if doCrop
                {
                    for k,v in viewRgn
                        c%k% := (v + (i * fCrop[k] // fSpeed) + ((fCrop.cHorz=0 and k="w") or (fCrop.cVert=0 and k="h") ? (i * fMove[k] // fSpeed) : 0))
                    if fMove
                        for k,v in winGeo
                            m%k% := (v + (i=fSpeed ? fMove[k] : (i * fMove[k] // fSpeed)))
                    for i,wID in appHwnds
                    {
                        WinSet, Region, % cx "-" cy " w" cw " h" ch (rounded ? " R" : ""), ahk_id %wID%
                        if fMove
                            WinMove, ahk_id %wID%,, % mx, % my, % mw, % mh
                    }
                }
                Sleep 1
            }
            for i,wID in appHwnds
            {
                WinSet, Bottom,, ahk_id %wID%
                sleep 100
                if doCrop
                    WinSet, Region, % viewRgn.x+fCrop.x "-" viewRgn.y+fCrop.y " w" viewRgn.w+fCrop.w+(fCrop.cHorz=0 ? fMove.w : 0) " h" (viewRgn.h+fCrop.h + (fCrop.cVert=0 ? fMove.h : 0)) (rounded ? " R" : ""), ahk_id %wID%
            }

        fadeIn:
            while not WinActive("ahk_id " fadeWin) and not stop
                sleep % updateInterval
            Loop % fSpeed
            {
                i := A_Index
                if doFade
                    WinSet, Transparent, % (i=fSpeed ? (fadedIn=255 ? "Off" : fadedIn) : fadedOut + i * fStep), ahk_id %fadeWin%
                if doCrop
                {
                    for k,v in viewRgn
                        c%k% := (v + fCrop[k] - (i=fSpeed ? fCrop[k] : (i * fCrop[k] // fSpeed)) + ((fCrop.cHorz=0 and k="w") or (fCrop.cVert=0 and k="h") ? (i=fSpeed ? 0 : fMove[k] - (i * fMove[k] // fSpeed)) : 0))
                    if fMove
                        for k,v in winGeo
                            m%k% := (v + fMove[k] - (i=fSpeed ? fMove[k] : (i * fMove[k] // fSpeed)))
                    for i,wID in appHwnds
                    {
                        WinSet, Region, % cx "-" cy " w" cw " h" ch (rounded ? " R" : ""), ahk_id %wID%
                        if fMove
                            WinMove, ahk_id %wID%,, % mx, % my, % mw, % mh
                    }
                }
                Sleep 1
            }
            if hwAccelOff
            {
                WinSet, TransColor, Off, ahk_id %gkeepHwnd%
                WinSet, ExStyle, -0x20, ahk_id %gkeepHwnd%
                WinSet, Transparent, %fadedIn%, ahk_id %gkeepHwnd%
                if not stop
                    WinActivate, ahk_id %gkeepHwnd%
            }
        if stop
            Return
        Goto fadeOut

    /* ______  ___  _____________________  _  ______
      / __/ / / / |/ / ___/_  __/  _/ __ \/ |/ / __/
     / _// /_/ /    / /__  / / _/ // /_/ /    /\ \  
    /_/  \____/_/|_/\___/ /_/ /___/\____/_/|_/___/
    */
        BlockIn(onoff) {
            global blockWhileLoad
            if blockWhileLoad
                PostMessage, 0x5555, %onoff%,,, % "Block_Input.ahk"
            Return
        }

        listener(stopping) {
            global stop := stopping
            if not stop
                SetTimer, fadeOut, -1
            Return
        }

        Cleanup(ExitReason, ExitCode) {
            global gkeepHwnd
            Critical
            PostMessage, 0x5555,,,, % "Block_Input.ahk"
            if WinExist("ahk_id " gkeepHwnd)
            {
                WinClose, ahk_id %gkeepHwnd%
                WinWaitClose, ahk_id %gkeepHwnd%,, 5
                if ErrorLevel
                {
                    WinKill, ahk_id %gkeepHwnd%
                    WinWaitClose, ahk_id %gkeepHwnd%,, 5
                    if ErrorLevel
                        MsgBox, 0, % "Error", % "Couldn't close Google Keep"
                }
            }
            ExitApp
        }
