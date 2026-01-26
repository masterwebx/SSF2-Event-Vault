package
{
	import flash.display.MovieClip;
	
	public class EventMode39_SwordsVsSpears extends SSF2CustomMatch
	{
		public function EventMode39_SwordsVsSpears(api:*)
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
				character: "marth",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: 3
			});
			game.playerSettings.push({ 
				character: "bandanadee",
				lives: 1,
				human: false,
				team: 1,
				level: 9,
				attackRatio: 1.2,
				damageRatio: 1.3
			});
			game.playerSettings.push({ 
				character: "bandanadee",
				lives: 1,
				human: false,
				team: 1,
				level: 9,
				attackRatio: 1.2,
				damageRatio: 1.3
			});
			game.playerSettings.push({ 
				character: "bandanadee",
				lives: 1,
				human: false,
				team: 1,
				level: 9,
				attackRatio: 1.2,
				damageRatio: 1.3
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "draculascastle";
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
					if(SSF2API.getElapsedFrames() <= 1550)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1800)
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