package
{
	import flash.display.MovieClip;
	
	public class EventMode18_TargetRace extends EventMode_AllStarTargetMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode18_TargetRace(api:*)
		{
			super(api);
			
			playerLives = 1;
			matchArray = [
				{ targetMC: "btt", stage: "targettest" },
				{ targetMC: "btt", stage: "targettest2" },
				{ targetMC: "btt", stage: "targettest3" },
				{ targetMC: "btt", stage: "targettest4" }
			];
		}
	}
}