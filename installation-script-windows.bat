@echo off

::Make sure that the root directory is right, its the default one here.
set tizen-dir=C:\tizen-studio

::URL to download wgt files
set url=https://github.com/reisxd/TizenBrew/releases/latest/download

::This line goes to the same drive as tizen studio (if launching from another drive)
%tizen-dir:~0,1%:

echo:
set /p userInput="Type here the IP of your TV (make sure you set TV's dev IP to yours) : "
echo:

echo:
echo =================== WGT Download =====================
echo Downloading wgt file from releases...
echo:
curl -L "%url%/TizenBrewStandalone.wgt" -o "%tizen-dir%/TizenBrewStandalone.wgt"
echo =======================================================

echo:
echo ================= Connecting to the TV ================
cd %tizen-dir%\tools
sdb connect %userInput%
sdb devices
echo =======================================================

echo:
echo =========== Installing TizenBrew to the TV ===========
cd ide\bin
call tizen install -n %tizen-dir%\TizenBrewStandalone.wgt
echo =========================================================

cd ../..
sdb disconnect %userInput%

echo:
echo The installation process is over. If all went well, you should have TizenBrew installed on your TV.
echo:
pause
