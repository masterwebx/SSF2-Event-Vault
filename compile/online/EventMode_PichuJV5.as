package
{
	import flash.display.MovieClip;
	
	public class EventMode_PichuJV5 extends SSF2CustomMatch
	{
		public var elapsedFrames:int = 0;
		public var eventinfo:Array = [
			{
				"id":"pichuJV5",
                "classAPI":EventMode_PichuJV5,
                "name":"Pichu JV5",
                "description":"Bruh do you think you can JV5 with Pichu? Prove it in this intense challenge!",
                "previewCharacter":"pichu",
				"previewCostume":-1,
                "creator":"MasterWex"
			}
		];
		public function EventMode_PichuJV5(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{			
			SSF2API.getGameTimer().setCurrentTime(SSF2API.getGameTimer().getCurrentTime())
			SSF2API.getPlayer(1).setLivesEnabled(false);
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "pichu",
				name: "VOLLAY",
				lives: 4,
				human: true,
				level: 9
			});
			game.playerSettings.push({ 
				character: "fox",
				lives: 4,
				human: false,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = true;
			game.levelData.countdown = false;
			game.levelData.showCountdownType = 1;
			game.levelData.lives = 4;
			game.levelData.stage = "waitingroom";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_OFF;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{				
				
				var players:Array = SSF2API.getPlayers();				
				if (players[0].getDamage() > 0 && !players[0].inState(CState.ATTACKING) || players[0].inState(CState.REVIVAL))
				{
				SSF2API.print("You got hit! Try again!\n!JV5 Failed!");
				SSF2API.getGameTimer().setCurrentTime(0);
				// Restart the event instead of failing
				elapsedFrames = SSF2API.getElapsedFrames();
				players[1].setLives(4);
				players[1].setDamage(0);
				players[0].setDamage(0);
				players[0].setLives(4);
				
				} else if (players[1].getLives() <= 0)
				{
					
					//Set rank based on elapsed time (8 minute match = 28800 frames)
					var rank = "F";
					if(SSF2API.getElapsedFrames() - elapsedFrames <= 5400)
				{
					rank = "S";
					SSF2API.print("Who are you? You must be some kind of Pichu god to get an S rank on this challenge!");
				}
				else if(SSF2API.getElapsedFrames() - elapsedFrames <= 5820)
				{
					rank = "A";
					SSF2API.print("Dang, you got about the same time as Vollay's JV5! Impressive!");
				}
				else if(SSF2API.getElapsedFrames() - elapsedFrames <= 6300)
				{
					rank = "B";
					SSF2API.print("Almost as good as Vollay's JV5!");
				}
				else if(SSF2API.getElapsedFrames() - elapsedFrames <= 6840)
				{
					rank = "C";
				}
				else if(SSF2API.getElapsedFrames() - elapsedFrames <= 7320)
				{
					rank = "D";
				}
				else if(SSF2API.getElapsedFrames() - elapsedFrames <= 7800)
				{
					rank = "E";
				}
				else
				{
					rank = "F";
				}
					matchData.score = SSF2API.getElapsedFrames() - elapsedFrames;
					matchData.scoreType = "time";
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({
                        success: true,
                        immediate: false,
                        slowMo: false
                    });
				}
			}
		}
	}
}
