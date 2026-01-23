package
{
	import flash.display.MovieClip;
	
	public class EventMode3_GourmetRace extends SSF2CustomMatch
	{
		public function EventMode3_GourmetRace(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).setDamage(300);
			SSF2API.getPlayer(2).setDamage(300);
			SSF2API.getPlayer(3).setDamage(300);
			SSF2API.getPlayer(1).setTeamID(1);
			SSF2API.getPlayer(2).setTeamID(1);
			SSF2API.getPlayer(3).setTeamID(1);
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(3).setLivesEnabled(false);
			SSF2API.getPlayer(1).updateCharacterStats({weight1:99999});
			SSF2API.getPlayer(2).updateCharacterStats({weight1:99999});
			SSF2API.getPlayer(3).updateCharacterStats({weight1:99999});
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
				character: "yoshi",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				startDamage:300
			});
			game.playerSettings.push({ 
				character: "kirby",
				costume: 0,
				lives: 99,
				human: false,
				startDamage:300,
				level: 9
			});
			game.playerSettings.push({ 
				character: "wario",
				costume: 0,
				lives: 99,
				human: false,
				startDamage:300,
				level: 9
			});
			game.levelData.usingLives = false;
			game.levelData.usingTime = true;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.time = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "dreamland";
			game.levelData.startDamage = 300;
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.food;
			delete game.items.items.fooditem;
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var food;
				if(SSF2API.random() > 0.5){
					food = SSF2API.generateItem("fooditem",-18+(SSF2API.random()*440),-83);
					if(food){
						food.recoverAmount = 1;
					}
				} else {
					food = SSF2API.generateItem("fooditem",-52+(SSF2API.random()*528),89);
					if(food){
						food.recoverAmount = 1;
					}
				}
				
				var players:Array = SSF2API.getPlayers();
				if (SSF2API.getGameTimer().getCurrentTime() <= 0 && (players[0].getDamage() >= players[1].getDamage() && players[0].getDamage() >= players[2].getDamage()) || players[2].getDamage() == 0 || players[1].getDamage() == 0 || players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (SSF2API.getGameTimer().getCurrentTime() <= 0 || players[0].getDamage() <= 0)
				{
					//Set rank
					var rank = "F";
					if(players[0].getDamage() <= 267)
						rank = "S";
					else if(players[0].getDamage() <= 272)
						rank = "A";
					else if(players[0].getDamage() <= 281)
						rank = "B";
					else if(players[0].getDamage() <= 285)
						rank = "C";
					else if(players[0].getDamage() <= 290)
						rank = "D";
					else if(players[0].getDamage() <= 295)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.rank = rank;
					matchData.scoreType = "damage";
					matchData.score = players[0].getDamage();
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ immediate: false });
				}
			}
		}
		
	}
}