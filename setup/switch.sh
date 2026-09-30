#!/bin/sh
# You MUST install devkitpro and must install any dependencies with pacman -s --needed or sudo dkp-pacman -S --needed
# Most dependencies can be found here: https://github.com/Slushi-Github/lime-nx/tree/main
cd ..
echo Making the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git hx-gamejolt https://github.com/cocoCode17/hx-gamejolt
haxelib git flixel-addons https://github.com/GreenColdTea/flixel-addons.git funkin-before-rebase --skip-dependencies
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4
haxelib git hxswitchvideo https://github.com/Slushi-Github/HxSwitchVideo.git
haxelib git hx_libnx https://github.com/Slushi-Github/hx_libnx.git
haxelib install hxp 1.3.1
haxelib install nape-haxe4
haxelib git hscript-iris https://github.com/GreenColdTea/hscript-iris.git
haxelib git flixel-animate https://github.com/FNF-CC-ENGINE/flixel-animate.git --skip-dependencies
haxelib git hxluajit https://github.com/MAJigsaw77/hxluajit.git
haxelib git hxluajit-wrapper https://github.com/MAJigsaw77/hxluajit-wrapper.git --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://github.com/osakared/grig.audio.git
haxelib install tink_core 1.26.0
haxelib git flixel https://github.com/FNF-CC-ENGINE/flixel.git --skip-dependencies
haxelib git lime https://github.com/GreenColdTea/lime-fc.git
haxelib git openfl https://github.com/FNF-CC-ENGINE/openfl-fc.git
haxelib git hxcpp https://github.com/Wolfie1985yt/hxcpp.git
haxelib set hxcpp git
haxelib run lime rebuild tools
echo Finished!
