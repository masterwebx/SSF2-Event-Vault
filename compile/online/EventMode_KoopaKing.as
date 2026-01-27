package
{
	import flash.display.MovieClip;
	
	public class EventMode_KoopaKing extends SSF2MultiManMatch
	{
		public var eventinfo:Array = [
			{
				"id":"koopaKing",
                "classAPI":EventMode_KoopaKing,
                "name":"Rise of King Koopa!",
                "description":"Everyone is challenging the king of koopas! Defeat all your foes as quickly as you can!",
                "previewCharacter":"bowser",
				"previewCostume":-1,
                "creator":"MasterWex"
			}
		];
		public function EventMode_KoopaKing(api:*)
		{
			super(api);
		}
		
		private var charSpawnArray = ["mario", "luigi", "peach", "yoshi","wario","waluigi"];

		 

		public function bowserPalette(param1:int = 0) : Object
        {
			var _loc2_:Array = new Array();
				 _loc2_.push({
            "base":true,
            "info": "All Stars Bowser by Felix",
			"paletteSwap": {
				"colors": [4294147653, 4293479198, 4288489741, 4284356621, 4281929480, 4280420868, 4283236096, 4281974528, 4280712960, 4279451392, 4278255615, 4278239167, 4278222719, 4294961535, 4293245696, 4286539776, 4294302871, 4293704826, 4290350682, 4287719750, 4283382820, 4289855743, 4286709951, 4283891839, 4282515552, 4281008191, 4283275263, 4278217471, 4278210495, 4278203775, 4283506220, 4281340186, 4294040739, 4291016826, 4289304931, 4286933573, 4283449385, 4294950874, 4294934454, 4294918034, 4290707538, 4285105976, 4283591212, 4280630035, 4279640332, 4294901980, 4292542654, 4290707621, 4286513262, 4282318903, 4294959245, 4294954584, 4294751784, 4292185893, 4288898839, 4285351953, 4283380748, 4281672199, 4284504665, 4282070581, 4280820514, 4278190080, 4286578629, 4284070027, 4281957725, 4279841575, 4294938441, 4291588667, 4288239148, 4284889373, 4281539598, 4294901760, 4290707456, 4286513152, 4282318848, 4279763201, 4278203775, 4279841575, 4294040739, 4291016826, 4286513152, 4283449385, 4279451392, 4281957725, 4278255615, 4284070027, 4290707538, 4290707538, 4281957725, 4280712960],
				"replacements": [4294668861, 4294064917, 4288879878, 4284616969, 4281929480, 4280485891, 4284008229, 4282223130, 4279390976, 4278923266, 4294967295, 4292269782, 4288453788, 4280359704, 4279570705, 4279830529, 4294946891, 4294938392, 4293029144, 4289547020, 4283705095, 4294638330, 4289967291, 4285295995, 4283058772, 4281545529, 4294638330, 4292664803, 4289967291, 4285295995, 4283506220, 4281340186, 4294638309, 4293583545, 4291346075, 4288383345, 4284437830, 4290441127, 4284008229, 4282223130, 4278923266, 4284008229, 4282223130, 4279390976, 4278923266, 4294967273, 4294306260, 4292464318, 4287135607, 4282927170, 4294951797, 4294946891, 4294938392, 4293029144, 4289547020, 4285351953, 4283705095, 4281672199, 4284504665, 4287728779, 4285557610, 4278190080, 4284504665, 4282070581, 4280820514, 4278190080, 4293909647, 4291474536, 4289301324, 4286602549, 4282987031, 4293258751, 4287930287, 4285362294, 4281216563, 4279763201, 4285295995, 4278190080, 4294638309, 4293583545, 4285362294, 4284437830, 4278923266, 4280820514, 4294967295, 4282070581, 4278923266, 4278923266, 4280820514, 4279390976]
			},
			"paletteSwapPA": {
				"colors": [4294147653, 4293479198, 4288489741, 4284356621, 4281929480, 4280420868, 4283236096, 4281974528, 4280712960, 4279451392, 4278255615, 4278239167, 4278222719, 4294961535, 4293245696, 4286539776, 4294302871, 4293704826, 4290350682, 4287719750, 4283382820, 4289855743, 4286709951, 4283891839, 4282515552, 4281008191, 4283275263, 4278217471, 4278210495, 4278203775, 4283506220, 4281340186, 4294040739, 4291016826, 4289304931, 4286933573, 4283449385, 4294950874, 4294934454, 4294918034, 4290707538, 4285105976, 4283591212, 4280630035, 4279640332, 4294901980, 4292542654, 4290707621, 4286513262, 4282318903, 4294959245, 4294954584, 4294751784, 4292185893, 4288898839, 4285351953, 4283380748, 4281672199, 4284504665, 4282070581, 4280820514, 4278190080, 4286578629, 4284070027, 4281957725, 4279841575, 4294938441, 4291588667, 4288239148, 4284889373, 4281539598, 4294901760, 4290707456, 4286513152, 4282318848],
				"replacements": [4294668861, 4294064917, 4288879878, 4284616969, 4281929480, 4280485891, 4284008229, 4282223130, 4279390976, 4278923266, 4294967295, 4292269782, 4288453788, 4280359704, 4279570705, 4279830529, 4294946891, 4294938392, 4293029144, 4289547020, 4283705095, 4294638330, 4289967291, 4285295995, 4283058772, 4281545529, 4294638330, 4292664803, 4289967291, 4285295995, 4283506220, 4281340186, 4294638309, 4293583545, 4291346075, 4288383345, 4284437830, 4290441127, 4284008229, 4282223130, 4278923266, 4284008229, 4282223130, 4279390976, 4278923266, 4294967273, 4294306260, 4292464318, 4287135607, 4282927170, 4294951797, 4294946891, 4294938392, 4293029144, 4289547020, 4285351953, 4283705095, 4281672199, 4284504665, 4287728779, 4285557610, 4278190080, 4284504665, 4282070581, 4280820514, 4278190080, 4293909647, 4291474536, 4289301324, 4286602549, 4282987031, 4293258751, 4287930287, 4285362294, 4281216563]
			}
         });
         return _loc2_[param1];
		}
		
		public override function initMatch(gameSettings: Object = null):void{
			
			winCondition = SSF2MultiManMatch.KO_BASED;
			playerCharOverride = "bowser";
			stageOverride = "bowserscastle";
			musicOverride = "bgm_supermariobrostheme";
			bodyCount = 6;
			spawnCount = 6;
			MAX_ENEMIES_ON_SCREEN = 1;
			charArray = ["mario", "luigi", "peach", "yoshi","wario","waluigi"];
			keepCameraAway = false;
			displayCountHUD = true;
			
			difficultySettings = {
				level: 6,
				attackRatio: 0.9,
				damageRatio: 1.3
			};
			

			SSF2API.queueResources(charArray.concat("bgm_athletictheme","bgm_ashleystheme","bgm_smb2overworld","bgm_bobombbattlefield"));
		}

		override public function initialize():void
        {
			super.initialize();
			SSF2API.getPlayer(1).updateCharacterStats({
				"displayName":"KING KOOPA"
			});
			SSF2Utils.replacePalette(SSF2API.getPlayer(1).getHealthBox().getChildByName("charHead") as MovieClip,this.bowserPalette(0).paletteSwapPA,2);			
			SSF2API.getPlayer(1).setPaletteSwapData(this.bowserPalette());		
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
			if(spawnedChar == "peach"){
				SSF2API.playMusic("bgm_bobombbattlefield", 12541);
			}
			else if(spawnedChar == "yoshi"){
				SSF2API.playMusic("bgm_athletictheme", 12541);
			}
			else if(spawnedChar == "wario"){
				SSF2API.playMusic("bgm_ashleystheme", 12541);
			}
			else if(spawnedChar == "waluigi"){
				SSF2API.playMusic("bgm_smb2overworld", 12541);
			}
			return {
				characterID: spawnedChar,
				isMultiman: false
			}
		}
	}
}