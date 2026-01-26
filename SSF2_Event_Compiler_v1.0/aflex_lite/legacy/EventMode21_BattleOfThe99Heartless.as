package {
	import flash.display.MovieClip;

	public class EventMode21_BattleOfThe99Heartless extends SSF2MultiManMatch {
		public function EventMode21_BattleOfThe99Heartless(api: * ) {
			super(api);
		}

		public override function initMatch(gameSettings: Object = null):void{
			winCondition = SSF2MultiManMatch.TIMED_KO_EVENT;
			playerCharOverride = "sora";
			stageOverride = "twilighttown";
			musicOverride = "bgm_rowdyrumble";
			bodyCount = 99;
			spawnCount = 99;
			maxTime = 5;
			stockOverride = 2;
			charArray = ["gameandwatch"];
			
			difficultySettings = {
				level: 5,
				attackRatio: 0.775,
				damageRatio: 3.5
			};
			
			MAX_ENEMIES_ON_SCREEN = 4;

			SSF2API.queueResources(charArray);
		}

		public override function onSuccess(): void {
			//Set rank
			var rank = "F";
			if (SSF2API.getElapsedFrames() <= 3350)
				rank = "S";
			else if (SSF2API.getElapsedFrames() <= 3575)
				rank = "A";
			else if (SSF2API.getElapsedFrames() <= 3950)
				rank = "B";
			else if (SSF2API.getElapsedFrames() <= 4750)
				rank = "C";
			else if (SSF2API.getElapsedFrames() <= 5300)
				rank = "D";
			else if (SSF2API.getElapsedFrames() <= 5800)
				rank = "E";
			else
				rank = "F";

			matchData.rank = rank;
			matchData.success = true;
			matchData.stock = SSF2API.getPlayers()[0].getLives();
			matchData.score = SSF2API.getElapsedFrames();
			matchData.scoreType = "time";
			matchData.fps = SSF2API.getAverageFPS();
			SSF2API.triggerUnlock(Unlockable.THE_WORLD_THAT_NEVER_WAS);
			SSF2API.endGame({
				success: true,
				immediate: false,
				slowMo: false
			});
		}
		public override function onPlayerKO(e: * = null) {
			if (e.data.caller.getLives() <= 0) {
				matchData.success = false;
				SSF2API.endGame({
					slowMo: false,
					immediate: false
				});
			}
		}
		
		public override function generateNextEnemy():Object{
			var charsize:int = 0;
			var rng:Number = SSF2API.random();
			if(rng < 0.1){
				charsize = -1;
			}
			else if(rng > 0.9){
				charsize = 1;
			}
			
			var isMetal:Boolean = SSF2API.random() < 0.05;
			if(isMetal && charsize < 0){
				charsize = 0;
			}
			
			return {
				characterID: "gameandwatch",
				isMultiman: false,
				size: charsize,
				metal: isMetal
			}
		}
	}
}