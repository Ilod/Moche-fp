setlocal
IF EXIST "%PROGRAMFILES(X86)%" (
    SET SUFFIX=32
) ELSE (
    SET SUFFIX=64
)
call ..\extern_bin\elevation\IsElevated%SUFFIX%.exe -q
if ERRORLEVEL EQU 0 goto :elevate
call install_clang_admin.bat %1
endlocal
goto :eof

:elevate
call ..\extern_bin\elevation\Elevate%SUFFIX%.exe -w -- cmd.exe /C "%~dp0\install_clang_admin.bat %1"
endlocal
goto :eof