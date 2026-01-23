// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//event_mode_fla.CherishBallIdle_5

package event_mode_fla
{
    import flash.display.MovieClip;
    import flash.geom.*;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.utils.*;
    import adobe.utils.*;
    import flash.accessibility.*;
    import flash.desktop.*;
    import flash.errors.*;
    import flash.external.*;
    import flash.globalization.*;
    import flash.media.*;
    import flash.net.*;
    import flash.net.drm.*;
    import flash.printing.*;
    import flash.profiler.*;
    import flash.sampler.*;
    import flash.sensors.*;
    import flash.system.*;
    import flash.text.*;
    import flash.text.ime.*;
    import flash.text.engine.*;
    import flash.ui.*;
    import flash.xml.*;

    public dynamic class CherishBallIdle_5 extends MovieClip 
    {

        public var attackBox:MovieClip;
        public var catchBox:MovieClip;
        public var hitBox:MovieClip;
        public var self:*;

        public function CherishBallIdle_5()
        {
            addFrameScript(0, this.frame1, 1, this.frame2, 14, this.frame15, 22, this.frame23, 23, this.frame24, 26, this.frame27, 29, this.frame30, 35, this.frame36, 41, this.frame42, 73, this.frame74, 74, this.frame75, 95, this.frame96, 101, this.frame102, 128, this.frame129);
        }

        internal function frame1():*
        {
            this.self = SSF2API.getItem(this);
            stop();
        }

        internal function frame2():*
        {
            gotoAndStop("begin");
        }

        internal function frame15():*
        {
            SSF2API.playSound("pokeball_land");
        }

        internal function frame23():*
        {
            stop();
        }

        internal function frame24():*
        {
            gotoAndStop("pause");
        }

        internal function frame27():*
        {
            this.self.attachEffect("global_spark");
        }

        internal function frame30():*
        {
            SSF2API.playSound("pokeball_open");
            this.self.attachEffect("masterball_effect");
        }

        internal function frame36():*
        {
            this.self.attachEffect("masterball_effect");
        }

        internal function frame42():*
        {
            this.self.attachEffect("masterball_effect");
        }

        internal function frame74():*
        {
            this.self.attachEffect("global_dust_cloud");
            this.self.destroy();
            stop();
        }

        internal function frame75():*
        {
            this.self.attachEffect("global_spark");
        }

        internal function frame96():*
        {
            this.self.attachEffect("global_dust_light");
        }

        internal function frame102():*
        {
            gotoAndStop("closeloop");
        }

        internal function frame129():*
        {
            this.self.attachEffect("global_dust_cloud");
            this.self.destroy();
            stop();
        }


    }
}//package event_mode_fla

