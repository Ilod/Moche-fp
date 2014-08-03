%FILE_START% vs
if %~1==getVersionVisual call :getVersionVisual %2
if %~1==getVisualYear call :getVisualYear %2
if %~1==getPlatform call :getPlatform %2 %3
if %~1==getToolset call :getToolset %2 %3
if %~1==build call :build %2 %3 %4 %5
goto :eof

:is64Bits
%FUNCTION_START% vs:is64Bits %1
IF EXIST "%PROGRAMFILES(X86)%" (set "%~1=1") ELSE (set "%~1=0")
%FUNCTION_END% vs:is64Bits %1
goto :eof

:getVersionVisual
%FUNCTION_START% vs:getVersionVisual %1
set "%~1=0"
%PRE_EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.10.0"
%EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.10.0"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.10.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=10"
%PRE_EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.11.0"
%EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.11.0"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.11.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=11"
%PRE_EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.12.0"
%EXTERNAL_CALL% reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.12.0"
reg query "HKEY_CLASSES_ROOT\VisualStudio.DTE.12.0" >> nul 2>&1
if %ERRORLEVEL% EQU 0 set "%~1=12"
%FUNCTION_END% vs:getVersionVisual %1
goto :eof

:getPlatform
%FUNCTION_START% vs:getPlatform %1 %2
setlocal
call :is64Bits is64
if %is64%==1 (
    set defaultPlatform=x64
) else (
    set defaultPlatform=Win32
)
if "%~1"=="" (
    set buildPlatform=%defaultPlatform%
) else (
    set buildPlatform=%~1
)
(
endlocal
set "%~2=%buildPlatform%"
)
%FUNCTION_END% vs:getPlatform %1 %2
goto :eof

:getToolset
%FUNCTION_START% vs:getToolset %1 %2
setlocal
set _ts="%~1"
call :getVisualYear _vsy
if "%~1"=="" (
    set _ts=LLVM-vs%_vsy%
)
if "%~1"=="llvm" (
    set _ts=LLVM-vs%_vsy%
)
if "%~1"=="clang" (
    set _ts=LLVM-vs%_vsy%
)
if "%~1"=="visual" (
    set _ts=""
)
if "%~1"=="vs" (
    set _ts=""
)
if "%~1"=="default" (
    set _ts=""
)
(
endlocal
set "%~2=%_ts%"
)
%FUNCTION_END% vs:getToolset %1 %2
goto :eof

:getVisualYear
%FUNCTION_START% vs:getVisualYear %1
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
%FUNCTION_END% vs:getVisualYear %1
goto :eof

:getRegistryKeyVisual
%FUNCTION_START% vs:getRegistryKeyVisual %1
setlocal
call :is64Bits is64bits
if %is64bits%==1 (
    endlocal
    call :getRegistryKeyVisual64 %1
) else (
    endlocal
    call :getRegistryKeyVisual32 %1
)
%FUNCTION_END% vs:getRegistryKeyVisual %1
goto :eof

:getRegistryKeyVisual64
%FUNCTION_START% vs:getRegistryKeyVisual64 %1
setlocal
call :getVersionVisual VisualVersion
(
endlocal
set "%~1=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\%VisualVersion%.0\"
)
%FUNCTION_END% vs:getRegistryKeyVisual64 %1
goto :eof

:getRegistryKeyVisual32
%FUNCTION_START% vs:getRegistryKeyVisual32 %1
setlocal
call :getVersionVisual VisualVersion
(
endlocal
set "%~1=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\%VisualVersion%.0\"
)
%FUNCTION_END% vs:getRegistryKeyVisual32 %1
goto :eof

:getPathVisual
%FUNCTION_START% vs:getPathVisual %1
setlocal
call :getRegistryKeyVisual KEY_NAME
for /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v InstallDir 2^>nul`) DO (
    set ValueValue=%%C
)
(
endlocal
set "%~1=%ValueValue%"
)
%FUNCTION_END% vs:getPathVisual %1
goto :eof

:getPathVCVars
%FUNCTION_START% vs:getPathVCVars %1
setlocal
call :getPathVisual PATH_VISUAL
(
endlocal
set "%~1=%PATH_VISUAL%..\..\VC\vcvarsall.bat"
)
%FUNCTION_END% vs:getPathVCVars %1
goto :eof

:setupEnv
%FUNCTION_START% vs:setupEnv
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
%PRE_EXTERNAL_CALL% "%PATH_VCVARS%" %PLATFORM%
%EXTERNAL_CALL% "%PATH_VCVARS%" %PLATFORM%
call "%PATH_VCVARS%" %PLATFORM% %TRACE%
)
%FUNCTION_END% vs:setupEnv
goto :eof

:build
%FUNCTION_START% vs:build %1 %2 %3 %4
setlocal

call :is64Bits is64
call :getVisualYear visualYear

if "%~2"=="" (
    set buildConfig=Release
) else (
    set buildConfig=%2
)

call :getPlatform "%~3" buildPlatform
call :getToolset "%~4" buildToolset

if %buildToolset%=="" (
    set buildToolsetArgument=""
) else (
    set buildToolsetArgument="/p:PlatformToolset=%buildToolset%"
)
call :setupEnv
%PRE_EXTERNAL_CALL% msbuild "%~1" %buildToolsetArgument% /nologo /p:Configuration=%buildConfig% /p:Platform=%buildPlatform% %MSBUILDTRACE_EXTERN%
%EXTERNAL_CALL% msbuild "%~1" %buildToolsetArgument% /nologo /p:Configuration=%buildConfig% /p:Platform=%buildPlatform% %MSBUILDTRACE_EXTERN%
msbuild "%~1" %buildToolsetArgument% /nologo /p:Configuration=%buildConfig% /p:Platform=%buildPlatform% %MSBUILDTRACE_EXTERN%
endlocal
%FUNCTION_END% vs:build %1 %2 %3 %4
goto :eof
