%FILE_START% svn
SETLOCAL
set SVN=..\bootstrap\svn\bin\svn.exe
set SVN_REPOS=..\extern\repos\
if %~1==get call :get %2 %3 %4
if %~1==checkout call :checkout %2 %3
if %~1==update call :update %2
if %~1==check call :check %2
ENDLOCAL
goto :eof

:get
%FUNCTION_START% svn:get %1 %2 %3
if "%~3" NEQ "" (
    echo. *** Checkout %~3 repository ***
) else (
    echo. *** Checkout %~1 repository ***
)
call :check %1
if not errorlevel 1 (
call :update %1
) else (
call :checkout %1 %2
)
if "%~3" NEQ "" (
    echo. *** %~3 checkout done ***
) else (
    echo. *** %~1 checkout done ***
)
%FUNCTION_END% svn:get %1 %2 %3
goto :eof

:checkout
%FUNCTION_START% svn:checkout %1 %2
%PRE_EXTERNAL_CALL% %SVN% co %2 "%SVN_REPOS%%~1"
%EXTERNAL_CALL% %SVN% co %2 "%SVN_REPOS%%~1"
%SVN% co %2 "%SVN_REPOS%%~1" %TRACE%
%FUNCTION_END% svn:checkout %1 %2
goto :eof

:update
%FUNCTION_START% svn:update %1
%PRE_EXTERNAL_CALL% %SVN% update "%SVN_REPOS%%~1"
%EXTERNAL_CALL% %SVN% update "%SVN_REPOS%%~1"
%SVN% update "%SVN_REPOS%%~1" %TRACE%
%FUNCTION_END% svn:update %1
goto :eof

:check
%FUNCTION_START% svn:check %1
%PRE_EXTERNAL_CALL% %SVN% info "%SVN_REPOS%%~1"
%EXTERNAL_CALL% %SVN% info "%SVN_REPOS%%~1"
%SVN% info "%SVN_REPOS%%~1"  >nul 2>nul
%FUNCTION_END% svn:check %1
goto :eof
