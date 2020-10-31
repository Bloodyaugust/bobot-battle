#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/3.2.stable/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --export-debug "Linux/X11" build/linux/bobot-battle.x86_64 -v
echo "EXPORTING FOR OSX"
echo "-----------------------------"
godot --export-debug "Mac OSX" build/osx/bobot-battle.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --export-debug "Windows Desktop" build/win/bobot-battle.exe -v
echo "-----------------------------"

echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
echo "-----------------------------"
cd build/osx/
mv bobot-battle.dmg bobot-battle-osx-alpha.zip
unzip bobot-battle-osx-alpha.zip
rm bobot-battle-osx-alpha.zip
chmod +x bobot-battle.app/Contents/MacOS/bobot-battle
zip -r "bobot-battle-osx-alpha-${CIRCLE_BUILD_NUM}.zip" bobot-battle.app
rm -rf bobot-battle.app
cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r "bobot-battle-win-alpha-${CIRCLE_BUILD_NUM}.zip" bobot-battle.exe bobot-battle.pck
rm -r bobot-battle.exe bobot-battle.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r "bobot-battle-linux-alpha-${CIRCLE_BUILD_NUM}.zip" bobot-battle.x86_64 bobot-battle.pck
rm -r bobot-battle.x86_64 bobot-battle.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/bobot-battle:linux-alpha --userversion "${CIRCLE_BUILD_NUM}"
butler push build/osx/ synsugarstudio/bobot-battle:osx-alpha --userversion "${CIRCLE_BUILD_NUM}"
butler push build/win/ synsugarstudio/bobot-battle:win-alpha --userversion "${CIRCLE_BUILD_NUM}"
