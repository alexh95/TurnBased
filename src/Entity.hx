package;
import h2d.Sprite;

/**
 * ...
 * @author ...
 */
class Entity 
{
	
	public var sprite : Sprite;
	public var underlay : Sprite;

	public var player : Player;

	public var position : TileMapPosition;
	public var speed : Int;
	public var attackRange : Int;
	public var used : Bool;

	public function new(parent : Sprite, position : TileMapPosition, speed : Int) 
	{
		sprite = new Sprite(parent);
		underlay = new Sprite(sprite);
		this.position = position;
		this.speed = speed;
		used = false;
	}
	
}