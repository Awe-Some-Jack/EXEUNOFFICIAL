#if !macro
//Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

//Psych
#if LUA_ALLOWED
import hxluajit.*;
import hxluajit.Lua;
import hxluajit.Types.Lua_State;
import hxluajit.wrapper.LuaUtils as LuaUtilsHx;
import hxluajit.wrapper.LuaConverter;
#end

import cpp.RawPointer;

import backend.Achievements;

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

#if flxgif
import flxgif.*;
#end

import backend.Paths;
import backend.MemoryUtil;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomShapeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
import backend.Language;

import backend.ui.*; //Psych-UI

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;
import states.extras.bios.BIOS;
import states.extras.dagarden.DAGarden;
import states.extras.ExtrasMenu;

#if flixel_animate
import animate.*;
#end

#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

import openfl.Assets;

import openfl.utils.Assets as OpenFlAssets;

#if android
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.widget.Toast as AndroidToast;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
#end

#if mobile
import mobile.backend.MobileUtil;
#end

// Windows API
#if sl_windows_api
import winapi.*;
import winapi.gdi.*;
#end

using StringTools;
#end
