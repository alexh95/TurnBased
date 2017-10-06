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
	
	public var initiative : Int;
	public var orderScore : Int;

	public var position : TileMapPosition;
	public var movementSpeed : Int;
	public var attackRange : Int;
	public var canBeUsed : Bool;

	public function new(parent : Sprite) 
	{
		sprite = new Sprite(parent);
		underlay = new Sprite(sprite);
		
		initiative = 0;
		orderScore = 0;
		
		position = new TileMapPosition();
		movementSpeed = 0;
		attackRange = 0;
		canBeUsed = false;
	}
	
}