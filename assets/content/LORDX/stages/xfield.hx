function onLoad() {
    var field:FlxSprite = new FlxSprite(-600, -400).loadGraphic(Paths.image("field"));
    add(field);

    // var yoshi = new Yoshi([field.x, field.width], 700, 2);
    // if(KUTValueHandler.getYoshi()) foreground.add(yoshi);
    // PlayState.instance.camHUD.alpha = 0;
}

function onEvent(){
    if(curBeat == 32)
        FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 1);
}

function onCreatePost(){
    for(m in playHUD.members) m.visible = false;
    playHUD.scoreTxt.visible = true;

    game.canReset = false;
}

function onUpdate(elapsed){
    if (game.health < 1) {
        game.health = 2;
    }
}