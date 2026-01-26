package
{
	import flash.display.MovieClip;
	
	public class EventMode49_GottaCherishThemAll extends SSF2CustomMatch
	{
		public function EventMode49_GottaCherishThemAll(api:*)
		{
			super(api);
		}
		public override function initialize():void
		{
			SSF2API.addCustomItem({
				statsName: "cherishball", classAPI: EventAsset_CherishBall, linkage_id:"cherish_ball", displayName:"Cherish%20Ball", width:15, height:15, weight1:100, canPickup:true, canReceiveKnockback:false, pushCharacters:true, retainPlayerID:true, gravity:1, max_gravity:9, tossSpeed:10, effectSound:"pokeball_open", landSound:"pokeball_land", surviveDeathBounds:false, 
				attack_idle:{
					attackBoxes: { 
						attackBox: { damage:2, priority:2, hitStun:3, selfHitStun:3, effect_id:"effect_hit1", direction:90, power:1, kbConstant:0, effectSound:null }
					}
				},
				attack_toss:{
					refreshRate:30,attackBoxes: { 
						attackBox: { damage:1, priority:2, hitStun:13, selfHitStun:3, effect_id:"effect_hit1", direction:90, power:1, kbConstant:0, effectSound:"brawl_punch_s" }
					}
				}
			});
			
			SSF2API.getPlayer(2).setHurtInterrupt(pokeBallCheck);
			SSF2API.getPlayer(2).setLivesEnabled(false);
			SSF2API.getPlayer(2).addEventListener(SSF2Event.CHAR_KO_DEATH,checkDeath,{persistent:true});
			SSF2API.getPlayer(3).setHurtInterrupt(pokeBallCheck);
			SSF2API.getPlayer(3).setLivesEnabled(false);
			SSF2API.getPlayer(3).addEventListener(SSF2Event.CHAR_KO_DEATH,checkDeath,{persistent:true});
			SSF2API.getPlayer(4).setHurtInterrupt(pokeBallCheck);
			SSF2API.getPlayer(4).setLivesEnabled(false);
			SSF2API.getPlayer(4).addEventListener(SSF2Event.CHAR_KO_DEATH,checkDeath,{persistent:true});

		}
		public function pokeBallCheck(status:Object):Boolean
		{
			var foe = status.target;
			var foeType = foe.getType();
			if(foeType)
			{
				if(foeType == "SSF2Item"){
					if(foe.getItemStat("linkage_id") == "cherish_ball")
						return false;
					else
						return true;
				}else{
					return true;
				}
			} else return false;
		}
		public function checkDeath(e:*):void
		{
			var player = e.data.caller;
			var foe = player.getLastHurtAttackBoxStats();
			
			if(foe)
			{
				foe = foe.owner;
				
				if(foe.getType() == "SSF2Item" && foe.getItemStat("linkage_id") == "cherish_ball"){
				player.removeEventListener(SSF2Event.CHAR_KO_DEATH,checkDeath);
				player.setLivesEnabled(true);
				player.setLives(0);
				player.setStandby(true);
				}else{ 
					player.setLivesEnabled(false);
				}
			}
		}
		public override function matchSetup(initSettings:Object):Object
		{
			var game:Object = {
				playerSettings: [], // Start out playerSettings fresh
				levelData: initSettings.levelData, // Inherit levelData
				items: initSettings.items // Inherit item settings
			};
			
			game.playerSettings.push({ 
				character: "pikachu",
				name: initSettings.playerSettings[0].name,
				costume: initSettings.playerSettings[0].costume,
				lives: 3,
				human: true,
				team: 1
			});
			game.playerSettings.push({ 
				character: "link",
				lives: 1,
				human: false,
				team: 3,
				level: 9
			});
			game.playerSettings.push({ 
				character: "ichigo",
				lives: 1,
				human: false,
				team: 3,
				level: 9
			});
			game.playerSettings.push({ 
				character: "zamus",
				lives: 1,
				human: false,
				team: 3,
				level: 9
			});
			
			game.levelData.usingLives = true;
			game.levelData.usingTime = false;
			game.levelData.teamDamage = false;
			game.levelData.lives = 3;
			game.levelData.hazards = true;
			game.levelData.stage = "lakeofrage";
			
			var allItems:Array = SSF2API.getItemStatsList();
			for (var i:int = 0; i < allItems.length; i++)
			{
				game.items.items[allItems[i].statsName] = false;
			}
			game.items.items.cherishball = true;

			game.items.frequency = ItemSettings.FREQUENCY_MAX;
			return game;
		}
		public override function update():void
		{
			if (!SSF2API.isGameEnded())
			{
				var players:Array = SSF2API.getPlayers();
				if (players[0].getLives() <= 0)
				{
					matchData.success = false;
					SSF2API.endGame({ success: false, immediate: false });
				} else if (players[1].getLives() <= 0 && players[2].getLives() <= 0 && players[3].getLives() <= 0)
				{
					var rank = "F";
					if(SSF2API.getElapsedFrames() <= 580)
						rank = "S";
					else if(SSF2API.getElapsedFrames() <= 1400)
						rank = "A";
					else if(SSF2API.getElapsedFrames() <= 1865)
						rank = "B";
					else if(SSF2API.getElapsedFrames() <= 2150)
						rank = "C";
					else if(SSF2API.getElapsedFrames() <= 2500)
						rank = "D";
					else if(SSF2API.getElapsedFrames() <= 2900)
						rank = "E";
					else
						rank = "F";
					
					matchData.success = true;
					matchData.stock = players[0].getLives();
					matchData.score = SSF2API.getElapsedFrames();
					matchData.scoreType = "time";
					
					matchData.rank = rank;
					matchData.fps = SSF2API.getAverageFPS();
					SSF2API.endGame({ success: true, immediate: false });
				}
			}
		}
	}
}