// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//Protoman

package 
{
    import flash.display.MovieClip;

    public class Protoman extends SSF2Enemy 
    {

        public const PROTOMAN_IDLE:* = 0;
        public const PROTOMAN_DASH:* = 1;
        public const PROTOMAN_JUMP:* = 2;
        public const PROTOMAN_DESTROY:* = 7;

        public var m_action:Number;
        private var m_idleTimer:FrameTimer;
        private var m_walkTimer:FrameTimer;
        private var m_jumpTimer:FrameTimer;
        private var m_targetTimer:FrameTimer;
        private var m_attackTimer:FrameTimer;
        public var m_totalTimer:FrameTimer;
        private var m_fadeTimer:FrameTimer;
        private var m_health:Number;
        private var m_blinkTimer:FrameTimer;
        private var m_blinkToggle:Boolean;
        private var m_hitFromRight:Boolean;
        private var m_justHurt:Boolean;
        private var m_endTimer:FrameTimer;
        private var m_currentTarget:*;
        private var m_wasOnGround:Boolean;

        public function Protoman(_arg_1:*):void
        {
            super(_arg_1);
        }

        override public function initialize():void
        {
            forceAttack("entrance");
            this.m_action = -2;
            this.m_idleTimer = new FrameTimer(60);
            this.m_walkTimer = new FrameTimer(20);
            this.m_jumpTimer = new FrameTimer(4);
            this.m_targetTimer = new FrameTimer((30 * 3));
            this.m_attackTimer = new FrameTimer((30 * 2));
            this.m_totalTimer = new FrameTimer((30 * 15));
            this.m_health = 0;
            this.m_blinkTimer = new FrameTimer(2);
            this.m_blinkToggle = true;
            this.m_fadeTimer = new FrameTimer(15);
            this.m_hitFromRight = false;
            this.m_justHurt = false;
            this.m_wasOnGround = false;
            SSF2API.playSound("protoman_whistle");
            this.m_currentTarget = getNearest("character", true);
            if (this.m_currentTarget == null)
            {
                if (SSF2API.random() > 0.5)
                {
                    faceLeft();
                };
            }
            else
            {
                if (this.m_currentTarget.getX() < getX())
                {
                    faceLeft();
                };
            };
            this.m_endTimer = new FrameTimer((30 * 20));
            addToCamera();
            this.addEventListener(SSF2Event.ENEMY_DESTROYED, this.removeCamera, {"persistent":true});
        }

        override public function getOwnStats():Object
        {
            return ({
                "linkage_id":"protoman",
                "width":20,
                "height":20,
                "gravity":1,
                "max_ySpeed":10,
                "max_projectile":999,
                "classAPI":Protoman
            });
        }

        override public function getAttackStats():Object
        {
            return ({
                "bash":{
                    "refreshRate":4,
                    "attackBoxes":{"attackBox":{
                            "damage":7,
                            "priority":5,
                            "effect_id":"effect_hit1",
                            "direction":30,
                            "power":70,
                            "kbConstant":15,
                            "effectSound":"brawl_punch_m"
                        }}
                },
                "dash":{
                    "refreshRate":4,
                    "attackBoxes":{"attackBox":{
                            "damage":1,
                            "priority":4,
                            "effect_id":"effect_hit1",
                            "direction":30,
                            "power":70,
                            "kbConstant":15,
                            "effectSound":"brawl_punch_s"
                        }}
                }
            });
        }

        override public function getProjectileStats():Object
        {
            return ({
                "shot1":{
                    "classAPI":SSF2Projectile,
                    "statsName":"shot1",
                    "linkage_id":"protoman_shot",
                    "width":8,
                    "height":8,
                    "xspeed":11,
                    "xoffset":24.8,
                    "yoffset":-16.1,
                    "limit":9999,
                    "limitOverwrite":true,
                    "canBePocketed":true,
                    "canBeReversed":true,
                    "canBeAbsorbed":true,
                    "attack_idle":{"attackBoxes":{"attackBox":{
                                "damage":2,
                                "priority":5,
                                "effect_id":"effect_hit2",
                                "direction":20,
                                "power":45,
                                "kbConstant":25,
                                "effectSound":"brawl_zap_s"
                            }}}
                },
                "shot2":{
                    "classAPI":SSF2Projectile,
                    "statsName":"shot2",
                    "linkage_id":"protoman_shot",
                    "width":8,
                    "height":8,
                    "time_max":90,
                    "xspeed":11,
                    "xoffset":24.8,
                    "yoffset":-16.1,
                    "limit":9999,
                    "limitOverwrite":true,
                    "canBePocketed":true,
                    "canBeReversed":true,
                    "canBeAbsorbed":true,
                    "attack_idle":{"attackBoxes":{"attackBox":{
                                "damage":2,
                                "priority":5,
                                "effect_id":"effect_hit2",
                                "direction":20,
                                "power":45,
                                "kbConstant":25,
                                "effectSound":"brawl_zap_s"
                            }}}
                },
                "chargeblast":{
                    "classAPI":SSF2Projectile,
                    "statsName":"chargeblast",
                    "linkage_id":"protoman_chargeblast",
                    "width":30,
                    "height":30,
                    "xspeed":13,
                    "xoffset":42.6,
                    "yoffset":-9.9,
                    "limit":999,
                    "limitOverwrite":true,
                    "canBePocketed":true,
                    "canBeReversed":true,
                    "canBeAbsorbed":true,
                    "attack_idle":{"attackBoxes":{"attackBox":{
                                "damage":11,
                                "priority":5,
                                "effect_id":"effect_hit2",
                                "direction":20,
                                "power":85,
                                "kbConstant":50,
                                "effectSound":"brawl_zap_m"
                            }}}
                }
            });
        }

        private function runAI():void
        {
            var _local_3:Number;
            var _local_4:Number;
            var _local_5:Boolean;
            var _local_6:Boolean;
            var _local_7:Boolean;
            if ((((!(this.m_wasOnGround)) && (isOnGround())) && (this.m_action > this.PROTOMAN_IDLE)))
            {
            };
            if (((!(this.m_action == this.PROTOMAN_DESTROY)) && (this.m_action >= this.PROTOMAN_IDLE)))
            {
                this.m_totalTimer.tick();
                if (((this.m_totalTimer.completed) || (this.m_currentTarget == null)))
                {
                    this.m_action = this.PROTOMAN_DESTROY;
                    resetFade();
                };
            };
            this.m_targetTimer.tick();
            if (this.m_targetTimer.completed)
            {
                this.m_targetTimer.reset();
                this.m_currentTarget = getNearest("character", true);
            };
            var _local_1:* = null;
            var _local_2:MovieClip;
            if (this.m_action == -2)
            {
                if (this.m_idleTimer.elapsedFrames == 0)
                {
                    forceAttack("exit");
                    stancePlayFrame(4);
                };
                if (getStanceMC().currentFrame >= 20)
                {
                    forceAttack("entrance");
                    getMC().visible = false;
                };
                this.m_idleTimer.tick();
                if (this.m_idleTimer.completed)
                {
                    this.m_idleTimer.reset();
                    this.m_idleTimer.duration = 15;
                    this.m_action = -1;
                    stancePlayFrame(0);
                    this.m_currentTarget = getNearest("character", true);
                    if (this.m_currentTarget == null)
                    {
                        if (SSF2API.random() > 0.5)
                        {
                            faceLeft();
                        };
                    }
                    else
                    {
                        if (SSF2API.random() > 0.5)
                        {
                            faceLeft();
                        };
                        _local_3 = getX();
                        _local_4 = getY();
                        setX(this.m_currentTarget.getX());
                        setY(this.m_currentTarget.getY());
                        while (((!(SSF2API.hitTestGround(getX(), getY()))) && ((getY() - _local_4) < 200)))
                        {
                            setY((getY() + 1));
                        };
                        if ((getY() - _local_4) >= 200)
                        {
                            setX(_local_3);
                            setY(_local_4);
                        }
                        else
                        {
                            attachToGround();
                        };
                    };
                    getMC().visible = true;
                };
            };
            if (this.m_action == -1)
            {
                if (getStanceMC().currentFrame >= 19)
                {
                    this.m_action = this.PROTOMAN_IDLE;
                    forceAttack("idle");
                };
            }
            else
            {
                if (this.m_action == this.PROTOMAN_IDLE)
                {
                    this.m_idleTimer.tick();
                    if (this.m_idleTimer.completed)
                    {
                        this.m_action = this.PROTOMAN_DASH;
                        forceAttack("dash");
                        SSF2API.playSound("protoman_dash");
                    };
                }
                else
                {
                    if (this.m_action == this.PROTOMAN_DASH)
                    {
                        this.m_walkTimer.tick();
                        setXSpeed(((isFacingRight()) ? 12 : -12));
                        if (((this.m_walkTimer.completed) && (isOnGround())))
                        {
                            setXSpeed(0);
                            this.m_walkTimer.reset();
                            this.m_walkTimer.duration = 15;
                            if (this.m_currentTarget != null)
                            {
                                if (this.m_currentTarget.getX() < getX())
                                {
                                    _local_2 = SSF2API.attachEffectOverlay("effect_run", {
                                        "x":getStageParentPosition().x,
                                        "y":getStageParentPosition().y,
                                        "scaleX":((isFacingRight()) ? 1 : -1)
                                    });
                                    _local_2.alpha = 0.75;
                                    if (isFacingRight())
                                    {
                                        faceLeft();
                                    }
                                    else
                                    {
                                        faceRight();
                                    };
                                };
                            };
                            if (SSF2API.random() > 0.75)
                            {
                                this.m_jumpTimer.reset();
                                forceAttack("jump");
                                this.m_action = 5;
                                unnattachFromGround();
                                setYSpeed(-14);
                            }
                            else
                            {
                                if (SSF2API.random() < 0.25)
                                {
                                    this.m_action = 3;
                                    setXSpeed(0);
                                    setYSpeed(0);
                                    forceAttack("shoot");
                                }
                                else
                                {
                                    this.m_action = 4;
                                    setXSpeed(0);
                                    setYSpeed(0);
                                    forceAttack("charge_shoot");
                                };
                            };
                        }
                        else
                        {
                            _local_5 = ((isOnGround()) && (!(SSF2API.hitTestGround(((getXSpeed() > 0) ? ((getX() + getXSpeed()) + 9) : ((getX() + getXSpeed()) - 5)), (getY() + 9)))));
                            _local_6 = ((getXSpeed() < 0) && (SSF2API.hitTestGround(((getX() + getXSpeed()) - (getWidth() / 2)), ((getY() + getYSpeed()) - 35))));
                            _local_7 = ((getXSpeed() > 0) && (SSF2API.hitTestGround(((getX() + getXSpeed()) + (getWidth() / 2)), ((getY() + getYSpeed()) - 35))));
                            if ((((_local_5) || ((_local_7) && (getXSpeed() > 0))) || ((_local_6) && (getXSpeed() < 0))))
                            {
                                if (isFacingRight())
                                {
                                    faceLeft();
                                }
                                else
                                {
                                    faceRight();
                                };
                            };
                        };
                    }
                    else
                    {
                        if (this.m_action == this.PROTOMAN_JUMP)
                        {
                            this.m_jumpTimer.tick();
                            if (((getYSpeed() >= 0) && (!(getCurrentAnimation() === "fall"))))
                            {
                                forceAttack("fall");
                            };
                            if (isOnGround())
                            {
                                this.m_idleTimer.reset();
                                this.m_action = this.PROTOMAN_IDLE;
                                forceAttack("idle");
                            };
                        }
                        else
                        {
                            if (this.m_action == 5)
                            {
                                if (((getYSpeed() >= -4) && (!(isOnGround()))))
                                {
                                    forceAttack("spread_shoot");
                                    this.m_action = 6;
                                }
                                else
                                {
                                    if (isOnGround())
                                    {
                                        this.m_idleTimer.reset();
                                        this.m_action = this.PROTOMAN_IDLE;
                                        forceAttack("idle");
                                    };
                                };
                            }
                            else
                            {
                                if (this.m_action == this.PROTOMAN_DESTROY)
                                {
                                    fadeOut();
                                    this.m_fadeTimer.tick();
                                    if (this.m_fadeTimer.completed)
                                    {
                                        attachEffect("enemy_disappear");
                                        destroy();
                                    };
                                };
                            };
                        };
                    };
                };
            };
            this.m_wasOnGround = isOnGround();
        }

        override public function update():void
        {
            this.runAI();
        }

        private function removeCamera(_arg_1:*=null):*
        {
            this.removeFromCamera();
        }


    }
}//package 

