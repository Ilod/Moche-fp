@echo off

SETLOCAL
set SVN=..\extern_bin\svn\bin\svn.exe
set SVN_REPOS=..\extern_repo\
if %~1==get call :get %2 %3
if %~1==checkout call :checkout %2 %3
if %~1==update call :checkout %2
if %~1==check call :check %2
ENDLOCAL
goto :eof

:get
call :check %1
if not errorlevel 1 (
call :update %1
) else (
call :checkout %1 %2
)
goto :eof

:checkout
%SVN% co %2 "%SVN_REPOS%%~1" >nul
goto :eof

:update
%SVN% update "%SVN_REPOS%%~1" >nul
goto :eof

:check
%SVN% info "%SVN_REPOS%%~1"  >nul 2>nul
goto :eof


