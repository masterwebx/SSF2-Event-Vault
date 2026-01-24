// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventMode53MasterofHands

package 
{
    import flash.geom.*;

    
    public class EventMode53MasterofHands extends SSF2CustomMatch 
    {
        public var eventinfo:Array = [
			{
				"id":"MasterofHands",
                "classAPI":EventMode53MasterofHands,
                "name":"53. Master of Hands",
                "description":"*help* H I I I I I I I I *this is actually fun*",
                "chooseCharacter":true
			}
		];

        private var enemy:*;
        private var attackDelayModifier:* = 0;
        private var enemy4:*;
        private var enemy5:*;
        private var enemy6:*;
        private var enemy2:*;
        private var enemy3:*;
        private var enemy8:*;
        private var enemy7:*;
        private var enemy9:*;
        private var hpModifier:* = 100;

        public function EventMode53MasterofHands(_arg_1:*)
        {
            this.hpModifier = 100;
            this.attackDelayModifier = 0;
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
                if (_local_1[0].getLives() <= 0)
                {
                    matchData.success = false;
                    SSF2API.endGame({
                        "success":false,
                        "immediate":false
                    });
                }
                else
                {
                    if (((((((((((this.enemy.inState(EState.DEAD)) || (!(this.enemy))) && ((this.enemy2.inState(EState.DEAD)) || (!(this.enemy2)))) && ((this.enemy3.inState(EState.DEAD)) || (!(this.enemy3)))) && ((this.enemy4.inState(EState.DEAD)) || (!(this.enemy4)))) && ((this.enemy5.inState(EState.DEAD)) || (!(this.enemy5)))) && ((this.enemy6.inState(EState.DEAD)) || (!(this.enemy6)))) && ((this.enemy7.inState(EState.DEAD)) || (!(this.enemy7)))) && ((this.enemy8.inState(EState.DEAD)) || (!(this.enemy8)))) && ((this.enemy9.inState(EState.DEAD)) || (!(this.enemy9)))))
                    {
                        _local_2 = "F";
                        if (SSF2API.getElapsedFrames() <= 300)
                        {
                            _local_2 = "S";
                        }
                        else
                        {
                            if (SSF2API.getElapsedFrames() <= 600)
                            {
                                _local_2 = "A";
                            }
                            else
                            {
                                if (SSF2API.getElapsedFrames() <= 750)
                                {
                                    _local_2 = "B";
                                }
                                else
                                {
                                    if (SSF2API.getElapsedFrames() <= 900)
                                    {
                                        _local_2 = "C";
                                    }
                                    else
                                    {
                                        if (SSF2API.getElapsedFrames() <= 1000)
                                        {
                                            _local_2 = "D";
                                        }
                                        else
                                        {
                                            if (SSF2API.getElapsedFrames() <= 1200)
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
                        SSF2API.endGame({
                            "success":true,
                            "immediate":false
                        });
                    };
                };
            };
        }

        override public function initialize():void
        {
            this.enemy = SSF2API.spawnEnemy("MasterHand");
            this.enemy.setHomePosition(new Point(465, 20));
            this.enemy.setHurtInterrupt(this.checkMH);
            this.enemy.setX(465);
            this.enemy.setY(20);
            this.enemy2 = SSF2API.spawnEnemy("MasterHand");
            this.enemy2.setHurtInterrupt(this.checkMH);
            this.enemy2.setHomePosition(new Point(0, 20));
            this.enemy2.faceLeft();
            this.enemy3 = SSF2API.spawnEnemy("MasterHand");
            this.enemy3.setHurtInterrupt(this.checkMH);
            this.enemy3.setHomePosition(new Point(200, 420));
            this.enemy3.faceRight();
            this.enemy4 = SSF2API.spawnEnemy("MasterHand");
            this.enemy4.setHurtInterrupt(this.checkMH);
            this.enemy4.setHomePosition(new Point(10, 20));
            this.enemy4.faceRight();
            this.enemy5 = SSF2API.spawnEnemy("MasterHand");
            this.enemy5.setHurtInterrupt(this.checkMH);
            this.enemy5.setHomePosition(new Point(30, 620));
            this.enemy5.faceRight();
            this.enemy6 = SSF2API.spawnEnemy("MasterHand");
            this.enemy6.setHurtInterrupt(this.checkMH);
            this.enemy6.setHomePosition(new Point(50, 20));
            this.enemy6.faceRight();
            this.enemy7 = SSF2API.spawnEnemy("MasterHand");
            this.enemy7.setHurtInterrupt(this.checkMH);
            this.enemy7.setHomePosition(new Point(70, 420));
            this.enemy7.faceRight();
            this.enemy8 = SSF2API.spawnEnemy("MasterHand");
            this.enemy8.setHurtInterrupt(this.checkMH);
            this.enemy8.setHomePosition(new Point(90, 20));
            this.enemy8.faceRight();
            this.enemy9 = SSF2API.spawnEnemy("MasterHand");
            this.enemy9.setHurtInterrupt(this.checkMH);
            this.enemy9.setHomePosition(new Point(110, 620));
            this.enemy9.faceRight();
            if (this.hpModifier != 0)
            {
                this.enemy.setHP(this.hpModifier);
                this.enemy2.setHP(this.hpModifier);
                this.enemy3.setHP(this.hpModifier);
                this.enemy4.setHP(this.hpModifier);
                this.enemy5.setHP(this.hpModifier);
                this.enemy6.setHP(this.hpModifier);
                this.enemy7.setHP(this.hpModifier);
                this.enemy8.setHP(this.hpModifier);
                this.enemy9.setHP(this.hpModifier);
            };
            if (this.attackDelayModifier > -1)
            {
                this.enemy.setAttackDelay(this.attackDelayModifier);
                this.enemy2.setAttackDelay(this.attackDelayModifier);
                this.enemy3.setAttackDelay(this.attackDelayModifier);
                this.enemy4.setAttackDelay(this.attackDelayModifier);
                this.enemy5.setAttackDelay(this.attackDelayModifier);
                this.enemy6.setAttackDelay(this.attackDelayModifier);
                this.enemy7.setAttackDelay(this.attackDelayModifier);
                this.enemy8.setAttackDelay(this.attackDelayModifier);
                this.enemy9.setAttackDelay(this.attackDelayModifier);
            };
            SSF2API.getPlayer(1).setX(235);
            SSF2API.getPlayer(1).faceRight();
        }

        public function checkMH(_arg_1:*):Boolean
        {
            if (_arg_1.target.getType() == "SSF2Enemy")
            {
                if (_arg_1.target.getEnemyStat("linkage_id") == "masterhand_enemy")
                {
                    return (true);
                };
                return (false);
            };
            return (false);
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_2:Object;
            var _local_3:Array;
            var _local_4:int;
            _local_2 = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            _local_2.playerSettings.push({
                "character":_arg_1.playerSettings[0].character,
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":1,
                "human":true
            });
            _local_2.levelData.usingLives = true;
            _local_2.levelData.usingTime = false;
            _local_2.levelData.lives = 3;
            _local_2.levelData.hazards = true;
            _local_2.levelData.stage = "hyruletemple";
            _local_3 = SSF2API.getItemStatsList();
            _local_4 = 0;
            while (_local_4 < _local_3.length)
            {
                _local_2.items.items[_local_3[_local_4].statsName] = false;
                _local_4++;
            };
            delete _local_2.items.items.firework;
            _local_2.items.frequency = ItemSettings.FREQUENCY_MAX;
            return (_local_2);
        }


    }
}//package 

