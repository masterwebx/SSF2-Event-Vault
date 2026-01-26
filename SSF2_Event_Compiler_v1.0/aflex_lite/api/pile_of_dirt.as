// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//pile_of_dirt

package 
{
    import flash.display.MovieClip;

    public dynamic class pile_of_dirt extends MovieClip 
    {

        public var stance:MovieClip;
        public var xframe:String;
        public var type:String;
        public var classAPI:Class;

        public function pile_of_dirt()
        {
            addFrameScript(0, this.frame1);
        }

        internal function frame1():*
        {
            this.xframe = "idle";
            this.type = "enemy";
            this.classAPI = EventAsset_PileOfDirt;
            stop();
        }


    }
}//package 

