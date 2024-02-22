@echo off

::Make sure that the root directory is right, its the default one here.
set tizen-dir=C:\tizen-studio

::URL to download wgt files
set url=https://github.com/ThowZzy/install-tizenbrew/releases/latest/download

::This line goes to the same drive as tizen studio (if launching from another drive)
%tizen-dir:~0,1%:

echo:
echo =================== WGT Download =====================
echo Downloading wgt file from releases...
echo:
curl -L "%url%/TizenBrew.wgt" -o "%tizen-dir%/TizenBrew.wgt"
echo =======================================================

echo:
set /p userInput="Type here the IP of your TV (make sure you set TV's dev IP to yours) : "
echo:

echo:
echo ================= Connecting to the TV ================
cd %tizen-dir%\tools
sdb connect %userInput%
sdb devices
echo =======================================================

echo:
echo =========== Installing applications to the TV ===========
cd ide\bin
call tizen install -n %tizen-dir%\TizenBrew.wgt
echo =========================================================

cd ../..
sdb disconnect %userInput%

echo:
echo The installation process is over. If all went well, you should have the Launcher and TizenTube installed on your TV.
echo:
pause
