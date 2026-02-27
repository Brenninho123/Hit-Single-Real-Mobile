import funkin.objects.Yoshi;
import openfl.filters.ShaderFilter;
import funkin.utils.CameraUtil;
import flixel.effects.FlxFlicker;
import funkin.game.shaders.FuckScorp;
import flixel.text.FlxText;

var normalzoom:Bool = false;
var duet:Bool = false;
var tvsection:Bool = false;
var lockCamnera:Bool = false;
var vg:FlxSprite;

var transitionSprite:FlxSprite;
var staticOV:FlxSprite;
var transitionCamera:FlxCamera;

var fakebaybe:FunkinVideoSprite;
var endVideo:FunkinVideoSprite;

var black:FlxSprite;
var colorSwap:ColorSwap;

var bg1:Array<FlxSprite> = [];
var reallland:FlxSprite;

var yoshi:Yoshi;

var title:FlxText;

var fuck = new FuckScorp();
var shader2 = newShader("warp");
shader2.setFloat("warp",1.75);

var f1 = new ShaderFilter(fuck);
var f2 = new ShaderFilter(shader2);


function onDestroy() {
    FlxG.filters = [];
    if (fakebaybe != null) fakebaybe.destroy();
    if (endVideo != null) endVideo.destroy();  
}

function onSongStart() {
    fakebaybe.play();
}

// decoy, youre my goat for doing code for me but holy shit fix your indentations PLEASE
function onLoad() 
{
    var idekwhatthisisfor = new FlxSprite().loadGraphic(Paths.image("fondo"));
    var sky = new FlxSprite().loadGraphic(Paths.image("skynsuch"));
    var trees = new FlxSprite().loadGraphic(Paths.image("letrees"));
    var fog = new FlxSprite().loadGraphic(Paths.image("mustardgas"));
    var fog2 = new FlxSprite().loadGraphic(Paths.image("mustardgas2"));

    var water:FlxSprite = new FlxSprite().loadGraphic(Paths.image("agua"));    

    yoshi = new Yoshi([-250, 2500], 900, 1);
    yoshi.colorSwap.saturation = -50;
    yoshi.colorSwap.brightness = -0.5;
    yoshi.canWalk = false;
    yoshi.zIndex = 999;
    // add(yoshi);

    var arena:FlxSprite = new FlxSprite().loadGraphic(Paths.image("arena"));
    for (i in [idekwhatthisisfor,sky,trees,fog,fog2,water,arena]) {
        i.scale.set(1.6,1.6);
        add(i);
        bg1.push(i);
    }

    var frontTrees = new FlxSprite().loadGraphic(Paths.image("lefrontree"));
    frontTrees.scrollFactor.set(0.6, 0.6);
    frontTrees.scale.set(1.6, 1.6);
    frontTrees.zIndex = 2;
    bg1.push(frontTrees);


    var waterSplash = new FlxSprite(2025,1750);
    waterSplash.frames = Paths.getSparrowAtlas("waterbaby");
    waterSplash.animation.addByPrefix("i","water instancia 1",24);
    waterSplash.animation.play('i');
    waterSplash.scale.set(1.1,1.1);
    add(waterSplash);
    bg1.push(waterSplash);

    realland = new FlxSprite().loadGraphic(Paths.image("realbaby"));
	add(realland); 
    realland.visible = false;
}

function onEvent(name:String,val1:String,val2:String) {
    if (name == '') {
        if (val1 == 'atlasAnim') {
            transitionCamera.visible=true;
            vg.color = 0x00000000;
            vg.alpha = 0;

            black.color = 0xFFFF0000;
            black.alpha = 0;
            black.cameras = [transitionCamera];

            for (i in [transitionSprite,black]) {FlxTween.tween(i, {alpha: 1},2,{ease:FlxEase.sineOut});}

            FlxTween.tween(staticOV, {alpha: 0.3},2, {startDelay: 0.25,onComplete: Void->{
                FlxFlicker.flicker(staticOV,0.4,0.04,false);
            }});

            FlxTween.tween(vg, {alpha: 1},1.5, {startDelay: 0.5,ease:FlxEase.sineInOut});

            transitionSprite.animation.play('i');
            transitionSprite.animation.finishCallback = (s:String)->{
                black.alpha = 0;
                vg.alpha = 0;
                transitionSprite.visible =false;
                staticOV.alpha = 0;
                camOther.flash(0xFFFF0000);
            }

            tvsection = true;

            FlxTween.num(defaultCamZoom, 1.5, 2, {ease: FlxEase.backIn}, (f)->{defaultCamZoom = f;});

            yoshi.visible = yoshi.canWalk = false;

        }
        if (val1 == 'playFinale') {
            FlxG.camera.visible = false;
            //camHUD.visible = false;
            for(i in [playHUD.timeBar, playHUD.healthBar, playHUD.iconP1, playHUD.iconP2,])
                FlxTween.tween(i, {alpha: 0},1);
            endVideo.play();
            FlxG.filters = [f1];

        }
        if (val1 == 'showTitle') {
            camOther.filters = [f1, f2];
            FlxTween.tween(title, {alpha: 1}, 2.5, {ease: FlxEase.quadOut,onComplete: function (f) {
                FlxTween.tween(title, {alpha: 0},2, {ease: FlxEase.quadOut, startDelay: 1});
            }});
        }
    }
}


function onCreatePost(){
    GameOverSubstate.deathSoundName = "empty";
    GameOverSubstate.loopSoundName = "empty";
    GameOverSubstate.endSoundName = "empty";

    camGame.filters = [f1, f2];
    camHUD.filters = [f1, f2];
 
    transitionCamera = new FlxCamera();
    transitionCamera.bgColor = 0x0;
    CameraUtil.insertFlxCamera(1,transitionCamera,false);

    camHUD.zoom = 0.9;
    camHUD.alpha = 0;
    defaultHudZoom = 0.9;
    skipCountdown = true;

    vg = new FlxSprite().loadGraphic(Paths.image("RedVG"));
    vg.color = 0xFF000000;
    vg.cameras = [camOther];
    add(vg);

    black = new FlxSprite().makeGraphic(1,1, 0xFFFFFFFF);
    black.scale.set(FlxG.width,FlxG.height);
    black.updateHitbox();
    black.cameras = [camOther];
    black.color = 0xFF000000;
    add(black);

    fakebaybe = new FunkinVideoSprite();
    fakebaybe.onFormat(()->{
        fakebaybe.setGraphicSize(0,FlxG.height);
        fakebaybe.updateHitbox();
        fakebaybe.screenCenter();
        fakebaybe.cameras = [camOther];
    });
    fakebaybe.load(Paths.video('fakeintro'), [FunkinVideoSprite.muted]);
    add(fakebaybe);

    endVideo = new FunkinVideoSprite();
    endVideo.onFormat(()->{
        endVideo.setGraphicSize(0,FlxG.height);
        endVideo.updateHitbox();
        endVideo.screenCenter();
        endVideo.cameras = [transitionCamera];
    });
    endVideo.load(Paths.video('fakefinale'),[FunkinVideoSprite.muted]);
    add(endVideo);

    title = new FlxText();
    title.text = 'NO MORE INNOCENCE\nFakebaby';
    title.setFormat(Paths.font("CODE Bold.otf"), 96, 0xFFFF0000, FlxTextAlign.CENTER);
    title.cameras = [camOther];
    title.screenCenter();
    title.alpha = 0;
    add(title);

    transitionSprite = new FlxSprite();
    transitionSprite.frames = Paths.getSparrowAtlas('transitionS');
    transitionSprite.animation.addByPrefix('i','nmi instance 1',24,false);
    transitionSprite.screenCenter();
    transitionSprite.y += 100;
    transitionSprite.alpha = 0;
    add(transitionSprite);
    transitionSprite.cameras = [transitionCamera];

    staticOV = new FlxSprite();
    staticOV.frames = Paths.getSparrowAtlas('static');
    staticOV.animation.addByPrefix('i','static',30);
    staticOV.animation.play('i');
    staticOV.setGraphicSize(0,FlxG.height * 1.5);
    staticOV.updateHitbox();
    staticOV.setColorTransform(1,1,1,1,200);
    staticOV.alpha = 0;
    add(staticOV);
    staticOV.cameras = [transitionCamera];

    // too lazy to use the psych event system, im in a rush
    modManager.queueFuncOnce(304, function(shit,shit2){ 
        FlxTween.tween(black, {alpha: 0}, 2, {ease: FlxEase.quadOut});
        FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.quadOut});
        yoshi.canWalk = true;
    });
    modManager.queueFuncOnce(576, function(shit,shit2){ FlxTween.tween(vg, {alpha: 0}, 2, {ease: FlxEase.quadOut}); normalzoom = true; });
    modManager.queueFuncOnce(832, function(shit,shit2){ normalzoom = false; });
    modManager.queueFuncOnce(960, function(shit,shit2){ 
        duet = true; 
        camZooming = true;
        defaultCamZoom = 0.35;
        FlxTween.tween(FlxG.camera, {zoom: 0.35}, 1);
        trace(defaultCamZoom);
    });
    modManager.queueFuncOnce(1071, function(shit,shit2){ duet = false; isCameraOnForcedPos = false;});
    modManager.queueFuncOnce(1088, function(shit,shit2){ normalzoom = true; });
    modManager.queueFuncOnce(2112, function(shit,shit2){
        for(sprite in bg1){ sprite.visible = false; }
        realland.visible = true;
        FlxTween.cancelTweensOf(black);
        FlxTween.tween(black, {alpha: 0}, 1);
        defaultCamZoom = 0.6;
        FlxG.camera.filters = [];
        camHUD.filters = [];
        camOther.filters = [];
        defaultHudZoom = 1;
        camHUD.zoom = 1;
        lockCamnera = true;
    });
}

function onGameOverStart() 
{
    var video = new FunkinVideoSprite();
    video.onFormat(()->{
        video.setGraphicSize(0,FlxG.height);
        video.updateHitbox();
        video.screenCenter();
        video.cameras = [camOther];
    });
    video.load(Paths.video("realinnodeathscreen"));
    video.onEnd(()->{
        FlxG.resetState();
    });
    video.play();
    GameOverSubstate.instance.add(video);
}

function onUpdate(elapsed){

    if(!tvsection){
        if(duet){
            isCameraOnForcedPos = true;
            defaultCamZoom = 0.35;
            camFollow.x = 1280;
            camFollow.y = 950;
        }else{
            isCameraOnForcedPos = false;
            if(normalzoom){
                if(PlayState.SONG.notes[curSection].mustHitSection)
                    defaultCamZoom = 0.6;
                else
                    defaultCamZoom = 0.5;
            }else{
                if(PlayState.SONG.notes[curSection].mustHitSection)
                    defaultCamZoom = 0.6;
                else
                    defaultCamZoom = 0.9;
            }    
        }
    }else{
        if(lockCamnera){
            camFollow.x = 1074;
            camFollow.y = 840;
            isCameraOnForcedPos = true;    
        }
    }
}