package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class EventMode6_SavingTheSaturns extends SSF2CustomMatch
	{
		private var saturnArray:Array = [];
		private var numSaturns:Number = 3;
		private var spawnLocations:Array = [new Point(136,215),new Point(166,219),new Point(184,219),new Point(200,219),new Point(220,219),new Point(245,219)];
		private var failed:Boolean = false;

		public function EventMode6_SavingTheSaturns(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime()/1.5);
			
			for(var i=0; i<numSaturns; i++)
			{
				var loc = spawnLocations[Math.floor(SSF2API.random() * spawnLocations.length)];
				var saturn = SSF2API.generateItem("mrsaturn", loc.x, loc.y, true);
				spawnLocations.splice(spawnLocations.indexOf(loc),1);
				
				saturn.weightSim = 160;
				saturn.updateItemStats({time_max:int.MAX_VALUE});
				saturn.resetTime();
				saturn.addToCamera();
				saturn.setCamBoxSize(50,30);
				saturnArray.push(saturn);
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
				character: "ness",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "luffy",
				lives: 2,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			//game.levelData.time = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "saturnvalley";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.items.mrsaturn = false;
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update():void
		{
			for(var i=0; i<saturnArray.length; i++)
			{
				var saturn = saturnArray[i];
				
				if(saturn.inState(IState.DEAD)){
					failed=true;
					saturn.attachEffect("deathMC");
					SSF2API.playSound("deathExplosion");
				}else{
					saturn.updateItemStats({time_max:int.MAX_VALUE});
					saturn.resetTime();
				}
			}
			
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				
				if (players[0].getLives() <= 0 || failed)
				{
					matchData.success = false;
					SSF2API.endGame({success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					var rank = "F";
					if(players[0].getDamage() <= 10)
						rank = "S";
					else if(players[0].getDamage() <= 35)
						rank = "A";
					else if(players[0].getDamage() <= 75)
						rank = "B";
					else if(players[0].getDamage() <= 100)
						rank = "C";
					else if(players[0].getDamage() <= 120)
						rank = "D";
					else if(players[0].getDamage() <= 150)
						rank = "E";
					else
						rank = "F";
					
					//should save the percentage that the player was at
					matchData.success = true;
					matchData.rank = rank;
					matchData.stock = players[0].getLives();
					matchData.score = players[0].getDamage();
					matchData.scoreType = "damage";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({success: true, immediate: false });
				}
			}
		}
	}
}