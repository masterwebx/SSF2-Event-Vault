package {
	import flash.display.MovieClip;
	import flash.geom.Point;

	public class EventMode41_BobombBattlefield extends SSF2CustomMatch {
		private var m_bombTimer;
		private var randomPosList: Array = [new Point(0, -300), new Point(50, -300), new Point(100, -300), new Point(150, -300), new Point(200, -300), new Point(250, -300), new Point(350, -300), new Point(400, -300), new Point(450, -300), new Point(500, -300)];

		public function EventMode41_BobombBattlefield(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			m_bombTimer = new FrameTimer(2 * 30);
			SSF2API.setCamStageFocus(int.MAX_VALUE);
			//SSF2API.getPlayer(2).setHurtInterrupt(processHurt);
		}
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: "ichigo",
				name: initSettings.playerSettings[0].name,
				costume: 0,
				lives: 2,
				human: true,
				team: 1
			});
			game.playerSettings.push({
				character: "peach",
				lives: 2,
				human: false,
				team: 3,
				level: 9
			});

			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "battlefield";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public function checkBombTimer(): void {
			m_bombTimer.tick();

			if (m_bombTimer.completed) {
				var genPos = randomPoint();
				var bomb = SSF2API.generateItem("bobomb", genPos.x, genPos.y, true);
				bomb.setScale(1.2, 1.2);
				bomb.toToss();
				bomb.addToCamera();
				m_bombTimer.reset();
			}
		}
		public function randomPoint(): Point {
			return randomPosList[Math.floor(SSF2API.random() * randomPosList.length)];
		}
		public override function update(): void {
			if (!SSF2API.isGameEnded()) {
				checkBombTimer();

				var players: Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0) {
					matchData.success = false;
					SSF2API.endGame({
						slowMo: false,
						success: false,
						immediate: false
					});
				} else if (players[1].getLives() <= 0) {
					var rank = "F";
					if (players[0].getLives() == 2 && players[0].getDamage() == 0)
						rank = "S";
					else if (players[0].getLives() == 2 && players[0].getDamage() <= 50)
						rank = "A";
					else if (players[0].getLives() == 2 && players[0].getDamage() <= 100)
						rank = "B";
					else if ((players[0].getLives() == 2 && players[0].getDamage() > 100) || (players[0].getLives() == 1 && players[0].getDamage() == 0))
						rank = "C";
					else if (players[0].getLives() == 1 && players[0].getDamage() <= 50)
						rank = "D";
					else if (players[0].getLives() == 1 && players[0].getDamage() <= 100)
						rank = "E";
					else
						rank = "F";

					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = 200 - (players[0].getLives() * 100 - players[0].getDamage()) > 0 ? 200 - (players[0].getLives() * 100 - players[0].getDamage()) : 0;
					matchData.scoreType = "damage";

					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({
						slowMo: false,
						success: true,
						immediate: false
					});
				}
			}
		}
	}
}