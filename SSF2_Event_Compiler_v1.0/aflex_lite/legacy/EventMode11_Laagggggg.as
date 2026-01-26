package
{
	import flash.display.MovieClip;
	
	public class EventMode11_Laagggggg extends SSF2CustomMatch
	{
		private var m_lagStartupTimer;
		private var m_lagDurationTimer;
		private var lagging = false;
		
		public function EventMode11_Laagggggg(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			m_lagStartupTimer = new FrameTimer(5*30);
			m_lagDurationTimer = new FrameTimer(10);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "zamus",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: "captainfalcon",
				name: "Ace",
				lives: 2,
				human: false,
				team: -1,
				level: 8
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 8;
			game.levelData.lives = 2;
			game.levelData.hazards = false;
			game.levelData.stage = "smashville";
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
			if(!lagging)
			{
				m_lagStartupTimer.tick();
				if (m_lagStartupTimer.completed)
				{
					if(SSF2API.getPlayer(1).getLives() == 1 || SSF2API.getPlayer(2).getLives() == 1)
						SSF2API.setFrameRate(2);
					else
						SSF2API.setFrameRate(10);
					lagging = true;
					m_lagStartupTimer.reset();
				}
			}else{
				m_lagDurationTimer.tick();
				if (m_lagDurationTimer.completed)
				{
					SSF2API.setFrameRate(30);
					lagging = false;
					m_lagDurationTimer.reset();
				}
			}
			
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 700)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1200)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1850)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2000)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2200)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2550)
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