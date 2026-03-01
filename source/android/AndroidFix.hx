package android;

/**
 * Wrapper seguro para operações de FileSystem no Android.
 * Salva arquivos em /Android/data/com.fnf.hitsingle/files/
 */
class AndroidFix
{
	public static final PACKAGE = "com.fnf.hitsingle";

	/**
	 * Retorna o path base em /Android/data/com.fnf.hitsingle/files/
	 * Esse path é visível no gerenciador de arquivos e não precisa de permissão especial.
	 */
	public static function getDataPath():String
	{
		#if android
		// lime.system.System.applicationStorageDirectory já aponta para
		// /Android/data/com.fnf.hitsingle/files/ no Android
		return lime.system.System.applicationStorageDirectory;
		#elseif sys
		return Sys.getCwd() + '/';
		#else
		return '';
		#end
	}

	/**
	 * Verifica se um arquivo existe.
	 * Checa primeiro via OpenFL Assets (APK), depois no storage externo.
	 */
	public static function exists(path:String):Bool
	{
		#if android
		if (openfl.utils.Assets.exists(path))
			return true;
		#if sys
		try { return sys.FileSystem.exists(path); }
		catch (e:Dynamic) { return false; }
		#end
		return false;
		#elseif sys
		return sys.FileSystem.exists(path);
		#else
		return openfl.utils.Assets.exists(path);
		#end
	}

	/**
	 * Lê o conteúdo de um arquivo como String.
	 */
	public static function getContent(path:String):String
	{
		#if android
		try
		{
			if (openfl.utils.Assets.exists(path, TEXT))
				return openfl.utils.Assets.getText(path);
			#if sys
			if (sys.FileSystem.exists(path))
				return sys.io.File.getContent(path);
			#end
		}
		catch (e:Dynamic) { trace('[AndroidFix] Erro ao ler $path: $e'); }
		return '';
		#elseif sys
		try { return sys.io.File.getContent(path); }
		catch (e:Dynamic) { return ''; }
		#else
		return openfl.utils.Assets.getText(path);
		#end
	}

	/**
	 * Lista arquivos de um diretório.
	 * No Android usa Assets.list() para arquivos dentro do APK.
	 */
	public static function readDirectory(path:String):Array<String>
	{
		#if android
		try
		{
			var assetPath = path.startsWith('assets/') ? path : 'assets/' + path;
			assetPath = assetPath.endsWith('/') ? assetPath : assetPath + '/';

			var list = openfl.utils.Assets.list();
			var result:Array<String> = [];

			for (asset in list)
			{
				if (asset.startsWith(assetPath))
				{
					var relative = asset.substring(assetPath.length);
					if (relative.length > 0 && relative.indexOf('/') == -1)
						result.push(relative);
				}
			}

			return result;
		}
		catch (e:Dynamic)
		{
			trace('[AndroidFix] Erro ao listar $path: $e');
			return [];
		}
		#elseif sys
		try
		{
			if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
				return sys.FileSystem.readDirectory(path);
			return [];
		}
		catch (e:Dynamic) { return []; }
		#else
		return [];
		#end
	}

	/**
	 * Cria um diretório recursivamente.
	 */
	public static function createDirectory(path:String):Void
	{
		#if sys
		if (path == null || path.length == 0) return;
		try
		{
			if (!sys.FileSystem.exists(path))
			{
				var parts = path.split('/');
				var current = '';
				for (part in parts)
				{
					if (part.length == 0) continue;
					current += '/' + part;
					if (!sys.FileSystem.exists(current))
					{
						try { sys.FileSystem.createDirectory(current); }
						catch (e:Dynamic) { trace('[AndroidFix] Erro ao criar $current: $e'); }
					}
				}
			}
		}
		catch (e:Dynamic) { trace('[AndroidFix] Erro ao criar diretório $path: $e'); }
		#end
	}

	/**
	 * Salva conteúdo em um arquivo no Android/data.
	 */
	public static function saveContent(fileName:String, content:String):Void
	{
		#if sys
		var path = getDataPath() + fileName;
		try
		{
			var dir = path.split('/').slice(0, -1).join('/');
			if (dir.length > 0) createDirectory(dir);
			sys.io.File.saveContent(path, content);
		}
		catch (e:Dynamic) { trace('[AndroidFix] Erro ao salvar $path: $e'); }
		#end
	}

	/**
	 * Lê um arquivo do Android/data.
	 */
	public static function readSavedFile(fileName:String):Null<String>
	{
		#if sys
		var path = getDataPath() + fileName;
		try
		{
			if (sys.FileSystem.exists(path))
				return sys.io.File.getContent(path);
		}
		catch (e:Dynamic) { trace('[AndroidFix] Erro ao ler $path: $e'); }
		#end
		return null;
	}

	public static function isDirectory(path:String):Bool
	{
		#if sys
		try { return sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path); }
		catch (e:Dynamic) { return false; }
		#else
		return false;
		#end
	}
}