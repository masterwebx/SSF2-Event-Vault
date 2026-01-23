package
{
	import flash.display.MovieClip;
	
	public class EventMode46Special_AllStarBattleBeta extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode46Special_AllStarBattleBeta(api:*)
		{
			super(api);
			
			playerLives = 2;
			cpuLevel = 9;
			matchArray = [
				{ opponent: "isaac", stage: "venuslighthouse" },
				{ opponent: "bowser", stage: "bowserscastle" },
				{ opponent: "gameandwatch", stage: "flatzoneplus" },
				{ opponent: "luigi", stage: "kingdom2" }, 
				{ opponent: "sandbag", stage: "waitingroom" },
				{ opponent: "pacman", stage: "pacmaze" },
				{ opponent: "pit", stage: "palutenasshrine" },
				{ opponent: "falco", stage: "sectorz" },
				{ opponent: "bandanadee", stage: "dreamland" },
				{ opponent: "luffy", stage: "thousandsunny" }
			];
			
		}
	}
}