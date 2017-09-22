package;
import h2d.Sprite;

/**
 * ...
 * @author ...
 */
class Entity 
{
	
	public var sprite : Sprite;
	public var position : TileMapPosition;
	public var speed : Int;
	public var attackRange : Int;
	public var used : Bool;
	public var player : Player;

	public function new(parent : Sprite, position : TileMapPosition, speed : Int) 
	{
		sprite = new Sprite(parent);
		this.position = position;
		this.speed = speed;
		used = false;
	}
	
}