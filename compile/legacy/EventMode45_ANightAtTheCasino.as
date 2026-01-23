package
{
	import flash.display.MovieClip;
	
	public class EventMode45_ANightAtTheCasino extends SSF2CustomMatch
	{
		public var bumper1:Boolean;
		public var bumper2:Boolean;
		public var bumper3:Boolean;
		public var bumper4:Boolean;
		public var bumper5:Boolean;
		public var bumper6:Boolean;
		
		public function EventMode45_ANightAtTheCasino(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.setCamStageFocus(int.MAX_VALUE);
			SSF2API.getPlayer(1).addEventListener(SSF2Event.CHAR_HURT, checkBumper, {persistent:true});
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "sonic",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 2,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "wario",
				lives: 1,
				human: false,
				team: 3,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "casinonightzone";
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				delete game.items.items[allItems[i].statsName];
			}
			game.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
			return game;
		}
		public function checkBumper(e:*)
		{		
			if(e.data.attackBoxData.metadata && e.data.attackBoxData.metadata.bumper && e.data.attackBoxData.metadata.bumperName)
			{
				var foe = e.data.attackBoxData.metadata.bumper;
				var foeName = e.data.attackBoxData.metadata.bumperName;
				
				if(foe && foeName)
				{
					if(foeName == "Bumper1_B" && !bumper1)
					{
						bumper1 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
					else if(foeName == "Bumper1_T" && !bumper2)
					{
						bumper2 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
					else if(foeName == "Bumper2_L" && !bumper3)
					{
						bumper3 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
					else if(foeName == "Bumper2_R" && !bumper4)
					{
						bumper4 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
					else if(foeName == "Bumper3_L" && !bumper5)
					{
						bumper5 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
					else if(foeName == "Bumper3_R" && !bumper6)
					{
						bumper6 = true;
						SSF2API.getStage().getMidground()[foeName].visible = false;
						foe.destroy();
					}
				}
			}
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ slowMo: false, success: false, immediate: false });
				} else if (bumper1 && bumper2 && bumper3 && bumper4 && bumper5 && bumper6)
				{
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 605)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 750)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 870)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 935)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 1067)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 1300)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					
					SSF2API.endGame({ slowMo: false, success: true, immediate: false });
				}
			}
		}
	}
}