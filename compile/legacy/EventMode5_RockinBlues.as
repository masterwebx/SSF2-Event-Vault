package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class EventMode5_RockinBlues extends SSF2CustomMatch
	{
		var m_assist = null;
		public function EventMode5_RockinBlues(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			generateProtoman();
			m_assist.forceAttack("entrance");
		}
		public function generateProtoman():void
		{
			if(m_assist && !m_assist.inState(EState.DEAD))
				m_assist.destroy();
			
			m_assist = SSF2API.spawnEnemy(Protoman);
			//m_assist.forceAttack("idle");
			m_assist.setX(SSF2API.getPlayer(1).getX());
			m_assist.setY(SSF2API.getPlayer(1).getY());
			m_assist.setOwner(SSF2API.getPlayer(1));
		}
		public function generateProtomanJank():void
		{
			m_assist = SSF2API.spawnEnemy(SSF2API.getRandomAssist()); //this needs to be protoman only at some point
			
			while(m_assist.getEnemyStat("linkage_id") != "protoman"){
				m_assist.destroy();
				m_assist = SSF2API.spawnEnemy(SSF2API.getRandomAssist());
				
				if(m_assist.getEnemyStat("linkage_id") == "protoman")
					break;
			}
			
			if(m_assist.getEnemyStat("linkage_id") == "protoman")
			{
				m_assist.m_totalTimer.reset();
				m_assist.setX(SSF2API.getPlayer(1).getX());
				m_assist.setY(SSF2API.getPlayer(1).getY());
				m_assist.setOwner(SSF2API.getPlayer(1));
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
				character: "megaman",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "megaman",
				lives: 1,
				human: false,
				team: 2,
				level: 5,
				costume: 1
			});
			game.playerSettings.push({ 
				character: "jigglypuff",
				lives: 1,
				human: false,
				team: 2,
				level: 5,
				costume: 6
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.stage = "skullfortress";
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

				if(m_assist.inState(EState.DEAD) && m_assist.getEnemyStat("linkage_id") == "protoman" || SSF2Utils.getDistance(new Point(m_assist.getX(),m_assist.getY()), new Point(players[0].getX(), players[0].getY())) > 600)
					generateProtoman();

				if(m_assist.getEnemyStat("linkage_id") == "protoman")
					m_assist.m_totalTimer.reset();

				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({success:false, immediate: false});
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0)
				{
					//Set rank
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 400)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 800)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 2000)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2500)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 3000)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 4200)
						rank = "E";
					else
						rank = "F";
					
					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({immediate: false});
				}
			}
		}
	}
}