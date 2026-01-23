// EventModeTemplate_BossBattle.as
// TEMPLATE: Boss Battle Event
// This is a template for creating boss battle events where the player fights a powerful CPU opponent.
// Customize the boss character, stats, stage, and win conditions below.
// For beginners: This event sets up a 1v1 fight against a boss with enhanced stats.

package
{
    import flash.utils.getDefinitionByName;

    public class EventModeTemplate_BossBattle extends SSF2CustomMatch
    {
        // EVENT INFO: This array tells the game about your event. Copy this structure for your custom events.
        // - id: Unique identifier (no spaces, used internally)
        // - classAPI: Must match your class name exactly
        // - name: Display name in the menu
        // - description: Short description shown in event selection
        // - chooseCharacter: true if player can pick their character, false for fixed
        public var eventinfo:Array = [
            {
                "id": "BossBattleTemplate",
                "classAPI": EventModeTemplate_BossBattle,
                "name": "Boss Battle Template",
                "description": "Fight against a powerful boss! Customize the boss and win conditions.",
                "chooseCharacter": true  
            }
        ];

        // Class variables: These can be accessed by all functions in this class
        private var MultiplayerManagerClass:Class;  // For notifications (optional)

        // Constructor: Called when the event is created. Usually just calls super(api)
        public function EventModeTemplate_BossBattle(api:*)
        {
            super(api);
        }

        // INITIALIZE: Called once at the start of the match. Set up boss stats, sizes, etc.
        override public function initialize():void
        {
            super.initialize();

            // OPTIONAL: Set up notifications (copy from other events if you want chat messages)
            this.MultiplayerManagerClass = getDefinitionByName("com.mcleodgaming.ssf2.net.MultiplayerManager") as Class;
            this.MultiplayerManagerClass["notify"]("Boss battle begins! Defeat the boss!");

            // BOSS SETUP: Make the CPU opponent (Player 2) bigger and stronger
            SSF2API.getPlayer(2).setSizeStatus(1);      // Size: 1 = big, -1 = small, 0 = normal
            SSF2API.getPlayer(2).lockSizeStatus(true);  // Lock size so it doesn't change

            // Boss damage multiplier (higher = takes more damage to KO)
            SSF2API.getPlayer(2).updateCharacterStats({damageRatio: 2.0});  // 2x damage resistance

            // OPTIONAL: Player size (make player smaller for challenge)
            SSF2API.getPlayer(1).setSizeStatus(-1);
            SSF2API.getPlayer(1).lockSizeStatus(true);
        }

        // MATCH SETUP: Called before the match starts. Define players, stage, rules.
        override public function matchSetup(initSettings:Object):Object
        {
            // Create the match settings object. Don't change this structure.
            var game:Object = {
                playerSettings: [],  // Player configurations
                levelData: initSettings.levelData,  // Copy level settings
                items: initSettings.items  // Copy item settings
            };

            // PLAYER 1: The human player
            game.playerSettings.push({
                character: initSettings.playerSettings[0].character,  // Use player's chosen character
                name: initSettings.playerSettings[0].name,
                costume: initSettings.playerSettings[0].costume,
                lives: 3,      // How many stocks player has
                human: true,   // This is the human player
                team: -1       // Team color (-1 = no team)
            });

            // PLAYER 2: The CPU boss
            game.playerSettings.push({
                character: "bowser",  // CHANGE THIS: Set your boss character (e.g., "ganondorf")
                lives: 5,       // Boss has more lives
                human: false,   // CPU controlled
                team: -1,
                level: 9        // Max AI difficulty
            });

            // MATCH RULES
            game.levelData.usingLives = true;   // Use stock system
            game.levelData.usingTime = false;   // No time limit
            game.levelData.lives = 3;           // Max lives (should match player 1)
            game.levelData.hazards = true;      // Stage hazards enabled
            game.levelData.teamDamage = false;  // No team damage
            game.levelData.stage = "kingdom1";  // CHANGE THIS: Set your stage (e.g., "finaldestination")

            // ITEMS: Remove all items for a pure fight (optional)
            var allItems:Array = SSF2API.getItemStatsList();
            for (var i:int = 0; i < allItems.length; i++) {
                delete game.items.items[allItems[i].statsName];
            }
            game.items.frequency = 0;  // No items spawn

            return game;
        }

        // UPDATE: Called every frame during the match. Check win/lose conditions here.
        override public function update():void
        {
            var players:Array = SSF2API.getPlayers();

            // WIN CONDITION: Player defeats boss (boss has 0 lives)
            if (players[1].getLives() <= 0) {  // Boss is Player 2 (index 1)
                matchData.success = true;
                matchData.score = SSF2API.getElapsedFrames();  // Score = time taken
                matchData.scoreType = "time";
                SSF2API.endGame({
                    "slowMo": false,
                    "success": true,
                    "immediate": false
                });
            }

            // LOSE CONDITION: Player runs out of lives
            if (players[0].getLives() <= 0) {  // Player is Player 2 (index 0)
                matchData.success = false;
                SSF2API.endGame({
                    "slowMo": false,
                    "success": false,
                    "immediate": false
                });
            }
        }
    }
}