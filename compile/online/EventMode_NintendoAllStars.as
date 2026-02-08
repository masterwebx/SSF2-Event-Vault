package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class EventMode_NintendoAllStars extends SSF2CustomMatch
	{
		public var spawnMCs:Array = [];
		public var spawnFirst:Boolean = true;
		public var eventinfo:Array = [
			{
				"id":"nintendoallstars",
                "classAPI":EventMode_NintendoAllStars,
                "name":"Nintendo All-Stars",
                "description":"Prove your worth against flagship Nintendo characters!",
                "chooseCharacter": true,
                "creator":"Mcleodgaming/Wex"
			}
		];
		public function EventMode_NintendoAllStars(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{			
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime());
			SSF2API.getPlayer(3).faceLeft();
			
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			game.playerSettings.push({ 
				character: initSettings.playerSettings[0].character,
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 3,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "link",
				damageRatio: 1,
				lives: 2,
				team: 3,
				human: false,
				level: 9
			});
			game.playerSettings.push({ 
				character: "pikachu",
				lives: 2,
				team: 3,
				human: false,
				level: 9
			});
			game.playerSettings.push({ 
				character: "mario",
				lives: 2,
				team: 3,
				human: false,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.stage = "finaldestination";
			game.levelData.hazards = true;
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			delete game.items.items.fooditem;
			delete game.items.items.maximumtomato;
			delete game.items.items.heartContainer;
			delete game.items.items.energytank;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();				
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
					else if (players.length > 3 && players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
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
