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

Gui, Add, Button, hwndHBT1 gUpscale x25 w144 h30 , Upscale
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 gAnimeUpscale x+12 w144 h30 , Anime Upscale
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

GuiDropFiles:
GuiControl,, Progress, 0
GuiControl,, ProgressText, Progress: 0`%
fileArray:=[]
numberOfFiles:=0

Loop, Parse, A_GuiEvent, `n
{
	if IsImageFile(A_LoopField) {
		fileArray.Push(A_LoopField)
		numberOfFiles++
	}
}
Loop, % fileArray.MaxIndex()
{
	input:=fileArray[A_Index]
	output:=SubStr(fileArray[A_Index], 1, -4) . "_AnimeUpscale" . SubStr(fileArray[A_Index], -3, 4)
	RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n realesrgan-x4plus-anime, , Hide
	varProgress:=Ceil(A_Index/numberOfFiles*100)
	GuiControl,, Progress, %varProgress%
	GuiControl,, ProgressText, Progress: %varProgress%`% (%A_Index%/%numberOfFiles%)
}
return

Upscale:
	Gui, Submit, NoHide
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress:
	
	FileSelectFile, imagesToUpscale , M 1, Image File, Select the Images you want to Upscale, Images (*.png; *.jpg)

	i:=0
	inputfileArray:=[]
	outputfileArray:=[]
	loop,parse,imagesToUpscale,`n,`r 
	{
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		inputDir:=path . "\" . A_loopfield
		outputDir:=path . "\Upscale-x4\" . A_loopfield
		inputfileArray.Push(inputDir)
		outputfileArray.Push(outputDir)
	}
	numberOfFiles:=inputfileArray.MaxIndex()
	i:=1
	Loop % numberOfFiles {
		input:=inputfileArray[i]
		output:=outputfileArray[i]
		RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n realesrgan-x4plus, , Hide
		varProgress:=Floor(i/numberOfFiles*100)
		if (numberOfFiles=i)
			varProgress:=100
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%i%/%numberOfFiles%)
		i++
	}
	;msgbox finished :)
	return



AnimeUpscale:
	Gui, Submit, NoHide
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress:
	
	FileSelectFile, imagesToUpscale , M 1, Image File, Select the Images you want to Upscale, Images (*.png; *.jpg)

	i:=0
	inputfileArray:=[]
	outputfileArray:=[]
	loop,parse,imagesToUpscale,`n,`r 
	{
		msgbox % A_loopfield
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		inputDir:=path . "\" . A_loopfield
		outputDir:=path . "\Upscale-x4-Anime\" . A_loopfield
		inputfileArray.Push(inputDir)
		outputfileArray.Push(outputDir)
	}
	numberOfFiles:=inputfileArray.MaxIndex()
	i:=1
	Loop % numberOfFiles {
		input:=inputfileArray[i]
		output:=outputfileArray[i]
		RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n realesrgan-x4plus-anime, , Hide
		varProgress:=Floor(i/numberOfFiles*100)
		if (numberOfFiles=i)
			varProgress:=100
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%i%/%numberOfFiles%)
		i++
	}
	;msgbox finished :)
	return

AnimeVideoUpscale:
	Gui, Submit, NoHide
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress:
	
	FileSelectFile, videosToUpscale , M 1, Video File, Select the Videos you want to Upscale, Videos (*.mp4; *.mkv)

	i:=0
	inputfileArray:=[]
	outputfileArray:=[]
	loop,parse,videosToUpscale,`n,`r 
	{
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		inputDir:=path . "\" . A_loopfield
		outputDir:=path . "\Upscale-Video\" . A_loopfield
		inputfileArray.Push(inputDir)
		outputfileArray.Push(outputDir)
	}
	if (path!="") {
		FileCreateDir, %path%\Upscale-Video
	}
	numberOfFiles:=inputfileArray.MaxIndex()
	i:=1
	Loop % numberOfFiles {
		input:=inputfileArray[i]
		output:=outputfileArray[i]
		percent:="%"
		if (FFMPEG=0) {
			RunWait, "FFmpeg\bin\ffmpeg.exe" -i "%input%" -qscale:v 1 -qmin 1 -qmax 1 -vsync 0 "tmp_frames/frame%percent%08d.jpg", , Hide
		}
		else {
			RunWait, ffmpeg -i "%input%" -qscale:v 1 -qmin 1 -qmax 1 -vsync 0 "tmp_frames/frame%percent%08d.jpg", , Hide
		}
		RunWait, realesrgan-ncnn-vulkan.exe -i tmp_frames -o out_frames -n realesr-animevideov3 -s %scale% -f jpg, , Hide
		if (FFMPEG=0) {
			RunWait, "FFmpeg\bin\ffmpeg.exe" -i out_frames/frame%percent%08d.jpg -i "%input%" -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 23.98 -pix_fmt yuv420p "%output%", , Hide
		}
		else {
			RunWait, ffmpeg -i out_frames/frame%percent%08d.jpg -i "%input%" -map 0:v:0 -map 1:a:0 -c:a copy -c:v libx264 -r 23.98 -pix_fmt yuv420p "%output%", , Hide
		}
		varProgress:=Floor(i/numberOfFiles*100)
		if (numberOfFiles=i)
			varProgress:=100
		GuiControl,, Progress, %varProgress%
		GuiControl,, ProgressText, Progress: %varProgress%`% (%i%/%numberOfFiles%)
		i++
	}
	;msgbox finished :)
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

GuiClose:
ExitApp
return 