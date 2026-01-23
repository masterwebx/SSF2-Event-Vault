// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode_AllStarBattleMatch

package 
{
    public class EventMode_AllStarBattleMatch extends EventMode_AllStarBaseMatch 
    {

        public function EventMode_AllStarBattleMatch(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function getRank():String
        {
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 300))
            {
                return ("S");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 550))
            {
                return ("A");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 900))
            {
                return ("B");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 1300))
            {
                return ("C");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 1600))
            {
                return ("D");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 2500))
            {
                return ("E");
            };
            return ("F");
        }

        override public function update():void
        {
            var _local_1:Array;
            if (!SSF2API.isGameEnded())
            {
                _local_1 = SSF2API.getPlayers();
                if (_local_1[0].getLives() <= 0)
                {
                    matchData.success = false;
                    EventMode.currentInstance.failed = true;
                    SSF2API.endGame({
                        "success":false,
                        "immediate":false
                    });
                }
                else
                {
                    if (_local_1[1].getLives() <= 0)
                    {
                        if (isLastMatch())
                        {
                            matchData.rank = this.getRank();
                            matchData.success = true;
                            matchData.stock = _local_1[0].getLives();
                            matchData.score = SSF2API.getGameTimer().getCurrentTime();
                            matchData.scoreType = "time";
                            matchData.fps = SSF2API.getAverageFPS();
                            SSF2API.endGame({
                                "success":true,
                                "immediate":false
                            });
                        }
                        else
                        {
                            EventMode.currentInstance.savePlayerDamage(_local_1[0].getDamage());
                            EventMode.currentInstance.savePlayerLives(_local_1[0].getLives());
                            EventMode.currentInstance.saveMatchTime();
                            SSF2API.endGame({
                                "immediate":false,
                                "silent":true
                            });
                        };
                    };
                };
            };
        }


    }
}//package 

