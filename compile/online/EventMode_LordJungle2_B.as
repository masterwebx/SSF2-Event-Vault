package {
	import flash.display.MovieClip;

	public class EventMode_LordJungle2_B extends SSF2MultiManMatch {
		public var eventinfo:Array = [
			{
				"id":"lordJungle2B",
                "classAPI":EventMode_LordJungle2_B,
                "name":"Lord of the Jungle 2 B-Side",
                "description":"Now he brought 64 of his closest friends! Can you survive the jungle?",
                "previewCharacter":"donkeykong",
				"previewCostume":0,
                "creator":"Mcleodgaming/Wex"
			}
		];
		public function EventMode_LordJungle2_B(api: * ) {
			super(api);
		}

		public override function initMatch(gameSettings: Object = null):void{
			SSF2API.print("initMatch called");
			winCondition = SSF2MultiManMatch.TIMED_KO_EVENT;
			playerCharOverride = "donkeykong";
			stageOverride = "junglehijinx";
			musicOverride = "bgm_gangplankgalleon";
			bodyCount = 64;
			spawnCount = 64;
			maxTime = 4;
			stockOverride = 2;
			charArray = ["donkeykong"];
			
			difficultySettings = {
				level: 9,
				attackRatio: 0.775,
				damageRatio: 2
			};
			
			MAX_ENEMIES_ON_SCREEN = 4;

			SSF2API.print("bodyCount=" + bodyCount + " spawnCount=" + spawnCount + " maxTime=" + maxTime);
			SSF2API.queueResources(charArray);
		}

		public override function matchSetup(initSettings: Object): Object {
			var game:Object = super.matchSetup(initSettings);
			
			// Set player 1 costume to 0
			if (game.playerSettings && game.playerSettings.length > 0) {
				game.playerSettings[0].costume = 0;				
				SSF2API.print("Set player costume to 0");
			}
			
			return game;
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
					success: false,
					slowMo: false,
					immediate: false
				});
			}
		}
		
		public override function update(): void {
			if (matchData.customData == null) {
				matchData.customData = {};
			}
			if (!matchData.customData.playerSetup) {
				// Lock player 1 size
				SSF2API.print("Setting up player...");
				SSF2API.getPlayer(1).setSizeStatus(1);
				SSF2API.getPlayer(1).lockSizeStatus(true);
				SSF2API.getPlayer(1).updateCharacterStats({"displayName":"LORD DK"});
				SSF2API.print("Player setup complete");
				matchData.customData.playerSetup = true;
			}			
			super.update();
		}
		
		public override function generateNextEnemy():Object{
			SSF2API.print("generateNextEnemy called");
			var charsize:int = -1;			
			var isMetal:Boolean = SSF2API.random() < 0.05;
			
			SSF2API.print("Generating enemy: size=" + charsize + " metal=" + isMetal);
			
			return {
				characterID: "donkeykong",
				isMultiman: true,
				size: charsize,
				metal: isMetal,
				costume: 2
			}
		}
		override protected function getMultimanCostumeData(_arg_1:String):Object
        {
            
            if (_arg_1 == "donkeykong")
            {
                return ({
                    "hue":-170,
                    "saturation":-20,
                    "brightness":10,
                    "redOffset":15,
                    "greenOffset":-15,
                    "blueOffset":20,
                    "blueMultiplier":0.55
                });
            };
            return ({
                "alphaMultiplier":0.9,
                "redMultiplier":-1,
                "greenMultiplier":-1,
                "blueMultiplier":-1,
                "redOffset":0xFF,
                "greenOffset":0xFF,
                "blueOffset":0xFF,
                "saturation":-100,
                "brightness":35,
                "contrast":10
            });
        }
	}
}
