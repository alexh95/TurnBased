package;

/**
 * ...
 * @author ...
 */
class TileMapPosition 
{
	
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	
	public function new(x : Int = 0, y : Int = 0)
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function getMapKey() : Int
	{
		return (y << 16) | x;
	}
	
	public inline function add(n : Int) : TileMapPosition
	{
		var newX : Int = this.x + n;
		var newY : Int = this.y + n;
		return new TileMapPosition(newX, newY);
	}
	
	public inline function sub(n : Int) : TileMapPosition
	{
		var newX : Int = this.x - n;
		var newY : Int = this.y - n;
		return new TileMapPosition(newX, newY);
	}
	
	public inline function addPos(p : TileMapPosition) : TileMapPosition
	{
		var newX : Int = this.x + p.x;
		var newY : Int = this.y + p.y;
		return new TileMapPosition(newX, newY);
	}
	
	public inline function subPos(p : TileMapPosition) : TileMapPosition
	{
		var newX : Int = this.x - p.x;
		var newY : Int = this.y - p.y;
		return new TileMapPosition(newX, newY);
	}
	
	public inline function clamp(lowX : Int, highX : Int, lowY : Int, highY : Int) : TileMapPosition
	{
		var newX : Int = x;
		if (newX < lowX) newX = lowX;
		else if (newX > highX) newX = highX;
		var newY : Int = y;
		if (newY < lowY) newY = lowY;
		else if (newY > highY) newY = highY;
		return new TileMapPosition(newX, newY);
	}
	
	public inline function inside(lowX : Int, highX : Int, lowY : Int, highY : Int) : Bool
	{
		return lowX <= x && x <= highX && lowY <= y && y <= highY;
	}
	
	public inline function distance(p : TileMapPosition) : Float
	{
		var dx : Int = this.x - p.x;
		var dy : Int = this.y - p.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
}