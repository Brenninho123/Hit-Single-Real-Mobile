package funkin;

import haxe.Json;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.media.Sound;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Paths
{
	public static inline final CORE_DIRECTORY = "assets";
	public static inline final MODS_DIRECTORY = "content";

	public static inline final SOUND_EXT = "ogg";
	public static inline final VIDEO_EXT = "mp4";

	public static var currentLevel:Null<String> = null;

	public static function setCurrentLevel(?name:String):Void
	{
		currentLevel = name != null ? name.toLowerCase() : null;
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentFolder:String, checkMods:Bool = false):String
	{
		#if MODS_ALLOWED
		#if sys
		if (checkMods)
		{
			var modPath = modFolders(parentFolder == null ? file : parentFolder + "/" + file);
			if (FileSystem.exists(modPath)) return modPath;
		}
		#end
		#end

		if (parentFolder != null)
			return '$CORE_DIRECTORY/$parentFolder/$file';

		if (currentLevel != null)
		{
			var levelPath = '$CORE_DIRECTORY/$currentLevel/$file';
			if (Assets.exists(levelPath, type)) return levelPath;
		}

		return '$CORE_DIRECTORY/$file';
	}

	// Retorna o caminho primário como string pura
	// Quando chamado sem argumentos, retorna o diretório raiz de mods
	public static function getPrimaryPath(?key:String, ?library:String):String
	{
		if (key == null || key.length == 0)
		{
			#if MODS_ALLOWED
			return mods();
			#else
			return CORE_DIRECTORY + '/';
			#end
		}

		#if MODS_ALLOWED
		#if sys
		var modPath = modFolders(key);
		if (FileSystem.exists(modPath)) return modPath;
		#end
		#end

		return getPath(key, TEXT, library);
	}

	// Força um caminho de biblioteca específica
	public static function getLibraryPathForce(key:String, ?library:String):String
	{
		if (library != null && library.length > 0)
			return '$CORE_DIRECTORY/$library/$key';
		return '$CORE_DIRECTORY/$key';
	}

	public static inline function txt(key:String, ?library:String):String
		return getPath('data/$key.txt', TEXT, library, true);

	public static inline function xml(key:String, ?library:String):String
		return getPath('data/$key.xml', TEXT, library, true);

	public static inline function json(key:String, ?library:String):String
		return getPath('songs/$key.json', TEXT, library, true);

	public static inline function noteskin(key:String, ?library:String):String
		return getPath('noteskins/$key.json', TEXT, library, true);

	public static inline function lua(key:String, ?library:String):String
		return getPath('$key.lua', TEXT, library);

	public static function sound(key:String, ?library:String):Null<Sound>
	{
		var path = getPath('sounds/$key.$SOUND_EXT', SOUND, library, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}

	public static function soundRandom(key:String, min:Int, max:Int, ?library:String):Null<Sound>
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	public static function music(key:String, ?library:String):Null<Sound>
	{
		var path = getPath('music/$key.$SOUND_EXT', SOUND, library, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}

	public static function image(key:String, ?library:String, ?cache:Bool = true):Null<FlxGraphic>
	{
		var path = getPath('images/$key.png', IMAGE, library, true);
		return Assets.exists(path) ? FlxGraphic.fromBitmapData(Assets.getBitmapData(path)) : null;
	}

	public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		var xmlPath = getPath('images/$key.xml', TEXT, library, true);
		var img = image(key, library);
		return FlxAtlasFrames.fromSparrow(img, Assets.getText(xmlPath));
	}

	public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		var txtPath = getPath('images/$key.txt', TEXT, library, true);
		var img = image(key, library);
		return FlxAtlasFrames.fromSpriteSheetPacker(img, Assets.getText(txtPath));
	}

	public static function getMultiAtlas(keys:Array<String>, ?library:String):FlxAtlasFrames
	{
		var baseFrames = getSparrowAtlas(keys[0], library);
		if (keys.length <= 1) return baseFrames;

		for (i in 1...keys.length)
		{
			var extraFrames = getSparrowAtlas(keys[i], library);
			for (frame in extraFrames.frames)
				baseFrames.pushFrame(frame);
		}

		return baseFrames;
	}

	// Texture Atlas (pasta do Animation.json)
	public static function textureAtlas(key:String, ?library:String):String
		return getPath('images/$key', TEXT, library, true);

	// Texto de arquivo
	public static function getTextFromFile(key:String, ?library:String):String
	{
		var path = getPath(key, TEXT, library, true);
		#if sys
		if (FileSystem.exists(path)) return File.getContent(path);
		#end
		return Assets.exists(path) ? Assets.getText(path) : '';
	}

	// Verificação de arquivo
	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String):Bool
	{
		#if MODS_ALLOWED
		#if sys
		if (!ignoreMods)
		{
			var modPath = modFolders(key);
			if (FileSystem.exists(modPath)) return true;
		}
		#end
		#end

		var path = getPath(key, type, library);
		#if sys
		if (FileSystem.exists(path)) return true;
		#end
		return Assets.exists(path, type);
	}

	// Font
	public static inline function font(key:String):String
		return getPath('fonts/$key', TEXT);

	// Shaders
	public static inline function shaderFrag(key:String):String
		return getPath('shaders/$key.frag', TEXT, null, true);

	public static inline function shaderVert(key:String):String
		return getPath('shaders/$key.vert', TEXT, null, true);

	// Inst e Voices
	public static function inst(song:String, ?library:String):Null<Sound>
	{
		var path = getPath('songs/${formatToSongPath(song)}/Inst.$SOUND_EXT', SOUND, library, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}

	public static function voices(song:String, ?postfix:String, ?cache:Bool = true):Null<Sound>
	{
		var suffix = (postfix != null && postfix.length > 0) ? '-$postfix' : '';
		var path = getPath('songs/${formatToSongPath(song)}/Voices$suffix.$SOUND_EXT', SOUND, null, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}

	public static function formatToSongPath(path:String):String
		return path.toLowerCase().replace(" ", "-");

	// ================= MODS =================
	// Esses métodos ficam FORA do #if MODS_ALLOWED para evitar erros de compilação
	// quando a flag não está ativa — eles simplesmente retornam o path base

	public static inline function mods(key:String = ""):String
		return '$MODS_DIRECTORY/$key';

	public static inline function modsJson(key:String):String
		return modFolders('songs/$key.json');

	public static inline function modsFont(key:String):String
		return modFolders('fonts/$key');

	public static inline function modsTxt(key:String):String
		return modFolders('images/$key.txt');

	public static inline function modsNoteskin(key:String):String
		return modFolders('noteskins/$key.json');

	public static function modFolders(key:String):String
	{
		#if sys
		#if MODS_ALLOWED
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
		{
			var path = mods(Mods.currentModDirectory + "/" + key);
			if (FileSystem.exists(path)) return path;
		}

		for (mod in Mods.globalMods)
		{
			var path = mods(mod + "/" + key);
			if (FileSystem.exists(path)) return path;
		}
		#end
		#end

		return '$MODS_DIRECTORY/$key';
	}
}