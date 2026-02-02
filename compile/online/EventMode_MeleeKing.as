package
{
	import flash.display.MovieClip;
	
	public class EventMode_MeleeKing extends SSF2CustomMatch
	{
		public var bowserSucks:Boolean = false;
		public var bowserFinal:Boolean = false;
		public var bowserName:Boolean = false;
		public var eventinfo:Array = [
			{
				"id":"meleeKing",
                "classAPI":EventMode_MeleeKing,
                "name":"Rise of the Melee King!",
                "description":"Take on the king of melee! Defeat him to show your superiority!",
                "chooseCharacter":true,
                "creator":"MasterWex"
			}
		];
		public function EventMode_MeleeKing(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(1).setDamage(300);
			
			
			
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime());
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
				character: "bowser",
				lives: 1,
				human: false,
				team: -1,
				level: 9,
				unlimitedFinal:true
			});
			
			game.levelData.usingStamina = true;
			game.levelData.usingLives = true;
            game.levelData.startStamina = 400;
			game.levelData.usingTime = true;
			game.levelData.lives = 2;
			game.levelData.time = 2;
			game.levelData.hazards = true;
			game.levelData.stage = "draculascastle";
			game.levelData.musicOverride = "bgm_MKDDBowsersCastle";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			return game;
		}
		public override function update():void
		{
			if (SSF2API.getPlayer(2).inState(CState.REVIVAL))
			{
				bowserFinal = false;	
				bowserName = false;
				SSF2API.getPlayer(2).setDamage(SSF2API.getPlayer(1).getDamage());
			}
			if(bowserFinal == false)
			{
				SSF2API.getPlayer(2).forceAttack("special");				
				bowserFinal = true;				
			}
			if(SSF2API.getElapsedFrames() == 5 && bowserName == false)
			{				
				SSF2API.getPlayer(2).updateCharacterStats({
					"displayName":"The King of Melee",
					"attackRatio":2,
					"heavyArmor":50
				});	
				bowserName = true
			}
			if (SSF2API.getPlayer(2).getDamage() <= 1 && bowserSucks != true) 
			{
				SSF2API.getPlayer(2).updateCharacterStats({
					"displayName":"Bowser"
				});
				 SSF2API.getPlayer(2).endFinalForm();
				 bowserSucks = true;
			}
			if (!SSF2API.isGameEnded())
			{				
				var players:Array = SSF2API.getPlayers();				
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getDamage() == 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 360)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 615)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 850)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1000)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1350)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1500)
						rank = "E";
					else
						rank = "F";
					
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
