package
{
	import flash.display.MovieClip;
	
	public class EventMode15_SwornToTheSword extends SSF2MultiManMatch
	{
		public function EventMode15_SwornToTheSword(api:*)
		{
			super(api);
		}
		
		private var charSpawnArray = ["marth", "link", "ichigo"];
		
		public override function initMatch(gameSettings: Object = null):void{
			winCondition = SSF2MultiManMatch.KO_BASED;
			playerCharOverride = "lloyd";
			stageOverride = "castlesiege";
			musicOverride = "bgm_fireemblemtheme";
			bodyCount = 3;
			spawnCount = 3;
			MAX_ENEMIES_ON_SCREEN = 1;
			charArray = ["link", "marth", "ichigo"];
			keepCameraAway = false;
			displayCountHUD = false;
			
			difficultySettings = {
				level: 6,
				attackRatio: 0.9,
				damageRatio: 1.3
			};
			

			SSF2API.queueResources(charArray.concat("bgm_darkworld", "bgm_ontheprecipiceofdefeat"));
		}
		
		public override function onSuccess(): void {
			//Set rank
			var rank = "F";
			if (SSF2API.getElapsedFrames() <= 1800)
				rank = "S";
			else if (SSF2API.getElapsedFrames() <= 2350)
				rank = "A";
			else if (SSF2API.getElapsedFrames() <= 2750)
				rank = "B";
			else if (SSF2API.getElapsedFrames() <= 3000)
				rank = "C";
			else if (SSF2API.getElapsedFrames() <= 3400)
				rank = "D";
			else if (SSF2API.getElapsedFrames() <= 3850)
				rank = "E";
			else
				rank = "F";

			matchData.rank = rank;
			matchData.success = true;
			matchData.stock = SSF2API.getPlayers()[0].getLives();
			matchData.score = SSF2API.getElapsedFrames();
			matchData.scoreType = "time";
			matchData.fps = SSF2API.getAverageFPS();
			SSF2API.endGame({
				success: true,
				immediate: false,
				slowMo: false
			});
		}
		
		public override function generateNextEnemy():Object{
			var spawnedChar = charSpawnArray.shift();
			if(spawnedChar == "link"){
				SSF2API.playMusic("bgm_darkworld", 11058);
			}
			else if(spawnedChar == "ichigo"){
				SSF2API.playMusic("bgm_ontheprecipiceofdefeat", 12541);
			}
			return {
				characterID: spawnedChar,
				isMultiman: false
			}
		}
	}
}