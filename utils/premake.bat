%FILE_START% premake
setlocal
set PREMAKE=..\extern\bin\premake\premake5.exe
if not exist %PREMAKE% set PREMAKE=..\bootstrap\premake\premake5.exe
REM repoName action displayName fullDisplayName additionalPremakeParameters
if %~1==generate call :generate %2 %3 %4 %5 %6
REM repoName config platform solutionName displayName
if %~1==buildOnly call :buildOnly %2 %3 %4 %5 %6
REM repoName action config platform solutionName displayName fullDisplayName additionalPremakeParameters
if %~1==build call :build %2 %3 %4 %5 %6 %7 %8 %9
endlocal
goto :eof

:generate
echo. premake:generate %1 %2 %3 %4 %5
setlocal
if "%~4" NEQ "" (
    echo. *** %~4 ***
) else (
    if "%~3" NEQ "" (
        echo. *** Generate %~3 solution ***
    ) else (
        echo. *** Generate %~1 solution ***
    )
)
%INTERNAL_CALL% paths.bat getRepoPath %1 truePath
call paths.bat getRepoPath %1 truePath
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
set action=%~2
if "%action%"=="" set action=vs
if "%action%"=="visual" set action=vs
if "%action%"=="vs" set action=vs%YEAR_VISUAL%
%PRE_EXTERNAL_CALL% %PREMAKE% --file="%truePath%\premake5.lua" %action% %~5
echo %PREMAKE% --file="%truePath%\premake5.lua" %~5 %action%
%PREMAKE% --file="%truePath%\premake5.lua" %~5 %action%
endlocal
%FUNCTION_END% premake:generate %*
goto :eof

:build
%FUNCTION_START% premake:build %1 %2 %3 %4 %5 %6 %7 %8
%INTERNAL_CALL% :generate %1 %2 %6 %7 %8
call :generate %1 %2 %6 %7 %8
if not errorlevel 1 (
    %INTERNAL_CALL% :buildOnly %1 %3 %4 %5 %6
    call :buildOnly %1 %3 %4 %5 %6
)
%FUNCTION_END% premake:build %1 %2 %3 %4 %5 %6 %7 %8
goto :eof

:buildOnly
%FUNCTION_START% premake:buildOnly %1 %2 %3 %4 %5
setlocal
if "%~5" NEQ "" (
    echo. *** Build %~5 ***
) else (
    echo. *** Build %~1 ***
)
if "%~4" NEQ "" (
    set solutionName=%~4
) else (
    set solutionName=%~1.sln
)
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
%INTERNAL_CALL% vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\%solutionName%" %2 %3 default
call vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\%solutionName%" %2 %3 default
endlocal
%FUNCTION_END% premake:buildOnly %1 %2 %3 %4 %5
goto :eof
