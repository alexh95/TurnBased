package;
import h2d.Bitmap;
import h2d.Sprite;
import h2d.Tile;
import h2d.Text;
import hxd.Res;
import hxd.Event;
import hxd.Key;

/**
 * ...
 * @author Alex H.
 */
class DebugScene extends GameScene 
{
	
	public function new(sharedData:SharedData) 
	{
		super(sharedData);
		
	}
	
	private var debugLayer : Sprite;
	private var debugCrosshair : Bitmap;
	
	private var debugScreenSize : Text;
	
	private var debugFPS : Text;
	private var lastFPS : Array<Float>;
	private var lastFPSCounter : Int;
	
	private var debugPlayerTurn : Text;
	
	
	private function initDebugLayer() : Void
	{
		if (debugLayer == null)
		{
			debugLayer = new Sprite();
			addChildAt(debugLayer, 10);
		}
		else
		{
			debugLayer.removeChildren();
		}
		
		var debugTL : Bitmap = new Bitmap(Tile.fromColor(0x00FF00, 5, 5), debugLayer);
		debugTL.setPos(0, 0);
		var debugTR : Bitmap = new Bitmap(Tile.fromColor(0x00FF00, 5, 5), debugLayer);
		debugTR.setPos(width - debugTR.tile.width, 0);
		var debugBL : Bitmap = new Bitmap(Tile.fromColor(0x00FF00, 5, 5), debugLayer);
		debugBL.setPos(0, height - debugBL.tile.height);
		var debugBR : Bitmap = new Bitmap(Tile.fromColor(0x00FF00, 5, 5), debugLayer);
		debugBR.setPos(width - debugBR.tile.width, height - debugBR.tile.height);
		
		debugCrosshair = new Bitmap(Res.crosshair.toTile(), debugLayer);
		debugCrosshair.tile.dx = -cast(debugCrosshair.tile.width / 2, Int);
		debugCrosshair.tile.dy = -cast(debugCrosshair.tile.height / 2, Int);
		
		debugScreenSize = new Text(Res.cour.build(32), debugLayer);
		debugScreenSize.textColor = 0xFFFFFF;
		debugScreenSize.text = "W: " + width + "\nH: " + height;
		debugScreenSize.setPos(20, 20);
		
		debugFPS = new Text(Res.cour.build(32), debugLayer);
		debugFPS.textColor = 0xFFFFFF;
		debugFPS.setPos(width - debugScreenSize.textWidth, 20);
		lastFPS = [];
		lastFPSCounter = 0;
		
		debugPlayerTurn = new Text(Res.cour.build(32), debugLayer);
		debugPlayerTurn.textColor = 0xFFFFFF;
		debugPlayerTurn.text = "Current Player: ";
		debugPlayerTurn.setPos(20, debugScreenSize.textHeight + 20);
	}
	
	private function updateDebugLayer(dt : Float)
	{
		debugCrosshair.setPos(mouseX, mouseY);
		
		lastFPS[lastFPSCounter] = dt * 60;
		
		var fps : Float = 0;
		var count : Int = 0;
		for (f in lastFPS)
		{
			fps += f;
			++count;
		}
		fps /= count;
		
		if (++lastFPSCounter >= 32) 
		{
			lastFPSCounter = 0;
			debugFPS.text = Std.string(fps);
		}
		
		debugPlayerTurn.text = "Current Player: " + currentPlayer.name;
	}
	
	private var content : Sprite;
	private var tiles : Array<Array<Sprite>>;
	private var tileMap : Sprite;
	private var tileMapRows : Int;
	private var tileMapCols : Int;
	private var tileWidth : Float;
	private var tileHeight : Float;
	private var tileHover : Sprite;
	private var tileSelected : Sprite;
	private var tileReachable : Sprite;
	
	private var entities : Map<Int, Entity>;
	private var selectedEntity : Entity;
	private var isEntitySelected : Bool;
	
	private var reachableTiles : Array<TileMapPosition>;
	
	private var startScrollMouseX : Float;
	private var startScrollMouseY : Float;
	private var startScrollPositionX : Float;
	private var startScrollPositionY : Float;
	private var scrolling : Bool;
	
	private var zoomLevel : Float;
	
	private var players : Array<Player>;
	private var currentPlayer : Player;
	private var currentPlayerIndex : Int;
	
	private function nextPlayer()
	{
		if (++currentPlayerIndex >= players.length)
		{
			currentPlayerIndex = 0;
		}
		currentPlayer = players[currentPlayerIndex];
	}
	
	private function handleMouseEvent(event : Event)
	{
		if (event.kind == EPush)
		{
			if (event.button == 0)
			{
				var tileX : Int = Math.floor((event.relX - tileMap.x) / tileWidth * (1 / zoomLevel));
				var tileY : Int = Math.floor((event.relY - tileMap.y) / tileHeight * (1 / zoomLevel));
				if (tileX >= 0 && tileX < tileMapCols && tileY >= 0 && tileY < tileMapRows)
				{
					var entity = entities.get(new TileMapPosition(tileX, tileY).getMapKey());
					if (entity != null)
					{
						if (entity.player == currentPlayer)
						{
							isEntitySelected = true;
							selectedEntity = entity;
							tileSelected.visible = true;
							tileSelected.setPos(tileX * tileWidth, tileY * tileHeight);
							
							reachableTiles = [];
							
							var topLeftX : Int = selectedEntity.position.x - selectedEntity.speed;
							if (topLeftX < 0) topLeftX = 0;
							else if (topLeftX >= tileMapCols) topLeftX = tileMapCols - 1;
							
							var topLeftY : Int = selectedEntity.position.y - selectedEntity.speed;
							if (topLeftY < 0) topLeftY = 0;
							else if (topLeftY >= tileMapRows) topLeftY = tileMapRows - 1;
							
							var bottomRightX : Int = selectedEntity.position.x + selectedEntity.speed + 1;
							if (bottomRightX < 0) bottomRightX = 0;
							else if (bottomRightX >= tileMapCols) bottomRightX = tileMapCols;
							
							var bottomRightY : Int = selectedEntity.position.y + selectedEntity.speed + 1;
							if (bottomRightY < 0) bottomRightY = 0;
							else if (bottomRightY >= tileMapRows) bottomRightY = tileMapRows;
							
							for (x in topLeftX...bottomRightX)
							{
								for (y in topLeftY...bottomRightY)
								{
									if (x != selectedEntity.position.x || y != selectedEntity.position.y)
									{
										var dx : Int = x - selectedEntity.position.x;
										var dy : Int = y - selectedEntity.position.y;
										var distance : Float = Math.sqrt(dx * dx + dy * dy);
										trace(distance);
										if (distance <= selectedEntity.speed)
										{
											reachableTiles.push(new TileMapPosition(x, y));
										}
									}
								}
							}
							tileReachable.removeChildren();
							var reachableTile : Tile = Res.TileReachable_png.toTile();
							for (position in reachableTiles)
							{
								var reachableTileSprite : Sprite = new Sprite(tileReachable);
								var reachableTileBitmap : Bitmap = new Bitmap(reachableTile, reachableTileSprite);
								reachableTileSprite.setPos(position.x * tileWidth, position.y * tileHeight);
							}
						}
					}
					else
					{
						if (isEntitySelected)
						{
							var dx : Int = tileX - selectedEntity.position.x;
							var dy : Int = tileY - selectedEntity.position.y;
							var distance : Float = Math.sqrt(dx * dx + dy * dy);
							if (distance <= selectedEntity.speed)
							{
								entities.remove(selectedEntity.position.getMapKey());
								selectedEntity.position.x = tileX;
								selectedEntity.position.y = tileY;
								entities.set(selectedEntity.position.getMapKey(), selectedEntity);
								selectedEntity.sprite.setPos(selectedEntity.position.x * tileWidth, selectedEntity.position.y * tileHeight);
							}
						}
						
						selectedEntity = null;
						isEntitySelected = false;
						tileSelected.visible = false;
						tileReachable.removeChildren();
					}
				}
				else
				{
					selectedEntity = null;
					tileSelected.visible = false;
					tileReachable.removeChildren();
				}
			}
			else if (event.button == 1)
			{
				
			}
			else if (event.button == 2)
			{
				scrolling = true;
				startScrollMouseX = mouseX;
				startScrollMouseY = mouseY;
				startScrollPositionX = tileMap.x;
				startScrollPositionY = tileMap.y;
			}
		}
		else if (event.kind == ERelease)
		{
			if (event.button == 0)
			{
				
			}
			else if (event.button == 1)
			{
				
			}
			else if (event.button == 2)
			{
				trace("scroll end");
				scrolling = false;
			}
		}
		else if (event.kind == EMove)
		{
			if (scrolling)
			{
				var dx : Float = startScrollPositionX + mouseX - startScrollMouseX;
				var dy : Float = startScrollPositionY + mouseY - startScrollMouseY;
				tileMap.x = dx;
				tileMap.y = dy;
			}	
		}
		else if (event.kind == EWheel)
		{
			trace(event.wheelDelta);
			var oldZoomLevel = zoomLevel;
			var dz : Float = 0.05 * (event.wheelDelta / 4);
			zoomLevel -= dz;
			if (zoomLevel < 0.25) zoomLevel = 0.25;
			else if (zoomLevel > 4.0) zoomLevel = 4.0;
			if (zoomLevel != tileMap.scaleX)
			{
				var clippedMouseX : Float = mouseX;
				if (clippedMouseX < tileMap.x) clippedMouseX = tileMap.x;
				else if (clippedMouseX > tileMap.x + tileMapCols * tileWidth * oldZoomLevel)
					clippedMouseX = tileMap.x + tileMapCols * tileWidth * oldZoomLevel;
					
				var clippedMouseY : Float = mouseY;
				if (clippedMouseY < tileMap.y) clippedMouseY = tileMap.y;
				else if (clippedMouseY > tileMap.y + tileMapRows * tileHeight * oldZoomLevel)
					clippedMouseY = tileMap.y + tileMapRows * tileHeight * oldZoomLevel;
				
				var dmX : Float = clippedMouseX - tileMap.x;
				var dmY : Float = clippedMouseY - tileMap.y;
				tileMap.x += dmX;
				tileMap.y += dmY;
				tileMap.scaleX = zoomLevel;
				tileMap.scaleY = zoomLevel;
				tileMap.x -= dmX * (zoomLevel / oldZoomLevel);
				tileMap.y -= dmY * (zoomLevel / oldZoomLevel);
			}
		}
		else if (event.kind == EKeyDown)
		{
			if (event.keyCode == Key.E)
			{
				nextPlayer();
			}
		}
		else if (event.kind == EKeyUp)
		{
			
		}
	}
	
	override function afterResize(width : Int, height : Int) : Void
	{
		initDebugLayer();
	}
	
	override function init() : Void
	{
		initDebugLayer();
		
		content = new Sprite(this);
		
		tileMapRows = 50;
		tileMapCols = 50;
		tileMap = new Sprite(content);
		tileMap.setPos(20, 20);
		tiles = [];
		for (i in 0...tileMapRows) 
		{
			tiles[i] = [];
			for (j in 0...tileMapCols)
			{
				tiles[i][j] = new Sprite(tileMap);
				var tileBitmap : Bitmap = new Bitmap(Res.TileGrass_png.toTile());
				tiles[i][j].addChild(tileBitmap);
				var x : Float = tileBitmap.tile.width * j;
				var y : Float = tileBitmap.tile.height * i;
				tiles[i][j].setPos(x, y);
			}
		}
		
		isEntitySelected = false;
		scrolling = false;
		zoomLevel = tileMap.scaleX;
		
		tileHover = new Sprite(tileMap);
		var gridTileHoverBitmap = new Bitmap(Res.TileHover_png.toTile());
		tileHover.addChild(gridTileHoverBitmap);
		tileHover.visible = false;
		tileWidth = gridTileHoverBitmap.tile.width;
		tileHeight = gridTileHoverBitmap.tile.height;
		
		tileSelected = new Sprite(tileMap);
		var gridTileSelectedBitmap = new Bitmap(Res.TileSelected_png.toTile());
		tileSelected.addChild(gridTileSelectedBitmap);
		tileSelected.visible = false;
		
		tileReachable = new Sprite(tileMap);
		
		entities = new Map();
		
		var lightTank1 : Entity = new Entity(tileMap, new TileMapPosition(1, 3), 7);
		lightTank1.attackRange = 20;
		var lightTankBitmap : Bitmap = new Bitmap(Res.LightTank_png.toTile(), lightTank1.sprite);
		entities.set(lightTank1.position.getMapKey(), lightTank1);
		lightTank1.sprite.setPos(lightTank1.position.x * tileWidth, lightTank1.position.y * tileHeight);

		var mediumTank1 : Entity = new Entity(tileMap, new TileMapPosition(3, 1), 4);
		mediumTank1.attackRange = 24;
		var mediumTankBitmap : Bitmap = new Bitmap(Res.MediumTank_png.toTile(), mediumTank1.sprite);
		entities.set(mediumTank1.position.getMapKey(), mediumTank1);
		mediumTank1.sprite.setPos(mediumTank1.position.x * tileWidth, mediumTank1.position.y * tileHeight);

		var heavyArtillery1 : Entity = new Entity(tileMap, new TileMapPosition(1, 1), 1);
		heavyArtillery1.attackRange = 38;
		var heavyArtilleryBitmap : Bitmap = new Bitmap(Res.HeavyArtillery_png.toTile(), heavyArtillery1.sprite);
		entities.set(heavyArtillery1.position.getMapKey(), heavyArtillery1);
		heavyArtillery1.sprite.setPos(heavyArtillery1.position.x * tileWidth, heavyArtillery1.position.y * tileHeight);
		
		var lightTank2 : Entity = new Entity(tileMap, new TileMapPosition(9, 11), 7);
		lightTank2.attackRange = 20;
		var lightTankBitmap : Bitmap = new Bitmap(Res.LightTank_png.toTile(), lightTank2.sprite);
		entities.set(lightTank2.position.getMapKey(), lightTank2);
		lightTank2.sprite.setPos(lightTank2.position.x * tileWidth, lightTank2.position.y * tileHeight);

		var mediumTank2 : Entity = new Entity(tileMap, new TileMapPosition(11, 9), 4);
		mediumTank2.attackRange = 24;
		var mediumTankBitmap : Bitmap = new Bitmap(Res.MediumTank_png.toTile(), mediumTank2.sprite);
		entities.set(mediumTank2.position.getMapKey(), mediumTank2);
		mediumTank2.sprite.setPos(mediumTank2.position.x * tileWidth, mediumTank2.position.y * tileHeight);

		var heavyArtillery2 : Entity = new Entity(tileMap, new TileMapPosition(11, 11), 1);
		heavyArtillery2.attackRange = 38;
		var heavyArtilleryBitmap : Bitmap = new Bitmap(Res.HeavyArtillery_png.toTile(), heavyArtillery2.sprite);
		entities.set(heavyArtillery2.position.getMapKey(), heavyArtillery2);
		heavyArtillery2.sprite.setPos(heavyArtillery2.position.x * tileWidth, heavyArtillery2.position.y * tileHeight);
		
		players = [];
		var player1 : Player = new Player();
		player1.name = "Player 1";
		player1.entities.push(lightTank1);
		lightTank1.player = player1;
		player1.entities.push(mediumTank1);
		mediumTank1.player = player1;
		player1.entities.push(heavyArtillery1);
		heavyArtillery1.player = player1;
		players.push(player1);
		var player2 : Player = new Player();
		player2.name = "Player 2";
		player2.entities.push(lightTank2);
		lightTank2.player = player2;
		player2.entities.push(mediumTank2);
		mediumTank2.player = player2;
		player2.entities.push(heavyArtillery2);
		heavyArtillery2.player = player2;
		players.push(player2);
		
		currentPlayer = player1;
		currentPlayerIndex = 0;
		
		addEventListener(handleMouseEvent);
	}
	
	override function update(dt : Float) : Void
	{
		updateDebugLayer(dt);
		
		var gridMouseTileX : Int = Math.floor((mouseX - tileMap.x) / tileWidth * (1 / zoomLevel));
		var gridMouseTileY : Int = Math.floor((mouseY - tileMap.y) / tileHeight * (1 / zoomLevel));
		if (gridMouseTileX >= 0 && gridMouseTileX < tileMapCols && gridMouseTileY >= 0 && gridMouseTileY < tileMapRows)
		{
			tileHover.visible = true;
			tileHover.setPos(gridMouseTileX * tileWidth, gridMouseTileY * tileHeight);
		}
		else
		{
			tileHover.visible = false;
		}
	}
	
}
