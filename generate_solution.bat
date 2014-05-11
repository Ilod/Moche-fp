@echo off
pushd utils
call init_log.bat
call vs.bat getVisualYear YEAR_VISUAL
popd
extern\bin\premake\premake5.exe --file=premake\premake5.lua vs%YEAR_VISUAL% --folder=..\engine
