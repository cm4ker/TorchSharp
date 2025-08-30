@if "%_echo%" neq "on" echo off
rem
rem This file invokes cmake and generates the build system for windows.

set argC=0
for %%x in (%*) do Set /A argC+=1

if NOT %argC%==3 GOTO :USAGE
if %1=="/?" GOTO :USAGE

setlocal
set __sourceDir=%~dp0

set __ExtraCmakeParams=

set __VSString=%2
 :: Remove quotes
set __VSString=%__VSString:"=%



if defined CMakePath goto DoGen

:: Eval the output from probe-win1.ps1
pushd "%__sourceDir%"
for /f "delims=" %%a in ('powershell -NoProfile -ExecutionPolicy ByPass "& .\probe-win.ps1"') do %%a
popd

:DoGen
:: Set the target architecture to a format cmake understands.
if /i "%3" == "x64"     (set __ExtraCmakeParams=%__ExtraCmakeParams% -A x64)
if /i "%3" == "x86"     (set __ExtraCmakeParams=%__ExtraCmakeParams% -A Win32)
if /i "%3" == "arm64"   (set __ExtraCmakeParams=%__ExtraCmakeParams% -A ARM64)

echo "%CMakePath%" "-DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE%" "-DCMAKE_INSTALL_PREFIX=%__CMakeBinDir%" "-DLIBTORCH_PATH=%LIBTORCH_PATH%" -G "Visual Studio %__VSString%" %__ExtraCmakeParams% -B. -H%1
"%CMakePath%" "-DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE%" "-DCMAKE_INSTALL_PREFIX=%__CMakeBinDir%" "-DLIBTORCH_PATH=%LIBTORCH_PATH%" -G "Visual Studio %__VSString%" %__ExtraCmakeParams% -B. -H%1
endlocal
GOTO :DONE

:USAGE
  echo "Usage..."
  echo "gen-buildsys-win.bat <VSVersion> <Target Architecture>"
  echo "Specify the VSVersion to be used - VS2015, VS2017 or VS2019"
  echo "Specify the Target Architecture - x86, or x64."
  EXIT /B 1

:DONE
  EXIT /B 0
