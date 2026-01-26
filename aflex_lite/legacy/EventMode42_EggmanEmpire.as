package {
	import flash.display.MovieClip;

	public class EventMode42_EggmanEmpire extends SSF2MultiManMatch {
		public function EventMode42_EggmanEmpire(api: * ) {
			super(api);
			
			charArray = ["megaman", "chibirobo"];
		}

		public override function initMatch(gameSettings: Object = null): void {
			winCondition = SSF2MultiManMatch.TIMED;
			playerCharOverride = "tails";
			stageOverride = "centralhighway";
			musicOverride = "bgm_stormeagle";
			maxTime = 2;
			keepCameraAway = false;
			displayCountHUD = false;
			overrideTimer = true;

			difficultySettings = {
				level: 6,
				attackRatio: 0.6,
				damageRatio: 3.3
			};

			MAX_ENEMIES_ON_SCREEN = 3;
		}

		public override function matchSetup(initSettings: Object): Object {
			var game:Object = super.matchSetup(initSettings);
			
			SSF2API.queueResources(charArray);
			
			return game;
		}
		public override function update(): void {
			if (SSF2API.getGameTimer().getCurrentTime() <= 0) {
				//Set rank
				var rank = "F";
				if (bodyCount >= 60)
					rank = "S";
				else if (bodyCount >= 50)
					rank = "A";
				else if (bodyCount >= 40)
					rank = "B";
				else if (bodyCount >= 30)
					rank = "C";
				else if (bodyCount >= 20)
					rank = "D";
				else if (bodyCount >= 10)
					rank = "E";
				else
					rank = "F";

				matchData.rank = rank;
				matchData.success = true;
				matchData.stock = SSF2API.getPlayers()[0].getLives();
				matchData.score = bodyCount;
				matchData.scoreType = "kos";
				matchData.fps = SSF2API.getAverageFPS();
				SSF2API.endGame({
					success: true,
					immediate: false,
					slowMo: false
				});
			}
			
			super.update();
		}

		public override function generateNextEnemy():Object{
			return {
				characterID: charArray[SSF2API.randomInteger(0, charArray.length - 1)],
				isMultiman: false
			}
		}
	}
}