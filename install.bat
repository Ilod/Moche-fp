@echo off
pushd utils
call init_log.bat
call cmake.bat install cmake "" "" vs
call get_extern.bat
REM To fix
REM call :checkClang
call build_extern.bat
popd
goto :eof

:checkClang
echo. *** Search existing Clang Visual Studio integration ***
call vs.bat getVisualVersion VERSION_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
call vs.bat getPlatform "" PLATFORM
if "%VERSION_VISUAL%"=="12" set FOLDER_MSBUILD=\120
if "%VERSION_VISUAL%"=="11" set FOLDER_MSBUILD=\110
set FOUND=0
set D="%ProgramFiles%\MSBuild\Microsoft.Cpp\v4.0%FOLDER_MSBUILD%\Platforms\%PLATFORM%\PlatformToolsets\LLVM-vs%YEAR_VISUAL%"
if exist %D% set FOUND=1
set D="%ProgramFiles(x86)%\MSBuild\Microsoft.Cpp\v4.0%FOLDER_MSBUILD%\Platforms\%PLATFORM%\PlatformToolsets\LLVM-vs%YEAR_VISUAL%"
if exist %D% set FOUND=1
if %FOUND%==1 call :firstClang
if %FOUND%==0 echo. *** Existing Clang installation found ***
goto :eof

:firstClang
echo. *** Visual Studio Clang not found ***
call cmake.bat install llvm "" "" "vs" "LLVM/CLang compiled by MSVC"
goto :eof