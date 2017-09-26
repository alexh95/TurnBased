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
		debugCrosshair.visible = false;
		
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
	private var tileAttackable : Sprite;
	
	private var entities : Map<Int, Entity>;
	private var selectedEntity : Entity;
	private var isEntitySelected : Bool;
	
	private var reachableTiles : Array<TileMapPosition>;
	private var attackableTiles : Array<TileMapPosition>;
	
	private var startScrollMouseX : Float;
	private var startScrollMouseY : Float;
	private var startScrollPositionX : Float;
	private var startScrollPositionY : Float;
	private var scrolling : Bool;
	
	private var zoomLevel : Float;
	
	private var players : Array<Player>;
	private var currentPlayer : Player;
	private var currentPlayerIndex : Int;
	
	private var cursor : Sprite;
	private var currentCursorBitmap : Bitmap;
	private var defaultCursorBitmap : Bitmap;
	private var selectCursorBitmap : Bitmap;
	private var moveCursorBitmap : Bitmap;
	private var attackCursorBitmap : Bitmap;
	
	private function deselectEntity() : Void
	{
		selectedEntity = null;
		isEntitySelected = false;
		tileSelected.visible = false;
		tileReachable.removeChildren();
		tileAttackable.removeChildren();
	}
	
	private function nextPlayer() : Void
	{
		deselectEntity();

		if (++currentPlayerIndex >= players.length)
		{
			currentPlayerIndex = 0;
		}
		currentPlayer = players[currentPlayerIndex];		
	}
	
	private function setCursorBitmap(cursorBitmap : Bitmap) : Void
	{
		currentCursorBitmap.visible = false;
		currentCursorBitmap = cursorBitmap;
		currentCursorBitmap.visible = true;
	}
	
	private function handleMouseEvent(event : Event)
	{
		if (event.kind == EPush)
		{
			if (event.button == 0)
			{
				var tile : TileMapPosition = new TileMapPosition(
					Math.floor((event.relX - tileMap.x) / tileWidth * (1 / zoomLevel)), 
					Math.floor((event.relY - tileMap.y) / tileHeight * (1 / zoomLevel)));
				if (tile.inside(0, tileMapCols, 0, tileMapRows))
				{
					var entity = entities.get(new TileMapPosition(tile.x, tile.y).getMapKey());
					if (entity != null)
					{
						if (entity.player == currentPlayer)
						{
							isEntitySelected = true;
							selectedEntity = entity;
							tileSelected.visible = true;
							tileSelected.setPos(tile.x * tileWidth, tile.y * tileHeight);
							
							reachableTiles = [];
							
							var topLeftMoveBound : TileMapPosition = selectedEntity.position.sub(selectedEntity.speed);
							topLeftMoveBound = topLeftMoveBound.clamp(0, tileMapCols - 1, 0, tileMapCols - 1);
							var bottomRightMoveBound : TileMapPosition = selectedEntity.position.add(selectedEntity.speed + 1);
							bottomRightMoveBound = bottomRightMoveBound.clamp(0, tileMapCols - 1, 0, tileMapRows - 1);
							
							for (x in topLeftMoveBound.x...bottomRightMoveBound.x + 1)
							{
								for (y in topLeftMoveBound.y...bottomRightMoveBound.y + 1)
								{
									if (x != selectedEntity.position.x || y != selectedEntity.position.y)
									{
										var distance : Float = new TileMapPosition(x, y).distance(selectedEntity.position);
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
								var reachableTileBitmap : Bitmap = new Bitmap(reachableTile, tileReachable);
								reachableTileBitmap.setPos(position.x * tileWidth, position.y * tileHeight);
							}
							
							attackableTiles = [];
							
							var topLeftAttackBound : TileMapPosition = selectedEntity.position.sub(selectedEntity.attackRange);
							topLeftAttackBound = topLeftAttackBound.clamp(0, tileMapCols - 1, 0, tileMapCols - 1);
							var bottomRightAttackBound : TileMapPosition = selectedEntity.position.add(selectedEntity.attackRange + 1);
							bottomRightAttackBound = bottomRightAttackBound.clamp(0, tileMapCols - 1, 0, tileMapRows - 1);
							
							for (x in topLeftAttackBound.x...bottomRightAttackBound.x + 1)
							{
								for (y in topLeftAttackBound.y...bottomRightAttackBound.y + 1)
								{
									if (x != selectedEntity.position.x || y != selectedEntity.position.y)
									{
										var distance : Float = new TileMapPosition(x, y).distance(selectedEntity.position);
										if (distance <= selectedEntity.attackRange)
										{
											attackableTiles.push(new TileMapPosition(x, y));
										}
									}
								}
							}
							
							tileAttackable.removeChildren();
							var attackableTile : Tile = Res.TileAttackable_png.toTile();
							for (position in attackableTiles)
							{
								var attackableTileBitmap : Bitmap = new Bitmap(attackableTile, tileAttackable);
								attackableTileBitmap.setPos(position.x * tileWidth, position.y * tileHeight);
							}
						}
						else
						{
							// NOTE(alex): pressed on enemy player
						}
					}
					else
					{
						if (isEntitySelected)
						{
							var dx : Int = tile.x - selectedEntity.position.x;
							var dy : Int = tile.y - selectedEntity.position.y;
							var distance : Float = Math.sqrt(dx * dx + dy * dy);
							if (distance <= selectedEntity.speed)
							{
								entities.remove(selectedEntity.position.getMapKey());
								selectedEntity.position = new TileMapPosition(tile.x, tile.y);
								entities.set(selectedEntity.position.getMapKey(), selectedEntity);
								selectedEntity.sprite.setPos(selectedEntity.position.x * tileWidth, selectedEntity.position.y * tileHeight);
							}
						}
						
						deselectEntity();
					}
				}
				else
				{
					deselectEntity();
				}
			}
			else if (event.button == 1)
			{
				scrolling = true;
				startScrollMouseX = mouseX;
				startScrollMouseY = mouseY;
				startScrollPositionX = tileMap.x;
				startScrollPositionY = tileMap.y;
			}
			else if (event.button == 2)
			{
				
			}
		}
		else if (event.kind == ERelease)
		{
			if (event.button == 0)
			{
				
			}
			else if (event.button == 1)
			{
				scrolling = false;
			}
			else if (event.button == 2)
			{
				
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
			var oldZoomLevel = zoomLevel;
			var dz : Float = 0.0125 * event.wheelDelta;
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
		tileAttackable = new Sprite(tileMap);
		
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
		players.push(player1);

		player1.name = "Player 1";
		player1.entityUnderlay = Res.TileUnderlayRed_png.toTile();
		player1.addEntity(lightTank1);
		player1.addEntity(mediumTank1);
		player1.addEntity(heavyArtillery1);
		
		var player2 : Player = new Player();
		players.push(player2);

		player2.name = "Player 2";
		player2.entityUnderlay = Res.TileUnderlayBlue_png.toTile();
		player2.addEntity(lightTank2);
		player2.addEntity(mediumTank2);
		player2.addEntity(heavyArtillery2);
		
		currentPlayer = player1;
		currentPlayerIndex = 0;
		
		cursor = new Sprite(content);
		defaultCursorBitmap = new Bitmap(Res.DefaultCursor_png.toTile(), cursor);
		currentCursorBitmap = defaultCursorBitmap;
		
		selectCursorBitmap = new Bitmap(Res.SelectCursor_png.toTile(), cursor);
		selectCursorBitmap.tile.dx = -cast(selectCursorBitmap.tile.width / 2., Int);
		selectCursorBitmap.tile.dy = -cast(selectCursorBitmap.tile.height / 2., Int);
		selectCursorBitmap.visible = false;
		
		moveCursorBitmap = new Bitmap(Res.MoveCursor_png.toTile(), cursor);
		moveCursorBitmap.tile.dx = -cast(moveCursorBitmap.tile.width / 2., Int);
		moveCursorBitmap.tile.dy = -cast(moveCursorBitmap.tile.height / 2., Int);
		moveCursorBitmap.visible = false;
		
		attackCursorBitmap = new Bitmap(Res.AttackCursor_png.toTile(), cursor);
		attackCursorBitmap.tile.dx = -cast(attackCursorBitmap.tile.width / 2., Int);
		attackCursorBitmap.tile.dy = -cast(attackCursorBitmap.tile.height / 2., Int);
		attackCursorBitmap.visible = false;
		
		addEventListener(handleMouseEvent);
	}
	
	override function update(dt : Float) : Void
	{
		updateDebugLayer(dt);
		
		cursor.x = mouseX;
		cursor.y = mouseY;
		
		var gridMouseTile : TileMapPosition = new TileMapPosition(
			Math.floor((mouseX - tileMap.x) / tileWidth * (1 / zoomLevel)), 
			Math.floor((mouseY - tileMap.y) / tileHeight * (1 / zoomLevel)));
		if (gridMouseTile.inside(0, tileMapCols - 1, 0, tileMapRows - 1))
		{
			tileHover.visible = true;
			tileHover.setPos(gridMouseTile.x * tileWidth, gridMouseTile.y * tileHeight);
			
			var hoveredEntity : Entity = entities.get(gridMouseTile.getMapKey());
			if (hoveredEntity != null)
			{
				if (isEntitySelected)
				{
					if (hoveredEntity.player == currentPlayer)
					{
						setCursorBitmap(selectCursorBitmap);
					}
					else
					{
						setCursorBitmap(attackCursorBitmap);
					}
				}
				else
				{
					if (hoveredEntity.player == currentPlayer)
					{
						setCursorBitmap(selectCursorBitmap);
					}
					else
					{
						setCursorBitmap(defaultCursorBitmap);
					}
				}
			}
			else 
			{
				if (isEntitySelected)
				{
					var distance : Float = gridMouseTile.distance(selectedEntity.position);
					if (distance <= selectedEntity.speed)
					{
						setCursorBitmap(moveCursorBitmap);
					}
					else
					{
						setCursorBitmap(defaultCursorBitmap);
					}
				}
				else
				{
					setCursorBitmap(defaultCursorBitmap);
				}
			}
		}
		else
		{
			tileHover.visible = false;
		}
		
		
	}
	
}
