#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git flixel https://github.com/FNF-CC-ENGINE/flixel.git
haxelib git lime https://github.com/GreenColdTea/lime-fc.git
haxelib git openfl https://github.com/GreenColdTea/openfl.git
haxelib git flixel-addons https://github.com/GreenColdTea/flixel-addons.git funkin-before-rebase
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4
haxelib install hxvlc 2.3.0 --skip-dependencies
haxelib git flxgif https://github.com/FNF-CC-ENGINE/flxgif.git
haxelib git hscript-iris https://github.com/GreenColdTea/hscript-iris.git
haxelib git flixel-animate https://github.com/FNF-CC-ENGINE/flixel-animate.git
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://github.com/osakared/grig.audio.git
echo Finished!
