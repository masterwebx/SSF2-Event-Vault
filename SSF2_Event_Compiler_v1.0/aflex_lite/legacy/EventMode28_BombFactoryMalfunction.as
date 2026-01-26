package
{
	import flash.display.MovieClip;
	
	public class EventMode28_BombFactoryMalfunction extends SSF2CustomMatch
	{
		
		public function EventMode28_BombFactoryMalfunction(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getStage().specialEvent = true;
			SSF2API.getPlayer(1).updateCharacterStats({canShield:false});
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime()/2);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "bomberman",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.countdown = false;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "bombfactory";
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
				if (players[0].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() >= 40*30)
						rank = "S";
					else if(SSF2API.getElapsedFrames() >= 35*30)
						rank = "A";
					else if(SSF2API.getElapsedFrames() >= 30*30)
						rank = "B";
					else if(SSF2API.getElapsedFrames() >= 25*30)
						rank = "C";
					else if(SSF2API.getElapsedFrames() >= 20*30)
						rank = "D";
					else if(SSF2API.getElapsedFrames() >= 10*30)
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