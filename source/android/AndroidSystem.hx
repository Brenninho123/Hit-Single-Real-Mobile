package android;

#if android
import sys.io.File;
import sys.FileSystem;
import lime.system.System;
import openfl.utils.Assets;
import openfl.events.Event;
#end

class AndroidStorage
{
	// Pasta externa do jogo no Android
	public static final GAME_FOLDER = "HitSingleReal";

	// Subpastas que serão copiadas do APK para o externo
	public static final ASSET_FOLDERS = [
		"images",
		"music",
		"sounds",
		"songs",
		"data",
		"fonts",
		"shaders",
		"videos"
	];

	public static function getExternalPath():String
	{
		#if android
		// Pega o storage externo real (/sdcard/HitSingleReal/)
		var extPath = lime.system.System.documentsDirectory;

		// Remove o "Documents" do final e sobe um nível pro sdcard
		var parts = extPath.split("/");
		while (parts.length > 0 && parts[parts.length - 1] != "storage" 
			&& parts[parts.length - 1] != "sdcard"
			&& parts[parts.length - 1] != "0")
		{
			parts.pop();
		}

		// Tenta /sdcard diretamente, mais compatível
		if (FileSystem.exists("/sdcard"))
			return '/sdcard/$GAME_FOLDER/';

		// Fallback para applicationStorageDirectory
		return System.applicationStorageDirectory + "/$GAME_FOLDER/";
		#else
		return 'storage/$GAME_FOLDER/';
		#end
	}

	public static function getBasePath():String
		return getExternalPath();

	// ===================== INIT + COPY =====================

	/**
	 * Chama isso no Main.hx antes de qualquer coisa.
	 * Cria as pastas e copia os assets do APK pro externo
	 * apenas na primeira vez (ou se a pasta não existir).
	 */
	public static function init():Void
	{
		#if sys
		var base = getBasePath();

		var isFirstRun = !FileSystem.exists(base) 
			|| !FileSystem.exists(base + ".initialized");

		createDirectory(base);

		if (isFirstRun)
		{
			trace("[AndroidStorage] Primeira execução detectada, copiando assets...");
			copyAssetsFromAPK(base);

			// Marca que já foi inicializado
			File.saveContent(base + ".initialized", "1");
			trace("[AndroidStorage] Assets copiados com sucesso!");
		}
		else
		{
			trace("[AndroidStorage] Assets já existem, pulando cópia.");
		}
		#end
	}

	/**
	 * Força a re-cópia de todos os assets (útil ao atualizar o jogo).
	 */
	public static function forceReinit():Void
	{
		#if sys
		var base = getBasePath();
		var marker = base + ".initialized";
		if (FileSystem.exists(marker))
			FileSystem.deleteFile(marker);
		init();
		#end
	}

	// ===================== CÓPIA DE ASSETS =====================

	static function copyAssetsFromAPK(destBase:String):Void
	{
		#if android
		for (folder in ASSET_FOLDERS)
		{
			var destFolder = destBase + folder + "/";
			createDirectory(destFolder);
			copyAssetFolder("assets/" + folder, destFolder);
		}
		#end
	}

	static function copyAssetFolder(assetPath:String, destPath:String):Void
	{
		#if android
		var list = Assets.list();

		for (asset in list)
		{
			// Só copia assets que começam com o caminho desejado
			if (!asset.startsWith(assetPath)) continue;

			// Monta o caminho de destino relativo
			var relative = asset.substring("assets/".length);
			var dest = destPath.split(GAME_FOLDER + "/")[0] 
				+ GAME_FOLDER + "/" + relative;

			// Cria as subpastas necessárias
			var destDir = dest.split("/");
			destDir.pop();
			createDirectory(destDir.join("/"));

			// Só copia se não existir já
			if (!FileSystem.exists(dest))
			{
				try
				{
					var bytes = Assets.getBytes(asset);
					if (bytes != null)
						File.saveBytes(dest, bytes);
				}
				catch (e:Dynamic)
				{
					trace('[AndroidStorage] Erro ao copiar $asset: $e');
				}
			}
		}
		#end
	}

	// ===================== FILE OPERATIONS =====================

	public static function saveFile(fileName:String, content:String):Void
	{
		#if sys
		var path = getBasePath() + fileName;
		createDirectory(path.split("/").slice(0, -1).join("/"));
		File.saveContent(path, content);
		#end
	}

	public static function saveBytes(fileName:String, bytes:haxe.io.Bytes):Void
	{
		#if sys
		var path = getBasePath() + fileName;
		createDirectory(path.split("/").slice(0, -1).join("/"));
		File.saveBytes(path, bytes);
		#end
	}

	public static function readFile(fileName:String):Null<String>
	{
		#if sys
		var path = getBasePath() + fileName;
		if (FileSystem.exists(path))
			return File.getContent(path);
		#end
		return null;
	}

	public static function readBytes(fileName:String):Null<haxe.io.Bytes>
	{
		#if sys
		var path = getBasePath() + fileName;
		if (FileSystem.exists(path))
			return File.getBytes(path);
		#end
		return null;
	}

	public static function exists(fileName:String):Bool
	{
		#if sys
		return FileSystem.exists(getBasePath() + fileName);
		#else
		return false;
		#end
	}

	public static function delete(fileName:String):Void
	{
		#if sys
		var path = getBasePath() + fileName;
		if (FileSystem.exists(path))
			FileSystem.deleteFile(path);
		#end
	}

	public static function listFiles(subFolder:String = ""):Array<String>
	{
		#if sys
		var path = getBasePath() + subFolder;
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			return FileSystem.readDirectory(path);
		#end
		return [];
	}

	// ===================== UTILS =====================

	public static function createDirectory(path:String):Void
	{
		#if sys
		if (path == null || path.length == 0) return;
		if (!FileSystem.exists(path))
		{
			// Cria recursivamente
			var parts = path.split("/");
			var current = "";
			for (part in parts)
			{
				if (part.length == 0) continue;
				current += "/" + part;
				if (!FileSystem.exists(current))
				{
					try { FileSystem.createDirectory(current); }
					catch (e:Dynamic) { trace('[AndroidStorage] Erro ao criar pasta $current: $e'); }
				}
			}
		}
		#end
	}

	public static function getFullPath(fileName:String):String
		return getBasePath() + fileName;
}