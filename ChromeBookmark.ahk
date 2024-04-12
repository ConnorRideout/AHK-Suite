#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
#Include <ToastNotif>
OnExit("Cleanup")
SendMode, Input
SetMouseDelay, -1
SetTitleMatchMode, 2

/* ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___ 
  | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
  | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
  |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/

toastTime := 3000 ; milliseconds. How long a toast notification remains on screen
book1 := "Bookmark added" ; title of first bookmark window
book2 := "Edit bookmark" ; title of second bookmark window
tOut := 120 ; seconds. Timeout interval



/* ___ ___  ___   ___ ___    _   __  __ 
  | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
  |  _/   / (_) | (_ \   / / _ \| |\/| |
  |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/
    ; -----Check for admin-----
        if not A_IsAdmin
        {
            showToast("ChromeBookmark Error", "Not run as Administrator. Script will now exit")
            ExitApp
        }
	; -----Initialize Vars-----
		GroupAdd, bookmarkWins, % book1
		GroupAdd, bookmarkWins, % book2
		Hotkey, IfWinActive, ahk_exe chrome.exe
            Hotkey, ~^d, ChromeBookmark, On
		Hotkey, IfWinActive, % book2
            Hotkey, ~Esc, bookmarkCancel, Off
            HotKey, ~Enter, bookmarkClose, Off
            Hotkey, ~LButton Up, bookmarkClick, Off
		Return

	ChromeBookmark:
		WinWait, ahk_group bookmarkWins,, 2
		if ErrorLevel
		{
			showToast("Error", "ChromeBookmark timed out")
			Return
		}
		Send, {Tab}{Down 8}
		loopCount := 0
		SetTimer, chromeTimeout, % tOut * 1000
		Hotkey, IfWinActive, ahk_exe chrome.exe
			Hotkey, ~^d, Off
		Hotkey, IfWinActive, % book2
			Hotkey, ~Esc, On
			HotKey, ~Enter, On
			Hotkey, ~LButton Up, On
		Return

	bookmarkClick:
		MouseGetPos, cx, cy, clickedWin
		WinGetTitle, clickedWinTitle, ahk_id %clickedWin%
		if (clickedWinTitle = book2)
		{
			if (346 < cx and cx < 439) and (482 < cy and cy < 515) ; Cancel button was clicked
			{
				Goto bookmarkCancel
			}
			else if (244 < cx and cx < 339) and (482 < cy and cy < 515) ; Save button was clicked
			{
				Goto bookmarkClose
			}
		}
	Return

	bookmarkCancel:
		BlockIn(1)
		Send, ^d
		WinWait, % book2,, 2
		if ErrorLevel
		{
			BlockIn(0)
			showToast("Error", "ChromeBookmark timed out waiting for the 'Edit bookmark' window")
			Goto bookmarkClose
		}
		Send, {Tab 3}{Enter}
		BlockIn(0)
		bookmarkClose:
			SetTimer, chromeTimeout, Off
			Hotkey, IfWinActive, ahk_exe chrome.exe
				Hotkey, ~^d, On
			Hotkey, IfWinActive, % book2
				Hotkey, ~Esc, Off
				HotKey, ~Enter, Off
				Hotkey, ~LButton Up, Off
	Return

	chromeTimeout:
		loopCount += 1
		MsgBox, 4, % "ChromeBookmark", % "ChromeBookmark has been waiting for " loopCount * tOut " seconds. Keep waiting?"
		IfMsgBox, No, Goto bookmarkClose
	Return

	/* ______  ___  _____________________  _  ______
	  / __/ / / / |/ / ___/_  __/  _/ __ \/ |/ / __/
	 / _// /_/ /    / /__  / / _/ // /_/ /    /\ \  
	/_/  \____/_/|_/\___/ /_/ /___/\____/_/|_/___/
	*/
		BlockIn(onoff) {
			PostMessage, 0x5555, %onoff%,,, % "Block_Input.ahk"
			Return
		}

		showToast(titleTxt, bodyTxt) {
			global toastTime
			new ToastNotif("imgttl", "AHK.png", titleTxt, bodyTxt, toastTime)
			Return
		}

		Cleanup(ExitReason, ExitCode) {
			Critical
			BlockIn(0)
			ExitApp
		}