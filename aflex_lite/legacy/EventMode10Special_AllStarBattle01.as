package
{
	import flash.display.MovieClip;
	
	public class EventMode10Special_AllStarBattle01 extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode10Special_AllStarBattle01(api:*)
		{
			super(api);
			
			playerLives = 2;
			cpuLevel = 4;
			matchArray = [
				{ opponent: "mario", stage: "galaxytours" },
				{ opponent: "kirby", stage: "rainbowroute" },
				{ opponent: "ichigo", stage: "huecomundo" },
				{ opponent: "lloyd", stage: "towerofsalvation" }
			];
		}
	}
}