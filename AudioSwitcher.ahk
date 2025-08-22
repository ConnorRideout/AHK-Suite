#NoEnv
#NoTrayIcon
#Persistent
#Include <ToastNotif>
#SingleInstance Force

;  ___ ___ ___ _____ _   ___ _    ___  __   ___   ___  ___ 
; | __|   \_ _|_   _/_\ | _ ) |  | __| \ \ / /_\ | _ \/ __|
; | _|| |) | |  | |/ _ \| _ \ |__| _|   \ V / _ \|   /\__ \
; |___|___/___| |_/_/ \_\___/____|___|   \_/_/ \_\_|_\|___/

toastTime := 2000 ; milliseconds. How long a toast notification remains on screen
d1 := "Speakers" ; name of the primary sound device
d2 := "Headphones" ; name of the secondary sound device
%d1%Img := d1 ".png" ; path of the image corresponding to d1 (can be in docs\AutoHotkey\Lib\img)
%d2%Img := d2 ".png" ; path of the image corresponding to d2 (can be in docs\AutoHotkey\Lib\img)
Return

;  ___ ___  ___   ___ ___    _   __  __ 
; | _ \ _ \/ _ \ / __| _ \  /_\ |  \/  |
; |  _/   / (_) | (_ \   / / _ \| |\/| |
; |_| |_|_\\___/ \___/_|_\/_/ \_\_|  |_|

#a::
	toggleAudio := !toggleAudio
	if toggleAudio
	{
		Run, % "nircmd setdefaultsounddevice """ d2 """"
		Run, % "nircmd setdefaultsounddevice """ d2 """ 2"
		soundToasty(d2)
	}
	else
	{
		Run, % "nircmd setdefaultsounddevice """ d1 """"
		Run, % "nircmd setdefaultsounddevice """ d1 """ 2"
		soundToasty(d1)
	}
Return

soundToasty(device) {
	global toastTime
	new ToastNotif("imgttl", %device%Img, "Default Sound Device:", device, toastTime)
	Sleep % toastTime
	Return
}