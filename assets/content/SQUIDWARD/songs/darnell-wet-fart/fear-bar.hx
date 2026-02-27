import flixel.ui.FlxBar;
import funkin.data.Highscore;
import funkin.utils.MathUtil;
// addHaxeLibrary('Highscore', 'meta.data');

var fuck:FlxBar;
var bluevg:FlxSprite;
var fearNo:Float = 0;
var fearStr:String = "?";
var text:FlxText;
var black:FlxSprite;

function onCreatePost() {

    var fearBarBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bar"));
    fearBarBG.cameras = [camHUD];
    fearBarBG.scale.set(0.325, 0.325);
    fearBarBG.updateHitbox();
    fearBarBG.screenCenter();
    fearBarBG.x = FlxG.width - (fearBarBG.width * 1.25);

    fuck = new FlxBar(0, 0);
    fuck.createFilledBar(0xFF000000, 0xFF0000FF);
    fuck.cameras = [camHUD];
    fuck.angle = 270;
    fuck.scale.set(3.25,2.8);
    fuck.x = fearBarBG.x - 1.25;
    fuck.y = FlxG.height - 370;

    bluevg = new FlxSprite().loadGraphic(Paths.image("blueVG"));
    bluevg.alpha = 0;
    bluevg.cameras = [camOther];

    playHUD.scoreTxt.setFormat(Paths.font("sponge.ttf"), 24, 0xFF0000FF);
    playHUD.scoreTxt.borderColor = 0xFF000000;
    playHUD.scoreTxt.borderSize = 2;
    playHUD.scoreTxt.borderStyle = FlxTextBorderStyle.OUTLINE;
    // FlxG.log.add(scoreTxt.borderSize);

    add(fuck);
    add(fearBarBG);
    add(bluevg);
    

    black = new FlxSprite(-200, -200);
    black.makeGraphic(1280 * 2, 720 * 2, 0xFF000000);
    black.scrollFactor.set();
    add(black);

    // scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' | Fear: ' + fearStr;
}

function onUpdate(elapsed){
    FlxG.watch.addQuick("Fear:", fearNo);
    FlxG.watch.addQuick("Health:", health);

    if(fuck != null) fuck.percent = fearNo;

    if(health >= 0.1){
        if (fearNo < 25 && fearNo > 0.1){
            health -= 0.05* elapsed;
            fearStr = "Normal";
        }
        else if (fearNo >= 25 && fearNo < 50){
            health -= 0.075 * elapsed;
            fearStr = "Paranoid";
        }
        else if (fearNo >= 50 && fearNo < 75){
            health -= 0.125 * elapsed;
            fearStr = "Scared";
        }
        else if (fearNo >= 75 && fearNo < 100){
            health -= 0.175 * elapsed;
            fearStr = "Terrified";
        }else if(fearNo >= 100){
            health = 0;
        }
    }

    bluevg.alpha = fearNo * 0.0075;
}

function opponentNoteHit(){
    fearNo += 0.1575;
    // yes this number is a real number
     // no i didnt spam my keyboard
     // i used a calculator
}

function goodNoteHit(){
    fearNo -= 0.15;
}

function onUpdateScore(){
    playHUD.scoreTxt.text =  'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName; 
    if(ratingName != '?')
        playHUD.scoreTxt.text += ' (' + MathUtil.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;	

    return Function_Stop;
}

function onSongStart(){
    FlxTween.tween(black, {alpha: 0}, 2);
}