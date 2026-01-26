package
{
    import flash.display.MovieClip;

    public dynamic class ExternalEvents extends MovieClip
    {
        public function ExternalEvents():void
        {
           this.eventList2 = [
         { id: "TroubledKing", classAPI: EventMode1_TroubledKing, name: "1. Troubled King", description: "Fight Mario in a classic Mushroom Kingdom clash!"},
         { id: "Fleas", classAPI: EventMode2_Fleas, name: "2. Fleas", description: 'Looks like Donkey Kong has a "little" problem.' },
         { id: "GourmetRace", classAPI: EventMode3_GourmetRace, name: "3. Gourmet Race", description: "After an epic showdown, you're damaged pretty seriously... Heal up more than your foes!"},
         { id: "BattleRevolution", classAPI: EventMode4_BattleRevolution, name: "4. Battle Revolution", description: "It's an all-out Pokémon showdown! Defeat your rival's Pokémon to move on!", chooseCharacter: true},
         { id: "RockinBlues", classAPI: EventMode5_RockinBlues, name: "5. Rockin' Blues", description: "Mega Man can't defeat all of these foes on his own! In comes a whistle..." },
         { id: "SavingTheSaturns", classAPI: EventMode6_SavingTheSaturns, name: "6. Saving the Saturns", description: "ZOOM! SAVE US FROM THE SCARY RUBBER MAN." },
         { id: "WhoNeedsTurnips", classAPI: EventMode7_WhoNeedsTurnips, name: "7. Who Needs Turnips?", description: "You think turnips are all I've got up my sleeve? I won't need Mario this time." },
         { id: "OppositeDay", classAPI: EventMode8_OppositeDay, name: "8. Opposite Day", description: "You want me to LOSE the battle in less than 30 seconds...?! There must be a catch." },
         { id: "YoureTooSlow", classAPI: EventMode9_YoureTooSlow, name: "9. You're Too Slow", description: "These hedgehogs are way too fast! Maybe if you use your Stop spell..." },
         { id: "TagYoureIt", classAPI: EventMode10_TagYoureIt, name: "10. Tag You're It", description: "Use an Exploding Tag to deliver the final strikes in this explosive battle.", chooseCharacter:true },
         { id: "AllStarBattle01", classAPI: EventMode10Special_AllStarBattle01, name: "All-Star Battle v0.1", description: "Duke it out with the original characters added in Super Smash Flash 2's v0.1 demo!", chooseCharacter: true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------W A V E    2------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "Laagggggg", classAPI: EventMode11_Laagggggg, name: "11. Laagggggg", description: "Well, someone's internet connection isn't the best... Take him out anyway - no johns!"},
         { id: "ShadowCloneShowdown", classAPI: EventMode12_ShadowCloneShowdown, name: "12. Shadow Clone Showdown", description: "Only the real Naruto can summon clones! Figure out which he is and KO him!"},
         { id: "ComboMaker", classAPI: EventMode13_ComboMaker, name: "13. Combo Maker", description: "String together a Turbo Mode combo that does at least 50%!", chooseCharacter:true},
         { id: "InTheBallpark", classAPI: EventMode14_InTheBallpark, name: "14. In the Ballpark", description: "Are you a real super slugger? Knock your foes out of the park with your Home-Run Bat!"},
         { id: "SwornToTheSword", classAPI: EventMode15_SwornToTheSword, name: "15. Sworn To The Sword", description: "Prove that two swords are better than one!"},
         { id: "BountyHunting", classAPI: EventMode16_BountyHunting, name: "16. Bounty Hunting", description: "KO the green Yoshi without harming any innocent bystanders."},
         { id: "DarkLinksAdvance", classAPI: EventMode17_DarkLinksAdvance, name: "17. Dark Link's Advance", description: "Defeat your shadow before the darkness envelops you."},
         { id: "TargetRace", classAPI: EventMode18_TargetRace, name: "18. Target Race", description: "How fast can you smash 40 targets?", chooseCharacter: true, special: true},
         { id: "NightmareInDreamland", classAPI: EventMode19_NightmareInDreamland, name: "19. Nightmare In Dream Land", description: "Protect Kirby from the enigmatic attackers!"},
         { id: "SpeedDemon", classAPI: EventMode20_SpeedDemon, name: "20. Speed Demon", description: "KO your speedy opponent before the time runs out!"},
         { id: "AllStarBattle06", classAPI: EventMode20Special_AllStarBattle06, name: "All-Star Battle v0.6", description: "Put yourself to the test against every character added from demo v0.1 to v0.6!", chooseCharacter: true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------W A V E    3------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "BattleOfThe99Heartless", classAPI: EventMode21_BattleOfThe99Heartless, name: "21. Battle of the 99 Heartless?", description: "You're surrounded - defeat the army of Heartless!"},
         { id: "RoleReversal", classAPI: EventMode22_RoleReversal, name: "22. Role Reversal", description: "Sandbag rears up for revenge... Land a devastating home run!"},
         { id: "MeteoCampaign", classAPI: EventMode23_MeteoCampaign, name: "23. Meteo Campaign", description: "Defeat Fox on his home turf!"},
         { id: "Restless", classAPI: EventMode24_Restless, name: "24. Restless", description: "These poor kids just can't go to sleep. Help them out?"},
         { id: "LuigiTakesCharge", classAPI: EventMode25_LuigiTakesCharge, name: "25. Luigi Takes Charge!", description: "Mario's on vacation. It's up to you to protect Peach this time, Luigi!"},
         { id: "CleaningDuty", classAPI: EventMode26_CleaningDuty, name: "26. Cleaning Duty", description: "Chibi-Robo's gotta clean up this mess that Wario's made before the Sandersons get home."},
         { id: "MonkeyDeeLuffy", classAPI: EventMode27_MonkeyDeeLuffy, name: "27. Monkey, Dee, Luffy!", description: "A newcomer and a seasoned veteran need to take out Luffy! How will he stack up?"},
         { id: "BombFactoryMalfunction", classAPI: EventMode28_BombFactoryMalfunction, name: "28. Bomb Factory Malfunction", description: "Oh, no! Why is the factory making so many bombs?! And where's my shield?!"},
         { id: "ThePowerOfRandom", classAPI: EventMode29_ThePowerOfRandom, name: "29. The Power Of Random", description: "You have an infinite arsenal of randomized items... use it to take down your random foes!"},
         { id: "AtYourService", classAPI: EventMode30_AtYourService, name: "30. At Your Service", description: "The assist trophies are here to assist with your giant opponent problem.", chooseCharacter: true},
         { id: "AllStarBattle07", classAPI: EventMode30Special_AllStarBattle07, name: "All-Star Battle v0.7", description: "These are getting harder - this time, all of the crew from v0.7!", chooseCharacter: true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------W A V E    3 . 5------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "AHeavenlyPower", classAPI: EventMode31_AHeavenlyPower, name: "31. A Heavenly Power", description: "A heavenly power is protecting you from the evils nearby."},
         { id: "McLeodGamingTime", classAPI: EventMode32_McLeodGamingTime, name: "32. SSF2 Time", description: "You only have 3...ish seconds to KO your opponent!", chooseCharacter: true},
         { id: "HideNSheik", classAPI: EventMode47_HideNSheik, name: "33. Hide 'n' Sheik", description: "Only Sheik KOs count! Wait for the change...", chooseCharacter:true},
         { id: "MegaMicrogames", classAPI: EventMode48_MegaMicrogames, name: "34. Mega Microgames", description: "The microgames never stop - win them all, and keep an eye on your damage!"},
         { id: "Biohazard", classAPI: EventMode33_Biohazard, name: "35. Biohazard", description: "Black Mage has infected you with his most powerful poison. Take him out before it's too late!", chooseCharacter:true},
         { id: "GottaCherishThemAll", classAPI: EventMode49_GottaCherishThemAll, name: "36. Gotta Cherish Them All!", description: "Pikachu hates Pokéballs. Show these humans what it's like to be trapped in one!"},
         { id: "AllStarBattle08", classAPI: EventMode33Special_AllStarBattle08, name: "All-Star Battle v0.8", description: "Time to battle with the characters added in our v0.8 update!", chooseCharacter: true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------W A V E    4------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "FistOfTheWorldKing", classAPI: EventMode34_FistOfTheWorldKing, name: "37. Fist of the World King", description: "Use Kaio-ken to defeat a powerful adversary."},
         { id: "PrettyInPink", classAPI: EventMode35_PrettyInPink, name: "38. Pretty In Pink", description: "A plethora of powerful Pink opponents wish to pummel you. Pulverise them!", chooseCharacter: true},
         { id: "DawnOfTheFirstDay", classAPI: EventMode36_DawnOfTheFirstDay, name: "39. Dawn of the First Day", description: "Can you survive 72 hours of Termina's threats and beasts?"},
         { id: "TheMotherBrain", classAPI: EventMode50_TheMotherBrain, name: "40. The Mother Brain", description: "A classic matchup! Eliminate the Mother Brain!"},
         { id: "DownWithMario", classAPI: EventMode37_DownWithMario, name: "41. Down With Mario", description: "For a good guy, Mario sure does have a lot of enemies."},
         { id: "Pacmania", classAPI: EventMode38_Pacmania, name: "42. Pacmania", description: "PAC-MAN's been smashing a lot recently - let's make sure he's still got it!"},
         { id: "SwordsVsSpears", classAPI: EventMode39_SwordsVsSpears, name: "43. Swords vs Spears", description: "The Hero King must defend his kingdom from the invading army."},
         { id: "ClimateChanges", classAPI: EventMode40_ClimateChanges, name: "44. Climate Changes", description: "Crateria's conditions are worsening. Defeat your foe - and avoid the acid rain, or else!"},
         { id: "AllStarBattle09", classAPI: EventMode40Special_AllStarBattle09, name: "All-Star Battle v0.9", description: "A smack-down from the past - battle all of the characters added in v0.9a and v0.9b!", chooseCharacter:true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------W A V E    5------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "BobombBattlefield", classAPI: EventMode41_BobombBattlefield, name: "45. Bob-omb Battlefield", description: "These giant bombs are getting in the way.."},
         { id: "EggmanEmpire", classAPI: EventMode42_EggmanEmpire, name: "46. Eggman Empire", description: "Dr. Eggman has sent a squadron of robots to take you out!"},
         { id: "TheTroubleWithDoubles", classAPI: EventMode43_TheTroubleWithDoubles, name: "47. The Trouble With Doubles", description: "You and your partner share damage. Try to keep each other safe!", chooseCharacter: true},
         { id: "PirateAttack", classAPI: EventMode44_PirateAttack, name: "48. Pirate Attack", description: "Don't let the pirates capture your ship!"},
         { id: "ANightAtTheCasino", classAPI: EventMode45_ANightAtTheCasino, name: "49. A Night At The Casino", description: "Bounce off of each bumper - and hurry!"},
         { id: "MetalClash", classAPI: EventMode51_MetalClash, name: "50. Metal Clash", description: "Battle some vicious metal foes!", chooseCharacter: true},
         { id: "AllStarBattleBeta", classAPI: EventMode46Special_AllStarBattleBeta, name: "All-Star Battle Beta", description: "Here's what we've got now! Are you ready?", chooseCharacter:true, allStar: true, special: true},
/*---------------------------------------------------------------------------------------------F I N A L    W A V E------------------------------------------------------------------------------------------------------------------------------------------------*/				
         { id: "ACelebration", classAPI: EventMode51Special_ACelebration, name: "51. ?????", description: "Y O U *click* D I D  I T!  L E T ' S  C E L E B R A T E ! *whrr*", chooseCharacter:true}
         ];
            

        }
    }
}




