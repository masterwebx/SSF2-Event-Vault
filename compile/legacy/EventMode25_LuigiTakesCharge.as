package {
	import flash.display.MovieClip;

	public class EventMode25_LuigiTakesCharge extends SSF2CustomMatch {
		public var bowserKOs: int;

		public function EventMode25_LuigiTakesCharge(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			bowserKOs = 0;

			SSF2API.getPlayer(1).setTeamID(1);
			SSF2API.getPlayer(2).setTeamID(1);
			SSF2API.getPlayer(2).setCPUForcedAction(CPUState.FORCE_WALK);
			SSF2API.getPlayer(2).addEventListener(SSF2Event.CHAR_KO_DEATH, function () {
				matchData.success = false;
				SSF2API.endGame({
					success: false,
					immediate: false
				});
			}, {
				persistent: true
			});
			SSF2API.getPlayer(3).setTeamID(2);
			SSF2API.getPlayer(3).addEventListener(SSF2Event.CHAR_KO_DEATH, function () {
				bowserKOs++;
				SSF2API.print(bowserKOs.toString());
			}, {
				persistent: true
			})
		}
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: "luigi",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({
				character: "peach",
				lives: 1,
				human: false,
				level: 9,
				team: -1
			});
			game.playerSettings.push({
				character: "bowser",
				lives: 2,
				human: false,
				level: 7,
				team: -1
			});

			game.levelData.usingLives = false;
			game.levelData.usingTime = true;
			game.levelData.countdown = true;
			game.levelData.time = 2;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.teamDamage = false;
			game.levelData.stage = "bowserscastle";
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
				if (SSF2API.getGameTimer().getCurrentTime() <= 0) {

					//Set rank
					var rank = "F";
					if (bowserKOs >= 6)
						rank = "S";
					else if (bowserKOs >= 5)
						rank = "A";
					else if (bowserKOs >= 4)
						rank = "B";
					else if (bowserKOs >= 3)
						rank = "C";
					else if (bowserKOs >= 2)
						rank = "D";
					else if (bowserKOs >= 1)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = bowserKOs;
					matchData.scoreType = "kos";
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