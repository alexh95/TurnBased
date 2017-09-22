package;

/**
 * ...
 * @author Alex H.
 */
class SharedData 
{

	public var setGameScene(default, null) : GameScenes -> Void;
	
	public function new(setGameScene : GameScenes -> Void) 
	{
		this.setGameScene = setGameScene;
	}
	
}