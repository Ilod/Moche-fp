%FILE_START% build_extern.bat
call cmake.bat install llvm "" "" "" "LLVM/CLang"
if errorlevel 1 (
    echo. Error building LLVM/Clang
    pause
    exit /B %errorlevel%
)