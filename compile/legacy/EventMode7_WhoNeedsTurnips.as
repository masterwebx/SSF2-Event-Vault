package
{
	import flash.display.MovieClip;
	
	public class EventMode7_WhoNeedsTurnips extends SSF2CustomMatch
	{
		public function EventMode7_WhoNeedsTurnips(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).setSpecialEvent(true);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "peach",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "bowser",
				lives: 3,
				human: false,
				team: -1,
				level: 5
			});
			
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 3;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "galaxytours";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_LOW;
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
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1500)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1700)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2200)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2300)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2400)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2800)
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