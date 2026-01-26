package
{
	import flash.display.MovieClip;
	
	public class EventMode33Special_AllStarBattle08 extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
				
		public function EventMode33Special_AllStarBattle08(api:*)
		{
			super(api);
			
			playerLives = 2;
			cpuLevel = 7;
			matchArray = [
				{ opponent: "pikachu", stage: "pokemoncolosseum" },
				{ opponent: "donkeykong", stage: "junglehijinx" },
				{ opponent: "fox", stage: "meteovoyage" },
				{ opponent: "yoshi", stage: "yoshisisland" },
				{ opponent: "captainfalcon", stage: "sandocean" }
			];
		}
	}
}

