package;

#if js
import js.Browser;
#end

import h3d.Engine;
import hxd.App;
import hxd.Res;

/**
 * ...
 * @author Alex H.
 */
class Main extends App 
{
	
	private var sharedData : SharedData;
	private var currentScene : GameScene;
	
	public static function main() : Void
	{
		Res.initEmbed();
		new Main();
	}
	
	private function setGameScene(gameScene : GameScenes) : Void
	{
		setScene2D(currentScene = switch gameScene
		{
			case DEBUG: new DebugScene(sharedData);
			default: null;
		});
	}
	
	override function onResize()
	{
		#if js
		var width : Int = Browser.window.innerWidth;
		var height : Int = Browser.window.innerHeight;
		var engine : Engine = Engine.getCurrent();
		if (width != engine.width || height != engine.height)
		{
			engine.resize(width, height);
		}
		if (width != currentScene.width || height != currentScene.height)
		{
			currentScene.resize(width, height);
		}
		#end
	}
	
	override function init() : Void
	{
		sharedData = new SharedData(setGameScene);
		setGameScene(GameScenes.DEBUG);
	}
	
	override function update(dt : Float) : Void
	{
		onResize();
		currentScene.update(dt);
	}
	
}