package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class EventMode_Swordsmen extends SSF2CustomMatch
	{
		public var spawnMCs:Array = [];
		public var spawnFirst:Boolean = true;
		public var eventinfo:Array = [
			{
				"id":"swordsmen",
                "classAPI":EventMode_Swordsmen,
                "name":"Swordsmen",
                "description":"Prove that two swords are better than one!",
                "previewCharacter":"lloyd",
				"previewCostume":-1,
                "creator":"Mcleodgaming/Wex"
			}
		];
		public function EventMode_Swordsmen(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{			
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime());
			
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "lloyd",
				damageRatio: 1,
				lives: 2,
				human: true
			});
			game.playerSettings.push({ 
				character: "ichigo",
				lives: 2,
				human: false,
				level: 9
			});
			game.playerSettings.push({ 
				character: "link",
				lives: 2,
				human: false,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.stage = "castlesiege";
			game.levelData.hazards = true;
			game.levelData.musicOverride = "bgm_tosmedley"
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				
				// Set players to their designated spawn positions on first frame
				if (spawnFirst == true)
				{
					if (players != null && players.length >= 3)
					{
						// Player 0 gets player 2's position
						players[0].setX(380);
						players[0].setY(-41.65);
						SSF2API.getPlayer(1).faceLeft();
						
						// Player 1 stays in middle
						players[1].setX(52.4);
						players[1].setY(22.9);
						SSF2API.getPlayer(2).faceRight();
						
						// Player 2 gets player 0's position
						players[2].setX(98.25);
						players[2].setY(-69.95);
					}
					spawnFirst = false;
				}
				
				if (players != null && players.length > 0 && matchData != null)
				{
					if (players[0].getLives() <= 0)
					{
						matchData.success = false;
						SSF2API.endGame({
							success: false,
							immediate: false
						});
					} 
					else if (players.length > 2 && players[1].getLives() <= 0 && players[2].getLives() <= 0)
					{
						//Set rank based on elapsed time
						var rank = "F";
						if(SSF2API.getElapsedFrames()  <= 3000) // 0:50 or better
						{
							rank = "S";
						}
						else if(SSF2API.getElapsedFrames()  <= 3600) // 1:00 or better
						{
							rank = "A";
						}
						else if(SSF2API.getElapsedFrames()  <= 4200) // 1:10 or better
						{
							rank = "B";
						}
						else if(SSF2API.getElapsedFrames()  <= 4800) // 1:20 or better
						{
							rank = "C";
						}
						else if(SSF2API.getElapsedFrames()  <= 5400) // 1:30 or better
						{
							rank = "D";
						}
						else if(SSF2API.getElapsedFrames()  <= 6000) // 1:40 or better
						{
							rank = "E";
						}
						else // Over 1:40
						{
							rank = "F";
						}
						matchData.success = true;
						matchData.score = SSF2API.getElapsedFrames();
						matchData.scoreType = "time";
						matchData.rank = rank;
						matchData.fps = SSF2API.getAverageFPS();
						SSF2API.endGame({
							success: true,
							immediate: false,
							slowMo: false
						});
					}
				}
			}
		}
	}
}
