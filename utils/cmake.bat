%FILE_START% cmake
setlocal
set CMAKE=..\extern\bin\cmake\bin\cmake.exe
if not exist %CMAKE% set CMAKE=..\bootstrap\cmake\bin\cmake.exe
REM repoName platform toolset displayName
if %1==generate call :generate %2 %3 %4 %5
REM repoName config platform toolset displayName
if %1==buildOnly call :buildOnly %2 %3 %4 %5 %6
REM repoName config platform toolset displayName
if %1==build call :build %2 %3 %4 %5 %6
REM repoName config platform toolset displayName
if %1==installOnly call :installOnly %2 %3 %4 %5 %6
REM repoName config platform toolset displayName
if %1==install call :install %2 %3 %4 %5 %6
endlocal
goto :eof

:generate
%FUNCTION_START% cmake:generate %1 %2 %3 %4
setlocal
if "%~4" NEQ "" (
    echo. *** Generate %~4 solution ***
) else (
    echo. *** Generate %~1 solution ***
)
%INTERNAL_CALL% paths.bat getRepoPath %1 truePath
call paths.bat getRepoPath %1 truePath
%INTERNAL_CALL% vs.bat getVersionVisual VERSION_VISUAL
call vs.bat getVersionVisual VERSION_VISUAL
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
%INTERNAL_CALL% vs.bat getPlatform "%~2" PLATFORM_FOLDER
call vs.bat getPlatform "%~2" PLATFORM_FOLDER
%INTERNAL_CALL% vs.bat getToolset "%~3" buildToolset
call vs.bat getToolset "%~3" buildToolset
REM Can't make cmake run with Clang, so default toolset for now
set buildToolset=""
if "%PLATFORM_FOLDER%"=="x64" (
    set PLATFORM_SUFFIX=" Win64"
) else (
    set PLATFORM_SUFFIX=""
)
if %buildToolset%=="" (
    set TOOLSET=
) else (
    set PLATFORM_FOLDER=%PLATFORM_FOLDER%_%buildToolset%
    set TOOLSET=-T %buildToolset%
)
set PLATFORM_SUFFIX=%PLATFORM_SUFFIX:"=%
set oldDir=%CD%
%PRE_EXTERNAL_CALL% mkdir "..\extern\build\%~1\build\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%"
%EXTERNAL_CALL% mkdir "..\extern\build\%~1\build\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%"
mkdir "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%" 1>nul 2>nul
cd "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%"
%PRE_EXTERNAL_CALL% %oldDir%\%CMAKE% -G "Visual Studio %VERSION_VISUAL%%PLATFORM_SUFFIX%" -DCMAKE_INSTALL_PREFIX="%oldDir%\..\extern\bin\%~1" %TOOLSET% "%oldDir%\%truePath%"
%EXTERNAL_CALL% %oldDir%\%CMAKE% -G "Visual Studio %VERSION_VISUAL%%PLATFORM_SUFFIX%" -DCMAKE_INSTALL_PREFIX="%oldDir%\..\extern\bin\%~1" %TOOLSET% "%oldDir%\%truePath%"
%oldDir%\%CMAKE% -G "Visual Studio %VERSION_VISUAL%%PLATFORM_SUFFIX%" -DCMAKE_INSTALL_PREFIX="%oldDir%\..\extern\bin\%~1" %TOOLSET% "%oldDir%\%truePath%" %TRACE%
cd %oldDir%
endlocal
%FUNCTION_END% cmake:generate %1 %2 %3 %4
goto :eof

:build
%FUNCTION_START% cmake:build %1 %2 %3 %4 %5
%INTERNAL_CALL% :generate %1 %3 %4 %5
call :generate %1 %3 %4 %5
%INTERNAL_CALL% :buildOnly %1 %2 %3 %4 %5
call :buildOnly %1 %2 %3 %4 %5
%FUNCTION_END% cmake:build %1 %2 %3 %4 %5
goto :eof

:buildOnly
%FUNCTION_START% cmake:buildOnly %1 %2 %3 %4 %5
setlocal
if "%~5" NEQ "" (
    echo. *** Build %~5 ***
) else (
    echo. *** Build %~1 ***
)
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
%INTERNAL_CALL% vs.bat getPlatform "%~3" PLATFORM_FOLDER
call vs.bat getPlatform "%~3" PLATFORM_FOLDER
%INTERNAL_CALL% vs.bat getToolset "%~4" buildToolset
call vs.bat getToolset "%~4" buildToolset
REM Can't make cmake run with Clang, so default toolset for now
set buildToolset=""
if %buildToolset%=="" (
    set PLATFORM_FOLDER=%PLATFORM_FOLDER%
) else (
    set PLATFORM_FOLDER=%PLATFORM_FOLDER%_%buildToolset%
)
%INTERNAL_CALL% vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\ALL_BUILD.vcxproj" %2 %3 %4
call vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\ALL_BUILD.vcxproj" %2 %3 %4
endlocal
%FUNCTION_END% cmake:buildOnly %1 %2 %3 %4 %5
goto :eof

:install
%FUNCTION_START% cmake:install %1 %2 %3 %4 %5
call :build  %1 %2 %3 %4 %5
call :installOnly %1 %2 %3 %4 %5
%FUNCTION_END% cmake:install %1 %2 %3 %4 %5
goto :eof

:installOnly
%FUNCTION_START% cmake:installOnly %1 %2 %3 %4 %5
if "%~5" NEQ "" (
    echo. *** Install %~5 ***
) else (
    echo. *** Install %~1 ***
)
%PRE_EXTERNAL_CALL% rmdir /S /Q "..\extern\bin\%~1"
%EXTERNAL_CALL% rmdir /S /Q "..\extern\bin\%~1"
%INTERNAL_CALL% vs.bat getVisualYear YEAR_VISUAL
call vs.bat getVisualYear YEAR_VISUAL
%INTERNAL_CALL% vs.bat getPlatform "%~3" PLATFORM_FOLDER
call vs.bat getPlatform "%~3" PLATFORM_FOLDER
%INTERNAL_CALL% vs.bat getToolset "%~4" buildToolset
call vs.bat getToolset "%~4" buildToolset
REM Can't make cmake run with Clang, so default toolset for now
set buildToolset=""
if %buildToolset%=="" (
    set PLATFORM_FOLDER=%PLATFORM_FOLDER%
) else (
    set PLATFORM_FOLDER=%PLATFORM_FOLDER%_%buildToolset%
)
%INTERNAL_CALL% vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\INSTALL.vcxproj" %2 %3 %4
call vs.bat build "..\extern\build\%~1\vs%YEAR_VISUAL%\%PLATFORM_FOLDER%\INSTALL.vcxproj" %2 %3 %4
%FUNCTION_END% cmake:installOnly %1 %2 %3 %4 %5
goto :eof