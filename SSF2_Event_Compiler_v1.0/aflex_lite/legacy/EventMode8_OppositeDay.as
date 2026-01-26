package
{
	import flash.display.MovieClip;
	
	public class EventMode8_OppositeDay extends SSF2CustomMatch
	{
		public function EventMode8_OppositeDay(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime()/2);
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(3).setLivesEnabled(false);
			SSF2API.getPlayer(4).setLivesEnabled(false);

		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "gameandwatch",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "bowser",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "ichigo",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "zelda",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 2;
			game.levelData.stage = "pacmaze";
			game.levelData.teamDamage = false;
			game.levelData.hazards = true;
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
				if (players[1].getLives() <= 0 || players[2].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[0].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 575)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 650)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 700)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 750)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 800)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 850)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({success: true, immediate: false });
				}
			}
		}
	}
}