%FILE_START% build_extern.bat
call cmake.bat install llvm "" "" "" "LLVM/CLang"
if errorlevel 1 (
    echo. Error building LLVM/Clang
    exit /B %errorlevel%
)
exit /B 0