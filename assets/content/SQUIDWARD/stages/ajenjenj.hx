import openfl.filters.ShaderFilter;
import funkin.game.shaders.ColorSwap;

var interior:FlxSprite;
var fart:FlxSprite;
var fart2:FlxSprite;
var sponge:FlxSprite;
var camTween:FlxTween;
var noteGrp:FlxTypedGroup;

var blue = newShader('blue');
blue.data.hue.value = [1.3];
blue.data.pix.value = [0.00001];

function onLoad() {
    var x = -50;
    var y = 30;

    fart = new FlxSprite(x,y);
    fart.frames = Paths.getSparrowAtlas('TheBg');
    fart.animation.addByPrefix('i','the actual background',24);
    fart.animation.play('i');
    add(fart);

    fart2 = new FlxSprite(x,y);
    fart2.frames = Paths.getSparrowAtlas('Stage');
    fart2.animation.addByPrefix('i','Stage',24);
    fart2.animation.play('i');
    add(fart2);

    interior = new FlxSprite(x,y);
    interior.frames = Paths.getSparrowAtlas('THE_GOG');
    interior.animation.addByPrefix('i','THE FOG',24);
    interior.animation.play('i');
    add(interior);

    sponge = new FlxSprite(x + 448,y + 610);
    sponge.frames = Paths.getSparrowAtlas('IHadABobNowHesGone');
    sponge.animation.addByPrefix('i','I',24);
    sponge.animation.play('i');
    sponge.scale.set(1.2,1.2);
    sponge.updateHitbox();
    sponge.zIndex = 3;
    add(sponge);

    noteGrp = new FlxTypedGroup();
    add(noteGrp);

    for (i in [fart,fart2,interior]) {
        i.scale.set(1.15,1.15);
        i.updateHitbox();
    }

    // yoshi = new Yoshi([350, 1500], 350, 1);
    // yoshi.colorSwap.hue = 100;
    // yoshi.colorSwap.brightness = -0.5;
    // if(KUTValueHandler.getYoshi()) add(yoshi);

}
//zoom in on teuthida, zoom out on krabs
function onMoveCamera(whosTurn){
    if(whosTurn == "dad")
        defaultCamZoom = 0.875;
    else
        defaultCamZoom = 0.925;
}

var bluemode:Array<FlxBasic>;

function onCreatePost(){
    boyfriendGroup.zIndex = 999;
    refreshZ();

    modManager.setValue("opponentSwap", 0.5);
    modManager.setValue("alpha", 1, 1);

    var f = new ShaderFilter(blue);
    for(m in [camGame, camHUD]){
        m.filters = [f];
        m.filtersEnabled = false;
    }
}

function onEvent(eventName, value1, value2){
    if(eventName == 'Blue'){
        if(value1 == 'on'){
            camOther.flash(FlxColor.fromRGB(0,0,255), 0.75);
            for(m in [camGame, camHUD]) m.filtersEnabled = true;

            modManager.setValue("tipsy", .5);
            modManager.setValue("squish", .5);
            modManager.queueEase(curStep, curStep + 4, "squish", 0, 'circOut');
        }else{
            camOther.flash(FlxColor.fromRGB(255, 59, 59), 1);
            for(m in [camGame, camHUD]) m.filtersEnabled = false;

            modManager.setValue("tipsy", .0);
            modManager.setValue("squish", .5);
            modManager.queueEase(curStep, curStep + 4, "squish", 0, 'circOut');
        }
    } 
}

var anims = ['purple', 'blue', 'green', 'red'];
function opponentNoteHit(note){
    if(note.noteType == "Ghost Note" && !note.mustPress && !note.isSustainNote){
        var anim = anims[note.noteData];
        // trace(anim);
        var note = new FlxSprite();
        note.frames = Paths.getSparrowAtlas('NOTE_assets');
        note.animation.addByPrefix('note', anim + '0', 24, false);
        note.animation.play('note');
        noteGrp.add(note);
        
        note.scale.set(2, 2);
        note.updateHitbox();
        note.screenCenter();
        note.x += 300;
        // note.y -= 400;
    
        // note.antialiasing = true;
        note.x += FlxG.random.int(-450, 450);
        note.y += FlxG.random.int(-170, 170);
        // note.angle = FlxG.random.float(0, 360);
        note.alpha = 0;
        // note.blend = BlendMode.ADD;
        note.shader = blue;
        // FlxTween.tween(note, {alpha: 1, angle: 0}, 0.25, {ease: FlxEase.quartOut, onComplete: ()->{
    
        // }});
        FlxTween.tween(note, {alpha: 0.8, "scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.quartOut, onComplete: ()->{
            FlxTween.tween(note, {"scale.x": 0.125, "scale.y": 0.125, alpha: 0}, 0.325, {startDelay: 1, ease: FlxEase.quartIn, onComplete:()->{
                noteGrp.remove(note);
                note.destroy();
            }});
        }});    
    }
}