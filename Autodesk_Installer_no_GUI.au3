; Filename: Autodesk_Installer_no_GUI.au3
; Last File Change: 20 May 2016
; Purpose: Autodesk software installer (non-GUI version w/ progress bars)

#RequireAdmin
#include <DirConstants.au3>
#include <FileConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <FontConstants.au3>
#include <Date.au3>

Const $server_share = "\\server_name\share_name"
Const $domain = "domain_name"
Const $map_drive = "X:"
Const $hatch_patterns_install_dir ="C:\Program Files\Autodesk\AutoCAD 2017\Support\en-us\"
Const $autodesk_2015_shortcut_dir = "C:\Users\Public\Desktop\Autodesk 2015\"

Global $username = ""
Global $password = ""

Global $deployment_base_dir = "Autodesk_Deployments\"
Global $adsu_dir = "ADSU_2017\"
Global $pdsu_dir = "PDSU_2017\"
Global $revit_dir = "Revit_2017\"
Global $3ds_max_dir = "3DS_MAX_2017\"
Global $temp_dir = "temp_dir_name"
Global $hatch_patterns_temp_dir = $temp_dir & "Hatch_Patterns\"
 
Global $file_1 = "Admin_Shell.exe"
;Global $file_2 = "Disable_MC3.reg"

Global $sleep_time = ""

Func RunOpeningSplash()

    Local $sMessage_1 = StringAddCR("Autodesk Installer" & @LF & "May, 2016" & @LF & "Coded by: username <username@email_address")
    Local $sMessage_2 = StringAddCR("The needs of the many outweigh the needs of the few, or the one!")
    
    SplashTextOn("Autodesk 2017", $sMessage_1, 400, 150, -1, -1, -1, -1, 14, $FW_BOLD)

    Sleep(4000) 

    SplashOff()
    
    SplashTextOn("Autodesk 2017", $sMessage_2, 300, 100, -1, -1, -1, -1, 12, $FW_MEDIUM)

    Sleep(3000) 

    SplashOff()
    
EndFunc

Func GetStartDateTime()

    Local $DateTime_1 = _Date_Time_GetLocalTime()
    
    SplashTextOn("Start Date / Time", "The starting date / time is: " & @LF & _Date_Time_SystemTimeToDateTimeStr($DateTime_1), 400, 150, -1, -1, -1, -1, 14, $FW_BOLD)

    Sleep(4000) 

    SplashOff()
    
EndFunc

Func GetEndDateTime()

    Local $DateTime_1 = _Date_Time_GetLocalTime()
    
    SplashTextOn("End Date / Time", "The ending date / time is: " & @LF & _Date_Time_SystemTimeToDateTimeStr($DateTime_1), 400, 150, -1, -1, -1, -1, 14, $FW_BOLD)

    Sleep(4000) 

    SplashOff()
    
EndFunc

RunOpeningSplash()

GetStartDateTime()

$username = InputBox("Username", "Please enter your username", "", "", "", "", "", "", 180)
$password = InputBox("Password", "Please enter your password", "", "*M", "", "", "", "", 180)

DriveMapAdd($map_drive, $server_share, "", $domain & "\" & $username, $password)

FileCopy($map_drive & "\" & $file_1, $temp_dir & $file_1, $FC_OVERWRITE + $FC_CREATEPATH)

Run($temp_dir & $file_1, "", @SW_MINIMIZE, "")

WinWaitActive("Administrator: C:\Windows\system32\cmd.exe", "", 30)

DirCreate($autodesk_2015_shortcut_dir)

FileMove("C:\Users\Public\Desktop\AutoCAD 2015 - English.lnk", $autodesk_2015_shortcut_dir)
FileMove("C:\Users\Public\Desktop\AutoCAD Architecture 2015 - English (US Imperial).lnk", $autodesk_2015_shortcut_dir)
FileMove("C:\Users\Public\Desktop\Autodesk Inventor Professional 2015.lnk", $autodesk_2015_shortcut_dir)
FileMove("C:\Users\Public\Desktop\Revit 2015.lnk", $autodesk_2015_shortcut_dir)

$sleep_time = Random(0,10000,1)
sleep($sleep_time)

ProgressOn("Autodesk for CAD labs", "Starting install of CAD Lab 2017 Software...", "", 10, 10)
Sleep(2000)
ProgressSet(0, "", "Installing AutoCAD 2017")

ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $adsu_dir & "Img\Setup.exe", "/W /q /I Img\ADSU_2017.ini /language en-us", "", "", "")  

ProgressSet(25, "", "AutoCAD 2017 install complete")
Sleep(2000)

ProgressSet(25, "", "Installing Inventor 2017")

ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

ProgressSet(50, "", "Inventor 2017 install complete")
Sleep(2000)

ProgressSet(50, "", "Installing Revit 2017")

ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $revit_dir & "Img\Setup.exe", "/W /q /I Img\Revit_2017.ini /language en-us", "", "", "") 

ProgressSet(75, "", "Revit 2017 install complete")
Sleep(2000)

ProgressSet(75, "", "Installing 3DS MAX 2017")

ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $3DS_MAX_dir & "Img\Setup.exe", "/W /q /I Img\3DS_MAX_2017.ini /language en-us", "", "", "") 

ProgressSet(99, "", "3DS MAX 2017 install complete")
Sleep(2000)

DirCreate($hatch_patterns_temp_dir)

FileCopy($map_drive & "\" & "Files" & "\" & "Hatch_Patterns" & "\" & "*.pat", $hatch_patterns_temp_dir & "*.pat", $FC_OVERWRITE)

FileCopy($hatch_patterns_temp_dir & "*.pat", $hatch_patterns_install_dir & "*.pat", $FC_OVERWRITE) 

;FileCopy($map_drive & "\" & "Files" & "\" & $file_2, $temp_dir & $file_2, $FC_OVERWRITE)

ProgressSet(100, "", "CAD Lab installations complete")

DriveMapDel($map_drive)

FileDelete("C:\Users\Public\Desktop\A360 Desktop.lnk")

FileDelete("C:\Users\Public\Desktop\Autodesk Product Design Suite Ultimate 2017.lnk")

MsgBox(64, "Installations complete", "All CAD lab installations are complete... Please check computers for programs and operation.")

GetEndDateTime()
