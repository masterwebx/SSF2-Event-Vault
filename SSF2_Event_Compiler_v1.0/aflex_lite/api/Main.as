// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//Main

package 
{
    import flash.display.Loader;
    import flash.events.Event;
    import flash.net.URLRequest;

    public dynamic class Main extends SSF2Asset 
    {

        private static var externalLoaded:Boolean = false;

        public var eventList:Array;

        public function Main():void
        {
            var _local_1:Loader;
            super();
            addFrameScript(0, this.frame1);
            register("id", "event_mode");
            register("guid", "d56c1d3c-f0dd-4c56-9dc4-6afe72a0de39");
            register("resources", {
                "movieclips":["allstar_icon_container", "cherish_ball", "pile_of_dirt", "Series_Metroid", "motherBrain_icon"],
                "sounds":[]
            });
            register("mode", EventMode);
            this.eventList = [];
            register("eventList", this.eventList);
            if (!externalLoaded)
            {
                _local_1 = new Loader();
                _local_1.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onExternalLoaded);
                _local_1.load(new URLRequest("custom_events.swf"));
                externalLoaded = true;
            };
        }

        private function onExternalLoaded(_arg_1:Event):void
        {
            var _local_4:Object;
            var _local_5:Boolean;
            var _local_6:Object;
            trace("onExternalLoaded called");
            trace("loaded URL:", _arg_1.target.url);
            var _local_2:* = _arg_1.target.content;
            trace("externalMain:", _local_2);
            trace("externalMain.eventList2:", _local_2.eventList2);
            if (_local_2.eventList2)
            {
                trace("eventList2 length:", _local_2.eventList2.length);
            };
            trace("externalMain.eventList:", _local_2.eventList);
            if (_local_2.eventList)
            {
                trace("eventList length:", _local_2.eventList.length);
            };
            var _local_3:Array;
            if (((_local_2) && (_local_2.eventList)))
            {
                _local_3 = _local_2.eventList;
            }
            else
            {
                if (((_local_2) && (_local_2.eventList2)))
                {
                    _local_3 = _local_2.eventList2;
                };
            };
            if (_local_3)
            {
                trace("external events length:", _local_3.length);
                if (_local_3.length > 0)
                {
                    trace("First external event id:", _local_3[0].id);
                    trace("First external event name:", _local_3[0].name);
                };
                trace("current eventList length before:", this.eventList.length);
                for each (_local_4 in _local_3)
                {
                    _local_5 = false;
                    for each (_local_6 in this.eventList)
                    {
                        if (_local_6.id == _local_4.id)
                        {
                            _local_5 = true;
                            break;
                        };
                    };
                    if (!_local_5)
                    {
                        this.eventList.push(_local_4);
                    };
                };
                trace("current eventList length after:", this.eventList.length);
                register("eventList", this.eventList);
            }
            else
            {
                trace("externalMain or external events is null/undefined");
            };
        }

        internal function frame1():*
        {
            stop();
        }


    }
}//package 

