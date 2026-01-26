package
{
	import flash.display.MovieClip;
	
	public class EventMode29_ThePowerOfRandom extends SSF2CustomMatch
	{
		public var holdableItems:Array = new Array(
			"trophystand", 
			"fan",
			"beamsword",
			"homerunbat",
			"starrod",
			"beamrod",
			"bloodsword",
			"poisondagger",
			"icewing",
			"rayGun",
			"coconutGun",
			"gustJar",
			"fireFlower",
			"iceFlower",
			"bobomb",
			"motionSensorBomb",
			"gooeybomb",
			"explodingtag",
			"dekuNut",
			"poisonBomb",
			"mrsaturn",
			"unira",
			"pitfall",
			"greenShell",
			"yellowShell",
			"freezie"
		);		
		
		public function EventMode29_ThePowerOfRandom(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			randomItem();
			SSF2API.addEventListener(SSF2Event.GAME_ITEM_CREATED, setTimeMax); 
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: SSF2API.getRandomCharacterID(),
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 3,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: SSF2API.getRandomCharacterID(),
				lives: 3,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: SSF2API.getRandomCharacterID(),
				lives: 3,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({ 
				character: SSF2API.getRandomCharacterID(),
				lives: 3,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 6;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = SSF2API.getRandomStageID(true, false);
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			
			return game;
		}
		public function randomItem():void
		{
			for(var i:int=0; i < SSF2API.getPlayers().length; i++)
			{
				var player = SSF2API.getPlayers()[i];
				if(!player.getItem() && !player.inState(CState.DEAD) && !player.inState(CState.ENTRANCE) && !player.inState(CState.DISABLED) && !player.inState(CState.SCREEN_KO) && !player.inState(CState.STAR_KO) && !player.inState(CState.REVIVAL) && !player.inState(CState.INJURED) && !player.inState(CState.FLYING) && player.getCharacterStat("canHoldItems") && player.getLives() > 0)
					player.generateItem(holdableItems[SSF2API.randomInteger(0, holdableItems.length)], true, false, true);
			}
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				randomItem();
				
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 2000)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 2350)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2600)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 3000)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 3200)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 3500)
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
		public function setTimeMax(e:*):void
		{
			if(e.data.item.getItemStat("linkage_id") == "motionSensorBomb")
			{
				e.data.item.updateItemStats({time_max:300});
				e.data.item.resetTime();
			}else{
				e.data.item.updateItemStats({time_max:1});
				e.data.item.resetTime();
			}
		}
	}
}