%FILE_START% paths
if %~1==getRepoPath call :getRepoPath %2 %3
goto :eof

:getRepoPath
%FUNCTION_START% paths:getRepoPath %1 %2
if exist "..\submodules\%~1" (
set "%~2=..\submodules\%~1"
) else (
set "%~2=..\extern\repos\%~1"
)
%FUNCTION_END% path:getRepoPath %1 %2
goto :eof
