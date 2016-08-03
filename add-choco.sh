#!/bin/bash
#
# simple script to add script/choco.bat before clean.bat
#
cat > script/choco.bat <<EOF
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
EOF

ls -al *.json | awk '{print $9}' | xargs -I{} sed -i 's/\"script\/clean.bat/"script\/choco.bat",\n        "script\/clean.bat/' {}
