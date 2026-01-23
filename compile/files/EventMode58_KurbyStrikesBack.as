// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode58_KurbyStrikesBack

package 
{
     
    public class EventMode58_KurbyStrikesBack extends SSF2CustomMatch 
    {
        public var eventinfo:Array = [
			{
				"id":"pancakes",
                "classAPI":EventMode58_KurbyStrikesBack,
                "name":"58. Attack of the Purple Pancakes!",
                "description":"Purple pancakes threaten to destroy the Homeland, team up with Dee and defeat at least 25 of them!"
			}
		];
        public function EventMode58_KurbyStrikesBack(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function initialize():void
        {
            SSF2API.getPlayer(1).setTeamID(1);
            SSF2API.getPlayer(2).setTeamID(1);
            SSF2API.getPlayer(3).setTeamID(2);
            SSF2API.getPlayer(4).setTeamID(2);
            SSF2API.getPlayer(5).setTeamID(2);
            SSF2API.getPlayer(6).setTeamID(2);
            SSF2API.getPlayer(3).setScale(2, 0.2);
            SSF2API.getPlayer(4).setScale(2, 0.2);
            SSF2API.getPlayer(5).setScale(2, 0.2);
            SSF2API.getPlayer(6).setScale(2, 0.2);
            SSF2API.getPlayer(3).updateCharacterStats({
                "damageRatio":5,
                "displayName":"Purple Pancake"
            });
            SSF2API.getPlayer(4).updateCharacterStats({
                "damageRatio":5,
                "displayName":"Purple Pancake"
            });
            SSF2API.getPlayer(5).updateCharacterStats({
                "damageRatio":5,
                "displayName":"Purple Pancake"
            });
            SSF2API.getPlayer(6).updateCharacterStats({
                "damageRatio":5,
                "displayName":"Purple Pancake"
            });
            SSF2API.getPlayer(3).setLivesEnabled(false);
            SSF2API.getPlayer(4).setLivesEnabled(false);
            SSF2API.getPlayer(5).setLivesEnabled(false);
            SSF2API.getPlayer(6).setLivesEnabled(false);
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_2:Object = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            _local_2.playerSettings.push({
                "character":"metaknight",
                "name":_arg_1.playerSettings[0].name,
                "lives":2,
                "human":true
            });
            _local_2.playerSettings.push({
                "character":"bandanadee",
                "human":false,
                "lives":2,
                "level":8,
                "team":1
            });
            _local_2.playerSettings.push({
                "character":"kirby",
                "human":false,
                "level":8,
                "costume":7
            });
            _local_2.playerSettings.push({
                "character":"kirby",
                "human":false,
                "level":8,
                "costume":7
            });
            _local_2.playerSettings.push({
                "character":"kirby",
                "human":false,
                "level":8,
                "costume":7
            });
            _local_2.playerSettings.push({
                "character":"kirby",
                "human":false,
                "level":8,
                "costume":7
            });
            _local_2.levelData.showEntrances = false;
            _local_2.levelData.showCountdown = false;
            _local_2.levelData.usingLives = true;
            _local_2.levelData.usingTime = true;
            _local_2.levelData.teamDamage = false;
            _local_2.levelData.time = 2;
            _local_2.levelData.lives = 2;
            _local_2.levelData.hazards = true;
            _local_2.levelData.stage = "dreamland";
            var _local_3:Array = SSF2API.getItemStatsList();
            var _local_4:int;
            while (_local_4 < _local_3.length)
            {
                delete _local_2.items.items[_local_3[_local_4].statsName];
                _local_4++;
            };
            _local_2.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
            return (_local_2);
        }

        override public function update():void
        {
            var _local_1:Array;
            var _local_2:* = undefined;
            if (!SSF2API.isGameEnded())
            {
                _local_1 = SSF2API.getPlayers();
                SSF2API.print((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos));
                if (_local_1[0].getLives() <= 0)
                {
                    matchData.success = false;
                    SSF2API.endGame({
                        "success":false,
                        "immediate":false
                    });
                };
                if (((SSF2API.getGameTimer().getCurrentTime() <= 0) && ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) < 25)))
                {
                    matchData.success = false;
                    SSF2API.endGame({
                        "success":false,
                        "immediate":false
                    });
                }
                else
                {
                    if (SSF2API.getGameTimer().getCurrentTime() <= 0)
                    {
                        _local_2 = "F";
                        if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 50)
                        {
                            _local_2 = "S";
                        }
                        else
                        {
                            if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 40)
                            {
                                _local_2 = "A";
                            }
                            else
                            {
                                if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 35)
                                {
                                    _local_2 = "B";
                                }
                                else
                                {
                                    if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 30)
                                    {
                                        _local_2 = "C";
                                    }
                                    else
                                    {
                                        if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 27)
                                        {
                                            _local_2 = "D";
                                        }
                                        else
                                        {
                                            if ((_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos) >= 25)
                                            {
                                                _local_2 = "E";
                                            }
                                            else
                                            {
                                                _local_2 = "F";
                                            };
                                        };
                                    };
                                };
                            };
                        };
                        matchData.rank = _local_2;
                        matchData.success = true;
                        matchData.stock = _local_1[0].getLives();
                        matchData.score = (_local_1[0].getMatchStatistics().kos + _local_1[1].getMatchStatistics().kos);
                        matchData.scoreType = "kos";
                        matchData.fps = SSF2API.getAverageFPS();
                        SSF2API.endGame({
                            "success":true,
                            "immediate":false
                        });
                    };
                };
            };
        }


    }
}//package 

