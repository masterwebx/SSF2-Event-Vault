// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode

package 
{
    import flash.display.MovieClip;

    public class EventMode extends SSF2CustomMode 
    {

        public static var currentInstance:EventMode;

        private var m_currentMatch:SSF2CustomMatch;
        private var eventMatchPropData:Object = null;
        private var eventMatchClass:Class = null;
        private var m_playerDamage:Number = 0;
        private var m_playerLives:int = 2;
        private var m_hpDisplay:MovieClip;
        private var m_elapsedFrames:int = -1;
        public var matchNumber:int = -1;
        public var failed:Boolean = false;

        public function EventMode(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function initialize():void
        {
            EventMode.currentInstance = this;
            var _local_1:String = getModeSettings().eventMatchID;
            var _local_2:Array = SSF2API.getProp("eventList");
            var _local_3:int;
            while (_local_3 < _local_2.length)
            {
                if (_local_1 === _local_2[_local_3].id)
                {
                    this.eventMatchPropData = _local_2[_local_3];
                    this.eventMatchClass = this.eventMatchPropData.classAPI;
                };
                _local_3++;
            };
            if (this.eventMatchPropData.special)
            {
                this.initNextAllStarMatch();
            }
            else
            {
                this.m_currentMatch = SSF2API.createCustomMatch(this.eventMatchClass, this, getInitialGameSettings());
                startMatch(this.m_currentMatch);
            };
        }

        private function initNextAllStarMatch():void
        {
            var _local_1:EventMode_AllStarBaseMatch;
            if (this.failed)
            {
                endMode({});
            }
            else
            {
                this.matchNumber++;
                SSF2API.print("All Star Match initializing.");
                SSF2API.print((("Beginning match" + (this.matchNumber + 1)) + "."));
                startMatch((this.m_currentMatch = SSF2API.createCustomMatch(this.eventMatchClass, this, getInitialGameSettings())));
                _local_1 = (this.m_currentMatch as EventMode_AllStarBaseMatch);
                SSF2API.print((("There are " + _local_1.matchArray.length) + " matches."));
                SSF2API.print("Successfully loaded array of match data.");
            };
        }

        override public function handleMatchComplete():void
        {
            if (((this.eventMatchPropData.special) && ((!(this.m_currentMatch)) || (!((this.m_currentMatch as EventMode_AllStarBaseMatch).isLastMatch())))))
            {
                this.initNextAllStarMatch();
            }
            else
            {
                if (this.m_currentMatch.matchData.success)
                {
                    saveModeData({
                        "type":"eventMatch",
                        "eventMatchID":getModeSettings().eventMatchID,
                        "matchData":this.m_currentMatch.matchData
                    });
                };
                SSF2API.print((((("" + this.m_currentMatch.matchData.score) + ": rank ") + this.m_currentMatch.matchData.rank) + "."));
                endMode({});
            };
        }

        public function getPlayerLives():int
        {
            return (this.m_playerLives);
        }

        public function savePlayerLives(_arg_1:*):void
        {
            this.m_playerLives = _arg_1;
        }

        public function getPlayerDamage():Number
        {
            return (this.m_playerDamage);
        }

        public function savePlayerDamage(_arg_1:*):void
        {
            this.m_playerDamage = _arg_1;
        }

        public function getMatchTime():Number
        {
            SSF2API.print(("Match elapsed time is " + this.m_elapsedFrames));
            return (this.m_elapsedFrames);
        }

        public function setMatchTime():void
        {
            SSF2API.getGameTimer().setCurrentTime(this.m_elapsedFrames);
            SSF2API.print(("Match elapsed time is " + SSF2API.getGameTimer().getCurrentTime()));
        }

        public function saveMatchTime():void
        {
            this.m_elapsedFrames = SSF2API.getGameTimer().getCurrentTime();
            SSF2API.print(("Match elapsed time is " + this.m_elapsedFrames));
        }


    }
}//package 

