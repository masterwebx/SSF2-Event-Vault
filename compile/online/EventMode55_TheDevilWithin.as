// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode55_TheDevilWithin

package 
{
    import flash.utils.getDefinitionByName;

    public class EventMode55_TheDevilWithin extends SSF2CustomMatch 
    {
        public var eventinfo:Array = [
			{
				"id":"TheDevilWithin",
                "classAPI":EventMode55_TheDevilWithin,
                "name":"55. The Devil Within",
                "description":"A battle against yourself, your pain is the only way to win.",
                "chooseCharacter":true
			}
		];
        public var updated:* = false;
        private var MultiplayerManagerClass:Class;
        private var player1PreviousLives:int = 2;

        public function EventMode55_TheDevilWithin(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function initialize():void
        {            
            super.initialize();    
            // Get the class dynamically
            this.MultiplayerManagerClass = getDefinitionByName("com.mcleodgaming.ssf2.net.MultiplayerManager") as Class;            
            // Call the method
            this.MultiplayerManagerClass["notify"]("Made by MasterWex, originally for Project Sandbag, enjoy!");
            SSF2API.getPlayer(2).setSizeStatus(1);
            SSF2API.getPlayer(2).lockSizeStatus(true);
            SSF2API.getPlayer(1).setSizeStatus(-1);
            SSF2API.getPlayer(1).lockSizeStatus(true);
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_2:Object = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":2,
                "human":true,
                "team":-1
            });
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":1,
                "human":false,
                "team":-1,
                "level":9
            });
            _local_2.levelData.usingLives = true;
            _local_2.levelData.usingTime = false;
            _local_2.levelData.lives = 3;
            _local_2.levelData.hazards = true;
            _local_2.levelData.teamDamage = true;
            _local_2.levelData.stage = "devilsmachine";
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
            var _local_1:* = undefined;
            var _local_2:* = undefined;
            var _local_3:* = undefined;
            var _local_4:* = undefined;
            var _local_5:* = undefined;
            var _local_6:* = undefined;
            var _local_7:* = undefined;
            var _local_8:* = undefined;
            var _local_9:* = undefined;
            var _local_10:Array = SSF2API.getPlayers();
            var player1Lives:int = _local_10[0].getLives();
            if (player1Lives < this.player1PreviousLives) {
                this.MultiplayerManagerClass["notify"]("YOU WILL NEVER DEFEAT YOUR INNER DEMONS!");
            }
            this.player1PreviousLives = player1Lives;
            if (!this.updated)
            {
                _local_1 = _local_10[0];
                _local_2 = _local_10[1];
                _local_5 = _local_1.getDamage();
                _local_6 = _local_2.getDamage();
                if (_local_6 < _local_5)
                {
                    _local_2.setDamage(_local_5);
                    _local_2.throbDamageCounter();
                }
                else
                {
                    if (_local_5 < _local_6)
                    {
                        _local_1.setDamage(_local_6);
                        _local_1.throbDamageCounter();
                    };
                };
                this.updated = true;
            }
            else
            {
                this.updated = false;
            };
            if (!SSF2API.isGameEnded())
            {
                if (_local_10[0].getLives() <= 0)
                {
                    matchData.success = false;
                    SSF2API.endGame({
                        "slowMo":false,
                        "success":false,
                        "immediate":false
                    });
                }
                else
                {
                    if (_local_10[1].getLives() <= 0)
                    {
                        _local_9 = "F";
                        if (SSF2API.getElapsedFrames() <= 950)
                        {
                            _local_9 = "S";
                        }
                        else
                        {
                            if (SSF2API.getElapsedFrames() <= 1250)
                            {
                                _local_9 = "A";
                            }
                            else
                            {
                                if (SSF2API.getElapsedFrames() <= 1470)
                                {
                                    _local_9 = "B";
                                }
                                else
                                {
                                    if (SSF2API.getElapsedFrames() <= 3000)
                                    {
                                        _local_9 = "C";
                                    }
                                    else
                                    {
                                        if (SSF2API.getElapsedFrames() <= 3290)
                                        {
                                            _local_9 = "D";
                                        }
                                        else
                                        {
                                            if (SSF2API.getElapsedFrames() <= 3450)
                                            {
                                                _local_9 = "E";
                                            }
                                            else
                                            {
                                                _local_9 = "F";
                                            };
                                        };
                                    };
                                };
                            };
                        };
                        matchData.success = true;
                        matchData.stock = _local_10[0].getLives();
                        matchData.score = SSF2API.getElapsedFrames();
                        matchData.scoreType = "time";
                        matchData.rank = _local_9;
                        matchData.fps = SSF2API.getAverageFPS();
                        SSF2API.endGame({
                            "slowMo":false,
                            "success":true,
                            "immediate":false
                        });
                    };
                };
            };
        }


    }
}//package 

