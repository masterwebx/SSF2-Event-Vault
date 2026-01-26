package {
	import flash.display.MovieClip;

	public class EventMode14_InTheBallpark extends SSF2CustomMatch {
		public function EventMode14_InTheBallpark(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			SSF2API.getPlayer(1).generateItem("homerunbat", true, false, true);
			for (var i: int = 2; i <= 4; i++) {
				var player = SSF2API.getPlayer(i);
				player.setLivesEnabled(false);
				player.addEventListener(SSF2Event.CHAR_KO_DEATH, checkBat, {
					persistent: true
				});
				player.setCPUForcedAction(CPUState.FORCE_WALK);
			}
		}
		public function checkBat(e: * ): void {
			var player = e.data.caller;
			var hurtStats:Object = player.getLastHurtAttackBoxStats();
			var foe = hurtStats ? hurtStats.owner : null;

			if (foe && foe.getType() == "SSF2Item" && foe.getItemStat("linkage_id") == "homerunbat") {
				player.removeEventListener(SSF2Event.CHAR_KO_DEATH, checkBat);
				player.setLivesEnabled(true);
				player.setLives(0);
				player.setStandby(true);
			} else {
				player.setLivesEnabled(false);
			}
		}
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: "ness",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({
				character: "pacman",
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			game.playerSettings.push({
				character: "jigglypuff",
				lives: 1,
				human: false,
				team: -1,
				level: 6
			});
			game.playerSettings.push({
				character: "kirby",
				lives: 1,
				human: false,
				team: -1,
				level: 8
			});

			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.teamDamage = false;
			game.levelData.stage = "saturnvalley";

			var allItems: Array = SSF2API.getItemStatsList();
			for (var i: int = 0; i < allItems.length; i++) {
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public override function update(): void {
			if (!SSF2API.isGameEnded()) {
				var players: Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || (!players[0].getItem() && !players[0].inState(CState.DEAD))) {
					matchData.success = false;
					SSF2API.endGame({
						success: false,
						immediate: false
					});
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0) {
					//Set rank
					var rank = "F";
					if (SSF2API.getElapsedFrames() <= 450)
						rank = "S";
					else if (SSF2API.getElapsedFrames() <= 700)
						rank = "A";
					else if (SSF2API.getElapsedFrames() <= 950)
						rank = "B";
					else if (SSF2API.getElapsedFrames() <= 1150)
						rank = "C";
					else if (SSF2API.getElapsedFrames() <= 1400)
						rank = "D";
					else if (SSF2API.getElapsedFrames() <= 1775)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({
						success: true,
						immediate: false
					});
				}
			}
		}
	}
}