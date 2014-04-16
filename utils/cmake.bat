@echo off
setlocal
set CMAKE=..\extern_bin\cmake\bin\cmake.exe
set PROJECTS_ROOT=..\extern_repo\
if %1==generate call :generate %2
if %1==build call :build %2 %3 %4 %5 %6
endlocal
goto :eof

:generate
setlocal
call vs.bat getVersionVisual VERSION_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
IF EXIST "%PROGRAMFILES(X86)%" (
set PLATFORM_SUFFIX=" Win64"
set PLATFORM_FOLDER=x64
) ELSE (
set PLATFORM_SUFFIX=""
set PLATFORM_FOLDER=x86
)
set PLATFORM_SUFFIX=%PLATFORM_SUFFIX:"=%
set oldDir=%CD%
mkdir "%PROJECTS_ROOT%%~1\build\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%" 2>nul
cd "%PROJECTS_ROOT%%~1\build\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%"
%oldDir%\%CMAKE% -G "Visual Studio %VERSION_VISUAL%%PLATFORM_SUFFIX%" "..\..\.." 1>nul
cd %oldDir%
endlocal
goto :eof

:build
setlocal
call vs.bat getVisualYear YEAR_VISUAL
IF EXIST "%PROGRAMFILES(X86)%" (
set PLATFORM_FOLDER=x64
) ELSE (
set PLATFORM_FOLDER=x86
)
call vs.bat build "extern_repo\%~1\build\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\%~2" %3 %4 %5
endlocal
goto :eof