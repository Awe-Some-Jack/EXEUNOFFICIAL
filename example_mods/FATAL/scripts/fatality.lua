-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local CONFIG = {
    SONG_NAME = 'Fatality',

    WINDOW = {
        WIDTH = 960,
        HEIGHT = 720,
        WIDESCREEN_OFFSET = (26 * 6) + 4
    },

    STRUMS = {
        OPPONENT = {
            X_POSITIONS = {25, 137, 249, 361},
            Y_OFFSET = 50
        },
        PLAYER = {
            X_POSITIONS = {510, 622, 734, 846},
            Y_OFFSET = 50
        }
    },

    HEALTHBAR = {
        MAX_SQUARES = 25,
        SQUARE_WIDTH = 16,
        SQUARE_HEIGHT = 15,
        SPACING = 2,
        SCALE = 1.32,
        WINDOW_WIDTH = 472,
        WINDOW_HEIGHT = 70,
        WINDOW_X_OFFSET = 155,
        WINDOW_Y_OFFSET_FROM_TOP = 150,
        WINDOW_Y_SLIDE_START = -500,
        LIFE_SPRITE_X = 13,
        LIFE_SPRITE_Y = 64
    },

    HUD = {
        TIME_OFFSET_NORMAL = -20,
        TIME_OFFSET_DOWNSCROLL = 10,
        SCALE = 1.3
    },

    COUNTDOWN_SOUNDS = {
        {counter = 0, sound = 'intro3-fatal'},
        {counter = 1, sound = 'intro2-fatal'},
        {counter = 2, sound = 'intro1-fatal'},
        {counter = 3, sound = 'introGo-fatal'}
    },

    STEP_EVENTS = {
        SLIDE_HEALTHBAR = 255,
        START_SHAKE = 2230,
        START_INFINITY = 2240,
        RETURN_TO_NORMAL = 2432,
        SHAKE_AGAIN = 2528,
        FINAL_SCREEN = 2560
    }
}

-- ============================================================================
-- STATE VARIABLES
-- ============================================================================

local state = {
    isActiveSong = false,
    savedFullscreen = false,
    currentHealthSquares = 25,
    hasInitialized = false,
    isClosing = false
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function isFatalitySong()
    return songName == CONFIG.SONG_NAME or songName:lower() == CONFIG.SONG_NAME:lower()
end

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================

local function resetWindowToDefault()
    setPropertyFromClass('flixel.FlxG', 'width', 1280)
    setPropertyFromClass('openfl.Lib', 'current.stage.stageWidth', 1280)
    setPropertyFromClass('openfl.Lib', 'application.window.width', 1280)
    setPropertyFromClass('openfl.Lib', 'application.window.height', 720)
    setPropertyFromClass('openfl.Lib', 'application.window.resizable', true)
end

local function setupCustomAspectRatio()
    if getPropertyFromClass('openfl.Lib', 'application.window.width') == CONFIG.WINDOW.WIDTH then
        return
    end

    setPropertyFromClass('flixel.FlxG', 'width', CONFIG.WINDOW.WIDTH)
    setPropertyFromClass('openfl.Lib', 'current.stage.stageWidth', CONFIG.WINDOW.WIDTH)
    setPropertyFromClass('openfl.Lib', 'application.window.width', CONFIG.WINDOW.WIDTH)
    setPropertyFromClass('openfl.Lib', 'application.window.height', CONFIG.WINDOW.HEIGHT)
    setPropertyFromClass('openfl.Lib', 'application.window.x',
        getPropertyFromClass('openfl.Lib', 'application.window.x') + CONFIG.WINDOW.WIDESCREEN_OFFSET)
    setPropertyFromClass('openfl.Lib', 'application.window.resizable', false)
end

local function restoreWindowProperties()
    setPropertyFromClass('flixel.FlxG', 'width', 1280)
    setPropertyFromClass('openfl.Lib', 'current.stage.stageWidth', 1280)
    setPropertyFromClass('openfl.Lib', 'application.window.width', 1280)
    setPropertyFromClass('openfl.Lib', 'application.window.height', 720)
    setPropertyFromClass('openfl.Lib', 'application.window.resizable', true)
end

local function closeHealthWindow()
    pcall(function()
        runHaxeCode([[
            import lime.ui.Window;
            try {
                var healthWindow:Window = getVar('healthWindow');
                if (healthWindow != null) {
                    healthWindow.close();
                }
            } catch (e:Dynamic) {
            }

            setVar('healthWindow', null);
            setVar('healthBarSprite', null);
            setVar('healthLifeSprite', null);
            setVar('healthContainer', null);
            setVar('healthWindowSliding', null);
            setVar('healthWindowFloating', null);
            setVar('healthWindowShaking', null);
            setVar('windowShaking', null);
        ]])
    end)
end

local function createHealthWindow()
    local windowWidth = math.ceil(CONFIG.HEALTHBAR.WINDOW_WIDTH * CONFIG.HEALTHBAR.SCALE)
    local windowHeight = math.ceil(CONFIG.HEALTHBAR.WINDOW_HEIGHT * CONFIG.HEALTHBAR.SCALE)

    local code1 = [[
        import lime.ui.Window;
        import lime.ui.WindowAttributes;
        import openfl.display.Sprite;
        import openfl.display.Bitmap;
        import openfl.display.BitmapData;
        import lime.app.Application;
        import openfl.events.Event;
        
        try {
            var attrs:WindowAttributes = {};
            attrs.width = ]] .. windowWidth .. [[;
            attrs.height = ]] .. windowHeight .. [[;
            attrs.title = "";
            attrs.borderless = true;
            attrs.alwaysOnTop = false;
            attrs.resizable = false;
            attrs.hidden = false;
            
            var healthWindow = Application.current.createWindow(attrs);
            var mainWindow = Application.current.window;
            
            healthWindow.x = mainWindow.x + ]] .. CONFIG.HEALTHBAR.WINDOW_X_OFFSET .. [[;
            healthWindow.y = mainWindow.y + ]] .. CONFIG.HEALTHBAR.WINDOW_Y_SLIDE_START .. [[;
            
            setVar("healthWindowTargetY", mainWindow.y - ]] .. CONFIG.HEALTHBAR.WINDOW_Y_OFFSET_FROM_TOP .. [[);
            setVar("healthWindow", healthWindow);
            
            var container = new Sprite();
            healthWindow.stage.addChild(container);
            setVar("healthContainer", container);
            
            mainWindow.focus();
        } catch(e:Dynamic) {
        }
    ]]
    pcall(function() runHaxeCode(code1) end)
    
    local code2 = [[
        try {
            var barBg = BitmapData.fromFile("mods/FATAL/images/fatality/bar/bar.png");
            var barSprite = new openfl.display.Bitmap(barBg);
            barSprite.x = 0;
            barSprite.y = 0;
            barSprite.scaleX = ]] .. CONFIG.HEALTHBAR.SCALE .. [[;
            barSprite.scaleY = ]] .. CONFIG.HEALTHBAR.SCALE .. [[;
            
            var container = getVar("healthContainer");
            if (container != null) {
                container.addChild(barSprite);
                setVar("healthBarSprite", barSprite);
            }
        } catch(e:Dynamic) {
        }
    ]]
    pcall(function() runHaxeCode(code2) end)
    
    local code3 = [[
        try {
            var lifeBg = BitmapData.fromFile("mods/FATAL/images/fatality/bar/life.png");
            var lifeSprite = new openfl.display.Bitmap(lifeBg);
            lifeSprite.x = ]] .. CONFIG.HEALTHBAR.LIFE_SPRITE_X .. [[;
            lifeSprite.y = ]] .. CONFIG.HEALTHBAR.LIFE_SPRITE_Y .. [[;
            lifeSprite.scaleX = ]] .. CONFIG.HEALTHBAR.SCALE .. [[;
            lifeSprite.scaleY = ]] .. CONFIG.HEALTHBAR.SCALE .. [[;
            
            var container = getVar("healthContainer");
            if (container != null) {
                container.addChild(lifeSprite);
                setVar("healthLifeSprite", lifeSprite);
            }
            
            var mainWindow = lime.app.Application.current.window;
            if (mainWindow != null) {
                mainWindow.focus();
            }
        } catch(e:Dynamic) {
        }
    ]]
    pcall(function() runHaxeCode(code3) end)
end

-- ============================================================================
-- HUD MANAGEMENT
-- ============================================================================

local function hideDefaultHudElements()
    setProperty('timeTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)

    setProperty('scoreTxt.visible', false)
    setProperty('scoreTxt.alpha', 0)
    setTextString('scoreTxt', '')
    setProperty('scoreTxt.x', -9999)
    setProperty('scoreTxt.y', -9999)

    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)

    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end

    setProperty('showCombo', false)
    setProperty('showComboNum', false)
    setProperty('showRating', false)
end

local function adjustHudPositions()
    local offset = downscroll and CONFIG.HUD.TIME_OFFSET_DOWNSCROLL or CONFIG.HUD.TIME_OFFSET_NORMAL
    local hudElements = {'timeTxt', 'timeBarBG', 'timeBar', 'botplayTxt'}

    for _, element in ipairs(hudElements) do
        setProperty(element .. '.y', getProperty(element .. '.y') + offset)
    end
end

local function createCustomHud()
    local hudY = downscroll and 0 or 615
    makeLuaSprite('hudSprite', 'fatality/bar/hud', 0, hudY)
    setProperty('hudSprite.antialiasing', false)
    setObjectCamera('hudSprite', 'other')
    scaleObject('hudSprite', CONFIG.HUD.SCALE, CONFIG.HUD.SCALE)
    addLuaSprite('hudSprite', true)

    local missesY = downscroll and 39 or 654
    makeLuaText('missesTxt', 'Misses: 0', 400, 15, missesY)
    setTextFont('missesTxt', 'ari-w9500-bold.ttf')
    setTextSize('missesTxt', 17)
    setProperty('missesTxt.antialiasing', false)
    setTextBorder('missesTxt', 0)
    setTextColor('missesTxt', '000000')
    setTextAlignment('missesTxt', 'left')
    setObjectCamera('missesTxt', 'other')
    addLuaText('missesTxt', true)

    local scoreY = downscroll and 77 or 692
    makeLuaText('scoreTxt2', 'Score: 0', 400, 15, scoreY)
    setTextFont('scoreTxt2', 'ari-w9500-bold.ttf')
    setTextSize('scoreTxt2', 17)
    setProperty('scoreTxt2.antialiasing', false)
    setTextBorder('scoreTxt2', 0)
    setTextColor('scoreTxt2', '000000')
    setTextAlignment('scoreTxt2', 'left')
    setObjectCamera('scoreTxt2', 'other')
    addLuaText('scoreTxt2', true)
end

local function updateScoreDisplay()
    setTextString('missesTxt', 'Misses: ' .. getProperty('songMisses'))
    setTextString('scoreTxt2', 'Score: ' .. getProperty('songScore'))
end

-- ============================================================================
-- STRUMS AND NOTES MANAGEMENT
-- ============================================================================

local function setupStrumsPositions()
    for i = 0, 3 do
        local opponentY = downscroll and
            (screenHeight - getProperty('opponentStrums.members[' .. i .. '].height') - CONFIG.STRUMS.OPPONENT.Y_OFFSET) or
            CONFIG.STRUMS.OPPONENT.Y_OFFSET
        local playerY = downscroll and
            (screenHeight - getProperty('playerStrums.members[' .. i .. '].height') - CONFIG.STRUMS.PLAYER.Y_OFFSET) or
            CONFIG.STRUMS.PLAYER.Y_OFFSET

        setPropertyFromGroup('opponentStrums', i, 'x', CONFIG.STRUMS.OPPONENT.X_POSITIONS[i + 1])
        setPropertyFromGroup('opponentStrums', i, 'y', opponentY)
        setPropertyFromGroup('playerStrums', i, 'x', CONFIG.STRUMS.PLAYER.X_POSITIONS[i + 1])
        setPropertyFromGroup('playerStrums', i, 'y', playerY)
    end
end

local function setupNoteSkins()
    if not getPropertyFromClass('PlayState', 'isPixelStage') then
        return
    end

    for i = 0, 3 do
        setPropertyFromGroup('strumLineNotes', i, 'texture', 'fatal')
    end
end

local function hideOpponentNotes()
    for i = 0, getProperty('notes.length') - 1 do
        if not getPropertyFromGroup('notes', i, 'mustPress') then
            setPropertyFromGroup('notes', i, 'visible', false)
            setPropertyFromGroup('notes', i, 'alpha', 0)
        end
    end
end

local function updateNoteSkins()
    if not getPropertyFromClass('PlayState', 'isPixelStage') then
        return
    end

    for i = 0, getProperty('notes.length') - 1 do
        if not getPropertyFromGroup('notes', i, 'mustPress') and
           getPropertyFromGroup('notes', i, 'noteType') == '' then
            setPropertyFromGroup('notes', i, 'texture', 'fatal')
        end
    end
end

local function maintainStrumsPositions()
    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'x', CONFIG.STRUMS.OPPONENT.X_POSITIONS[i + 1])
        setPropertyFromGroup('playerStrums', i, 'x', CONFIG.STRUMS.PLAYER.X_POSITIONS[i + 1])
    end
end

-- ============================================================================
-- HEALTH BAR
-- ============================================================================

local function updateHealthBarDisplay()
    if not state.isActiveSong or not state.hasInitialized then
        return
    end

    local currentHealth = getProperty('health')
    if currentHealth == nil then return end

    local healthPercent = (currentHealth / 2) * 100
    local healthSquares = math.floor((healthPercent / 100) * CONFIG.HEALTHBAR.MAX_SQUARES)
    healthSquares = math.max(0, math.min(healthSquares, CONFIG.HEALTHBAR.MAX_SQUARES))

    state.currentHealthSquares = healthSquares

    local pixelsToShow = healthSquares * (CONFIG.HEALTHBAR.SQUARE_WIDTH + CONFIG.HEALTHBAR.SPACING)

    local code = 'import openfl.geom.Rectangle; var lifeSprite:openfl.display.Bitmap = getVar("healthLifeSprite"); if (lifeSprite != null) { lifeSprite.scrollRect = new Rectangle(0, 0, ' .. pixelsToShow .. ', ' .. CONFIG.HEALTHBAR.SQUARE_HEIGHT .. '); }'
    pcall(function() runHaxeCode(code) end)
end

-- ============================================================================
-- WINDOW ANIMATIONS
-- ============================================================================

local function updateHealthWindowAnimations()
    if not state.isActiveSong or not state.hasInitialized then
        return
    end

    local code = [[
        import lime.app.Application;
        var mainWindow = Application.current.window;
        var healthWindow = getVar('healthWindow');
        var isSliding = getVar('healthWindowSliding');
        var isFloating = getVar('healthWindowFloating');
        var baseX = getVar('healthWindowBaseX');

        if (getVar('windowShaking') == true) {
            var mainBaseX = getVar('mainWindowBaseX');
            var mainBaseY = getVar('mainWindowBaseY');
            var shakeX = Std.int(Math.random() * 20 - 10);
            var shakeY = Std.int(Math.random() * 20 - 10);
            mainWindow.x = mainBaseX + shakeX;
            mainWindow.y = mainBaseY + shakeY;
        }

        if (healthWindow != null && getVar('healthWindowShaking') == true) {
            var healthBaseX = getVar('healthWindowBaseX');
            var healthBaseY = getVar('healthWindowBaseY');
            var shakeX = Std.int(Math.random() * 20 - 10);
            var shakeY = Std.int(Math.random() * 20 - 10);
            healthWindow.x = healthBaseX + shakeX;
            healthWindow.y = healthBaseY + shakeY;
        }

        if (getVar('windowInfinity') == true) {
            var infinityTime:Float = getVar('infinityTime');
            infinityTime += 1/60;
            setVar('infinityTime', infinityTime);

            var centerX = getVar('mainWindowCenterX');
            var centerY = getVar('mainWindowCenterY');
            var t = infinityTime * 0.5;
            var offsetX = Math.sin(t) * 100;
            var offsetY = Math.sin(t * 2) * 50;
            mainWindow.x = Std.int(centerX + offsetX);
            mainWindow.y = Std.int(centerY + offsetY);
        }

        if (healthWindow != null && getVar('healthWindowInfinity') == true) {
            var infinityTime:Float = getVar('infinityTime');
            var centerX = getVar('healthWindowCenterX');
            var centerY = getVar('healthWindowCenterY');
            var t = infinityTime * 0.5;
            var offsetX = Math.sin(t) * 100;
            var offsetY = Math.sin(t * 2) * 50;
            healthWindow.x = Std.int(centerX + offsetX);
            healthWindow.y = Std.int(centerY + offsetY);
        }

        if (getVar('windowReturning') == true) {
            var returnTime:Float = getVar('returnTime');
            returnTime += 1/60;
            setVar('returnTime', returnTime);

            var duration = 1.5;
            if (returnTime >= duration) {
                mainWindow.x = Std.int(getVar('mainWindowBaseX'));
                mainWindow.y = Std.int(getVar('mainWindowBaseY'));
                setVar('windowReturning', false);
            } else {
                var t = returnTime / duration;
                var eased = 1 - Math.pow(1 - t, 3);
                var startX = getVar('returnStartX');
                var startY = getVar('returnStartY');
                var targetX = getVar('mainWindowBaseX');
                var targetY = getVar('mainWindowBaseY');
                mainWindow.x = Std.int(startX + (targetX - startX) * eased);
                mainWindow.y = Std.int(startY + (targetY - startY) * eased);
            }
        }

        if (healthWindow != null && getVar('healthWindowReturning') == true) {
            var returnTime:Float = getVar('returnTime');
            var duration = 1.5;
            if (returnTime >= duration) {
                healthWindow.x = Std.int(getVar('healthWindowBaseX'));
                healthWindow.y = Std.int(getVar('healthWindowBaseY'));
                setVar('healthWindowReturning', false);
            } else {
                var t = returnTime / duration;
                var eased = 1 - Math.pow(1 - t, 3);
                var startX = getVar('healthReturnStartX');
                var startY = getVar('healthReturnStartY');
                var targetX = getVar('healthWindowBaseX');
                var targetY = getVar('healthWindowBaseY');
                healthWindow.x = Std.int(startX + (targetX - startX) * eased);
                healthWindow.y = Std.int(startY + (targetY - startY) * eased);
            }
        }

        if (healthWindow != null && isSliding == true) {
            var slideTime:Float = getVar('healthWindowSlideTime');
            var startY:Float = getVar('healthWindowStartY');
            var targetY:Float = getVar('healthWindowTargetY');

            slideTime += 1/60;
            setVar('healthWindowSlideTime', slideTime);

            var duration = 1.0;
            if (slideTime >= duration) {
                healthWindow.y = Std.int(targetY);
                setVar('healthWindowSliding', false);
                setVar('healthWindowFloating', true);
            } else {
                var t = slideTime / duration;
                var eased = 1 - Math.pow(2, -10 * t);
                var currentY = startY + (targetY - startY) * eased;
                healthWindow.y = Std.int(currentY);
            }
        }

        if (healthWindow != null && isFloating == true && baseX != null &&
            getVar('windowInfinity') != true &&
            getVar('windowShaking') != true &&
            getVar('windowReturning') != true) {
            var floatTime:Float = getVar('floatTime');
            floatTime += 1/60;
            setVar('floatTime', floatTime);

            var offset = Math.sin(floatTime * 0.8) * 8;
            healthWindow.x = Std.int(baseX + offset);
        }
    ]]
    pcall(function() runHaxeCode(code) end)
end

-- ============================================================================
-- WINDOW ANIMATION TRIGGERS
-- ============================================================================

local function startHealthWindowSlide()
    local code = 'import lime.app.Application; var healthWindow = getVar("healthWindow"); var targetY = getVar("healthWindowTargetY"); var mainWindow = Application.current.window; if (healthWindow != null && targetY != null) { setVar("healthWindowSliding", true); setVar("healthWindowStartY", healthWindow.y); setVar("healthWindowSlideTime", 0.0); setVar("healthWindowBaseX", mainWindow.x + ' .. CONFIG.HEALTHBAR.WINDOW_X_OFFSET .. '); }'
    pcall(function() runHaxeCode(code) end)
end

local function startWindowShake()
    local code = [[
        import lime.app.Application;
        var mainWindow = Application.current.window;
        var healthWindow = getVar('healthWindow');

        setVar('windowShaking', true);
        setVar('mainWindowBaseX', mainWindow.x);
        setVar('mainWindowBaseY', mainWindow.y);

        if (healthWindow != null) {
            setVar('healthWindowShaking', true);
            setVar('healthWindowBaseX', healthWindow.x);
            setVar('healthWindowBaseY', healthWindow.y);
        }
    ]]
    pcall(function() runHaxeCode(code) end)
end

local function startInfinityMovement()
    local code = [[
        import lime.app.Application;
        var mainWindow = Application.current.window;
        var healthWindow = getVar('healthWindow');

        setVar('windowShaking', false);
        setVar('healthWindowShaking', false);
        setVar('windowInfinity', true);
        setVar('infinityTime', 0.0);
        setVar('mainWindowCenterX', mainWindow.x);
        setVar('mainWindowCenterY', mainWindow.y);

        if (healthWindow != null) {
            setVar('healthWindowInfinity', true);
            setVar('healthWindowCenterX', healthWindow.x);
            setVar('healthWindowCenterY', healthWindow.y);
        }
    ]]
    pcall(function() runHaxeCode(code) end)
end

local function startReturnToNormal()
    local code = [[
        import lime.app.Application;
        var mainWindow = Application.current.window;
        var healthWindow = getVar('healthWindow');

        setVar('windowInfinity', false);
        setVar('healthWindowInfinity', false);
        setVar('windowReturning', true);
        setVar('healthWindowReturning', true);
        setVar('returnTime', 0.0);

        setVar('returnStartX', mainWindow.x);
        setVar('returnStartY', mainWindow.y);

        if (healthWindow != null) {
            setVar('healthReturnStartX', healthWindow.x);
            setVar('healthReturnStartY', healthWindow.y);
        }
    ]]
    pcall(function() runHaxeCode(code) end)
end

local function resumeShaking()
    local code = [[
        import lime.app.Application;
        var mainWindow = Application.current.window;
        var healthWindow = getVar('healthWindow');

        setVar('windowReturning', false);
        setVar('healthWindowReturning', false);
        setVar('windowShaking', true);
        setVar('healthWindowShaking', true);

        setVar('mainWindowBaseX', mainWindow.x);
        setVar('mainWindowBaseY', mainWindow.y);

        if (healthWindow != null) {
            setVar('healthWindowBaseX', healthWindow.x);
            setVar('healthWindowBaseY', healthWindow.y);
        }
    ]]
    pcall(function() runHaxeCode(code) end)
end

local function showFinalScreen()
    local code = [[
        import lime.app.Application;
        var healthWindow = getVar('healthWindow');

        setVar('windowShaking', false);
        setVar('healthWindowShaking', false);

        if (healthWindow != null) {
            healthWindow.visible = false;
        }
    ]]
    pcall(function() runHaxeCode(code) end)

    setPropertyFromClass('flixel.FlxG', 'fullscreen', true)
    makeLuaSprite('fatalScreen', 'fatality/fatal', 0, 0)
    setObjectCamera('fatalScreen', 'other')
    addLuaSprite('fatalScreen', true)
    setProperty('fatalScreen.alpha', 1)
end

-- ============================================================================
-- ENGINE CALLBACKS
-- ============================================================================

function onCreate()
    state.isActiveSong = isFatalitySong()
    if not state.isActiveSong then
        if state.hasInitialized then
            closeHealthWindow()
            restoreWindowProperties()
            pcall(function()
                setPropertyFromClass('flixel.FlxG', 'fullscreen', state.savedFullscreen)
            end)
            state.hasInitialized = false
        end
        return
    end

    state.isClosing = false
    state.hasInitialized = false

    closeHealthWindow()
    resetWindowToDefault()
    setupCustomAspectRatio()
    createCustomHud()

    local code = [[
        setVar('floatTime', 0.0);
    ]]
    pcall(function() runHaxeCode(code) end)

    state.savedFullscreen = getPropertyFromClass('flixel.FlxG', 'fullscreen')
    state.hasInitialized = true
end

function onCreatePost()
    if not state.isActiveSong then
        return
    end

    hideDefaultHudElements()
    adjustHudPositions()
    setupNoteSkins()
    setProperty('health', 2)
end

function onSongStart()
    if not state.isActiveSong then
        return
    end

    setupStrumsPositions()
    closeHealthWindow()
    runTimer('createWindow', 0.5)
end

function onTimerCompleted(tag)
    if tag == 'createWindow' then
        createHealthWindow()
    elseif tag == 'restoreOnExit' or tag == 'restoreOnGameOver' or tag == 'restoreOnEnd' then
        restoreWindowProperties()
        pcall(function()
            setPropertyFromClass('flixel.FlxG', 'fullscreen', state.savedFullscreen)
        end)
    end
end

function onStepHit()
    if not state.isActiveSong then
        return
    end

    local step = curStep

    if step == CONFIG.STEP_EVENTS.SLIDE_HEALTHBAR then
        startHealthWindowSlide()
    elseif step == CONFIG.STEP_EVENTS.START_SHAKE then
        startWindowShake()
    elseif step == CONFIG.STEP_EVENTS.START_INFINITY then
        startInfinityMovement()
    elseif step == CONFIG.STEP_EVENTS.RETURN_TO_NORMAL then
        startReturnToNormal()
    elseif step == CONFIG.STEP_EVENTS.SHAKE_AGAIN then
        resumeShaking()
    elseif step == CONFIG.STEP_EVENTS.FINAL_SCREEN then
        showFinalScreen()
    end
end

function onUpdate(elapsed)
    if not state.isActiveSong or state.isClosing or not state.hasInitialized then
        return
    end

    updateNoteSkins()
    hideOpponentNotes()
    updateHealthBarDisplay()
    updateScoreDisplay()
    updateHealthWindowAnimations()
    maintainStrumsPositions()
end

function onCountdownTick(counter)
    if not state.isActiveSong then
        return
    end

    for _, sound in ipairs(CONFIG.COUNTDOWN_SOUNDS) do
        if counter == sound.counter then
            playSound(sound.sound, 1)
            break
        end
    end
end

function onOpenChartEditor()
    if state.isActiveSong then
        setPropertyFromClass('flixel.FlxG', 'width', 1280)
    end
end

function onOpenCharacterEditor()
    if state.isActiveSong then
        setPropertyFromClass('flixel.FlxG', 'width', 1280)
    end
end

function onExitSong()
    if state.isActiveSong then
        closeHealthWindow()
        runTimer('restoreOnExit', 0.2)
    end
    return Function_Continue
end

function onGameOver()
    if state.isActiveSong then
        closeHealthWindow()
        runTimer('restoreOnGameOver', 0.2)
    end
    return Function_Continue
end

function onEndSong()
    if state.isActiveSong then
        closeHealthWindow()
        runTimer('restoreOnEnd', 0.2)
    end
    return Function_Continue
end

function onDestroy()
    state.isClosing = true
    state.hasInitialized = false
    if state.isActiveSong then
        closeHealthWindow()
        restoreWindowProperties()       
        pcall(function()
            setPropertyFromClass('flixel.FlxG', 'fullscreen', state.savedFullscreen)
        end)
    end
end

function onResume()
    if state.isActiveSong then
        local code = [[
            import lime.app.Application;
            var mainWindow = Application.current.window;
            if (mainWindow != null) {
            }
        ]]
        pcall(function() 
            runHaxeCode(code) 
        end)
    end
end