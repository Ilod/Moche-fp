%FILE_START% build_extern.bat
call cmake.bat install llvm "" "" "" "LLVM/CLang"
if errorlevel 1 (
    echo. Error building LLVM/Clang
    exit /B %errorlevel%
)
call premake.bat generate premake5 embed "" "Generate premake embed scripts"
if errorlevel 1 (
    echo. Error generating premake5 embed scripts
    exit /B %errorlevel%
)
setlocal
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
call premake.bat build premake5 vs%YEAR_VISUAL% "" "Win32" "" "" "" "--to=%~dp0\..\extern\build\premake5\vs%YEAR_VISUAL%"
endlocal
if errorlevel 1 (
    echo. Error building premake5
    exit /B %errorlevel%
)
echo. *** Install premake5 ***
%PRE_EXTERNAL_CALL% copy /B /Y "..\submodules\premake5\bin\release\premake5.exe" ..\extern\bin\premake\premake5.exe
%EXTERNAL_CALL% copy /B /Y "..\submodules\premake5\bin\release\premake5.exe" ..\extern\bin\premake\premake5.exe
copy /B /Y "..\submodules\premake5\bin\release\premake5.exe" ..\extern\bin\premake\premake5.exe %TRACE%
if errorlevel 1 (
    echo. Error building premake5
    exit /B %errorlevel%
)
exit /B 0
goto :eof
