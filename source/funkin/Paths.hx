package funkin;

import haxe.Json;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

class Paths
{
	#if ASSET_REDIRECT
	public static inline final trail = #if macos '../../../../../../../' #else '../../../../' #end;
	#end
	
	public static inline final CORE_DIRECTORY = #if ASSET_REDIRECT trail + 'assets/game' #else 'assets' #end;
	public static inline final MODS_DIRECTORY = #if ASSET_REDIRECT trail + 'assets/content' #else 'assets/content' #end;
	
	public static inline final SOUND_EXT = "ogg";
	public static inline final VIDEO_EXT = "mp4";
	
	public static var currentLevel:Null<String> = null;

	public static function getAndroidStoragePath():String
	{
		#if android
		return System.applicationStorageDirectory + "/mods/";
		#else
		return MODS_DIRECTORY + "/";
		#end
	}

	static public function setCurrentLevel(?name:String):Void
	{
		currentLevel = name?.toLowerCase() ?? null;
	}

	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentFolder:String, checkMods:Bool = false):String
	{
		#if MODS_ALLOWED
		if (checkMods)
		{
			var modPath:String = modFolders(parentFolder == null ? file : parentFolder + '/' + file);
			if (FileSystem.exists(modPath)) return modPath;
		}
		#end
		
		if (parentFolder != null)
			return '$CORE_DIRECTORY/$parentFolder/$file';
		
		return '$CORE_DIRECTORY/$file';
	}

	public static inline function txt(key:String, ?library:String):String
		return getPath('data/$key.txt', TEXT, library, true);

	public static inline function json(key:String, ?library:String):String
		return getPath('songs/$key.json', TEXT, library, true);

	public static inline function image(key:String, ?library:String, allowGPU:Bool = true):Null<FlxGraphic>
	{
		#if sys
		var modImg:String = modFolders('images/$key.png');
		if (FileSystem.exists(modImg))
			return FunkinAssets.getGraphic(modImg, true, allowGPU);
		#end
		
		return FunkinAssets.getGraphic(getPath('images/$key.png', IMAGE, library), true, allowGPU);
	}

	public static inline function sound(key:String, ?library:String)
	{
		return FunkinAssets.getSound(getPath('sounds/$key.$SOUND_EXT', SOUND, library, true));
	}

	public static inline function music(key:String, ?library:String)
	{
		return FunkinAssets.getSound(getPath('music/$key.$SOUND_EXT', SOUND, library, true));
	}

	public static inline function voices(song:String)
	{
		return FunkinAssets.getSound(getPath('songs/${formatToSongPath(song)}/Voices.$SOUND_EXT', SOUND, null, true));
	}

	public static inline function inst(song:String)
	{
		return FunkinAssets.getSound(getPath('songs/${formatToSongPath(song)}/Inst.$SOUND_EXT', SOUND, null, true));
	}

	public static inline function getSparrowAtlas(key:String, ?library:String, allowGPU:Bool = true):FlxAtlasFrames
	{
		var xml = getPath('images/$key.xml', TEXT, library, true);
		var img = image(key, library, allowGPU);
		return FlxAtlasFrames.fromSparrow(img, FunkinAssets.getContent(xml));
	}

	#if MODS_ALLOWED

	public static inline function mods(key:String = ''):String
	{
		return getAndroidStoragePath() + key;
	}

	static public function modFolders(key:String):String
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

	#end

	public static inline function formatToSongPath(path:String):String
	{
		return path.toLowerCase().replace(' ', '-');
	}
}