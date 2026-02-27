import funkin.utils.CameraUtil;
import openfl.filters.ShaderFilter;

function onLoad(){

    var sky = new FlxSprite(-1200, -300).loadGraphic(Paths.image('retrosky'));
    sky.scrollFactor.set(0.3,0.3);
    sky.scale.set(2,2);
    add(sky);

    var clouds = new FlxSprite( -1020, -500).loadGraphic(Paths.image('retroclouds'));
    clouds.scrollFactor.set(0.7,0.7);
    add(clouds);

    var retroground = new FlxSprite( -1200, 130).loadGraphic(Paths.image('retroground'));
    retroground.scrollFactor.set(0.9,0.9);
    add(retroground);

    var retrobush = new FlxSprite( -1200, 10).loadGraphic(Paths.image('retrobush'));
    retrobush.scrollFactor.set(0.9,0.9);
    add(retrobush);

    var retropipe = new FlxSprite( 800, -245).loadGraphic(Paths.image('retropipe'));
    retropipe.scrollFactor.set(0.9,0.9);
    add(retropipe);

    // makeLuaSprite('borderRig', 'border', 1300, 600);
    // addLuaSprite('borderLeft', false); addLuaSprite('borderRight', false)
    // setProperty('borderLeft.antialiasing', false); setProperty('borderRight.antialiasing', false)
    // setObjectCamera('borderLeft', 'camOther'); setObjectCamera('borderRight', 'camOther')
}

function onCreatePost() 
{
    var bL = new FlxSprite().makeGraphic(1,1,0xFF000000);
    bL.scale.set(160,FlxG.height);
    bL.updateHitbox();
    add(bL);
    bL.cameras = [game.camOther];

    var bR = new FlxSprite(FlxG.width-160).makeGraphic(1,1,0xFF000000);
    bR.scale.set(160,FlxG.height);
    bR.updateHitbox();
    add(bR);
    bR.cameras = [game.camOther];

    for(m in [playHUD.iconP1, playHUD.iconP2, playHUD.healthBar]) m.visible = false;

    modManager.setValue('opponentSwap',0.1);

    var mosaic = newShader('mosaic');
    for (i in FlxG.cameras.list)
        CameraUtil.addShader(mosaic,i);
    
    var s = FlxG.random.int(1,4);
    mosaic.data.uBlocksize.value = [s, s];

    GameOverSubstate.deathSoundName = "empty";
    GameOverSubstate.loopSoundName = "empty";
    GameOverSubstate.endSoundName = "empty";
}
function update(elapsed) {
    camZooming = false;
}

function onGameOverStart() 
{
    var video = new PsychVideoSprite();
    video.onFormat(()->{
        video.setGraphicSize(0,FlxG.height);
        video.updateHitbox();
        video.screenCenter();
        video.cameras = [camOther];
    });
    video.onEnd(()->{
        FlxG.resetState();
    });
    video.load(Paths.video("video"));
    video.play();
    GameOverSubstate.instance.add(video);
    GameOverSubstate.instance.boyfriend.alpha = 0;
    
}
