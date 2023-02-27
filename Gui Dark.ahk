#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
#SingleInstance Force
#Include DarkGui\Class_ImageButton.ahk
#Include DarkGui\UseGDIP.ahk
Menu, tray, Icon , UpscaleUI.ico
DetectHiddenWindows, ON

upscaler:=A_ScriptDir . "realesrgan-ncnn-vulkan.exe"

;--------------------------------UI start---------------------------

Gui, Destroy
Gui, New , HwndCustomUpscale, UpscaleUI
DllCall("dwmapi\DwmSetWindowAttribute", "ptr", CustomUpscale, "int", "20", "int*", true, "int", 4)
GuiColor := "0x171717"
GuiElementsColor := "0x333333"
Gui, Font, s10 q4, ;Poppins
Gui, Color, %GuiColor%, %GuiElementsColor%
ImageButton.SetGuiColor(GuiColor)

Opt1 := [0, GuiElementsColor, , "White", 7, , 0x555555, 1]
Opt2 := [ , 0x414141]

Gui, Add, Text, x0 y20 w350 h20 +Center cwhite, Select an action.

Gui, Add, Button, hwndHBT1 vUpscale gUpscale x25 w144 h30 , Upscale
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 vAnimeUpscale gAnimeUpscale x+12 w144 h30 , Anime Upscale
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 gAnimeVideoUpscale x25 y+12 w300 h30 , Anime Video Upscale
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, CheckBox, Checked vFFMPEG x26 y+15 h20 w20,
Gui, Add, Text, x+-0 y+-18 w95 h20 +Left cwhite gCheckbox, installed ffmpeg

Gui, Add, Text, x+0 y+-20 w130 h20 +Right cwhite, Scale factor:

Gui, Add, Button, x+5 y+-25 w45 h26 hwndHBT1 vBackground1,
ImageButton.Create(HBT1, Opt1, Opt1, , , Opt1)
Gui, Add, Edit, x+-41 y+-21 h16 w40 +Center -E0x200 -Border cwhite
Gui, Add, UpDown, Hidden vscale Range2-4, 4
Gui, Add, Picture, x+-14 y+-21 gUpRound, DarkGui\UpRound.png
Gui, Add, Picture, y+-0 gDownRound, DarkGui\DownRound.png

Gui, Add, Text, vProgressText x25 y+30 w300 h16 cwhite, Progress:
Gui, Add, Button, hwndHBT1 x25 y+8 w300 h22 vBackground2,
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)
Gui, Add, Progress, x+-299 y+-21 w298 h20 Background%GuiElementsColor% c005FB8 vProgress, 0

loop 2
	GuiControl, Disable, % "Background" . A_Index

;ControlFocus, Button1, AniRip ahk_class AutoHotkeyGUI
gui margin,0,20
Gui, Show, hide
Gui, Show
Return

UpRound:
Gui, Submit, NoHide
GuiControl, , scale, % scale + 1
return

DownRound:
Gui, Submit, NoHide
GuiControl, , scale, % scale - 1
return

Checkbox:
Gui, Submit, NoHide
GuiControl, , FFMPEG, % FFMPEG * (- 1) + 1
return







;-------------------------------------Drop files on GUI---------------------------------
GuiDropFiles:
	fileArray:=[]
	numberOfFiles:=0

	if (A_GuiControl != "Upscale") {
		model:="realesrgan-x4plus-anime"
		fileExt:="_x4anime"
	}
	else {
		model:="realesrgan-x4plus"
		fileExt:="_x4"
	}

	Loop, Parse, A_GuiEvent, `n
	{
		if IsImageFile(A_LoopField) {
			fileArray.Push(A_LoopField)
			numberOfFiles++
		}
		else
			msgbox %A_LoopField% is not a supported image type (png, jpg).
	}

	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress: 0`% (0/%numberOfFiles%)

	Loop %numberOfFiles% {
		input:=fileArray[A_Index]
		output:=SubStr(fileArray[A_Index], 1, -4) . fileExt . SubStr(fileArray[A_Index], -3, 4)
		RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n %model%, , Hide
		varProgress:=Ceil(A_Index/numberOfFiles*100)
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%A_Index%/%numberOfFiles%)
	}
return







;-------------------------------------Image Upscale via Buttons---------------------------------
Upscale:
	upscale("realesrgan-x4plus", "\Upscale_x4\")
Return

AnimeUpscale:
	upscale("realesrgan-x4plus-anime", "\Upscale_x4Anime\")
Return

upscale(model, folderName) {
	inputArray := []
	outputArray := []
	FileSelectFile, imagesToUpscale , M 1, Image File, Select the Images you want to Upscale, Images (*.png; *.jpg)
	
	loop,parse,imagesToUpscale,`n,`r 
	{
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		if IsImageFile(A_LoopField) {
			inputArray.Push(path . "\" . A_loopfield)
			outputArray.Push(path . folderName . A_loopfield)
		}
		else
			msgbox %A_LoopField% is not a supported image type (png, jpg).
	}

	numberOfFiles := inputArray.MaxIndex()
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress: 0`% (0/%numberOfFiles%)
	
	Loop %numberOfFiles% {
		input:=inputArray[A_Index]
		output:=outputArray[A_Index]
		RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n %model%, , Hide
		varProgress:=Ceil(A_Index/numberOfFiles*100)
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%A_Index%/%numberOfFiles%)
	}
}







;-------------------------------------Video Upscale via Buttons---------------------------------
AnimeVideoUpscale:
	Gui, Submit, NoHide
	
	;FileRemoveDir, tmp_frames, 1
	;FileRemoveDir, out_frames, 1
	
	; select Video
	FileSelectFile, videosToUpscale , M 1, Video File, Select the Videos you want to Upscale, Videos (*.mp4; *.mkv)
	if ErrorLevel
		return
	
	;count how many videos to upscale
	inputfileArray:=[]
	outputfileArray:=[]
	loop,parse,videosToUpscale,`n,`r 
	{
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		if IsVideoFile(A_LoopField) {
			inputfileArray.Push(path . "\" . A_loopfield)
			outputfileArray.Push(path . "\Upscale_Video\" . A_loopfield)
		}
		else
			msgbox %A_LoopField% is not a supported video type (mp4, mkv).
	}
	if (path!="") {
		FileCreateDir, %path%\Upscale_Video
	}
	
	FileCreateDir, tmp_frames
	FileCreateDir, out_frames
	numberOfFiles:=inputfileArray.MaxIndex()
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress: 0`% (0/%numberOfFiles%)
	
	Loop % numberOfFiles {
		input:=inputfileArray[A_Index]
		output:=outputfileArray[A_Index]
		FileDelete, %output%
		
		if (FFMPEG=0)
			RunWait, "FFmpeg\bin\ffmpeg.exe" -i "%input%" -qscale:v 1 -qmin 1 -qmax 1 -vsync 0 "tmp_frames/frame`%08d.jpg", , Hide
		else
			RunWait, ffmpeg -i "%input%" -qscale:v 1 -qmin 1 -qmax 1 -vsync 0 "tmp_frames/frame`%08d.jpg", , Hide
			
		varProgress:=Ceil(A_Index*0.33/numberOfFiles*100)
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, % "Progress: " . varProgress . "%" . " (" A_Index-1 . "/" . numberOfFiles . ")"
			
		RunWait, realesrgan-ncnn-vulkan.exe -i tmp_frames -o out_frames -n realesr-animevideov3 -s %scale% -f jpg, , Hide
		
		varProgress:=Ceil(A_Index*0.66/numberOfFiles*100)
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, % "Progress: " . varProgress . "%" . " (" A_Index-1 . "/" . numberOfFiles . ")"
		
		if (FFMPEG=0)
			RunWait, "FFmpeg\bin\ffmpeg.exe" -i out_frames/frame`%08d.jpg -i "%input%" -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 23.98 -pix_fmt yuv420p "%output%", , Hide
		else
			RunWait, ffmpeg -i out_frames/frame`%08d.jpg -i "%input%" -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 23.98 -pix_fmt yuv420p "%output%", , Hide
			
		varProgress:=Ceil(A_Index/numberOfFiles*100)
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%A_Index%/%numberOfFiles%)
	}
	return

IsImageFile(filePath) {
    ; Split the file path by the dot character
	Array := StrSplit(filePath , ".")

    ; Get the last part of the split string, which should be the file extension
    fileExt := Array[Array.MaxIndex()]

    ; Check if it's an image file
    if (fileExt = "jpg" or fileExt = "png")
        return 1
    else
        return 0
}

IsVideoFile(filePath) {
    ; Split the file path by the dot character
	Array := StrSplit(filePath , ".")

    ; Get the last part of the split string, which should be the file extension
    fileExt := Array[Array.MaxIndex()]

    ; Check if it's an image file
    if (fileExt = "mp4" or fileExt = "mkv")
        return 1
    else
        return 0
}

GuiClose:
ExitApp
return 