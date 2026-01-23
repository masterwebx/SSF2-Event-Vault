package
{
	import flash.display.MovieClip;
	
	public class EventMode31_AHeavenlyPower extends SSF2CustomMatch
	{
		public function EventMode31_AHeavenlyPower(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(3).setTeamID(3);
			SSF2API.getPlayer(4).setTeamID(3);
			SSF2API.getPlayer(2).setSizeStatus(1);
			SSF2API.getPlayer(2).lockSizeStatus(true);
			SSF2API.getPlayer(2).updateCharacterStats({canReceiveDamage:false, canReceiveKnockback:false, canShield:false, canUseItems:false, heavyArmor:99999});
			SSF2API.getPlayer(2).setLivesEnabled(false);
			
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "pit",
				name: initSettings.playerSettings[0].name,
				costume: 1,
				lives: 1,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "pit",
				lives: 1,
				human: false,
				team: 1,
				level: 9
			});
			game.playerSettings.push({ 
				character: "ness",
				lives: 1,
				human: false,
				costume: 9,
				level: 9
			});
			game.playerSettings.push({ 
				character: "ness",
				lives: 1,
				human: false,
				costume: 9,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "devilsmachine";
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
			SSF2API.getPlayer(2).setVisibility(false);

			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 900)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1450)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1650)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2100)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2500)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2800)
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