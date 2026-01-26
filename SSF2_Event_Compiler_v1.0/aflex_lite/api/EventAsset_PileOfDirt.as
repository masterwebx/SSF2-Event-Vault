// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//EventAsset_PileOfDirt

package 
{
    public class EventAsset_PileOfDirt extends SSF2Enemy 
    {

        public function EventAsset_PileOfDirt(_arg_1:*):void
        {
            super(_arg_1);
        }

        override public function initialize():void
        {
            forceAttack("idle");
            this.forceOnGround();
            setHurtInterrupt(this.handleHurtInterrupt);
            addEventListener(SSF2Event.ENEMY_HURT, this.onHurt, {"persistent":true});
        }

        override public function getOwnStats():Object
        {
            return ({
                "linkage_id":"pile_of_dirt",
                "width":20,
                "height":20,
                "gravity":1,
                "max_ySpeed":14,
                "ghost":false,
                "canReceiveKnockback":false
            });
        }

        override public function getAttackStats():Object
        {
            return (null);
        }

        override public function update():void
        {
        }

        private function handleHurtInterrupt(_arg_1:Object):Boolean
        {
            if (_arg_1.target.getType() == "SSF2Character")
            {
                if (((_arg_1.target.getCharacterStat("linkage_id") == "chibirobo") && ((_arg_1.target.getCurrentAttackFrame() == "b_forward") || (_arg_1.target.getCurrentAttackFrame() == "b_forward_air"))))
                {
                    this.attachEffect("effect_waterhit_heavy");
                    return (false);
                };
                return (true);
            };
            return (true);
        }

        public function onHurt(_arg_1:*):void
        {
            this.destroy();
        }


    }
}//package 

