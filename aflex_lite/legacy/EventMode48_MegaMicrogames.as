package
{
	import flash.display.MovieClip;
	
	public class EventMode48_MegaMicrogames extends SSF2CustomMatch
	{
		public var failure = false;
		public var successes = 0;
		
		public function EventMode48_MegaMicrogames(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getStage().eventInstance = this;
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "wario",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "wario",
				lives: 2,
				human: false,
				team: 3,
				level: 7
			});
			game.playerSettings.push({ 
				character: "luigi",
				lives: 2,
				human: false,
				team: 3,
				level: 5
			});
			game.playerSettings.push({ 
				character: "mario",
				lives: 2,
				human: false,
				team: 3,
				level: 6
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.teamDamage = true;
			game.levelData.stage = "warioware";
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
			var tempStage = SSF2API.getStage();
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || failure)
				{
					matchData.success = false;
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (successes >= 3)
				{

					var rank = "F";
					if(players[0].getDamage() <= 50)
						rank = "S";
					else if(players[0].getDamage() <= 100)
						rank = "A";
					else if(players[0].getDamage() <= 120)
						rank = "B";
					else if(players[0].getDamage() <= 140)
						rank = "C";
					else if(players[0].getDamage() <= 175)
						rank = "D";
					else if(players[0].getDamage() <= 200)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = players[0].getDamage();
					matchData.scoreType = "damage";
					
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ slowMo: false, success: true, immediate: false });
				}
			}
		}
	}
}