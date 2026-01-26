package
{
	import flash.display.MovieClip;
	
	public class EventMode47_HideNSheik extends SSF2CustomMatch
	{
		private const transformDelay:int = 270;
		
		
		private var transformTimer:int;
		
		public function EventMode47_HideNSheik(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			transformTimer = transformDelay;
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(3).setLivesEnabled(false);
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
				character: "zelda",
				lives: 1,
				human: false,
				team: 3,
				damageRatio: 1.275,
				level: 9
			});
			game.playerSettings.push({ 
				character: "zelda",
				lives: 1,
				human: false,
				team: 3,
				damageRatio: 1.275,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 2;
			game.levelData.hazards = true;
			game.levelData.stage = "hylianskies";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public function handleSheik():void
		{
			if(SSF2API.getPlayer(2).getCharacterStat("statsName") == "sheik")
				SSF2API.getPlayer(2).setLivesEnabled(true);
			else
				SSF2API.getPlayer(2).setLivesEnabled(false);
			if(SSF2API.getPlayer(3).getCharacterStat("statsName") == "sheik")
				SSF2API.getPlayer(3).setLivesEnabled(true);
			else
				SSF2API.getPlayer(3).setLivesEnabled(false);
				
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				transformTimer--;
				
				if(transformTimer <= 0)
				{
					var chance = SSF2API.random()*100;
					var downBinput = [0,1,1088,20];
					
					if(!SSF2API.getPlayer(2).inState(CState.DEAD) && !SSF2API.getPlayer(3).inState(CState.DEAD))
					{
						if(chance <= 40)
							SSF2API.getPlayer(2).importCPUControls(downBinput);
						else if(chance <= 80) 
							SSF2API.getPlayer(3).importCPUControls(downBinput);
						else if(chance < 87){
							SSF2API.getPlayer(2).importCPUControls(downBinput);
							SSF2API.getPlayer(3).importCPUControls(downBinput);
						}
					}else if (SSF2API.getPlayer(2).inState(CState.DEAD))
					{
						if(chance < 75)
							SSF2API.getPlayer(3).importCPUControls(downBinput);
						
					}else if (SSF2API.getPlayer(3).inState(CState.DEAD))
					{
						if(chance < 75)
							SSF2API.getPlayer(2).importCPUControls(downBinput);
						
					}
						
					transformTimer = transformDelay;
				}
				
				handleSheik();
				
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{

					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 2500)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 3200)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 3600)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 4200)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 4740)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 5300)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					
					SSF2API.endGame({success: true, immediate: false });
				}
			}
		}
	}
}