package android;

/**
 * Wrapper seguro para operações de FileSystem no Android.
 * No Android, assets dentro do APK não são acessíveis via sys.FileSystem.
 * Use esse wrapper no lugar de sys.FileSystem e sys.io.File.
 */
class AndroidFix
{
	/**
	 * Verifica se um arquivo existe.
	 * No Android, checa primeiro via OpenFL Assets, depois via FileSystem se disponível.
	 */
	public static function exists(path:String):Bool
	{
		#if android
		// Checa via OpenFL Assets (dentro do APK)
		if (openfl.utils.Assets.exists(path))
			return true;

		// Checa via FileSystem (storage externo)
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
	 * No Android, tenta via OpenFL Assets primeiro.
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
		catch (e:Dynamic)
		{
			trace('[AndroidFix] Erro ao ler $path: $e');
		}
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
	 * No Android, usa Assets.list() para listar arquivos dentro do APK.
	 */
	public static function readDirectory(path:String):Array<String>
	{
		#if android
		try
		{
			// Normaliza o path removendo o prefixo "assets/" se existir
			var assetPath = path.startsWith('assets/') ? path : 'assets/' + path;
			assetPath = assetPath.endsWith('/') ? assetPath : assetPath + '/';

			var list = openfl.utils.Assets.list();
			var result:Array<String> = [];

			for (asset in list)
			{
				if (asset.startsWith(assetPath))
				{
					var relative = asset.substring(assetPath.length);
					// Só pega arquivos diretos (sem subpastas)
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
	 * Verifica se é um diretório.
	 */
	public static function isDirectory(path:String):Bool
	{
		#if sys
		try { return sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path); }
		catch (e:Dynamic) { return false; }
		#else
		return false;
		#end
	}

	/**
	 * Cria um diretório recursivamente (só funciona no storage externo do Android).
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
	 * Salva conteúdo em um arquivo (só no storage externo).
	 */
	public static function saveContent(path:String, content:String):Void
	{
		#if sys
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
	 * Retorna o diretório base para salvar arquivos no Android.
	 * Usa o storage externo (/sdcard) se disponível.
	 */
	public static function getSaveDirectory():String
	{
		#if android
		if (exists('/sdcard'))
			return '/sdcard/HitSingleReal/';
		return lime.system.System.applicationStorageDirectory + '/HitSingleReal/';
		#elseif sys
		return Sys.getCwd() + '/';
		#else
		return '';
		#end
	}
}
