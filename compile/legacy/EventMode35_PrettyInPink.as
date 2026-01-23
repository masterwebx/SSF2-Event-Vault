package
{
	import flash.display.MovieClip;
	
	public class EventMode35_PrettyInPink extends SSF2CustomMatch
	{
		public function EventMode35_PrettyInPink(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).setTeamID(1);
			SSF2API.getPlayer(2).setTeamID(2);
			SSF2API.getPlayer(3).setTeamID(2);
			SSF2API.getPlayer(4).setTeamID(2);
			
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
				human: true
			});
			game.playerSettings.push({ 
				character: "kirby",
				lives: 1,
				human: false,
				level: 9
			});
			game.playerSettings.push({ 
				character: "jigglypuff",
				lives: 1,
				human: false,
				level: 9
			});
			game.playerSettings.push({ 
				character: "peach",
				lives: 1,
				human: false,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "dreamland";
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
					if(SSF2API.getElapsedFrames() <= 1000)
						//zelda up special on floaties at the top platform my friend
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 2000)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2400)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2800)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 3100)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 3500)
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