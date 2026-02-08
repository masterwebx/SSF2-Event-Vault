package
{
	import flash.display.MovieClip;
	
	public class EventMode_MeteoCampaign9B extends SSF2CustomMatch
	{
		public var eventinfo:Array = [
			{
				"id":"meteocampaign9b",
                "classAPI":EventMode_MeteoCampaign9B,
                "name":"Meteo Campaign 9B",
                "description":"Pick! Defeat Fox on his home turf!",
                "chooseCharacter": true,
                "creator":"Mcleodgaming/Wex"
			}
		];
		public function EventMode_MeteoCampaign9B(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			
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
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "fox",
				lives: 3,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 2;
			game.levelData.hazards = true;
			game.levelData.stage = "meteovoyage";
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.smashball;
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 2600)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 3100)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 3350)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 3700)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 4200)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 5000)
						rank = "E";
					else
						rank = "F";
					
					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}