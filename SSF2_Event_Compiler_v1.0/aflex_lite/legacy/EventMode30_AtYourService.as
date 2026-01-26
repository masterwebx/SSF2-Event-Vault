package
{
	import flash.display.MovieClip;
	
	public class EventMode30_AtYourService extends SSF2CustomMatch
	{
		public function EventMode30_AtYourService(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(2).setSizeStatus(1);
			SSF2API.getPlayer(2).lockSizeStatus(true);			
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
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "goku",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "draculascastle";
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.assistTrophy;
			game.items.frequency = ItemSettings.FREQUENCY_MAX;
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
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1200)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1550)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1800)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2180)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2460)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2800)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.time = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					matchData.score = SSF2API.getElapsedFrames();
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}