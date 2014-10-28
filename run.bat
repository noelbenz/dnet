
del bin\main.exe

dmd -odbin -ofbin/main.exe main.d net.d

start server.bat
start client.bat

pause
