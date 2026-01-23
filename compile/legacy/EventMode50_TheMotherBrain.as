package
{
	import flash.display.MovieClip;
	
	public class EventMode50_TheMotherBrain extends SSF2CustomMatch
	{
		var motherBrain:*;
		public function EventMode50_TheMotherBrain(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).faceLeft();
			
			motherBrain = SSF2API.spawnEnemy(MotherBrain);
			motherBrain.setHP(200);
			motherBrain.attachHealthBox("MOTHER BRAIN", "motherBrain_icon", "Series_Metroid");
			motherBrain.setX(230);
			motherBrain.setY(220);
			motherBrain.setTimer(100000);
			motherBrain.addToCamera();
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "samus",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: 1
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "tourian";
			game.levelData.musicOverride = "bgm_vsridley";
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
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (motherBrain.inState(EState.DEAD) || !motherBrain)
				{
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 810)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1250)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1400)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1620)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1750)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1900)
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