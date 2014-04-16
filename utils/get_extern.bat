@echo off
echo. *** Checkout LLVM ***
call svn.bat get llvm http://llvm.org/svn/llvm-project/llvm/trunk
call svn.bat get llvm\tools\clang http://llvm.org/svn/llvm-project/cfe/trunk
call svn.bat get llvm\tools\clang\tools\extra http://llvm.org/svn/llvm-project/clang-tools-extra/trunk
call svn.bat get llvm\projects\compiler-rt http://llvm.org/svn/llvm-project/compiler-rt/trunk
echo. *** LLVM checkout done ***

