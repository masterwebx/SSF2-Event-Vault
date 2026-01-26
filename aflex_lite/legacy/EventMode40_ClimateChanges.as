package
{
	import flash.display.MovieClip;
	
	public class EventMode40_ClimateChanges extends SSF2CustomMatch
	{
		public function EventMode40_ClimateChanges(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getStage().m_specialEvent = true;
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "zamus",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "marth",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			game.playerSettings.push({ 
				character: "luigi",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			game.playerSettings.push({ 
				character: "goku",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "crateria";
			game.levelData.teamDamage = false;
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
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1880)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 2000)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2100)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2300)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2550)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2700)
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