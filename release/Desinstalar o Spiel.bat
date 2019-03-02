title "Desinstalar o Spiel"
wmic product where name="spiel" call uninstall /nointeractive
rmdir /S /Q "%PROGRAMFILES(X86)%\spiel"
rmdir /S /Q "%PROGRAMFILES%\spiel"
echo off
cls
echo O Spiel foi desinstalado com sucesso.
pause