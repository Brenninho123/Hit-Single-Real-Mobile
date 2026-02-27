import flixel.text.FlxText;

var text:FlxText;

function onCreatePost() {
    text = new FlxText();
    text.cameras = [PlayState.instance.camOther];
    text.setFormat(Paths.font("Castellar.ttf"), 36, 0xFFFFFFFF);
    text.screenCenter();
    text.color = 0xFFFFFFFF;
    text.y = playHUD.healthBar.y - (text.height * 2);
    add(text);
}

function onEvent(eventName, value1, value2){
    switch(eventName){
        case 'lyric':
            text.text = value1;
            text.screenCenter();
            text.y = playHUD.healthBar.y - (text.height * 2);
    }
}