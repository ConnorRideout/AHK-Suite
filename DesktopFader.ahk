#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
#InstallMouseHook
SetTitleMatchMode, 2
OnExit("Cleanup")

/* ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___ 
  | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
  | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
  |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/
*/
	fadeWait := 25 ; default=25 milliseconds. How long the mouse must be stationary before the desktop fades in
	fadeSpeed := 15 ; default=15 milliseconds. Approximate. Fading occurs over about this many milliseconds
    fadePercent := 15 ; default=0 percent. Approximate. Percent opacity after fading, where 0 means invisible, 100 means no fading at all
	mouseCheck := 10 ; default=10 milliseconds. How often to check if mouse is over the desktop
	desktopClass := "WorkerW" ; name of the desktop window class, usually 'WorkerW' or 'Progman'

    /* A NOTE ON WHY SOME VARIABLES ARE APPROXIMATIONS:
    These values are not truly exact because I prioritized smooth transitions and readability over exact timings and values.
    The differences are negligible; nothing will be off by more than one or two miliseconds or very small decimal values
    (i.e. fading in/out might take up to 2 miliseconds longer, or the opacity would be 50.2% rather than right at 50%)
    */


/* ___ ___  ___   ___ ___    _   __  __ 
  | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
  |  _/   / (_) | (_ \   / / _ \| |\/| |
  |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|
*/
	; -----Initialize vars-----
		if not (desktop := WinExist("ahk_class " desktopClass))
		{
			MsgBox,, % "Error", % "Check desktopClass variable"
			Return
		}
		fadeState := "showing"
        fadeTo := Round(255 * (fadePercent / 100))
        fadeMax := Max(fadeTo, 1)
		fadeStep := Round((255 - fadeTo) / fadeSpeed)
		OnMessage(0x5555, "listener")
		SetTimer, CheckMousePos, % mouseCheck
		Return


	CheckMousePos:
        if (A_TimeIdleMouse > 100)
            Return
		MouseGetPos, mx, my, win_under_mouse
		WinGetClass, class_under_mouse, ahk_id %win_under_mouse%
		WinGetClass, activeClass, A
		if (activeClass = desktopClass) or (not activeClass) or (class_under_mouse = desktopClass)
		{
			if (fadeState = "hiding")
			{
				Sleep % fadeWait
				MouseGetPos, mx1, my1
				if (mx = mx1) and (my = my1)
					Goto FadeIn
			}
		}
		else if (fadeState = "showing")
			Goto FadeOut
	Return

	FadeIn:
		WinExist("ahk_id " desktop)
        transVal := fadeTo
		While (transVal < 255) && (fadeState != "stop")
		{
			WinSet, Transparent, % transVal
            transVal += fadeStep
			Sleep 1
		}
		WinSet, Transparent, Off
		fadeState := "showing"
	Return

	FadeOut:
		WinExist("ahk_id " desktop)
		transVal := 255
        While (transVal > fadeTo) && (fadeState != "stop")
		{
			WinSet, Transparent, % transVal
            transVal -= fadeStep
			Sleep 1
		}
		WinSet, Transparent, % fadeMax
		fadeState := "hiding"
	Return

	/* ______  ___  _____________________  _  ______
	  / __/ / / / |/ / ___/_  __/  _/ __ \/ |/ / __/
	 / _// /_/ /    / /__  / / _/ // /_/ /    /\ \  
	/_/  \____/_/|_/\___/ /_/ /___/\____/_/|_/___/
	*/
		listener(stop) {
			global
			if stop
			{
				SetTimer, CheckMousePos, Off
				fadeState := "stop"
				Sleep % fadeSpeed
				WinSet, Transparent, Off, ahk_id %desktop%
				fadeState := "showing"
			}
			else
				SetTimer, CheckMousePos, On
			Return
		}

		Cleanup(ExitReason, ExitCode) {
			Critical
			listener(1)
			ExitApp
		}