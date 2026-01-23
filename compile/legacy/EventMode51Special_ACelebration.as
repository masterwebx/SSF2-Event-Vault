package {
	import flash.display.MovieClip;
	import flash.geom.Point;

	public class EventMode51Special_ACelebration extends SSF2CustomMatch {
		private var enemy;
		private var enemy2;
		private var hpModifier = 500;
		private var attackDelayModifier = -1;

		public function EventMode51Special_ACelebration(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			enemy = SSF2API.spawnEnemy("MasterHand");
			enemy.setHomePosition(new Point(200, 40));
			enemy.setHurtInterrupt(checkMH);
			enemy.setX(200);
			enemy.setY(40);

			enemy2 = SSF2API.spawnEnemy("MasterHand");
			enemy2.setHurtInterrupt(checkMH);
			enemy2.setHomePosition(new Point(-200, 40));
			enemy2.faceLeft();
			enemy2.setX(-200);
			enemy2.setY(40);

			if (hpModifier != 0) {
				enemy.setHP(hpModifier);
				enemy2.setHP(hpModifier);
			}

			if (attackDelayModifier > -1) {
				enemy.setAttackDelay(attackDelayModifier);
				enemy2.setAttackDelay(attackDelayModifier);
			}

			SSF2API.getPlayer(1).setX(0);
			SSF2API.getPlayer(1).faceRight();
		}
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: initSettings.playerSettings[0].character,
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true
			});

			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "finaldestination";
			game.levelData.musicOverride = "bgm_menu";
			
			var allItems: Array = SSF2API.getItemStatsList();
			for (var i: int = 0; i < allItems.length; i++) {
				game.items.items[allItems[i].statsName] = false;
			}
			delete game.items.items.firework;
			game.items.frequency = ItemSettings.FREQUENCY_MAX;
			return game;
		}
		public function checkMH(e:*):Boolean
		{
			if(e.target.getType() == "SSF2Enemy"){
				if(e.target.getEnemyStat("linkage_id") == "masterhand_enemy"){
					return true
				}else{
					return false
				}
			}else{
				return false
			}
		}
		public override function update(): void {
			if (!SSF2API.isGameEnded()) 
			{
				var players: Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0) {
					matchData.success = false;
					SSF2API.endGame({success: false,immediate: false});
				} else if ((enemy.isDisposed() || enemy.inState(EState.DEAD) || !enemy) && (enemy2.isDisposed() || enemy2.inState(EState.DEAD) || !enemy2)) {
					var rank = "F";
					if (SSF2API.getElapsedFrames() <= 1715)
						rank = "S";
					else if (SSF2API.getElapsedFrames() <= 1880)
						rank = "A";
					else if (SSF2API.getElapsedFrames() <= 2060)
						rank = "B";
					else if (SSF2API.getElapsedFrames() <= 2190)
						rank = "C";
					else if (SSF2API.getElapsedFrames() <= 2400)
						rank = "D";
					else if (SSF2API.getElapsedFrames() <= 2900)
						rank = "E";
					else
						rank = "F";

					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";

					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({success: true,immediate: false});
				}
			}
		}
	}
}