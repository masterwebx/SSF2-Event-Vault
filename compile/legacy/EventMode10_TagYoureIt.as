package
{
	import flash.display.MovieClip;
	
	public class EventMode10_TagYoureIt extends SSF2CustomMatch
	{
		public function EventMode10_TagYoureIt(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(2).addEventListener(SSF2Event.CHAR_KO_DEATH,checkTag,{persistent:true});
			SSF2API.getPlayer(3).setLivesEnabled(false);
			SSF2API.getPlayer(3).addEventListener(SSF2Event.CHAR_KO_DEATH,checkTag,{persistent:true});
		}
		public function checkTag(e:*):void
		{
			var player = e.data.caller;
			var foe = player.getLastHurtAttackBoxStats().owner;
			
			if(foe.getType() == "SSF2Item" && foe.getItemStat("linkage_id") == "explodingtag"){
				player.removeEventListener(SSF2Event.CHAR_KO_DEATH,checkTag);
				player.setLivesEnabled(true);
				player.setLives(0);
				player.setStandby(true);
			}else{ 
				player.setLivesEnabled(false);
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
				character: initSettings.playerSettings[0].character,
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "samus",
				lives: 1,
				human: false,
				team: -1,
				level: 3
			});
			game.playerSettings.push({ 
				character: "link",
				lives: 1,
				human: false,
				team: -1,
				level: 5
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "peachscastle";
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.explodingtag;

			game.items.frequency = ItemSettings.FREQUENCY_MAX;
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
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 1200)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1300)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1450)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1500)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1575)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1700)
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