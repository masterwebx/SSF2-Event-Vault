package
{
	import flash.display.MovieClip;
	
	public class EventMode37_DownWithMario extends SSF2MultiManMatch
	{
		private var charSpawnArray = ['donkeykong', 'bowser', 'wario'];
		
		public function EventMode37_DownWithMario(api:*)
		{
			super(api);
			
			playerCharOverride = "mario";
			stageOverride = "mushroomkingdom3";
			musicOverride = "bgm_brambleblast";
			winCondition = SSF2MultiManMatch.TIMED_KO_EVENT;
			bodyCount = 3;
			spawnCount = 3;
			MAX_ENEMIES_ON_SCREEN = 1;
			maxTime = 2.5;
			stockOverride = 1;
			keepCameraAway = false;
			displayCountHUD = true;
			charArray = charSpawnArray;
			
			difficultySettings = {
				level: 9,
				attackRatio: 1.2,
				damageRatio: 0.8
			};
		}
		public override function initMatch(gameSettings: Object = null): void {
	
			SSF2API.queueResources(charArray.concat("bgm_bowsersrampage", "bgm_wariowareinc"));
		}		
		
		public override function generateNextEnemy():Object{
			var spawnedChar = charSpawnArray.shift();
			if(spawnedChar == "bowser"){
				SSF2API.playMusic("bgm_bowsersrampage", 103530);
			}
			else if(spawnedChar == "wario"){
				SSF2API.playMusic("bgm_wariowareinc", 5043);
			}
			return {
				characterID: spawnedChar,
				isMultiman: false
			}
		}

		public override function onPlayerKO(e: * = null) {
			if (e.data.caller.getLives() <= 0) {
				matchData.success = false;
				SSF2API.endGame({success: false, immediate: false });
			}
		}

		public override function onSuccess(): void {
			//Set rank
			var rank = "F";
			
			if(SSF2API.getElapsedFrames() <= 1800)
				rank = "S";
			else if(SSF2API.getElapsedFrames() <= 2250)
				rank = "A";
			else if(SSF2API.getElapsedFrames() <= 2850)
				rank = "B";
			else if(SSF2API.getElapsedFrames() <= 3150)
				rank = "C";
			else if(SSF2API.getElapsedFrames() <= 3600)
				rank = "D";
			else if(SSF2API.getElapsedFrames() <= 4050)
				rank = "E";
			else
				rank = "F";
			
			var players: Array = SSF2API.getPlayers();
			matchData.rank = rank;
			matchData.success = true;
			matchData.stock = players[0].getLives();
			matchData.score = SSF2API.getElapsedFrames();
			matchData.scoreType = "time";
			matchData.fps = SSF2API.getAverageFPS();
			SSF2API.endGame({success: true, immediate: false });
		}
	}
}