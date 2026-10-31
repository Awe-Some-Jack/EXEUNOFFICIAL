import openfl.Lib;
import lime.system.System;

final isMobile:Bool = (buildTarget == 'ios' || buildTarget == 'android');

final margin:Float = 24;

final floatEase:Float = 1.5;

final roamBlendSeconds:Float = 1.5;
final roamReturnSeconds:Float = 2.2;
final roamMinBand:Float = 40;
final roamHealthBarRoom:Float = 160;
final roamRampWidth:Float = 240;
final roamSamples:Int = 200;

var windowMode:String = null;
var homeX:Int = 0;
var homeY:Int = 0;
var lastX:Int = 0;
var lastY:Int = 0;

var floatStopping:Bool = false;
var floatPhase:Float = 0;
var floatPeriod:Float = 5;
var floatAmplitude:Float = 0;
var floatTarget:Float = 0;

var roamReturning:Bool = false;
var roamStartX:Float = 0;
var roamStartY:Float = 0;
var roamBlend:Float = 0;
var roamBack:Float = 0;
var roamTheta:Float = 0;
var roamPeriod:Float = 8;
var centerX:Float = 0;
var reachX:Float = 0;
var tableX0:Float = 0;
var tableStep:Float = 1;
var tableTop:Array<Float> = [];
var tableBottom:Array<Float> = [];

function sendTo(varName:String, line:String) {
    var proc = getVar(varName);
    if(proc == null) return;
    try {
        proc.stdin.writeString(line + '\n');
        proc.stdin.flush();
    } catch (e:Dynamic) {
        trace('fatalEvents: ' + varName + ' failed: ' + e);
    }
}

function setBarsFollow(follow:Bool) {
    var line = follow ? 'follow:on' : 'follow:off';
    sendTo('healthBarProcess', line);
    sendTo('corruptionBarProcess', line);
}

function setPopupsFollow(follow:Bool) {
    var host = getVar('fatalPopupHost');
    if(host == null) return;
    try {
        host.send(follow ? 'follow:on' : 'follow:off');
    } catch (e:Dynamic) {}
}

function clean(value:String):String {
    return StringTools.trim(value == null ? '' : value);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float) {
    if(isMobile) return;
    switch(name) {
        case 'Fatal Hand':
            handEvent(clean(value1).toLowerCase(), clean(value2));
        case 'Fatal Window Float':
            floatEvent(clean(value1).toLowerCase(), clean(value2));
        case 'Fatal Window Roam':
            roamEvent(clean(value1).toLowerCase(), clean(value2));
    }
}

function handEvent(edges:String, positionsText:String) {
    var proc = getVar('healthBarProcess');
    if(proc == null) return;

    var commands:Array<String> = [];
    if(edges == 'release' || edges == 'soltar') {
        commands.push('handrelease');
    } else {
        var positions = positionsText.split(',');
        var i = 0;
        for(edge in edges.split(',')) {
            var pos = StringTools.trim(positions[Std.int(Math.min(i, positions.length - 1))]);
            commands.push('hand:' + StringTools.trim(edge) + ':' + pos);
            i++;
        }
    }

    try {
        for(cmd in commands) proc.stdin.writeString(cmd + '\n');
        proc.stdin.flush();
    } catch (e:Dynamic) {
        trace('Fatal Hand failed: ' + e);
    }
}

function canMoveWindow():Bool {
    var window = Lib.application.window;
    return !(window.fullscreen || window.maximized);
}

function beginMotion(mode:String) {
    var window = Lib.application.window;
    if(windowMode == null) {
        homeX = window.x;
        homeY = window.y;
        lastX = window.x;
        lastY = window.y;
    }
    windowMode = mode;
}

function moveWindow(x:Float, y:Float) {
    var nextX = Math.round(x);
    var nextY = Math.round(y);
    if(nextX == lastX && nextY == lastY) return;
    lastX = nextX;
    lastY = nextY;
    Lib.application.window.move(nextX, nextY);
}

function finishMotion() {
    if(windowMode == null) return;
    var wasRoaming = windowMode == 'roam';
    windowMode = null;
    floatStopping = false;
    roamReturning = false;
    Lib.application.window.move(homeX, homeY);
    setBarsFollow(true);
    if(wasRoaming) setPopupsFollow(false);
}

function floatEvent(command:String, secondsText:String) {
    if(command == 'stop' || command == 'parar') {
        if(windowMode == 'float') {
            floatStopping = true;
            floatTarget = 0;
        }
        return;
    }
    if(windowMode == 'roam' || !canMoveWindow()) return;

    var window = Lib.application.window;
    var pixels = Std.parseFloat(command);
    var seconds = Std.parseFloat(secondsText);
    floatTarget = Math.isNaN(pixels) ? window.width * 0.05 : Math.abs(pixels);
    floatPeriod = (Math.isNaN(seconds) || seconds <= 0) ? 5 : seconds;
    floatStopping = false;

    if(windowMode != 'float') {
        beginMotion('float');
        floatPhase = 0;
        floatAmplitude = 0;
        setBarsFollow(false);
    }
}

function updateFloat(elapsed:Float) {
    floatPhase += elapsed * Math.PI * 2 / floatPeriod;
    floatAmplitude += (floatTarget - floatAmplitude) * Math.min(1, elapsed * floatEase);

    if(floatStopping && floatAmplitude < 0.5) {
        finishMotion();
        return;
    }
    moveWindow(homeX + Math.sin(floatPhase) * floatAmplitude, homeY);
}

function roamEvent(command:String, secondsText:String) {
    if(command == 'return' || command == 'stop' || command == 'regresar' || command == 'volver') {
        if(windowMode == 'roam' && !roamReturning) {
            roamReturning = true;
            roamBack = 0;
        }
        return;
    }
    if(windowMode == 'roam' || !canMoveWindow()) return;

    var window = Lib.application.window;
    var seconds = Std.parseFloat(secondsText);
    roamPeriod = (Math.isNaN(seconds) || seconds <= 0) ? 8 : seconds;

    beginMotion('roam');
    roamStartX = window.x + window.width / 2;
    roamStartY = window.y + window.height / 2;
    computePath(roamStartX, roamStartY, window.width, window.height);
    roamTheta = closestTheta(roamStartX, roamStartY);
    roamBlend = 0;
    roamBack = 0;
    roamReturning = false;
    setBarsFollow(true);
    setPopupsFollow(true);
}

function bandTop(s:Dynamic, h:Float):Float return s.y + roamHealthBarRoom + h / 2 + margin;

function bandBottom(s:Dynamic, h:Float):Float return s.y + s.height - h / 2 - margin;

function computePath(x:Float, y:Float, w:Float, h:Float) {
    var screens:Array<Dynamic> = [];
    for(i in 0...System.numDisplays) {
        var display = System.getDisplay(i);
        if(display != null && display.bounds != null) screens.push(display.bounds);
    }
    if(screens.length == 0) {
        centerX = x;
        reachX = 0;
        tableX0 = x;
        tableStep = 1;
        tableTop = [];
        tableBottom = [];
        for(k in 0...roamSamples) {
            tableTop.push(y);
            tableBottom.push(y);
        }
        return;
    }
    screens.sort(function(a, b) {
        return a.x < b.x ? -1 : (a.x > b.x ? 1 : 0);
    });

    var current = 0;
    var bestDistance = Math.POSITIVE_INFINITY;
    for(i in 0...screens.length) {
        var s = screens[i];
        var dx = Math.max(0, Math.max(s.x - x, x - (s.x + s.width)));
        var dy = Math.max(0, Math.max(s.y - y, y - (s.y + s.height)));
        if(dx * dx + dy * dy < bestDistance) {
            bestDistance = dx * dx + dy * dy;
            current = i;
        }
    }

    var row:Array<Dynamic> = [screens[current]];
    var i = current - 1;
    while(i >= 0) {
        var s = screens[i];
        var next = row[0];
        var t = Math.max(bandTop(s, h), bandTop(next, h));
        var b = Math.min(bandBottom(s, h), bandBottom(next, h));
        if(Math.abs(s.x + s.width - next.x) > 8 || b - t < roamMinBand) break;
        row.insert(0, s);
        i--;
    }
    i = current + 1;
    while(i < screens.length) {
        var s = screens[i];
        var previous = row[row.length - 1];
        var t = Math.max(bandTop(s, h), bandTop(previous, h));
        var b = Math.min(bandBottom(s, h), bandBottom(previous, h));
        if(Math.abs(s.x - (previous.x + previous.width)) > 8 || b - t < roamMinBand) break;
        row.push(s);
        i++;
    }

    var left:Float = row[0].x;
    var right:Float = row[row.length - 1].x + row[row.length - 1].width;
    var minX = left + w / 2 + margin;
    var maxX = right - w / 2 - margin;
    if(maxX < minX) {
        minX = (left + right) / 2;
        maxX = minX;
    }
    centerX = (minX + maxX) / 2;
    reachX = (maxX - minX) / 2;
    buildBands(row, w, h, minX, maxX);
}

function buildBands(row:Array<Dynamic>, w:Float, h:Float, minX:Float, maxX:Float) {
    tableX0 = minX;
    tableStep = Math.max(1, (maxX - minX) / (roamSamples - 1));

    var exactTop:Array<Float> = [];
    var exactBottom:Array<Float> = [];
    for(k in 0...roamSamples) {
        var x = minX + k * tableStep;
        var t = Math.NEGATIVE_INFINITY;
        var b = Math.POSITIVE_INFINITY;
        for(s in row) {
            if(s.x + s.width > x - w / 2 && s.x < x + w / 2) {
                t = Math.max(t, bandTop(s, h));
                b = Math.min(b, bandBottom(s, h));
            }
        }
        if(t == Math.NEGATIVE_INFINITY) {
            t = bandTop(row[0], h);
            b = bandBottom(row[0], h);
        }
        if(b < t) {
            t = (t + b) / 2;
            b = t;
        }
        exactTop.push(t);
        exactBottom.push(b);
    }

    var reach = Std.int(Math.max(1, Math.ceil(roamRampWidth / tableStep)));
    var erodedTop:Array<Float> = [];
    var erodedBottom:Array<Float> = [];
    for(k in 0...roamSamples) {
        var t = Math.NEGATIVE_INFINITY;
        var b = Math.POSITIVE_INFINITY;
        for(j in Std.int(Math.max(0, k - reach))...Std.int(Math.min(roamSamples, k + reach + 1))) {
            t = Math.max(t, exactTop[j]);
            b = Math.min(b, exactBottom[j]);
        }
        erodedTop.push(t);
        erodedBottom.push(b);
    }

    var half = Std.int(Math.max(1, reach / 2));
    tableTop = [];
    tableBottom = [];
    for(k in 0...roamSamples) {
        var sumTop = 0.0;
        var sumBottom = 0.0;
        var count = 0;
        for(j in Std.int(Math.max(0, k - half))...Std.int(Math.min(roamSamples, k + half + 1))) {
            sumTop += erodedTop[j];
            sumBottom += erodedBottom[j];
            count++;
        }
        var t = sumTop / count;
        var b = sumBottom / count;
        if(b < t) {
            t = (t + b) / 2;
            b = t;
        }
        tableTop.push(t);
        tableBottom.push(b);
    }
}

function lookup(table:Array<Float>, x:Float):Float {
    var f = (x - tableX0) / tableStep;
    if(f <= 0) return table[0];
    if(f >= roamSamples - 1) return table[roamSamples - 1];
    var k = Std.int(f);
    return table[k] + (table[k + 1] - table[k]) * (f - k);
}

function pathX(t:Float):Float return centerX + reachX * Math.sin(t);

function pathY(t:Float):Float {
    var x = pathX(t);
    var top = lookup(tableTop, x);
    var bottom = lookup(tableBottom, x);
    return (top + bottom) / 2 + (bottom - top) / 2 * Math.sin(t * 2);
}

function closestTheta(x:Float, y:Float):Float {
    var best = 0.0;
    var bestDistance = Math.POSITIVE_INFINITY;
    for(k in 0...96) {
        var t = k * Math.PI * 2 / 96;
        var dx = pathX(t) - x;
        var dy = pathY(t) - y;
        if(dx * dx + dy * dy < bestDistance) {
            bestDistance = dx * dx + dy * dy;
            best = t;
        }
    }
    return best;
}

function smooth(t:Float):Float return t * t * (3 - 2 * t);

function updateRoam(elapsed:Float) {
    var window = Lib.application.window;
    roamTheta += elapsed * Math.PI * 2 / roamPeriod;
    roamBlend = Math.min(1, roamBlend + elapsed / roamBlendSeconds);
    var eased = smooth(roamBlend);
    var x = roamStartX + (pathX(roamTheta) - roamStartX) * eased;
    var y = roamStartY + (pathY(roamTheta) - roamStartY) * eased;

    if(roamReturning) {
        roamBack = Math.min(1, roamBack + elapsed / roamReturnSeconds);
        var homing = smooth(roamBack);
        x += (homeX + window.width / 2 - x) * homing;
        y += (homeY + window.height / 2 - y) * homing;
        if(roamBack >= 1) {
            finishMotion();
            return;
        }
    }
    moveWindow(x - window.width / 2, y - window.height / 2);
}

function onUpdatePost(elapsed:Float) {
    if(isMobile) return;
    if(windowMode == 'float') updateFloat(elapsed);
    else if(windowMode == 'roam') updateRoam(elapsed);
}

function onEndSong() {
    if(isMobile) return Function_Continue;
    finishMotion();
    return Function_Continue;
}

function onGameOver() {
    if(isMobile) return Function_Continue;
    finishMotion();
    return Function_Continue;
}

function onDestroy() {
    if(isMobile) return;
    finishMotion();
}
