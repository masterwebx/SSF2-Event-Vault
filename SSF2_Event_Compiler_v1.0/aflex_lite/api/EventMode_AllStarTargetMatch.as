// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode_AllStarTargetMatch

package 
{
    public class EventMode_AllStarTargetMatch extends EventMode_AllStarBaseMatch 
    {

        public function EventMode_AllStarTargetMatch(_arg_1:*)
        {
            super(_arg_1);
        }

        override public function getRank():String
        {
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 630))
            {
                return ("S");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 700))
            {
                return ("A");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 750))
            {
                return ("B");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 800))
            {
                return ("C");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 850))
            {
                return ("D");
            };
            if (EventMode.currentInstance.getMatchTime() <= (matchArray.length * 1000))
            {
                return ("E");
            };
            return ("F");
        }

        override public function getFoeQueue():Array
        {
            var _local_1:Array = [];
            var _local_2:int = EventMode.currentInstance.matchNumber;
            while (_local_2 < matchArray.length)
            {
                _local_1.push(matchArray[_local_2].targetMC);
                _local_2++;
            };
            return (_local_1);
        }

        override public function update():void
        {
            var targets:Array;
            var players:Array;
            if (!SSF2API.isGameEnded())
            {
                targets = SSF2API.getTargets().filter(function (_arg_1:*):*
                {
                    return (_arg_1.inState(TState.IDLE));
                });
                players = SSF2API.getPlayers();
                if (players[0].getLives() <= 0)
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
                    if (targets.length <= 0)
                    {
                        if (isLastMatch())
                        {
                            EventMode.currentInstance.saveMatchTime();
                            matchData.rank = this.getRank();
                            matchData.success = true;
                            matchData.stock = players[0].getLives();
                            matchData.score = EventMode.currentInstance.getMatchTime();
                            matchData.scoreType = "time";
                            matchData.fps = SSF2API.getAverageFPS();
                            SSF2API.endGame({
                                "success":true,
                                "immediate":false
                            });
                        }
                        else
                        {
                            EventMode.currentInstance.savePlayerDamage(players[0].getDamage());
                            EventMode.currentInstance.savePlayerLives(players[0].getLives());
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

