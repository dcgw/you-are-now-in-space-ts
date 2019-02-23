package net.noiseinstitute.youarenowinspace.entities {
    import net.flashpunk.FP;
    import net.flashpunk.Sfx;
    import net.flashpunk.graphics.Spritemap;
    import net.noiseinstitute.youarenowinspace.YANISEntity;

    public class Alien extends YANISEntity {

        public static const WIDTH:uint = 24;
        public static const HEIGHT:uint = 17;

        private const FRAME_WIDTH:uint = WIDTH;
        private const FRAME_HEIGHT:uint = 21;

        [Embed(source = 'Alien.png')]
        private const ALIEN_SPRITEMAP:Class;

        [Embed(source="AlienSplode.mp3")]
        private const SPLODE_SOUND:Class;

        public static const RED:String = "red";
        public static const GREEN:String = "green";
        public static const BROWN:String = "brown";
        public static const GREY:String = "grey";

        private var _dead:Boolean = false;
        private var _inFormation:Boolean = true;

        private static const ASPLODE:String = "asplode";

        private var _animation:Spritemap = new Spritemap(ALIEN_SPRITEMAP, FRAME_WIDTH, FRAME_HEIGHT);
        public var onDie:Function;

        public function Alien (colour:String = RED) {
            width = WIDTH;
            height = HEIGHT;

            graphic = _animation;
            _animation.add(RED, [0,1,2,3,4,5], 0.25);
            _animation.add(GREEN, [7,8,9,10,11,12], 0.25);
            _animation.add(BROWN, [14,15,16,17,18,19], 0.25);
            _animation.add(GREY, [21,22,23,24,25,26], 0.25);
            _animation.add(ASPLODE, [28,29,30,31,32,33,34], 0.25);
            _animation.originY = 2;

            _animation.play(colour);

            type="deadly";
            setHitbox(WIDTH, HEIGHT);
        }

        public function get dead ():Boolean {
            return _dead;
        }

        public function get inFormation ():Boolean {
            return _inFormation;
        }

        public function breakFormation ():void {
            _inFormation = false;
        }

        override public function update ():void {
            super.update();

            if (!_dead) {
                // Have we been shot?
                var b:Bullet = collide("bullet", x, y) as Bullet;
                if (b) {
                    // Destroy the bullet
                    b.destroy();

                    _dead = true;
                    collidable = false;

                    _animation.play(ASPLODE);
                    var me:Alien = this;
                    _animation.callback = function():void {
                        FP.world.remove(me);
                    }

                    new Sfx(SPLODE_SOUND).play(0.75);

                    if (onDie != null) {
                        onDie();
                    }
                }
            }
        }
    }
}