// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//SSF2MultiManMatch

package 
{
    import flash.display.MovieClip;

    public class SSF2MultiManMatch extends SSF2CustomMatch 
    {

        public static const SURVIVAL:int = 0;
        public static const TIMED:int = 1;
        public static const KO_BASED:int = 2;
        public static const TIMED_KO_EVENT:int = 3;

        public var bodyCount:int;
        public var winCondition:int;
        public var maxTime:int;
        public var difficultySettings:Object;
        public var musicOverride:String;
        public var stageOverride:String;
        public var itemOverride:Boolean;
        public var playerCharOverride:String;
        public var stockOverride:int;
        public var isCruel:Boolean;
        public var iconOverride:String;
        public var characterLock:Boolean = false;
        public var spawnCount:int;
        private var currentEnemyCount:int;
        private var spawnTimer:FrameTimer;
        private var spawningPoints:Array;
        public var charArray:Array = ["mario", "kirby", "link", "pikachu"];
        private var failureFlag:Boolean = false;
        private var countHUD:MovieClip;
        public var keepCameraAway:Boolean = true;
        public var displayCountHUD:Boolean = true;
        public var overrideTimer:Boolean = false;
        private var KOScore:int = 0;
        protected var replaySave:Boolean = false;
        public var spawnPlayer:Boolean = false;
        public var MAX_ENEMIES_ON_SCREEN:int = 3;
        private var lastSpawnedCharacter:String = null;

        public function SSF2MultiManMatch(_arg_1:*)
        {
            super(_arg_1);
        }

        public function getKOScore():int
        {
            return (this.KOScore);
        }

        public function onEnemyKill(_arg_1:*=null):*
        {
            this.bodyCount = (((this.winCondition == KO_BASED) || (this.winCondition == TIMED_KO_EVENT)) ? (this.bodyCount - 1) : (this.bodyCount + 1));
            this.currentEnemyCount--;
            this.spawnTimer.reset();
            this.countHUD.bodyCountDisplayText.text = this.bodyCount.toString();
            _arg_1.data.caller.detachHealthBox();
            SSF2API.getCamera().deleteTarget(_arg_1.data.caller.getMC());
            _arg_1.data.caller.destroy();
            this.KOScore++;
        }

        public function onDamageChanged(_arg_1:*=null):*
        {
            if (_arg_1.data.caller.getDamage() > matchData.damage)
            {
                matchData.damage = _arg_1.data.caller.getDamage();
            };
        }

        public function onPlayerKO(_arg_1:*=null):*
        {
            if (this.winCondition == SURVIVAL)
            {
                matchData.success = (this.bodyCount > 0);
                SSF2API.endGame({
                    "success":(this.bodyCount > 0),
                    "immediate":false,
                    "replaySave":this.replaySave,
                    "record":((this.bodyCount > 0) ? this.saveScore() : false)
                });
            }
            else
            {
                matchData.success = false;
                SSF2API.endGame({
                    "success":false,
                    "immediate":false
                });
            };
        }

        private function saveScore():Boolean
        {
            var _local_1:String = ((SSF2API.getCustomMode().getModeSettings().multiManModeID) || (null));
            var _local_2:Boolean;
            if (_local_1 == "man10")
            {
                if (matchData.success)
                {
                    _local_2 = SSF2API.getCustomMode().saveModeData({
                        "type":"multiman",
                        "matchData":{
                            "scoreType":"time",
                            "score":matchData.time
                        }
                    });
                }
                else
                {
                    _local_2 = SSF2API.getCustomMode().saveModeData({
                        "type":"multiman",
                        "matchData":{
                            "scoreType":"kos",
                            "score":this.getKOScore()
                        }
                    });
                };
            }
            else
            {
                if (_local_1 == "man100")
                {
                    if (matchData.success)
                    {
                        _local_2 = SSF2API.getCustomMode().saveModeData({
                            "type":"multiman",
                            "matchData":{
                                "scoreType":"time",
                                "score":matchData.time
                            }
                        });
                    }
                    else
                    {
                        _local_2 = SSF2API.getCustomMode().saveModeData({
                            "type":"multiman",
                            "matchData":{
                                "scoreType":"kos",
                                "score":this.getKOScore()
                            }
                        });
                    };
                }
                else
                {
                    if ((((_local_1 == "min3") || (_local_1 == "endless")) || (_local_1 == "cruel")))
                    {
                        _local_2 = SSF2API.getCustomMode().saveModeData({
                            "type":"multiman",
                            "matchData":{
                                "scoreType":"kos",
                                "score":this.getKOScore(),
                                "damage":matchData.damage
                            }
                        });
                    };
                };
            };
            return (_local_2);
        }

        override public function initialize():void
        {
            var _local_2:*;
            var _local_3:Object;
            var _local_4:*;
            this.initMatch();
            SSF2API.getPlayer(1).faceRight();
            this.currentEnemyCount = 0;
            this.KOScore = 0;
            this.spawnTimer = new FrameTimer(30);
            this.spawningPoints = SSF2API.getStage().getSpawnPositionMCs();
            SSF2API.print(this.spawningPoints.length.toString());
            this.countHUD = SSF2API.getStage().getHUDForegroundMC().addChild(SSF2API.getMCByLinkageName("multiman_hud_display"));
            if (this.iconOverride != null)
            {
                this.countHUD.removeChild(this.countHUD.placeholder);
                _local_2 = this.countHUD.addChild(SSF2API.getMCByLinkageName((this.iconOverride + "_stock")));
                _local_2.x = -1;
                _local_2.y = -56;
                _local_2.scaleX = 0.25;
                _local_2.scaleY = 0.25;
                _local_3 = SSF2API.getCostumeData(this.iconOverride, -1, -1);
                if (_local_3)
                {
                    SSF2Utils.setColorFilters(_local_2, _local_3);
                    if (_local_3.paletteSwap)
                    {
                        SSF2Utils.replacePalette(_local_2, _local_3.paletteSwap, 2, false, true);
                    };
                };
            };
            this.countHUD.x = -300;
            this.countHUD.y = -100;
            if (SSF2API.isDebug())
            {
                this.countHUD.y = -50;
            };
            this.countHUD.bodyCountDisplayText.text = this.bodyCount.toString();
            this.countHUD.visible = this.displayCountHUD;
            if (this.keepCameraAway)
            {
                SSF2API.getCamera().updateCameraParameters({"minZoomHeight":400});
            };
            if (!this.overrideTimer)
            {
                if (this.winCondition == TIMED_KO_EVENT)
                {
                    SSF2API.getGameTimer().setEndGameOptions({
                        "success":false,
                        "immediate":false,
                        "exit":true
                    });
                }
                else
                {
                    SSF2API.getGameTimer().setEndGameOptions({
                        "success":true,
                        "immediate":false,
                        "exit":true
                    });
                };
            };
            SSF2API.getPlayers()[0].addEventListener(SSF2Event.CHAR_KO_DEATH, this.onPlayerKO, {"persistent":true});
            SSF2API.getPlayers()[0].addEventListener(SSF2Event.DAMAGE_CHANGED, this.onDamageChanged, {"persistent":true});
            matchData.damage = 0;
            var _local_1:int;
            while (_local_1 < this.charArray.length)
            {
                _local_4 = SSF2API.spawnCharacter(SSF2API.getCharacterStats(this.charArray[_local_1]).classAPI);
                _local_4.destroy();
                _local_1++;
            };
        }

        override public function matchSetup(_arg_1:Object):Object
        {
            var _local_5:*;
            var _local_6:Array;
            var _local_2:Object = {
                "playerSettings":[],
                "levelData":_arg_1.levelData,
                "items":_arg_1.items
            };
            this.initMatch(_local_2);
            _local_2.playerSettings.push({
                "character":((this.playerCharOverride != null) ? this.playerCharOverride : _arg_1.playerSettings[0].character),
                "name":_arg_1.playerSettings[0].name,
                "costume":_arg_1.playerSettings[0].costume,
                "lives":((this.stockOverride > 0) ? this.stockOverride : 1),
                "human":true,
                "team":-1
            });
            _local_2.levelData.usingLives = true;
            _local_2.levelData.usingTime = true;
            _local_2.levelData.teamDamage = false;
            _local_2.levelData.countdown = ((this.winCondition == TIMED) || (this.winCondition == TIMED_KO_EVENT));
            _local_2.levelData.lives = 1;
            _local_2.levelData.time = this.maxTime;
            _local_2.levelData.hazards = true;
            _local_2.levelData.showEntrances = false;
            _local_2.levelData.showCountdownType = 3;
            _local_2.levelData.stage = ((this.stageOverride != null) ? this.stageOverride : "battlefield2");
            if (this.musicOverride != "default")
            {
                _local_2.levelData.musicOverride = ((this.musicOverride != null) ? this.musicOverride : "bgm_multimansmash");
            };
            if (this.isCruel)
            {
                _local_2.levelData.musicOverride = "bgm_cruelsmash";
            };
            _local_2.levelData.teamDamage = false;
            if (!this.itemOverride)
            {
                _local_2.items.frequency = ((this.isCruel) ? ItemSettings.FREQUENCY_OFF : ItemSettings.FREQUENCY_HIGH);
            };
            var _local_3:Array = ["partyball", "spinyShell", "energytank", "heartContainer", "potion", "maximtomato", "fooditem", "smashball", "bloodsword"];
            var _local_4:Object = new Object();
            if (!this.itemOverride)
            {
                _local_5 = 0;
                while (_local_5 < _local_3.length)
                {
                    _local_4[_local_3[_local_5]] = 0;
                    _local_5++;
                };
                _local_2.items.items = _local_4;
            };
            if (this.itemOverride)
            {
                _local_2.items.frequency = ItemSettings.FREQUENCY_MEDIUM;
                _local_6 = SSF2API.getItemStatsList();
                _local_5 = 0;
                while (_local_5 < _local_6.length)
                {
                    delete _local_2.items.items[_local_6[_local_5].statsName];
                    _local_5++;
                };
            };
            return (_local_2);
        }

        override public function update():void
        {
            var _local_1:Object;
            var _local_2:*;
            var _local_3:MovieClip;
            if (((!(SSF2API.isGameStarted())) && (!(SSF2API.isGameEnded()))))
            {
                this.updateExt();
                if ((((this.winCondition == KO_BASED) || (this.winCondition == TIMED_KO_EVENT)) && (this.bodyCount <= 0)))
                {
                    this.onSuccess();
                    return;
                };
                this.spawnTimer.tick();
                while (((this.currentEnemyCount < this.MAX_ENEMIES_ON_SCREEN) && (this.spawnTimer.completed)))
                {
                    if ((((!(this.winCondition == KO_BASED)) && (!(this.winCondition == TIMED_KO_EVENT))) || (this.spawnCount > 0)))
                    {
                        if (!this.spawnPlayer)
                        {
                            _local_1 = this.generateNextEnemy();
                        }
                        else
                        {
                            _local_1 = {"characterID":SSF2API.getPlayer(1).getCharacterStat("statsName")};
                            _local_1.isMultiman = false;
                        };
                        _local_1.isMultiman = ((_local_1.isMultiman !== undefined) ? _local_1.isMultiman : true);
                        _local_1.level = ((_local_1.level !== undefined) ? _local_1.level : this.difficultySettings.level);
                        _local_1.size = ((_local_1.size !== undefined) ? _local_1.size : 0);
                        _local_1.metal = ((_local_1.metal !== undefined) ? _local_1.metal : false);
                        _local_2 = SSF2API.spawnCharacter(SSF2API.getCharacterStats(_local_1.characterID).classAPI);
                        if (_local_1.characterID == "sheik")
                        {
                            _local_2.replaceCharacter("sheik");
                        };
                        if ((((_local_1.characterID == "zelda") || (_local_1.characterID == "zelda")) && (this.characterLock)))
                        {
                            _local_2.setAttackEnabled(false, "b_down");
                            _local_2.setAttackEnabled(false, "b_down_air");
                        };
                        if (_local_2 != null)
                        {
                            this.enemySpawned(_local_2);
                            if (this.spawningPoints != null)
                            {
                                _local_3 = this.spawningPoints[SSF2API.randomInteger(0, (this.spawningPoints.length - 1))];
                                if (_local_3 != null)
                                {
                                    _local_2.setX(_local_3.x);
                                    _local_2.setY(_local_3.y);
                                };
                            };
                            _local_2.setTeamID(3);
                            if (_local_1.isMultiman)
                            {
                                _local_2.setColorFilters(this.getMultimanCostumeData(_local_1.characterID));
                                _local_2.setPaletteSwapData(this.getMultimanCostumeData(_local_1.characterID));
                                _local_2.updateCharacterStats({
                                    "canTaunt":false,
                                    "canShield":((this.difficultySettings.canShield !== undefined) ? this.difficultySettings.canShield : false),
                                    "canDodge":((this.difficultySettings.canDodge !== undefined) ? this.difficultySettings.canDodge : false),
                                    "canThrow":false,
                                    "canHoldItems":false,
                                    "canUseItems":false,
                                    "canGrabLedges":false,
                                    "canUseSpecials":false,
                                    "weight1":85
                                });
                            };
                            _local_2.setHumanControl(false, _local_1.level);
                            _local_2.updateCharacterStats({
                                "attackRatio":this.difficultySettings.attackRatio,
                                "damageRatio":this.difficultySettings.damageRatio,
                                "canStarKO":false
                            });
                            if (_local_1.size != 0)
                            {
                                _local_2.setSizeStatus(_local_1.size);
                                _local_2.lockSizeStatus(true);
                            };
                            if (_local_1.metal)
                            {
                                _local_2.setMetalStatus(true);
                            };
                            _local_2.attachHealthBox(((_local_1.isMultiman) ? "SILHOUETTE" : _local_2.getCharacterStat("displayName").toUpperCase()), _local_2.getCharacterStat("thumbnail"), ((_local_1.isMultiman) ? "smash_symbol" : _local_2.getCharacterStat("seriesIcon")));
                            SSF2API.getCamera().addTarget(_local_2.getMC());
                            this.currentEnemyCount++;
                            if (this.spawnCount >= 0)
                            {
                                this.spawnCount--;
                            };
                            _local_2.addEventListener(SSF2Event.CHAR_KO_DEATH, this.onEnemyKill, {"persistent":true});
                        };
                    }
                    else
                    {
                        return;
                    };
                };
            };
        }

        public function generateNextEnemy():Object
        {
            var _local_1:*;
            do 
            {
                _local_1 = this.charArray[SSF2API.randomInteger(0, (this.charArray.length - 1))];
            } while (_local_1 == this.lastSpawnedCharacter);
            this.lastSpawnedCharacter = _local_1;
            return ({"characterID":_local_1});
        }

        public function onSuccess():void
        {
            matchData.success = true;
            SSF2API.endGame({
                "success":true,
                "immediate":false,
                "record":this.saveScore()
            });
        }

        public function initMatch(_arg_1:Object=null):void
        {
        }

        public function updateExt():void
        {
        }

        public function enemySpawned(_arg_1:*):void
        {
        }

        private function getMultimanCostumeData(_arg_1:String):Object
        {
            if (_arg_1 == "mario")
            {
                if (this.isCruel)
                {
                    return ({
                        "paletteSwap":{
                            "colors":[4285913463, 4281313330, 4280781609, 4280117023, 4279652375, 4280559627, 4294767332, 4293967741, 4291392835, 4286596644, 0xFF00A2E8, 0xFF008DCA, 0xFF004B6C, 4294883981, 4294089322, 4291064653, 4286987563, 4280290315, 4294309365, 4291217094, 4286940549, 0xFF0055BD, 4279042890, 0xFF000000, 4278519045, 4285936144, 4283311631, 4281341711, 4293533987, 4290582298, 4287042323, 4284287244, 4280944907, 4282411195, 4281354895, 4280431722, 4279903057, 4279242529, 0xFFFFEC6D, 4292192056, 4287521816, 4294441193, 4292334512, 4289504347, 4285623097, 4280492306, 4287914298, 4285286959, 4282724383, 4279635724, 4291069517, 4287453998, 4281869330, 0xFFFFFF01, 4292456195, 0xFF937400, 0xFF6A5500, 0xFFFFFDF5, 4294897570, 4294755204, 4293036114, 4288370206, 4283050511, 4294111210, 4284826156, 4279111180, 4288540822, 4286958975, 4284330057, 4282091315, 4281496108, 4280703266, 4279579411, 4278785288, 4281719551, 4279589224],
                            "replacements":[4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4278650631, 4283190348, 4288256409, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4293256677, 4288256409, 4290756543, 4293256677, 0xFFFFFF01, 4292456195, 0xFF937400, 0xFF6A5500, 0xFFFFFDF5, 4294897570, 4294755204, 4293036114, 4288370206, 4283050511, 4294111210, 4284826156, 4279111180, 4288540822, 4286958975, 4284330057, 4282091315, 4281496108, 4280703266, 4279579411, 4278785288, 4293256677, 4293256677]
                        },
                        "paletteSwapPA":{
                            "colors":[4281313330, 4280781609, 4280117023, 4279652375, 4280559627, 4294767332, 4293967741, 4291392835, 4286596644, 4283901191, 0xFF00A2E8, 0xFF008DCA, 0xFF004B6C, 0xFF00212F, 4294889391, 4294883981, 4294089322, 4291064653, 4286987563, 4280290315, 4294309365, 4291217094, 4286940549, 4281743419, 4284984319, 0xFF0073FF, 0xFF0055BD, 4279042890, 0xFF000000, 4281477418, 4280293400, 4278519045, 4285936144, 4283311631, 4281341711, 4280158983, 4293533987, 4290582298, 4287042323, 4284287244, 4280944907, 4282411195, 4281354895, 4280431722, 4279903057, 4279242529, 0xFFFFEC6D, 4292192056, 4287521816, 4283448338, 4294441193, 4292334512, 4289504347, 4285623097, 4280492306, 4291071846, 4287914298, 4285286959, 4282724383, 4281343763, 4280357898, 4279635724, 4291069517, 4287453998, 4286271025, 4285154338, 4281869330],
                            "replacements":[4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4278650631, 4278650631, 4283190348, 4288256409, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4288256409, 4290756543, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4278650631, 4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4280690214, 4283190348, 4283190348, 4288256409, 4293256677, 4288256409, 4290756543, 4290756543, 4290756543, 4293256677]
                        }
                    });
                };
                return ({
                    "paletteSwap":{
                        "colors":[4285913463, 4281313330, 4280781609, 4280117023, 4279652375, 4280559627, 4294767332, 4293967741, 4291392835, 4286596644, 0xFF00A2E8, 0xFF008DCA, 0xFF004B6C, 4294883981, 4294089322, 4291064653, 4286987563, 4280290315, 4294309365, 4291217094, 4286940549, 0xFF0055BD, 4279042890, 0xFF000000, 4278519045, 4285936144, 4283311631, 4281341711, 4293533987, 4290582298, 4287042323, 4284287244, 4280944907, 4282411195, 4281354895, 4280431722, 4279903057, 4279242529, 0xFFFFEC6D, 4292192056, 4287521816, 4294441193, 4292334512, 4289504347, 4285623097, 4280492306, 4287914298, 4285286959, 4282724383, 4279635724, 4291069517, 4287453998, 4281869330, 0xFFFFFF01, 4292456195, 0xFF937400, 0xFF6A5500, 0xFFFFFDF5, 4294897570, 4294755204, 4293036114, 4288370206, 4283050511, 4294111210, 4284826156, 4279111180, 4288540822, 4286958975, 4284330057, 4282091315, 4281496108, 4280703266, 4279579411, 4278785288, 4281719551, 4279589224],
                        "replacements":[4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4278650631, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4293256677, 4288256409, 4290756543, 4293256677, 0xFFFFFF01, 4292456195, 0xFF937400, 0xFF6A5500, 0xFFFFFDF5, 4294897570, 4294755204, 4293036114, 4288370206, 4283050511, 4294111210, 4284826156, 4279111180, 4288540822, 4286958975, 4284330057, 4282091315, 4281496108, 4280703266, 4279579411, 4278785288, 4293256677, 4293256677]
                    },
                    "paletteSwapPA":{
                        "colors":[4281313330, 4280781609, 4280117023, 4279652375, 4280559627, 4294767332, 4293967741, 4291392835, 4286596644, 4283901191, 0xFF00A2E8, 0xFF008DCA, 0xFF004B6C, 0xFF00212F, 4294889391, 4294883981, 4294089322, 4291064653, 4286987563, 4280290315, 4294309365, 4291217094, 4286940549, 4281743419, 4284984319, 0xFF0073FF, 0xFF0055BD, 4279042890, 0xFF000000, 4281477418, 4280293400, 4278519045, 4285936144, 4283311631, 4281341711, 4280158983, 4293533987, 4290582298, 4287042323, 4284287244, 4280944907, 4282411195, 4281354895, 4280431722, 4279903057, 4279242529, 0xFFFFEC6D, 4292192056, 4287521816, 4283448338, 4294441193, 4292334512, 4289504347, 4285623097, 4280492306, 4291071846, 4287914298, 4285286959, 4282724383, 4281343763, 4280357898, 4279635724, 4291069517, 4287453998, 4286271025, 4285154338, 4281869330],
                        "replacements":[4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4278650631, 4278650631, 4283190348, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4288256409, 4290756543, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4278650631, 4278650631, 4278650631, 4280690214, 4283190348, 4288256409, 4293256677, 4278650631, 4278650631, 4280690214, 4283190348, 4283190348, 4288256409, 4293256677, 4288256409, 4290756543, 4290756543, 4290756543, 4293256677]
                    }
                });
            };
            if (_arg_1 == "link")
            {
                if (this.isCruel)
                {
                    return ({
                        "paletteSwap":{
                            "colors":[4281869847, 4284104230, 4285283363, 4288438333, 4292185695, 4294430609, 4294892997, 4285992976, 4287304724, 4287632661, 4289075481, 4291174175, 4293076261, 0xFF00165F, 4279372429, 4280231092, 4280625364, 4280963785, 4282618579, 4291283404, 4294572537, 4278519045, 4278587421, 4280105563, 4286521358, 4289212697, 4290889665, 4294111986, 4282397200, 4285750047, 4288248361, 4292324921, 4294571645, 4278852104, 4280239383, 4281292327, 4282478899, 4285376097, 0xFF2C0300, 0xFF580500, 0xFF710400, 0xFF910200, 0xFFE80F00, 4283448328, 4286537482, 4287917836, 4289955598, 4293834526, 4278987068, 4279516760, 4279979111, 4280705406, 4283600820, 4278723603, 4279123489, 4279323689, 4279656756, 4280324173, 4281208586, 4285211159, 4286195482, 4287639071, 4289935911, 4279767821, 4281083679, 4283911226, 4287266665, 4290818443, 4293911495, 4281081636, 4283906628, 4287261043, 4290808729, 4293904338, 4282329873, 4286800435, 4290683496, 4279897608, 4281802257, 4283510042, 4285348643, 4288042548, 4280948765, 4282853682, 4284889927, 4287517026, 4278267691, 4278608474, 4279734920, 4281253811, 4286513140, 4280419073, 4282779393, 4286057218, 4279173411, 4280222022, 4281533049, 4283433291, 4287693449, 4290839220, 4294841576, 0xFFFF79D2, 4279255327, 4281916014, 4286381252, 4280092185, 4281929009, 4284292179, 4288035203, 4280223489, 4282387970, 4285405187, 4289409046, 4280033564, 4281941561, 4283652435, 4287469197, 4291284167, 4293520105, 0xFF431E00, 0xFF753500, 0xFF9F4900, 0xFFBE5600, 0xFFFF9317, 4279187002, 4282750880, 4283676353, 4284403419, 4279635505, 4280752474, 4282592406, 4284893902, 4294841459, 0xFFFF798F, 4281872923, 4287332699, 4291346835, 4293453502, 4279767821, 4282331683, 4285028422, 4279834126, 4282926396, 4285229921, 4279240196, 4281866770, 4284100644, 4287257160, 4280361496, 4288912766, 4291938991, 4285298286, 4282333697, 4284303382, 4280823080, 4285295726, 4287470745, 4284443746, 4289312429, 4279900426, 4282194960, 4283903261, 4286006837, 4282860882, 4286288034, 4288920013, 4291748338, 4282856195, 4291931673, 4294763375, 4280754964, 4285621052, 4289568114, 0xFF004A20, 4278484025, 4278303593, 4281567002, 4285778724, 4291293337, 4279901452, 4282467125, 4286084970, 4285031241, 4289700735, 4290557592, 4292400049, 4279637009, 4280426778, 4281939757, 4283715904, 4285090062, 4293251129, 4294770549, 4283056156, 4284504885, 4287334234, 4290687618, 4294242247, 4289160769, 4285743141, 0xFFCCFF00],
                            "replacements":[4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 0xFFFF0000, 0xFFFF0000, 4293256677, 0xFFFF0000, 0xFFFF0000, 4279045389, 4279045389, 0xFFFF0000, 0xFFFF0000, 4293256677, 4293256677, 4289901234, 4284900966, 4283190348, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4289901234, 4289901234, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4293256677, 4279834905, 0xFF000000, 4293256677, 4289901234, 4284900966, 4281545523, 4279834905, 4293256677, 4293256677, 4293256677, 4293256677, 4279834905, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4279637270, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293323249, 4281545523, 0xFF000000, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 0xFF000000, 0xFF000000, 4284900966, 4293256677, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4284900966, 4293256949, 0xFF000000, 4281545523, 4281545523, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293256677, 4281545523, 4281545523, 4293256677, 4284900966, 4279834905, 0xFF000000, 0xFF000000, 0xFF000000, 4293256677, 4279834905, 4283190348, 4281545523, 0xFF000000, 4285623144, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293256677, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4284900966, 4293256677, 4284900966]
                        },
                        "paletteSwapPA":{
                            "colors":[4281869847, 4288438333, 4292185695, 4294430609, 4294892997, 4285992976, 4287304724, 4287632661, 4289075481, 4291174175, 4293076261, 0xFF00165F, 4279372429, 4280231092, 4280625364, 4280963785, 4282618579, 4291283404, 4294572537, 4278519045, 4278587421, 4280105563, 4290889665, 4282397200, 4285750047, 4288248361, 4292324921, 4294571645, 4278852104, 4280239383, 4281292327, 4282478899, 4285376097, 0xFF2C0300, 0xFF580500, 0xFF710400, 0xFF910200, 0xFFE80F00, 4283448328, 4286537482, 4287917836, 4289955598, 4293834526, 4278987068, 4279516760, 4279979111, 4280705406, 4283600820, 4278723603, 4279123489, 4279323689, 4279656756, 4280324173, 4281208586, 4285211159, 4286195482, 4287639071, 4289935911, 4281083679, 4283911226, 4287266665, 4290818443, 4293911495, 4281081636, 4283906628, 4287261043, 4290808729, 4293904338, 4282329873, 4286800435, 4290683496, 4279897608, 4281802257, 4283510042, 4285348643, 4288042548, 4280948765, 4282853682, 4284889927, 4287517026, 4278267691, 4278608474, 4279734920, 4281253811, 4286513140, 4280419073, 4282779393, 4286057218, 4279173411, 4283433291, 4290839220, 4294841576, 0xFFFF79D2, 4279255327, 4281916014, 4286381252, 4281929009, 4284292179, 4288035203, 4282387970, 4285405187, 4289409046, 4280033564, 4281941561, 4283652435, 4287469197, 4291284167, 0xFF431E00, 0xFF753500, 0xFF9F4900, 0xFFBE5600, 0xFFFF9317, 4279635505, 4280752474, 4282592406, 4284893902, 4294841459, 0xFFFF798F, 0xFFCCFF00, 4293001065, 4289160769, 4285743141, 4278519557, 4279244047, 4279638805, 4280165404, 4278519820],
                            "replacements":[4293256677, 4284900966, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 0xFFFF0000, 0xFFFF0000, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4293256677, 4293256677, 4289901234, 4284900966, 4283190348, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4289901234, 4289901234, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4293256677, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4293256677, 4293256677, 4279834905, 0xFF000000, 0xFF000000, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4284900966, 4283190348, 4281545523, 0xFFFF0000]
                        }
                    });
                };
                return ({
                    "paletteSwap":{
                        "colors":[4281869847, 4284104230, 4285283363, 4288438333, 4292185695, 4294430609, 4294892997, 4285992976, 4287304724, 4287632661, 4289075481, 4291174175, 4293076261, 0xFF00165F, 4279372429, 4280231092, 4280625364, 4280963785, 4282618579, 4291283404, 4294572537, 4278519045, 4278587421, 4280105563, 4286521358, 4289212697, 4290889665, 4294111986, 4282397200, 4285750047, 4288248361, 4292324921, 4294571645, 4278852104, 4280239383, 4281292327, 4282478899, 4285376097, 0xFF2C0300, 0xFF580500, 0xFF710400, 0xFF910200, 0xFFE80F00, 4283448328, 4286537482, 4287917836, 4289955598, 4293834526, 4278987068, 4279516760, 4279979111, 4280705406, 4283600820, 4278723603, 4279123489, 4279323689, 4279656756, 4280324173, 4281208586, 4285211159, 4286195482, 4287639071, 4289935911, 4279767821, 4281083679, 4283911226, 4287266665, 4290818443, 4293911495, 4281081636, 4283906628, 4287261043, 4290808729, 4293904338, 4282329873, 4286800435, 4290683496, 4279897608, 4281802257, 4283510042, 4285348643, 4288042548, 4280948765, 4282853682, 4284889927, 4287517026, 4278267691, 4278608474, 4279734920, 4281253811, 4286513140, 4280419073, 4282779393, 4286057218, 4279173411, 4280222022, 4281533049, 4283433291, 4287693449, 4290839220, 4294841576, 0xFFFF79D2, 4279255327, 4281916014, 4286381252, 4280092185, 4281929009, 4284292179, 4288035203, 4280223489, 4282387970, 4285405187, 4289409046, 4280033564, 4281941561, 4283652435, 4287469197, 4291284167, 4293520105, 0xFF431E00, 0xFF753500, 0xFF9F4900, 0xFFBE5600, 0xFFFF9317, 4279187002, 4282750880, 4283676353, 4284403419, 4279635505, 4280752474, 4282592406, 4284893902, 4294841459, 0xFFFF798F, 4281872923, 4287332699, 4291346835, 4293453502, 4279767821, 4282331683, 4285028422, 4279834126, 4282926396, 4285229921, 4279240196, 4281866770, 4284100644, 4287257160, 4280361496, 4288912766, 4291938991, 4285298286, 4282333697, 4284303382, 4280823080, 4285295726, 4287470745, 4284443746, 4289312429, 4279900426, 4282194960, 4283903261, 4286006837, 4282860882, 4286288034, 4288920013, 4291748338, 4282856195, 4291931673, 4294763375, 4280754964, 4285621052, 4289568114, 0xFF004A20, 4278484025, 4278303593, 4281567002, 4285778724, 4291293337, 4279901452, 4282467125, 4286084970, 4285031241, 4289700735, 4290557592, 4292400049, 4279637009, 4280426778, 4281939757, 4283715904, 4285090062, 4293251129, 4294770549, 4283056156, 4284504885, 4287334234, 4290687618, 4294242247, 4289160769, 4285743141, 0xFFCCFF00],
                        "replacements":[4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4279045389, 4279045389, 4293256677, 4279045389, 4293256677, 4293256677, 4289901234, 4284900966, 4283190348, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4289901234, 4289901234, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4293256677, 4279834905, 0xFF000000, 4293256677, 4289901234, 4284900966, 4281545523, 4279834905, 4293256677, 4293256677, 4293256677, 4293256677, 4279834905, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4279637270, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293323249, 4281545523, 0xFF000000, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 0xFF000000, 0xFF000000, 4284900966, 4293256677, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4284900966, 4293256949, 0xFF000000, 4281545523, 4281545523, 4293256677, 4284900966, 4281545523, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293256677, 4281545523, 4281545523, 4293256677, 4284900966, 4279834905, 0xFF000000, 0xFF000000, 0xFF000000, 4293256677, 4279834905, 4283190348, 4281545523, 0xFF000000, 4285623144, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4281545523, 0xFF000000, 4293256677, 4293256677, 4281545523, 0xFF000000, 0xFF000000, 4284900966, 4293256677, 4284900966]
                    },
                    "paletteSwapPA":{
                        "colors":[4281869847, 4288438333, 4292185695, 4294430609, 4294892997, 4285992976, 4287304724, 4287632661, 4289075481, 4291174175, 4293076261, 0xFF00165F, 4279372429, 4280231092, 4280625364, 4280963785, 4282618579, 4291283404, 4294572537, 4278519045, 4278587421, 4280105563, 4290889665, 4282397200, 4285750047, 4288248361, 4292324921, 4294571645, 4278852104, 4280239383, 4281292327, 4282478899, 4285376097, 0xFF2C0300, 0xFF580500, 0xFF710400, 0xFF910200, 0xFFE80F00, 4283448328, 4286537482, 4287917836, 4289955598, 4293834526, 4278987068, 4279516760, 4279979111, 4280705406, 4283600820, 4278723603, 4279123489, 4279323689, 4279656756, 4280324173, 4281208586, 4285211159, 4286195482, 4287639071, 4289935911, 4281083679, 4283911226, 4287266665, 4290818443, 4293911495, 4281081636, 4283906628, 4287261043, 4290808729, 4293904338, 4282329873, 4286800435, 4290683496, 4279897608, 4281802257, 4283510042, 4285348643, 4288042548, 4280948765, 4282853682, 4284889927, 4287517026, 4278267691, 4278608474, 4279734920, 4281253811, 4286513140, 4280419073, 4282779393, 4286057218, 4279173411, 4283433291, 4290839220, 4294841576, 0xFFFF79D2, 4279255327, 4281916014, 4286381252, 4281929009, 4284292179, 4288035203, 4282387970, 4285405187, 4289409046, 4280033564, 4281941561, 4283652435, 4287469197, 4291284167, 0xFF431E00, 0xFF753500, 0xFF9F4900, 0xFFBE5600, 0xFFFF9317, 4279635505, 4280752474, 4282592406, 4284893902, 4294841459, 0xFFFF798F, 0xFFCCFF00, 4293001065, 4289160769, 4285743141, 4278519557, 4279244047, 4279638805, 4280165404, 4278519820],
                        "replacements":[4293256677, 4284900966, 4281545523, 0xFF000000, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4281545523, 0xFF000000, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4289901234, 4284900966, 4283190348, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4289901234, 4289901234, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4283190348, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4293256677, 4293256677, 4284900966, 4281545523, 4279834905, 4293256677, 4293256677, 4293256677, 4279834905, 0xFF000000, 0xFF000000, 4284900966, 4281545523, 4279834905, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4281545523, 4279834905, 0xFF000000, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4284900966, 4284900966, 4284900966, 4293256677, 4293256677, 4284900966, 4283190348, 4281545523, 4293256677]
                    }
                });
            };
            if (_arg_1 == "kirby")
            {
                if (this.isCruel)
                {
                    return ({
                        "paletteSwap":{
                            "colors":[4294825442, 4294688724, 4294618309, 4293629617, 4291852181, 4289220468, 4284163381, 4293412679, 4291701290, 4289598227, 4287039239, 4285465861, 4282845449, 4294864582, 0xFFFF6691, 4292364400, 4283960586, 4279385474, 4279640381, 0xFF000000, 4294506744, 4287406023, 4286084991, 4291588657, 4288106008, 4285213710, 4282063625, 4280029711, 4294177779, 4290756543, 4288651167, 4286545791, 4281677109, 0xFFFFEC8E, 4292395602, 4293222036, 4291573105, 4294638185, 4292793424, 4289306420, 4284965912, 4294835709, 4293452511, 4291479750, 4290162864, 4288321434, 4284505952, 4293322490, 4291348720, 4289243376, 4285032576, 4282532435, 0xFFF0F000, 0xFFE8B000, 0xFFF08800, 4287641608, 4287456071, 4285288790, 4282726463, 4289970643, 4287077562, 4284246915, 4281942867, 4287136932, 4282992222, 4281676611, 4278257675, 4293320413, 4292003009, 4290421406, 4286544758, 4282335039, 0xFFFFEFB6, 0xFFFFD94A, 0xFFE8B700, 0xFFDF9300, 0xFFB86E00, 0xFF7F4C00, 4284492552, 4281868560, 4292996089, 4289773781, 4286352547, 4283457399, 4282793284, 4280882956, 4289732616, 4287784043, 4292033079, 4291606173, 4288642133, 4286144322, 4284631859, 4282397218, 0xFFFF7B00, 0xFFE06500, 0xFFC64D00, 0xFFA93F00, 0xFF833000, 0xFF420D00, 4278847495, 4287731376, 4283652213, 4282270037, 4280888376, 4280558638, 4279440410, 4293651447, 4291218411, 4286941610, 4283519313, 4290758365, 4289244869, 4286943915, 4283656837, 4281680471, 4280297256, 4289574068, 4285563005, 4283852142, 4294309365, 4291416272, 4287207830, 4286263609, 4293322470, 4288782753, 4279968034, 4293454578, 4288587990, 4285756822, 4283191158, 4280691282, 4279572002, 0xFFFFB5D0, 4294674609, 4293878164, 4292229219, 4289009713, 4283566088, 4292796407, 4280887337],
                            "replacements":[4278519045, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4285690482, 4293256677, 4293256677, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4291588657, 4288106008, 4285213710, 4282063625, 4280029711, 4294177779, 4290756543, 4288651167, 4286545791, 4281677109, 0xFFFFEC8E, 4292395602, 4293222036, 4291573105, 4294638185, 4292793424, 4289306420, 4284965912, 4294835709, 4293452511, 4291479750, 4290162864, 4288321434, 4284505952, 4293322490, 4291348720, 4289243376, 4285032576, 4282532435, 0xFFF0F000, 0xFFE8B000, 0xFFF08800, 4287641608, 4287456071, 4285288790, 4282726463, 4289970643, 4287077562, 4284246915, 4281942867, 4287136932, 4282992222, 4281676611, 4278257675, 4293320413, 4292003009, 4290421406, 4286544758, 4282335039, 0xFFFFEFB6, 0xFFFFD94A, 0xFFE8B700, 0xFFDF9300, 0xFFB86E00, 0xFF7F4C00, 4284492552, 4281868560, 4292996089, 4289773781, 4286352547, 4283457399, 4282793284, 4280882956, 4289732616, 4287784043, 4292033079, 4291606173, 4288642133, 4286144322, 4284631859, 4282397218, 0xFFFF7B00, 0xFFE06500, 0xFFC64D00, 0xFFA93F00, 0xFF833000, 0xFF420D00, 4278847495, 4287731376, 4283652213, 4282270037, 4280888376, 4280558638, 4279440410, 4293651447, 4291218411, 4286941610, 4283519313, 4290758365, 4289244869, 4286943915, 4283656837, 4281680471, 4280297256, 4289574068, 4285563005, 4283852142, 4294309365, 4291416272, 4287207830, 4286263609, 4293322470, 4288782753, 4279968034, 4293454578, 4288587990, 4285756822, 4283191158, 4280691282, 4279572002, 0xFFFFB5D0, 4294674609, 4293878164, 4292229219, 4289009713, 4283566088, 4292796407, 4280887337]
                        },
                        "paletteSwapPA":{
                            "colors":[4294825442, 4294688724, 4294618309, 4293629617, 4291852181, 4289220468, 4284163381, 4293412679, 4291701290, 4289598227, 4287039239, 4285465861, 4282845449, 4294864582, 4293947552, 4292364400, 4283960586, 4279385474, 4279640381, 0xFF000000, 4294506744, 4291677645, 4286084991, 4288059114, 4286020046, 4280689753],
                            "replacements":[4278519045, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4285690482, 4293256677, 4293256677, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFF660000, 0xFF660000, 0xFFB20000]
                        }
                    });
                };
                return ({
                    "paletteSwap":{
                        "colors":[4294825442, 4294688724, 4294618309, 4293629617, 4291852181, 4289220468, 4284163381, 4293412679, 4291701290, 4289598227, 4287039239, 4285465861, 4282845449, 4294864582, 0xFFFF6691, 4292364400, 4283960586, 4279385474, 4279640381, 0xFF000000, 4294506744, 4287406023, 4286084991, 4291588657, 4288106008, 4285213710, 4282063625, 4280029711, 4294177779, 4290756543, 4288651167, 4286545791, 4281677109, 0xFFFFEC8E, 4292395602, 4293222036, 4291573105, 4294638185, 4292793424, 4289306420, 4284965912, 4294835709, 4293452511, 4291479750, 4290162864, 4288321434, 4284505952, 4293322490, 4291348720, 4289243376, 4285032576, 4282532435, 0xFFF0F000, 0xFFE8B000, 0xFFF08800, 4287641608, 4287456071, 4285288790, 4282726463, 4289970643, 4287077562, 4284246915, 4281942867, 4287136932, 4282992222, 4281676611, 4278257675, 4293320413, 4292003009, 4290421406, 4286544758, 4282335039, 0xFFFFEFB6, 0xFFFFD94A, 0xFFE8B700, 0xFFDF9300, 0xFFB86E00, 0xFF7F4C00, 4284492552, 4281868560, 4292996089, 4289773781, 4286352547, 4283457399, 4282793284, 4280882956, 4289732616, 4287784043, 4292033079, 4291606173, 4288642133, 4286144322, 4284631859, 4282397218, 0xFFFF7B00, 0xFFE06500, 0xFFC64D00, 0xFFA93F00, 0xFF833000, 0xFF420D00, 4278847495, 4287731376, 4283652213, 4282270037, 4280888376, 4280558638, 4279440410, 4293651447, 4291218411, 4286941610, 4283519313, 4290758365, 4289244869, 4286943915, 4283656837, 4281680471, 4280297256, 4289574068, 4285563005, 4283852142, 4294309365, 4291416272, 4287207830, 4286263609, 4293322470, 4288782753, 4279968034, 4293454578, 4288587990, 4285756822, 4283191158, 4280691282, 4279572002, 0xFFFFB5D0, 4294674609, 4293878164, 4292229219, 4289009713, 4283566088, 4292796407, 4280887337],
                        "replacements":[4278519045, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4285690482, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4291588657, 4288106008, 4285213710, 4282063625, 4280029711, 4294177779, 4290756543, 4288651167, 4286545791, 4281677109, 0xFFFFEC8E, 4292395602, 4293222036, 4291573105, 4294638185, 4292793424, 4289306420, 4284965912, 4294835709, 4293452511, 4291479750, 4290162864, 4288321434, 4284505952, 4293322490, 4291348720, 4289243376, 4285032576, 4282532435, 0xFFF0F000, 0xFFE8B000, 0xFFF08800, 4287641608, 4287456071, 4285288790, 4282726463, 4289970643, 4287077562, 4284246915, 4281942867, 4287136932, 4282992222, 4281676611, 4278257675, 4293320413, 4292003009, 4290421406, 4286544758, 4282335039, 0xFFFFEFB6, 0xFFFFD94A, 0xFFE8B700, 0xFFDF9300, 0xFFB86E00, 0xFF7F4C00, 4284492552, 4281868560, 4292996089, 4289773781, 4286352547, 4283457399, 4282793284, 4280882956, 4289732616, 4287784043, 4292033079, 4291606173, 4288642133, 4286144322, 4284631859, 4282397218, 0xFFFF7B00, 0xFFE06500, 0xFFC64D00, 0xFFA93F00, 0xFF833000, 0xFF420D00, 4278847495, 4287731376, 4283652213, 4282270037, 4280888376, 4280558638, 4279440410, 4293651447, 4291218411, 4286941610, 4283519313, 4290758365, 4289244869, 4286943915, 4283656837, 4281680471, 4280297256, 4289574068, 4285563005, 4283852142, 4294309365, 4291416272, 4287207830, 4286263609, 4293322470, 4288782753, 4279968034, 4293454578, 4288587990, 4285756822, 4283191158, 4280691282, 4279572002, 0xFFFFB5D0, 4294674609, 4293878164, 4292229219, 4289009713, 4283566088, 4292796407, 4280887337]
                    },
                    "paletteSwapPA":{
                        "colors":[4294825442, 4294688724, 4294618309, 4293629617, 4291852181, 4289220468, 4284163381, 4293412679, 4291701290, 4289598227, 4287039239, 4285465861, 4282845449, 4294864582, 4293947552, 4292364400, 4283960586, 4279385474, 4279640381, 0xFF000000, 4294506744, 4291677645, 4286084991, 4288059114, 4286020046, 4280689753],
                        "replacements":[4278519045, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4278519045, 4280690214, 4283190348, 4285690482, 4288256409, 4293256677, 4285690482, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4283190348, 4283190348, 4288256409]
                    }
                });
            };
            if (_arg_1 == "pikachu")
            {
                if (this.isCruel)
                {
                    return ({
                        "paletteSwap":{
                            "colors":[4294892874, 4293575994, 4291535398, 4288642591, 4283383831, 4283169894, 4280262184, 4279651353, 4290760101, 4286693119, 4283539444, 4281239786, 4278671535, 4278268777, 4285567976, 4283989204, 4282474408, 4280893041, 4279772486, 4284788303, 4282743350, 4281028129, 4279841042, 0xFF00FCFF, 0xFF00D5D7, 0xFF00ADAF, 0xFF005D5E, 4290547235, 4287910697, 4286593321, 4284819482, 4282064148, 4289216242, 4284551067, 4292916479, 4293191661, 4291021005, 0xFFFF4D33, 0xFFE60002, 0xFFAC0001, 0xFF5E0001, 4278650631, 4293228175, 4291252325, 4281994760],
                            "replacements":[0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF660000, 0xFFB20000, 0xFFFF0000, 0xFF000000, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4288256409, 4293256677, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4283190348, 4283190348, 4283190348, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677]
                        },
                        "paletteSwapPA":{
                            "colors":[4294892874, 4293575994, 4291535398, 4288642591, 4283383831, 4283169894, 4280262184, 4279651353, 4290760101, 4286693119, 4283539444, 4281239786, 4278671535, 4278268777, 4285567976, 4283989204, 4282474408, 4280893041, 4279772486, 4284788303, 4282743350, 4281028129, 4279841042, 0xFF00FCFF, 0xFF00D5D7, 0xFF00ADAF, 0xFF005D5E, 4290547235, 4287910697, 4286593321, 4284819482, 4282064148, 4289216242, 4284551067, 4292916479, 4293191661, 4291021005, 0xFFFF4D33, 0xFFE60002, 0xFFAC0001, 0xFF5E0001, 4278650631, 4293228175, 4291252325, 4281994760],
                            "replacements":[0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF660000, 0xFFB20000, 0xFFFF0000, 0xFF000000, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4288256409, 4293256677, 4293256677, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 0xFFFF0000, 4283190348, 4283190348, 4283190348, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677]
                        }
                    });
                };
                return ({
                    "paletteSwap":{
                        "colors":[4294892874, 4293575994, 4291535398, 4288642591, 4283383831, 4283169894, 4280262184, 4279651353, 4290760101, 4286693119, 4283539444, 4281239786, 4278671535, 4278268777, 4285567976, 4283989204, 4282474408, 4280893041, 4279772486, 4284788303, 4282743350, 4281028129, 4279841042, 0xFF00FCFF, 0xFF00D5D7, 0xFF00ADAF, 0xFF005D5E, 4290547235, 4287910697, 4286593321, 4284819482, 4282064148, 4289216242, 4284551067, 4292916479, 4293191661, 4291021005, 0xFFFF4D33, 0xFFE60002, 0xFFAC0001, 0xFF5E0001, 4278650631, 4293228175, 4291252325, 4281994760],
                        "replacements":[0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4293256677, 0xFF000000, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4283190348, 4283190348, 4283190348, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677]
                    },
                    "paletteSwapPA":{
                        "colors":[4294892874, 4293575994, 4291535398, 4288642591, 4283383831, 4283169894, 4280262184, 4279651353, 4290760101, 4286693119, 4283539444, 4281239786, 4278671535, 4278268777, 4285567976, 4283989204, 4282474408, 4280893041, 4279772486, 4284788303, 4282743350, 4281028129, 4279841042, 0xFF00FCFF, 0xFF00D5D7, 0xFF00ADAF, 0xFF005D5E, 4290547235, 4287910697, 4286593321, 4284819482, 4282064148, 4289216242, 4284551067, 4292916479, 4293191661, 4291021005, 0xFFFF4D33, 0xFFE60002, 0xFFAC0001, 0xFF5E0001, 4278650631, 4293228175, 4291252325, 4281994760],
                        "replacements":[0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4293256677, 0xFF000000, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 0xFF000000, 4280690214, 4283190348, 4288256409, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4290756543, 4293256677, 4283190348, 4288256409, 4288256409, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677, 4283190348, 4283190348, 4283190348, 4293256677, 4293256677, 4293256677, 4293256677, 4293256677]
                    }
                });
            };
            return ({
                "alphaMultiplier":0.9,
                "redMultiplier":-1,
                "greenMultiplier":-1,
                "blueMultiplier":-1,
                "redOffset":0xFF,
                "greenOffset":0xFF,
                "blueOffset":0xFF,
                "saturation":-100,
                "brightness":35,
                "contrast":10
            });
        }


    }
}//package 

