#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
#SingleInstance Force
#Include %A_ScriptDir%\DarkGui\Class_ImageButton.ahk
#Include %A_ScriptDir%\DarkGui\UseGDIP.ahk
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

Gui, Add, Text, x25 y20 w280 h20 +Center cwhite, Select an action.

Gui, Add, Button, hwndHBT1 vUpscale gUpscale x25 w134 h30 , Real-plus
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 vAnimeUpscale gAnimeUpscale x+12 wp hp , Anime
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 vRealSRUpscale gRealSRUpscale x25 y+12 wp hp , Real
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 vBSRGANUpscale gBSRGANUpscale x+12 wp hp , BSRGAN
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, Button, hwndHBT1 vAnimeVideoUpscale gAnimeVideoUpscale x25 y+30 w280 hp , Anime Video Upscale
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)

Gui, Add, CheckBox, Checked vFFMPEG x26 y+15 h20 w20,
Gui, Add, Text, x+-0 y+-18 w95 h20 +Left cwhite gCheckbox, installed ffmpeg

Gui, Add, Text, x+0 y+-20 w110 h20 +Right cwhite, Scale:
Gui, Add, Button, x+5 y+-25 w45 h26 hwndHBT1 vBackground1,
ImageButton.Create(HBT1, Opt1, Opt1, , , Opt1)
Gui, Add, Edit, x+-41 y+-21 h16 w40 +Center -E0x200 -Border cwhite
Gui, Add, UpDown, Hidden vscale Range2-4, 4
Gui, Add, Picture, x+-14 y+-21 gUpRound, DarkGui\UpRound.png
Gui, Add, Picture, y+-0 gDownRound, DarkGui\DownRound.png

Gui, Add, Text, vProgressText x25 y+30 w280 h16 cwhite, Progress:
Gui, Add, Button, hwndHBT1 x25 y+8 w280 h22 vBackground2,
ImageButton.Create(HBT1, Opt1, Opt2, , , Opt5)
Gui, Add, Progress, x+-279 y+-21 w278 h20 Background%GuiElementsColor% c005FB8 vProgress, 0

loop 2
	GuiControl, Disable, % "Background" . A_Index

;ControlFocus, Button1, AniRip ahk_class AutoHotkeyGUI
gui margin,25,25
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
	Gui, Submit, NoHide
	inputArray := []
	outputArray := []

	if (A_GuiControl = "Upscale") {
		model:="realesrgan-x4plus"
		fileExt:="_x4"
	}
	else if (A_GuiControl = "BSRGANUpscale") {
		model:="bsrgan-x4"
		fileExt:="_x4BSRGAN"
	}
	else if (A_GuiControl = "RealSRUpscale") {
		model:="realsrgan-x4"
		fileExt:="_x4real"
	}
	else if (A_GuiControl = "AnimeVideoUpscale") {
		fileExt:="_x4video"
	}
	else {
		model:="realesrgan-x4plus-anime"
		fileExt:="_x4anime"
	}

	Loop, Parse, A_GuiEvent, `n
	{
		if (fileExt!="_x4video" and IsImageFile(A_LoopField)) {
			inputArray.Push(A_LoopField)
			RegExMatch(A_LoopField, "(.*)(\..*)", SubPart)
			;if SubPart2=".webp"
			;	SubPart2=".png"
			outPath:=SubPart1 . fileExt . SubPart2
			outputArray.Push(outPath)
		}
		else if (fileExt="_x4video" and IsVideoFile(A_LoopField)) {
			inputArray.Push(A_LoopField)
			RegExMatch(A_LoopField, "(.*)(\..*)", SubPart)
			outPath:=SubPart1 . fileExt . SubPart2
			outputArray.Push(outPath)
		}
		else if (fileExt!="_x4video")
			msgbox %A_LoopField% `n`nThis file type is not supported. `nSupported file types are: png, jpg, webp`nThe program will skip this file.
		else if (fileExt="_x4video")
			msgbox %A_LoopField% `n`nThis file type is not supported. `nSupported file types are: mp4, mkv`nThe program will skip this file.
	}
	if (fileExt="_x4video")
		upscaleVideo(scale)
	else
		upscale(model)
return







;-------------------------------------Image Upscale via Buttons---------------------------------
Upscale:
	createArray("\Upscale_x4\")
	upscale("realesrgan-x4plus-anime")
Return

AnimeUpscale:
	createArray("\Upscale_x4Anime\")
	upscale("realesrgan-x4plus-anime")
Return

BSRGANUpscale:
	createArray("\Upscale_x4BSRGAN\")
	upscale("bsrgan-x4")
Return

RealSRUpscale:
	createArray("\Upscale_x4RealSR\")
	upscale("realsrgan-x4")
Return

createArray(folderName) {
	global inputArray := []
	global outputArray := []
	FileSelectFile, imagesToUpscale , M 1, Image File, Select the Images you want to Upscale, Images (*.png; *.jpg; *.webp)
	
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
			msgbox %A_LoopField% `n`nThis file type is not supported. `nSupported file types are: png, jpg, webp`nThe program will skip this file.
	}
}







;-------------------------------------Image Upscale Funktion---------------------------------
upscale(model) {
	global inputArray
	global outputArray

	numberOfFiles := inputArray.MaxIndex()
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress: 0`% (0/%numberOfFiles%)
	
	Loop %numberOfFiles% {
		input:=inputArray[A_Index]
		output:=outputArray[A_Index]
		RunWait, "realesrgan-ncnn-vulkan.exe" -i "%input%" -o "%output%" -n %model%, , Hide
		;if (IsImageFile(input)=3) {
		;	RunWait, %ComSpec% /c ImageMagick-7.1.0-62-portable-Q16-HDRI-x64\magick.exe "%input%" Temp\pngConvert.png, ,Hide 
		;	input:="Temp\pngConvert.png"
		;}
		if (IsImageFile(input)>1) {
			RunWait, %ComSpec% /c ImageMagick-7.1.0-62-portable-Q16-HDRI-x64\identify.exe -format '`%[channels]' "%input%" >>Temp\alpha.txt, ,Hide 
			FileRead, isAlpha, Temp\alpha.txt
			if inStr(isAlpha, "a") {
				RunWait, %ComSpec% /c ImageMagick-7.1.0-62-portable-Q16-HDRI-x64\convert.exe "%input%" -alpha extract Temp\alpha.png, ,Hide 
				RunWait, "realesrgan-ncnn-vulkan.exe" -i Temp\alpha.png -o Temp\alphaUpscale.png -n %model%, , Hide
				RunWait, %ComSpec% /c ImageMagick-7.1.0-62-portable-Q16-HDRI-x64\convert.exe "%output%" Temp\alphaUpscale.png -alpha off -compose copy_opacity -composite "%output%", ,Hide
			}
		}
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
	inputArray:=[]
	outputArray:=[]
	loop,parse,videosToUpscale,`n,`r 
	{
		if (A_Index = 1) {
			path:=A_loopfield
			continue
		}
		if IsVideoFile(A_LoopField) {
			inputArray.Push(path . "\" . A_loopfield)
			outputArray.Push(path . "\Upscale_Video\" . A_loopfield)
		}
		else
			msgbox %A_LoopField% `n`nThis file type is not supported. `nSupported file types are: mp4, mkv`nThe program will skip this file.
	}
	if (path!="") {
		FileCreateDir, %path%\Upscale_Video
	}
	upscaleVideo(scale)
Return







;-------------------------------------Video Upscale Funktion---------------------------------
upscaleVideo(scale) {
	global inputArray
	global outputArray
	
	FileCreateDir, tmp_frames
	FileCreateDir, out_frames
	numberOfFiles:=inputArray.MaxIndex()
	GuiControl,, Progress, 0
	GuiControl,, ProgressText, Progress: 0`% (0/%numberOfFiles%)
	
	Loop % numberOfFiles {
		input:=inputArray[A_Index]
		output:=outputArray[A_Index]
		;FileDelete, %output%
		
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
}









IsImageFile(filePath) {
    ; Split the file path by the dot character
	Array := StrSplit(filePath , ".")

    ; Get the last part of the split string, which should be the file extension
    fileExt := Array[Array.MaxIndex()]

    ; Check if it's an image file
    if (fileExt = "jpg")
        return 1
	else if (fileExt = "png")
        return 2
	else if (fileExt = "webp")
        return 3
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