@echo off
echo. *** Generate LLVM solution ***
call cmake.bat generate llvm
echo. *** Build LLVM solution ***
call cmake.bat build llvm LLVM.sln vs
