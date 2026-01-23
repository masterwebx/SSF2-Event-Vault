package
{
	import flash.display.MovieClip;
	
	public class EventMode43_TheTroubleWithDoubles extends SSF2CustomMatch
	{
		public var updated = false;
		
		public function EventMode43_TheTroubleWithDoubles(api:*)
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
				character: initSettings.playerSettings[0].character,
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: initSettings.playerSettings[0].character,
				lives: 2,
				human: false,
				team: 1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "fox",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			game.playerSettings.push({ 
				character: "falco",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.teamDamage = true;
			game.levelData.stage = "saffroncity";
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
			var players:Array = SSF2API.getPlayers();

			if(!updated)
			{
				var player1 = players[0];
				var player2 = players[1];
				var player3 = players[2];
				var player4 = players[3];
				
				var player1Damage = player1.getDamage();
				var player2Damage = player2.getDamage();
				var player3Damage = player3.getDamage();
				var player4Damage = player4.getDamage();
				
				if(player2Damage < player1Damage){
					player2.setDamage(player1Damage);
					player2.throbDamageCounter();
				}else if(player1Damage < player2Damage){
					player1.setDamage(player2Damage);
					player1.throbDamageCounter();
				}
				
				if(player4Damage < player3Damage){
					player4.setDamage(player3Damage);
					player4.throbDamageCounter();
				}else if(player3Damage < player4Damage){
					player3.setDamage(player4Damage);
					player3.throbDamageCounter();
				}
				updated = true;
			}else{
				updated = false;
			}
			
			if (!SSF2API.isGameEnded())
			{
				if (players[0].getLives() <= 0 || players[1].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 950)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1250)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1470)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 3000)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 3290)
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