package;

import h2d.Scene;

/**
 * ...
 * @author Alex H.
 */
class GameScene extends Scene 
{
	
	private var sharedData : SharedData;
	
	public function new(sharedData : SharedData) 
	{
		super();
		this.sharedData = sharedData;
		init();
	}
	
	public function resize(width : Int, height : Int) : Void
	{
		this.width = width;
		this.height = height;
		afterResize(width, height);
	}
	
	public function afterResize(width : Int, height : Int) : Void {}
	
	public function init() : Void {}
	
	public function update(dt : Float) : Void {}
	
}