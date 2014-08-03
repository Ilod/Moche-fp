@echo off
call "%~dp0\utils\init_log.bat"
call "%~dp0\utils\cmake.bat" install cmake "" "" vs
if errorlevel 1 (
    echo. Fatal error building CMake
    pause
    exit /B %errorlevel%
)
call "%~dp0\utils\get_extern.bat"
REM To fix
REM call :checkClang
call "%~dp0\utils\build_extern.bat"
if errorlevel 1 (
    echo. Fatal error building extern tools
    pause
    exit /B %errorlevel%
)
popd
echo. Build finished
pause
goto :eof

:checkClang
echo. *** Search existing Clang Visual Studio integration ***
call "%~dp0\utils\vs.bat" getVisualVersion VERSION_VISUAL
call "%~dp0\utils\vs.bat" getVisualYear YEAR_VISUAL
call "%~dp0\utils\vs.bat" getPlatform "" PLATFORM
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
call "%~dp0\utils\cmake.bat" install llvm "" "" "vs" "LLVM/CLang compiled by MSVC"
goto :eof