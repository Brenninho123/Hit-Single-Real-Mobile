import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;

var text:FlxText;

function onCreatePost(){
    text = new FlxText();
    text.cameras = [camOther];
    text.setFormat(Paths.font("sponge.ttf"), 24, 0xFF0000FF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    text.screenCenter();
    text.color = 0xFF0000FF;
    text.y = playHUD.healthBar.y - text.height;
    add(text);
}

function onEvent(eventName, value1){
    switch(eventName){
        case 'Lyrics':
            text.text = value1;
            text.screenCenter();
            text.y = playHUD.healthBar.y - text.height;
    }
}