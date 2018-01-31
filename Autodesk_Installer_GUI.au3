; Filename: Autodesk_Installer_GUI.au3
; Date of last modification: 12 October, 2017
; Purpose: To enable installation of Autodesk software 

; ##### Changelog #####
;
; Moved existing code into various functions
; Added timer code
; Adding some basic error checking
;
; 28 August, 2017 - Corrected undeclared variable
;
; 18 September, 2017 - Reworked UI
;
; 21 September, 2017 - Fixed broken path in "$file_4" in function "Run_Anim_Lab_Install"
;
; 27 September, 2017 - Added randomization for start times, additional error checking, and some colorization of progress bars
;
; 28 September, 2017 - Removed un-necessary MsgBox dialog in Run_Inventor_Install()
;
; 02 October, 2017 - Made "Cleanup()" run before "Unmap_Drive()"
;
; 12 October, 2017 - Added MsgBox indicators before each install occurs. Timeout is 5 seconds
;
; 25 October, 2017 - Fixed time randomization
;
; ##### End of Changelog #####

#RequireAdmin
#include <DirConstants.au3>
#include <FileConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <FontConstants.au3>
#include <Date.au3>
#include <ProgressConstants.au3>
#include <SendMessage.au3>
#include <ColorConstants.au3>
#include <WinAPI.au3>

Const $server_share = "\\server_name\share_name"
Const $domain = "domain_name"
Const $deployment_base_dir = "Autodesk_Deployments\"

Global $username = ""
Global $password = ""
Global $map_drive = "X:"
Global $hatch_patterns_install_dir ="C:\Program Files\Autodesk\AutoCAD 2017\Support\en-us\"
Global $3ds_max_dir = "3DS_MAX_2017\"
Global $adsu_dir = "ADSU_2017\"
Global $acad_arch_dir = "ACAD_Arch_2017\"
Global $pdsu_dir = "PDSU_2017\"
Global $revit_dir = "Revit_2017\"
Global $sketchbook_dir="SketchBook_Pro_2016\"
Global $maya_dir = "Maya_2016\"
Global $mudbox_dir = "Mudbox_2016\"
Global $motion_builder_dir = "MotionBuilder_2016\"
Global $temp_dir = "temp_dir_name"
Global $hatch_patterns_temp_dir = $temp_dir & "Hatch_Patterns\"
Global $file_1 = "Admin_Shell.exe"
Global $sleep_time = ""

Global $input_1 = ""
Global $input_2 = ""

Global $progress_1 = ""
Global $progress_2 = ""

Global $hTimer = ""
Global $fDiff = ""

Func GUI_Create()

    ; Create a GUI with various controls
    $hGUI = GUICreate("Autodesk", 430, 415, -1, -1, -1)
    $label_1 = GUICtrlCreateLabel("Autodesk Installer", 145, 20, 125, 100)
    $label_2 = GUICtrlCreateLabel("Username:", 88, 58, 63, 100)
    $label_3 = GUICtrlCreateLabel("Password:", 88, 88, 63, 100)
    $label_4 = GUICtrlCreateLabel("Current:", 100, 260, 50, 100)
    $label_5 = GUICtrlCreateLabel("Overall:", 100, 290, 50, 100)
    $radio_group_1 = GUICtrlCreateGroup("", 148, 120, 110, 120, $WS_THICKFRAME)
    $radio_1 = GUICtrlCreateRadio("CAD", 163, 137, 90)
    $radio_2 = GUICtrlCreateRadio("Animation", 163, 160, 90)
    $radio_3 = GUICtrlCreateRadio("Tech", 163, 183, 90)
    $radio_4 = GUICtrlCreateRadio("Robotics", 163, 206, 90)
    $button_1 = GUICtrlCreateButton("Map Drive", 246, 60, 80, 40, $BS_DEFPUSHBUTTON)
    $button_2 = GUICtrlCreateButton("Exit", 180, 340, 50, 40, $BS_DEFPUSHBUTTON)
    $input_1 = GUICtrlCreateInput("", 160, 55, 75, 20)
    $input_2 = GUICtrlCreateInput("", 160, 85, 75, 20, $ES_PASSWORD) 
    $progress_1 = GUICtrlCreateProgress(160, 260, 130, 20, $PBS_MARQUEE)
    $progress_2 = GUICtrlCreateProgress(160, 290, 130, 20)
    $msg = ""

    GUICtrlSetColor($progress_1, $COLOR_RED)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)

    _WinAPI_SetFocus($input_1)

    ;Display the GUI
    GUISetState (@SW_SHOW, $hGUI)

    ; Loop until the user exits
    While 1
        $msg = GUIGetMsg()
        Select
            Case $msg = $button_1
                Map_Drive()
            Case $msg = $radio_1 And $GUI_CHECKED = 1
                MsgBox($MB_ICONINFORMATION, "User Selection:", "You selected 'CAD'")
                    $hTimer = TimerInit()
                    Run_Admin_Shell()
                    Run_CAD_Lab_Install()
                    Copy_Hatch_Patterns()
                    Cleanup()
                    Unmap_Drive()
                    ExitLoop
            Case $msg = $radio_2 And $GUI_CHECKED = 1
                MsgBox($MB_ICONINFORMATION, "User Selection:", "You selected 'Animation'")
                    $hTimer = TimerInit()
                    Run_Admin_Shell()
                    Run_Anim_Lab_Install()
                    Unmap_Drive()
                    ExitLoop
            Case $msg = $radio_3 And $GUI_CHECKED = 1
                MsgBox($MB_ICONINFORMATION, "User Selection:", "You selected 'Tech'")
                    $hTimer = TimerInit()
                    Run_Admin_Shell()
                    Run_Tech_Lab_Install()
                    Copy_Hatch_Patterns()
                    Cleanup()
                    Unmap_Drive()
                    ExitLoop
            Case $msg = $radio_4 And $GUI_CHECKED = 1
                MsgBox($MB_ICONINFORMATION, "User Selection:", "You selected 'Robotics'")
                    $hTimer = TimerInit()
                    Run_Admin_Shell()
                    Run_Inventor_Install()
                    Cleanup()
                    Unmap_Drive()
                    ExitLoop
            Case $msg = $button_2
                Unmap_Drive()
                ExitLoop
        EndSelect
    WEnd

    ; Delete the previous GUI and all controls
    GUIDelete($hGUI)

EndFunc
    
Func Run_Opening_Splash()

    Local $sMessage_1 = StringAddCR("Autodesk Package Installer" & @LF & _
    "Last Updated: October 25, 2017" & @LF & "Coded by: username <user@email>")
    
    SplashTextOn("Autodesk", $sMessage_1, 400, 150, -1, -1, -1, -1, 14, $FW_BOLD)
    Sleep(10000) 
    SplashOff()
    
EndFunc

Func Map_Drive()

    $is_drive_mapped = ""
    $timeout = 10

    $username = GUICtrlRead($input_1)
    $password = GUICtrlRead($input_2)

    DriveMapAdd($map_drive, $server_share, "", $domain & "\" & $username, $password)

    $is_drive_mapped = DriveMapGet("X:")

    If $is_drive_mapped <> "" Then
        MsgBox($MB_ICONINFORMATION, "Drive Map", "Drive map successful", $timeout)
    Else
        MsgBox($MB_ICONERROR, "Drive Map", "Drive map not successful", $timeout)
    EndIf

EndFunc

Func Unmap_Drive()

    $timeout = 10

    DriveMapDel($map_drive)

    Local $is_drive_mapped = DriveMapGet("X:")

    If $is_drive_mapped == "" Then
        MsgBox($MB_ICONINFORMATION, "Unmapping drive...", "Drive unmapped successfully...", $timeout)
    Else
        MsgBox($MB_ICONERROR, "Unmapping Drive...", "Drive not unmapped sucessfully... Exiting") 
    EndIf

EndFunc

Func Run_Admin_Shell()

    FileCopy($map_drive & "\" & $file_1, $temp_dir & "\" & $file_1, _
    $FC_OVERWRITE + $FC_CREATEPATH)

    Local $file = $temp_dir & $file_1

    If FileExists($file) Then
        Run($temp_dir & $file_1, "", @SW_MINIMIZE, "")
    Else
        MsgBox($MB_ICONERROR, "Admin shell file copy...", "File not copied... please investigate")
    EndIf

    WinWaitActive("Administrator: C:\Windows\system32\cmd.exe", "", 30)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

EndFunc

Func Copy_Hatch_Patterns()

    DirCreate($hatch_patterns_temp_dir)

    FileCopy($map_drive & "\" & "Files" & "\" & "Hatch_Patterns" & "\" & "*.pat", _
    $hatch_patterns_temp_dir & "*.pat", $FC_OVERWRITE)

    FileCopy($hatch_patterns_temp_dir & "*.pat", $hatch_patterns_install_dir & "*.pat", $FC_OVERWRITE) 

    Local $file = $hatch_patterns_install_dir & "*.pat"

    If FileExists($file) Then
        GUICtrlSetColor($progress_1, $COLOR_GREEN)
        _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)
    
        GUICtrlSetColor($progress_2, $COLOR_GREEN)
        GUICtrlSetData($progress_2, 100)
    Else
        MsgBox($MB_ICONERROR, "Hatch pattern/s file copy...", "Copy failed... please investigate")
    EndIf

EndFunc

Func Cleanup()

    $timeout = 10

    MsgBox($MB_ICONINFORMATION, "Installation progress...", "Almost finished... Performing cleanup", $timeout)

    FileDelete("C:\Users\Public\Desktop\A360 Desktop.lnk")

    FileDelete("C:\Users\Public\Desktop\Autodesk Product Design Suite Ultimate 2017.lnk")

    $fDiff = TimerDiff($hTimer)
    $fDiff = round($fDiff / 1000 / 60, 2)

    Sleep(2000)

    MsgBox($MB_ICONINFORMATION, "Installation progress...", "Installation has completed" & @CRLF & @CRLF & "Total running time was: " & $fDiff & " minutes")

EndFunc

Func Run_CAD_Lab_Install()

    Local $file_1 = ("C:\Program Files\Autodesk\AutoCAD 2017\acad.exe")

    Local $file_2 = ("C:\Program Files\Autodesk\Inventor 2017\Bin\Inventor.exe")

    Local $file_3 = ("C:\Program Files\Autodesk\Revit 2017\Revit.exe")

    Local $file_4 = ("C:\Program Files\Autodesk\3ds Max 2017\3dsmax.exe")

    Local $file_5 = ("C:\Program Files\Autodesk\Autodesk SketchBook Pro 2016\SketchBookPro.exe")

    $timeout = 5

    GUICtrlSetColor($progress_1, $COLOR_RED)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetColor($progress_2, $COLOR_RED)
    GUICtrlSetData($progress_2, 0)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of AutoCAD", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $adsu_dir & "Img\Setup.exe", _
    "/W /q /I Img\ADSU_2017.ini /language en-us", "", "", "")  

    If FileExists($file_1) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "AutoCAD 2017...", "Install failed... Please check install log file on deployment share")
    EndIf
         
    GUICtrlSetData($progress_2, 16)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of AutoCAD Architecture", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $acad_arch_dir & "Img\Setup.exe", _
    "/W /q /I Img\ACAD_Arch_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 32)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Inventor", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", _
    "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

    If FileExists($file_2) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Inventor 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 48)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Revit", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $revit_dir & "Img\Setup.exe", _
    "/W /q /I Img\Revit_2017.ini /language en-us", "", "", "") 

    If FileExists($file_3) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Revit 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 64)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of 3DS Max", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $3ds_max_dir & "Img\Setup.exe", _
    "/W /q /I Img\3DS_MAX_2017.ini /language en-us", "", "", "") 

    If FileExists($file_4) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "3DS Max 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 80)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of SketchBook Pro", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $sketchbook_dir & "Img\Setup.exe", _
    "/W /q /I Img\SketchBook_Pro_2016.ini /language en-us", "", "", "")  

    If FileExists($file_5) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "SketchBook Pro 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 95)

EndFunc

Func Run_Anim_Lab_Install()

    Local $file_1 = ("C:\Program Files\Autodesk\3ds Max 2017\3dsmax.exe")

    Local $file_2 = ("C:\Program Files\Autodesk\Maya2016\bin\maya.exe")

    Local $file_3 = ("C:\Program Files\Autodesk\Mudbox 2016\mudbox.exe")

    Local $file_4 = ("C:\Program Files\Autodesk\MotionBuilder 2016\bin\x64\MotionBuilder.exe")

    Local $file_5 = ("C:\Program Files\Autodesk\Autodesk SketchBook Pro 2016\SketchBookPro.exe")

    $timeout = 5

    GUICtrlSetColor($progress_1, $COLOR_RED)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetColor($progress_2, $COLOR_RED)
    GUICtrlSetData($progress_2, 0)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of 3DS Max", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $3ds_max_dir & "Img\Setup.exe", _
    "/W /q /I Img\3DS_MAX_2017.ini /language en-us", "", "", "") 

    If FileExists($file_1) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "3DS Max 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 20)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Maya", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $maya_dir & "Img\Setup.exe", _
    "/W /q /I Img\Maya_2016.ini /language en-us", "", "", "")  

    If FileExists($file_2) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Maya 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 40)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Mudbox", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $mudbox_dir & "Img\Setup.exe", _
    "/W /q /I Img\Mudbox_2016.ini /language en-us", "", "", "")  

    If FileExists($file_3) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Mudbox 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 60)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Motion Builder", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $motion_builder_dir & "Img\Setup.exe", _
    "/W /q /I Img\MotionBuilder_2016.ini /language en-us", "", "", "") 

    If FileExists($file_4) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "MotionBuilder 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 80)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of SketchBook Pro", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $sketchbook_dir & "Img\Setup.exe", _
    "/W /q /I Img\SketchBook_Pro_2016.ini /language en-us", "", "", "")  

    If FileExists($file_5) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "SketchBook Pro 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetColor($progress_1, $COLOR_GREEN)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)
    
    GUICtrlSetColor($progress_2, $COLOR_GREEN)
    GUICtrlSetData($progress_2, 100)

    $fDiff = TimerDiff($hTimer)
    $fDiff = round($fDiff / 1000 / 60, 2)

    MsgBox($MB_ICONINFORMATION, "Installation progress...", "Installation has completed" & @CRLF & @CRLF & "Total running time was: " & $fDiff & " minutes")

EndFunc

Func Run_Tech_Lab_Install()

    Local $file_1 = ("C:\Program Files\Autodesk\AutoCAD 2017\acad.exe")

    Local $file_2 = ("C:\Program Files\Autodesk\Inventor 2017\Bin\Inventor.exe")

    Local $file_3 = ("C:\Program Files\Autodesk\Revit 2017\Revit.exe")

    Local $file_4 = ("C:\Program Files\Autodesk\Autodesk SketchBook Pro 2016\SketchBookPro.exe")

    $timeout = 5

    GUICtrlSetColor($progress_1, $COLOR_RED)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetColor($progress_2, $COLOR_RED)
    GUICtrlSetData($progress_2, 0)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of AutoCAD", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $adsu_dir & "Img\Setup.exe", _
    "/W /q /I Img\ADSU_2017.ini /language en-us", "", "", "")  

    If FileExists($file_1) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "AutoCAD 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 20)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of AutoCAD Architecture", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $acad_arch_dir & "Img\Setup.exe", _
    "/W /q /I Img\ACAD_Arch_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 40)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Inventor", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", _
    "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

    If FileExists($file_2) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Inventor 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 60)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Revit", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $revit_dir & "Img\Setup.exe", _
    "/W /q /I Img\Revit_2017.ini /language en-us", "", "", "") 

    If FileExists($file_3) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Revit 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 80)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of SketchBook Pro", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $sketchbook_dir & "Img\Setup.exe", _
    "/W /q /I Img\SketchBook_Pro_2016.ini /language en-us", "", "", "")  

    If FileExists($file_4) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "SketchBook Pro 2016...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 95)

EndFunc

Func Run_Inventor_Install()

    Local $file_1 = ("C:\Program Files\Autodesk\Inventor 2017\Bin\Inventor.exe")

    $timeout = 5

    GUICtrlSetColor($progress_1, $COLOR_RED)
    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetColor($progress_2, $COLOR_RED)
    GUICtrlSetData($progress_2, 0)

    $sleep_time = Random(1000, 5000, 1)
    sleep($sleep_time)

    MsgBox($MB_ICONINFORMATION, "Installation Progress...", "Starting install of Inventor", $timeout)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", _
    "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

    If FileExists($file_1) Then
        sleep(2000)
    Else
        MsgBox($MB_ICONWARNING, "Inventor 2017...", "Install failed... Please check install log file on deployment share")
    EndIf

    GUICtrlSetData($progress_2, 95)

EndFunc

; Execution begins with calls to Run_Opening_Splash() and GUI_Create()

Run_Opening_Splash()
GUI_Create()
