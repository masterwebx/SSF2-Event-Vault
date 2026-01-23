package
{
	import flash.display.MovieClip;
	
	public class EventMode22_RoleReversal extends SSF2CustomMatch
	{
		public function EventMode22_RoleReversal(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.getPlayer(1).grantFinalSmash(); 
			SSF2API.getPlayer(2).setX(697);
			SSF2API.getPlayer(2).setY(275);
			
			if(SSF2API.getPlayer(2).getCharacterStat("max_xSpeed") >= 4)
				SSF2API.getPlayer(2).updateCharacterStats({max_xSpeed:4});
			SSF2API.getPlayer(2).setCPUForcedAction(CPUState.FORCE_RUN);
			SSF2API.getPlayer(2).faceRight();
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "sandbag",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 1,
				human: true,
				team: -1
			});
			game.playerSettings.push({ 
				character: SSF2API.getRandomCharacterID(),
				lives: 1,
				human: false,
				team: -1,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.time = 1;
			game.levelData.lives = 1;
			game.levelData.hazards = false;
			game.levelData.stage = "homeruncontest";
			game.levelData.musicOverride = "bgm_waitingroom";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			return game;
		}
		private function handleLoopingBackground():void
		{
			// Figure out looping background calculations
			var loopMC1:MovieClip = MovieClip(SSF2API.getStage().getBackground().getChildByName("hrc_groundloop1"));
			var loopMC2:MovieClip = MovieClip(SSF2API.getStage().getBackground().getChildByName("hrc_groundloop2"));
			//Get the camera's X position relative to the background MC
			var cameraX:Number = SSF2API.getCamera().getTopLeftPoint().x - SSF2API.getStage().getBackground().x;
			//Once camera goes beyond length of initial ground loop's starting position
			if (cameraX > 2220)
			{
				
				//If the right side of the camera + 600 px buffer goes beyond the camera bounds
				if (cameraX + SSF2API.getCamera().getMC().width + 600 > SSF2API.getStage().getCameraBounds().x + SSF2API.getStage().getCameraBounds().width + SSF2API.getStage().getMidground().x - SSF2API.getStage().getBackground().x)
				{
					//Increase the width of the camera boundary
					SSF2API.getStage().getCameraBounds().width += 2000;
				}
				
				//Now we must position the background loop based on the relative position of the camera
				//(Note: Calculation figures out how many times farther the camera is to the right of original background position, and shifts it accrordingly
				var loopWidth:Number = 2280;
				var originalLoopX:Number = 2220;
				var offset:Number = 500;
				loopMC1.x = originalLoopX + loopWidth * Math.floor((cameraX - originalLoopX - offset) / loopWidth);
				loopMC2.x = loopMC1.x + loopWidth;
				
			}
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				handleLoopingBackground();
				var players:Array = SSF2API.getPlayers();
				if (players[0].getMC().currentLabel == "special" && players[0].getStanceMC().currentLabel == "failed" || SSF2API.getGameTimer().getCurrentTime() <= 0 || !players[0].getMC().currentLabel == "special" && !players[0].hasSmashBallAura())
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[0].getMC().currentLabel == "special")
				{
					var fsClip = players[0].getFinalSmashCutscene();
							
					if(fsClip && fsClip.currentLabel == "end"){
						//Set rank
						var rank = "F";
						if(SSF2API.getElapsedFrames() <= 261)
							rank = "S";
						else if(SSF2API.getElapsedFrames() <= 276)
							rank = "A";
						else if(SSF2API.getElapsedFrames() <= 320)
							rank = "B";
						else if(SSF2API.getElapsedFrames() <= 395)
							rank = "C";
						else if(SSF2API.getElapsedFrames() <= 415)
							rank = "D";
						else if(SSF2API.getElapsedFrames() <= 450)
							rank = "E";
						else
							rank = "F";
						matchData.rank = rank;
						matchData.success = true;
						matchData.stock = players[0].getLives();
						matchData.score = SSF2API.getElapsedFrames();
						matchData.scoreType = "time";
						matchData.fps = SSF2API.getAverageFPS();
						SSF2API.endGame({ success: true, immediate: false });
					}
				}
			}
		}
	}
}