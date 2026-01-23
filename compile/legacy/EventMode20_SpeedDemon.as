package
{
	import flash.display.MovieClip;
	
	public class EventMode20_SpeedDemon extends SSF2CustomMatch
	{
		public function EventMode20_SpeedDemon(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(2).setCPUForcedAction(CPUState.EVADE);
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime() / 2);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "captainfalcon",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "sonic",
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
			game.levelData.stage = "sandocean";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = true;
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 500)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 550)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 575)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 625)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 650)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 700)
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