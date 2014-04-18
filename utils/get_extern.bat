%FILE_START% get_extern.bat
%INTERNAL_CALL% svn.bat get llvm http://llvm.org/svn/llvm-project/llvm/trunk
call svn.bat get llvm http://llvm.org/svn/llvm-project/llvm/trunk "LLVM"
%INTERNAL_CALL% svn.bat get llvm\tools\clang http://llvm.org/svn/llvm-project/cfe/trunk
call svn.bat get llvm\tools\clang http://llvm.org/svn/llvm-project/cfe/trunk "CLang"
%INTERNAL_CALL% svn.bat get llvm\tools\clang\tools\extra http://llvm.org/svn/llvm-project/clang-tools-extra/trunk "CLang extras"
call svn.bat get llvm\tools\clang\tools\extra http://llvm.org/svn/llvm-project/clang-tools-extra/trunk
%INTERNAL_CALL% svn.bat get llvm\projects\compiler-rt http://llvm.org/svn/llvm-project/compiler-rt/trunk
call svn.bat get llvm\projects\compiler-rt http://llvm.org/svn/llvm-project/compiler-rt/trunk "LLVM Compiler-rt"