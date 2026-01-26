// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode_AllStarBaseMatch

package 
{
    import flash.display.MovieClip;

    public class EventMode_AllStarBaseMatch extends SSF2CustomMatch 
    {

        private static const EMPTY_PALETTE_SWAP:Object = {
            "colors":[],
            "replacements":[]
        };

        public var playerLives:Number = 2;
        public var cpuLevel:Number = 9;
        public var matchArray:Array;

        public function EventMode_AllStarBaseMatch(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function initialize():void
        {
            var _local_8:*;
            var _local_9:Object;
            SSF2API.getPlayer(1).setDamage(EventMode.currentInstance.getPlayerDamage());
            SSF2API.getPlayer(1).setLives(EventMode.currentInstance.getPlayerLives());
            EventMode.currentInstance.setMatchTime();
            if (this.isFirstMatch())
            {
                SSF2API.print("what up bitch");
                EventMode.currentInstance.savePlayerLives(this.playerLives);
            };
            var _local_1:Array = this.getFoeQueue();
            var _local_2:MovieClip = SSF2API.getStage().getHUDForegroundMC().addChild(new allstar_icon_container());
            _local_2.x = -300;
            if (SSF2API.isDebug())
            {
                _local_2.y = -130;
            }
            else
            {
                _local_2.y = -160;
            };
            var _local_3:Number = 0;
            var _local_4:Number = 0;
            var _local_5:int = 10;
            var _local_6:int = 23;
            var _local_7:int;
            while (_local_7 < _local_1.length)
            {
                SSF2API.print((("searching for " + _local_1[_local_7]) + "_stock"));
                SSF2API.print((("appending " + _local_1[_local_7]) + " to HUD"));
                _local_8 = _local_2.addChild(SSF2API.getMCByLinkageName((_local_1[_local_7] + "_stock")));
                if (_local_8)
                {
                    _local_9 = SSF2API.getCostumeData(_local_1[_local_7], -1, -1);
                    SSF2Utils.setColorFilters(_local_8, _local_9);
                    SSF2Utils.replacePalette(_local_8, ((((_local_9) || ({})).paletteSwap) || (EMPTY_PALETTE_SWAP)), 2, false, true);
                    _local_8.x = _local_3;
                    _local_8.y = _local_4;
                    _local_8.scaleX = ((0.9 * _local_6) / _local_8.width);
                    _local_8.scaleY = ((0.9 * _local_6) / _local_8.height);
                    _local_3 = (_local_3 + _local_6);
                    if (_local_3 >= (_local_6 * _local_5))
                    {
                        _local_3 = 0;
                        _local_4 = (_local_4 + _local_6);
                    };
                };
                _local_7++;
            };
            _local_2.removeChild(_local_2.placeholder);
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_2:Object = this.matchArray[EventMode.currentInstance.matchNumber];
            var _local_3:Object = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            _local_3.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":EventMode.currentInstance.getPlayerLives(),
                "human":true,
                "team":-1
            });
            if (_local_2.opponent !== undefined)
            {
                _local_3.playerSettings.push({
                    "character":_local_2.opponent,
                    "lives":1,
                    "human":false,
                    "team":-1,
                    "level":this.cpuLevel
                });
            };
            if (this.isFirstMatch())
            {
                _local_3.levelData.showEntrances = true;
                _local_3.levelData.showCountdown = true;
                _local_3.levelData.showCountdownType = 1;
            }
            else
            {
                _local_3.levelData.showEntrances = false;
                _local_3.levelData.showCountdown = false;
            };
            _local_3.levelData.usingLives = true;
            _local_3.levelData.usingTime = true;
            _local_3.levelData.countdown = false;
            _local_3.levelData.hazards = true;
            _local_3.levelData.stage = _local_2.stage;
            _local_3.levelData.lives = 1;
            var _local_4:Array = SSF2API.getItemStatsList();
            var _local_5:int;
            while (_local_5 < _local_4.length)
            {
                delete _local_3.items.items[_local_4[_local_5].statsName];
                _local_5++;
            };
            if (_local_2.opponent !== undefined)
            {
                _local_3.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
            }
            else
            {
                _local_3.items.frequency = ItemSettings.FREQUENCY_OFF;
            };
            return (_local_3);
        }

        public function getRank():String
        {
            return ("");
        }

        public function isFirstMatch():Boolean
        {
            if (EventMode.currentInstance.matchNumber <= 0)
            {
                return (true);
            };
            return (false);
        }

        public function isLastMatch():Boolean
        {
            if (EventMode.currentInstance.matchNumber >= (this.matchArray.length - 1))
            {
                return (true);
            };
            return (false);
        }

        public function getFoeQueue():Array
        {
            var _local_1:Array = [];
            var _local_2:int = EventMode.currentInstance.matchNumber;
            while (_local_2 < this.matchArray.length)
            {
                _local_1.push(this.matchArray[_local_2].opponent);
                _local_2++;
            };
            return (_local_1);
        }


    }
}//package 

