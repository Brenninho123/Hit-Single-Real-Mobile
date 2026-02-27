var him:FlxSprite;
var thing:FlxSprite;
var staticSprite:FlxSprite;
var black:FlxSprite;

function onLoad() {
    // BG image, loads the sprite "SCARYSAWKINGBG", sets the size to 2.1x the original size and adds the image.
    
    thing = new FlxSprite(-185, -290);
    thing.loadGraphic(Paths.image("SCARYSAWNIKBGRED"));
    thing.loadGraphic(Paths.image("THEHILLFORMERLYKNOWNASGREEN"));
    thing.loadGraphic(Paths.image("SCARYSAWNIKBG"));
    thing.scale.set(2.1, 2.1);
    thing.updateHitbox();
    add(thing);

    black = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
    black.cameras = [camOther];
    black.alpha = 0;
    add(black);

    him = new FlxSprite(925, 500).loadGraphic(Paths.image("What the fuck"));
    him.visible = false;
    // him.setPosition(dad.x, dad.y);
    add(him);
    
    // for(i in 0...3){
    //     var staticSprite = new FlxSprite();
    //     staticSprite.frames = Paths.getSparrowAtlas("daSTAT");
    //     staticSprite.animation.addByPrefix("static", "staticFLASH", 24, true);
    //     staticSprite.animation.play("static");
    //     staticSprite.scrollFactor.set();
    //     staticSprite.scale.set(2, 2);
    //     staticSprite.updateHitbox();
    //     // staticSprite.screenCenter();
    //     staticSprite.alpha = 0.03;
    //     // staticSprite.visible = false;
    //     staticSprite.x = 0 + (staticSprite.width * i);
    //     staticSprite.y -= 200;
    //     foreground.add(staticSprite);    
    // }
    // for(i in 0...3){
    //     var staticSprite = new FlxSprite();
    //     staticSprite.frames = Paths.getSparrowAtlas("daSTAT");
    //     staticSprite.animation.addByPrefix("static", "staticFLASH", 24, true);
    //     staticSprite.animation.play("static");
    //     staticSprite.scrollFactor.set();
    //     staticSprite.scale.set(2, 2);
    //     staticSprite.updateHitbox();
    //     // staticSprite.screenCenter();
    //     staticSprite.alpha = 0.03;
    //     // staticSprite.visible = false;
    //     staticSprite.x = 0 + (staticSprite.width * i);
    //     staticSprite.y += 397;
    //     foreground.add(staticSprite);    
    // }

}

function onCreatePost() {
    game.canReset = false;
}

function onUpdate(elapsed){

    game.health = 2;

    // if(FlxG.keys.pressed.NINE){
    //     dad.visible = false;
    //     him.visible = true;
    // }else{
    //     dad.visible = true;
    //     him.visible = false;
    // }
}

function onEvent(eventName, value1, value2){
    // 2:48 > Lights turn off
    // 2:51 > Lights turn on
    // 3:46 "Remember... THIS." > Hills
    // 4:35 > turn red
    switch(eventName){
        case 'Camera Fade':
            black.alpha = 1;
            camOther.flash(0xFF808080, 1.68);
        case "evilRED":
            switch(value1){
                case 'fucker1':
                    thing.loadGraphic(Paths.image("SCARYSAWNIKBGRED"));
                    black.alpha = 0;
                    camOther.flash(0xFF660000, 1.68);
                case 'fucker2':
                    camOther.flash(0xFFddab4e, 1.68);
                    thing.loadGraphic(Paths.image("THEHILLFORMERLYKNOWNASGREEN"));
                    thing.color = 0xFFc1c1c1;
                    dad.color = 0xFFFFFFFF;
            }
    }
}