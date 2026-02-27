var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
var fire:FlxSprite;
var doubleBop:Bool = false;

function onCreatePost() {
    for(m in playHUD.members) m.visible = false;
    playHUD.scoreTxt.visible = true;
    
    skipCountdown = true;
    camGame.alpha = 0;
    camHUD.alpha = 0;

    //Stage-specific visibility / color modifiers
    dad.color = 0xffa19f9f;
    boyfriend.visible = false;
    
    gf.flipY = true;
    gf.alpha = 0.5;
    gf.color = 0xFF1B1818;

    for(m in dadGroup) m.ghostsEnabled = false;

    fire = new FlxSprite().loadGraphic(Paths.image("fire"));
    fire.cameras = [camOther];
    fire.scale.set(2.5, 2.5);
    fire.alpha = 0;
    fire.screenCenter();
    fire.y = -1980;
    add(fire);

    modManager.setValue("alpha", 1, 1);
}

function onStepHit() {
    switch(curStep){
        case 80:
            camGame.alpha = 1;
            camHUD.alpha = 1;
            camHUD.flash(0xFF808080, 1.68);
    }
}

function opponentNoteHit(note){
    var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
    gf.playAnim(animToPlay, true);
    gf.holdTimer = 0;
}

function onBeatHit(){
    if(doubleBop){
        camHUD.zoom += 0.03;
        FlxG.camera.zoom += 0.015;
    }

}

function onEvent(eventName, value1, value2){
    switch(eventName){
        case 'bop':
            if(value1 == "true")
                doubleBop = true;
            else
                doubleBop = false;
        case 'fire':
            FlxTween.tween(fire, {y: 0, alpha: 1}, 12, {onComplete: function(sht:FlxTween){
                camGame.alpha = 0;
                camHUD.alpha = 0;
                FlxTween.tween(fire, {y: 1980, alpha: 0}, 12);
            }});
        case 'Change Character':
            if(value1 == "dad"){
                switch(value2){
                    case 'x_3dEVIL':
                        dad.color = 0xFFff66ff;
                    default:
                        dad.color = 0xFFca5d5d;
                        // 0xFFd35454 maybe
                }
            }else if(value1 == "gf"){
                switch(value2){
                    case 'x_3d_shadow':
                        gf.flipY = true;
                        gf.color = 0xFF000000;
                        gf.alpha = 0.5;
                    case 'x_3dEVIL_shadow':
                        gf.flipY = true;
                        gf.color = 0xFF000000;
                        gf.alpha = 0.325;
                }
            }
    }
}