package
{
	import flash.display.MovieClip;
	
	public class EventMode_LordJungle2 extends SSF2CustomMatch
	{
		public var eventinfo:Array = [
			{
				"id":"lordJungle2",
                "classAPI":EventMode_LordJungle2,
                "name":"Lord of the Jungle 2",
                "description":"This time he's brought a friend! Are you still the top primate?",
                "previewCharacter":"donkeykong",
				"previewCostume":0,
                "creator":"Mcleodgaming/Wex"
			}
		];
		public function EventMode_LordJungle2(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			for(var i:int = 2; i <= 3; i++){
				var player = SSF2API.getPlayer(i);
				player.setSizeStatus(-1);
				player.lockSizeStatus(true);
				player.setScale(0.5, 0.5);
			}
			SSF2API.getPlayer(1).setSizeStatus(1);
			SSF2API.getPlayer(1).lockSizeStatus(true);
			SSF2API.getPlayer(2).setTeamID(2);
			SSF2API.getPlayer(3).setTeamID(2);
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
				lives: 1,
				human: true,
				damageRatio: 1.5,
				costume: 0,
				team: 1
			});
			game.playerSettings.push({ 
				character: "donkeykong",
				lives: 2,
				human: false,
				team: 2,
				costume: 2,
				damageRatio: 0.5,
				level: 9
			});
			game.playerSettings.push({ 
				character: "donkeykong",
				lives: 2,
				human: false,
				team: 2,
				costume: 2,
				damageRatio: 0.5,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 2;
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
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 3600) // S rank: 60.00 seconds or less
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 4500) // A rank: 75.00 seconds or less
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 5400) // B rank: 90.00 seconds or less
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 6300) // C rank: 105.00 seconds or less
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 7200) // D rank: 120.00 seconds or less
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 8100) // E rank: 135.00 seconds or less
						rank = "E";
					else
						rank = "F"; // F rank: 135.01 seconds or more
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({
							success: true,
							immediate: false,
							slowMo: false
						});
				}
			}
		}
		
	}
}