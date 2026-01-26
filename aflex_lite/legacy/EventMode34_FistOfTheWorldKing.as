package
{
	import flash.display.MovieClip;
	
	public class EventMode34_FistOfTheWorldKing extends SSF2CustomMatch
	{
		public function EventMode34_FistOfTheWorldKing(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(2).setSizeStatus(1);
			SSF2API.getPlayer(2).lockSizeStatus(true);
			SSF2API.getPlayer(2).updateCharacterStats({damageRatio:0.75, heavyArmor:10});
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "goku",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "donkeykong",
				costume: 6,
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "worldtournament";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.items["smashball"] = false;
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update():void
		{
			SSF2API.getPlayer(1).powerUp();
			
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 650)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 760)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 850)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1600)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1800)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2000)
						rank = "E";
					else
						rank = "F";
					
					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}