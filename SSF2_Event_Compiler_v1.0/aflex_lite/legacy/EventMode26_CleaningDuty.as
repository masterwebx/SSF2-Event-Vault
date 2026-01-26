package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class EventMode26_CleaningDuty extends SSF2CustomMatch
	{
		private var dirtArray:Array = [];
		private var numDirt:Number = 4;
		private var spawnLocations:Array = [new Point(163,142),new Point(21,142),new Point(20,25),new Point(27,-187),new Point(430,-187),new Point(500,-234),new Point(578,7)];
		
		public function EventMode26_CleaningDuty(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime()/2.5);
			SSF2API.getStage().getForeground().obj1.visible = false;

			for(var i=0; i<numDirt; i++)
			{
				var loc = spawnLocations[Math.floor(SSF2API.random() * spawnLocations.length)];
				var dirt = SSF2API.spawnEnemy(EventAsset_PileOfDirt);
				dirt.setX(loc.x);
				dirt.setY(loc.y);
				dirt.forceOnGround();
				dirt.addToCamera();
				spawnLocations.splice(spawnLocations.indexOf(loc),1);
				
				dirtArray.push(dirt);
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
				character: "chibirobo",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "wario",
				human: false,
				team: -1,
				lives: 1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.stage = "desk";
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
			if (!SSF2API.isGameEnded())
			{				
				for(var i=0; i<dirtArray.length; i++)
				{
					if(dirtArray[i].inState(EState.DEAD))
					{
						dirtArray[i].removeFromCamera();
						dirtArray.splice(i,1);
					}
				}

				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (dirtArray.length <= 0)
				{
					//Set rank
					var rank = "F";
					if(players[1].inState(CState.DEAD))
						rank = "S";
					else if(players[1].getDamage() >= 34)
						rank = "A";
					else if(players[1].getDamage() >= 20)
						rank = "B";
					else if(players[1].getDamage() >= 10)
						rank = "C";
					else if(players[1].getDamage() >= 5)
						rank = "D";
					else if(players[1].getDamage() >= 2)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					if(players[1].inState(CState.DEAD))
						matchData.score = "999999";
					else
						matchData.score = players[1].getDamage();						
					matchData.scoreType = "points";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}