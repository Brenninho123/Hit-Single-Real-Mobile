import funkin.scripting.HScriptSubstate;
import funkin.video.FunkinVideoSprite;

var scene:FunkinVideoSprite;
var phase1 = [];
var phase2 = [];
var post = false;
var logo:FlxSprite;
var amidead:Bool = false;
var preDeath:FlxSprite;
var postDeath:FlxSprite;
var missFlicker = null;

function onLoad()
{
	var bg = new FlxSprite().loadGraphic(Paths.image('stage/lettherebebg'));
	bg.screenCenter();
	add(bg);
    phase1 = [bg];
	
    var bg2 = new FlxSprite().loadGraphic(Paths.image('stage/BackGround'));
    bg2.screenCenter();
    add(bg2);

    var fire = new FlxSprite();
    fire.frames = Paths.getSparrowAtlas('stage/junkfire');
    fire.animation.addByPrefix('idle', 'fire',  24, true);
    fire.animation.play('idle');
    fire.screenCenter();
    fire.blend = BlendMode.ADD;
    add(fire);

    var junk = new FlxSprite().loadGraphic(Paths.image('stage/Junk'));
    junk.screenCenter();
    junk.zIndex = 2;
    add(junk);
	
	phase2 = [bg2, fire, junk];
	
	for (m in phase2)
	{
        junk.antialiasing = ClientPrefs.globalAntialiasing;
		m.visible = false;
	}
}

function onCreatePost()
{
	modManager.setValue("opponentSwap", 1);
	playHUD.flipBar();
	
	dad.danceEveryNumBeats = 2;
	boyfriend.danceEveryNumBeats = 2;
	
	addCharacterToList('m2', 0);
	addCharacterToList('d2', 1);
	
	for (b in boyfriendGroup.members)
	{
		b.useMissColoring = true;
		b.missColor = FlxColor.WHITE;
	}
	
	scene = new FunkinVideoSprite();
	if (scene.load(Paths.video('scene'), [FunkinVideoSprite.muted]))
	{
		scene.onStart(() -> {
			scene.stop();
			scene.visible = false;
		}, true);
		
		scene.play();
	}
	scene.onFormat(() -> {
		scene.cameras = [camHUD];
		scene.screenCenter();
		scene.visible = false;
	});
	scene.onEnd(p2);
	scene.onStart(()->{
		scene.visible = true;
	});
	add(scene);
	
	logo = new FlxSprite().loadGraphic(Paths.image('logo'));
	logo.camera = camHUD;
	logo.y = ClientPrefs.downScroll ? 44 : FlxG.height - (88);
	logo.visible = false;
	add(logo);
	
	preDeath = new FlxSprite(-750, -350).loadSparrowFrames('death/pre');
	preDeath.animation.addByPrefix('die', 'Death', 24, false);
	preDeath.visible = false;
	preDeath.animation.onFinish.addOnce(loadDeathState);
	add(preDeath);
	
	postDeath = new FlxSprite().loadSparrowFrames('death/post');
	postDeath.animation.addByPrefix('die', 'Death', 24, false);
	postDeath.screenCenter();
	postDeath.x -= 50;
	postDeath.y += 315;
	postDeath.visible = false;
	postDeath.animation.onFinish.addOnce(loadDeathState);
	postDeath.zIndex = 9;
	add(postDeath);
	
	modManager.queueEase(824, 832, "alpha", 1, 'quadInOut');
	modManager.queueEase(824, 832, "opponentSwap", 0.5, 'quadInOut');
	modManager.queueEase(1081, 1086, "alpha", 0, 'quadInOut',0);
	modManager.queueFuncOnce(1090, (s,s2)->{ vocals.volume = 1; });


	if (ClientPrefs.downScroll)
	{
		modManager.queueEase(834, 834, "transformY", -50, 'quadInOut');
	}

	// p2();
	
	game.skipCountdown = true;

}

function noteMissPress(note)
{
	missShit();
}

function noteMiss(note)
{
	missShit();
}

function resetFlicker(flciker)
{
	if (flciker == null) return;
	
	if (flciker.timer != null) flciker.timer.cancel();
	if (flciker.object != null) flciker.object.visible = true;
	flciker.release();
	flciker = null;
}

function missShit()
{
	resetFlicker(missFlicker);
	
	boyfriend.setColorTransform(1, 1, 1, 1, 100, 100, 100, 0);
	missFlicker = FlxFlicker.flicker(boyfriend, 1, 0.05, true, true, () -> {
		boyfriend.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
	});
}

function p2()
{
	if (ClientPrefs.downScroll)
	{
		modManager.setValue('transformY',0);
	}
	FlxG.camera.flash(FlxColor.ORANGE, 0.5);
	
	for (m in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2, playHUD.timeTxt, playHUD.timeBar])
	{
		if (m != null) m.alpha = 0;
	}
	
	for (m in phase2)
	{
		m.visible = true;
	}
	playHUD.scoreTxt.alpha = 1;
	
	logo.visible = true;
	FlxTween.tween(logo, {alpha: 0}, 8, {startDelay: 1, onComplete: logo.destroy});
	
	triggerEventNote('Change Character', 'bf', 'm2');
	triggerEventNote('Change Character', 'dad', 'd2');
	
	dad.screenCenter(FlxAxes.X);
	dad.x -= 10;
	dad.y = -32.5;
	boyfriend.screenCenter(FlxAxes.X);
	boyfriend.x += 17;
	
	dadGroup.zIndex = 1;
	boyfriendGroup.zIndex = 3;
	refreshZ(stage);
	

	FlxG.camera.zoom = defaultCamZoom = 2.3;

	var p = getCharacterCameraPos(dad);
	snapCamToPos(p.x, p.y - 150,true);


	var time = 2;

	FlxTween.tween(FlxG.camera, {zoom: 1.0625},time,{ease: FlxEase.expoInOut});

	// var player = getCharacterCameraPos(boyfriend);

	function lock() FlxG.camera.snapToTarget();

	FlxTween.tween(camFollow, {y: p.y},time,{ease: FlxEase.expoInOut,onUpdate: lock,onComplete: Void->{
		lock();
		isCameraOnForcedPos = false;
		post = true;
	}});

	

}

function onMoveCamera(turn)
{
	if (post)
	{
		if (turn == 'dad') defaultCamZoom = 1.0625;
		else defaultCamZoom = (0.925 + 0.005);
	}
}

function vid()
{
	for (m in [playHUD.healthBar, playHUD.iconP1, playHUD.iconP2, playHUD.timeTxt, playHUD.timeBar, playHUD.scoreTxt])
	{
		FlxTween.tween(m, {alpha: 0}, 0.75);
	}
	scene.play();
}

function onEvent(eventName, value1, value2)
{
	if (eventName == 'vid') vid();
}

function onGameOver()
{
	die();
	return Function_Stop;
}

function onPause()
{
	if (amidead) return Function_Stop;
}

function die()
{
	FlxTween.tween(camHUD, {alpha: 0}, 0.625);
	
	FlxTween.tween(FlxG.camera, {zoom: post ? 1.125 : 0.775}, 0.625,
		{
			ease: FlxEase.quadOut,
			onComplete: (f) -> {
				actualDeath();
			}
		});
	for (m in [FlxG.sound.music, vocals])
		if (m != null) FlxTween.tween(m, {pitch: 0.125, volume: 0}, 0.625);

	KillNotes();
	
	isCameraOnForcedPos = true;
	camFollow.x = getCharacterCameraPos(boyfriend).x + (post ? 0 : -150);
	camFollow.y = getCharacterCameraPos(boyfriend).y + (post ? 75 : 0);
}

function actualDeath()
{
	if (amidead) return;
	
	amidead = true;
	finishTimer = new FlxTimer().start(1, (f) -> {});
	
	paused = true;
	persistentUpdate = false;
	persistentDraw = true;
	
	for (m in [FlxG.sound.music, vocals])
		if (m != null) m.stop();
		
	// if(m != null) FlxTween.tween(m, {volume: 0}, 0.625, {onComplete: m.stop});
	
	onPauseSignal.dispatch();
	FlxTimer.globalManager.forEach((i:FlxTimer) -> if (!i.finished) i.active = false);
	FlxTween.globalManager.forEach((i:FlxTween) -> if (!i.finished) i.active = false);
	
	FlxG.sound.play(Paths.sound('damage'));
	
	new FlxTimer().start(0.425, (t) -> {
		FlxG.sound.play(Paths.sound('death'));
	});
	boyfriend.visible = false;
	var d = post ? postDeath : preDeath;
	d.visible = true;
	d.animation.play('die');
}

function loadDeathState()
{
	FlxG.camera.fade(FlxColor.BLACK, 0.625);
	new FlxTimer().start(0.725, game.openSubState(new HScriptSubstate('VideoGO')));
}
