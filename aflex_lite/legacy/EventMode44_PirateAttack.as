package
{
	import flash.display.MovieClip;
	
	public class EventMode44_PirateAttack extends SSF2CustomMatch
	{
		public function EventMode44_PirateAttack(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
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
				costume: initSettings.playerSettings[0].costume,
				lives: 3,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "luffy",
				lives: 2,
				human: false,
				team: 2,
				level: 9,
				costume: 4
			});
			game.playerSettings.push({ 
				character: "luffy",
				lives: 2,
				human: false,
				team: 2,
				level: 9,
				costume: 4
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "gangplankgalleon";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.items.fooditem = false;
			game.items.items.maximumtomato = false;
			game.items.items.heartContainer = false;
			game.items.items.energytank = false;
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
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1400)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1900)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2500)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2840)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 3100)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 3450)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ slowMo: false, success: true, immediate: false });
				}
			}
		}
	}
}