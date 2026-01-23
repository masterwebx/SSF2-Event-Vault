package
{
	import flash.display.MovieClip;
	
	public class EventMode17_DarkLinksAdvance extends SSF2CustomMatch
	{
		
		private var failureTimer:FrameTimer = new FrameTimer(1350 + 138);
		
		public function EventMode17_DarkLinksAdvance(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(1350 + 138);
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
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "link",
				lives: 1,
				human: false,
				team: -1,
				level: 9,
				costume: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.countdown = true;
			game.levelData.time = 3;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "hylianskies";
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
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 900)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1250)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1525)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1900)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2300)
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
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}