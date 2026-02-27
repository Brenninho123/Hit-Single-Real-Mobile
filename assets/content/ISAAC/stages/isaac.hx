import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import funkin.data.Highscore;
import funkin.utils.MathUtil;
import funkin.data.scripts.Globals;
import funkin.scripting.HScriptSubstate;

// addHaxeLibrary('FlxFlicker', 'flixel.effects');
// addHaxeLibrary('Highscore', 'meta.data');
// addHaxeLibrary('Globals','meta.data.scripts');

var hearts:Array<FlxSprite> = [];
var ui:Array<FlxSprite> = [];
var bfIcon:FlxSprite;
var oppIcon:FlxSprite;

var curHealth:Int = 5;
var invincTime = 1;

var lockConductor = false;
var lockTime = 0;


function onLoad() 
{
    var bg = new FlxSprite().loadGraphic(Paths.image("background"));
    add(bg);

    var overlay = new FlxSprite(0,-300).loadGraphic(Paths.image('use_overlay_and_50_opacity'));
    overlay.blend = BlendMode.MULTIPLY;
    // foreground.add(overlay);
    // overlay.centerOnSprite(bg,FlxAxes.X);
    overlay.x = (bg.width - overlay.x) / 2;
    overlay.scale.x *= 1.75; 
    overlay.zIndex = 9999;

    //for the gameover
    Paths.image('ui/gameover');
}

function onCreatePost() {

    var circle1 = new FlxSprite().loadGraphic(Paths.image('circle'));
    circle1.setPosition(dad.x,dad.y + dad.height - 50);
    add(circle1);
    circle1.alpha = 0.3;

    var circle2 = new FlxSprite().loadGraphic(Paths.image('circle'));
    circle2.setPosition(boyfriend.x + 25,boyfriend.y + boyfriend.height - 180);
    add(circle2);
    circle2.alpha = 0.3;

    var circle3 = new FlxSprite().loadGraphic(Paths.image('circle'));
    circle3.setPosition(gf.x,gf.y + gf.height - 90);
    add(circle3);
    circle3.alpha = 0.3;

    for(m in [circle1, circle2, circle3]) m.zIndex = 1; 
    for(m in [boyfriendGroup, gfGroup, dadGroup]) m.zIndex = 2;

    initHUD();
    for (i in ui) {
        if(i.zIndex != 999){
            i.zIndex = 1;
            playHUD.add(i);
        } 
        i.antialiasing = ClientPrefs.globalAntialiasing;
    }
    refreshZ(playHUD);

    scoreAllowedToBop = false;
    modManager.setValue('alpha',1,1);
    var t = [[-1,-1],[-1,-1],[-1,-3],[-1,-1]];
    for (i in 0...t.length) {
        playerStrums.members[i].addOffset('confirm',t[i][0],t[i][1]);
        playerStrums.members[i].addOffset('pressed',t[i][0],t[i][1]);
    }

    healthLoss = 0;
    healthGain = 0;

}

function onSpawnNotePost(note){
    if (note.isSustainNote) {
        note.alpha = note.multAlpha = 1;
    }
}

function initHUD() {
    for(i in playHUD.members)
        if(i != null) i.visible = false;

    var songNameUnderlay = new FlxSprite().loadGraphic(Paths.image('ui/brush'));
    // songNameUnderlay.setScale(0.75);
    songNameUnderlay.scale.set(0.75, 0.75);
    songNameUnderlay.updateHitbox();
    songNameUnderlay.screenCenter(FlxAxes.X);
    ui.push(songNameUnderlay);
    if (ClientPrefs.downScroll) {
        songNameUnderlay.y = FlxG.height - songNameUnderlay.height + 5;
    }

    var songName = new FlxText(0,0,0,PlayState.SONG.song,40);
    songName.font = Paths.font('upheavtt.ttf');
    songName.y = songNameUnderlay.y + (songNameUnderlay.height - songName.height)/2 - 5;
    songName.screenCenter(FlxAxes.X); //field width wasnt working??????
    ui.push(songName);

    var scoreUnderlay = new FlxSprite().loadGraphic(Paths.image('ui/stats paper'));
    scoreUnderlay.screenCenter(FlxAxes.X);
    ui.push(scoreUnderlay);
    scoreUnderlay.y = FlxG.height - scoreUnderlay.height + 5;
    if (ClientPrefs.downScroll) {
        scoreUnderlay.flipY = true;
        scoreUnderlay.y = -10;
    }

    playHUD.scoreTxt.font = Paths.font('Sonic Advanced 2.ttf');
    playHUD.scoreTxt.color = 0x392E28;
    playHUD.scoreTxt.borderSize = 0;
    playHUD.scoreTxt.size = 32;
    playHUD.scoreTxt.y = scoreUnderlay.y + (scoreUnderlay.height - playHUD.scoreTxt.height)/2 + 15;
    playHUD.scoreTxt.zIndex = 999;
    if (ClientPrefs.downScroll) {
        playHUD.scoreTxt.y+= -30; 
    }
    playHUD.scoreTxt.visible = true;
    ui.push(playHUD.scoreTxt);


    var heartFrame = new FlxSprite(50,75).loadGraphic(Paths.image('ui/hearts base'));
    heartFrame.scale.set(0.75, 0.75);
    heartFrame.updateHitbox();
    ui.push(heartFrame);
    if (ClientPrefs.downScroll) {
        heartFrame.y = FlxG.height - heartFrame.height - 50;
    }

    for (i in 0...3) {
        var heart = new FlxSprite();
        heart.frames = Paths.getSparrowAtlas('ui/heart');
        heart.animation.addByPrefix('half','halfheart anim',24,false);
        heart.animation.addByPrefix('empty','emptyheart anim',24,false);
        // heart.addAndPlay('full','heart anim',24,false);
        heart.animation.addByPrefix("full", 'heart anim', 24, false);
        heart.animation.play('full');
        heart.scale.set(0.6, 0.6);
        heart.updateHitbox();
        heart.setPosition(15 + (heartFrame.width - heart.x) / 2, -6.5 + (heartFrame.width - heart.y) / 4);
        heart.x += (heart.width * (i - (3/2))) + 30;
        ui.push(heart);
        hearts.push(heart);
    }

    oppIcon = new FlxSprite().loadGraphic(Paths.image('ui/isaac icon'));
    oppIcon.scale.set(0.6, 0.6);
    oppIcon.updateHitbox();
    ui.push(oppIcon);
    oppIcon.y = heartFrame.y + (heartFrame.height - oppIcon.height)/2 - 5;
    oppIcon.x = heartFrame.x - oppIcon.width/2;

    bfIcon = new FlxSprite().loadGraphic(Paths.image('ui/bf icon'));
    bfIcon.scale.set(0.6, 0.6);
    bfIcon.updateHitbox();
    ui.push(bfIcon);
    bfIcon.y = heartFrame.y + (heartFrame.height - bfIcon.height)/2 - 5;
    bfIcon.x = heartFrame.x + heartFrame.width - bfIcon.width/2;

    var noteUnderlay = new FlxSprite().loadGraphic(Paths.image('ui/basebase'));
    // noteUnderlay.setScale(0.7);
    noteUnderlay.scale.set(0.7, 0.7);
    noteUnderlay.updateHitbox();
    noteUnderlay.x = playerStrums.members[0].x + script_NOTEOffsets[0].x;
    noteUnderlay.y = playerStrums.members[0].y + (playerStrums.members[0].height - noteUnderlay.height)/2 + script_NOTEOffsets[0].y;
    ui.push(noteUnderlay);
    if (ClientPrefs.downScroll) {
        noteUnderlay.y = FlxG.height - noteUnderlay.height - 15 - 25;
    }

    showCombo = false;
    showRating = false;

    PlayState.instance.updateScoreBar();
}

function onUpdateScore(miss){
    playHUD.scoreTxt.text = 'SCORE: ' + songScore + ' | RATING: ' + ratingName;
    if(ratingName != '?')
        playHUD.scoreTxt.text += ' | ACC: ' + MathUtil.floorDecimal(ratingPercent * 100, 2) + '%' + ' - ' + ratingFC;

    return Function_Stop;
}

function onBeatHit() {
    for (i in [oppIcon,bfIcon]) {
        i.scale.set(0.7,0.7);
    }

    if (curBeat % 2 == 0) {
        for (i in hearts) {
            i.animation.play(i.animation.curAnim.name);
        }
    }

}

function onSongStart() {

}


function noteMiss(d) {
    if (!d.isSustainNote)
        lostHP();
}

function noteMissPress(d) {
    if (!d.isSustainNote) // i should add some logic to invalidate notes essentially maybe
        lostHP();
}

function update(elapsed) 
{
    // if (FlxG.keys.justPressed.Y) { 
    //     die();
    // }

    invincTime-=elapsed;

    var mult:Float = FlxMath.lerp(0.6, bfIcon.scale.x, Math.exp(-elapsed * 9));
    bfIcon.scale.set(mult, mult);

    var mult:Float = FlxMath.lerp(0.6, oppIcon.scale.x, Math.exp(-elapsed * 9));
    oppIcon.scale.set(mult, mult);
}

function onUpdatePost(elapsed) {
    if (lockConductor) {
        Conductor.songPosition = lockTime;
    }
}
function lostHP() 
{
    if (invincTime > 0) return;

    FlxFlicker.flicker(boyfriend,1,0.08,true,true, ()->{boyfriend.animTimer = 0; if (!lockConductor)boyfriend.dance();});
    boyfriend.playAnim('hurt',true);
    boyfriend.animTimer = 100;
    invincTime = 1;

    curHealth -= 1;
    for (i in 0...hearts.length) { //cheap but it works
        hearts[i].animation.play('full');
        if (i == curHealth/2) {
            hearts[i].animation.play('half',true);
        }

        if (i > curHealth/2) {
            hearts[i].animation.play('empty');
        }
    }

    if (curHealth < 0) die();
    else {
        FlxG.sound.play(Paths.sound('hurt-grunt-' + FlxG.random.int(0,2)));
    }

}

function onGameOver() {
    die();
    health = 2;
    return Globals.Function_Stop;
}

function die() {
    inCutscene = true;
    canPause = false;

    FlxG.sound.play(Paths.sound('isaac-dies-new-' + FlxG.random.int(0,2)));
    FlxG.sound.music.volume = 0;
    vocals.volume = 0;

    lockTime = Conductor.songPosition;
    lockConductor = true;

    FlxFlicker.stopFlickering(boyfriend);
    boyfriend.playAnim('death',true);
    boyfriend.animTimer = 100;
    boyfriend.animation.finishCallback = (n:String)->{
        if (n == 'death') {
            new FlxTimer().start(0.5,()->{
                paused = true;
                openSubState(new HScriptSubstate('death'));
            });
        }
    }

}


function onEvent(ev,v1,v2) {
    if (ev == '' && v1 == 'cutDie') {
        FlxG.camera._fxFadeColor = FlxColor.BLACK;
        FlxG.camera._fxFadeAlpha = 1;
    }
}