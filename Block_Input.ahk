#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
#InstallKeybdHook
#InstallMouseHook
SendMode, Input

OnMessage(0x5555, "Blocking")
Return

Blocking(wParam=2) {
	static callCount
	if (wParam = 2) ; timed out
		callCount := 0
	else if wParam ; called by script
	{
		callCount += 1
		BlockInput, On
		SetTimer, Blocking, -5000
		Return
	}
	else if (callCount > 0) ; finished by script
		callCount -= 1
	if (callCount > 0) ; continue waiting
		Return
	SetTimer, Blocking, Off ; all calls are finished
	for i,key in ["Alt", "Ctrl", "Shift", "LWin", "RWin", "RButton", "MButton", "LButton"]
		if (GetKeyState(key) != GetKeyState(key, "P"))
			Send, % "{" key (GetKeyState(key, "P") ? " Down}" : " Up}")
	BlockInput, Off
	Return
}