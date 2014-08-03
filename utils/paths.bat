%FILE_START% paths
if %~1==getRepoPath call :getRepoPath %2 %3
goto :eof

:getRepoPath
%FUNCTION_START% paths:getRepoPath %1 %2
if exist "%~dp0\..\submodules\%~1" (
set "%~2=%~dp0\..\submodules\%~1"
) else (
set "%~2=%~dp0\..\extern\repos\%~1"
)
%FUNCTION_END% path:getRepoPath %1 %2
goto :eof
