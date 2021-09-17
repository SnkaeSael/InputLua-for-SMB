rem encode method by slither, script by Mizumaririn
rem drag the first avi to this batch to encode it in 1440p
@echo off
set p=%~nx1
if "%p%"=="" (
echo drag the first file
pause
exit
)
set /a count=2
:loop
set bool=0
setlocal enabledelayedexpansion
for /r %%a in (*) do if "%%~nxa" =="%~n1_part!count!%~x1" (
set p=!p:^|=^|!^^^|%%~nxa
set /a count+=1
set bool=1
)
if %bool%==1 goto loop
set /a count -=1
echo %count% parts found
pause
if %count%==1 (
set q="%p%"
) else (
set q="%~n1contact.mkv"
ffmpeg -i "concat:%p%" -c:v ffv1 -c:a copy !q!
)
ffmpeg -i %q% -c:v h264 -c:a copy -s 1536x1440 -sws_flags neighbor "%~n1encoded.mkv"
echo done
pause
exit

if you can understand the code, this batch file won't hurt your computer
p = the file you dragged into e.g. smb.avi
if no argument, exit
count = _part2
label loop
for each file in directory {
	if file == part count of p e.g. smb_part2.avi, p=p|file e.g. smb.avi|smb_part2.avi
	count++
}
if file found, goto loop (breaks when no more files found)
if more than 1 file, contact them
upscale
