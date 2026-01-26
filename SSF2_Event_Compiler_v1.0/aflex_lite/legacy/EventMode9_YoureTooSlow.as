package
{
	import flash.display.MovieClip;
	
	public class EventMode9_YoureTooSlow extends SSF2CustomMatch
	{
		private var success = false;
		
		public function EventMode9_YoureTooSlow(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime() / 2);
			
			SSF2API.getPlayer(1).specialEvent = true;
			SSF2API.getPlayer(1).setGlobalVariable("SlowCharge", 6);
			SSF2API.getPlayer(1).updateCharacterStats({max_xSpeed:15.137});
			SSF2API.getPlayer(2).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(2).setHurtInterrupt(checkStop);
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(3).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(3).setHurtInterrupt(checkStop);
			SSF2API.getPlayer(3).setLivesEnabled(false);
			SSF2API.getPlayer(4).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(4).setHurtInterrupt(checkStop);
			SSF2API.getPlayer(4).setLivesEnabled(false);
		}
		public function checkStop(status:Object):Boolean
		{
			if(status.target.getType() == "SSF2Character")
			{
				if(status.target.getMC().currentLabel == "b" || status.target.getMC().currentLabel == "b_air"){
					return false;
				}else{
					return true;
				}
			}else if(status.target.getType() == "SSF2Projectile"){
				if(status.target.getOwner() == SSF2API.getPlayer(1))
					return true;
				else
					return false;
			}else if(status.target.getType() == "SSF2Item"){
				if(status.target.getOwner() == SSF2API.getPlayer(1))
					return true;
				else 
					return false;
			}else{ 
				return true;
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
				character: "blackmage",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "sonic",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "sonic",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "sonic",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "greenhillzone";
			game.levelData.teamDamage = false;
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
			SSF2API.getPlayer(1).setGlobalVariable("SlowCharge", 6);
				
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || players[1].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].inState(CState.INJURED) && players[2].inState(CState.INJURED) && players[3].inState(CState.INJURED))
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 300)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 500)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 600)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 800)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1000)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1400)
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