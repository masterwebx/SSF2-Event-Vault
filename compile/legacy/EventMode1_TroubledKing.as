package
{
	import flash.display.MovieClip;
	
	public class EventMode1_TroubledKing extends SSF2CustomMatch
	{
		public function EventMode1_TroubledKing(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(2).setSizeStatus(1);
			SSF2API.getPlayer(2).lockSizeStatus(true);
			SSF2API.getPlayer(2).updateCharacterStats({damageRatio: 2});
			
			
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime());
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "bowser",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "mario",
				lives: 2,
				human: false,
				team: -1,
				level: 3
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.lives = 2;
			game.levelData.time = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "kingdom1";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_HIGH;
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
					if(SSF2API.getElapsedFrames() <= 360)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 615)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 850)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1000)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1350)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1500)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({immediate:false});
				}
			}
		}
	}
}