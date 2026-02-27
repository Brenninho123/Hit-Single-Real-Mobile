package android;

import sys.FileSystem;
import sys.io.Process;
import sys.io.File;
import haxe.io.Path;

#if android
class OptPNG
{
    public static function optimizeFolder(path:String):Void
    {
        if (!FileSystem.exists(path)) {
            trace("OptPNG: Folder not found -> " + path);
            return;
        }

        for (file in FileSystem.readDirectory(path))
        {
            var fullPath = Path.join([path, file]);

            if (FileSystem.isDirectory(fullPath))
            {
                optimizeFolder(fullPath);
            }
            else if (StringTools.endsWith(file.toLowerCase(), ".png"))
            {
                optimizeImage(fullPath);
            }
        }
    }

    static function optimizeImage(filePath:String):Void
    {
        trace("OptPNG: Optimizing -> " + filePath);

        try {
            var process = new Process("optpng", ["-o7", "-quiet", filePath]);
            process.exitCode();
            process.close();
        }
        catch (e:Dynamic)
        {
            trace("OptPNG ERROR: optpng not found or failed.");
        }
    }
}
#end