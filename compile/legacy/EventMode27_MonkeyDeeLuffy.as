package
{
	import flash.display.MovieClip;
	
	public class EventMode27_MonkeyDeeLuffy extends SSF2CustomMatch
	{
		public function EventMode27_MonkeyDeeLuffy(api:*)
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
				character: "luffy",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "donkeykong",
				lives: 1,
				human: false,
				team: 3,
				level: 7,
				damageRatio: 1.2
			});
			game.playerSettings.push({ 
				character: "bandanadee",
				lives: 1,
				human: false,
				team: 3,
				level: 7,
				damageRatio: 1.2
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.teamDamage = false;
			game.levelData.stage = "thousandsunny";
			
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
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 830)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1200)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1450)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1800)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2450)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 3000)
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