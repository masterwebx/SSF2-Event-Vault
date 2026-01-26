package
{
	import flash.display.MovieClip;
	
	public class EventMode30Special_AllStarBattle07 extends EventMode_AllStarBattleMatch
	{
		//This match is the initializer - the player will never see this.
		//It is only here to return data to start the real matches.
		public function EventMode30Special_AllStarBattle07(api:*)
		{
			super(api);
			
			playerLives = 1;
			cpuLevel = 7;
			matchArray = [
				{ opponent: "ness", stage: "saturnvalley" },
				{ opponent: "tails", stage: "casinonightzone" },
				{ opponent: "goku", stage: "planetnamek" },
				{ opponent: "wario", stage: "emeraldcave" },
				{ opponent: "peach", stage: "peachscastle" },
				{ opponent: "blackmage", stage: "chaosshrine" }
			];
		}
	}
}

