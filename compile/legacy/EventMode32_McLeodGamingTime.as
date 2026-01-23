package
{
	import flash.display.MovieClip;
	
	public class EventMode32_McLeodGamingTime extends SSF2CustomMatch
	{
		private var extended = false;
		
		public function EventMode32_McLeodGamingTime(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime() * 0.05);
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
				startDamage: 86,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "captainfalcon",
				startDamage: 115,
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "smashville";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_ULTRA_HIGH;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if(SSF2API.getGameTimer().getCurrentTime() <= 0 && !extended)
				{
					SSF2API.getGameTimer().setCurrentTime(6*30);
					SSF2API.getGameTimer().restart();
					extended = true;
					
				} else if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0 && extended)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 90)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 125)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 147)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 170)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 195)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 205)
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