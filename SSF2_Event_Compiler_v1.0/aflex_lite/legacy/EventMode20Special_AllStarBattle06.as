package
{
	import flash.display.MovieClip;
	
	public class EventMode20Special_AllStarBattle06 extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode20Special_AllStarBattle06(api:*)
		{
			super(api);
			
			playerLives = 2;
			cpuLevel = 6;
			matchArray = [
				{ opponent: "sonic", stage: "greenhillzone" },
				{ opponent: "link", stage: "clocktown" },
				{ opponent: "naruto", stage: "konohavillage" }, 
				{ opponent: "megaman", stage: "skullfortress" },
				{ opponent: "sora", stage: "twilighttown" }
			];
		}
	}
}