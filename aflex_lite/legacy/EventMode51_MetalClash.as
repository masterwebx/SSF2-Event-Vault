package {

	import flash.filters.*;

	public class EventMode51_MetalClash extends SSF2CustomMatch {

		public function EventMode51_MetalClash(api: * ) {
			super(api);
		}

		public override function initialize(): void {
			var players: Array = SSF2API.getPlayers();

			players[1].setMetalStatus(true);
			players[1].endAttack();
			players[2].setMetalStatus(true);
			players[2].endAttack();
			players[3].setMetalStatus(true);
			players[3].setScale(2,2);
			players[3].endAttack();
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
				human: true,
				team: 2
			});
			game.playerSettings.push({
				character: "donkeykong",
				lives: 1,
				human: false,
				team: 1,
				level: 9
			});
			game.playerSettings.push({
				character: "bowser",
				lives: 1,
				human: false,
				team: 1,
				level: 9
			});
			game.playerSettings.push({
				character: "megaman",
				lives: 1,
				human: false,
				team: 1,
				level: 8
			});

			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.lives = 1;
			game.levelData.time = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "metalcavern";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			return game;
		}
		public override function update(): void {
			if (!SSF2API.isGameEnded()) {
				var players: Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0 || SSF2API.getGameTimer().getCurrentTime() <= 0) {
					matchData.success = false;
					SSF2API.endGame({
						slowMo: false,
						success: false,
						immediate: false
					});
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0) {
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 650)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 870)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1000)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 1150)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1270)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1375)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					
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