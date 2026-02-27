import funkin.states.MainMenuState;
import flixel.addons.transition.FlxTransitionableState;
import funkin.game.KUTValueHandler;

import funkin.states.HitSingleMenu;
import funkin.states.HitSingleMenu.Mode;


function onCreatePost() {
    // trace('penis');
    PlayState.instance.persistentUpdate = false;

    var bg = new FlxSprite().makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
    add(bg);
    bg.alpha = 0.3;
    bg.cameras = [PlayState.instance.camOther];

    var youDIED = new FlxSprite().loadGraphic(Paths.image('ui/gameover'));
    youDIED.updateGraphicSize(FlxG.width,FlxG.height);
    add(youDIED);

    for (i in [bg, youDIED]) {
        i.antialiasing = ClientPrefs.globalantialiasing;
        i.cameras = [PlayState.instance.camOther];
    }

}

function onUpdate(elapsed) {
    if (FlxG.keys.justPressed.SIX) {
        FlxG.resetState();
    }
    if (FlxG.keys.justPressed.ESCAPE) {
        leaveMenu(()->{
            FlxG.switchState(()->new HitSingleMenu(Mode.MAIN));
            FlxG.sound.playMusic(Paths.music(KUTValueHandler.getMenuMusic()));
            FlxG.sound.music.volume = 1;
        });
    }

    if (FlxG.keys.justPressed.SPACE) {
        leaveMenu(()->{FlxG.resetState();});

    }

}

function leaveMenu(func) {
    var cam = FlxG.cameras.list[FlxG.cameras.list.length-1];
    // FlxTransitionableState.skipNextTransOut = true;
    FlxTransitionableState.skipNextTransIn = true;
    FlxTween.tween(cam, {_fxFadeAlpha: 1},0.25, {onComplete: ()->{
        func();
    }});

}