// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode568P_Ditto

package 
{
    public class EventMode568P_Ditto extends SSF2CustomMatch 
    {

        public var eventinfo:Array = [
			{
				"id":"8P_ditto",
                "classAPI":EventMode568P_Ditto,
                "name":"8 Player Ditto",
                "description":"Hey it's me x8!",
                "chooseCharacter":true,
                "creator":"MasterWex"
			}
		];
        public function EventMode568P_Ditto(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function update():void
        {
            var _local_1:Array;
            var _local_2:* = undefined;
            _local_1 = null;
            _local_2 = undefined;
            if (!SSF2API.isGameEnded())
            {
                _local_1 = SSF2API.getPlayers();
                if (((_local_1[0].getLives() <= 0) || (SSF2API.getGameTimer().getCurrentTime() <= 0)))
                {
                    matchData.success = false;
                    SSF2API.endGame({
                        "success":false,
                        "immediate":false
                    });
                }
                else
                {
                    if ((((((((_local_1[1].getLives() <= 0) && (_local_1[2].getLives() <= 0)) && (_local_1[3].getLives() <= 0)) && (_local_1[4].getLives() <= 0)) && (_local_1[5].getLives() <= 0)) && (_local_1[6].getLives() <= 0)) && (_local_1[7].getLives() <= 0)))
                    {
                        _local_2 = "F";
                        if (SSF2API.getElapsedFrames() <= 2800)
                        {
                            _local_2 = "S";
                        }
                        else
                        {
                            if (SSF2API.getElapsedFrames() <= 3600)
                            {
                                _local_2 = "A";
                            }
                            else
                            {
                                if (SSF2API.getElapsedFrames() <= 5400)
                                {
                                    _local_2 = "B";
                                }
                                else
                                {
                                    if (SSF2API.getElapsedFrames() <= 6300)
                                    {
                                        _local_2 = "C";
                                    }
                                    else
                                    {
                                        if (SSF2API.getElapsedFrames() <= 7200)
                                        {
                                            _local_2 = "D";
                                        }
                                        else
                                        {
                                            if (SSF2API.getElapsedFrames() <= 8000)
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
                        matchData.success = true;
                        matchData.stock = _local_1[0].getLives();
                        matchData.score = SSF2API.getElapsedFrames();
                        matchData.scoreType = "time";
                        matchData.rank = _local_2;
                        matchData.fps = SSF2API.getAverageFPS();
                        SSF2API.endGame({"immediate":false});
                    };
                };
            };
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_2:Object;
            var _local_3:Array;
            var _local_4:int;
            var _local_5:Array = ["mario", "luigi", "peach", "bowser", "yoshi", "wario", "donkeykong", "link", "zelda", "sheik", "pikachu", "jigglypuff", "captainfalcon", "gameandwatch", "kirby", "metaknight", "bandanadee", "fox", "falco", "marth", "pit", "samus", "zamus", "ness", "chibirobo", "isaac", "sonic", "tails", "blackmage", "sora", "pacman", "bomberman", "ichigo", "naruto", "goku", "luffy", "sandbag"];
            var _local_6:Array = ["1", "2", "3", "4", "5", "6", "7", "8"];
            var _local_7:Array = ["finaldestination", "bowserscastle", "yoshisisland", "emeraldcave", "gangplankgalleon", "lakeofrage", "flatzoneplus", "meteovoyage", "crateria", "phase8", "saturnvalley", "devilsmachine", "desk", "casinonightzone", "skysanctuary", "chaosshrine", "lunarcore", "skullfortress", "pacmaze", "bombfactory", "draculascastle", "konohavillage", "finalvalley", "worldtournament", "kingdom1", "peachscastle", "kingdom2", "hyrulecastle64", "hyruletemple", "saffroncity", "sectorz"];
            _local_2 = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":3,
                "human":true,
                "team":-1
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "lives":3,
                "human":false,
                "team":-1,
                "level":9,
                "costume":_local_6[int((_local_6.length * Math.random()))]
            });
            _local_2.levelData.usingLives = true;
            _local_2.levelData.usingTime = true;
            _local_2.levelData.lives = 3;
            _local_2.levelData.time = 5;
            _local_2.levelData.hazards = true;
            _local_2.levelData.stage = _local_7[int((_local_7.length * Math.random()))];
            _local_3 = SSF2API.getItemStatsList();
            _local_4 = 0;
            while (_local_4 < _local_3.length)
            {
                delete _local_2.items.items[_local_3[_local_4].statsName];
                _local_4++;
            };
            _local_2.items.frequency = ItemSettings.FREQUENCY_ULTRA_HIGH;
            return (_local_2);
        }


    }
}//package 

