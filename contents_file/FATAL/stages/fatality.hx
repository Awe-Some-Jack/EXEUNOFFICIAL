import flixel.addons.display.FlxBackdrop;

var truefatalstage:FlxSprite;

var lb_fondo1:FlxSprite;
var lb_agua1:FlxSprite;
var lb_montanas:FlxSprite;
var lb_pla:FlxSprite;
var lb_agua2:FlxSprite;
var lb_planta:FlxSprite;
var lb_piso:FlxSprite;

final launchSprites:Array<FlxSprite> = [];

var redbg:FlxSprite;
var smallassbox:FlxBackdrop;
var glitchythingy:FlxSprite;
var smallbox:FlxBackdrop;
var bigbox:FlxSprite;
var barbg:FlxBackdrop;
var floorbg:FlxSprite;
var bansheeBG:FlxSprite;
var dismantlerBG:FlxSprite;
var machineBG:FlxSprite;
var trapperBG:FlxSprite;

final newBGSprites:Array<FlxSprite> = [];
final newBGBoppers:Array<FlxSprite> = [];

function onCreate()
{
    truefatalstage = new FlxSprite(-1050, -850);
    truefatalstage.frames = Paths.getSparrowAtlas('fatality/truefatalstage');
    truefatalstage.animation.addByPrefix('idle', 'idle', 15, true);
    truefatalstage.animation.play('idle', true);
    truefatalstage.scale.set(5, 5);
    truefatalstage.updateHitbox();
    truefatalstage.antialiasing = false;
    truefatalstage.visible = false;
    addBehindGF(truefatalstage);

    lb_fondo1 = new FlxSprite();
    lb_fondo1.frames = Paths.getSparrowAtlas('fatality/new/launchbase/fondo1');
    lb_fondo1.animation.addByPrefix('idle', 'fondo_gif', 24, true);
    lb_fondo1.animation.play('idle', true);
    lb_fondo1.scale.set(4.3, 4.3);
    lb_fondo1.updateHitbox();
    lb_fondo1.setPosition(-1500, -1300);
    lb_fondo1.antialiasing = false;
    addBehindGF(lb_fondo1);
    launchSprites.push(lb_fondo1);

    lb_agua1 = new FlxSprite();
    lb_agua1.frames = Paths.getSparrowAtlas('fatality/new/launchbase/agua1');
    lb_agua1.animation.addByPrefix('idle', 'agua1', 24, true);
    lb_agua1.animation.play('idle', true);
    lb_agua1.scale.set(4, 4);
    lb_agua1.updateHitbox();
    lb_agua1.setPosition(-1500, 310);
    lb_agua1.antialiasing = false;
    addBehindGF(lb_agua1);
    launchSprites.push(lb_agua1);

    lb_montanas = new FlxSprite(-1500, 130).loadGraphic(Paths.image('fatality/new/launchbase/montanas'));
    lb_montanas.scale.set(4, 4);
    lb_montanas.updateHitbox();
    lb_montanas.antialiasing = false;
    addBehindGF(lb_montanas);
    launchSprites.push(lb_montanas);

    lb_pla = new FlxSprite(-1200, -1020).loadGraphic(Paths.image('fatality/new/launchbase/pla'));
    lb_pla.scale.set(4.3, 4.3);
    lb_pla.updateHitbox();
    lb_pla.antialiasing = false;
    addBehindGF(lb_pla);
    launchSprites.push(lb_pla);

    lb_agua2 = new FlxSprite();
    lb_agua2.frames = Paths.getSparrowAtlas('fatality/new/launchbase/agua2');
    lb_agua2.animation.addByPrefix('idle', 'agua2', 24, true);
    lb_agua2.animation.play('idle', true);
    lb_agua2.scale.set(3, 3);
    lb_agua2.updateHitbox();
    lb_agua2.setPosition(-450, 480);
    lb_agua2.antialiasing = false;
    addBehindGF(lb_agua2);
    launchSprites.push(lb_agua2);

    lb_planta = new FlxSprite(-1500, 500).loadGraphic(Paths.image('fatality/new/launchbase/planta'));
    lb_planta.scale.set(4.3, 4.3);
    lb_planta.updateHitbox();
    lb_planta.antialiasing = false;
    addBehindGF(lb_planta);
    launchSprites.push(lb_planta);

    lb_piso = new FlxSprite(-1400, 600).loadGraphic(Paths.image('fatality/new/launchbase/piso'));
    lb_piso.scale.set(4, 4);
    lb_piso.updateHitbox();
    lb_piso.antialiasing = false;
    addBehindGF(lb_piso);
    launchSprites.push(lb_piso);

    redbg = new FlxSprite(-1350, -900).loadGraphic(Paths.image('fatality/new/domain/redbg'));
    redbg.scale.set(5, 5);
    redbg.updateHitbox();
    redbg.antialiasing = false;
    redbg.visible = false;
    addBehindGF(redbg);
    newBGSprites.push(redbg);

    smallassbox = new FlxBackdrop(null, 0x01);
    smallassbox.frames = Paths.getSparrowAtlas('fatality/new/domain/smallassbox');
    smallassbox.animation.addByPrefix('idle', 'smallassbox idle', 12, false);
    smallassbox.scale.set(5, 5);
    smallassbox.updateHitbox();
    smallassbox.setPosition(-1350, -900);
    smallassbox.velocity.x = -700;
    smallassbox.antialiasing = false;
    smallassbox.visible = false;
    addBehindGF(smallassbox);
    newBGSprites.push(smallassbox);
    newBGBoppers.push(smallassbox);

    glitchythingy = new FlxSprite(-1350, -900);
    glitchythingy.frames = Paths.getSparrowAtlas('fatality/new/domain/glitchythingy');
    glitchythingy.animation.addByPrefix('idle', 'glitchythingy idle', 12, false);
    glitchythingy.scale.set(5, 5);
    glitchythingy.updateHitbox();
    glitchythingy.antialiasing = false;
    glitchythingy.visible = false;
    addBehindGF(glitchythingy);
    newBGSprites.push(glitchythingy);
    newBGBoppers.push(glitchythingy);

    smallbox = new FlxBackdrop(null, 0x01);
    smallbox.frames = Paths.getSparrowAtlas('fatality/new/domain/smallbox');
    smallbox.animation.addByPrefix('idle', 'smallbox idle', 12, false);
    smallbox.scale.set(5, 5);
    smallbox.updateHitbox();
    smallbox.setPosition(-1350, -900);
    smallbox.velocity.x = -500;
    smallbox.antialiasing = false;
    smallbox.visible = false;
    addBehindGF(smallbox);
    newBGSprites.push(smallbox);
    newBGBoppers.push(smallbox);

    bigbox = new FlxSprite(-1350, -900);
    bigbox.frames = Paths.getSparrowAtlas('fatality/new/domain/bigbox');
    bigbox.animation.addByPrefix('idle', 'bigbox idle', 12, false);
    bigbox.scale.set(5, 5);
    bigbox.updateHitbox();
    bigbox.antialiasing = false;
    bigbox.visible = false;
    addBehindGF(bigbox);
    newBGSprites.push(bigbox);
    newBGBoppers.push(bigbox);

    barbg = new FlxBackdrop(null, 0x01);
    barbg.loadGraphic(Paths.image('fatality/new/domain/barbg'));
    barbg.scale.set(5, 5);
    barbg.updateHitbox();
    barbg.setPosition(-1350, -900);
    barbg.velocity.x = -100;
    barbg.antialiasing = false;
    barbg.visible = false;
    addBehindGF(barbg);
    newBGSprites.push(barbg);

    floorbg = new FlxSprite(-1350, -900).loadGraphic(Paths.image('fatality/new/domain/floorbg'));
    floorbg.scale.set(5, 5);
    floorbg.updateHitbox();
    floorbg.antialiasing = false;
    floorbg.visible = false;
    addBehindGF(floorbg);
    newBGSprites.push(floorbg);

    dismantlerBG = new FlxSprite(750, -200);
    dismantlerBG.frames = Paths.getSparrowAtlas('fatality/new/domain/Dismantler and Meatsheild BG sheet');
    dismantlerBG.animation.addByPrefix('idle', 'Dismantler and Meatsheild BG', 24, false);
    dismantlerBG.flipX = true;
    dismantlerBG.scale.set(4, 4);
    dismantlerBG.updateHitbox();
    dismantlerBG.antialiasing = false;
    dismantlerBG.visible = false;
    addBehindGF(dismantlerBG);
    newBGSprites.push(dismantlerBG);
    newBGBoppers.push(dismantlerBG);

    machineBG = new FlxSprite(-1200, -500);
    machineBG.frames = Paths.getSparrowAtlas('fatality/new/domain/Machine BG sheet');
    machineBG.animation.addByPrefix('idle', 'Machine BG', 24, false);
    machineBG.scale.set(4, 4);
    machineBG.updateHitbox();
    machineBG.antialiasing = false;
    machineBG.visible = false;
    addBehindGF(machineBG);
    newBGSprites.push(machineBG);
    newBGBoppers.push(machineBG);

    trapperBG = new FlxSprite(0, -270);
    trapperBG.frames = Paths.getSparrowAtlas('fatality/new/domain/Trapper BG sheet');
    trapperBG.animation.addByPrefix('idle', 'Trapper BG', 24, false);
    trapperBG.scale.set(4, 4);
    trapperBG.updateHitbox();
    trapperBG.antialiasing = false;
    trapperBG.visible = false;
    addBehindGF(trapperBG);
    newBGSprites.push(trapperBG);
    newBGBoppers.push(trapperBG);

    bansheeBG = new FlxSprite(1300, 100);
    bansheeBG.frames = Paths.getSparrowAtlas('fatality/new/domain/Banshee BG sheet');
    bansheeBG.animation.addByPrefix('idle', 'Banshee BG', 24, false);
    bansheeBG.flipX = true;
    bansheeBG.scale.set(4, 4);
    bansheeBG.updateHitbox();
    bansheeBG.antialiasing = false;
    bansheeBG.visible = false;
    add(bansheeBG);
    newBGSprites.push(bansheeBG);
    newBGBoppers.push(bansheeBG);
}

function onCreatePost()
{
    game.scoreTxt.visible = false;

    for (i in 0...4) {
        final opStr = game.opponentStrums.members[i];
        final plStr = game.playerStrums.members[i];
        if (opStr != null) {
            opStr.x = 10 + (opStr.width * i);
            opStr.texture = 'noteSkins/NOTEFATAL_assets';
        }
        if (plStr != null)
            plStr.x = (FlxG.width - 10 - (plStr.width * 4)) + (plStr.width * i);
    }

    for (note in game.unspawnNotes)
        if (note != null && !note.mustPress) note.texture = 'noteSkins/NOTEFATAL_assets';
}

function onBeatHit()
{
    if (curBeat % 4 == 0)
        for (spr in newBGBoppers)
            if (spr != null) spr.animation.play('idle', true);
}

function onEvent(name:String, value1:String, value2:String)
{
    if (name == 'FatalityNewBG') {
        for (spr in launchSprites) {
            if (spr != null) {
                remove(spr, true);
                spr.destroy();
            }
        }
        launchSprites.resize(0);

        for (spr in newBGSprites)
            if (spr != null) spr.visible = true;
    }
    else if (name == 'FatalityStage') {
        for (spr in newBGSprites)
            if (spr != null) spr.visible = false;

        truefatalstage.visible = true;

        game.triggerEvent('Change Character', 'dad', 'true-fatal');
        game.triggerEvent('Change Character', 'bf', 'bf-fatal-small');

        if (dad != null) dad.danceEveryNumBeats = 4;

        final cam = game.gameplayCam.settings;
        cam.BFx      = 900;
        cam.BFy      = 300;
        cam.DADx     = 900;
        cam.DADy     = 300;
        cam.MiddleX  = 900;
        cam.MiddleY  = 300;
        cam.OffsetsBF  = 0;
        cam.OffsetsDAD = 0;
    }
}
