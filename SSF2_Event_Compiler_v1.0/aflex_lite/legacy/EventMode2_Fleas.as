package
{
	import flash.display.MovieClip;
	
	public class EventMode2_Fleas extends SSF2CustomMatch
	{
		public function EventMode2_Fleas(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			for(var i:int = 2; i <= 4; i++){
				var player = SSF2API.getPlayer(i);
				player.setSizeStatus(-1);
				player.lockSizeStatus(true);
				player.setScale(0.5, 0.5);
				player.updateCharacterStats({damageRatio: 1.65});
			}
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "donkeykong",
				name: initSettings.playerSettings[0].name,
				lives: 3,
				human: true,
				team: 0
			});
			game.playerSettings.push({ 
				character: "tails",
				lives: 3,
				human: false,
				team: 1,
				level: 4
			});
			game.playerSettings.push({ 
				character: "pit",
				lives: 3,
				human: false,
				team: 1,
				level: 4,
				costume: 4
			});
			game.playerSettings.push({ 
				character: "metaknight",
				lives: 1,
				human: false,
				team: 1,
				level: 4,
				costume: 2
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.teamDamage = false;
			game.levelData.hazards = true;
			game.levelData.stage = "junglehijinx";
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
					SSF2API.endGame({ slowMo: true, success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 730)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 900)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1250)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1750)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2600)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2850)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({immediate: false });
				}
			}
		}
		
	}
}