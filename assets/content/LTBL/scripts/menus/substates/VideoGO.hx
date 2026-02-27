import funkin.video.FunkinVideoSprite;
import funkin.states.MainMenuState;

var start:FunkinVideoSprite;
var loop:FunkinVideoSprite;
var end:FunkinVideoSprite;

var loopStarted:Bool = false;

function onCreatePost(){
    loop = new FunkinVideoSprite();
    loop.onFormat(()->{
        loop.camera = PlayState.instance.camOther;
    });
    loop.load(Paths.video('gameoverLoop'), [FunkinVideoSprite.looping]);

    end = new FunkinVideoSprite();
    end.onFormat(()->{
        end.camera = PlayState.instance.camOther;
    });
    end.load(Paths.video('gameoverEND'));

    start = new FunkinVideoSprite();
    start.onFormat(()->{
        start.camera = PlayState.instance.camOther;
    });
    start.load(Paths.video('gameoverINTROFADE'));

    new FlxTimer().start(4.05, ()->{
        loop.play();
        loopStarted = true;
    });

    add(start);
    add(loop);
    add(end);

    start.play();
}

function onUpdate(elapsed){
    // if(FlxG.keys.justPressed.R) FlxG.switchState(new PlayState());
    if(loopStarted){
        if(FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER){
            end.onEnd(()->{ leave(); FlxG.resetState(); });
            loop.stop();
            end.play();
        }
    }
}

function leave(){
    for(m in [start, loop, end])
        if(m != null) m.destroy();
}