package;
import h2d.Sprite;
import h2d.Bitmap;
import h2d.Tile;

/**
 * ...
 * @author ...
 */
class Player
{
	
	public var name : String;
	public var entities : Array<Entity>;
	public var entityUnderlay : Tile;
	
	public function new()
	{
		entities = [];
	}
	
	public function addEntity(entity : Entity)
	{
		entity.player = this;
		entity.underlay.addChild(new Bitmap(entityUnderlay));
		entities.push(entity);
	}
	
}