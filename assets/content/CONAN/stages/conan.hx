import openfl.filters.ShaderFilter;
var yougottaadmit:FlxSprite;

function onLoad(){
    var conan = new FlxSprite(-205, 255).loadGraphic(Paths.image("conanbg"));
    add(conan);

    // var yoshi = new Yoshi([-500, FlxG.width], 610, 1);
    // if(KUTValueHandler.getYoshi()) add(yoshi);
}

var mosaic = newShader("mosaic");
var strength:Float = 3.5;
skipCountdown = true;

function onCreatePost(){
    //lq shit
    var fuck = new ShaderFilter(mosaic);
    // camHUD.filters = [fuck];
    camGame.filters = [fuck];
    // FlxG.game.filters = [fuck];
    mosaic.setFloatArray('uBlocksize', [strength, strength]);

    dad.shader = mosaic;
    boyfriend.shader = mosaic;

    yougottaadmit = new FlxSprite();
    yougottaadmit.frames = Paths.getSparrowAtlas('is this cool');
    yougottaadmit.animation.addByPrefix('yes it is', 'yes it is', 24, true);
    yougottaadmit.animation.play('yes it is', true);
    yougottaadmit.setGraphicSize(1280, 720);
    yougottaadmit.updateHitbox();
    yougottaadmit.cameras = [camHUD];
    yougottaadmit.screenCenter();
    yougottaadmit.alpha = 0;
    add(yougottaadmit);

    modManager.queueFuncOnce(540, function(step,step2){
        FlxTween.num(3, 0, 1, {ease: FlxEase.quadOut, onUpdate: function(twn:FlxTween){
            strength = twn.value;
        }});
    });
}
function onUpdate(elapsed){
    mosaic.setFloatArray('uBlocksize', [strength, strength]);
    camHUD.alpha = 1;
    if(yougottaadmit.alpha == 1 && !startingSong) health = 0;
}

function noteMiss(d){
    yougottaadmit.alpha += 0.05;
}
function goodNoteHit(){
    yougottaadmit.alpha -= 0.025;
}
function onGameOver(){
    FlxG.sound.play(Paths.sound("eh"), 1);
}
// function onEndSong(){
//     MusicBeatState.switchState(new ConanLevel());
// }