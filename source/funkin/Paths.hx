package funkin;

import haxe.Json;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if android
import lime.system.System;
#end

class Paths
{
	public static inline final CORE_DIRECTORY = "assets";
	public static inline final MODS_DIRECTORY = "assets/content";

	public static inline final SOUND_EXT = "ogg";
	public static inline final VIDEO_EXT = "mp4";

	public static var currentLevel:Null<String> = null;

	/* ========================= STORAGE ========================= */

	public static function getAndroidStoragePath():String
	{
		#if android
		return System.applicationStorageDirectory + "/mods/";
		#else
		return MODS_DIRECTORY + "/";
		#end
	}

	/* ========================= CORE ========================= */

	public static function setCurrentLevel(?name:String):Void
	{
		currentLevel = name != null ? name.toLowerCase() : null;
	}

	public static function getPrimaryPath():String
	{
		return CORE_DIRECTORY;
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:String, checkMods:Bool = false):String
	{
		#if MODS_ALLOWED
		if (checkMods)
		{
			var modPath = modFolders(file);
			if (fileExists(modPath))
				return modPath;
		}
		#end

		if (library != null)
			return '$CORE_DIRECTORY/$library/$file';

		return '$CORE_DIRECTORY/$file';
	}

	public static function fileExists(path:String):Bool
	{
		#if sys
		return FileSystem.exists(path);
		#else
		return Assets.exists(path);
		#end
	}

	public static function getTextFromFile(path:String):String
	{
		#if sys
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end

		if (Assets.exists(path))
			return Assets.getText(path);

		return "";
	}

	/* ========================= BASIC ASSETS ========================= */

	public static inline function txt(key:String, ?library:String)
		return getPath('data/$key.txt', TEXT, library, true);

	public static inline function json(key:String, ?library:String)
		return getPath('data/$key.json', TEXT, library, true);

	public static inline function image(key:String, ?library:String, allowGPU:Bool = true):Null<FlxGraphic>
	{
		return FunkinAssets.getGraphic(getPath('images/$key.png', IMAGE, library, true), true, allowGPU);
	}

	public static inline function font(key:String):String
	{
		return getPath('fonts/$key.ttf', FONT, null, true);
	}

	public static inline function sound(key:String, ?library:String)
	{
		return FunkinAssets.getSound(getPath('sounds/$key.$SOUND_EXT', SOUND, library, true));
	}

	public static inline function music(key:String, ?library:String)
	{
		return FunkinAssets.getSound(getPath('music/$key.$SOUND_EXT', SOUND, library, true));
	}

	public static inline function soundRandom(key:String, min:Int, max:Int)
	{
		var random = FlxG.random.int(min, max);
		return sound(key + random);
	}

	public static inline function voices(song:String)
	{
		return FunkinAssets.getSound(getPath('songs/${formatToSongPath(song)}/Voices.$SOUND_EXT', SOUND, null, true));
	}

	public static inline function inst(song:String)
	{
		return FunkinAssets.getSound(getPath('songs/${formatToSongPath(song)}/Inst.$SOUND_EXT', SOUND, null, true));
	}

	/* ========================= ATLASES ========================= */

	public static function textureAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return getSparrowAtlas(key, library);
	}

	public static function getSparrowAtlas(key:String, ?library:String, allowGPU:Bool = true):FlxAtlasFrames
	{
		var xmlPath = getPath('images/$key.xml', TEXT, library, true);
		var img = image(key, library, allowGPU);
		return FlxAtlasFrames.fromSparrow(img, getTextFromFile(xmlPath));
	}

	/* ========================= SHADERS ========================= */

	public static inline function shaderFrag(key:String)
		return getPath('shaders/$key.frag', TEXT, null, true);

	public static inline function shaderVert(key:String)
		return getPath('shaders/$key.vert', TEXT, null, true);

	/* ========================= NOTESKINS ========================= */

	public static inline function noteskin(key:String)
		return getPath('images/noteskins/$key.png', IMAGE, null, true);

	public static inline function modsNoteskin(key:String)
		return modFolders('images/noteskins/$key.png');

	/* ========================= MODS ========================= */

	#if MODS_ALLOWED

	public static inline function mods(key:String = ''):String
	{
		return getAndroidStoragePath() + key;
	}

	public static function modFolders(key:String):String
	{
		var base = getAndroidStoragePath();

		#if sys
		if (FileSystem.exists(base))
		{
			for (folder in FileSystem.readDirectory(base))
			{
				var path = base + folder + '/' + key;
				if (FileSystem.exists(path))
					return path;
			}
		}
		#end

		return base + key;
	}

	public static inline function modsJson(key:String)
	{
		return modFolders('data/$key.json');
	}

	#end

	/* ========================= UTIL ========================= */

	public static inline function formatToSongPath(path:String):String
	{
		return path.toLowerCase().replace(" ", "-");
	}
}