# Multi Keyboard For AutoHotkey #


# README #

## Links ##

* Download - https://github.com/sebeksd/Multi-Keyboard-For-AutoHotkey/releases
* Surcecode - https://github.com/sebeksd/Multi-Keyboard-For-AutoHotkey
* Issues and feature requests - https://github.com/sebeksd/Multi-Keyboard-For-AutoHotkey/issues


## Description ##
AutoHotkey is powerfull macro application but unfortunatly if you have multiply keybords you can not distinguish them so all of them have same macros.
"Multi Keyboard For AutoHotkey" application allow user to define each keyboard as separate device for AutoHotkey.

If you like this app go to **"Donation"** section :)

## Instruction ##

#### Installation ####
You can run this app from portable version, just decopress exe and dll files anywhere or you can install using installer.
To make it working you can run this app manually, add it to autostart or add start script to AutoHotkey script (see example script for that).
After launching app will show in Windows tray, from there you can open configuration windowd (right click), in configuration window in top part you will see keybords that where connected after opening this window (disconnect and connect it again if it was already connected). Choose discovered device than provide name for it (name is only for user) and number/id (this will be used in AutoHotkey), press add, from now on this device will send all keystrokes to AutoHotkey.
Using example script "AutoHotkey_example.ahk" create your own script.

#### Settings location ####
Settings file is located in local user appdata folder:
"C:\Users\[User]\AppData\Local\MultiKeyboardForAutoHotkey\Configuration.ini"

## Building from source ##

To build this app you need Delphi IDE, it should work on most of Delphi versions (XE+), it doesn't require any external components or tools. I'm using Delphi 10.4 community edition (which is free).
Additionally, installer is made using NSIS (Nullsoft Scriptable Install System Files) os to make installer package you need to have NSIS tool.
Scripts:
- NSIS_Installer.nsi - used to create installer
- PreparePackage.bat - script to copy required files for installer and also create Portable archive (you need to build before using this script)

## Issues and Features requests ##

You can report an issue or make feature request through Issues tab on Github

## Contribution guidelines ##

Make a fork of this repository, make your changes then create pull request

## License and Disclaimer ##
Application was highly inspired and based on LuaMacros https://github.com/me2d13/luamacros (permision was granted to me by Petr Medek to use LuaMacros code, thank you !).
	
See LICENCE file

## Donation ##
If you like this app and you think it is worth of your money or you just have to much money, feel free to donate to my Bitcoin Address :)

Bitcoin address: 1LwEjzR2GZDqdApPA8twyFNTr2ZXzVnBD3
