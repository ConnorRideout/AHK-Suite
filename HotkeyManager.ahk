#NoEnv
#Persistent
#SingleInstance Force
#Include <ToastNotif>
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
SetTitleMatchMode, 2
OnExit("Cleanup")

/* ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___ 
  | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
  | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
  |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/
	trayIcon := A_MyDocuments "\AutoHotkey\Lib\img\Manager.ico"
    autoHotKeyExe := "AutoHotkeyU64.exe"
	/* The format for 'allSripts' and 'sysScripts' is <scriptName>:<options>. sysScripts will be added to a menu after allScripts
	<options> is any combination of the following letters:
		r = add script to 'reload' menu
		e = add script to 'exit' menu
		c|p|s = add script to 'suspend' menu:
			c = custom suspend (defined within the script with 'OnMessage(0x5555, <myFunction>)')
			p = ahk_pause
			s = ahk_suspend
	*/
	allScripts := {	"AudioSwitcher" 	: 	"res"
					; ,"ChromeBookmark" 	: 	"res"
					; ,"DesktopFader" 	: 	"rec"
                    ,"FadeWindows"      :   "rec"
					,"GoogleKeep" 		: 	"rec"
					; ,"GSyncCycling" 	: 	"rec"
					; ,"SetOnTop" 		: 	"rec"
                    ,"MinimizeApp"      :   "res"
                    ,"Snipping"         :   "res"
					,"ToggleResolution"	: 	"res"
                    ; ,"TransparentWindow":   "res"
					,"TurboHotkey"		: 	"res"
					,0:0}
	sysScripts := {	"Block_Input"					:	"r"
					,SubStr(A_ScriptName, 1, -4)	:	"r"}
	; Menu label text variables
	relMenuTxt := "Reload a Script"
	susMenuTxt := "Suspend a Script"
	exitMenuTxt := "Exit a Script"
	relAllTxt := "Reload All Scripts"
	susAllTxt := "Suspend All Scripts"
	exitAllTxt := "Exit All Scripts"
	toastTime := 3000 ; milliseconds. How long a toast notification remains on screen


/* ___ ___  ___   ___ ___    _   __  __ 
  | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
  |  _/   / (_) | (_ \   / / _ \| |\/| |
  |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/
	allScripts.Delete(0)
	subscriptCount := allScripts.Count() + sysScripts.Count() - 1
	progInfo := " M FM14 FS12 R0-"
	OnMessage(0x5555, "listener")
	; -----Tray menu set-up-----
		sus := {}
		rel := []
		for script,opt in allScripts
		{
			if InStr(opt, "r")
			{
				Menu, ReloadMenu, Add, % script, reloadScript
				rel.Push(script)
			}
			if RegExMatch(opt, "c|p|s")
			{
				Menu, SuspendMenu, Add, % script, suspendScript
				sus[script] := False
			}
			if InStr(opt, "e")
				Menu, ExitMenu, Add, % script, exitScript
		}
		for script,opt in sysScripts
		{
			if InStr(opt, "r")
			{
				if not rSp
					Menu, ReloadMenu, Add
				rSp := True
				Menu, ReloadMenu, Add, % script, reloadScript
				rel.Push(script)
			}
			if RegExMatch(opt, "c|p|s")
			{
				if not sSp
					Menu, SuspendMenu, Add
				sSp := True
				Menu, SuspendMenu, Add, % script, suspendScript
				sus[script] := False
			}
			if InStr(opt, "e")
			{
				if not eSp
					Menu, ExitMenu, Add
				eSp := True
				Menu, ExitMenu, Add, % script, exitScript
			}
		}
		Menu, Tray, NoStandard
		Menu, Tray, Icon, % trayIcon
		Menu, Tray, Add, % relMenuTxt, :ReloadMenu
		Menu, Tray, Add
		Menu, Tray, Add, % susMenuTxt, :SuspendMenu
		Menu, Tray, Add
		Menu, Tray, Add, % exitMenuTxt, :ExitMenu
		Menu, Tray, Add
		Menu, Tray, Add, % relAllTxt, reload_all
		Menu, Tray, Add, % susAllTxt, suspend_all
		Menu, Tray, Add, % "Suspend GSync Process", toggle_gsync
		Menu, Tray, Add
		Menu, Tray, Add, % exitAllTxt, Cleanup

	; -----Start all scripts-----
		if FileExist("managerreloaded")
		{
			Loop, Read, % "managerreloaded"
			{
				kv := StrSplit(A_LoopReadLine, "=")
				if (kv[1]="runGS")
					listener(kv[2])
				else if kv[2]
				{
					if (kv[1]="suspended")
					{
						Menu, Tray, Disable, % susMenuTxt
						Menu, Tray, Check, % susAllTxt
						Suspend, On
					}
					else
						Menu, SuspendMenu, Check, % kv[1]
				}
			}
			FileDelete, % "managerreloaded"
			showToast("Success", SubStr(A_ScriptName, 1, -4) " has been reloaded!")
		}
		else if FileExist("allreloaded")
		{
			Loop, Read, % "allreloaded"
			{
				if (A_Index=1)
					reloadedScripts := A_LoopReadLine
				else
					errors .= "`n" A_LoopReadLine
			}
			FileDelete, % "allreloaded"
			showToast("Reloading Complete", (errors ? reloadedScripts : "All") " AHK scripts have been reloaded!" errors)
		}
		else
			for script in allScripts
				Run, % script ".ahk"
		Return


	/* ______  ___  _____________________  _  ______
	  / __/ / / / |/ / ___/_  __/  _/ __ \/ |/ / __/
	 / _// /_/ /    / /__  / / _/ // /_/ /    /\ \  
	/_/  \____/_/|_/\___/ /_/ /___/\____/_/|_/___/
	*/

		; -----Reloading-----
			reloadScript(script, other*) {
				global
				if InStr(A_ScriptName, script)
				{
					str := "suspended=" (A_IsSuspended ? "1" : "0")
					str .= "`nrunGS=" runGS
					for script,val in sus
						str .= "`n" script "=" val
					FileAppend, % str, % "managerreloaded"
					Reload
				}
				if (other.Count() ? exitScript(script, 1) : exitScript(script))
					Return True
				Run, % script ".ahk"
				WinWait, % script ".ahk",, 3
				if ErrorLevel
				{
					if other.Count()
						MsgBox, 0, % "Error", % "Couldn't restart " script
					Try Menu, SuspendMenu, Disable, % script
					Try Menu, ExitMenu, Disable, % script
					Return True
				}
				Try Menu, SuspendMenu, Enable, % script
				Try Menu, ExitMenu, Enable, % script
				if other.Count()
					showToast("Success", script " has been reloaded!")
				Return
			}

			reload_all:
				Progress, % progInfo rel.Count(), % A_Space, % "Reloading subscript:", % "Reloading all scripts"
				err := []
				for i,script in rel
				{
					if not InStr(A_ScriptName, script)
					{
						Progress, % A_Index, % script "..."
						if reloadScript(script)
							err.Push(script)
					}
				}
				Progress, % rel.Count(), % "Subscript reloading is complete", % "Reloading " A_ScriptName
				reloaded := subscriptCount - err.Count()
				str := reloaded "/" subscriptCount
				for i,e in err
					str .= "`n" e
				FileAppend, % str, % "allreloaded"
				Sleep 1000
				Reload
			Return

		; -----Suspending-----
			suspendScript(script, ignored*) {
				global
				sus[script] := !sus[script]
				Menu, SuspendMenu, % (sus[script] ? "Check" : "UnCheck"), % script
				if InStr(allScripts[script], "c")
					PostMessage, 0x5555, % (sus[script] ? 1 : 0),,, % script ".ahk" ; custom
				else if InStr(allScripts[script], "p")
					PostMessage, 0x111, 65403,,, % script ".ahk" ; pause
				else
					PostMessage, 0x111, 65404,,, % script ".ahk" ; suspend
				Return
			}

			suspend_all:
				if A_IsSuspended
				{
					Progress, % progInfo sus.Count(), % A_Space, % "Resuming subscript:", % "Resuming all scripts"
					Menu, Tray, Enable, % susMenuTxt
					for script in sus
					{
						Progress, % A_Index, % script "..."
						sus[script] := True
						suspendScript(script)
					}
					Menu, Tray, Uncheck, % susAllTxt
					Suspend, Off
					Progress, % sus.Count(), % "All scripts have been resumed", % "Complete"
					Sleep 1000
					Progress, Off
				}
				else
				{
					Progress, % progInfo sus.Count(), % A_Space, % "Suspending subscript:", % "Suspending all scripts"
					Menu, Tray, Disable, % susMenuTxt
					for script in sus
					{
						Progress, % A_Index, % script "..."
						sus[script] := false
						suspendScript(script)
					}
					Menu, Tray, Check, % susAllTxt
					Suspend, On
					Progress, % sus.Count(), % "All scripts have been suspended", % "Complete"
					Sleep 1000
					Progress, Off
				}
			Return

		exitScript(script, other*) {
			global sus
			WinGet, scriptWins, List, % script ".ahk ahk_exe " autoHotKeyExe
			loop % scriptWins
			{
				WinExist("ahk_id " scriptWins%A_Index%)
				WinClose
				WinWaitClose,,, 3
				if ErrorLevel
				{
					WinKill
					WinWaitClose,,, 3
					if ErrorLevel
					{
						if other.Count()
							MsgBox, 0, % "Error", % "Couldn't stop " script "`nIs " A_ScriptName " running as admin?"
						Return True
					}
				}
			}
			if other.Count()
			{
				sus[script] := False
				Try Menu, SuspendMenu, UnCheck, % script
				Try Menu, SuspendMenu, Disable, % script
				Try Menu, ExitMenu, Disable, % script
			}
			Return
		}

		toggle_gsync:
			PostMessage, 0x5555, % (runGS ? 2 : 3),,, % "GSyncCycling.ahk"
			listener(runGS ? 0 : 1)
		Return

		listener(wParam, ignored*) {
			global runGS
			if (wParam = 0)
			{
				Menu, Tray, Check, % "Suspend GSync Process"
				runGS := false
			}
			else if (wParam = 1)
			{
				Menu, Tray, UnCheck, % "Suspend GSync Process"
				runGS := true
			}
			Return
		}

		showToast(titleTxt, bodyTxt) {
			global toastTime
			new ToastNotif("imgttl", "AHK.png", titleTxt, bodyTxt, toastTime)
			Return
		}

		Cleanup(ExitReason, ExitCode) {
			global
			Critical
			if (ExitReason != "Reload")
			{
				Progress, % progInfo subscriptCount, % A_Space, % "Closing subscript:", % "Closing all scripts"
				for script in allScripts
				{
					Progress, % A_Index, % script "..."
					exitScript(script)
				}
				for script in sysScripts
				{
					if not InStr(A_ScriptName, script)
					{
						Progress, % allScripts.Count() + A_Index, % script "..."
						exitScript(script)
					}
				}
				Progress, % subscriptCount, % "All subscripts have been closed", % "Closing " A_ScriptName
				Sleep 1000
			}
			ExitApp
		}
