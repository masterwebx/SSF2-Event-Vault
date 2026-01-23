package {
	import flash.display.MovieClip;

	public class EventMode13_ComboMaker extends SSF2CustomMatch {
		public const SUCCESS_DAMAGE = 50;

		public function onStateChange(e: *= null) {
			var hurtStateList: Array = [
				CState.CRASH_GETUP,
				CState.CRASH_LAND,
				CState.TECH_GROUND,
				CState.TECH_ROLL,
				CState.ROLL,
				CState.CAUGHT,
				CState.LAND,
				CState.INJURED,
				CState.FROZEN,
				CState.DIZZY,
				CState.STUNNED,
				CState.PITFALL,
				CState.EGG,
				CState.LAND,
				CState.FLYING
			];

			if (hurtStateList.indexOf(e.data.fromState) >= 0 && hurtStateList.indexOf(e.data.toState) < 0) {
				if (e.data.caller.getDamage() >= 50) {
					//Set rank
					var rank = "F";
					if(e.data.caller.getDamage() >= 62)
						rank = "S";
					else if(e.data.caller.getDamage() >= 56)
						rank = "A";
					else if(e.data.caller.getDamage() >= 54)
						rank = "B";
					else if(e.data.caller.getDamage() >= 53)
						rank = "C";
					else if(e.data.caller.getDamage() >= 52)
						rank = "D";
					else if(e.data.caller.getDamage() <= 51)
						rank = "E";
					else
						rank = "F";

					matchData.rank = rank;
					matchData.success = true;
					matchData.stock = SSF2API.getPlayer(1).getLives();
					matchData.score = e.data.caller.getDamage();
					matchData.scoreType = "points";
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({
						slowMo: false,
						success: true,
						immediate: false
					});
				} else {
					e.data.caller.setDamage(0);
				}
			}
		}

		public function EventMode13_ComboMaker(api: * ) {
			super(api);
		}
		public override function initialize(): void {
			var sandbag = SSF2API.getPlayer(2);
			sandbag.setSizeStatus(1);
			sandbag.lockSizeStatus(true);
			sandbag.setCPUForcedAction(CPUState.FORCE_DO_NOTHING);
			sandbag.toIdle();
			sandbag.addEventListener(SSF2Event.STATE_CHANGE, onStateChange, {
				persistent: true
			});
		}
		public override function matchSetup(initSettings: Object): Object {
			var game: Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};

			game.playerSettings.push({
				character: initSettings.playerSettings[0].character,
				costume: initSettings.playerSettings[0].costume,
				name: initSettings.playerSettings[0].name,
				lives: 999,
				human: true,
				team: -1
			});
			game.playerSettings.push({
				character: "sandbag",
				lives: 999,
				human: false,
				team: -1,
				level: 9
			});

			game.levelData.usingLives = false;
			game.levelData.usingTime = true;
			game.levelData.hazards = false;
			game.levelData.stage = "waitingroom";
			game.levelData.musicOverride = "bgm_menunesmix";
			game.levelData.time = 2;
			game.levelData.specialModes = SpecialMode.TURBO;
			var allItems: Array = SSF2API.getItemStatsList();
			for (var i: int = 0; i < allItems.length; i++) {
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			return game;
		}
		public override function update(): void {
			if (!SSF2API.isGameEnded()) {
				var players: Array = SSF2API.getPlayers();
				if (SSF2API.getGameTimer().getCurrentTime() <= 0) {
					matchData.success = false;
					SSF2API.endGame({
						slowMo: false,
						success: false,
						immediate: false
					});
				}
			}
		}
	}
}