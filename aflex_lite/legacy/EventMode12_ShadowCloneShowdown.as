package {
	import flash.display.MovieClip;

	public class EventMode12_ShadowCloneShowdown extends SSF2CustomMatch {
		public var realNaruto = null;

		public function EventMode12_ShadowCloneShowdown(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			var randyNum = SSF2API.randomInteger(2, SSF2API.getPlayers().length);
			realNaruto = SSF2API.getPlayer(randyNum);
			SSF2API.print("Will the real Naruto please stand up?");
			SSF2API.print("(Naruto " + randyNum + " stood up.)");

			for (var i: int = 2; i <= 4; i++) {
				//can be players 2, 3, 4
				var player = SSF2API.getPlayer(i);
				if (i != randyNum) {
					player.updateCharacterStats({
						damageRatio: 1.5,
						canUseSpecials: false,
						canThrow: false,
						canTaunt: false
					});
					// Disable Jab & Forward Smash
					disableMoves();
					player.addEventListener(SSF2Event.CHAR_KO_DEATH, disableMoves, { persistent: true })					
				} else {
					player.addEventListener(SSF2Event.CHAR_KO_DEATH, function () {
						//Set rank
						var rank = "F";
						if (SSF2API.getElapsedFrames() <= 600)
							rank = "S";
						else if (SSF2API.getElapsedFrames() <= 900)
							rank = "A";
						else if (SSF2API.getElapsedFrames() <= 1300)
							rank = "B";
						else if (SSF2API.getElapsedFrames() <= 1750)
							rank = "C";
						else if (SSF2API.getElapsedFrames() <= 2000)
							rank = "D";
						else if (SSF2API.getElapsedFrames() <= 2500)
							rank = "E";
						else
							rank = "F";

						matchData.rank = rank;
						matchData.success = true;
						matchData.stock = SSF2API.getPlayer(1).getLives();
						matchData.score = SSF2API.getElapsedFrames();
						matchData.scoreType = "time";
						matchData.fps = SSF2API.getAverageFPS();
						SSF2API.endGame({
							success: true,
							immediate: false
						});
					}, {
						persistent: true
					})
				}
				player.setTeamID(2);
			}

		}

		// idk why using the player var in initialize() doesn't work for this
		function disableMoves(e:*=null):void {
			for (var i: int = 2; i <= 4; i++) {
				if (SSF2API.getPlayer(i) != realNaruto) {
					SSF2API.getPlayer(i).setAttackEnabled(false, "a");
					SSF2API.getPlayer(i).setAttackEnabled(false, "a_forwardsmash");
				}
			}
		}		
		
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: "naruto",
				costume: 3,
				name: initSettings.playerSettings[0].name,
				lives: 2,
				human: true,
				team: -1
			});
			game.playerSettings.push({
				character: "naruto",
				lives: 1,
				human: false,
				team: -1,
				level: 5
			});
			game.playerSettings.push({
				character: "naruto",
				lives: 1,
				human: false,
				team: -1,
				level: 5
			});
			game.playerSettings.push({
				character: "naruto",
				lives: 1,
				human: false,
				team: -1,
				level: 5
			});

			game.levelData.usingLives = false;
			game.levelData.usingTime = true;
			game.levelData.teamDamage = false;
			game.levelData.lives = 1;
			game.levelData.hazards = true;
			game.levelData.stage = "finalvalley";
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
				if (players[0].getLives() <= 0) {
					matchData.success = false;
					SSF2API.endGame({
						success: false,
						immediate: false
					});
				} else if (realNaruto.getLives() <= 0) {
					//Set rank
					var rank = "F";
					if (SSF2API.getElapsedFrames() <= 600)
						rank = "S";
					else if (SSF2API.getElapsedFrames() <= 900)
						rank = "A";
					else if (SSF2API.getElapsedFrames() <= 1300)
						rank = "B";
					else if (SSF2API.getElapsedFrames() <= 1750)
						rank = "C";
					else if (SSF2API.getElapsedFrames() <= 2000)
						rank = "D";
					else if (SSF2API.getElapsedFrames() <= 2500)
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