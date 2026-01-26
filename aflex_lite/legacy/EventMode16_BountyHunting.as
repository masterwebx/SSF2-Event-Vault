package
{
	import flash.display.MovieClip;
	
	public class EventMode16_BountyHunting extends SSF2CustomMatch
	{
		public function EventMode16_BountyHunting(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).setTeamID(1);
			SSF2API.getPlayer(2).setTeamID(2);
			SSF2API.getPlayer(3).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(3).setTeamID(3);
			SSF2API.getPlayer(4).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(4).setTeamID(3);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "samus",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "yoshi",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "yoshi",
				lives: 1,
				human: false,
				team: -1,
				level: 4,
				costume: 4
			});
			game.playerSettings.push({ 
				character: "yoshi",
				lives: 1,
				human: false,
				team: -1,
				level: 4,
				costume: 2
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "yoshisisland";
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
				if (players[0].getLives() <= 0 || players[2].getLives() <= 0 || players[3].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 680)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1200)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1450)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1650)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1900)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2250)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ slowMo: false, success: true, immediate: false });
				}
			}
		}
		
	}
}