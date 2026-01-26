package
{
	import flash.display.MovieClip;
	
	public class EventMode24_Restless extends SSF2CustomMatch
	{
		public function EventMode24_Restless(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime()/4);
			SSF2API.getPlayer(1).setSizeStatus(1);
			SSF2API.getPlayer(1).lockSizeStatus(true);
			SSF2API.getPlayer(2).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(3).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(4).setCPUForcedAction(CPUState.FORCE_RUN);
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
				character: "jigglypuff",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 3,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "ness",
				human: false,
				lives: 999,
				team: -1,
				level: 8
			});
			game.playerSettings.push({ 
				character: "ness",
				human: false,
				lives: 999,
				team: -1,
				level: 8
			});
			game.playerSettings.push({ 
				character: "ness",
				human: false,
				lives: 999,
				team: -1,
				level: 8
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.stage = "nintendo3ds";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
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
				} else if (players[1].getCurrentAnimation() == "sleep" && players[2].getCurrentAnimation() == "sleep" && players[3].getCurrentAnimation() == "sleep")
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 20)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 85)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 220)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 320)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 400)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 750)
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