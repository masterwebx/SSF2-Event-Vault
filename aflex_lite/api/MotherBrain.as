// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//MotherBrain

package 
{
    public class MotherBrain extends SSF2Enemy 
    {

        public const MOTHER_BRAIN_SPAWN:int = -1;
        public const MOTHER_BRAIN_IDLE:int = 0;
        public const MOTHER_BRAIN_LASER:int = 1;
        public const MOTHER_BRAIN_DESTROYED:int = 2;
        public const MOTHER_BRAIN_FADEOUT:int = 3;

        public var state:int;
        public var startHP:Number = 100;
        public var damaged:Boolean;
        private var timer:FrameTimer;
        public var platform:SSF2Platform;

        public function MotherBrain(_arg_1:*)
        {
            super(_arg_1);
        }

        public function setTimer(_arg_1:int):*
        {
            this.timer.reset();
            this.timer.duration = _arg_1;
        }

        override public function initialize():void
        {
            this.state = this.MOTHER_BRAIN_SPAWN;
            this.damaged = false;
            this.timer = new FrameTimer(450);
            addEventListener(SSF2Event.ENEMY_HURT, this.receiveDamage, {"persistent":true});
            addToCamera();
        }

        public function setHP(_arg_1:Number):void
        {
            updateEnemyStats({"stamina":_arg_1});
            setDamage(_arg_1);
            this.startHP = _arg_1;
            SSF2API.print(getDamage().toString());
        }

        public function receiveDamage(_arg_1:*):void
        {
            SSF2API.print(getDamage().toString());
            if (((getDamage() <= (this.startHP / 4)) && (!(this.damaged))))
            {
                this.damaged = true;
                if (this.state == this.MOTHER_BRAIN_IDLE)
                {
                    getStanceMC().gotoAndPlay("damaged");
                };
            };
            if (getDamage() >= 100)
            {
                removeEventListener(SSF2Event.ENEMY_HURT, this.receiveDamage);
                this.state = this.MOTHER_BRAIN_DESTROYED;
                this.timer = new FrameTimer(15);
                this.platform.destroy();
                forceAttack("destroyed");
            };
        }

        override public function update():void
        {
            switch (this.state)
            {
                case this.MOTHER_BRAIN_IDLE:
                    this.timer.tick();
                    if (this.timer.completed)
                    {
                        this.state = this.MOTHER_BRAIN_FADEOUT;
                        this.timer = new FrameTimer(15);
                        return;
                    };
                    if ((this.timer.elapsedFrames % 10) == 0)
                    {
                        fireProjectile("rinka", (-100 + (400 * SSF2API.random())), (100 * SSF2API.random()));
                        SSF2API.playSound("motherBrain_rinka");
                    };
                    if (SSF2API.random() < 0.01)
                    {
                        this.state = this.MOTHER_BRAIN_LASER;
                        SSF2API.playSound("motherBrain_charge");
                        forceAttack("laser", ((this.damaged) ? "damaged" : "normal"));
                    };
                    return;
                case this.MOTHER_BRAIN_LASER:
                    this.timer.tick();
                    if ((((this.timer.elapsedFrames % 10) == 0) && (!(this.timer.completed))))
                    {
                        fireProjectile("rinka", (-200 + (400 * SSF2API.random())), (100 * SSF2API.random()));
                        SSF2API.playSound("motherBrain_rinka");
                    };
                    return;
                case this.MOTHER_BRAIN_FADEOUT:
                    fadeOut();
                    this.timer.tick();
                    if (this.timer.completed)
                    {
                        removeFromCamera();
                        destroy();
                    };
                    return;
            };
        }

        override public function getOwnStats():Object
        {
            return ({
                "linkage_id":"mother_brain",
                "width":300,
                "height":300,
                "gravity":1,
                "max_ySpeed":15,
                "max_projectile":10000,
                "classAPI":MotherBrain,
                "canReceiveKnockback":false,
                "canReceiveDamage":true
            });
        }

        override public function getAttackStats():Object
        {
            return ({
                "spawn":{
                    "refreshRate":15,
                    "attackBoxes":{"attackBox":{
                            "damage":5,
                            "power":60,
                            "kbConstant":50,
                            "direction":45,
                            "hitStun":3,
                            "forceTumbleFall":true,
                            "effectSound":"brawl_punch_m",
                            "effect_id":"effect_hit1"
                        }}
                },
                "idle":{
                    "refreshRate":15,
                    "attackBoxes":{"attackBox":{
                            "damage":5,
                            "power":60,
                            "kbConstant":50,
                            "direction":45,
                            "hitStun":3,
                            "forceTumbleFall":true,
                            "effectSound":"brawl_punch_m",
                            "effect_id":"effect_hit1"
                        }}
                },
                "laser":{
                    "refreshRate":15,
                    "attackBoxes":{"attackBox":{
                            "damage":5,
                            "power":60,
                            "kbConstant":50,
                            "direction":45,
                            "hitStun":3,
                            "forceTumbleFall":true,
                            "effectSound":"brawl_punch_m",
                            "effect_id":"effect_hit1"
                        }}
                }
            });
        }

        public function flipX(_arg_1:Number):Number
        {
            if (this.isFacingRight())
            {
                return (_arg_1);
            };
            return (_arg_1 * -1);
        }

        override public function getProjectileStats():Object
        {
            return ({
                "rinka":{
                    "classAPI":SSF2Projectile,
                    "statsName":"rinka",
                    "linkage_id":"rinka",
                    "width":8,
                    "height":8,
                    "time_max":60,
                    "limit":400,
                    "limitOverwrite":true,
                    "ghost":true,
                    "canBePocketed":true,
                    "canBeReversed":true,
                    "canBeAbsorbed":true,
                    "attack_idle":{"attackBoxes":{"attackBox":{
                                "damage":6,
                                "power":80,
                                "kbConstant":70,
                                "direction":45,
                                "effect_id":"effect_hit2",
                                "effectSound":"brawl_fire_s"
                            }}}
                },
                "laser":{
                    "linkage_id":"mother_brain_laser",
                    "classAPI":SSF2Projectile,
                    "width":10,
                    "height":10,
                    "time_max":9,
                    "limit":10,
                    "limitOverwrite":true,
                    "ghost":true,
                    "canBePocketed":false,
                    "canBeReversed":false,
                    "canBeAbsorbed":true,
                    "attack_idle":{
                        "refreshRate":2,
                        "attackBoxes":{"attackBox":{
                                "damage":9,
                                "kbConstant":59,
                                "power":25,
                                "priority":-1,
                                "direction":80,
                                "hitStun":2,
                                "selfHitStun":1,
                                "effect_id":"effect_hit2",
                                "effectSound":"brawl_fire_s"
                            }}
                    }
                }
            });
        }


    }
}//package 

