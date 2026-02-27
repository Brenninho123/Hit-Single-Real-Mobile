package funkin;

import haxe.Json;

import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.display.BitmapData;
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
	#if ASSET_REDIRECT
	public static inline final trail = #if macos '../../../../../../../' #else '../../../../' #end;
	#end
	
	public static inline final CORE_DIRECTORY = #if ASSET_REDIRECT trail + 'assets/game' #else 'assets' #end;
	public static inline final MODS_DIRECTORY = #if ASSET_REDIRECT trail + 'content' #else 'content' #end;
	
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
			final modPath:String = modFolders(parentFolder == null ? file : parentFolder + '/' + file);
			if (FileSystem.exists(modPath)) return modPath;
		}
		#end
		#end
		
		if (parentFolder != null) return getLibraryPath(file, parentFolder);
		
		if (currentLevel != null)
		{
			var levelPath:String = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type)) return levelPath;
		}
		
		return getPrimaryPath(file);
	}
	
	public static function getLibraryPath(file:String, parentFolder:Null<String>):String
	{
		return parentFolder == null ? getPrimaryPath(file) : getLibraryPathForce(file, parentFolder);
	}
	
	static inline function getLibraryPathForce(file:String, library:String):String
	{
		return '$CORE_DIRECTORY/$library/$file';
	}
	
	public static inline function getPrimaryPath(file:String = ''):String
	{
		return '$CORE_DIRECTORY/$file';
	}
	
	public static inline function txt(key:String, ?library:String):String
	{
		return getPath('data/$key.txt', TEXT, library, true);
	}
	
	public static inline function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library, true);
	}
	
	public static inline function json(key:String, ?library:String):String
	{
		return getPath('songs/$key.json', TEXT, library, true);
	}
	
	public static inline function noteskin(key:String, ?library:String):String
	{
		return getPath('noteskins/$key.json', TEXT, library, true);
	}
	
	public static inline function shaderFrag(key:String):String
	{
		return getPath('shaders/$key.frag', TEXT, null, true);
	}
	
	public static inline function shaderVert(key:String):String
	{
		return getPath('shaders/$key.vert', TEXT, null, true);
	}
	
	public static inline function lua(key:String, ?library:String):String
	{
		return getPath('$key.lua', TEXT, library);
	}
	
	static public function video(key:String):String
	{
		return '$CORE_DIRECTORY/videos/$key.$VIDEO_EXT';
	}
	
	static public function textureAtlas(key:String, ?library:String):String
	{
		return getPath('images/$key', AssetType.BINARY, library, true);
	}
	
	static public function sound(key:String, ?library:String):Null<Sound>
	{
		final path = getPath('sounds/$key.$SOUND_EXT', SOUND, library, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}
	
	public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String):Null<Sound>
	{
		return sound(key + FlxG.random.int(min, max), library);
	}
	
	public static inline function music(key:String, ?library:String):Null<Sound>
	{
		final path = getPath('music/$key.$SOUND_EXT', SOUND, library, true);
		return Assets.exists(path) ? Assets.getSound(path) : null;
	}
	
	public static inline function voices(song:String):Null<Sound>
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		songKey = getPath('songs/$songKey.$SOUND_EXT', SOUND, null, true);
		return Assets.exists(songKey) ? Assets.getSound(songKey) : null;
	}
	
	public static inline function inst(song:String):Null<Sound>
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		songKey = getPath('songs/$songKey.$SOUND_EXT', SOUND, null, true);
		return Assets.exists(songKey) ? Assets.getSound(songKey) : null;
	}
	
	public static inline function image(key:String, ?library:String):Null<FlxGraphic>
	{
		final path = getPath('images/$key.png', IMAGE, library, true);
		return Assets.exists(path) ? FlxGraphic.fromBitmapData(Assets.getBitmapData(path)) : null;
	}
	
	static public function getTextFromFile(key:String, ignoreMods:Bool = false):String
	{
		#if MODS_ALLOWED
		#if sys
		if (!ignoreMods)
		{
			var modPath = modFolders(key);
			if (FileSystem.exists(modPath))
				return File.getContent(modPath);
		}
		#end
		#end
		
		var path = getPath(key, TEXT);
		return Assets.exists(path) ? Assets.getText(path) : null;
	}
	
	public static inline function formatToSongPath(path:String):String
	{
		return path.toLowerCase().replace(' ', '-');
	}
	
	#if MODS_ALLOWED
	public static inline function mods(key:String = ''):String
	{
		return '$MODS_DIRECTORY/' + key;
	}
	
	static public function modFolders(key:String):String
	{
		#if sys
		for (mod in Mods.globalMods)
		{
			var fileToCheck:String = mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck)) return fileToCheck;
		}
		#end
		
		return '$MODS_DIRECTORY/' + key;
	}
	#end
}