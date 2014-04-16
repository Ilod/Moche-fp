@echo off

if %~1==getVersionVisual call :getVersionVisual %2
if %~1==getVisualYear call :getVisualYear %2
if %~1==build call :build %2 %3 %4 %5
goto :eof

:is64Bits
IF EXIST "%PROGRAMFILES(X86)%" (set "%~1=1") ELSE (set "%~1=0")
goto :eof

:getVersionVisual
set "%~1=0"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.10.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=10"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.11.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=11"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.12.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=12"
goto :eof

:getVisualYear
setlocal
call :getVersionVisual version
set year=0
if %version%==12 set year=2013
if %version%==11 set year=2012
if %version%==10 set year=2010
if %version%==9 set year=2008
if %version%==8 set year=2005
if %version%==7 set year=2003
(
endlocal
set "%~1=%year%"
)
goto :eof

:getRegistryKeyVisual
setlocal
call :is64Bits is64bits
if %is64bits%==1 (
    endlocal
    call :getRegistryKeyVisual64 %1
) else (
    endlocal
    call :getRegistryKeyVisual32 %1
)
goto :eof

:getRegistryKeyVisual64
setlocal
call :getVersionVisual VisualVersion
(
endlocal
set "%~1=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\%VisualVersion%.0\"
)
goto :eof

:getRegistryKeyVisual32
setlocal
call :getVersionVisual VisualVersion
(
endlocal
set "%~1=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\%VisualVersion%.0\"
)
goto :eof

:getPathVisual
setlocal
call :getRegistryKeyVisual KEY_NAME
for /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v InstallDir 2^>nul`) DO (
    set ValueValue=%%C
)
(
endlocal
set "%~1=%ValueValue%"
)
goto :eof

:getPathVCVars
setlocal
call :getPathVisual PATH_VISUAL
(
endlocal
set "%~1=%PATH_VISUAL%..\..\VC\vcvarsall.bat"
)
goto :eof

:setupEnv
setlocal
call :getPathVCVars PATH_VCVARS
call :is64bits IS_64_BITS
if %IS_64_BITS%==1 (
    set PLATFORM=amd64
) else (
    set PLATFORM=x86
)
(
endlocal
call "%PATH_VCVARS%" %PLATFORM%
)
goto :eof

:build
setlocal
call :is64Bits is64
call :getVisualYear visualYear
set buildToolset=%~2
if "%~2"=="" (
    set buildToolset=LLVM-vs-%visualYear%
)
if "%~2"=="llvm" (
    set buildToolset=LLVM-vs-%visualYear%
)
if "%~2"=="clang" (
    set buildToolset=LLVM-vs-%visualYear%
)
if "%~2"=="visual" (
    set buildToolset=""
)
if "%~2"=="vs" (
    set buildToolset=""
)
if %buildToolset%=="" (
    set buildToolsetArgument=""
) else (
    set buildToolsetArgument="/p:PlatformToolset=%buildToolset%"
)

if %is64%==1 (
    set defaultPlatform=x64
) else (
    set defaultPlatform=Win32
)
if "%~3"=="" (
    set buildPlatform=%defaultPlatform%
) else (
    set buildPlatform=%2
)
if "%~4"=="" (
    set buildConfig=Release
) else (
    set buildConfig=%4
)
call :setupEnv
msbuild "..\%~1" %buildToolsetArgument% /p:Configuration=%buildConfig% /p:Platform=%buildPlatform%
endlocal
goto :eof
