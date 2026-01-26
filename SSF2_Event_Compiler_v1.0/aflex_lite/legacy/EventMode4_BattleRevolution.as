package
{
	import flash.display.MovieClip;
	
	public class EventMode4_BattleRevolution extends SSF2CustomMatch
	{
		public function EventMode4_BattleRevolution(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			for(var i:int = 1; i <= 4; i++){
				var player = SSF2API.getPlayer(i);
				player.setHurtInterrupt(pokeBallCheck);
				
				if(i >= 2){
					player.updateCharacterStats({damageRatio: 1.35});
				}
			}
		}
		public function pokeBallCheck(status:Object):Boolean
		{
			if (status.target == null) {
				return false;
			}
			var foe = status.target;
			var foeType = foe.getType();
			
			if(foeType)
			{
				if(foeType == "SSF2Item"){
					if(foe.getItemStat("linkage_id") == "pokeball" || foe.getOwner().getType() == "SSF2Enemy")
						return false;
					else
						return true;
				}else if(foeType == "SSF2Enemy"){
					//if(SSF2API.getPokemonStatsList().indexOf(foe.getEnemyStat("linkage_id")) >= 0)
						return false;
					//else
						//return true;
				}else if(foeType == "SSF2Projectile"){ 
					if(foe.getOwner().getType() == "SSF2Enemy")
						return false;
					else
						return true;
				}else{
					return true;
				}
			} else return false;
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
				character: "pikachu",
				lives: 1,
				human: false,
				team: -1,
				level: 7
			});
			game.playerSettings.push({ 
				character: "pikachu",
				lives: 1,
				human: false,
				team: -1,
				level: 7
			});
			game.playerSettings.push({ 
				character: "jigglypuff",
				lives: 1,
				human: false,
				team: -1,
				level: 7
			});
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "pokemoncolosseum";
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.pokeball;
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
					SSF2API.endGame({success: false, immediate:false});
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1100)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1200)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1275)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1400)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1675)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1800)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.rank = rank;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ immediate: false });
				}
			}
		}
		
	}
}