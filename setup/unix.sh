#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git flixel-addons https://github.com/GreenColdTea/flixel-addons.git funkin-before-rebase --skip-dependencies
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4
haxelib install hxvlc 2.3.0 --skip-dependencies
haxelib install hxp 1.3.1
haxelib git acst-compressor https://github.com/KarimAkra/astc-compressor.git
haxelib git hscript-iris https://github.com/GreenColdTea/hscript-iris.git
haxelib git flixel-animate https://github.com/FNF-CC-ENGINE/flixel-animate.git --skip-dependencies
haxelib git hxluajit https://github.com/MAJigsaw77/hxluajit.git
haxelib git hxluajit-wrapper https://github.com/MAJigsaw77/hxluajit-wrapper.git --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git grig.audio https://github.com/osakared/grig.audio.git
haxelib install tink_core 1.26.0
haxelib git flixel https://github.com/FNF-CC-ENGINE/flixel.git --skip-dependencies
haxelib git lime https://github.com/GreenColdTea/lime-fc.git
haxelib git openfl https://github.com/FunkinCrew/openfl.git
haxelib install hxcpp 4.3.2
echo Finished!
