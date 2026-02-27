package android;

import flixel.FlxG;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import openfl.Lib;

class TouchManager
{
	public static var touches:Array<TouchData> = [];

	public static function init():Void
	{
		#if android
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		#end

		#if desktop
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		#end
	}

	static function onTouchBegin(e:TouchEvent):Void
	{
		touches.push(new TouchData(e.touchPointID, e.stageX, e.stageY));
	}

	static function onTouchMove(e:TouchEvent):Void
	{
		for (t in touches)
		{
			if (t.id == e.touchPointID)
			{
				t.x = e.stageX;
				t.y = e.stageY;
			}
		}
	}

	static function onTouchEnd(e:TouchEvent):Void
	{
		touches = touches.filter(t -> t.id != e.touchPointID);
	}

	static function onMouseDown(e:MouseEvent):Void
	{
		touches = [];
		touches.push(new TouchData(0, e.stageX, e.stageY));
	}

	static function onMouseUp(e:MouseEvent):Void
	{
		touches = [];
	}
}

class TouchData
{
	public var id:Int;
	public var x:Float;
	public var y:Float;

	public function new(id:Int, x:Float, y:Float)
	{
		this.id = id;
		this.x = x;
		this.y = y;
	}
}