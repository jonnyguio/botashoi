#!/bin/sh

zip -9 -q -r botashoi.love main.lua images/ srcs/

cat ../../love-0.10.1-win32/love.exe ./botashoi.love > ./bin/win32/botashoi.exe

cp botashoi.love ./bin/osx/botashoi.app/Contents/Resources;
