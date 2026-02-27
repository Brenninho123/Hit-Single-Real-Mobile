addHaxeLibrary('HitSingleMenu', 'meta.states');
addHaxeLibrary('FlxTransitionableState', 'flixel.addons.transition');
addHaxeLibrary('KUTValueHandler', 'meta.states');

function onLoad() {
    // trace('penis');
    PlayState.instance.persistentUpdate = false;
    


    var bg = new FlxSprite().makeScaledGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
    add(bg);
    bg.alpha = 0.3;
    bg.cameras = [PlayState.instance.camOther];

    var youDIED = new FlxSprite().loadImage('ui/gameover');
    youDIED.updateGraphicSize(FlxG.width,FlxG.height);
    add(youDIED);

    for (i in members) {
        i.antialiasing = ClientPrefs.globalantialiasing;
        i.cameras = [PlayState.instance.camOther];
    }

}

function update(elapsed) {
    if (FlxG.keys.justPressed.SIX) {
        FlxG.resetState();
    }
    if (FlxG.keys.justPressed.ESCAPE) {
        leaveMenu(()->{
            FlxG.switchState(new HitSingleMenu());
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
    FlxTransitionableState.skipNextTransOut = true;
    FlxTween.tween(cam, {_fxFadeAlpha: 1},0.25, {onComplete: ()->{
        func();
    }});

}