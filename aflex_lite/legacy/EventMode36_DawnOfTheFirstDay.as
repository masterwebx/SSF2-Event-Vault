package
{
	import flash.display.MovieClip;
	
	public class EventMode36_DawnOfTheFirstDay extends SSF2CustomMatch
	{
		private var maxTime:Number = 999;
		public function EventMode36_DawnOfTheFirstDay(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			maxTime = Math.floor(SSF2API.getStage().getCameraBackgrounds()[0].mc.totalFrames-240);
			SSF2API.getGameTimer().setCurrentTime(maxTime);
			//3410 frames which is 113.666 seconds. 
			
			SSF2API.getPlayer(1).setTeamID(1);
			SSF2API.getPlayer(2).setTeamID(2);
			SSF2API.getPlayer(3).setTeamID(2);
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(3).setLivesEnabled(false);

		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "link",
				name: initSettings.playerSettings[0].name,
				lives: 2,
				human: true
			});
			game.playerSettings.push({ 
				character: "bowser",
				human: false,
				level: 8,
				costume: 8
			});
			game.playerSettings.push({ 
				character: "blackmage",
				human: false,
				level: 8,
				costume: 7
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.teamDamage = true;
			game.levelData.time = 17;
			game.levelData.lives = 2;
			game.levelData.hazards = true;
			game.levelData.stage = "clocktown";
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
				SSF2API.print(players[0].getMatchStatistics().kos);
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					//Set rank
					var rank = "F";
				
					if(players[0].getMatchStatistics().kos >= 6)
						rank = "S";
					else if(players[0].getMatchStatistics().kos >= 5)
						rank = "A";
					else if(players[0].getMatchStatistics().kos >= 4)
						rank = "B";
					else if(players[0].getMatchStatistics().kos >= 3)
						rank = "C";
					else if(players[0].getMatchStatistics().kos >= 2)
						rank = "D";
					else if(players[0].getMatchStatistics().kos >= 1)
						rank = "E";
					else
						rank = "F";
										
					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = players[0].getMatchStatistics().kos;
					matchData.scoreType = "kos";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({success: true, immediate: false });
				}
			}
		}
	}
}