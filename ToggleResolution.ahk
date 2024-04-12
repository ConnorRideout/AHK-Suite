#NoEnv
#NoTrayIcon
#Persistent
#SingleInstance Force
OnExit("Cleanup")
Return


#F12::
if (toggleResolution := !toggleResolution)
{
    Run, % "nircmd setdisplay monitor:0 1920 1080 32"
    Run, % "nircmd setdisplay monitor:1 1920 1080 32"
}
else
{
    Run, % "nircmd setdisplay monitor:0 2560 1440 32 -updatereg"
    Run, % "nircmd setdisplay monitor:1 2560 1440 32 -updatereg"
}
Return

#Esc::
Run, % "nircmd monitor off"
Return


Cleanup(ExitReason, ExitCode) {
    global
    Critical
    if toggleDisplay
    {
        Run, % "nircmd setdisplay monitor:0 2560 1440 32 -updatereg"
        Run, % "nircmd setdisplay monitor:1 2560 1440 32 -updatereg"
    }
    ExitApp
}