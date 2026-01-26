package
{
	import flash.display.MovieClip;
	
	public class EventMode40Special_AllStarBattle09 extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode40Special_AllStarBattle09(api:*)
		{
			super(api);
			
			playerLives = 2;
			cpuLevel = 9;
			matchArray = [
				{ opponent: "metaknight", stage: "draculascastle" },
				{ opponent: "samus", stage: "crateria" },
				{ opponent: "bomberman", stage: "bombfactory" },
				{ opponent: "zelda", stage: "hyrulecastle64" },
				{ opponent: "jigglypuff", stage: "saffroncity" },
				{ opponent: "zamus", stage: "phase8" },
				{ opponent: "marth", stage: "castlesiege" },
				{ opponent: "chibirobo", stage: "desk" }
			];
		}
	}
}