package  {
	
	public dynamic class EventAsset_CherishBall extends SSF2Item{
		public var state:Number;
		public var foe:* = null;		
		public var bounceLand:Boolean;
		public var trapTime:Number;
		
		public function EventAsset_CherishBall(api:*):void {
			super(api);
		}

		public override function initialize():void 
 		{
			addEventListener(SSF2Event.ATTACK_HIT_SHIELD, open, { persistent: true });
			addEventListener(SSF2Event.ATTACK_HIT, open, { persistent: true });
			addEventListener(SSF2Event.GROUND_TOUCH, open, { persistent: true });
			addEventListener(SSF2Event.ITEM_DESTROYED, foeRelease, { persistent: true });
			setFrameInterrupt(handleInterrupt);
			state = 0;
			foe = null;
			bounceLand = true;
			trapTime = 0;
		}
 		public override function update():void 
 		{				
			if(inState(IState.HOLD))
				resetKnockback();
			
			if(state == 2 && foe){			
				foe.setCamBoxSize(this.getMC().width*1.35, this.getMC().height*1.35)
				foe.setX(getX());
				foe.setY(getY());
				foe.forceHitStun(6,0); //REMOVE SOON
				resetTime();
				//trapTime--;
				foe.setSizeStatus(-1); 
				if(trapTime < 0){
					toIdle();
					getStanceMC().gotoAndStop("finish");
					foe.removeEventListener(SSF2Event.CHAR_KO_DEATH, foeDead);
					foe.setYSpeed(-10);
					foe.setVisibility(true);
					foe.release();
					foe.toFlying();
					foe.applyKnockback(SSF2API.calculateKnockback(0, 115, 50, 0, 0, foe.getCharacterStat("weight1"), false), 50);

					attachEffect("global_sparkle");
					attachEffect("global_dust_swirl");
					attachEffect("pokeball_light");
					SSF2API.playSound("pokeball_open");
					state = 3;
					foe.setSizeStatus(1); 
				}
			}
		
		}
		
		public function handleInterrupt(status:Object):Boolean
		{
			//Override the following actions
			var grounded:Array = ["a", "a_forward", "a_forwardsmash", "a_forward_tilt", "a_up", "a_up_tilt", "a_down", "crouch_attack", "grab" ];
			var aerials:Array = ["a_air", "a_air_up", "a_air_forward", "a_air_backward", "a_air_down"];
			
			//Determine what type of action occured
			var wasGrounded:Boolean = (grounded.indexOf(status.targetFrame) >= 0);
			var wasAerial:Boolean = (aerials.indexOf(status.targetFrame) >= 0);
			
			//If an interruptable move
			if ((wasGrounded || wasAerial) && state < 3){
				//Toss item
				getOwner().toToss();
				
				//Inform engine to interrupt
				return true;
			}
			
			//Do not interrupt
			return false;
		}
		public function open(e:*):void{
			if(state == 0){ //no one captured, just landing after spawn
				if(inState(IState.TOSS)){
					if(!isOnGround()){
						setXSpeed(getXSpeed()*-0.2);
						setYSpeed(-6);
						state = 1;
						toIdle();
						getStanceMC().gotoAndStop("open");
						removeEventListener(SSF2Event.ATTACK_HIT, open);
						removeEventListener(SSF2Event.ATTACK_HIT_SHIELD, open);
						addEventListener(SSF2Event.ATTACK_HIT, capture, { persistent: true });
						addEventListener(SSF2Event.ATTACK_HIT_SHIELD, capture, { persistent: true });
					}else{
						destroy();
					}
				}
			}else if(state == 2){ // someone captured, landing after throw
					if(inState(IState.TOSS) && getStanceMC().currentLabel != "open"){
						toIdle();
						resetKnockback();
						updateItemStats({canReceiveKnockback:false});
						getStanceMC().gotoAndStop("closeloop");
					}
			}else if(inState(IState.TOSS) && !isOnGround()){
				setXSpeed(getXSpeed()*-0.2);
				setYSpeed(-6);
			}
		}
		public function capture(e:*):void{
			if(state == 1){
				foe = e.data.receiver;
				foe.setSizeStatus(-1);
				foe.setSizeStatus(-1); //INTENTIONALLY HERE TWICE LEAVE THIS ALONE FUCKOOS.
				state = 2;
				updateItemStats({ canReceiveKnockback:true, ghost:true});
				trapTime = 30 + (foe.getDamage()*0.65);
				setDamage(foe.getDamage());
				foe.grab(getOwner().getID(), false, true);
				foe.toBarrel();
				foe.setVisibility(false);
				foe.setIntangibility(true);
				foe.addEventListener(SSF2Event.CHAR_KO_DEATH, foeDead, { persistent:true});

				if(trapTime > 210){trapTime = 210;}
					getStanceMC().gotoAndStop("close");
			}
		}
		public function foeDead(e:*):void{
			state = 3;
			foe.removeEventListener(SSF2Event.CHAR_KO_DEATH, foeDead);
			destroy();
		}
		public function foeRelease(e:*):void{
			if(foe){
				foe.setVisibility(true);
				foe.release();
			}
			removeEventListener(SSF2Event.ITEM_DESTROYED, foeRelease);
		}
		public function damaged(e:*):void{
			//ow
			
		}
	}
	
}
