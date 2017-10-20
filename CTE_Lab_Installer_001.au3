; Filename: CTE_Lab_Installer_001.au3
; Date of last modification: 08 May, 2017
; Coded by: username <username@no_reply.net>

#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <DirConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <ProgressConstants.au3>
#include <SendMessage.au3>
#include <ColorConstants.au3>

Const $map_drive = "X:"
Const $server_share = "\\server_name\share_name"
Const $domain = "domain_name"
Const $file_1 = "Admin_Shell.exe"
Const $deployment_base_dir = "Autodesk_Deployments\"
Const $adsu_dir = "ADSU_2017\"
Const $acad_arch_dir = "ACAD_Arch_2017\"
Const $pdsu_dir = "PDSU_2017\"
Const $revit_dir = "Revit_2017\"
Const $3ds_max_dir = "3DS_MAX_2017\"
Const $maya_dir = "Maya_2016\"
Const $mudbox_dir = "Mudbox_2016\"
Const $motion_builder_dir = "MotionBuilder_2016\"
Const $hatch_patterns_install_dir ="C:\Program Files\Autodesk\AutoCAD 2017\Support\en-us\"

$username = ""
$password = ""

$input_1 = ""
$input_2 = ""

$progress_1 = ""
$progress_2 = ""

$temp_dir = "C:\temp_dir"
$sleep_time = ""

Func GUI_Create()

    ; Create a GUI with various controls
    $hGUI = GUICreate("CTE_Installer_GUI", 305, 305, -1, -1, -1)
    $label_1 = GUICtrlCreateLabel("CTE Installer", 110, 10)
    $label_2 = GUICtrlCreateLabel("Username:", 50, 50)
    $label_3 = GUICtrlCreateLabel("Password:", 50, 80)
    $label_4 = GUICtrlCreateLabel("Current:", 55, 200)
    $label_5 = GUICtrlCreateLabel("Overall:", 55, 230)
    $radio_group_1 = GUICtrlCreateGroup("", 90, 100, 115, 80)
    $radio_1 = GUICtrlCreateRadio("CAD Lab", 105, 110, 90)
    $radio_2 = GUICtrlCreateRadio("Animation Lab", 105, 130, 105)
    $radio_3 = GUICtrlCreateRadio("Tech Lab", 105, 150, 95)
    $button_1 = GUICtrlCreateButton("Map Drive", 188, 60)
    $button_2 = GUICtrlCreateButton("Exit", 170, 260)
    $button_3 = GUICtrlCreateButton("Run", 110, 260)
    $msg = ""

    $input_1 = GUICtrlCreateInput("", 105, 45, 75, 20)
    $input_2 = GUICtrlCreateInput("", 105, 75, 75, 20, $ES_PASSWORD) 
    $progress_1 = GUICtrlCreateProgress(100, 195, 150, 20, $PBS_MARQUEE)
    $progress_2 = GUICtrlCreateProgress(100, 225, 150, 20)

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)

    ;Display the GUI
    GUISetState (@SW_SHOW, $hGUI)

    ; Loop until the user exits
    While 1
        $msg = GUIGetMsg()
        Select
            Case $msg = $button_1
                Map_Drive()
            Case $msg = $radio_1 And BitAND(GUICtrlRead($radio_1), $GUI_CHECKED) = $GUI_CHECKED
                Case $msg = $button_3
                    Run_Admin_Shell()
                    Run_CAD_Lab_Install()
                    DriveMapDel($map_drive)
                    ExitLoop
            Case $msg = $radio_2 And BitAND(GUICtrlRead($radio_2), $GUI_CHECKED) = $GUI_CHECKED
                Case $msg = $button_3
                    Run_Admin_Shell()
                    Run_Anim_Lab_Install()
                    DriveMapDel($map_drive)
                    ExitLoop
            Case $msg = $radio_3 And BitAND(GUICtrlRead($radio_3), $GUI_CHECKED) = $GUI_CHECKED
                Case $msg = $button_3
                    Run_Admin_Shell()
                    Run_Tech_Lab_Install()
                    DriveMapDel($map_drive)
                    ExitLoop
            Case $msg = $button_2
                DriveMapDel($map_drive)
                ExitLoop
        EndSelect
    WEnd

    ; Delete the previous GUI and all controls
    GUIDelete($hGUI)

EndFunc
    
Func Map_Drive()

    $is_drive_mapped = ""
    $timeout = 5

    $username = GUICtrlRead($input_1)
    $password = GUICtrlRead($input_2)

    DriveMapAdd($map_drive, $server_share, "", $domain & "\" & $username, $password)

    $is_drive_mapped = DriveMapGet("X:")
    If $is_drive_mapped <> "" Then
        MsgBox(8256, "Drive Map", "Drive map successful", $timeout)
    Else
        MsgBox(8240, "Drive Map", "Drive map not successful", $timeout)
    EndIf

EndFunc

Func Run_Admin_Shell()

    FileCopy($map_drive & "\" & $file_1, $temp_dir & "\" & $file_1, $FC_OVERWRITE + $FC_CREATEPATH)
    Run($temp_dir & "\" & $file_1, "", @SW_MINIMIZE, "")
    WinWaitActive("Administrator: C:\Windows\system32\cmd.exe", "", 30)
    $sleep_time = Random(0,10000,1)
    sleep($sleep_time)

EndFunc

Func Run_CAD_Lab_Install()

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetData($progress_2, 0)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $adsu_dir & "Img\Setup.exe", "/W /q /I Img\ADSU_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 16)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $acad_arch_dir & "Img\Setup.exe", "/W /q /I Img\ACAD_Arch_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 32)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 48)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $revit_dir & "Img\Setup.exe", "/W /q /I Img\Revit_2017.ini /language en-us", "", "", "") 

    GUICtrlSetData($progress_2, 64)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $3ds_max_dir & "Img\Setup.exe", "/W /q /I Img\3DS_MAX_2017.ini /language en-us", "", "", "") 

    GUICtrlSetData($progress_2, 80)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $maya_dir & "Img\Setup.exe", "/W /q /I Img\Maya_2016.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 99)

    Sleep(2000)

    DirCreate($hatch_patterns_temp_dir)

    FileCopy($map_drive & "\" & "Files" & "\" & "Hatch_Patterns" & "\" & "*.pat", $hatch_patterns_temp_dir & "*.pat", $FC_OVERWRITE)

    FileCopy($hatch_patterns_temp_dir & "*.pat", $hatch_patterns_install_dir & "*.pat", $FC_OVERWRITE) 

    Sleep(3000)

    FileDelete("C:\Users\Public\Desktop\A360 Desktop.lnk")

    FileDelete("C:\Users\Public\Desktop\Autodesk Product Design Suite Ultimate 2017.lnk")

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)
    
    GUICtrlSetData($progress_2, 100)

    Sleep(3000)

    MsgBox(64, "Installer complete.", "Installer has completed")

EndFunc

Func Run_Anim_Lab_Install()

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetData($progress_2, 0)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $3ds_max_dir & "Img\Setup.exe", "/W /q /I Img\3DS_MAX_2017.ini /language en-us", "", "", "") 

    GUICtrlSetData($progress_2, 25)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $maya_dir & "Img\Setup.exe", "/W /q /I Img\Maya_2016.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 50)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $mudbox_dir & "Img\Setup.exe", "/W /q /I Img\Mudbox_2016.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 75)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $motion_builder_dir & "Img\Setup.exe", "/W /q /I Img\MotionBuilder_2016.ini /language en-us", "", "", "") 

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)

    GUICtrlSetData($progress_2, 100)

    Sleep(3000)

    MsgBox(64, "Installer complete.", "Installer has completed")

EndFunc

Func Run_Tech_Lab_Install()

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 1, 200)

    GUICtrlSetData($progress_2, 0)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $adsu_dir & "Img\Setup.exe", "/W /q /I Img\ADSU_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 25)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $acad_arch_dir & "Img\Setup.exe", "/W /q /I Img\ACAD_Arch_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 50)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $pdsu_dir & "Img\Setup.exe", "/W /q /I Img\PDSU_2017.ini /language en-us", "", "", "")  

    GUICtrlSetData($progress_2, 75)

    Sleep(2000)

    ShellExecuteWait($map_drive & "\" & $deployment_base_dir & $revit_dir & "Img\Setup.exe", "/W /q /I Img\Revit_2017.ini /language en-us", "", "", "") 

    GUICtrlSetData($progress_2, 99)

    Sleep(2000)

    DirCreate($hatch_patterns_temp_dir)

    FileCopy($map_drive & "\" & "Files" & "\" & "Hatch_Patterns" & "\" & "*.pat", $hatch_patterns_temp_dir & "*.pat", $FC_OVERWRITE)

    FileCopy($hatch_patterns_temp_dir & "*.pat", $hatch_patterns_install_dir & "*.pat", $FC_OVERWRITE) 

    Sleep(3000)

    FileDelete("C:\Users\Public\Desktop\A360 Desktop.lnk")

    FileDelete("C:\Users\Public\Desktop\Autodesk Product Design Suite Ultimate 2017.lnk")

    _SendMessage(GUICtrlGetHandle($progress_1), $PBM_SETMARQUEE, 0, 200)

    GUICtrlSetData($progress_2, 100)

    Sleep(3000)

    MsgBox(64, "Installer complete.", "Installer has completed")

EndFunc

GUI_Create()
