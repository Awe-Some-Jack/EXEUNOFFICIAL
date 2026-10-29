import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import states.LoadingState;
import states.PlayState;

var stat:FlxSprite;
var bgGraphic:FlxSprite;
var blackGraphic:FlxSprite;
var whiteGraphic:FlxSprite;
var eas:FlxSprite;
var bluescreen:FlxSprite;

var glitchShader:ErrorHandledRuntimeShader;
var shaderTime:Float = 0;
var glitchIntensity:Float = 0;
var isGlitching:Bool = false;

function onCreate() {
    bgGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    bgGraphic.scale.set(2, 2);
    bgGraphic.screenCenter();
    bgGraphic.scrollFactor.set();

    eas = new FlxSprite(0, 0, Paths.image('fate/eas', 'LORD X'));
    eas.updateHitbox();
    eas.scrollFactor.set(0, 0);
    eas.setGraphicSize(FlxG.width, FlxG.height);
    eas.screenCenter();
    add(eas);

    stat = new FlxSprite(0, 0);
    stat.frames = Paths.getSparrowAtlas('daSTAT', 'LORD X');
    stat.animation.addByPrefix('idle', 'staticFLASH', 24, true);
    stat.animation.play('idle',true);
    stat.screenCenter();
    stat.scale.set(3.4, 3.4);
    stat.antialiasing = false;
    add(stat);

    whiteGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    whiteGraphic.scale.set(2, 2);
    whiteGraphic.screenCenter();
    whiteGraphic.scrollFactor.set();
    add(whiteGraphic);

    bluescreen = new FlxSprite(0, 0, Paths.image('fate/bluescreen', 'LORD X'));
    bluescreen.updateHitbox();
    bluescreen.scrollFactor.set();
    bluescreen.setGraphicSize(FlxG.width, FlxG.height);
    bluescreen.screenCenter();
    add(bluescreen);

    blackGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackGraphic.scale.set(2, 2);
    blackGraphic.screenCenter();
    blackGraphic.scrollFactor.set();
    add(blackGraphic);

    whiteGraphic.cameras = blackGraphic.cameras = bluescreen.cameras = eas.cameras = stat.cameras = [camOther];
    blackGraphic.alpha = bgGraphic.alpha = whiteGraphic.alpha = bluescreen.alpha = eas.alpha = stat.alpha = 0.00001;

    //ссанина
    final fragCode = "
        #pragma header
        uniform float uTime;
        uniform float uIntensity;
        
        float rand(vec2 co) {
            return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
        }

        void main() {
            vec2 uv = openfl_TextureCoordv;
            
            float melt = rand(vec2(uv.x, uTime)) * 0.15 * uIntensity;
            uv.y = fract(uv.y - melt);
            
            float blockY = floor(uv.y * (30.0 - uIntensity * 15.0));
            float blockNoise = rand(vec2(blockY, uTime));
            if (blockNoise > (0.98 - uIntensity * 0.6)) {
                uv.x += (rand(vec2(blockY, uTime + 1.0)) - 0.5) * 0.6 * uIntensity;
            }
            
            float tearNoise = fract(sin(dot(uv.yy, vec2(12.9898, 78.233))) * 43758.5453 + uTime);
            if (tearNoise > (0.95 - uIntensity * 0.5)) {
                uv.x += 0.15 * sin(uTime * 150.0) * uIntensity;
            }
            
            float splitAmt = uIntensity * (0.02 + 0.15 * rand(vec2(uTime, blockY)));
            
            vec4 col;
            col.r = flixel_texture2D(bitmap, fract(uv + vec2(splitAmt, 0.0))).r;
            col.g = flixel_texture2D(bitmap, fract(uv)).g;
            col.b = flixel_texture2D(bitmap, fract(uv - vec2(splitAmt, 0.0))).b;
            col.a = flixel_texture2D(bitmap, uv).a;
            
            float grain = rand(uv * uTime) * 0.6 * uIntensity;
            col.rgb = mix(col.rgb, vec3(rand(uv + 1.0), rand(uv + 2.0), rand(uv + 3.0)), grain * 0.4);
            col.rgb -= grain;

            if (uIntensity > 0.5 && rand(vec2(uTime, uv.y)) > (1.0 - uIntensity * 0.2)) {
                col.rgb = 1.0 - col.rgb;
            }

            gl_FragColor = col;
        }
    ";
    
    glitchShader = new ErrorHandledRuntimeShader("GottaGoGlitch", fragCode);
}

// all squished together for you
function onUpdate(elapsed:Float) {
    if(curStep >= 68 && dad.animation.curAnim.name == 'jarona') //JARONA JAJAJAJAJAJA
    {
        switch(dad.animation.curAnim.curFrame) 
        {
            case 25: stat.alpha = 1;
            case 43: stat.alpha = 0;
            case 92:
                addBehindDad(bgGraphic);
                FlxTween.tween(bgGraphic, {alpha: 1}, 0.78, {ease: FlxEase.linear});
            case 117, 185: bgGraphic.alpha = 0;
            case 161: bgGraphic.alpha = 1;
            case 230: eas.alpha = 1;
            case 256: eas.alpha = 0;
        }
    }
    
    if (isGlitching && glitchShader != null) 
    {
        shaderTime += elapsed;
        
        glitchIntensity += elapsed / 1.5;
        if (glitchIntensity > 1.0)
            glitchIntensity = 1.0;
        
        glitchShader.setFloat('uTime', shaderTime);
        glitchShader.setFloat('uIntensity', glitchIntensity);
    }
}

function onStepHit() {
    switch(curStep) {
        case 3428: FlxTween.tween(whiteGraphic, {alpha: 0.4}, 0.4, {ease: FlxEase.linear});
        case 3462: bluescreen.alpha = 1;
    }
}

function onEndSong() {
    if (states.SoundTest.fromSoundTest) 
    {
        camGame.alpha = 0.000001;
        bluescreen.alpha = 1;

        final daFilters = camOther.filters ?? [];
        daFilters.push(new ShaderFilter(glitchShader));
        camOther.filters = daFilters;
        
        isGlitching = true;
        
        //ну крч вас нахуй без выбора в gotta goon отправят
        new FlxTimer().start(1.5, (tmr:FlxTimer) -> {
            bluescreen.alpha = 0.00001;
            camOther.filters = [];
            isGlitching = false;
            glitchIntensity = 0;

            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;

            PlayState.SONG = Song.loadFromJson('gotta-go', 'gotta-go');
            PlayState.isStoryMode = false;
            
            LoadingState.prepareToSong();
            LoadingState.loadAndSwitchState(new PlayState());
        });

        return Function_Stop;
    }

    return Function_Continue;
}