%FILE_START% get_extern.bat
%PRE_EXTERNAL_CALL% mklink /J ..\submodules\llvm\tools\clang ..\submodules\clang 1>nul 2>nul
%EXTERNAL_CALL% mklink /J ..\submodules\llvm\tools\clang ..\submodules\clang 1>nul 2>nul
mklink /J ..\submodules\llvm\tools\clang ..\submodules\clang 1>nul 2>nul
%PRE_EXTERNAL_CALL% mklink /J ..\submodules\llvm\tools\clang\tools\extra ..\submodules\clang-tools-extra 1>nul 2>nul
%EXTERNAL_CALL% mklink /J ..\submodules\llvm\tools\clang\tools\extra ..\submodules\clang-tools-extra 1>nul 2>nul
mklink /J ..\submodules\llvm\tools\clang\tools\extra ..\submodules\clang-tools-extra 1>nul 2>nul
%PRE_EXTERNAL_CALL% mklink /J ..\submodules\llvm\projects\compiler-rt ..\submodules\compiler-rt 1>nul 2>nul
%EXTERNAL_CALL% mklink /J ..\submodules\llvm\projects\compiler-rt ..\submodules\compiler-rt 1>nul 2>nul
mklink /J ..\submodules\llvm\projects\compiler-rt ..\submodules\compiler-rt 1>nul 2>nul