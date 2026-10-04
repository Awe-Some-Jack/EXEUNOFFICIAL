@echo off
color 0a
cd ..
@echo on
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git flixel https://github.com/FNF-CC-ENGINE/flixel.git
haxelib git lime https://github.com/GreenColdTea/lime-fc.git
haxelib git openfl https://github.com/FNF-CC-ENGINE/openfl-fc.git
haxelib git hx-gamejolt https://github.com/cocoCode17/hx-gamejolt
haxelib git flixel-addons https://github.com/GreenColdTea/flixel-addons.git funkin-before-rebase --skip-dependencies
haxelib git extension-androidtools https://github.com/LimeExtensions/extension-androidtools.git --skip-dependencies
haxelib git astc-compressor https://github.com/Wolfie1985yt/astc-compressor.git --skip-dependencies
haxelib git hscript-iris https://github.com/GreenColdTea/hscript-iris.git
haxelib git flixel-animate https://github.com/FNF-CC-ENGINE/flixel-animate.git --skip-dependencies
haxelib git hxluajit https://github.com/MAJigsaw77/hxluajit.git
haxelib git hxluajit-wrapper https://github.com/MAJigsaw77/hxluajit-wrapper.git --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90
haxelib git sl-windows-api https://github.com/GreenColdTea/windows-api-improved.git
haxelib git grig.audio https://github.com/osakared/grig.audio.git
haxelib install flixel-tools 1.5.1
haxelib install tjson 1.4.0
haxelib install hxdiscord_rpc 1.2.4
haxelib install hxvlc 2.3.1 --skip-dependencies
haxelib install hxp 1.3.1
haxelib install tink_core 1.26.0
haxelib install nape-haxe4
haxelib git hxcpp https://github.com/Wolfie1985yt/hxcpp.git
haxelib set hxcpp git
echo Finished!
pause
