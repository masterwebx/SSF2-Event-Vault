package
{
	import flash.display.MovieClip;
	
	public class EventMode_TroubleKing extends SSF2CustomMatch
	{
		public var spawnFirst:Boolean = true;
		public var eventinfo:Array = [
			{
				"id":"troubleKing",
                "classAPI":EventMode_TroubleKing,
                "name":"Trouble King",
                "description":"Fight Bowser in a classic Mushroom Kingdom clash!",
                "previewCharacter":"mario",
				"previewCostume":-1,
                "creator":"SSBM - Wex"
			}
		];
		public function EventMode_TroubleKing(api:*)
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
				character: "mario",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "bowser",
				lives: 2,
				human: false,
				team: -1,
				level: 1
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.countdown = false;
			game.levelData.showEntrances = false;
            game.levelData.showCountdownType = 3;
			game.levelData.lives = 2;
			game.levelData.hazards = true;
			game.levelData.stage = "battlefield2";
			game.levelData.musicOverride = "bgm_multimansmash";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			delete game.items.items.smashball;
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
					if (players != null && players.length >= 2)
					{
						// Player 0 gets player 2's position
						players[0].setX(-3.55);
						players[0].setY(0.55);
						SSF2API.getPlayer(1).faceRight();
						
						// Player 1 stays in middle
						players[1].setX(-1.55);
						players[1].setY(-48.75);
						SSF2API.getPlayer(2).faceLeft();
					}
					
					spawnFirst = false;
				}
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 2400)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 3000)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 3600)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 4200)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 4800)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 5400)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
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