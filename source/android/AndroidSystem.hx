package android;

#if android
import sys.io.File;
import sys.FileSystem;
import lime.system.System;
import openfl.utils.Assets;
#end

class AndroidStorage
{
    public static function getBasePath():String
    {
        #if android
        var base:String = System.applicationStorageDirectory;
        return base + "/HitSingleReal/";
        #else
        return "storage/";
        #end
    }

    public static function init():Void
    {
        var path = getBasePath();

        #if sys
        if (!FileSystem.exists(path))
        {
            FileSystem.createDirectory(path);
        }
        #end
    }

    public static function saveFile(fileName:String, content:String):Void
    {
        var path = getBasePath() + fileName;

        #if sys
        File.saveContent(path, content);
        #end
    }

    public static function readFile(fileName:String):String
    {
        var path = getBasePath() + fileName;

        #if sys
        if (FileSystem.exists(path))
            return File.getContent(path);
        #end

        return null;
    }

    public static function exists(fileName:String):Bool
    {
        var path = getBasePath() + fileName;

        #if sys
        return FileSystem.exists(path);
        #else
        return false;
        #end
    }

    public static function delete(fileName:String):Void
    {
        var path = getBasePath() + fileName;

        #if sys
        if (FileSystem.exists(path))
            FileSystem.deleteFile(path);
        #end
    }
}